return {
	{
		'nvim-treesitter/nvim-treesitter',
		dependencies = {
			'nvim-treesitter/nvim-treesitter-textobjects',
		},
		opts = { ensure_installed = {} },
		build = ':TSUpdate',
		config = function()
			require 'nvim-treesitter.configs'.setup {
				modules = {},
				sync_install = false,
				auto_install = false,
				ignore_install = {},
				ensure_installed = {},
				highlight = {
					enable = true,
					additional_vim_regex_highlighting = true,
				},
				indent = { enable = true },
			}
		end,
	},
}
