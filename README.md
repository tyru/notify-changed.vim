# notify-changed.vim

Notify terminal buffer's changed lines with OS notification system (TODO: currently macOS only)

![macOS notification](https://user-images.githubusercontent.com/48169/78953099-aa98f480-7b12-11ea-8ada-95260247cf77.png)

## Usage

Run `:NotifyChanged` in the terminal buffer you want this plugin to notify.
This registers / updates / unregister (`-unwatch`) watch timer by given options

```
:NotifyChanged [-unwatch] [-switch] [-no-switch] [-period {period}]
```

* `-unwatch`: Unregister watch timer
* `-switch`, `-no-switch`: Switch to the terminal window if changed (or not)
* `-period {period}`: specify the period for timer (e.g. `{period}` = `10s`, `1000m`, `1000` (same as `1000m`))
