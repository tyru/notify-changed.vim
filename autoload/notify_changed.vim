scriptencoding utf-8

let s:watching = {}

let s:OPTS = ['-switch', '-no-switch', '-unwatch']
function! notify_changed#complete(arglead, ...) abort
  let opts = copy(s:OPTS)
  if a:arglead !=# ''
    return filter(opts, 'stridx(v:val, a:arglead) ==# 0')
  endif
  return opts
endfunction

function! notify_changed#command(args) abort
  let bufnr = bufnr('')
  let watched = v:false
  let unwatched = v:false
  if !has_key(s:watching, bufnr)
    let watched = v:true
    call s:watch(bufnr, win_getid(), 3000)
  endif
  let info = s:watching[bufnr]
  for arg in a:args
    if arg ==# '-switch'
      let info.switch = v:true
    elseif arg ==# '-no-switch'
      let info.switch = v:false
    elseif arg ==# '-unwatch'
      let unwatched = v:true
      call s:unwatch(bufnr)
    endif
  endfor
  if !watched && !unwatched
    echo 'Updated watch info.'
  endif
endfunction

function! s:watch(bufnr, winid, period) abort
  let s:watching[a:bufnr] = {
  \ 'bufnr': a:bufnr,
  \ 'winid': a:winid,
  \ 'switch': v:false,
  \ 'linecount': getbufinfo(a:bufnr)[0].linecount,
  \ 'lastline': getbufline(a:bufnr, '$')[0],
  \}
  let s:watching[a:bufnr].timer =
  \ timer_start(a:period, function('s:check_output', [s:watching[a:bufnr]]), {'repeat': -1})
  echo 'Watched buffer: ' . bufname(a:bufnr)
endfunction

" vint: next-line -ProhibitUnusedVariable
function! s:check_output(info, _) abort
  if win_id2tabwin(a:info.winid) ==# [0, 0]
    return
  endif
  let linecount = getbufinfo(a:info.bufnr)[0].linecount
  let lastline = getbufline(a:info.bufnr, '$')[0]
  if a:info.linecount !=# linecount || a:info.lastline !=# lastline
    " TODO notify changed lines
    " TODO support windows and linux
    let start = a:info.linecount + (a:info.lastline !=# lastline ? 0 : 1)
    let difflines = getbufline(a:info.bufnr, start, linecount)
    let msg = s:escape_arg(join(difflines))
    let title = s:escape_arg(bufname(a:info.bufnr))
    call job_start(['osascript', '-e', 'display notification "' . msg . '" with title "' . title . '"'])
  endif
  let a:info.linecount = linecount
  let a:info.lastline = lastline
endfunction

function! s:escape_arg(str) abort
  let str = strcharpart(a:str, 0, 100)
  let str = escape(str, '"')
  return str
endfunction

function! s:unwatch(bufnr) abort
  let info = remove(s:watching, a:bufnr)
  call timer_stop(get(info, 'timer'))
  let name = bufname(a:bufnr)
  echo 'Unwatched buffer' . (name !=# '' ? ': ' . name : '.')
endfunction
