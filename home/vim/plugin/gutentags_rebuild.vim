" gutentags_rebuild.vim
" Force rebuild gtags database after directory restructuring.

if exists('g:loaded_gutentags_rebuild')
  finish
endif
let g:loaded_gutentags_rebuild = 1

command! GtagsRebuild call s:gutentags_rebuild()

function! s:gutentags_rebuild() abort
  if !exists('b:gutentags_root')
    echoerr 'GtagsRebuild: not a gutentags project buffer'
    return
  endif
  let l:root = b:gutentags_root

  " Use gutentags' own path encoding to ensure consistency
  let l:gtags_path = gutentags#get_cachefile(l:root, get(g:, 'gutentags_gtags_dbpath', ''))
  let l:gtags_path = gutentags#stripslash(l:gtags_path)
  let l:gtags_dir = l:gtags_path

  let l:ctags_file = gutentags#get_cachefile(l:root, get(g:, 'gutentags_ctags_tagfile', 'tags'))

  if isdirectory(l:gtags_dir)
    call delete(l:gtags_dir, 'rf')
    echom 'Deleted old gtags cache: ' . l:gtags_dir
  endif
  if filereadable(l:ctags_file)
    call delete(l:ctags_file)
    echom 'Deleted old ctags cache: ' . l:ctags_file
  endif

  " Force immediate regeneration instead of waiting for auto-trigger
  call gutentags#rescan()
  if exists(':GutentagsUpdate')
    GutentagsUpdate!
  endif
  echom 'Gtags rebuilt for ' . l:root
endfunction


" Note: Ctrl+] is left to Vim's native ctags/LSP tagfunc.
" Use <leader>cg for gtags definition search (GscopeFind g).
