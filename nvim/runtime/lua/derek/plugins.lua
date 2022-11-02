vim.fn.setenv("MACOSX_DEPLOYMENT_TARGET", "10.15")

return require('packer').startup(function()
  -- Packer can manage itself as an optional plugin
  use { 'wbthomason/packer.nvim' }

  --fzf + ripgrep is what I used to navigate codebases; find my configuration in
  --$ZSH/nvim/runtime/plugin/fzf.vim
  use { 'junegunn/fzf.vim' }
  use { 'junegunn/fzf', run = './install --all' }

  --Add my favourite colorscheme
  use { 'dracula/vim', as = 'dracula' }

  --`gcc` comments out a single line
  use { 'https://tpope.io/vim/commentary' }

  --tmux aware pane / split switching
  use { 'christoomey/vim-tmux-navigator' }

  --tmux scripting from vim
  use { 'benmills/vimux' }

  --Configure the neovim language server client; find my configuration in
  --$ZSH/nvim/runtime/plugin/lsp.vim
  use { 'hrsh7th/nvim-cmp' }
  use { "hrsh7th/cmp-nvim-lua" }
  use { 'hrsh7th/cmp-nvim-lsp' }
  use { 'hrsh7th/cmp-buffer' }
  use { 'hrsh7th/cmp-path' }
  use { 'onsails/lspkind-nvim' }
  use { 'neovim/nvim-lspconfig' }
  use { 'L3MON4D3/LuaSnip' }
  use { 'nvim-lua/lsp_extensions.nvim' }

  -- Co-pilot
  use {
    'github/copilot.vim',
    branch = "release",
    config = function()
      local sysname = vim.loop.os_uname().sysname
      if sysname == "Darwin" then
        vim.g.copilot_node_command = vim.fs.find("node", { path = "/opt/homebrew/Cellar/node@16" })[1]
      end
    end
  }

  --Add tree-sitter for better highlighting
  use { 'nvim-treesitter/nvim-treesitter', run = ':TSUpdate' }
  -- use { '$PROJECTS/github.com/nvim-treesitter/nvim-treesitter', run = ':TSUpdate' }
  use { 'nvim-treesitter/completion-treesitter' }
  -- Useful for :TSHighlightCapturesUnderCursor and :TSPlaygroundToggle to see
  -- how tree-sitter is parsing the file.
  use { 'nvim-treesitter/playground' }

  --Telescope for pure lua, scriptable fuzzy finding.
  use { 'nvim-lua/popup.nvim' }
  use { 'nvim-lua/plenary.nvim' }
  use { 'nvim-telescope/telescope.nvim' }
  use { 'nvim-telescope/telescope-fzy-native.nvim' }
end)
