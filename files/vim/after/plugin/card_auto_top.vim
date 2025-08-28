" ~/.vim/after/plugin/card_auto_top.vim

augroup CardAutoTop
  autocmd!
  " 保存前：尝试把当前 ## section 置顶（仅在指定文件名时生效）
  autocmd BufWritePre  *.md  call s:CardAutoTop()
  " 保存后：记录本次 changedtick，供下次判断“是否有改动”
  autocmd BufWritePost *.md  let b:last_saved_tick = b:changedtick
augroup END

function! s:CardAutoTop() abort
  " —— 仅在文件名为 append.md 或 review.md 时生效（大小写不敏感）——
  let l:base = expand('%:t')                       " 文件名（不含路径）
  if l:base !~? '\v^(append|review)\.md$'
    return
  endif

  " —— 防重入 ——（避免任何间接触发再次执行）
  if get(b:, '_card_moving', 0)
    return
  endif

  " —— 本次没有改动就不动 ——（避免无意义的重排）
  if get(b:, 'last_saved_tick', 0) == b:changedtick
    return
  endif

  " —— 计算当前 Card（从最近的 '## ' 到下一个 '## ' 或文件末）——
  let l:start = search('^##\s', 'bnW')
  if l:start == 0
    return
  endif
  let l:end = search('^##\s', 'nW')
  if l:end == 0
    let l:end = line('$') + 1
  endif
  let l:end = l:end - 1

  " 已在顶端则不移动
  if l:start == 1
    return
  endif

  " —— 执行移动，并保护视图/光标位置 —— 
  let b:_card_moving = 1
  try
    let l:view = winsaveview()
    execute l:start . ',' . l:end . 'move 0'
    call winrestview(l:view)
  finally
    unlet b:_card_moving
  endtry
endfunction

