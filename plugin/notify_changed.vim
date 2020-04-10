scriptencoding utf-8

if v:version < 801
  echohl ErrorMsg
  echomsg 'notify-changed: This plugin requires Vim 8.1 or higher'
  echohl None
  finish
endif

if has("mac")
  let default_command = 'osascript -e "display notification" "%s"'
elseif has("linux")
  let default_command = 'notify-send "%s"'
else
  let default_command = ''
endif

let g:notify_changed_command = get(g:, "notify_changed_command", default_command)

command! -nargs=* -complete=customlist,notify_changed#complete NotifyChanged call notify_changed#command([<f-args>])
