local has_lspconfig, lspconfig = pcall(require, 'lspconfig')
local capabilities = require('cmp_nvim_lsp').update_capabilities(vim.lsp.protocol.make_client_capabilities())

if not has_lspconfig then return end

local on_attach = function()
  vim.set("n", "K", vim.lsp.buf.hover, {buffer=0})
  vim.set("n", "gd", vim.lsp.buf.definition, {buffer=0})
  vim.set("n", "gT", vim.lsp.buf.type_definition, {buffer=0})
  vim.set("n", "gi", vim.lsp.buf.implementation, {buffer=0})
  vim.set("n", "<leader>rn", vim.lsp.buf.rename, {buffer=0})
  vim.set("n", "<leader>rr", "<cmd>Telescope lsp_references<cr>", {buffer=0})
  vim.set("n", "<leader>dl", "<cmd>Telescope diagnostics<cr>", {buffer=0})
  vim.set("n", "<leader>dn", vim.diagnostics.next, {buffer=0})
  vim.set("n", "<leader>dp", vim.diagnostics.prev, {buffer=0})
  vim.set("n", "<leader>ca", "<cmd>Telescope lsp_code_actions<cr>", {buffer=0})
end

lspconfig.rust_analyzer.setup {
  capabilities = capabilities,
  on_attach = on_attach,
}

lspconfig.tsserver.setup {
  capabilities = capabilities,
}

lspconfig.sorbet.setup {
  cmd = {"bundle", "exec", "srb", "tc", "--lsp"},
  capabilities = capabilities,
}

local system_name
if vim.fn.has("mac") == 1 then
  system_name = "macOS"
elseif vim.fn.has("unix") == 1 then
  system_name = "Linux"
elseif vim.fn.has('win32') == 1 then
  system_name = "Windows"
else
  print("Unsupported system for sumneko")
end

-- set the path to the sumneko installation; if you previously installed via the now deprecated :LspInstall, use
local sumneko_root_path = vim.env.PROJECTS..'/github.com/sumneko/lua-language-server'
local sumneko_binary = sumneko_root_path.."/bin/"..system_name.."/lua-language-server"

lspconfig.sumneko_lua.setup {
  cmd = {sumneko_binary, "-E", sumneko_root_path .. "/main.lua"};
  capabilities = capabilities,
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
