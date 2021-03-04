lua require("lsp_setup")

let g:completion_matching_strategy_list = ['exact', 'substring', 'fuzzy']
let g:completion_matching_smart_case = 1
let g:completion_chain_complete_list = [
    \{'complete_items': ['lsp', 'snippet', 'ts']},
    \{'mode': '<c-p>'},
    \{'mode': '<c-n>'}
\]

" Use <Tab> and <S-Tab> to navigate through popup menu
inoremap <expr> <Tab>   pumvisible() ? "\<C-n>" : "\<Tab>"
inoremap <expr> <S-Tab> pumvisible() ? "\<C-p>" : "\<S-Tab>"

nnoremap <silent> <leader>sh :lua vim.lsp.buf.hover()<CR>
nnoremap <silent> <leader>sd :lua vim.lsp.buf.definition()<CR>
nnoremap <silent> <leader>si :lua vim.lsp.buf.implementation()<CR>
nnoremap <silent> <leader>ssh :lua vim.lsp.buf.signature_help()<CR>
nnoremap <silent> <leader>srr :lua vim.lsp.buf.references()<CR>
nnoremap <silent> <leader>srn :lua vim.lsp.buf.rename()<CR>
nnoremap <silent> <leader>sca :lua vim.lsp.buf.code_action()<CR>
nnoremap <silent> <leader>ssd :lua vim.lsp.util.show_line_diagnostics(); vim.lsp.util.show_line_diagnostics()<CR>

