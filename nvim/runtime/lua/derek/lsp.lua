local capabilities = require('cmp_nvim_lsp').default_capabilities(vim.lsp.protocol.make_client_capabilities())

require("mason").setup()
require("mason-lspconfig").setup()
require("neodev").setup()

local keymap = vim.keymap

local on_attach = function(client, bufnr)
  keymap.set("n", "K", vim.lsp.buf.hover, { buffer = bufnr, silent = true })
  keymap.set("n", "gd", vim.lsp.buf.definition, { buffer = bufnr, silent = true })
  keymap.set("n", "gi", "<cmd>Telescope lsp_implementations<cr>", { buffer = bufnr, silent = true })
  keymap.set("n", "gr", "<cmd>Telescope lsp_references<cr>", { buffer = bufnr, silent = true })
  keymap.set("n", "<leader>gT", vim.lsp.buf.type_definition, { buffer = bufnr, silent = true })
  keymap.set("n", "<leader>ds", "<cmd>Telescope lsp_document_symbols<cr>", { buffer = bufnr, silent = true })
  keymap.set("n", "<leader>rn", vim.lsp.buf.rename, { buffer = bufnr, silent = true })
  keymap.set("n", "<leader>dl", "<cmd>Telescope diagnostics<cr>", { buffer = bufnr, silent = true })
  keymap.set("n", "<leader>ca", vim.lsp.buf.code_action, { buffer = bufnr, silent = true })
end

vim.lsp.config('rust_analyzer',  {
  capabilities = capabilities,
  on_attach = on_attach,
  settings = {
    ['rust-analyzer'] = {
      diagnostics = {
        enable = true;
      }
    }
  },
})

vim.lsp.config('gopls',  {
  capabilities = capabilities,
  on_attach = on_attach,
})

vim.lsp.config('ruby_lsp',  {
  capabilities = capabilities,
  on_attach = on_attach,
})

vim.lsp.config('sorbet',  {
  capabilities = capabilities,
  on_attach = on_attach,
})

vim.lsp.config('tailwindcss',  {
  capabilities = capabilities,
  on_attach = on_attach,
})

vim.lsp.config('lua_ls',  {
  capabilities = capabilities,
  on_attach = on_attach,
  settings = {
    Lua = {
      runtime = {
        version = 'LuaJIT',
        path = vim.split(package.path, ';'),
      },
      diagnostics = {
        globals = {'describe', 'it', 'use'},
      },
    },
  },
})
