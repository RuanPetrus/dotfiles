local colorscheme = "gruvbox"
vim.cmd([[ let g:gruvbox_transparent_bg = '1' ]])

local status_ok, _ = pcall(vim.cmd, "colorscheme " .. colorscheme)
if not status_ok then
  vim.notify("colorscheme " .. colorscheme .. " not found!")
  return
else
    vim.cmd([[ highlight Normal ctermbg=NONE guibg=NONE ]])
end
