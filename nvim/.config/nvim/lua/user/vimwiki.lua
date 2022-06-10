use {
    'vimwiki/vimwiki',
    config = function()
        vim.g.vimwiki_list = {
            {
                path = '$HOME/Documents/notes/vimwiki',
                syntax = 'markdown',
                ext = '.md',
            }
        }
    end
}
