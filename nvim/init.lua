vim.g.mapleader = ' '
vim.g.maplocalleader = ' '

-- Plugin Manager
local lazypath = vim.fn.stdpath 'data' .. '/lazy/lazy.nvim'
if not vim.loop.fs_stat(lazypath) then
  vim.fn.system {
    'git',
    'clone',
    '--filter=blob:none',
    'https://github.com/folke/lazy.nvim.git',
    '--branch=stable', -- latest stable release
    lazypath,
  }
end
vim.opt.rtp:prepend(lazypath)

-- [[ Configure plugins ]]
require('lazy').setup({
  -- Detect tabstop and shiftwidth automatically
  'tpope/vim-sleuth',

  -- Colorscheme
  { 
    "ellisonleao/gruvbox.nvim", 
    lazy = false,
    config = function() 
	    require("gruvbox").setup({
		    -- transparent_mode = true,
		    constrast = "soft",
	    })

	    vim.o.background = "dark",
	    vim.cmd("colorscheme gruvbox")
    end,
  },

  -- Snippet engine
  {
    'L3MON4D3/LuaSnip',
    build = (function()
      if vim.fn.has 'win32' == 1 then
        return
      end
      return 'make install_jsregexp'
    end)(),
  },

  {
    -- Autocompletion
    'hrsh7th/nvim-cmp',
    dependencies = {
      -- Snippet Engine engine
      'saadparwaiz1/cmp_luasnip',
      'hrsh7th/cmp-path',
    },
  },

  -- Highlight, edit, and navigate code
  {
    'nvim-treesitter/nvim-treesitter',
    dependencies = {
	    'nvim-treesitter/nvim-treesitter-textobjects',
    },
    build = ':TSUpdate',
  },

  -- Competitive Programming
  {
    'xeluxee/competitest.nvim',
    dependencies = 'MunifTanjim/nui.nvim',
    cmd = {"CompetiTest"},
    keys = {
      { "<leader>cc" , "<cmd>CompetiTest run<cr>", desc = "CompetiTest run"},
    },
    config = function() require('competitest').setup({
      popup_ui = {
	total_width = 1,
	total_height = 1,
      },
      runner_ui = {
	viewer = {
	  width = 1,
	  height = 1,
	},
      },
      received_problems_path = "$(CWD)/$(JAVA_TASK_CLASS).$(FEXT)",
      received_contests_problems_path = "$(JAVA_TASK_CLASS).$(FEXT)",
      compile_command = {
	cpp = { exec = "g++", args = { "-Wall", "-Wextra", "-std=c++20", 
	                               "-ggdb", "-fsanitize=address,undefined", 
	                               "$(FNAME)", "-o", "$(FNOEXT)" } },
      },
    }) end,
  } 
}, {})

-- [[ Configure Treesitter ]]
vim.defer_fn(function()
  require('nvim-treesitter.configs').setup {
    ensure_installed = { 'c', 'cpp', 'go', 'lua', 'python', 'rust', 'tsx', 'javascript', 'typescript', 'vimdoc', 'vim', 'bash' },
    auto_install = false,
    sync_install = false,
    ignore_install = {},
    modules = {},
    highlight = { enable = true },
    indent = { enable = true },
  }
end, 0)

vim.opt.backup = false                          -- creates a backup file
vim.opt.cmdheight = 1                           -- more space in the neovim command line for displaying messages
vim.opt.conceallevel = 0                        -- so that `` is visible in markdown files
vim.opt.hlsearch = true                         -- highlight all matches on previous search pattern
vim.opt.ignorecase = true                       -- ignore case in search patterns
vim.opt.mouse = "a"                             -- allow the mouse to be used in neovim
vim.opt.pumheight = 10                          -- pop up menu height
vim.opt.showmode = false                        -- we don't need to see things like -- INSERT -- anymore
vim.opt.showtabline = 0                         -- always show tabs
vim.opt.smartcase = true                        -- smart case
vim.opt.smartindent = true                      -- make indenting smarter again
vim.opt.splitbelow = true                       -- force all horizontal splits to go below current window
vim.opt.splitright = true                       -- force all vertical splits to go to the right of current window
vim.opt.swapfile = false                        -- creates a swapfile
vim.opt.termguicolors = true                    -- set term gui colors (most terminals support this)
vim.opt.timeoutlen = 1000                       -- time to wait for a mapped sequence to complete (in milliseconds)
vim.opt.undofile = true                         -- enable persistent undo
vim.opt.updatetime = 300                        -- faster completion (4000ms default)
vim.opt.writebackup = false                     -- if a file is being edited by another program (or was written to file while editing with another program), it is not allowed to be edited
vim.opt.shiftwidth = 4                          -- the number of spaces inserted for each indentation
vim.opt.tabstop = 4                             -- insert 2 spaces for a tab
vim.opt.cursorline = true                       -- highlight the current line
vim.opt.number = true                           -- set numbered lines
vim.opt.relativenumber = true                           -- set numbered lines
vim.opt.numberwidth = 4                         -- set number column width to 2 {default 4}
vim.opt.signcolumn = "yes"                      -- always show the sign column, otherwise it would shift the text each time
vim.opt.wrap = false                            -- display lines as one long line
vim.opt.scrolloff = 8                           -- is one of my fav
vim.opt.sidescrolloff = 8

local opts = { silent = true }

-- Better window navigation
vim.keymap.set("n", "<C-h>", "<C-w>h", opts)
vim.keymap.set("n", "<C-j>", "<C-w>j", opts)
vim.keymap.set("n", "<C-k>", "<C-w>k", opts)
vim.keymap.set("n", "<C-l>", "<C-w>l", opts)


-- Navigate buffers
vim.keymap.set("n", "<S-l>", ":bnext<CR>", opts)
vim.keymap.set("n", "<S-h>", ":bprevious<CR>", opts)
-- Close buffers
vim.keymap.set("n", "<S-q>", "<cmd>Bdelete!<CR>", opts)

-- Clear highlights
vim.keymap.set("n", "<leader>h", "<cmd>nohlsearch<CR>", opts)

-- Copy to clipboard
vim.keymap.set("v", "<leader>y", '"+y', opts)
vim.keymap.set("x", "<leader>y", '"+y', opts)
vim.keymap.set("n", "<leader>Y", '"+yg_', opts)
vim.keymap.set("n", "<leader>y", '"+y', opts)
vim.keymap.set("n", "<leader>yy", '"+yy', opts)

-- Edit files
vim.keymap.set("n", "<leader>fs", ":edit ~/.config/nvim/snippets/cpp/<CR>", opts)
vim.keymap.set("n", "<leader>fc", ":edit ~/.config/nvim/init.lua<CR>", opts)



-- Snippets
require("luasnip.loaders.from_snipmate").lazy_load()
-- Cmp
local cmp = require 'cmp'

cmp.setup {
  snippet = {
    expand = function(args)
      luasnip.lsp_expand(args.body)
    end,
  },
  completion = {
    --  completeopt = 'menu,menuone,noinsert',
    completeopt = 'menu,menuone,noinsert',
    autocomplete=false,
  },
  mapping = cmp.mapping.preset.insert {
    ['<CR>'] = cmp.mapping.confirm {
      behavior = cmp.ConfirmBehavior.Replace,
      select = true,
    },
    ['<C-j>'] = cmp.mapping(function(fallback)
      if cmp.visible() then
        cmp.select_next_item()
      else
        cmp.complete()
      end
    end, { 'i', 's' }),
    ['<C-k>'] = cmp.mapping(function(fallback)
      if cmp.visible() then
        cmp.select_prev_item()
      else
        cmp.complete()
      end
    end, { 'i', 's' }),
  },
  sources = {
    { name = 'luasnip' },
    { name = 'path' },
  },
}
