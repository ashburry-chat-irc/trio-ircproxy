
on *:load: {
  baud_load_all

}
alias baud_load_all {
  signal -n baud_unload
  load -rs $qt($scriptdirbauderr\baud_common.mrc)
  load -rs $qt($scriptdirbauderr\baud_raw_events.mrc)
}
