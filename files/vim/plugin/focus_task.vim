" focus_task.vim - simple task timer for Vim
"
" Commands:
"   :Ft {minutes} [task name...]
"   :Fc
"   :AddTask {minutes} [task name...]   (长命令，兼容用)
"   :CancelTask
"
" Airline:
"   自动把 FocusTaskStatus() 挂到 airline 的 X 区

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

let s:task_timer_id  = -1
let s:task_end_time  = 0.0
let s:task_name      = ''

" sliding notification
let s:slide_timer_id = -1
let s:slide_step     = 0
let s:slide_full     = ''
let s:slide_width    = 0

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

" Public function for statusline / airline
function! FocusTaskStatus() abort
  return get(g:, 'focus_task_status', '')
endfunction

" -------- sliding message when finished --------
function! s:StartSlide() abort
  " stop previous slide
  if s:slide_timer_id != -1
    call timer_stop(s:slide_timer_id)
    let s:slide_timer_id = -1
  endif

  " build message
  if s:task_name !=# ''
    let l:msg = ' ⏰ DONE: ' . s:task_name . ' '
  else
    let l:msg = ' ⏰ DONE '
  endif

  " width = current columns
  let s:slide_width = &columns > 0 ? &columns : 80

  " pad both sides to let it slide in & out
  let l:pad = repeat(' ', s:slide_width)
  let s:slide_full = l:pad . l:msg . l:pad
  let s:slide_step = 0

  " slide speed (ms per step)
  let s:slide_timer_id = timer_start(80, function('s:OnSlide'), {'repeat': -1})
endfunction

function! s:OnSlide(timer) abort
  if s:slide_width <= 0
    let s:slide_width = &columns > 0 ? &columns : 80
  endif

  let l:max_start = strlen(s:slide_full) - s:slide_width

  if s:slide_step > l:max_start
    " done
    if s:slide_timer_id != -1
      call timer_stop(s:slide_timer_id)
      let s:slide_timer_id = -1
    endif
    unlet! g:focus_task_status
    redrawstatus
    return
  endif

  let g:focus_task_status = strpart(s:slide_full, s:slide_step, s:slide_width)
  let s:slide_step += 1
  redrawstatus
endfunction

" -------- airline integration (auto, on first task start) --------
function! s:EnsureAirline() abort
  " no airline
  if !exists('*airline#section#create_right')
    return
  endif

  " only once
  if exists('g:focus_task_airline_inited') && g:focus_task_airline_inited
    return
  endif

  if exists('g:airline_section_x')
    " prepend our status if not already there
    if stridx(string(g:airline_section_x), 'FocusTaskStatus') < 0
      let g:airline_section_x = airline#section#create_right(
            \ ['%{FocusTaskStatus()}', g:airline_section_x]
            \ )
    endif
  else
    let g:airline_section_x = airline#section#create_right(
          \ ['%{FocusTaskStatus()}', 'filetype']
          \ )
  endif

  let g:focus_task_airline_inited = 1

  if exists(':AirlineRefresh')
    silent! AirlineRefresh
  endif
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

    " sliding notification
    call s:StartSlide()

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
    echom 'A task timer is already running. Use :Fc / :CancelTask first.'
    echohl None
    return
  endif

  let l:parts = split(a:args)
  if empty(l:parts)
    echohl ErrorMsg
    echom 'Usage: Ft {minutes} [task name...]'
    echom '   or: AddTask {minutes} [task name...]'
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

  " stop any previous slide
  if s:slide_timer_id != -1
    call timer_stop(s:slide_timer_id)
    let s:slide_timer_id = -1
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

  " auto hook into airline if available
  call s:EnsureAirline()
endfunction

function! s:TaskCancel() abort
  if s:task_timer_id != -1
    call timer_stop(s:task_timer_id)
    let s:task_timer_id = -1
  endif
  if s:slide_timer_id != -1
    call timer_stop(s:slide_timer_id)
    let s:slide_timer_id = -1
  endif

  unlet! g:focus_task_status
  let s:task_name = ''
  redrawstatus

  echohl ModeMsg
  echom 'Task timer cancelled.'
  echohl None
endfunction

" -------- user commands --------

" 短命令（日常用）
command! -nargs=+ Ft call s:TaskStart(<q-args>)
command! -nargs=0 Fc call s:TaskCancel()

" 长命令（兼容 / 更易懂）
command! -nargs=+ AddTask    call s:TaskStart(<q-args>)
command! -nargs=0 CancelTask call s:TaskCancel()

