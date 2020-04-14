# notify-changed.vim

Notify terminal buffer's changed lines with OS notification system.

<img alt='macOS notification' src='https://user-images.githubusercontent.com/48169/78953099-aa98f480-7b12-11ea-8ada-95260247cf77.png' width='382'>
<img alt='Windows notification' src='https://user-images.githubusercontent.com/48169/78960964-aaa4ee80-7b2a-11ea-87c8-dc6cc38d9914.png' width='382'>
<img alt='Linux notification' src='https://user-images.githubusercontent.com/36663503/78963087-505b5c00-7b31-11ea-9af5-bece48b912f4.png' width='382'>

## Supported platform

* Vim 8+ or Neovim (0.5+ recommended) 

Supported platforms are:

* macOS
* Windows
* WSL
* Linux (notify-send)

## Usage

Run `:NotifyChanged` in the terminal buffer you want this plugin to notify.
This registers / updates / unregister (`-unwatch`) watch timer by given options

```
:NotifyChanged [-unwatch] [-switch] [-no-switch] [-period {period}]
```

* `-unwatch`: Unregister watch timer
* `-switch`, `-no-switch`: Switch to the terminal window if changed (or not)
* `-period {period}`: specify the period for timer (e.g. `{period}` = `10s`, `1000m`, `10` (same as `10s`))
