" ~/.vim/after/plugin/card_auto_top.vim
augroup CardAutoTop
  autocmd!
  autocmd BufWritePre  *.md  call <SID>CardAutoTop()
  autocmd BufWritePost *.md  let b:last_tick = b:changedtick
augroup END

function! s:CardAutoTop() abort
  " 仅这些文件名
  let name = expand('%:t')
  if name !~? '\v^(append|review|kanban)\.md$'
    return
  endif

  " 防重入 + 本次无改动就不动
  if get(b:, '_busy', 0) | return | endif
  if get(b:, 'last_tick', -1) == b:changedtick | return | endif

  " 找当前 card：从最近的 '## ' 到下一个 '## '（或文件结尾）
  let s = search('^##\s', 'bnW')
  if s == 0 | return | endif
  let e = search('^##\s', 'nW')
  if e == 0 | let e = line('$') + 1 | endif
  let e -= 1

  let b:_busy = 1
  try
    let v = winsaveview()
    " 移到最顶端（用 printf 避免引号问题）
    execute printf('%d,%dmove 0', s, e)
    " 规范化 card 之间的空行
    call s:NormalizeCardSpacing()
    call winrestview(v)
  finally
    unlet b:_busy
  endtry
endfunction

" 保证每个 '## ' 之前恰好 1 行空行（第一个 ## 例外）
function! s:NormalizeCardSpacing() abort
  call cursor(1, 1)
  while 1
    let l = search('^##\s', 'W')      " 若 ### 也算 card，改成 '^##\+\s'
    if l == 0 | break | endif
    if l > 1
      " 去掉标题上方多余的空行
      while l > 1 && getline(l-1) =~# '^\s*$'
        execute (l-1) . 'delete _'
        let l -= 1
      endwhile
      " 若上方不是空行，补一行空行
      if l > 1 && getline(l-1) !~# '^\s*$'
        call append(l-1, '')
        let l += 1
      endif
    endif
    call cursor(l+1, 1)
  endwhile
endfunction

