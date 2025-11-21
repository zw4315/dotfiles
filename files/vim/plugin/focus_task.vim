" focus_task.vim - simple task timer for Vim
"
" Commands:
"   :AddTask {minutes} [task name...]
"   :CancelTask
"
" Statusline:
"   set statusline+=%{FocusTaskStatus()}

if exists('g:loaded_focus_task')
  finish
endif
let g:loaded_focus_task = 1

" Need +timers (Vim 8+ / Neovim)
if !exists('*timer_start')
  echohl WarningMsg
  echom 'focus_task.vim: Vim/neovim was compiled without +timers, plugin disabled.'
  echohl None
  finish
endif

let s:task_timer_id   = -1
let s:flash_timer_id  = -1
let s:task_end_time   = 0.0
let s:task_name       = ''
let s:flash_count     = 0
let s:flash_on        = 0

" -------- statusline helper --------
function! s:UpdateStatus(remaining) abort
  if a:remaining < 0
    let l:rem = 0
  else
    let l:rem = float2nr(a:remaining)
  endif

  let l:mins = l:rem / 60
  let l:secs = l:rem % 60

  if s:task_name !=# ''
    let l:label = s:task_name
  else
    let l:label = 'Timer'
  endif

  let g:focus_task_status = printf(' ⏳ %s (%02d:%02d)', l:label, l:mins, l:secs)
  redrawstatus
endfunction

" Public function for statusline
function! FocusTaskStatus() abort
  return get(g:, 'focus_task_status', '')
endfunction

" -------- flashing when finished --------
function! s:StartFlash() abort
  " stop previous flash if any
  if s:flash_timer_id != -1
    call timer_stop(s:flash_timer_id)
  endif
  let s:flash_count = 10        " 10 * 500ms = 5 seconds
  let s:flash_on    = 0
  let s:flash_timer_id = timer_start(500, function('s:OnFlash'), {'repeat': -1})
endfunction

function! s:OnFlash(timer) abort
  if s:flash_count <= 0
    if s:flash_timer_id != -1
      call timer_stop(s:flash_timer_id)
      let s:flash_timer_id = -1
    endif
    unlet! g:focus_task_status
    redrawstatus
    return
  endif

  let s:flash_on = !s:flash_on

  if s:flash_on
    if s:task_name !=# ''
      let g:focus_task_status = ' ⏰ DONE: ' . s:task_name
    else
      let g:focus_task_status = ' ⏰ DONE'
    endif
  else
    let g:focus_task_status = ''
  endif

  let s:flash_count -= 1
  redrawstatus
endfunction

" -------- main timer tick --------
function! s:OnTick(timer) abort
  let l:now = reltimefloat(reltime())
  let l:remaining = s:task_end_time - l:now

  if l:remaining <= 0
    if s:task_timer_id != -1
      call timer_stop(s:task_timer_id)
      let s:task_timer_id = -1
    endif

    " clear normal countdown
    unlet! g:focus_task_status
    redrawstatus

    " flash a bit
    call s:StartFlash()

    echohl WarningMsg
    if s:task_name !=# ''
      echom '⏰ Task finished: ' . s:task_name
    else
      echom '⏰ Timer finished.'
    endif
    echohl None
  else
    call s:UpdateStatus(l:remaining)
  endif
endfunction

" -------- start & cancel --------
function! s:TaskStart(args) abort
  " only one timer at a time
  if s:task_timer_id != -1
    echohl WarningMsg
    echom 'A task timer is already running. Use :CancelTask first.'
    echohl None
    return
  endif

  let l:parts = split(a:args)
  if empty(l:parts)
    echohl ErrorMsg
    echom 'Usage: AddTask {minutes} [task name...]'
    echohl None
    return
  endif

  let l:first = remove(l:parts, 0)
  if l:first !~# '^\d\+$'
    echohl ErrorMsg
    echom 'First argument must be duration in minutes (integer).'
    echohl None
    return
  endif

  let l:minutes = str2nr(l:first)
  if l:minutes <= 0
    echohl ErrorMsg
    echom 'Duration must be positive.'
    echohl None
    return
  endif

  let s:task_name = empty(l:parts) ? '' : join(l:parts, ' ')

  " stop any previous flash
  if s:flash_timer_id != -1
    call timer_stop(s:flash_timer_id)
    let s:flash_timer_id = -1
  endif

  let s:task_end_time = reltimefloat(reltime()) + l:minutes * 60.0
  let s:task_timer_id = timer_start(1000, function('s:OnTick'), {'repeat': -1})

  call s:UpdateStatus(l:minutes * 60.0)

  echohl ModeMsg
  if s:task_name !=# ''
    echom printf('Started task "%s" for %d minutes.', s:task_name, l:minutes)
  else
    echom printf('Started %d-minute timer.', l:minutes)
  endif
  echohl None
endfunction

function! s:TaskCancel() abort
  if s:task_timer_id != -1
    call timer_stop(s:task_timer_id)
    let s:task_timer_id = -1
  endif
  if s:flash_timer_id != -1
    call timer_stop(s:flash_timer_id)
    let s:flash_timer_id = -1
  endif

  unlet! g:focus_task_status
  let s:task_name = ''
  redrawstatus

  echohl ModeMsg
  echom 'Task timer cancelled.'
  echohl None
endfunction

" -------- user commands --------
command! -nargs=+ AddTask    call s:TaskStart(<q-args>)
command! -nargs=0 CancelTask call s:TaskCancel()

" you can also use shorter names if you like:
command! -nargs=+ TaskStart  call s:TaskStart(<q-args>)
command! -nargs=0 TaskStop   call s:TaskCancel()
