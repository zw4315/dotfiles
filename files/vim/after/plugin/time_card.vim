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

" Enable tracking only for filenames matching these keywords (case-insensitive).
" Accepts a list of strings or a regex string.
if !exists('g:md_card_filename_keywords')
  let g:md_card_filename_keywords = ['append', 'review', 'kanban']
endif

" delta seconds helper moved to autoload: timecard#util#delta_seconds(last)

" Detect if the current line indicates an H2 header is being started but
" not yet a valid '## ' header (e.g. only '#' or '##' without space/title).
function! s:IsH2HeaderInProgress() abort
  let l = getline('.')
  if l =~# '^\s*#$'
    return 1
  endif
  " Match '##' optionally followed by spaces but no title text
  if l =~# '^\s*##\s*$'
    return 1
  endif
  return 0
endfunction

" Collect all valid H2 (##) titles present in current buffer.
" Returns a dictionary used as a set: {title -> 1}
function! s:CollectBufferH2Titles() abort
  let titles = {}
  let lnum = 1
  while lnum <= line('$')
    let l = getline(lnum)
    if l =~# '^\s*##\s\+\S'
      let t = matchstr(l, '^\s*##\s\+\zs.*')
      let t = trim(t)
      let t = substitute(t, '\s\+', ' ', 'g')
      if !empty(t)
        let titles[t] = 1
      endif
    endif
    let lnum += 1
  endwhile
  return titles
endfunction

function! s:GetCurCardKey() abort
  " Find nearest previous (or current) '## ' header (not ###), normalize as key
  let lnum = search('^\s*##\s\+', 'bcnW')
  if lnum == 0
    return ''
  endif
  let title = matchstr(getline(lnum), '^\s*##\s\+\zs.*')
  let title = trim(title)
  let title = substitute(title, '\s\+', ' ', 'g')
  return title
endfunction

" Read a JSON file safely; return {} on error
" Import persisted cards object to in-memory map {title -> card object}
function! s:ImportCards(obj) abort
  let nowiso = timecard#util#iso(localtime())
  let src = get(a:obj, 'cards', {})
  let out = {}
  if type(src) != type({})
    return out
  endif
  for k in keys(src)
    let nk = s:NormalizeDiskKey(k)
    let item = src[k]
    if type(item) == type(0.0) || type(item) == type(0)
      let sec = (0.0 + item)
      let created = get(a:obj, 'updated_at', nowiso)
      let updated = get(a:obj, 'updated_at', created)
    elseif type(item) == type({})
      let sec = (0.0 + get(item, 'seconds', 0.0))
      let created = get(item, 'created_at', nowiso)
      let updated = get(item, 'updated_at', created)
    else
      continue
    endif
    let out[nk] = {'title': nk, 'seconds': sec, 'created_at': created, 'updated_at': updated}
  endfor
  return out
endfunction

" If the current edit is on a header and the title changed, move accumulated seconds
function! s:MergeOnTitleRename(prev_key, cur_key) abort
  " Only treat as rename when editing a header and the title key changed
  if a:prev_key ==# '' || a:cur_key ==# '' || a:prev_key ==# a:cur_key
    return
  endif
  if getline('.') !~# '^\s*##\s\+'
    return
  endif
  if !exists('b:cards') | return | endif

  let old = get(b:cards, a:prev_key, {})
  let oldsec = (0.0 + get(old, 'seconds', 0.0))

  let nowiso = timecard#util#iso(localtime())
  let new = get(b:cards, a:cur_key, {'title': a:cur_key, 'seconds': 0.0, 'created_at': nowiso, 'updated_at': nowiso})

  let new.seconds = (0.0 + get(new, 'seconds', 0.0)) + oldsec
  let old_created = get(old, 'created_at', nowiso)
  let new_created = get(new, 'created_at', nowiso)
  if old_created < new_created
    let new.created_at = old_created
  endif
  let new.updated_at = nowiso

  let b:cards[a:cur_key] = new
  if has_key(b:cards, a:prev_key)
    call remove(b:cards, a:prev_key)
  endif
  let b:card_dirty = 1
endfunction

" Normalize a persisted card key to a title key (no line-number mapping)
function! s:NormalizeDiskKey(k) abort
  let key = type(a:k) == type('') ? a:k : string(a:k)
  let key = trim(key)
  let key = substitute(key, '\s\+', ' ', 'g')
  return key
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
    if !exists('b:cards') | let b:cards = {} | endif
    return
  endif
  let obj = timecard#util#read_json(meta.file)
  let b:cards = s:ImportCards(obj)
  let b:card_loaded_day = meta.day
  let b:card_dirty = 0
endfunction

function! s:OnBufEnter() abort
  " Load today's persisted totals once per day per buffer, then reset baseline
  if get(b:, 'card_loaded_day', '') !=# timecard#util#day_str()
    call s:LoadFromDisk()
  endif
  let b:card_last_time = reltime()
  " Capture the pre-edit title key so a first edit that renames the header
  " can correctly migrate seconds from old -> new.
  let b:card_last_key = s:GetCurCardKey()
endfunction

" Store current buffer's card-time snapshot for today (throttled or forced)
function! s:SerializeCards(nowiso) abort
  let out = {}
  let total = 0.0
  for k in keys(get(b:, 'cards', {}))
    let c = b:cards[k]
    if !has_key(c, 'created_at') | let c.created_at = a:nowiso | endif
    if !has_key(c, 'updated_at') | let c.updated_at = a:nowiso | endif
    let b:cards[k] = c
    let sec = (0.0 + get(c, 'seconds', 0.0))
    let out[k] = {'title': k, 'seconds': sec, 'created_at': c.created_at, 'updated_at': c.updated_at}
    let total += sec
  endfor
  return [out, total]
endfunction

function! s:WriteJson(path, obj) abort
  let tmp = a:path . '.tmp'
  try
    call writefile([json_encode(a:obj)], tmp)
    call rename(tmp, a:path)
  catch
    call writefile([json_encode(a:obj)], a:path)
  endtry
endfunction

function! s:SaveToDisk(force) abort
  let abs = expand('%:p')
  if abs ==# ''
    return
  endif
  let meta = s:BuildDiskMeta(abs)
  if !exists('b:cards') || empty(b:cards)
    return
  endif
  if !get(b:, 'card_dirty', 0)
    return
  endif
  call timecard#util#ensure_dir(meta.dir)
  let nowiso = timecard#util#iso(localtime())
  let parts = s:SerializeCards(nowiso)
  let cards = parts[0]
  let tot = parts[1]
  let obj = {
        \ 'version': 2,
        \ 'day': meta.day,
        \ 'task': meta.task,
        \ 'file_rel': meta.rel,
        \ 'gap_sec': g:md_card_gap_sec,
        \ 'updated_at': nowiso,
        \ 'total': tot,
        \ 'cards': cards,
        \ }
  call s:WriteJson(meta.file, obj)
  let b:card_dirty = 0
endfunction

function! s:SeedFirstEdit() abort
  let nowiso = timecard#util#iso(localtime())
  let cur = s:GetCurCardKey()
  " If user is just starting a new H2 header (typing '#' or '##'),
  " treat as no active card to avoid attributing to the previous card.
  if s:IsH2HeaderInProgress()
    let cur = ''
  endif
  let b:card_last_time = reltime()
  let b:card_last_key = cur
  if cur ==# '' | return | endif
  let c0 = get(b:cards, cur, {'title': cur, 'seconds': 0.0, 'created_at': nowiso, 'updated_at': nowiso})
  if !has_key(c0, 'created_at') | let c0.created_at = nowiso | endif
  if !has_key(c0, 'updated_at') | let c0.updated_at = nowiso | endif
  let b:cards[cur] = c0
  let b:card_dirty = 1
endfunction

function! s:AccumulateDeltaToLastCard(delta) abort
  if b:card_last_key ==# '' || a:delta > g:md_card_gap_sec | return | endif
  " Avoid creating zero-second throwaway entries for brand-new titles
  if a:delta <= 0.0 && !has_key(b:cards, b:card_last_key)
    return
  endif
  let nowiso = timecard#util#iso(localtime())
  let c = get(b:cards, b:card_last_key, {'title': b:card_last_key, 'seconds': 0.0, 'created_at': nowiso, 'updated_at': nowiso})
  let c.seconds = (0.0 + get(c, 'seconds', 0.0)) + a:delta
  if !has_key(c, 'created_at') | let c.created_at = nowiso | endif
  let c.updated_at = nowiso
  let b:cards[b:card_last_key] = c
  let b:card_dirty = 1
endfunction


function! s:OnCardEdit() abort
  if !exists('b:cards')
    let b:cards = {}
  endif

  " First change in this buffer/session: set baseline and card, don't count yet
  if !exists('b:card_last_time') || !exists('b:card_last_key')
    call s:SeedFirstEdit()
    return
  endif

  let card_cur_key = s:GetCurCardKey()
  let delta = timecard#util#delta_seconds(b:card_last_time)

  " If user is starting a new H2 header (only '#' or '##'), do not
  " attribute the delta to the previous card; reset baseline and pause.
  if s:IsH2HeaderInProgress()
    let b:card_last_time = reltime()
    let b:card_last_key = ''
    return
  endif

  call s:AccumulateDeltaToLastCard(delta)

  call s:MergeOnTitleRename(b:card_last_key, card_cur_key)

  " Update baseline and current card
  let b:card_last_time = reltime()
  let b:card_last_key = card_cur_key
endfunction

" Remove cards that exist in JSON/memory but no longer exist in the current buffer
function! s:CleanUnusedCards() abort
  if !exists('b:cards')
    echo 'timecard: no cards loaded for this buffer'
    return
  endif
  let present = s:CollectBufferH2Titles()
  let removed = []
  for k in keys(b:cards)
    if !has_key(present, k)
      call add(removed, k)
    endif
  endfor
  if empty(removed)
    echo 'timecard: no stale cards to clean'
    return
  endif
  " Preview list and ask for confirmation
  echo 'timecard: will remove ' . len(removed) . ' card(s):'
  for k in sort(removed)
    echo '  - ' . k
  endfor
  call inputsave()
  let ans = input('Proceed? [y/N] ')
  call inputrestore()
  if ans ==# '' || tolower(ans)[0] !=# 'y'
    echo 'timecard: clean aborted'
    return
  endif
  for k in removed
    call remove(b:cards, k)
  endfor
  let b:card_dirty = 1
  call s:SaveToDisk(v:true)
  echo 'timecard: cleaned ' . len(removed) . ' card(s)'
endfunction

function! s:ReportHere() abort
  let key = s:GetCurCardKey()
  if key ==# ''
    echo 'Not inside a ## card'
    return
  endif
  let secs = get(get(b:, 'cards', {})->get(key, {}), 'seconds', 0.0)
  echo printf('%s  %.1f min', key, (0.0 + secs) / 60.0)
endfunction

function! s:Reset() abort
  unlet! b:cards b:card_last_time b:card_last_key b:card_dirty
  echo 'timecard: timers reset'
endfunction

function! s:SetupBuffer() abort
  if !timecard#util#filename_allowed()
    return
  endif
  if !exists('b:cards')
    let b:cards = {}

  endif
  if !exists('b:card_dirty')
    let b:card_dirty = 0
  endif
  augroup MdCardEditTimeBuffer
    autocmd! * <buffer>
    autocmd TextChanged  <buffer> call s:OnCardEdit()
    autocmd TextChangedI <buffer> call s:OnCardEdit()
    autocmd BufEnter     <buffer> call s:OnBufEnter()
    autocmd BufWritePost <buffer> call s:SaveToDisk(v:true)
  augroup END
  " Ensure existing history is loaded immediately on first setup of this buffer
  call s:OnBufEnter()
endfunction

augroup MdCardEditTime
  autocmd!
  autocmd FileType markdown call s:SetupBuffer()
  " Ensure setup also happens when switching to another Markdown file via plugins
  autocmd BufEnter *.md,*.markdown call s:SetupBuffer()
augroup END

" Commands
command! TimeCardHere call s:ReportHere()
command! TimeCardReset call s:Reset()
command! TimeCardsClean call s:CleanUnusedCards()
