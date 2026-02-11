" plugin/transparent.vim

if exists('g:loaded_transparent_toggle')
  finish
endif
let g:loaded_transparent_toggle = 1

" 命令 & 快捷键
command! ToggleTransparent call transparent#toggle()

" 这里你可以换成自己喜欢的按键
nnoremap <silent> <F12> :ToggleTransparent<CR>

" 当切换 colorscheme 时，如果当前是透明状态，就重新应用一次
augroup TransparentAuto
  autocmd!
  autocmd ColorScheme * if get(g:, 'transparent_enabled', 0) | call transparent#apply() | endif
augroup END

