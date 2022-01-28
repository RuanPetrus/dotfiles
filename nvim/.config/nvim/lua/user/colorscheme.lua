local colorscheme = "dracula"

vim.g.nord_contrast = true
vim.g.nord_borders = false
vim.g.nord_disable_background = true
vim.g.nord_italic = true
vim.g.nord_enable_sidebar_background = true

vim.cmd[[let g:gruvbox_contrast_dark = 'medium']]
vim.cmd[[let g:gruvbox_transparent_bg = '1']]

local status_ok, _ = pcall(vim.cmd, "colorscheme " .. colorscheme)
if not status_ok then
  vim.notify("colorscheme " .. colorscheme .. " not found!")
  return
end
