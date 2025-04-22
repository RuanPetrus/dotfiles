return {
	{
		"neovim/nvim-lspconfig",
		dependencies = {
			{
				"folke/lazydev.nvim",
				ft = "lua", -- only load on lua files
				opts = {
					library = {
						-- See the configuration section for more details
						-- Load luvit types when the `vim.uv` word is found
						{ path = "${3rd}/luv/library", words = { "vim%.uv" } },
					},
				},
			},
			-- Setup null-ls with `black`
			{
				"jose-elias-alvarez/null-ls.nvim",
				-- opts = function()
				-- 	return require "config.plugins.null-ls"
				-- end,
			},
			{ -- optional blink completion source for require statements and module annotations
				"saghen/blink.cmp",
				build = "nix run .#build-plugin",
				dependencies = { 'L3MON4D3/LuaSnip', version = 'v2.*' },
				opts = {
					snippets = { preset = 'luasnip' },
					keymap = {
						preset = 'default',
						['<C-n>'] = {
							'show', 'select_next'
						},
						['<C-p>'] = {
							'show', 'select_prev'
						},
						['<CR>'] = { 'accept', 'fallback' },
						['<C-y>'] = { 'show_signature', 'hide_signature', 'fallback' },
					},
					appearance = {
						-- 'mono' (default) for 'Nerd Font Mono' or 'normal' for 'Nerd Font'
						-- Adjusts spacing to ensure icons are aligned
						nerd_font_variant = 'mono'
					},
					sources = {
						-- add lazydev to your completion providers
						default = { "lazydev", "lsp", "path", "snippets", "buffer" },
						providers = {
							lazydev = {
								name = "LazyDev",
								module = "lazydev.integrations.blink",
								-- make lazydev completions top priority (see `:h blink.cmp`)
								score_offset = 100,
							},
						},
					},
					fuzzy = {
						implementation = "prefer_rust_with_warning",
					},
					completion = {
						-- 'prefix' will fuzzy match on the text before the cursor
						-- 'full' will fuzzy match on the text before _and_ after the cursor
						-- example: 'foo_|_bar' will match 'foo_' for 'prefix' and 'foo__bar' for 'full'
						keyword = { range = 'full' },

						-- Disable auto brackets
						-- NOTE: some LSPs may add auto brackets themselves anyway
						accept = { auto_brackets = { enabled = false }, },

						-- Don't select by default, auto insert on selection
						list = { selection = { preselect = false, auto_insert = false } },

						menu = {
							-- Don't automatically show the completion menu
							auto_show = false,
						},
					},
				},
			},
		},
		config = function()
			local capabilities = require('blink.cmp').get_lsp_capabilities()

			require("lspconfig").lua_ls.setup { capabilities = capabilities }
			require("lspconfig").nixd.setup({
				capabilities = capabilities,
				settings = {
					nixd = {
						nixpkgs = {
							expr = "import <nixpkgs> { }",
						},
						formatting = {
							command = { "alejandra" },
						},
					},
				},
			})
			require("lspconfig").pyright.setup({
				capabilities = capabilities,
				settings = {
					python = {
						formatting = {
							command = { "black" },
						},
					},
				},
			})

			vim.api.nvim_create_autocmd('LspAttach', {
				callback = function(args)
					local c = vim.lsp.get_client_by_id(args.data.client_id)
					if not c then return end

					-- Format the current buffer on save
					vim.api.nvim_create_autocmd('BufWritePre', {
						buffer = args.buf,
						callback = function()
							vim.lsp.buf.format({ bufnr = args.buf, id = c.id })
						end,
					})
				end,
			})
		end,
	},
}
