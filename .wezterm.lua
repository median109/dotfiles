local wezterm = require("wezterm")
local config = wezterm.config_builder()

-- 1. 字体：WezTerm 默认已包含 Nerd Font 符号，无需特殊字体即可显示图标
config.font = wezterm.font("JetBrains Mono") -- 换成你喜欢的字体
config.font_size = 12.0

config.set_environment_variables = {
	LANG = "zh_CN.UTF-8",
	LC_ALL = "zh_CN.UTF-8",
}

-- 2. 配色方案
config.color_scheme = "Breeze" -- 可替换为 'Dracula', 'Tokyo Night','Batma', 'Catppuccin Mocha', 'Afterglow', 'Andromeda'等

-- 3. 窗口初始大小与内边距
config.initial_cols = 120
config.initial_rows = 30
config.window_padding = {
	left = 0,
	right = 0,
	top = 0,
	bottom = 0,
}

--[[
config.cursor_smear = true
config.cursor_smear_gradient = true
config.cursor_animation_duration = 0.15
config.cursor_trail_size = 1.0
config.cursor_trail_min_distance = 0
]]

-- 4. 背景透明度（0.0 完全透明，1.0 完全不透明）
--config.window_background_opacity = 0.99

-- 光标样式: SteadyBlock, BlinkingBlock, SteadyBar, BlinkingBar 等
config.default_cursor_style = "BlinkingBlock"
-- 闪烁频率 (毫秒，设置为 0 关闭闪烁)
config.cursor_blink_rate = 800
-- 动画帧率
config.animation_fps = 1
-- 关键设置：将“出现”和“消失”的缓动函数都设为 Constant
config.cursor_blink_ease_in = "Constant"
config.cursor_blink_ease_out = "Constant"

-- 无边框窗口
config.window_decorations = "NONE"--"RESIZE"
config.hide_tab_bar_if_only_one_tab = true
config.show_new_tab_button_in_tab_bar = false
config.use_fancy_tab_bar = false

-- ctrl+-调整字体时，禁用窗口自动缩放
config.adjust_window_size_when_changing_font_size = false

-- 开启视觉响铃：触发时让窗口背景闪烁一下
config.visual_bell = {
	-- 可以选择闪烁方式，比如淡出、反转颜色等
	fade_in_function = "EaseIn",
	fade_in_duration_ms = 150,
	fade_out_function = "EaseOut",
	fade_out_duration_ms = 150,
	target = "BackgroundColor",
}

-- 变色
-- 辅助函数：判断当前窗格是否处于 SSH 状态
local function is_ssh_pane(pane)
	-- 1. 检查 WezTerm 的 domain 是否包含 ssh
	local domain = pane:get_domain_name()
	if domain and domain:lower():find("ssh") then
		return true
	end

	-- 2. 检查本地终端的前台进程是否为 ssh (如在 PowerShell/CMD/Fish 中手动执行 ssh)
	local info = pane:get_foreground_process_info()
	if info then
		if info.executable and info.executable:lower():match("ssh") then
			return true
		end
		if info.argv and info.argv[1] and info.argv[1]:lower():match("ssh") then
			return true
		end
	end

	return false
end

wezterm.on("update-status", function(window, pane)
	local overrides = window:get_config_overrides() or {}

	if is_ssh_pane(pane) then
		-- 在 SSH 时强制开启标签栏（打破单标签自动隐藏的限制）
		overrides.hide_tab_bar_if_only_one_tab = false

		-- 设置右侧状态提示
		window:set_right_status(wezterm.format({
			{ Background = { Color = "deeppink" } },
			{ Foreground = { Color = "white" } },
			{ Text = " [SSH] " },
		}))
	else
		-- 本地会话时清空右侧状态栏
		window:set_right_status("")
		-- 本地会话时恢复全局的单标签自动隐藏
		overrides.hide_tab_bar_if_only_one_tab = nil
	end
	-- 动态生效
	window:set_config_overrides(overrides)
end)

--关闭选中就复制，启用右键复制
config.mouse_bindings = {
	--覆盖左键行为，阻止自动复制
	{
		event = { Up = { streak = 1, button = "Left" } },
		mods = "NONE",
		-- 使用 NOP（什么都不做）或者交给系统原生的纯文本选中逻辑，
		-- 但在 WezTerm 中，直接用 action_callback 捕获并只做基础选择，
		-- 可以有效阻止默认的 CopyTo Clipboard 行为。
		action = wezterm.action.Nop,
	},
	-- 覆盖右键行为：如果当前有选中文本，右键点击则复制并清除选中；如果没有选中，则执行粘贴
	{
		event = { Down = { streak = 1, button = "Right" } },
		mods = "NONE",
		action = wezterm.action_callback(function(window, pane)
			local has_selection = window:get_selection_text_for_pane(pane) ~= ""
			if has_selection then
				-- 有选中内容时：复制到剪贴板，并清除选中状态
				window:perform_action(wezterm.action.CopyTo("ClipboardAndPrimarySelection"), pane)
				window:perform_action(wezterm.action.ClearSelection, pane)
			else
				-- 没有选中内容时：执行标准的右键粘贴
				window:perform_action(wezterm.action.PasteFrom("Clipboard"), pane)
			end
		end),
	},
}

-- 绑定 Ctrl + Shift + 左右方向键切换标签页
config.keys = {
	-- Ctrl + Shift + 左方向键：切换到左侧标签页
	{
		key = "LeftArrow",
		mods = "CTRL|SHIFT",
		action = wezterm.action.ActivateTabRelative(-1),
	},
	-- Ctrl + Shift + 右方向键：切换到右侧标签页
	{
		key = "RightArrow",
		mods = "CTRL|SHIFT",
		action = wezterm.action.ActivateTabRelative(1),
	},
	{
		key = "Enter",
		mods = "CTRL|SHIFT",
		action = wezterm.action.ShowLauncher,
	},
}

-- 配置本地 Shell 菜单
config.launch_menu = {
	{
		label = "PowerShell",
		args = { "powershell.exe" },
	},
	{
		label = "Pwsh",
		args = { "pwsh.exe" },
	},
	{
		label = "Git Bash",
		args = { "D:\\Scoop\\apps\\git\\current\\bin\\bash.exe" },
	},
	{
		label = "CMD",
		args = { "cmd.exe" },
	},
	{
		label = "Nushell",
		args = { "nu.exe" },
	},
}
config.default_prog = { "nu.exe" }

return config
