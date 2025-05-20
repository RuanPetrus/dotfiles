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
				sync_install = true,
				auto_install = false,
				ignore_install = {},
				ensure_installed = { "lua", "luadoc", "vim", "vimdoc", "query", "c", "cpp", "python", "cuda", "nix", "bash", "markdown", "markdown_inline" },
				highlight = {
					enable = true,
					additional_vim_regex_highlighting = true,
				},
				indent = { enable = true },
			}
		end,
	},
}
