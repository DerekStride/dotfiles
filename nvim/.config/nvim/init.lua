--        __               __        __       _     __
--   ____/ /__  ________  / /_______/ /______(_)___/ /__
--  / __  / _ \/ ___/ _ \/ //_/ ___/ __/ ___/ / __  / _ \  Derek Stride
-- / /_/ /  __/ /  /  __/  < (__  ) /_/ /  / / /_/ /  __/  github.com/derekstride
-- \____/\___/_/   \___/_/|_/____/\__/_/  /_/\____/\___/

local cmd = vim.cmd

vim.g.mapleader = ' '

--Append custom runtime path from my dotfiles
cmd('set runtimepath^=$ZSH/nvim/runtime')
cmd('set runtimepath+=$ZSH/nvim/runtime/after')

require('derek')

cmd('silent! colorscheme dracula')
