"
" Rende la toc in usr_xx.txt un elenco di link interni
nnoremap <leader>wl Ypk0i[<Esc>A]<Esc>jV:s/^.*$/\L&/g<CR>V:s/ /-/ge<CR>0i(#<Esc>A)<Esc>kJxA<Space>\<Esc>j
"
" Rende una riga di testo un header
nnoremap <leader>1 0i#<Space><Esc>
nnoremap <leader>2 0i##<Space><Esc>
nnoremap <leader>3 0i###<Space><Esc>
nnoremap <leader>4 0i####<Space><Esc>
nnoremap <leader>5 0i#####<Space><Esc>
nnoremap <leader>6 0i######<Space><Esc>
"
" Racchiude tra backticks ciò che è tra due spazi
nnoremap <leader>' F<Space>li`<Esc>f<Space>i`<Esc> 
