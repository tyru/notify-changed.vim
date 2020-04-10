scriptencoding utf-8

let s:watching = {}

let s:OPTS = ['-switch', '-no-switch', '-unwatch', '-period']
function! notify_changed#complete(arglead, ...) abort
  let opts = copy(s:OPTS)
  if a:arglead !=# ''
    return filter(opts, 'stridx(v:val, a:arglead) ==# 0')
  endif
  return opts
endfunction

function! notify_changed#command(args) abort
  let bufnr = bufnr('')
  let action = 'watch'
  if has_key(s:watching, bufnr)
    let opt = {'switch': s:watching[bufnr].switch, 'period': 3000}
  else
    let opt = {'switch': v:false, 'period': 3000}
  endif
  let i = 0
  while i < len(a:args)
    let arg = a:args[i]
    if arg ==# '-switch'
      let opt.switch = v:true
    elseif arg ==# '-no-switch'
      let opt.switch = v:false
    elseif arg ==# '-unwatch'
      let action = 'unwatch'
    elseif arg ==# '-period'
      let p = s:parse_period(a:args[i+1])
      if p isnot v:null
        let opt.period = p
      endif
      let i += 1
    endif
    let i += 1
  endwhile
  let action = action ==# 'watch' && has_key(s:watching, bufnr) ? 'update' : action
  if action ==# 'watch'
    call s:watch(bufnr, win_getid(), opt)
    echo 'Watched buffer: ' . bufname(bufnr)
  elseif action ==# 'unwatch'
    if !has_key(s:watching, bufnr)
      echo 'Buffer is not watched'
      return
    endif
    call s:unwatch(bufnr)
    let name = bufname(bufnr)
    echo 'Unwatched buffer' . (name !=# '' ? ': ' . name : '.')
  elseif action ==# 'update'
    if has_key(s:watching, bufnr)
      call s:unwatch(bufnr)
    endif
    call s:watch(bufnr, win_getid(), opt)
    echo 'Updated watch info.'
  endif
endfunction

function! s:parse_period(str) abort
  for [pat, l:F] in [
  \ ['\v^(\d+)s(ec)?$', {m -> +(m[1] * 1000)}],
  \ ['\v^(\d+)m%[sec]?$', {m -> +m[1]}],
  \ ['\v^(\d+)$', {m -> +m[1]}],
  \]
    let m = matchlist(a:str, pat)
    if !empty(m)
      return l:F(m)
    endif
  endfor
  return v:null
endfunction

function! s:watch(bufnr, winid, opt) abort
  let s:watching[a:bufnr] = {
  \ 'bufnr': a:bufnr,
  \ 'winid': a:winid,
  \ 'switch': a:opt.switch,
  \ 'linecount': s:get_linecount(a:bufnr),
  \ 'lastline': getbufline(a:bufnr, '$')[0],
  \}
  let s:watching[a:bufnr].timer =
  \ timer_start(a:opt.period, function('s:check_output', [s:watching[a:bufnr]]), {'repeat': -1})
endfunction

" vint: next-line -ProhibitUnusedVariable
function! s:check_output(info, _) abort
  if win_id2tabwin(a:info.winid) ==# [0, 0]
    return
  endif
  let linecount = s:get_linecount(a:info.bufnr)
  let lastline = getbufline(a:info.bufnr, '$')[0]
  if a:info.linecount !=# linecount || a:info.lastline !=# lastline
    let start = a:info.linecount + (a:info.lastline !=# lastline ? 0 : 1)
    let difflines = getbufline(a:info.bufnr, start, linecount)
    let msg = s:truncate_arg(join(difflines))
    let title = s:truncate_arg(bufname(a:info.bufnr))
    let command = s:build_command(g:notify_changed_command, msg, title)
    call s:run_background(command)
    if a:info.switch
      call win_gotoid(a:info.winid)
    endif
  endif
  let a:info.linecount = linecount
  let a:info.lastline = lastline
endfunction

if has('nvim')
  function! s:run_background(command) abort
    call jobstart(a:command)
  endfunction
  if has('nvim-0.5')
    function! s:get_linecount(bufnr) abort
      return getbufinfo(a:bufnr)[0].linecount
    endfunction
  else
    function! s:get_linecount(bufnr) abort
      return len(getbufline(a:bufnr, 1, '$'))
    endfunction
  endif
else
  function! s:run_background(command) abort
    call job_start(a:command)
  endfunction
  function! s:get_linecount(bufnr) abort
    return getbufinfo(a:bufnr)[0].linecount
  endfunction
endif

function! s:build_command(fmt, msg, title) abort
  return map(copy(a:fmt), 's:embed(v:val, a:msg, a:title)')
endfunction

function! s:embed(str, msg, title) abort
  let str = substitute(a:str, '{{msg}}', a:msg, 'g')
  let str = substitute(str, '{{title}}', a:title, 'g')
  return str
endfunction

function! s:truncate_arg(str) abort
  let str = strcharpart(a:str, 0, 100)
  let str = escape(str, '"')
  let converted = iconv(str, &encoding, 'char')
  return converted !=# '' ? converted : str
endfunction

function! s:unwatch(bufnr) abort
  let info = remove(s:watching, a:bufnr)
  call timer_stop(get(info, 'timer'))
endfunction
