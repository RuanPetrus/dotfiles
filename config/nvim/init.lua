vim.g.mapleader = " "

vim.opt.number = true
vim.opt.relativenumber = true
vim.opt.signcolumn = "yes"
vim.opt.ignorecase = true
vim.opt.smartcase = true
vim.opt.splitbelow = true
vim.opt.splitright = true
vim.opt.shiftwidth = 4
vim.opt.tabstop = 4
vim.opt.swapfile = false
vim.opt.undofile = true
vim.opt.updatetime = 250
vim.opt.timeoutlen = 300

vim.pack.add({
  "https://github.com/stevearc/oil.nvim",
  "https://github.com/nvim-treesitter/nvim-treesitter",
  "https://github.com/nvim-lua/plenary.nvim",
  "https://github.com/nvim-telescope/telescope.nvim",
  "https://github.com/ellisonleao/gruvbox.nvim",
  "https://github.com/lewis6991/gitsigns.nvim",
})

vim.o.background = "dark"
vim.cmd.colorscheme("gruvbox")

require("nvim-treesitter").install({
  "bash",
  "c",
  "cpp",
  "css",
  "html",
  "javascript",
  "json",
  "lua",
  "markdown",
  "markdown_inline",
  "python",
  "query",
  "typescript",
  "vim",
  "vimdoc",
  "yaml",
  "rust",
  "go",
})

vim.api.nvim_create_autocmd("FileType", {
  callback = function(args)
    local language = vim.treesitter.language.get_lang(vim.bo[args.buf].filetype)
    if language then
      pcall(vim.treesitter.start, args.buf, language)
    end
  end,
})

vim.lsp.config("basedpyright", {
  cmd = { "basedpyright-langserver", "--stdio" },
  filetypes = { "python" },
  root_markers = { "pyproject.toml", "setup.py", "setup.cfg", "requirements.txt", ".git" },
})

vim.lsp.config("clangd", {
  cmd = { "clangd" },
  filetypes = { "c", "cpp" },
  root_markers = { "compile_commands.json", "compile_flags.txt", ".clangd", ".git" },
})

vim.lsp.config("rust_analyzer", {
  cmd = { "rust-analyzer" },
  filetypes = { "rust" },
  root_markers = { "Cargo.toml", "rust-project.json", ".git" },
})

vim.lsp.enable({ "basedpyright", "clangd", "rust_analyzer" })

vim.api.nvim_create_autocmd("LspAttach", {
  callback = function(args)
    local client = vim.lsp.get_client_by_id(args.data.client_id)
    vim.lsp.completion.enable(true, client.id, args.buf, { autotrigger = false })

    local map = function(lhs, rhs, desc)
      vim.keymap.set("n", lhs, rhs, { buffer = args.buf, desc = desc })
    end

    map("gd", vim.lsp.buf.definition, "Go to definition")
    map("gr", vim.lsp.buf.references, "References")
    map("K", vim.lsp.buf.hover, "Hover documentation")
    map("<leader>rn", vim.lsp.buf.rename, "Rename")
    map("<leader>ca", vim.lsp.buf.code_action, "Code action")

    vim.keymap.set("i", "<C-n>", function()
      if vim.fn.pumvisible() == 1 then
        return "<C-n>"
      end
      vim.lsp.completion.get()
    end, { buffer = args.buf, expr = true, desc = "Next suggestion" })

    vim.keymap.set("i", "<C-p>", function()
      if vim.fn.pumvisible() == 1 then
        return "<C-p>"
      end
      vim.lsp.completion.get()
    end, { buffer = args.buf, expr = true, desc = "Previous suggestion" })
  end,
})

require("oil").setup({
  default_file_explorer = true,
  view_options = { show_hidden = true },
})

require("gitsigns").setup()

local telescope = require("telescope.builtin")

-- Movement
vim.keymap.set("n", "<S-h>", "<cmd>bprevious<cr>", { desc = "Previous buffer" })
vim.keymap.set("n", "<S-l>", "<cmd>bnext<cr>", { desc = "Next buffer" })

-- commands
vim.keymap.set({ "n", "x" }, "<leader>y", '"+y', { desc = "Yank to system clipboard" })
vim.keymap.set("n", "<leader>e", "<cmd>Oil<cr>", { desc = "Open file explorer" })
vim.keymap.set("n", "<leader>ff", telescope.find_files, { desc = "Find files" })
vim.keymap.set("n", "<leader>fg", telescope.live_grep, { desc = "Find text" })
vim.keymap.set("n", "<leader>fb", telescope.buffers, { desc = "Find buffers" })
vim.keymap.set("n", "<leader>fh", telescope.help_tags, { desc = "Find help" })
vim.keymap.set("n", "<leader>/", telescope.current_buffer_fuzzy_find, { desc = "Find in buffer" })
vim.keymap.set("n", "]c", function() require("gitsigns").nav_hunk("next") end, { desc = "Next Git change" })
vim.keymap.set("n", "[c", function() require("gitsigns").nav_hunk("prev") end, { desc = "Previous Git change" })
vim.keymap.set("n", "<leader>gp", require("gitsigns").preview_hunk, { desc = "Preview Git change" })
vim.keymap.set("n", "<leader>gd", require("gitsigns").diffthis, { desc = "Git diff" })
vim.keymap.set("n", "<leader>gr", require("gitsigns").reset_hunk, { desc = "Reset Git hunk" })
vim.keymap.set("n", "<leader>gR", require("gitsigns").reset_buffer, { desc = "Reset Git buffer" })
vim.keymap.set("n", "<leader>gs", require("gitsigns").stage_hunk, { desc = "Stage Git hunk" })
vim.keymap.set("n", "<leader>gu", require("gitsigns").undo_stage_hunk, { desc = "Undo staged Git hunk" })
