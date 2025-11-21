" =========================================================
" QuickHL 增强：统计 + 相对/绝对跳转 + 当前索引
" 依赖：t9md/vim-quickhl，且已提供以下 <Plug>：
"   <Plug>(quickhl-manual-this-whole-word)
"   <Plug>(quickhl-manual-reset)
" =========================================================

" 统计当前词：总次数 + 第一/最后一行号，并设置搜索模式
function! QuickHLWordStats() abort
  let l:word = expand('<cword>')
  if empty(l:word)
    echo 'no word under cursor'
    return
  endif

  " 整词匹配，塞进 @/
  let l:pat = '\V\<'.escape(l:word, '\').'\>'
  let @/ = l:pat

  " 用 searchcount 统计总数（如果有）
  if exists('*searchcount')
    let l:sc = searchcount({'pattern': l:pat, 'maxcount': 0})
    let l:cnt = l:sc.total
  else
    let l:cnt = 0
  endif

  if l:cnt == 0
    echo 'count: 0'
    return
  endif

  " 保存光标位置
  let l:curpos = getpos('.')

  " 第一处：从文件头往下搜
  call cursor(1, 1)
  let l:first = search(l:pat, 'nW')

  " 最后一处：从文件尾往上搜
  call cursor(line('$'), 1)
  let l:last = search(l:pat, 'nbW')

  " 恢复光标
  call setpos('.', l:curpos)

  echo 'count: ' . l:cnt . ' first: ' . l:first . ' last: ' . l:last
endfunction


" 只看“当前是第几个/总共多少个”
function! QuickHLCurrentIndex() abort
  if !exists('*searchcount')
    echo 'searchcount() not available'
    return
  endif

  " 如果还没有搜索模式，尝试用光标下单词
  if empty(@/)
    let l:word = expand('<cword>')
    if empty(l:word)
      echo 'no search pattern / word'
      return
    endif
    let @/ = '\V\<'.escape(l:word, '\').'\>'
  endif

  let l:sc = searchcount({'recompute': 1, 'maxcount': 0})
  if l:sc.total == 0
    echo 'count: 0'
  else
    echo l:sc.current . '/' . l:sc.total
  endif
endfunction


" 内部工具函数：跳到第 target 个匹配（1-based），基于当前 @/
function! s:QuickHLGotoIndex(target) abort
  " 从文件头开始找第 target 个
  call cursor(1, 1)
  let l:idx  = 0
  let l:lnum = 0
  while l:idx < a:target
    let l:lnum = search(@/, 'W')  " W: 不 wrap
    if l:lnum == 0
      break
    endif
    let l:idx += 1
  endwhile

  if l:lnum == 0
    echo 'not found'
    return 0
  endif

  " 打印 index/total
  if exists('*searchcount')
    let l:sc = searchcount({'recompute': 1, 'maxcount': 0})
    echo l:sc.current . '/' . l:sc.total
  endif

  return 1
endfunction


" 相对跳转：hj / hk
"   dir =  1 : 向后
"   dir = -1 : 向前
function! QuickHLJump(dir) abort
  if !exists('*searchcount')
    echo 'searchcount() not available'
    return
  endif

  if empty(@/)
    echo 'no search pattern'
    return
  endif

  let l:sc    = searchcount({'recompute': 1, 'maxcount': 0})
  let l:total = l:sc.total
  let l:cur   = l:sc.current

  if l:total == 0
    echo 'count: 0'
    return
  endif

  " 相对步长：默认 1，有数字前缀就用 v:count1
  let l:step   = v:count1 * a:dir
  let l:target = l:cur + l:step

  " 边界处理
  if l:target < 1
    let l:target = 1
  elseif l:target > l:total
    let l:target = l:total
  endif

  if l:target == l:cur
    echo l:cur . '/' . l:total
    return
  endif

  call s:QuickHLGotoIndex(l:target)
endfunction


" 绝对跳转：hg
"   hg      : 第 1 个
"   4hg     : 第 4 个（超出则跳到最后一个）
function! QuickHLJumpAbsolute() abort
  if !exists('*searchcount')
    echo 'searchcount() not available'
    return
  endif

  if empty(@/)
    echo 'no search pattern'
    return
  endif

  let l:sc    = searchcount({'recompute': 1, 'maxcount': 0})
  let l:total = l:sc.total

  if l:total == 0
    echo 'count: 0'
    return
  endif

  let l:target = v:count
  if l:target <= 0
    let l:target = 1
  endif

  if l:target > l:total
    let l:target = l:total
  endif

  call s:QuickHLGotoIndex(l:target)
endfunction


" =================== 映射区 ===================

" hh：统计 + 高亮当前词
nnoremap hh :call QuickHLWordStats()<CR><Plug>(quickhl-manual-this-whole-word)

" HH：清空所有手动高亮
nnoremap hx <Plug>(quickhl-manual-reset)

" hc：只看当前是第几个 / 总共多少个
nnoremap hc :call QuickHLCurrentIndex()<CR>

" hj / hk：相对跳转（支持数字前缀）
"   hj      : 下一个
"   3hj     : 向后 3 个
"   hk      : 上一个
"   2hk     : 向前 2 个
nnoremap <silent> hj :<C-u>call QuickHLJump(1)<CR>
nnoremap <silent> hk :<C-u>call QuickHLJump(-1)<CR>

" hg：绝对跳转（支持数字前缀）
"   hg      : 第 1 个
"   4hg     : 第 4 个
nnoremap <silent> hg :<C-u>call QuickHLJumpAbsolute()<CR>

