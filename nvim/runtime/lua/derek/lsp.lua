local lspconfig = require('lspconfig')
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
  keymap.set("n", "<leader>j", vim.diagnostic.goto_next, { buffer = bufnr, silent = true })
  keymap.set("n", "<leader>k", vim.diagnostic.goto_prev, { buffer = bufnr, silent = true })
  keymap.set("n", "<leader>ca", vim.lsp.buf.code_action, { buffer = bufnr, silent = true })
end

lspconfig.rust_analyzer.setup {
  capabilities = capabilities,
  on_attach = on_attach,
  settings = {
    ['rust-analyzer'] = {
      diagnostics = {
        enable = true;
      }
    }
  },
}

lspconfig.tsserver.setup {
  capabilities = capabilities,
  on_attach = on_attach,
}

lspconfig.gopls.setup {
  capabilities = capabilities,
  on_attach = on_attach,
}

-- lspconfig.java_language_server.setup {
--   capabilities = capabilities,
--   on_attach = on_attach,
-- }

-- lspconfig.ruby_ls.setup {
--   capabilities = capabilities,
--   on_attach = function(client, bufnr)
--     keymap.set("n", "<leader>ds", "<cmd>Telescope lsp_document_symbols<cr>", { buffer = bufnr, silent = true })
--     keymap.set("n", "<leader>dl", "<cmd>Telescope diagnostics<cr>", { buffer = bufnr, silent = true })
--     keymap.set("n", "<leader>dj", vim.diagnostic.goto_next, { buffer = bufnr, silent = true })
--     keymap.set("n", "<leader>dk", vim.diagnostic.goto_prev, { buffer = bufnr, silent = true })
--     keymap.set("n", "<leader>ca", vim.lsp.buf.code_action, { buffer = bufnr, silent = true })
--   end,
-- }

-- lspconfig.sorbet.setup {
--   capabilities = capabilities,
--   on_attach = function(client, bufnr)
--     keymap.set("n", "<leader>ds", "<cmd>Telescope lsp_document_symbols<cr>", { buffer = bufnr, silent = true })
--     keymap.set("n", "<leader>dl", "<cmd>Telescope diagnostics<cr>", { buffer = bufnr, silent = true })
--     keymap.set("n", "<leader>dj", vim.diagnostic.goto_next, { buffer = bufnr, silent = true })
--     keymap.set("n", "<leader>dk", vim.diagnostic.goto_prev, { buffer = bufnr, silent = true })
--     keymap.set("n", "<leader>ca", vim.lsp.buf.code_action, { buffer = bufnr, silent = true })
--   end,
-- }

lspconfig.tailwindcss.setup {
  capabilities = capabilities,
  on_attach = on_attach,
}

lspconfig.lua_ls.setup {
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
}
