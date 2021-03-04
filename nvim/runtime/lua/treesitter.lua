require('nvim-treesitter.configs').setup {
  ensure_installed = { 'ruby', 'rust' }, -- one of "all", "maintained" (parsers with maintainers), or a list of languages
  highlight = {
    enable = true,
  },
}
