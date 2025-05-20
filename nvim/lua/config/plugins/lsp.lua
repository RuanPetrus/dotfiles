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
			-- {
			-- 	"jose-elias-alvarez/null-ls.nvim",
			-- 	-- opts = function()
			-- 	-- 	return require "config.plugins.null-ls"
			-- 	-- end,
			-- },
		},
		config = function()
			local capabilities = vim.lsp.protocol.make_client_capabilities()
			capabilities = vim.tbl_deep_extend('force', capabilities, require('cmp_nvim_lsp').default_capabilities())
			require("lspconfig").lua_ls.setup { capabilities = capabilities, }
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
			require("lspconfig").pyright.setup { capabilities = capabilities, }

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
