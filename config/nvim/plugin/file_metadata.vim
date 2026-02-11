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

  let s:root_cache[start] = ''
  return ''
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
  if empty(s:root(abs))
    return ''
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

" when rel-key missing, try reuse old uuid by matching filename
function! s:uuid_by_filename(abs, idx) abort
  let base = s:base(a:abs)
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

  let reused = s:uuid_by_filename(a:abs, idx)
  if !empty(reused)
    let idx[rel] = reused
    call s:idx(a:abs, idx)
    return reused
  endif

  let idx[rel] = s:uuid()
  call s:idx(a:abs, idx)
  return idx[rel]
endfunction

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

  let idx = s:idx(abs)
  if empty(idx) | echo 'meta: empty index' | return | endif

  let keep = {}
  for [k, id] in items(idx)
    let mp = base . '/' . id . '.json'
    if filereadable(mp)
      let keep[id] = 1
    else
      call remove(idx, k)
    endif
  endfor

  for mp in glob(base . '/*.json', 0, 1)
    let id = fnamemodify(mp, ':t:r')
    if id ==# 'index' | continue | endif
    if !has_key(keep, id)
      call delete(mp)
    endif
  endfor

  call s:idx(abs, idx)
  echo 'meta: pruned'
endfunction

function! s:metamove(newname) abort
  let abs = s:abs_or_empty()
  if empty(abs) | echo 'meta: no file' | return | endif

  let root = fnamemodify(s:root(abs), ':p')
  if empty(root) | echo 'meta: no root' | return | endif

  let newabs = a:newname
  if newabs =~# '^\\./'
    let newabs = root . '/' . newabs[2:]
  elseif newabs !~# '^/'
    let newabs = root . '/' . newabs
  endif
  let newabs = fnamemodify(newabs, ':p')

  call mkdir(fnamemodify(newabs, ':h'), 'p')
  call rename(abs, newabs)

  " update index mapping
  let idx = s:idx(newabs)
  let oldrel = s:rel(abs)
  let newrel = s:rel(newabs)
  let id = get(idx, oldrel, '')
  if empty(id)
    let id = s:mid(newabs)
  endif
  call remove(idx, oldrel)
  let idx[newrel] = id
  call s:idx(newabs, idx)

  " update metadata file
  let mp = s:base(newabs) . '/' . id . '.json'
  call s:upsert(newabs, mp, v:null)

  execute 'edit ' . fnameescape(newabs)
  echo 'meta: moved'
endfunction

command! MetaList  call s:metalist()
command! -nargs=* MetaDesc  call s:metadesc(<f-args>)
command! MetaPrune call s:metaprune()
command! -nargs=1 MetaMove  call s:metamove(<q-args>)

augroup FileMetadata
  autocmd!
  autocmd BufEnter      * call s:onenter()
  autocmd BufWritePost  * call s:onwrite()
augroup END

