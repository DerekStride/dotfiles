local lspconfig = require('lspconfig')
local capabilities = require('cmp_nvim_lsp').update_capabilities(vim.lsp.protocol.make_client_capabilities())
local keymap = vim.keymap

local on_attach = function(client, bufnr)
  keymap.set("n", "K", vim.lsp.buf.hover, { buffer = bufnr, silent = true })
  keymap.set("n", "gd", vim.lsp.buf.definition, { buffer = bufnr, silent = true })
  keymap.set("n", "gT", vim.lsp.buf.type_definition, { buffer = bufnr, silent = true })
  keymap.set("n", "gi", "<cmd>Telescope lsp_implementations<cr>", { buffer = bufnr, silent = true })
  keymap.set("n", "gr", "<cmd>Telescope lsp_references<cr>", { buffer = bufnr, silent = true })
  keymap.set("n", "<leader>rn", vim.lsp.buf.rename, { buffer = bufnr, silent = true })
  keymap.set("n", "<leader>dl", "<cmd>Telescope diagnostics<cr>", { buffer = bufnr, silent = true })
  keymap.set("n", "<leader>dj", vim.diagnostic.goto_next, { buffer = bufnr, silent = true })
  keymap.set("n", "<leader>dk", vim.diagnostic.goto_prev, { buffer = bufnr, silent = true })
  keymap.set("n", "<leader>ca", vim.lsp.buf.code_action, { buffer = bufnr, silent = true })
end

lspconfig.rust_analyzer.setup {
  capabilities = capabilities,
  on_attach = on_attach,
}

lspconfig.tsserver.setup {
  capabilities = capabilities,
  on_attach = on_attach,
}

lspconfig.gopls.setup {
  capabilities = capabilities,
  on_attach = on_attach,
}

-- lspconfig.sorbet.setup {
--   cmd = {"bundle", "exec", "srb", "tc", "--lsp"},
--   capabilities = capabilities,
--   -- on_attach = on_attach,
-- }

-- set the path to the sumneko installation; if you previously installed via the now deprecated :LspInstall, use
local sumneko_root_path = vim.env.PROJECTS..'/github.com/sumneko/lua-language-server'
local sumneko_binary = "lua-language-server"

lspconfig.sumneko_lua.setup {
  cmd = {sumneko_binary, "-E", sumneko_root_path .. "/main.lua"};
  capabilities = capabilities,
  on_attach = on_attach,
  settings = {
    Lua = {
      runtime = {
        -- Tell the language server which version of Lua you're using (most likely LuaJIT in the case of Neovim)
        version = 'LuaJIT',
        -- Setup your lua path
        path = vim.split(package.path, ';'),
      },
      diagnostics = {
        -- Get the language server to recognize the `vim` global
        globals = {'vim', 'describe', 'it', 'use'},
      },
      workspace = {
        -- Make the server aware of Neovim runtime files
        library = {
          [vim.fn.expand('$VIMRUNTIME/lua')] = true,
          [vim.fn.expand('$VIMRUNTIME/lua/vim/lsp')] = true,
        },
      },
    },
  },
}
