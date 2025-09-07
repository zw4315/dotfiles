" timecard utility helpers (autoload)
" Focus: small, self-contained helpers without business logic

if exists('g:loaded_timecard_util')
  finish
endif
let g:loaded_timecard_util = 1

function! timecard#util#ensure_dir(path) abort
  if !isdirectory(a:path)
    call mkdir(a:path, 'p')
  endif
endfunction

function! timecard#util#hash_name(text) abort
  if exists('*sha256')
    let h = sha256(a:text)
    return tolower(strpart(h, 0, 40))
  endif
  let s = substitute(a:text, '[^A-Za-z0-9._/-]', '_', 'g')
  let s = substitute(s, '/', '_', 'g')
  return tolower(strpart(s, 0, 40))
endfunction

function! timecard#util#iso(ts) abort
  return strftime('%Y-%m-%dT%H:%M:%S', float2nr(a:ts))
endfunction

function! timecard#util#day_str() abort
  return strftime('%Y-%m-%d')
endfunction

function! timecard#util#task_from_rel(rel) abort
  if a:rel =~# '/'
    return matchstr(a:rel, '^\zs[^/]*')
  endif
  return a:rel
endfunction

let s:warned_roots = {}

function! timecard#util#project_root(abs) abort
  let start = fnamemodify(a:abs, ':p:h')
  let gdir = finddir('.git', start . ';')
  if !empty(gdir)
    return fnamemodify(gdir, ':h')
  endif
  let rfile = findfile('.root', start . ';')
  if !empty(rfile)
    return fnamemodify(rfile, ':h')
  endif
  if !has_key(s:warned_roots, start)
    let s:warned_roots[start] = 1
    echohl WarningMsg
    echom '[timecard] project_root not found for: ' . start
    echom '[timecard] create a .git or .root at the project root.'
    echohl None
  endif
  return start
endfunction

function! timecard#util#delta_seconds(last) abort
  let l:rt = reltime(a:last)
  let l:sec = exists('*reltimefloat')
        \ ? reltimefloat(l:rt)
        \ : str2float(reltimestr(l:rt))
  if l:sec < 0
    let l:sec = 0.0
  endif
  return l:sec
endfunction

function! timecard#util#filename_allowed() abort
  if &filetype !=# 'markdown'
    return 0
  endif
  let fname = expand('%:t')
  let kws = get(g:, 'md_card_filename_keywords', [])
  if type(kws) == type([])
    for kw in kws
      if fname =~? kw
        return 1
      endif
    endfor
    return 0
  endif
  return fname =~? kws
endfunction

function! timecard#util#read_json(path) abort
  try
    return json_decode(join(readfile(a:path), "\n"))
  catch
    return {}
  endtry
endfunction
