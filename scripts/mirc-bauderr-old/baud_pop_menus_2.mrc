on *:signal:baud_unload: {
  !unload -rs $qt($script)
}

alias remote_on {
  !.remote on
}
alias quit {
  quit 18((Bauderr Script(https://Ashbury.pythonanywhere.com) $1- $+ )
}
alias pop_change_nickname_unique {
  return
}
alias pop_nickname {
  if ($istok($+($me,@,$mnick,@,$anick),$1,64)) { return $style(1) }
}
alias pop_connected_style_tempnickname {
  if ($status != connected) { return $style(2) }
  if ($1 != $mnick) && ($1 != $anick) { return $style(1) }
}
alias pop_connected_style_currentnickname {
  if ($status != connected) { return $style(2) }
  if ($1 == $mnick) && ($me == $1) { return $style(1) }
}
alias pop_style_mainnickname {
  if ($1 == $mnick) && ($me == $1) { return $style(1) }
}
alias pop_style_altnickname {
  if ($1 == $anick) && ($me == $1) { return $style(1) }
}
alias pop_change_nickname_unique {
  retrun $read($nickname-hisptory-unique.txt,n,$1)
}

alias pop.flood.chan.checked {
  if ($is_on_off($getvar_setup(noflood,chan).on) == 1) { return $style(1) }
}
alias pop.flood.self.checked {
  if ($is_on_off($getvar_setup(noflood,self).on) == 1) { return $style(1) }
}
alias pop.flood.both.checked {
  if ($is_on_off($getvar_setup(noflood,self).on) == 1) $&
    && ($is_on_off($getvar_setup(noflood,chan).on) == 1) { return $style(3) }
}
alias pop.flood.root.checked {
  if ($is_on_off($getvar_setup(noflood,self).on) == 1) $&
    && ($is_on_off($getvar_setup(noflood,chan).on) == 1) { return $style(1) }
}
alias pop_sounds_list_wave {
  var %i = $1
  if (%i !isnum) { return }
  var %file = $qw($findfile($sound(wave),*.wav,%i))
  if (%file == $null) { return }
  return $nopath(%file) : play_sound $2 %file
}
alias pop_sounds_list_ogg {
  var %i = $1
  if (%i !isnum) { return }
  var %file = $qw($findfile($sound(ogg),*.ogg,%i))
  if (%file == $null) { return }
  return $nopath(%file) : play_sound $2 %file
}
alias pop_sounds_list_midi {
  var %i = $1
  if (%i !isnum) { return }
  var %file = $qw($findfile($sound(midi),*.mid,%i))
  if (%file == $null) { return }
  return $nopath(%file) : play_sound $2 %file

}
alias pop_ascii_art_conn {
  if ($status != connected) || ($menu !isin channel,query,nicklist) || ((!$1) && (!$nick)) { return $style(2) }
}
alias pop_dcc_send_snick {
  if ($snick($chan,0) > 0) {
    return $true
  }
}
alias dcc_chat_selected_nicks {
  var %snick_i = 1
  :loop
  var %snick = $snick($chan,%snick_i)
  if (%snick == $null) { return }
  dcc chat %snick
  inc %snick_i
  goto loop
}

on *:disconnect: {
  unset %bde_cid-005* [ $+ [ $cid ] ]
}
alias dcc_chat_selected_ip {
  var %snick_i = 1
  var %port = $iif(($?="enter an port to dcc chat on, default is 59:" !isnum),59,$!)
  :loop
  var %snick = $snick($chan,%snick_i)
  if (%snick == $null) { return }
  var %snick_ip = $gettoK($address($snick($chan,%snick_i),2),2,64)
  if (%snick_ip == $null) { goto inc }
  dcc chat %snick_ip $+ : $+ %port
  :inc
  inc %snick_i
  goto loop
}
alias pop_dcc_send_query {
  ; if ($nick == $chat($nick)) || ($nick == $fserve($nick)) { return $nick }
  if ($active == $query($active)) { return $active }
  return $false
}
alias pop_sounds_list_mp3 {
  var %i = $1
  if (%i !isnum) { return }
  var %file = $qw($findfile($sound(mp3),*.mp3,%i))
  if (%file == $null) { return }
  return $nopath(%file) : play_sound $2 %file
}
alias play_sound { 
  ; play_sound $snick($chan,0) %file
  var %file = $qw($2-)
  if ($1 isnum) && ($1 > 0) { 
    var %i = 1 
    while ($snick($chan,%i)) { 
      sound $snick($chan,%i) %file
      inc %i 
    } 
  } 
  else { sound $active %file }
}
alias pop_sounds_list_wma {
  var %i = $1
  if (%i !isnum) { return }
  var %file = $qw($findfile($sound(wma),*.wma,%i))
  if (%file == $null) { return }
  return $nopath(%file) : play_sound $2 %file
}
alias pop_ascii_one_list {
  var %i = $1
  if (%i !isnum) { return }
  var %file = $findfile($scriptdir..\ascii\one_line\,*.txt,%i) 
  if (%file == $null) { return }
  return $nopath(%file) : play $qt(%file)
}
alias pop_ascii_small_list {
  var %i = $1
  if (%i !isnum) { return }
  var %file = $findfile($scriptdir..\ascii\small\,*.txt,%i) 
  if (%file == $null) { return }
  return $nopath(%file) : play $qt(%file)
}
alias pop_ascii_medium_list {
  var %i = $1
  if (%i !isnum) { return }
  var %file = $findfile($scriptdir..\ascii\medium\,*.txt,%i)
  if (%file == $null) { return }
  return $nopath(%file) : play $qt(%file)
}
alias pop_ascii_large_list {
  var %i = $1
  if (%i !isnum) { return }
  var %file = $findfile($scriptdir..\ascii\large\,*.txt,%i) 
  if (%file == $null) { return }
  return $nopath(%file) : play $qt(%file)
}
alias pop_is_away_checkmark {
  var %i = 0
  :loop
  inc %i
  if (!$scon(%i)) { return }
  if ($scon(%i).$away) { return $style(1) }
  goto loop
  ; disable if all connections are disconnected or away
  ; check if all cons do not have the same value: value is 'connected'.
  if ($exec_all_id_same($!away,$false) != $true) { return $style(1) }
  if ($exec_all_id_same_not($!status,connected) == $true) { return $style(2) }
}
alias exec_all_id_same_network_not {
  ; $exec_all_id_same(UnderNet,$!status,connected) == $true) { all are disconnected }
  if ($1 == $null) || ($2 == $null) || ($3 == $null) { return }
  var %i = 0
  :loop
  inc %i
  if (!$scon(%i)) { return $true }
  if ($scon(%i).$network != $1) { goto loop }
  if ($scon(%i). [ $+ [ $2 ] ] == $3) { return $false }
  goto loop
}

alias exec_all_id_same {
  ; $exec_all_id_same($!away,$false) == $true) { some are disconnected }
  if ($1 == $null) || ($2 == $null) { return }
  var %i = 0
  :loop
  inc %i
  if (!$scon(%i)) { return $true }
  if ($2 !isin $scon(%i). $+ $1) { return $false }
  goto loop
}
alias exec_all_id_same_not {
  ; $exec_all_id_same_not($!status,connected) == $true) { some are disconnected }
  if ($1 == $null) || ($2 == $null) { return }
  var %i = 0
  :loop
  inc %i
  if (!$scon(%i)) { return $true }
  if ($2 isin $scon(%i). $+ $1) { return $false }
  goto loop
}
alias pop_away_duration_checkmark {
  return $iif(($is_on_off($getvar_global(away-insert-enabler,blank,idle).off) == 1),$style(1))
}
alias pop_away_idle_checkmark {
  return $iif(($is_on_off($getvar_global(away-insert-enabler,blank,idle).off) == 1),$style(1))
}

alias pop_away_afk_checked {
  if (AFK* iswm $strip($awaymsg)) { return $style(1) }

}
alias pop_away_busy_checked {
  if (too busy to chat isin $strip($awaymsg)) { return $style(1) }
}
alias pop_away_msg_checked {
  if (leave a message isin $strip($awaymsg)) { return $style(1) }
}

alias pop_away_afk_checked_dis {
  if ($status != connected) { return $style(2) }
  if (AFK* iswm $strip($awaymsg)) { return $style(1) }

}
alias pop_config_cid_remove_dis {
  return $iif(($getvar_cid(cid-setup-using,blank) == $1),$style(2))

}
alias default return $!default
alias cid_setup_using {
  return $getvar_global(config-list,$getvar_cid(cid-setup-using,blank),blank)
}

alias pop_away_busy_checked_dis {
  if (too busy to chat isin $strip($awaymsg)) { return $style(3) }
}
alias pop_away_msg_checked_dis {
  if (leave a message isin $strip($awaymsg)) { return $style(3) }
}
alias pop_setback_checked {
  var %i = 0
  :loop
  inc %i
  if (!$scon(%i)) { return $style(3) }
  if ($scon(%i).$away == $true) { return }
  goto loop

}
alias pop_idle_away_checked {
  return $iif(($is_on_off($getvar_setup(auto-away-idle,blank).off != off),$style(1))
}
alias pop_away_custom_checked {
  if (!$pop_away_msg_checked) && (!$pop_away_busy_checked) && (!$pop_away_afk_checked) && ($away) { return $style(1) }
}
alias pop_away_custom_checked_dis {
  if (!$pop_away_msg_checked) && (!$pop_away_busy_checked) && (!$pop_away_afk_checked) && ($away) { return $style(3) }
}

alias pop_away_networks_msg {
  if ($1 !isnum) { return }
  if ($1 > 10) { return }
  return $scon($1).$network : /exec_alias_network $scon($1).$network /away i am away, leave a message.
}
alias pop_away_networks_busy {
  if ($1 !isnum) { return }
  if ($1 > 10) { return }
  if (!$scon($1)) { return }
  var %style
  if ($exec_id_network_awaymsg_match($scon($1).$network,too busy to chat) == $true) { %style = $style(3) }
  return %style $scon($1).$network : /exec_alias_network $scon($1).$network /away i am away; too busy to chat.
}
alias exec_id_network_awaymsg_match {
  var %i = 0
  :loop
  inc %i
  if ($scon(%i) == $null) { return $true }
  if ($scon(%i).$network == $1) {
    if ($2 !isin $scon(%i).$awaymsg) { return $false }
  }
  goto loop
}
alias pop_away_networks_custom {
  if ($1 !isnum) { return }
  if ($1 > 10) { return }
  return $scon($1).$network : /exec_alias_network $scon($1).$network /away $$!?="enter an short away message:"
}
alias pop_part_list {
  if ($1 !isnum) { return }
  if ($1 > 20) { return }
  var %c = $chan($1)
  if (!%c) { return }
  return %c : part %c
}
alias pop_setback_all_checked {
  var %i = 0
  :loop
  inc %i
  if (!$scon(%i)) { return $style(1) }
  if ($scon(%i).$away == $true) { return }
  goto loop
}
alias pop_setback_this_checked {
  if ($away) { return }
  elseif ($status != connected) { return $style(2) }
  else { return $style(3) }
}
alias pop_away_setback_list {
  if ($1 !isnum) { return }
  if (!$scon($1)) { return }
  var %i = $1
  var %dup.i = 0
  :loop
  inc %dup.i
  if ($scon(%dup.i) == $null) { goto end }
  if (%dup.i >= %i) { goto end }
  if ($scon(%dup.i).$network == $scon(%i).$network) { return }
  goto loop
  :end
  return $pop_away_networks_setback($1) $scon($1).$network : /exec_alias_network $scon($1).$network /away
}
;list unique networks
;put a check next to networks with afk away

alias pop_away_networks_afk {
  if ($1 !isnum) { return }
  if (!$scon($1)) { return }
  if ($exec_all_id_same_network_not($scon($1).$network,$!status,connected) == $true) { return $style(2) $scon($1).$network : return }
  var %i = $1
  var %dup.i = 0
  :loop
  inc %dup.i
  if ($scon(%dup.i) == $null) { goto end }
  if (%dup.i >= %i) { goto end }
  if ($scon(%dup.i).$network == $scon(%i).$network) { return }
  goto loop
  :end
  return $pop_away_networks_style_afk($1) $scon($1).$network : /exec_alias_network $scon($1).$network /away AFK - (a)way (f)rom (k)eybaord.
}

alias pop_away_networks_style_afk {
  if ($1 !isnum) { return }
  var %i = $1
  var %net.i = 0
  :loop
  inc %net.i
  if (!$scon(%net.i)) { goto end }
  if (%net.i > %i) { goto end }
  if ($scon($1).$network != $scon(%net.i).$network) || ($scon(%net.i).$status != connected) { goto loop }
  if (afk !isin $scon(%net.i).$awaymsg) { return } 
  goto loop
  :end
  return $style(1)

}

alias pop_away_networks_setback {
  if ($1 !isnum) { return }
  var %i = $1
  if (!$scon(%i)) { return }

  if ($pop_id_network_off($scon(%i).$network,$!away) == $true) { return $style(3) }
  else { return }
}

alias pop_id_network_off {
  var %i = 0,%state,%state_ch
  :loop
  inc %i
  if ($scon(%i) == $null) { 
    if (%state == present) { return }
    return $true
  }
  if ($scon(%i).$network == $1) {
    if (!$scon(%i). [ $+ [ $2 ] ]) { %state_ch = null }
    else { %state_ch = present }
  }
  else { goto loop }

  if (%state) {
    if (%state_ch != %state) { return } 
  } 
  else { %state = %state_ch }
  goto loop
}
