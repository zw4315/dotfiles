" Markdown Card Edit Time
" - Counts time between consecutive edits (TextChanged/TextChangedI)
" - If the gap > 30s (configurable), the gap is discarded and the next edit starts a new streak
" - Aggregates by nearest previous '## ' card within the buffer

if exists('g:loaded_time_card')
  finish
endif
let g:loaded_time_card = 1

" Configuration: max gap (seconds) between edits to be counted
" Use g:md_card_gap_sec exclusively (default 30.0)
if !exists('g:md_card_gap_sec')
  let g:md_card_gap_sec = 30.0
endif

" Persistence configuration
" Root selection: use g:md_card_root_dir if set; otherwise detect project
" root per file via .git or a .root marker, and store under <root>/.cardtime.
if !exists('g:md_card_flush_interval')
  let g:md_card_flush_interval = 60.0
endif
if !exists('g:md_card_flush_on_switch')
  let g:md_card_flush_on_switch = 1
endif

" Enable tracking only for filenames matching these keywords (case-insensitive).
" Accepts a list of strings or a regex string.
if !exists('g:md_card_filename_keywords')
  let g:md_card_filename_keywords = ['append', 'review', 'kanban']
endif

" delta seconds helper moved to autoload: timecard#util#delta_seconds(last)

function! s:GetCurCardKey() abort
  " Find nearest previous line starting with '## '
  let lnum = search('^\s*##\s\+', 'bnW')
  if lnum == 0
    return ''
  endif
  let title = matchstr(getline(lnum), '^\s*##\s\+\zs.*')
  return lnum . ':' . title
endfunction

" Filename and filetype gate in autoload: timecard#util#filename_allowed()


" Build per-day store metadata for a file: dir, file path, rel path, task, day
function! s:BuildDiskMeta(file) abort
  let abs = fnamemodify(a:file, ':p')
  let root = (exists('g:md_card_root_dir') && !empty(g:md_card_root_dir))
        \ ? fnamemodify(g:md_card_root_dir, ':p')
        \ : timecard#util#project_root(abs)
  if exists('*relpath')
    let rel = relpath(abs, root)
  else
    let rel = substitute(abs, '^' . escape(root, '\\'), '', '')
  endif
  let task = timecard#util#task_from_rel(rel)
  let hash = timecard#util#hash_name(rel)
  let day = timecard#util#day_str()
  let base = root . '/.cardtime'
  let dir = base . '/days/' . day
  return {
        \ 'dir': dir,
        \ 'file': dir . '/' . hash . '.json',
        \ 'rel': rel,
        \ 'task': task,
        \ 'day': day,
        \ }
endfunction

function! s:LoadFromDisk() abort
  let f = expand('%:p')
  let meta = s:BuildDiskMeta(f)
  if !filereadable(meta.file)
    let b:card_loaded_day = meta.day
    let b:card_dirty = 0
    return
  endif
  " Prefer single-line fast path; fallback to reading all lines
  try
    let line1 = get(readfile(meta.file, '', 1), 0, '')
    let obj = json_decode(line1)
  catch
    try
      let obj = json_decode(join(readfile(meta.file), "\n"))
    catch
      let b:card_loaded_day = meta.day
      let b:card_dirty = 0
      return
    endtry
  endtry
  if type(get(obj, 'cards', {})) == type({})
    let b:card_seconds_by_key = copy(obj.cards)
  endif
  let b:card_loaded_day = meta.day
  let b:card_dirty = 0
endfunction

function! s:OnBufEnter() abort
  " Load today's persisted totals once per day per buffer, then reset baseline
  if get(b:, 'card_loaded_day', '') !=# timecard#util#day_str()
    call s:LoadFromDisk()
  endif
  let b:card_last_time = reltime()
endfunction

" Store current buffer's card-time snapshot for today (throttled or forced)
function! s:SaveToDisk(force) abort
  if !exists('b:card_seconds_by_key') || empty(b:card_seconds_by_key)
    return
  endif
  if !get(b:, 'card_dirty', 0)
    return
  endif
  if !a:force
    if !exists('b:card_last_write_time')
      let b:card_last_write_time = reltime()
      return
    endif
    if timecard#util#delta_seconds(b:card_last_write_time) < g:md_card_flush_interval
      return
    endif
  endif

  let abs = expand('%:p')
  if abs ==# ''
    return
  endif
  let meta = s:BuildDiskMeta(abs)
  call timecard#util#ensure_dir(meta.dir)
  let cards = {}
  let tot = 0.0
  for k in keys(b:card_seconds_by_key)
    let sec = b:card_seconds_by_key[k]
    let cards[k] = sec
    let tot += sec
  endfor
  let obj = {
        \ 'version': 1,
        \ 'day': meta.day,
        \ 'task': meta.task,
        \ 'file_rel': meta.rel,
        \ 'gap_sec': g:md_card_gap_sec,
        \ 'updated_at': timecard#util#iso(localtime()),
        \ 'total': tot,
        \ 'cards': cards,
        \ }
  let tmp = meta.file . '.tmp'
  try
    call writefile([json_encode(obj)], tmp)
    call rename(tmp, meta.file)
  catch
    " Fallback: try direct write
    call writefile([json_encode(obj)], meta.file)
  endtry
  let b:card_last_write_time = reltime()
  let b:card_dirty = 0
endfunction

function! s:OnCardEdit() abort
  if !exists('b:card_seconds_by_key')
    let b:card_seconds_by_key = {}
  endif

  " First change in this buffer/session: set baseline and card, don't count yet
  if !exists('b:card_last_time') || !exists('b:card_last_key')
    let b:card_last_time = reltime()
    let b:card_last_key = s:GetCurCardKey()
    return
  endif

  let card_cur_key = s:GetCurCardKey()
  let delta = timecard#util#delta_seconds(b:card_last_time)

  " Accumulate into the previous card when within the allowed gap
  if b:card_last_key !=# '' && delta <= g:md_card_gap_sec
    let prev = get(b:card_seconds_by_key, b:card_last_key, 0.0)
    let b:card_seconds_by_key[b:card_last_key] = prev + delta
    let b:card_dirty = 1
  endif

  " Flush immediately when switching cards if enabled
  if g:md_card_flush_on_switch && card_cur_key !=# b:card_last_key && get(b:, 'card_dirty', 0)
    call s:SaveToDisk(v:true)
  endif

  " Update baseline and current card
  let b:card_last_time = reltime()
  let b:card_last_key = card_cur_key
  " Throttled persistence
  call s:SaveToDisk(v:false)
endfunction

function! s:ReportHere() abort
  let key = s:GetCurCardKey()
  if key ==# ''
    echo 'Not inside a ## card'
    return
  endif
  let secs = get(get(b:, 'card_seconds_by_key', {}), key, 0.0)
  echo printf('%s  %.1f min', key, secs / 60.0)
endfunction

function! s:Reset() abort
  unlet! b:card_seconds_by_key b:card_last_time b:card_last_key b:card_dirty
  echo 'timecard: timers reset'
endfunction

function! s:SetupBuffer() abort
  " Only enable for markdown buffers whose filename matches configured keywords
  if !timecard#util#filename_allowed()
    return
  endif
  let b:card_enabled = 1
  if !exists('b:card_seconds_by_key')
    let b:card_seconds_by_key = {}
  endif
  if !exists('b:card_dirty')
    let b:card_dirty = 0
  endif
  augroup MdCardEditTimeBuffer
    autocmd! * <buffer>
    autocmd TextChanged  <buffer> call s:OnCardEdit()
    autocmd TextChangedI <buffer> call s:OnCardEdit()
    " Reset baseline on re-entering this buffer to avoid large idle gaps
    autocmd BufEnter     <buffer> call s:OnBufEnter()
    autocmd BufLeave     <buffer> call s:SaveToDisk(v:true)
  augroup END
endfunction

function! s:OnVimExit() abort
  " Only flush when this buffer was tracking card time
  if exists('b:card_enabled') && b:card_enabled
    call s:SaveToDisk(v:true)
  endif
endfunction

augroup MdCardEditTime
  autocmd!
  autocmd FileType markdown call s:SetupBuffer()
  autocmd VimLeavePre * call s:OnVimExit()
augroup END

" Commands
command! TimeCardHere call s:ReportHere()
command! TimeCardReset call s:Reset()
