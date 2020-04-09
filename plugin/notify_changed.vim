scriptencoding utf-8

if v:version < 801
  echohl ErrorMsg
  echomsg 'notify-changed: This plugin requires Vim 8.1 or higher'
  echohl None
  finish
endif

command! -nargs=* -complete=customlist,notify_changed#complete NotifyChanged call notify_changed#command([<f-args>])
