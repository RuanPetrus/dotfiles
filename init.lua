vim.pack.add {
	'https://github.com/nvim-treesitter/nvim-treesitter',
	-- 'https://github.com/morhetz/gruvbox',
	'https://github.com/ellisonleao/gruvbox.nvim',
	'https://github.com/stevearc/oil.nvim',
}

vim.o.number = true
vim.o.relativenumber = true
vim.o.shiftwidth = 4
vim.o.tabstop = 4
vim.g.mapleader = " "
vim.g.maplocalleader = " "

require('oil').setup()

vim.cmd.colorscheme('gruvbox')
vim.keymap.set('n', '<leader>', ':Oil<CR>', { silent = true })

-- vim.cmd('syntax off')

vim.api.nvim_create_autocmd('FileType', {
  pattern = { '<filetype>' },
  callback = function() vim.treesitter.start() end,
})

-- Copy to clipboard
vim.keymap.set("v", "<leader>y", '"+y', opts)
vim.keymap.set("x", "<leader>y", '"+y', opts)
vim.keymap.set("n", "<leader>Y", '"+yg_', opts)
vim.keymap.set("n", "<leader>y", '"+y', opts)
vim.keymap.set("n", "<leader>yy", '"+yy', opts)
