return {
	{
		-- Autocompletion
		'hrsh7th/nvim-cmp',
		lazy = false,
		priority = 100,
		dependencies = {
			-- Snippet Engine engine
			'hrsh7th/cmp-path',
			'hrsh7th/cmp-nvim-lsp',
			'hrsh7th/cmp-buffer',
			{ 'L3MON4D3/LuaSnip', build = 'make install_jsregexp' },
			'saadparwaiz1/cmp_luasnip',
		},
		config = function()
			-- Snippets
			require("luasnip.loaders.from_snipmate").lazy_load(
				{
					path = { "~/.config/nvim/snippets" }
				}
			)
			-- Cmp
			local cmp = require 'cmp'

			cmp.setup {
				snippet = {
					expand = function(args)
						require("luasnip").lsp_expand(args.body)
					end,
				},
				completion = {
					--  completeopt = 'menu,menuone,noinsert',
					completeopt = 'menu,menuone,noinsert',
					autocomplete = false,
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
					{
						name = 'lazydev',
						-- set group index to 0 to skip loading LuaLS completions as lazydev recommends it
						group_index = 0,
					},
					{ name = 'nvim_lsp' },
					{ name = 'luasnip' },
					{ name = 'path' },
					{ name = 'buffer' },
				},
			}
		end,
	},
}
