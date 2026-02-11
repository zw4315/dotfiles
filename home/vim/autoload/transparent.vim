" autoload/transparent.vim

if !exists('g:transparent_enabled')
  let g:transparent_enabled = 0
endif

" 实际把各种高亮组改成透明
function! transparent#apply() abort
  if !g:transparent_enabled
    return
  endif

  " 按需增减
  for name in [
        \ 'Normal',
        \ 'NormalNC',
        \ 'NonText',
        \ 'LineNr',
        \ 'SignColumn',
        \ 'FoldColumn',
        \ 'VertSplit',
        \ 'StatusLine',
        \ 'StatusLineNC'
        \ ]
    execute 'hi ' . name . ' ctermbg=NONE guibg=NONE'
  endfor
endfunction

function! transparent#enable() abort
  let g:transparent_enabled = 1
  call transparent#apply()
endfunction

function! transparent#disable() abort
  let g:transparent_enabled = 0
  " 恢复当前 colorscheme 原本的背景
  if exists('g:colors_name')
    execute 'silent! colorscheme ' . g:colors_name
  endif
endfunction

function! transparent#toggle() abort
  if g:transparent_enabled
    call transparent#disable()
  else
    call transparent#enable()
  endif
endfunction

