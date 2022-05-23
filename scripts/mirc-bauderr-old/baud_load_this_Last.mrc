; Keep this file loaded; it contains the startup signal code.
; This should be the last script file of Bauderr script loaded.
; If you have other script files they can be loaded before or after this one. 
; Remember, no Bauderr script files should be loaded after this one. Just Bauderr script.

on *:signal:baud_just-loaded-now: {
  if ($iif((!$1),*,$ifmatch) !iswm 11.15.19) { return }
  /scid -a /gecho -s 91Bauderr Script $bdr_version $+  is successfully loaded.
}
on *:load: {
  ; this is the last file loaded. bdr_startup timer will unload the setup if it fails to 100% load.
  .timerbdr_startup off
  signal baud_just-loaded-now $bdr_version_numbers
}
on *:signal:baud_unload: {
  if ($iif((!$1),*,$ifmatch) !iswm 11.15.19) { return }
  !.timer -m 1 220 /unload -rs $qt($script)
}
on *:start: {
  !.signal baud_startup $bdr_version_numbers
}
on *:signal:baud_startup: {
  ; check for duplicate script files loaded. same filename. different location, possible?
  if ($1 != 5ioE.3) { unload -rs $qt($script) | return }
  ; execute commands on startup for this file
}
