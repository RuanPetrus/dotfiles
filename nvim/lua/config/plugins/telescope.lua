return {
	{
		'nvim-telescope/telescope.nvim',
		dependencies = { 'nvim-lua/plenary.nvim' },
		config = function()
			require("telescope").setup {
				pickers = {
					find_files = {
						theme = "ivy",
					},
				},
			}
			vim.keymap.set("n", "<space>fh", require("telescope.builtin").help_tags)
			vim.keymap.set("n", "<space>ff", require("telescope.builtin").find_files)
			vim.keymap.set("n", "<space>fc", function()
				require("telescope.builtin").find_files {
					cwd = vim.fn.stdpath("config")
				}
			end)
			vim.keymap.set("n", "<space>fd", function()
				require("telescope.builtin").find_files {
					cwd = "~/dotfiles"
				}
			end)
			vim.keymap.set("n", "<space>fn", function()
				require("telescope.builtin").find_files {
					cwd = "~/Documents/notes"
				}
			end)
		end
	}
}
