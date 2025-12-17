" ~/.vim/autoload/zw/floaterm.vim
"
" vimrc 用法（推荐）：
"   let g:zw_floaterm_prefix = '<leader>t'
"   call zw#floaterm#setup()

let s:did_setup = 0
let s:prefix = '<leader>t'

function! s:map_pair(lhs, cmd) abort
  " Normal mode
  execute 'nnoremap <silent> ' . a:lhs . ' :' . a:cmd . '<CR>'
  " Terminal mode: 先退回 normal 再执行
  execute 'tnoremap <silent> ' . a:lhs . ' <C-\><C-n>:' . a:cmd . '<CR>'
endfunction

function! s:try_setup() abort
  " 避免重复设置
  if s:did_setup
    return
  endif
  " Floaterm 命令还不存在就先不做（等下一次再试）
  if !exists(':FloatermToggle')
    return
  endif

  let s:did_setup = 1

  call s:map_pair(s:prefix . 't', 'FloatermToggle')
  call s:map_pair(s:prefix . 'k', 'FloatermKill')
  call s:map_pair(s:prefix . 'K', 'FloatermKill!')
  call s:map_pair(s:prefix . 'n', 'FloatermNew')
  call s:map_pair(s:prefix . 'h', 'FloatermPrev')
  call s:map_pair(s:prefix . 'l', 'FloatermNext')
endfunction

function! zw#floaterm#setup() abort
  let s:prefix = get(g:, 'zw_floaterm_prefix', '<leader>t')

  " 先尝试一次
  call s:try_setup()

  " 如果此刻还没加载 floaterm：在 VimEnter 后再试几次（很稳）
  if !s:did_setup
    call timer_start(0,   {-> s:try_setup()})
    call timer_start(50,  {-> s:try_setup()})
    call timer_start(200, {-> s:try_setup()})
  endif
endfunction

