" file_metadata.vim (UUID + index.json mapping, project-rooted, minimal)
"
" Layout:
"   <root>/.metadata/index.json     { "rel/path": "uuid", ... }
"   <root>/.metadata/<uuid>.json    { filename, description, created, updated }
"
" Commands:
"   :MetaList   -> quickfix single entry for CURRENT file (Enter opens JSON)
"   :MetaDesc   -> edit description for current file
"   :MetaPrune  -> delete orphan metadata (filename missing) + remove from index
"
" Autocmd:
"   BufWritePost -> upsert metadata (and ensure index mapping)
"   BufFilePost  -> update index key on rename/move inside Vim

if exists('g:loaded_file_metadata') | finish | endif
let g:loaded_file_metadata = 1

let g:file_metadata_dirname = get(g:, 'file_metadata_dirname', '.metadata')

function! s:now() abort
  return strftime('%Y-%m-%dT%H:%M:%S')
endfunction

function! s:okbuf() abort
  return &buftype ==# '' && !empty(expand('%:p'))
endfunction

function! s:abs() abort
  return fnamemodify(expand('%:p'), ':p')
endfunction

function! s:root(abs) abort
  let start = fnamemodify(a:abs, ':p:h')
  let gdir  = finddir('.git', start . ';')
  if !empty(gdir) | return fnamemodify(gdir, ':h') | endif
  let rfile = findfile('.root', start . ';')
  if !empty(rfile) | return fnamemodify(rfile, ':h') | endif
  return getcwd()
endfunction

function! s:base(abs) abort
  return fnamemodify(s:root(a:abs), ':p') . '/' . g:file_metadata_dirname
endfunction

function! s:rel(abs) abort
  let root = fnamemodify(s:root(a:abs), ':p')
  if exists('*relpath')
    return relpath(fnamemodify(a:abs, ':p'), root)
  endif
  return substitute(fnamemodify(a:abs, ':p'), '^' . escape(root, '\') . '/', '', '')
endfunction

function! s:readjson(p) abort
  if !filereadable(a:p) | return {} | endif
  try
    let l = readfile(a:p, '', 1)
    return empty(l) ? {} : json_decode(l[0])
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

" index helper: s:idx(abs) -> dict, s:idx(abs, dict) -> save
function! s:idx(abs, ...) abort
  let p = s:base(a:abs) . '/index.json'
  if a:0
    call s:writejson(p, a:1)
    return a:1
  endif
  let d = s:readjson(p)
  return type(d) == type({}) ? d : {}
endfunction

" ensure mapping rel->uuid, return uuid
function! s:mid(abs) abort
  let rel = s:rel(a:abs)
  let idx = s:idx(a:abs)
  if empty(get(idx, rel, ''))
    let idx[rel] = s:uuid()
    call s:idx(a:abs, idx)
  endif
  return idx[rel]
endfunction

function! s:mp(abs) abort
  return s:base(a:abs) . '/' . s:mid(a:abs) . '.json'
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

function! s:onwrite() abort
  if !s:okbuf() | return | endif
  let abs = s:abs()
  call s:upsert(abs, s:mp(abs), v:null)
endfunction

" track current rel for rename detection
function! s:onenter() abort
  if !s:okbuf() | return | endif
  let b:meta_rel = s:rel(s:abs())
endfunction

" if buffer filename changed, move index key old_rel -> new_rel (keep uuid)
function! s:onfilepost() abort
  if !s:okbuf() | return | endif
  let abs = s:abs()
  let new = s:rel(abs)
  let old = get(b:, 'meta_rel', '')
  if empty(old) || old ==# new
    let b:meta_rel = new
    return
  endif

  let idx = s:idx(abs)
  let id  = get(idx, old, '')
  if empty(id)
    let b:meta_rel = new
    return
  endif

  call remove(idx, old)
  let idx[new] = id
  call s:idx(abs, idx)

  let b:meta_rel = new
endfunction

function! s:metadesc(...) abort
  if !s:okbuf() | echo 'meta: no file' | return | endif
  let abs = s:abs()
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
  if !s:okbuf() | echo 'meta: open a file first' | return | endif
  let abs = s:abs()
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
  if !s:okbuf() | echo 'meta: open a file first' | return | endif
  let abs  = s:abs()
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
    let fn = get(s:readjson(p), 'filename', '')
    if empty(fn) || !filereadable(fn)
      call add(doomed, p)
      let badid[fnamemodify(p, ':t:r')] = 1
    endif
  endfor
  if empty(doomed) | echo 'meta: prune none' | return | endif

  echo 'meta: will delete ' . len(doomed)
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

command! -nargs=* MetaDesc  call s:metadesc(<f-args>)
command!          MetaList  call s:metalist()
command!          MetaPrune call s:metaprune()

augroup FileMetadata
  autocmd!
  autocmd BufEnter,BufReadPost * call s:onenter()
  autocmd BufFilePost * call s:onfilepost()
  autocmd BufWritePost * call s:onwrite()
augroup END

