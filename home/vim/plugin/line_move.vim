" line_move.vim - move current line to top or bottom of file
"
" Maps:
"   <leader>mt  move current line to line 3 (after common headers)
"   <leader>mb  move current line to last line
"   <leader>m0  move current line to first line (when you really need line 1)

if exists('g:loaded_line_move')
  finish
endif
let g:loaded_line_move = 1

" Move current line to line 3 (keeps cursor at same position)
nnoremap <silent> <leader>mt :call <SID>MoveToLine(3)<CR>

" Move current line to first line (keeps cursor at same position)
nnoremap <silent> <leader>m0 :call <SID>MoveToLine(1)<CR>

" Move current line to last line (keeps cursor at same position)
nnoremap <silent> <leader>mb :call <SID>MoveToLastLine()<CR>

" Move current line to specified line number, keeping cursor at same position
function! s:MoveToLine(target_line) abort
  let l:col = col('.')
  let l:current_line = line('.')
  let l:lnum = line('.')
  
  " If already at target, do nothing
  if l:current_line == a:target_line
    return
  endif
  
  " Calculate new cursor position based on line movement
  if l:lnum < a:target_line
    " Moving from before target to after: cursor shifts up by 1
    let l:new_line = l:current_line - 1
  elseif l:lnum > a:target_line
    " Moving from after target to before: cursor shifts down by 1
    let l:new_line = l:current_line + 1
  else
    let l:new_line = l:current_line
  endif
  
  " Move the line
  execute 'm' . (a:target_line - 1)
  
  " Restore cursor to original position (adjusted for line shift)
  call cursor(l:new_line, l:col)
  
  " Fix indentation on the moved line
  execute 'normal! ' . a:target_line . 'G=='
  
  " Restore cursor position after indent fix
  call cursor(l:new_line, l:col)
endfunction

" Move current line to last line, keeping cursor at same position
function! s:MoveToLastLine() abort
  let l:col = col('.')
  let l:current_line = line('.')
  let l:total_lines = line('$')
  
  " If already at last line, do nothing
  if l:current_line == l:total_lines
    return
  endif
  
  " Calculate new cursor position (current line moves away, so position shifts up)
  let l:new_line = l:current_line - 1
  if l:new_line < 1
    let l:new_line = 1
  endif
  
  " Move current line to end
  execute 'm$'
  
  " Restore cursor to original position (adjusted for line shift)
  call cursor(l:new_line, l:col)
  
  " Fix indentation on the moved line (now at last line)
  execute "normal! G=="
  
  " Restore cursor position after indent fix
  call cursor(l:new_line, l:col)
endfunction