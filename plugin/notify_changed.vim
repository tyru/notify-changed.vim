scriptencoding utf-8

if v:version < 800 && !has('nvim')
  echohl ErrorMsg
  echomsg 'notify-changed: This plugin requires Vim 8+ or Neovim (v0.5+ is recommended)'
  echohl None
  finish
endif

if !exists('g:notify_changed_command')
  if has('mac')
    let g:notify_changed_command = ['osascript', '-e', 'display notification "{{msg}}" with title "{{title}}"']
  elseif has('win32')
    let g:notify_changed_command = ['powershell', '-NoProfile', '-ExecutionPolicy', 'Unrestricted', '-Command', '& ' . expand('<sfile>:h:h') . '/macros/notify.ps1 "{{title}}" "{{msg}}"']
  elseif executable('notify-send')
    let g:notify_changed_command = ['notify-send', '"{{msg}}" with title "{{title}}"']
  else
    echohl ErrorMsg
    echomsg 'notify-changed: Your platform is not supported.'
    echohl None
    finish
  endif
endif

command! -nargs=* -complete=customlist,notify_changed#complete NotifyChanged call notify_changed#command([<f-args>])
