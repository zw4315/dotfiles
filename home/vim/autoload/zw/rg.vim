" autoload/zw/rg.vim
" 旧逻辑保留：Rg 搜索 + FZF 选择 + 逐文件替换（y/n/a/q）

" ---------- 搜索公用 ----------
function! zw#rg#_base() abort
  return 'rg --column --line-number --no-heading --color=always --hidden --with-filename --glob "!{.git,node_modules}/*" '
endfunction


function! zw#rg#_preview() abort
  return fzf#vim#with_preview({
        \ 'options': [
        \   '--multi',
        \   '--preview',
        \   'bat --theme=base16-256 --color=always --style=numbers --highlight-line {2} {1}'
        \ ]
        \ })
endfunction


" mode: smart/case/exact/file
function! zw#rg#run(mode, args) abort
  let base = zw#rg#_base()
  if a:mode ==# 'smart'
    let cmd = base . '--smart-case ' . a:args
  elseif a:mode ==# 'case'
    let cmd = base . '--case-sensitive ' . a:args
  elseif a:mode ==# 'exact'
    " PCRE2 词边界：(?<!\w)pat(?!\w)
    let pat = '(?<!\w)'.a:args.'(?!\w)'
    let cmd = base . '--pcre2 --case-sensitive ' . shellescape(pat)
  elseif a:mode ==# 'file'
    let cmd = base . '--pcre2 --case-sensitive ' . a:args . ' ' . shellescape(expand('%:p'))
  else
    echoerr 'Unknown mode: ' . a:mode | return
  endif
  call fzf#vim#grep(cmd, 1, zw#rg#_preview(), 0)
endfunction

" ---------- 旧逻辑：跨文件替换入口 ----------
" 跨文件替换入口
function! zw#rg#replace_in_files_prompt() abort
  let l:target = input('🔎 搜索词: ', expand('<cword>'))
  if empty(l:target) | return | endif

  " 默认值就是原词
  let l:replace = input('↪ 替换为: ', l:target)
  if l:replace ==# l:target
    echo '未修改'
    return
  endif

  let l:rg_cmd = 'rg --vimgrep --no-heading --hidden --glob "!{.git,node_modules}/*" ' .
        \          '--pcre2 --case-sensitive ' . shellescape('(?<!\w)'.l:target.'(?!\w)')

  let l:spec = zw#rg#_preview()
  let l:spec['sink*'] = function('zw#rg#ReplaceInFiles', [l:target, l:replace])
  call fzf#vim#grep(l:rg_cmd, 1, l:spec, 0)
endfunction

" ---------- 旧逻辑：逐文件执行替换（y/n/a/q） ----------
" selected: fzf 传来的选中行列表（file:lnum:col:text）
function! zw#rg#ReplaceInFiles(target, replace, selected) abort
  let l:replace_all = 0
  for l:item in a:selected
    " 解析 file:line:col:text
    let l:m = matchlist(l:item, '^\(.\+\):\(\d\+\):\(\d\+\):.*$')
    if len(l:m) < 4 | continue | endif
    let l:file = l:m[1]
    let l:lnum = str2nr(l:m[2])
    let l:col  = str2nr(l:m[3])

    if !filereadable(l:file) || !filewritable(l:file)
      echohl WarningMsg | echom '跳过不可写文件：' . l:file | echohl None
      continue
    endif

    " 打开文件（不污染 alt-file）
    silent! execute 'keepalt edit ' . fnameescape(l:file)

    if &buftype ==# 'nofile' || !&modifiable
      echohl WarningMsg | echom '跳过特殊缓冲区：' . l:file | echohl None
      continue
    endif

    " 跳到相应位置（主要用于可视反馈）
    call cursor(l:lnum, l:col)

    " 与旧版一致：忽略大小写 + 词边界
    let l:pat = '\c\<'.escape(a:target, '/\').'\>'
    let l:rep = escape(a:replace, '/\')

    if l:replace_all
      " 全文件全局
      silent execute '%s/'.l:pat.'/'.l:rep.'/g'
      write
    else
      echohl Question
      echom '替换：' . a:target . '  -->  ' . a:replace . '   (y/n/a/q)?'
      echohl None
      let l:ch = nr2char(getchar())
      redraw
      if l:ch ==# 'a'
        let l:replace_all = 1
        silent execute '%s/'.l:pat.'/'.l:rep.'/g'
        write
      elseif l:ch ==# 'y'
        " 当前行一次（与旧逻辑一致）
        silent execute 's/'.l:pat.'/'.l:rep.'/'
        write
      elseif l:ch ==# 'q'
        break
      else
        " n：跳过
      endif
    endif
  endfor
endfunction

" ---------- （可选）仅当前文件替换，复用旧匹配规则 ----------
" 仅当前文件替换
function! zw#rg#replace_in_buffer_prompt() abort
  let l:target = input('🔎 搜索词: ', expand('<cword>'))
  if empty(l:target) | return | endif

  " 默认值就是原词
  let l:replace = input('↪ 替换为: ', l:target)
  if l:replace ==# l:target
    echo '未修改'
    return
  endif

  let l:pat = '\c\<'.escape(l:target, '/\').'\>'
  let l:rep = escape(l:replace, '/\')
  execute '%s/'.l:pat.'/'.l:rep.'/gc'
  write
endfunction

