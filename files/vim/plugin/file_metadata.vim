" file_metadata.vim (MetaMove-driven, project-rooted, minimal)
"
" Layout:
"   <root>/.metadata/index.json     { "rel/path": "uuid", ... }
"   <root>/.metadata/<uuid>.json    { filename, description, created, updated }
"
" Commands:
"   :MetaList
"   :MetaDesc [text...]
"   :MetaPrune
"   :MetaMove {newname | rel/to/root | ./rel/to/root}
"
" Autocmd:
"   BufWritePost -> upsert metadata

if exists('g:loaded_file_metadata') | finish | endif
let g:loaded_file_metadata = 1

let g:file_metadata_dirname = get(g:, 'file_metadata_dirname', '.metadata')

let s:root_cache = {}

function! s:now() abort
  return strftime('%Y-%m-%dT%H:%M:%S')
endfunction

function! s:abs() abort
  let p = fnamemodify(expand('%:p'), ':p')
  " optional canonicalization: helps with symlink-open vs realpath-open
  if exists('*resolve')
    let rp = resolve(p)
    if !empty(rp)
      return fnamemodify(rp, ':p')
    endif
  endif
  return p
endfunction

" root discovery (cached by start dir)
function! s:root(abs) abort
  let start = fnamemodify(a:abs, ':p:h')
  if has_key(s:root_cache, start)
    return s:root_cache[start]
  endif

  let gdir = finddir('.git', start . ';')
  if !empty(gdir)
    let s:root_cache[start] = fnamemodify(gdir, ':h')
    return s:root_cache[start]
  endif

  let rfile = findfile('.root', start . ';')
  if !empty(rfile)
    let s:root_cache[start] = fnamemodify(rfile, ':h')
    return s:root_cache[start]
  endif

  let s:root_cache[start] = getcwd()
  return s:root_cache[start]
endfunction

function! s:base(abs) abort
  return fnamemodify(s:root(a:abs), ':p') . '/' . g:file_metadata_dirname
endfunction

function! s:is_meta_file(abs) abort
  let base = fnamemodify(s:base(a:abs), ':p')
  let p    = fnamemodify(a:abs, ':p')
  return p[:len(base)-1] ==# base
endfunction

" single guard: returns absolute path or '' (non-file / meta-file)
function! s:abs_or_empty() abort
  if &buftype !=# '' | return '' | endif
  let p = expand('%:p')
  if empty(p) | return '' | endif
  let abs = fnamemodify(p, ':p')
  if exists('*resolve')
    let rp = resolve(abs)
    if !empty(rp)
      let abs = fnamemodify(rp, ':p')
    endif
  endif
  return s:is_meta_file(abs) ? '' : abs
endfunction

" rel path under <root>; fallback uses prefix-strip (NO regex)
function! s:rel(abs) abort
  let root = fnamemodify(s:root(a:abs), ':p')
  let p    = fnamemodify(a:abs, ':p')

  if exists('*relpath')
    return relpath(p, root)
  endif

  if root[-1:] !=# '/'
    let root .= '/'
  endif
  return p[:len(root)-1] ==# root ? p[len(root):] : p
endfunction
" fix oneline problem?
function! s:readjson(p) abort
  if !filereadable(a:p) | return {} | endif
  try
    let l = join(readfile(a:p), "\n")
    return empty(l) ? {} : json_decode(l)
  catch
    return {}
  endtry
endfunction

function! s:writejson(p, obj) abort
  call mkdir(fnamemodify(a:p, ':h'), 'p')
  let tmp = a:p . '.tmp'
  call writefile([json_encode(a:obj)], tmp)
  call rename(tmp, a:p)
endfunction

function! s:uuid() abort
  if executable('uuidgen')
    return substitute(trim(system('uuidgen')), '\s\+', '', 'g')
  endif
  return exists('*sha256')
        \ ? strpart(sha256(string(localtime()).':'.reltimestr(reltime()).':'.rand()), 0, 32)
        \ : (string(localtime()) . '-' . string(rand()))
endfunction

function! s:idx(abs, ...) abort
  let p = s:base(a:abs) . '/index.json'
  if a:0
    call s:writejson(p, a:1)
    return a:1
  endif
  let d = s:readjson(p)
  return type(d) == type({}) ? d : {}
endfunction

" ---- NEW: when rel-key missing, try reuse old uuid by matching filename ----
function! s:uuid_by_filename(abs, idx) abort
  let base = s:base(a:abs)
  " fast scan: look through current idx values and check uuid.json filename
  for id in values(a:idx)
    let mp = base . '/' . id . '.json'
    let fn = get(s:readjson(mp), 'filename', '')
    if !empty(fn)
      let fnp = fnamemodify(fn, ':p')
      if exists('*resolve')
        let r = resolve(fnp)
        if !empty(r) | let fnp = fnamemodify(r, ':p') | endif
      endif
      if fnp ==# a:abs
        return id
      endif
    endif
  endfor
  return ''
endfunction

" ensure mapping rel->uuid, return uuid (with filename-based reuse)
function! s:mid(abs) abort
  let rel = s:rel(a:abs)
  let idx = s:idx(a:abs)

  let id = get(idx, rel, '')
  if !empty(id)
    return id
  endif

  " try reuse by filename
  let reused = s:uuid_by_filename(a:abs, idx)
  if !empty(reused)
    let idx[rel] = reused
    call s:idx(a:abs, idx)
    return reused
  endif

  " allocate new
  let idx[rel] = s:uuid()
  call s:idx(a:abs, idx)
  return idx[rel]
endfunction

" prefer buffer-cached uuid; if allocated now, sync back to b:meta_uuid
function! s:mp(abs) abort
  let base = s:base(a:abs)
  let id = get(b:, 'meta_uuid', '')
  if empty(id)
    let id = s:mid(a:abs)
    let b:meta_uuid = id
  endif
  return base . '/' . id . '.json'
endfunction

function! s:upsert(abs, mp, desc) abort
  let now = s:now()
  let obj = s:readjson(a:mp)
  call extend(obj, {'filename': a:abs, 'description': '', 'created': now, 'updated': now}, 'keep')
  if a:desc isnot v:null | let obj.description = a:desc | endif
  let obj.filename = a:abs
  let obj.updated  = now
  call s:writejson(a:mp, obj)
endfunction

function! s:onenter() abort
  let abs = s:abs_or_empty()
  if empty(abs) | return | endif
  " load from index; if missing, don't allocate on enter (only allocate on write)
  let rel = s:rel(abs)
  let b:meta_uuid = get(s:idx(abs), rel, '')
endfunction

function! s:onwrite() abort
  let abs = s:abs_or_empty()
  if empty(abs) | return | endif
  call s:upsert(abs, s:mp(abs), v:null)
endfunction

function! s:metadesc(...) abort
  let abs = s:abs_or_empty()
  if empty(abs) | echo 'meta: no file' | return | endif
  let mp  = s:mp(abs)

  if a:0
    let newdesc = join(a:000, ' ')
  else
    let cur = get(s:readjson(mp), 'description', '')
    call inputsave()
    let newdesc = input('description: ', cur)
    call inputrestore()
  endif

  call s:upsert(abs, mp, newdesc)
  echo 'meta: description updated'
endfunction

function! s:metalist() abort
  let abs = s:abs_or_empty()
  if empty(abs) | echo 'meta: open a file first' | return | endif
  let mp  = s:mp(abs)
  let obj = s:readjson(mp)
  let fn  = get(obj,'filename','')
  call setqflist([{
        \ 'filename': mp, 'lnum': 1, 'col': 1,
        \ 'text': get(obj,'created','') . ' -> ' . get(obj,'updated','')
        \       . ' | ' . (empty(fn) ? '' : fnamemodify(fn, ':t'))
        \       . ' | ' . get(obj,'description','')
        \ }], 'r')
  copen
endfunction

function! s:metaprune() abort
  let abs = s:abs_or_empty()
  if empty(abs) | echo 'meta: open a file first' | return | endif

  let base = s:base(abs)
  if !isdirectory(base) | echo 'meta: no .metadata dir' | return | endif

  let idx   = s:idx(abs)
  let idxp  = base . '/index.json'
  let files = glob(base . '/*.json', 0, 1)
  call filter(files, 'v:val !~# "/index\\.json$"')
  if empty(files) | echo 'meta: empty' | return | endif

  let doomed = []
  let badid  = {}
  for p in files
    let obj = s:readjson(p)
    let fn  = get(obj, 'filename', '')
    if empty(fn) || !filereadable(fn)
      call add(doomed, p)
      let badid[fnamemodify(p, ':t:r')] = 1
    endif
  endfor
  if empty(doomed) | echo 'meta: prune none' | return | endif

  " show doomed list in quickfix (Scheme A)
  let qf = []
  for p in doomed
    let obj = s:readjson(p)
    let fn  = get(obj, 'filename', '')
    call add(qf, {
          \ 'filename': p, 'lnum': 1, 'col': 1,
          \ 'text': (empty(fn) ? '[missing filename]' : fn)
          \       . ' | ' . get(obj, 'description', '')
          \       . ' | ' . get(obj, 'created', '') . ' -> ' . get(obj, 'updated', '')
          \ })
  endfor
  call setqflist(qf, 'r')
  copen

  echo 'meta: will delete ' . len(doomed) . ' (see quickfix)'
  if input('Proceed? [y/N] ') !~? '^y'
    echo 'meta: prune aborted' | return
  endif

  let n = 0
  for p in doomed
    if delete(p) == 0 | let n += 1 | endif
  endfor

  for [k, v] in items(idx)
    if has_key(badid, v) | call remove(idx, k) | endif
  endfor
  call s:writejson(idxp, idx)
  echo 'meta: pruned ' . n
endfunction

" --- MetaMove: newname OR rel/to/root OR ./rel/to/root (same-root assumption) ---

function! s:resolve_newabs_2mode(old_abs, newpath) abort
  if a:newpath =~# '^/'
    throw 'meta: absolute paths not supported (use newname OR rel/to/root)'
  endif

  if a:newpath !~# '/'
    return fnamemodify(a:old_abs, ':p:h') . '/' . a:newpath
  endif

  if a:newpath =~# '^\./'
    return fnamemodify(s:root(a:old_abs), ':p') . '/' . a:newpath[2:]
  endif

  return fnamemodify(s:root(a:old_abs), ':p') . '/' . a:newpath
endfunction

function! s:metamove(newpath) abort
  let old_abs = s:abs_or_empty()
  if empty(old_abs) | echo 'meta: open a file first' | return | endif

  " save current buffer to avoid losing changes before rename()
  silent! write

  let new_abs = fnamemodify(s:resolve_newabs_2mode(old_abs, a:newpath), ':p')
  if s:is_meta_file(new_abs) | echo 'meta: refusing to move into .metadata' | return | endif

  if old_abs ==# new_abs
    echo 'meta: same path' | return
  endif

  if filereadable(new_abs)
    echo 'meta: target exists: ' . new_abs
    if input('Overwrite? [y/N] ') !~? '^y'
      echo 'meta: move aborted' | return
    endif
    if delete(new_abs) != 0
      echo 'meta: failed to remove existing target' | return
    endif
  endif

  let old_rel = s:rel(old_abs)
  let new_rel = s:rel(new_abs)

  let idx  = s:idx(old_abs)
  let uuid = get(b:, 'meta_uuid', get(idx, old_rel, ''))
  if empty(uuid)
    " do not allocate a brand-new uuid if old_rel missing; reuse-by-filename via s:mid
    let uuid = s:mid(old_abs)
  endif

  call mkdir(fnamemodify(new_abs, ':h'), 'p')
  if rename(old_abs, new_abs) != 0
    echo 'meta: rename() failed' | return
  endif

  if has_key(idx, old_rel) | call remove(idx, old_rel) | endif
  let idx[new_rel] = uuid
  call s:idx(new_abs, idx)

  let mp = s:base(new_abs) . '/' . uuid . '.json'
  call s:upsert(new_abs, mp, v:null)

  execute 'silent keepalt file ' . fnameescape(new_abs)
  let b:meta_uuid = uuid

  echo 'meta: moved -> ' . new_abs
endfunction

command! -nargs=* MetaDesc  call s:metadesc(<f-args>)
command!          MetaList  call s:metalist()
command!          MetaPrune call s:metaprune()
command! -nargs=1 MetaMove  call s:metamove(<f-args>)

augroup FileMetadata
  autocmd!
  autocmd BufEnter,BufReadPost * call s:onenter()
  autocmd BufWritePost * call s:onwrite()
augroup END

