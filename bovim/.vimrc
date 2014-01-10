" Make a line a header or subheader
" Usage: put the cursor on the line you want to make header or
" subheader, then type `<leader>h-` or `<leader>h=`
nnoremap <leader>h yyp<c-v>$r
"
" search for a header with `#` and change it with `===`
nnoremap <leader>1 /^# <Enter>2xyyp<c-v>$r=
"
" search for a header with `##` and change it with `---`
nnoremap <leader>2 /^## <Enter>4xyyp<c-v>$r-
