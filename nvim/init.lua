-- ~/.config/nvim/init.lua

-- 基础选项
vim.opt.number = true          -- 显示行号
vim.opt.relativenumber = true  -- 相对行号
vim.opt.expandtab = false       -- Tab 转空格
vim.opt.shiftwidth = 2         -- 缩进宽度
vim.opt.clipboard = "unnamed" -- 系统剪贴板"unnamedplus"为增加，"unnamed"为主选区，""关闭
vim.opt.list = true -- 显示不可见字符
vim.opt.showmode = false -- 关闭自带的模式显示
vim.opt.laststatus = 3 -- 状态栏全局常驻显示
vim.opt.cursorline = true -- 开启当前光标所在行高亮
vim.opt.termguicolors = true   -- 24 位真彩色支持
vim.opt.undofile = true -- 持久化撤销树
-- 键位映射
vim.g.mapleader = " "  -- 设置空格为 Leader 键
vim.keymap.set("n", "<leader>w", ":w<CR>", { desc = "保存文件" })
vim.keymap.set("n", "<leader>q", ":q<CR>", { desc = "退出" })
vim.keymap.set("n", "<leader>e", ":e!<CR>", { desc = "强制重载" })
vim.keymap.set("n", "<leader>z", "za")
-- 快速移动行
vim.keymap.set("v", "J", ":m '>+1<CR>gv") -- '>表示选区的最后一行,gv表示恢复上次选区,=表示自动缩进
vim.keymap.set("v", "K", ":m '<-2<CR>gv")
vim.keymap.set("n", "<leader>u", function()
  vim.cmd.packadd("nvim.undotree")
  vim.cmd.Undotree()
end, { desc = "显示撤销树"})
vim.keymap.set({ "n", "x", "o" }, "s", function()
  -- require("flash").setup()
  require("flash").jump()
end, { desc = "快速跳转" })

-- 自动折叠
vim.api.nvim_create_autocmd('FileType', {
  pattern = { 'lua', 'c' },
  callback = function(args)
    local win = vim.api.nvim_get_current_win()
    if vim.api.nvim_win_get_buf(win) ~= args.buf then
      return
    end

    vim.treesitter.start(args.buf)
    vim.wo[win].foldminlines = 10
    vim.wo[win].foldexpr = 'v:lua.vim.treesitter.foldexpr()'
    vim.wo[win].foldmethod = 'expr'

    -- 等一帧让 treesitter 完成初始折叠计算后，应用目标层级并锁定为 manual
    vim.schedule(function()
      if vim.api.nvim_win_is_valid(win) and vim.api.nvim_win_get_buf(win) == args.buf then
        -- vim.wo[win].foldlevel = 3 -- 按需调整，不想默认折叠可设为 99
        vim.wo[win].foldmethod = 'manual'
      end
    end)
  end,
})

if vim.tbl_flatten then --为nvim-colorizer.lua插件，兼容赋值tbl_flatten
  vim.tbl_flatten = function(t)
    return vim.iter(t):flatten():totable()
  end
end


-- 插件管理
vim.pack.add{
  { src = 'https://github.com/nvim-tree/nvim-web-devicons'}, -- 图标支持
  { src = "https://github.com/stevearc/oil.nvim"}, -- 文件夹内容编辑(文件管理)
  { src = "https://github.com/nvim-lualine/lualine.nvim"}, -- 状态栏
  { src = "https://github.com/catppuccin/nvim", name = "catppuccin"}, -- 颜色主题
  { src = "https://github.com/lukas-reineke/indent-blankline.nvim"}, -- 缩进线显示,自动加载
  { src = "https://gitlab.com/HiPhish/rainbow-delimiters.nvim"}, -- 彩色括号,自动加载
  { src = "https://github.com/catgoose/nvim-colorizer.lua"}, -- 颜色解析
  { src = "https://github.com/RRethy/vim-illuminate"}, -- 高亮相同词
  -- 补全引擎
  { src = "https://github.com/neovim/nvim-lspconfig"}, -- LSP 配置
  { src = "https://github.com/hrsh7th/nvim-cmp"}, -- 代码补全
  { src = "https://github.com/hrsh7th/cmp-nvim-lsp"}, -- 接收 LSP 补全数据
  { src = "https://github.com/hrsh7th/cmp-buffer"},   -- 当前缓冲区词补全
  { src = "https://github.com/hrsh7th/cmp-path"},     -- 文件路径补全
  }
vim.pack.add({
  { src = "https://github.com/folke/flash.nvim"}, --光标跳转
  { src = "https://github.com/lewis6991/gitsigns.nvim"}, -- 左侧显示文件修改提示,自动加载
  -- 外部程序管理
  { src = "https://github.com/williamboman/mason.nvim"},          -- 外部工具管理器
  { src = "https://github.com/williamboman/mason-lspconfig.nvim"},-- 桥接 mason 与 lspconfig
  { src = "https://github.com/hrsh7th/cmp-cmdline"},
},{load = false})


-- 插件配置
require('lualine').setup()

require("oil").setup()
require('rainbow-delimiters.setup').setup{
  highlight = {
    "RainbowDelimiterYellow",
    "RainbowDelimiterBlue",
    "RainbowDelimiterOrange",
    "RainbowDelimiterGreen",
    "RainbowDelimiterViolet",
    "RainbowDelimiterCyan",
    "RainbowDelimiterRed",
  }}
require("colorizer").setup()
require("catppuccin").setup{
  flavour = "mocha",
  transparent_background = true, -- 不设置背景色，让终端背景透出来
}
vim.cmd.colorscheme("catppuccin-frappe")

require("illuminate").configure({
  under_cursor = false,
  min_count_to_highlight = 2, -- 文件里至少出现 2 次相同的词才高亮
})
-- 设置相同词高亮
local hl = { bg = "#3b4252", underline = false }
vim.api.nvim_set_hl(0, "IlluminatedWordText", hl)
vim.api.nvim_set_hl(0, "IlluminatedWordRead", hl)
vim.api.nvim_set_hl(0, "IlluminatedWordWrite", hl)

require("ibl").setup({
  indent = {
    char = "│",
  },
  scope = {
    enabled = true,
    show_start = false,
    show_end = false,
  },
})

---------------------------------------- 触发填充选择框 ----------------------------------------
vim.o.updatetime = 250 -- 设置光标停留后触发的时间（单位：毫秒），250ms 是一个比较顺手的值
local diagnostic_float_group = vim.api.nvim_create_augroup("DiagnosticAutoFloat", { clear = true }) -- 创建自动命令组，避免重复定义
-- 在光标停止移动（CursorHold）和插入模式光标停止移动（CursorHoldI）时触发
vim.api.nvim_create_autocmd({ "CursorHold", "CursorHoldI" }, {
  group = diagnostic_float_group,
  callback = function()
    -- 调用 open_float，并设置 focus = false，防止光标自动跳入浮窗，打断输入
    vim.diagnostic.open_float(nil, { focus = false })
  end,
})
vim.diagnostic.config({
  virtual_text = {
    spacing = 4,
    prefix = "●",
  },
  signs = true,
  underline = true,
  update_in_insert = false,
})

---------------------------------------- cmp配置 ----------------------------------------
local cmp = require("cmp")
-- 1. 主补全配置（插入模式）
cmp.setup({
  window = {
    completion = cmp.config.window.bordered({
      scrollbar = false, -- 关闭补全窗口右侧滚动条
      border = "single", -- 默认"rounded"是圆角边框，也可改为 "single"、"double" "shadow"等
    }),
    documentation = cmp.config.window.bordered({
      scrollbar = false, -- 关闭文档弹窗右侧滚动条
    }),
  },
  sources = cmp.config.sources({
    { name = "nvim_lsp" }, -- LSP 补全
    { name = "buffer" },   -- 当前缓冲区词补全
    { name = "path" },     -- 路径补全
  }),
  mapping = cmp.mapping.preset.insert({
    ["<C-b>"] = cmp.mapping.scroll_docs(-4),
    ["<C-f>"] = cmp.mapping.scroll_docs(4),
    ["<C-Space>"] = cmp.mapping.complete(), -- 手动触发补全
    ["<C-e>"] = cmp.mapping.abort(),
    ["<CR>"] = cmp.mapping.abort(),
    ["<Tab>"] = cmp.mapping.confirm({ select = true }), -- Tab 确认补全
  }),
})
-- 2. 搜索框补全（/ 和 ?）
cmp.setup.cmdline({ "/", "?" }, {
  mapping = cmp.mapping.preset.cmdline(),
  sources = {
    { name = "buffer" },
  },
})
-- 3. 命令行补全（:）
cmp.setup.cmdline(":", {
  mapping = cmp.mapping.preset.cmdline(),
  sources = cmp.config.sources({
    { name = "path" },
  }, {
    { name = "cmdline" },
  }),
  matching = { disallow_symbol_nonprefix_matching = false },
})



-- 将 nvim-cmp 的 LSP 能力广播给所有 LSP 客户端
vim.lsp.config("*", {
  capabilities = require("cmp_nvim_lsp").default_capabilities(),
})

-- 自动命令 (Autocommands)
vim.api.nvim_create_autocmd("BufWritePre", {
  pattern = "*",
  callback = function()
    -- 保存前去除行尾空格
    vim.cmd([[%s/\s\+$//e]])
  end,
})




 ------自定义函数-------

local function setup_clangd_windows_gcc()

  local local_appdata = os.getenv("LOCALAPPDATA")
  if not local_appdata then
    return
  end

  local clangd_cfg_dir = local_appdata .. "\\clangd"
  local clangd_cfg_path = clangd_cfg_dir .. "\\config.yaml"

  -- 若已存在则不重复覆盖
  if vim.fn.filereadable(clangd_cfg_path) == 1 then
    return
  end

  vim.fn.mkdir(clangd_cfg_dir, "p")
  local content = table.concat({
    "CompileFlags:",
    "  Add:",
    '    - "--target=x86_64-w64-mingw32"',
    '    - "-isystemD:/Scoop/apps/gcc/current/include"',
    '    - "-isystemD:/Scoop/apps/gcc/current/x86_64-w64-mingw32/include"',
  }, "\n") .. "\n"

  vim.fn.writefile(vim.split(content, "\n", { plain = true }), clangd_cfg_path)
end

-- 配置mason
local function set_mason()
-- 初始化 mason
require("mason").setup()
require("mason-lspconfig").setup({
  ensure_installed = { "lua_ls", "clangd" },
})
-- 为 lua_ls 配置 Neovim 运行时
vim.lsp.config("lua_ls", {
  settings = {
    Lua = {
      diagnostics = {
        globals = { "vim" },
      },
      workspace = {
        library = { vim.env.VIMRUNTIME },
        checkThirdParty = false,
      },
    },
  },
})
end
------------------- 不同系统独立配置 ---------------------
local uname = vim.uv.os_uname()
local os_name = uname.sysname
local kernel_release = uname.release or ""

local function is_android()
  if kernel_release:lower():find("android", 1, true) then
    return true
  end
  if vim.env.ANDROID_ROOT or vim.env.TERMUX_VERSION then
    return true
  end
  if vim.uv.fs_stat("/system/build.prop") then
    return true
  end
  return false
end

if os_name == "Linux" then
    if is_android() then --Android
    vim.opt.clipboard = "" --关闭系统剪贴板
    else
      --Linux
    end
elseif os_name == "Windows_NT" then
    --Windows 专属配置
    setup_clangd_windows_gcc()
    set_mason()
end
