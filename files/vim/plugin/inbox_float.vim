" inbox_float.vim - open inbox.md inside floaterm (keep vimrc short)

if exists('g:loaded_inbox_float')
  finish
endif
let g:loaded_inbox_float = 1

" -------- config --------
if !exists('g:inbox_float_file')
  let g:inbox_float_file = expand('~/mgnt/notes/00-inbox.md')
endif

" 是否自动绑定快捷键（默认开；你想关就 let g:inbox_map_disable = 1）
if !exists('g:inbox_map_disable')
  let g:inbox_map_disable = 0
endif

" 使用哪个编辑器（默认 vim；你要用 nvim 就设 g:inbox_term_editor='nvim'）
if !exists('g:inbox_term_editor')
  let g:inbox_term_editor = 'vim'
endif

" -------- core --------
command! InboxTerm call s:InboxOpenInFloaterm()

function! s:EnsureInboxFileExists(file) abort
  if !filereadable(a:file)
    call writefile(['# Inbox', '', '- '], a:file)
  endif
endfunction

function! s:InboxOpenInFloaterm() abort
  if !exists(':FloatermNew')
    echohl WarningMsg
    echom "Floaterm not found. Install vim-floaterm (need :FloatermNew)."
    echohl None
    return
  endif

  let l:file = fnamemodify(g:inbox_float_file, ':p')
  call s:EnsureInboxFileExists(l:file)

  " 关键：不要 shellescape()，用 fnameescape()，并加 -- 防止被当成选项
  let l:cmd = g:inbox_term_editor . ' +call\ cursor(1,1) -- ' . fnameescape(l:file)

  execute 'FloatermNew --name=inbox --title=inbox.md --autoclose=0 ' . l:cmd
endfunction

" -------- optional keymap --------
if !g:inbox_map_disable
  " 你可以把 <leader>i 改成你喜欢的键
  nnoremap <silent> <leader>i :InboxTerm<CR>
  " 复用/隐藏显示（如果你的 floaterm 支持按 name toggle）
  if exists(':FloatermToggle')
    nnoremap <silent> <leader>I :FloatermToggle inbox<CR>
  endif
endif

