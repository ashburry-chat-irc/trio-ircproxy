on *:signal:baud_unload: {
  /unload -rs $qt($script)
}

; for irc bot command use literals (not wildcards) . ! * - and ? and wildcard ? 
; ex.  *showcommands help   or   .showcomamnds [cmd]
alias pop_change_nickname_list {
  var %var = %bde_change-nickname!*@ $+ $network
  var %i = $1
  if (%i !isnum) { return }
  if ($var(bde_change-nickname!*@ $+ $network,%i) == $null) { 
    return $null 
  }
  return [ [ $var(bde_change-nickname!*@ $+ $network,%i) ] ] : nick [ [ $var(bde_change-nickname!*@ $+ $network,%i) ] ]
}
alias pop_connected_style {
  if ($status != connected) { return $style(2) }
}
alias if_disallowed_nickname {
  ; This is a list if dangerous nicknames that can kill by just saying them out loud. 
  ; or threatening some of these words results in death. and those who see your corpse also die.

  if (!$isid) { return }
  var %nick = $2
  if (!%nick) { return }
  if ($1 == phish) || ($1 == all) {
    if (%nick isnum) || (%nick == access) || (%nick == administrator) || (%nick == administration) || (%nick == admin) $&
      || (%nick == auth) || (%nick == oper) || (%nick == staff) { return phish }
  }
  elseif ($1 == suicide) || ($1 == all) {
    if (*recover* iswm %nick) || (*gluten* iswm %nick) || (*glu*ten* iswm %nick) || (*glu*10* iswm %nick) $&
      || (*wheat* iswm %nick) || (*wh34t* iswm %nick) || (?thic* iswm %nick) || (*gmo* iswm %nick) || (*gm0* iswm %nick) $&
      || (*?rm?c*u?ic* iswm %nick) || (*god* iswm %nick) || (*om6* iswm %nick) || (*g0d* iswm %nick) $&
      || (*g?o?d* iswm %nick) || (*g?0?d* iswm %nick) || (*60d* iswm %nick) || (*6od* iswm %nick) || (*6?0?d* iswm %nick) $&
      || (*6?o?d* iswm %nick) $&
      || (*omg* iswm %nick) || (*0m6* iswm %nick) || (*0mg* iswm %nick) || (*o?m?g* iswm %nick) $&
      || (*?m46?n* iswm %nick)|| (*?m4g?n* iswm %nick) || (*im461n* iswm %nick) || (*imagin* iswm %nick) { return suicide }
  }
  elseif ($1 == reserved) || ($1 == all) {
    if ($len(%nick) == 1) || (guest* iswm %nick) || (*serv iswm %nick) || (*serve iswm %nick) $&
      || (%nick == services) || (($network == synirc) && ((%nick == angel) || (%nick == synIRC))) { return reserved }
  }
  else { return $false }
}
alias disallow_nicknames {
  ;  $disallow_nicknames(all, nickname) OR $disallow_nicknames(reserved, nickname) OR $disallow_nicknames(suicide, nickname) OR $disallow_nicknames(phish, nickname)

  if (!$isid) { return }
  var %nick, %i = 2, %found = 0
  while (%i <= $0) {
    %nick = $ [ $+ [ %i ] ]
    if (!%nick) { inc %i | continue }
    if ($if_disallowed_nickname($1,%nick)) { inc %found }
    inc %i
  }
  return %found
}
alias make_nickname {
  ; $make_nickname(any|hacker|
  var %random,%type = $1
  if ($prop == unique) { %random = $+(_.$r(a,z), $r(99,9999)) }
}
alias nick {
  if ($isid) { return $nick($1,$2,$3,$4). [ $+ [ $prop ] ] }
  var %nick = $strip_some($1)
  nick_history_network_add %nick
  .timer -m 1 1 /!nick %nick
}
alias mnick {
  if ($isid) { return $mnick($1,$2). [ $+ [ $prop ] ] }
  var %nick = $strip_some($1)
  nick_history_network_add %nick
  .timer -m 1 1 /!mnick %nick
}
alias anick {
  if ($isid) { return $anick($1,$2). [ $+ [ $prop ] ] }
  var %nick = $strip_some($1)
  nick_history_network_add %nick
  .timer -m 1 1 /!anick %nick}
}
alias tnick {
  if ($isid) { return $tnick($1,$2). [ $+ [ $prop ] ] }
  var %nick = $strip_some($1)
  nick_history_network_add %nick
  .timer -m 1 1 /!tnick %nick
}

alias pop_temp_nick_style {
  if ($status != connected) { return $style(2) }
  if ($me == $1) && ($mnick != $1) { return $style(3) }
}
alias pop_main_current_nick_style {
  if ($status != connected) { return $style(2) }
  if ($me == $1) && ($mnick == $1) { return $style(3) }
}
alias pop_main_nick_style {
  if ($mnick == $1) { return $style(3) }
}
alias pop_alt_nick_style {
  if ($anick == $1) { return $style(3) }
}
on *:signal:baud_unload: {
  unload -rs $qt($script)
}
on *:signal:baud_startup: {
  if ($1 != 5ioE.3) { unload -rs $script | return }
  if ($1 == 5ioE.3) { .timer -o 1 2 /nick_history_startup }
}
alias nickname-unique-list return $qt($scriptdirtext_support\nickname_history\unique-list.txt)
alias recent-networks-list return $qt($scriptdirtext_support\nickname_history\recent-networks.txt)

alias nick_history_startup {  
  mkdir $nofile($nickname-unique-list)
  if ($1 != --startup) { scon -a /nick_history_startup --startup | return }
  write -m1s $+ $me $nickname-unique-list $me
  write -m1s $+ $anick $nickname-unique-list $anick
  write -m1s $+ $mnick $nickname-unique-list $mnick
}
alias nick_history_unique_add {
  write -m1s $+ $1 $nickname-unique-list $1
  while ($lines($nickname-unique-list) > 20) {
    write -dl21 $nickname-unique-list
  }

}
alias nick_history_unique_remove {
  if ($1 == $null) { return }
  write -ds $+ $1 $nickname-unique-list
}
alias nick_history_network_file {
  return $qt($+($scriptdirtext_support\nickname_history\,$iif((!$1),$$network,$1),.txt))
}
alias nick_history_network_add {
  ; /nick_history_network_add <nickname> [network]
  ;
  write -m1s $+ $$1 $nick_history_network_file($2) $1
  while ($lines($nick_history_network_file($2)) > 10) { 
    write -dl11 $nick_history_network_file($2) | flushini $nick_history_network_file($2) 
  }
  nick_history_unique_add $1
}
alias write2 {
  if ($0 == 0) { !echo $colour(info) -eas * /write: insufficient parameters | return }
  write $1-
  return
  :error
  !tokenize 32 $error
  var %fn = $deltok($error,-3-,32)
  if (/write: == $2) {
    if $3 == invalid { !echo $colour(info) -eas %fn | !reseterror | return }
    if ($3 == unable) {
      var %fn = $gettok(%fn,7-,32)
      gecho -as ERROR : please allow write permission for %fn (make sure folders exist)
      !reseterror
    }
  }
}
alias nick_history_network_remove {
  ; /nick_history_network_remove <nickname> [network]
  ;
  write -ds $+ $$1 $nick_history_network_file($2)
}
alias pop_recent_network_nick_history return $read($recent-networks-list,$1)

alias pop_nick_history_network {
  var -n %file = $read($recent-networks-list,$1) $+ .txt
  var %file = $findfile($scriptdirtext_support\nickname_history\,%file,1)
  return $read(%file,$2)
}
on *:connect: {
  nick_history_network_add $me
  nick_history_network_add $mnick
  nick_history_network_add $anick
  write -ds $+ $network $recent-networks-list
  write -il1 $recent-networks-list $network
}

menu status,channel,query,nicklist {
  $pop.flood.root.checked &flood protection
  .$pop.flood.chan.checked [for channels] : varset_setup noflood chan $iif(($is_on_off($getvar_setup(noflood,chan).on) == 1),off,on)
  .$pop.flood.self.checked [for yourself] : varset_setup noflood self $iif(($is_on_off($getvar_setup(noflood,self).on) == 1),off,on)
  .-
  .$pop.flood.both.checked - q u i c k  $chr(32) o n  - : varset_setup noflood self $iif(($is_on_off($getvar_setup(noflood,self).on) == 1),off,on) | varset_setup noflood chan $iif(($is_on_off($getvar_setup(noflood,chan).on) == 1),off,on)

  &client commands
  .$iif(($donotdisturb == $true),$style(1)) Do Not Disturb : /donotdisturb $iif(($donotdisturb == $true),off,on) | if ($donotdisturb == $true) { gecho -as Do Not Distrub will prevent your irc client app from getting your attention }
  .-
  .&stop playing sound : splay stop
  .$iif(($menu == nicklist),pl&ay sound to $snick($chan,0) users)
  ..$submenu($pop_sounds_list_wave($1,$snick($chan,0)))
  ..$submenu($pop_sounds_list_ogg($1,$snick($chan,0)))
  ..$submenu($pop_sounds_list_wma($1,$snick($chan,0)))
  ..$submenu($pop_sounds_list_midi($1,$snick($chan,0)))
  ..$submenu($pop_sounds_list_mp3($1,$snick($chan,0)))
  .$iif(($menu isin query,channel),pl&ay sound to $menu)
  ..$submenu($pop_sounds_list_wave($1,$active))
  ..$submenu($pop_sounds_list_ogg($1,$active))
  ..$submenu($pop_sounds_list_wma($1,$active))
  ..$submenu($pop_sounds_list_midi($1,$active))
  ..$submenu($pop_sounds_list_mp3($1,$active))
  .$iif(($menu !isin query,channel,nicklist), $style(2) pl&ay sound)
  .-
  .play &central : playctrl
  .&stop playing ascii : play stop
  .$pop_ascii_art_conn play &ascii art $iif(($menu isin status,query,channel),to $menu)
  ..on&e line
  ...$submenu($pop_ascii_one_list($1))
  ..&small
  ...$submenu($pop_ascii_small_list($1))
  ..*medium
  ...$submenu($pop_ascii_medium_list($1))
  ..la&rge
  ...$submenu($pop_ascii_large_list($1))
  .-
  .$pop_connected_style &dcc send/chat/fserve
  ..$iif(($snick($chan,0) == 0), $style(2)) dcc send $snick($chan,0) selected nicknames... : dcc_send_sel_nicks
  ..$iif(($snick($chan,0) == 0), $style(2)) dcc chat $snick($chan,0) selected nicknames... : dcc_chat_sel_nicks
  ..$iif(($snick($chan,0) == 0), $style(2)) dcc fserve $snick($chan,0) selected nicknames... : dcc_fserve_sel_nicks
  .&dccserver +sfc on 59 : dccserver +sfc on $iif(($?="enter an port number for dcc server: $+ $crlf $+ [default is 59]:" !isnum),$dccport,$ifmatch)
}
alias fserve_homedir {
  !.mkdir $qw($scriptdir..\file-server\)
  if ($prop == welcome) { !return $qw($scriptdir..\file-server\welcome.txt) }
  else { !return $qw($scriptdir..\file-server\) }
}
alias bauderr_fserve {
  if (. isin $1) { !var %port = $iif(remove($?="Enter an dcc server port number: [default: 59]:",+,-,.) isnum,$ifmatch,$dccport) }
  %dcc fserve $1 $+ : $+ $iif((%port isnum) && (%port >= 1) && (%port <= 65535),%port,59) $fserve-max-sends $fserve_homedir $fserve_homedir().welcome
}
alias fserve-max-gets return $fserve-max-sends
alias fserve-max-sends {
  var %n = $getvar_global(fserve-max-sends,blank,blank)
  if (%n isnum) {
    if (%n > 19) { return 5 }
    else { return %n }
  }
  else { return 5 }
}
alias -l dcc_chat_sel_nicks {
  if ($snick($chan,0) == 0) { return }
  var %i = $snick($chan,0)
  :loop
  if (%i <= 0) { return }
  dcc chat $snick($chan,%i)
  dec %i
  goto loop
}
alias -l dcc_chat_sel_ips {
  if ($snick($chan,0) == 0) { return }
  var %port = $iif(remove($?="Enter an dcc server port number: [default: 59]:",+,-,.) isnum,$ifmatch,59)
  var %i = $snick($chan,0)
  :loop
  if (%i <= 0) { return }
  var -n %ial = $gettok($ial($snick($chan,%i),1),2,64)
  if (!%ial) { goto next }
  dcc chat %ial $+ : $+ %port
  :next
  dec %i
  goto loop
}
alias -l dcc_fserve_sel_nicks {
  if ($snick($chan,0) == 0) { return }
  var %i = $snick($chan,0)
  :loop
  if (%i <= 0) { return }
  bauderr_fserve $snick($chan,%i) $fserve-max-gets
  dec %i
  goto loop
}
alias -l dcc_fserve_sel_ips {
  if ($snick($chan,0) == 0) { return }
  var %port = $iif($remove($?="Enter an dcc server port number: [default: 59]:",+,-,.) isnum,$ifmatch,59)
  var %i = $snick($chan,0)
  :loop
  if (%i <= 0) { return }
  var -n %ial = $gettok($ial($snick($chan,%i),1),2,64)
  if (!%ial) { goto next }
  bauderr_fserve %ial $+ : $+ %port
  :next
  dec %i
  goto loop
}
alias -l dcc_send_sel_nicks {
  if (!$snick($chan,0)) { return }
  var -n %file_to_send = $qw($sfile($sysdir(downloads),$UPPER(select a file to dcc send),DCC SEND FILE))
  if (%file_to_send == "") { return }
  var %i = $snick($chan,0)
  :loop
  if (%i <= 0) { return }
  dcc send $snick($chan,%i) %file_to_send
  dec %i
  goto loop
}
alias -l dcc_send_sel_ips {
  if (!$snick($chan,0)) { return }
  var -n %file_to_send = $qw($sfile($sysdir(downloads),$UPPER(select a file to dcc send),DCC SEND FILE))
  if (%file_to_send == "") { return }
  var %i = $snick($chan,0)
  :loop
  if (%i <= 0) { return }
  var -n %ial = $gettok($ial($snick($chan,%i),1),2,64)
  dcc send %ial $+ :59 %file_to_send
  dec %i
  goto loop
}
alias pop_author_brace {
  return $+($chr(40),$gettok($getvar_global(author_word,blank,blank),1,32),$chr(41))
}
alias pop_author_nobrace {
  return $getvar_global(author_word,blank,blank)
}
alias pop_idle_away_checked {
  return $iif(($is_on_off($getvar_setup(auto-away-idle,blank).off) != off),$style(1))
}

menu status,channel {
  &bauderr script
  .describe script : ame $bdr_describe
}
menu query,nicklist {
  &bauderr script
  .describe script : describe $1 $bdr_describe
  -
  &client commands

}
menu menubar {
  &bauderr script
  .describe script : /scid -a /ame $bdr_describe

  &system
  .&auto change to nickname preset : config_auto_nick
  .&auto change to network preset : config_auto_net
  .-
  .&save as
  ..$network @ network
  ...&save to : config_saveas_net $network
  ...&save as default : config_default_net $network
  ..$me ! nickname
  ...&save to : config_saveas_nick $me
  ...&set as default : config_default_nick $me
  ..-
  ..&save to new name : config_saveas $$?="enter an word to save your settings as:"
  .-
  .$pop_config_Preset_list(1)
  ..lo&ad : config_load 1
  ..&save to : config_saveas 1
  ..&set as default : config_set_default 1
  .$pop_config_Preset_list(2)
  ..lo&ad : config_load 2
  ..&save to : config_saveas 2
  ..&set as default : config_set_default 2
  .$pop_config_Preset_list(3)
  ..lo&ad : config_load 3
  ..&save to : config_saveas 3
  ..&set as default : config_set_default 3
  -

  &system
  -
  $iif(($os isin 7,10),&set client faster) : gecho -as changed priority of all running $nopath($mircexe) apps to 'High' | run -hn wmic process where name=" $+ $nopath($mircexe) $+ " CALL setpriority 128
  -
  &quit irc:/quit
}
menu menubar,status,channel,query,nicklist {
  $remote_on
  &bauderr script
  .contact Ashburry : echo -a 53 contact Ashburry at mailto:bauderr@outlook.com or chat with me on #ouikend on Undernet
  .join #ouikend on Undernet : run irc://irc.undernet.org:7000/ouikend
  .open website : url -n https://ashburry.pythonanywhere.com/
  .-
  .reload script v11.15.19 : baud_reload v11.15.19
  -
}


menu status,channel,query,nicklist {

  $pop_connected_style ir&c commands
  .&away system
  ..$pop_setback_checked set &back 
  ...$pop_setback_all_checked [&all connections] : /scon -at1 /away
  ...$pop_setback_this_checked thi&s connection : /away
  ...$pop_setback_proxy_checked all of proxy server: /proxy.away
  ...net&works
  ....$submenu($pop_away_setback_list($1))
  ..$pop_is_away_checkmark set &away
  ...$pop_away_afk_checked [(&a)way (f)rom (k)eybaord]
  ....[&all connections] : /scid -at1 away AFK - (a)way (f)rom (k)eybaord.
  ....$pop_away_afk_checked_dis thi&s connection : away AFK - (a)way (f)rom (k)eybaord.
  ....$pop_away_proxy_afk_checked all of proxy server : /proxy.away.afk
  ....net&works
  .....$submenu($pop_away_networks_afk($1))
  ...$pop_away_busy_checked i am &busy
  ....[&all connections] : /scid -at1 /away i am away; too busy to chat.
  ....$pop_away_busy_checked_dis thi&s connection : /away i am away; too busy to chat.
  ....$pop_away_proxy_busy_checked all of proxy server : /proxy.away.busy
  ....net&works
  .....$submenu($pop_away_networks_busy($1))
  ...$pop_away_msg_checked lea&ve an message 
  ....[&all connections] : /scid -at1 /away i am away, leave a message.
  ....$pop_away_msg_checked_dis thi&s connection : /away i am away, leave a message.
  ....$pop_away_proxy_msg_checked all of proxy server : /proxy.away.msg
  ....net&works
  .....$submenu($pop_away_networks_msg($1))
  ...$pop_away_custom_checked custom ?...
  ....[&all connections] : /scid -at1 /away $$?="enter an short away message:"
  ....$pop_away_custom_checked_dis thi&s connection : /away $$?="enter an short away message:"
  ....$pop_away_proxy_custom_checked all of proxy server : /proxy.away $$?="enter an short away message:"

  ....net&works
  .....$submenu($pop_away_networks_custom($1))
  ..-
  ..$pop_away_duration_checkmark [insert away &duration] : varset_global away-insert-enabler blank away $iif(($is_on_off($getvar.cid(away-insert-enabler,blank,away).off) == 1),off,on)
  ..$pop_away_idle_checkmark [insert idle &duration] : varset_global away-insert-enabler blank idle $iif(($is_on_off($getvar.cid(away-insert-enabler,blank,idle).off) == 1),off,on)
  ..-
  ..$pop_idle_away_checked switch on 'i&dle auto-away'
  ...$pop_idle_away_25 after &25 minutes : varset_setup auto-away-idle blank 25
  ...$pop_idle_away_35 after &35 minutes : varset_setup auto-away-idle blank 35
  ...$pop_idle_away_50 after &50 minutes : varset_setup auto-away-idle blank 50 
  ...-
  ...$pop_idle_away_off [&switch o&ff] : varset_setup auto-away-idle blank off
  .-
  .nickn&ame history
  ..custom nick ?...
  ...$pop_connected_style &temp nick : tnick $$?="enter an new temp nickname:"
  ...$pop_connected_style m&ain && current nick : nick $$?="enter an new current nickname:"
  ...-
  ...m&ain nick : mnick $$?="enter an new main nickname:"
  ...&alternate nick : anick $$?="enter an new alternate nickname:"
  ..-
  ..&clear history : gecho -as Erase all the network.txt files
  ..-
  ..unique nicknames
  ...$pop_nickname($pop_change_nickname_unique(1)) $pop_change_nickname_unique(1)
  ....$pop_connected_style_tempnickname($pop_change_nickname_unique(1)) &temp nick : tnick $pop_change_nickname_list_unique(1)
  ....$pop_connected_style_currentnickname($pop_change_nickname_unique(1)) $pop_connected_style m&ain && current : nick $pop_change_nickname_list_unique(1)
  ....-
  ....$pop_style_mainnickname($pop_change_nickname_unique(1)) m&ain nickname : mnick $pop_change_nickname_list_unique(1)
  ....$pop_style_altnickname($pop_change_nickname_unique(1)) &alternate nickname : anick $pop_change_nickname_list_unique(1)

  ..-

  .nickn&ame generator

  .&whois ?... : whois $$?="enter an nickname:"
  .-
  .$pop_silence_style &silence
  ..&silence list : silence
  ..-
  ..&silence nickmask...? : silence $$?="enter +nickmask to silence and -nickmask to remove:"
  ..$pop_unsilence_style un&silence
  ...$submenu($pop_silence_list($1))
  ...-
  ...$iif((!$getvar_cid(silence-copy,blank)),$style(2)) &clear list : silence -*
  .-
  .&server info
  ..&lusers : /lusers
  ..mot&d : /motd
  ..tim&e : /time
  ..-
  ..&server links : /links
  .-
  .list &channels : /list
  .-
  .join &channel
  ..#ir&chelp : join #irchelp
  ..#ouiken&d on UnderNet : /exec_alias_network UnderNet /join #ouikend
  ..&channel ?...: join #$$?="enter a channel name:"
  .part &channel
  ..$submenu($pop_part_list($1))
  .n&ames ?... : names #$$?="enter an channel name:"
  .-
  .server &help : /raw help
}
alias pop_silence_list {
  if ($1 !isnum) { return }
  return $gettok($getvar_cid(silence-copy,blank),$1,32) : silence - $+ $gettok($getvar_cid(silence-copy,blank),$1,32)
}
alias pop_unsilence_style {
  return $iif((!$getvar_cid(silence-copy,blank)),$style(3))
}
alias pop_silence_style {
  if ($getvar_cid(005,silence) == $null) || ($status != connected) { return $style(2) }
}

on me:*:NICK: {
  nick_history_network_add $newnick
}
menu channel,status {
  ir&c commands
  .nickn&ame history
  ..unique nicknames
  ..$pop_recent_network_nick_history(1)
  ...$pop_nick_history_network(1,1)
  ....$iif(($pop_nick_history_network(1,1) != $mnick) && ($pop_nick_history_network(1,1) != $anick),$style(1)) &temp nickname : tnick $pop_nick_history_network(1,1)
  ....$iif(($pop_nick_history_network(1,1) == $mnick) && ($pop_nick_history_network(1,1) == $me),$style(1)) current && m&ain : nick $pop_nick_history_network(1,1)
  ....-
  ....$iif(($pop_nick_history_network(1,1) == $mnick),$style(1)) m&ain nickname : mnick $pop_nick_history_network(1,1)
  ....$iif(($pop_nick_history_network(1,1) == $anick),$style(1)) &alternate nick : anick $pop_nick_history_network(1,1)
  ...$pop_nick_history_network(1,2)
  ....$iif(($pop_nick_history_network(1,2) != $mnick) && ($pop_nick_history_network(1,2) != $anick),$style(1)) &temp nickname : tnick $pop_nick_history_network(1,2)
  ....$iif(($pop_nick_history_network(1,2) == $mnick) && ($pop_nick_history_network(1,2) == $me),$style(1)) current && m&ain : nick $pop_nick_history_network(1,2)
  ....-
  ....$iif(($pop_nick_history_network(1,2) == $mnick),$style(1)) m&ain nickname : mnick $pop_nick_history_network(1,2)
  ....$iif(($pop_nick_history_network(1,2) == $anick),$style(1)) &alternate nick : anick $pop_nick_history_network(1,2)
  ...$pop_nick_history_network(1,3)
  ....$iif(($pop_nick_history_network(1,3) != $mnick) && ($pop_nick_history_network(1,3) != $anick),$style(1)) &temp nickname : tnick $pop_nick_history_network(1,3)
  ....$iif(($pop_nick_history_network(1,3) == $mnick) && ($pop_nick_history_network(1,3) == $me),$style(1)) current && m&ain : nick $pop_nick_history_network(1,3)
  ....-
  ....$iif(($pop_nick_history_network(1,3) == $mnick),$style(1)) m&ain nickname : mnick $pop_nick_history_network(1,3)
  ....$iif(($pop_nick_history_network(1,3) == $anick),$style(1)) &alternate nick : anick $pop_nick_history_network(1,3)
  ...$pop_nick_history_network(1,4)
  ....$iif(($pop_nick_history_network(1,4) != $mnick) && ($pop_nick_history_network(1,4) != $anick),$style(1)) &temp nickname : tnick $pop_nick_history_network(1,4)
  ....$iif(($pop_nick_history_network(1,4) == $mnick) && ($pop_nick_history_network(1,4) == $me),$style(1)) current && m&ain : nick $pop_nick_history_network(1,4)
  ....-
  ....$iif(($pop_nick_history_network(1,4) == $mnick),$style(1)) m&ain nickname : mnick $pop_nick_history_network(1,4)
  ....$iif(($pop_nick_history_network(1,4) == $anick),$style(1)) &alternate nick : anick $pop_nick_history_network(1,4)
  ...$pop_nick_history_network(1,5)
  ....$iif(($pop_nick_history_network(1,5) != $mnick) && ($pop_nick_history_network(1,5) != $anick),$style(1)) &temp nickname : tnick $pop_nick_history_network(1,5)
  ....$iif(($pop_nick_history_network(1,5) == $mnick) && ($pop_nick_history_network(1,5) == $me),$style(1)) current && m&ain : nick $pop_nick_history_network(1,5)
  ....-
  ....$iif(($pop_nick_history_network(1,5) == $mnick),$style(1)) m&ain nickname : mnick $pop_nick_history_network(1,5)
  ....$iif(($pop_nick_history_network(1,5) == $anick),$style(1)) &alternate nick : anick $pop_nick_history_network(1,5)
  ...$pop_nick_history_network(1,6)
  ....$iif(($pop_nick_history_network(1,6) != $mnick) && ($pop_nick_history_network(1,6) != $anick),$style(1)) &temp nickname : tnick $pop_nick_history_network(1,6)
  ....$iif(($pop_nick_history_network(1,6) == $mnick) && ($pop_nick_history_network(1,6) == $me),$style(1)) current && m&ain : nick $pop_nick_history_network(1,6)
  ....-
  ....$iif(($pop_nick_history_network(1,6) == $mnick),$style(1)) m&ain nickname : mnick $pop_nick_history_network(1,6)
  ....$iif(($pop_nick_history_network(1,6) == $anick),$style(1)) &alternate nick : anick $pop_nick_history_network(1,6)
  ...$pop_nick_history_network(1,7)
  ....$iif(($pop_nick_history_network(1,7) != $mnick) && ($pop_nick_history_network(1,7) != $anick),$style(1)) &temp nickname : tnick $pop_nick_history_network(1,7)
  ....$iif(($pop_nick_history_network(1,7) == $mnick) && ($pop_nick_history_network(1,7) == $me),$style(1)) current && m&ain : nick $pop_nick_history_network(1,7)
  ....-
  ....$iif(($pop_nick_history_network(1,7) == $mnick),$style(1)) m&ain nickname : mnick $pop_nick_history_network(1,7)
  ....$iif(($pop_nick_history_network(1,7) == $anick),$style(1)) &alternate nick : anick $pop_nick_history_network(1,7)
  ...$pop_nick_history_network(1,8)
  ....$iif(($pop_nick_history_network(1,8) != $mnick) && ($pop_nick_history_network(1,8) != $anick),$style(1)) &temp nickname : tnick $pop_nick_history_network(1,8)
  ....$iif(($pop_nick_history_network(1,8) == $mnick) && ($pop_nick_history_network(1,8) == $me),$style(1)) current && m&ain : nick $pop_nick_history_network(1,8)
  ....-
  ....$iif(($pop_nick_history_network(1,8) == $mnick),$style(1)) m&ain nickname : mnick $pop_nick_history_network(1,8)
  ....$iif(($pop_nick_history_network(1,8) == $anick),$style(1)) &alternate nick : anick $pop_nick_history_network(1,8)  

  ..$pop_recent_network_nick_history(2)
  ...$pop_nick_history_network(2,1)
  ....$iif(($pop_nick_history_network(2,1) != $mnick) && ($pop_nick_history_network(2,1) != $anick),$style(1)) &temp nickname : tnick $pop_nick_history_network(2,1)
  ....$iif(($pop_nick_history_network(2,1) == $mnick) && ($pop_nick_history_network(2,1) == $me),$style(1)) current && m&ain : nick $pop_nick_history_network(2,1)
  ....-
  ....$iif(($pop_nick_history_network(2,1) == $mnick),$style(1)) m&ain nickname : mnick $pop_nick_history_network(2,1)
  ....$iif(($pop_nick_history_network(2,1) == $anick),$style(1)) &alternate nick : anick $pop_nick_history_network(2,1)
  ...$pop_nick_history_network(2,2)
  ....$iif(($pop_nick_history_network(2,2) != $mnick) && ($pop_nick_history_network(2,2) != $anick),$style(1)) &temp nickname : tnick $pop_nick_history_network(2,2)
  ....$iif(($pop_nick_history_network(2,2) == $mnick) && ($pop_nick_history_network(2,2) == $me),$style(1)) current && m&ain : nick $pop_nick_history_network(2,2)
  ....-
  ....$iif(($pop_nick_history_network(2,2) == $mnick),$style(1)) m&ain nickname : mnick $pop_nick_history_network(2,2)
  ....$iif(($pop_nick_history_network(2,2) == $anick),$style(1)) &alternate nick : anick $pop_nick_history_network(2,2)
  ...$pop_nick_history_network(2,3)
  ....$iif(($pop_nick_history_network(2,3) != $mnick) && ($pop_nick_history_network(2,3) != $anick),$style(1)) &temp nickname : tnick $pop_nick_history_network(2,3)
  ....$iif(($pop_nick_history_network(2,3) == $mnick) && ($pop_nick_history_network(2,3) == $me),$style(1)) current && m&ain : nick $pop_nick_history_network(2,3)
  ....-
  ....$iif(($pop_nick_history_network(2,3) == $mnick),$style(1)) m&ain nickname : mnick $pop_nick_history_network(2,3)
  ....$iif(($pop_nick_history_network(2,3) == $anick),$style(1)) &alternate nick : anick $pop_nick_history_network(2,3)
  ...$pop_nick_history_network(2,4)
  ....$iif(($pop_nick_history_network(2,4) != $mnick) && ($pop_nick_history_network(2,4) != $anick),$style(1)) &temp nickname : tnick $pop_nick_history_network(2,4)
  ....$iif(($pop_nick_history_network(2,4) == $mnick) && ($pop_nick_history_network(2,4) == $me),$style(1)) current && m&ain : nick $pop_nick_history_network(2,4)
  ....-
  ....$iif(($pop_nick_history_network(2,4) == $mnick),$style(1)) m&ain nickname : mnick $pop_nick_history_network(2,4)
  ....$iif(($pop_nick_history_network(2,4) == $anick),$style(1)) &alternate nick : anick $pop_nick_history_network(2,4)
  ...$pop_nick_history_network(2,5)
  ....$iif(($pop_nick_history_network(2,5) != $mnick) && ($pop_nick_history_network(2,5) != $anick),$style(1)) &temp nickname : tnick $pop_nick_history_network(2,5)
  ....$iif(($pop_nick_history_network(2,5) == $mnick) && ($pop_nick_history_network(2,5) == $me),$style(1)) current && m&ain : nick $pop_nick_history_network(2,5)
  ....-
  ....$iif(($pop_nick_history_network(2,5) == $mnick),$style(1)) m&ain nickname : mnick $pop_nick_history_network(2,5)
  ....$iif(($pop_nick_history_network(2,5) == $anick),$style(1)) &alternate nick : anick $pop_nick_history_network(2,5)
  ...$pop_nick_history_network(2,6)
  ....$iif(($pop_nick_history_network(2,6) != $mnick) && ($pop_nick_history_network(2,6) != $anick),$style(1)) &temp nickname : tnick $pop_nick_history_network(2,6)
  ....$iif(($pop_nick_history_network(2,6) == $mnick) && ($pop_nick_history_network(2,6) == $me),$style(1)) current && m&ain : nick $pop_nick_history_network(2,6)
  ....-
  ....$iif(($pop_nick_history_network(2,6) == $mnick),$style(1)) m&ain nickname : mnick $pop_nick_history_network(2,6)
  ....$iif(($pop_nick_history_network(2,6) == $anick),$style(1)) &alternate nick : anick $pop_nick_history_network(2,6)
  ...$pop_nick_history_network(2,7)
  ....$iif(($pop_nick_history_network(2,7) != $mnick) && ($pop_nick_history_network(2,7) != $anick),$style(1)) &temp nickname : tnick $pop_nick_history_network(2,7)
  ....$iif(($pop_nick_history_network(2,7) == $mnick) && ($pop_nick_history_network(2,7) == $me),$style(1)) current && m&ain : nick $pop_nick_history_network(2,7)
  ....-
  ....$iif(($pop_nick_history_network(2,7) == $mnick),$style(1)) m&ain nickname : mnick $pop_nick_history_network(2,7)
  ....$iif(($pop_nick_history_network(2,7) == $anick),$style(1)) &alternate nick : anick $pop_nick_history_network(2,7)
  ...$pop_nick_history_network(2,8)
  ....$iif(($pop_nick_history_network(2,8) != $mnick) && ($pop_nick_history_network(2,8) != $anick),$style(1)) &temp nickname : tnick $pop_nick_history_network(2,8)
  ....$iif(($pop_nick_history_network(2,8) == $mnick) && ($pop_nick_history_network(2,8) == $me),$style(1)) current && m&ain : nick $pop_nick_history_network(2,8)
  ....-
  ....$iif(($pop_nick_history_network(2,8) == $mnick),$style(1)) m&ain nickname : mnick $pop_nick_history_network(2,8)
  ....$iif(($pop_nick_history_network(2,8) == $anick),$style(1)) &alternate nick : anick $pop_nick_history_network(2,8)  

  ..$pop_recent_network_nick_history(3)
  ...$pop_nick_history_network(3,1)
  ....$iif(($pop_nick_history_network(3,1) != $mnick) && ($pop_nick_history_network(3,1) != $anick),$style(1)) &temp nickname : tnick $pop_nick_history_network(3,1)
  ....$iif(($pop_nick_history_network(3,1) == $mnick) && ($pop_nick_history_network(3,1) == $me),$style(1)) current && m&ain : nick $pop_nick_history_network(3,1)
  ....-
  ....$iif(($pop_nick_history_network(3,1) == $mnick),$style(1)) m&ain nickname : mnick $pop_nick_history_network(3,1)
  ....$iif(($pop_nick_history_network(3,1) == $anick),$style(1)) &alternate nick : anick $pop_nick_history_network(3,1)
  ...$pop_nick_history_network(3,2)
  ....$iif(($pop_nick_history_network(3,2) != $mnick) && ($pop_nick_history_network(3,2) != $anick),$style(1)) &temp nickname : tnick $pop_nick_history_network(3,2)
  ....$iif(($pop_nick_history_network(3,2) == $mnick) && ($pop_nick_history_network(3,2) == $me),$style(1)) current && m&ain : nick $pop_nick_history_network(3,2)
  ....-
  ....$iif(($pop_nick_history_network(3,2) == $mnick),$style(1)) m&ain nickname : mnick $pop_nick_history_network(3,2)
  ....$iif(($pop_nick_history_network(3,2) == $anick),$style(1)) &alternate nick : anick $pop_nick_history_network(3,2)
  ...$pop_nick_history_network(3,3)
  ....$iif(($pop_nick_history_network(3,3) != $mnick) && ($pop_nick_history_network(3,3) != $anick),$style(1)) &temp nickname : tnick $pop_nick_history_network(3,3)
  ....$iif(($pop_nick_history_network(3,3) == $mnick) && ($pop_nick_history_network(3,3) == $me),$style(1)) current && m&ain : nick $pop_nick_history_network(3,3)
  ....-
  ....$iif(($pop_nick_history_network(3,3) == $mnick),$style(1)) m&ain nickname : mnick $pop_nick_history_network(3,3)
  ....$iif(($pop_nick_history_network(3,3) == $anick),$style(1)) &alternate nick : anick $pop_nick_history_network(3,3)
  ...$pop_nick_history_network(3,4)
  ....$iif(($pop_nick_history_network(3,4) != $mnick) && ($pop_nick_history_network(3,4) != $anick),$style(1)) &temp nickname : tnick $pop_nick_history_network(3,4)
  ....$iif(($pop_nick_history_network(3,4) == $mnick) && ($pop_nick_history_network(3,4) == $me),$style(1)) current && m&ain : nick $pop_nick_history_network(3,4)
  ....-
  ....$iif(($pop_nick_history_network(3,4) == $mnick),$style(1)) m&ain nickname : mnick $pop_nick_history_network(3,4)
  ....$iif(($pop_nick_history_network(3,4) == $anick),$style(1)) &alternate nick : anick $pop_nick_history_network(3,4)
  ...$pop_nick_history_network(3,5)
  ....$iif(($pop_nick_history_network(3,5) != $mnick) && ($pop_nick_history_network(3,5) != $anick),$style(1)) &temp nickname : tnick $pop_nick_history_network(3,5)
  ....$iif(($pop_nick_history_network(3,5) == $mnick) && ($pop_nick_history_network(3,5) == $me),$style(1)) current && m&ain : nick $pop_nick_history_network(3,5)
  ....-
  ....$iif(($pop_nick_history_network(3,5) == $mnick),$style(1)) m&ain nickname : mnick $pop_nick_history_network(3,5)
  ....$iif(($pop_nick_history_network(3,5) == $anick),$style(1)) &alternate nick : anick $pop_nick_history_network(3,5)
  ...$pop_nick_history_network(3,6)
  ....$iif(($pop_nick_history_network(3,6) != $mnick) && ($pop_nick_history_network(3,6) != $anick),$style(1)) &temp nickname : tnick $pop_nick_history_network(3,6)
  ....$iif(($pop_nick_history_network(3,6) == $mnick) && ($pop_nick_history_network(3,6) == $me),$style(1)) current && m&ain : nick $pop_nick_history_network(3,6)
  ....-
  ....$iif(($pop_nick_history_network(3,6) == $mnick),$style(1)) m&ain nickname : mnick $pop_nick_history_network(3,6)
  ....$iif(($pop_nick_history_network(3,6) == $anick),$style(1)) &alternate nick : anick $pop_nick_history_network(3,6)
  ...$pop_nick_history_network(3,7)
  ....$iif(($pop_nick_history_network(3,7) != $mnick) && ($pop_nick_history_network(3,7) != $anick),$style(1)) &temp nickname : tnick $pop_nick_history_network(3,7)
  ....$iif(($pop_nick_history_network(3,7) == $mnick) && ($pop_nick_history_network(3,7) == $me),$style(1)) current && m&ain : nick $pop_nick_history_network(3,7)
  ....-
  ....$iif(($pop_nick_history_network(3,7) == $mnick),$style(1)) m&ain nickname : mnick $pop_nick_history_network(3,7)
  ....$iif(($pop_nick_history_network(3,7) == $anick),$style(1)) &alternate nick : anick $pop_nick_history_network(3,7)
  ...$pop_nick_history_network(3,8)
  ....$iif(($pop_nick_history_network(3,8) != $mnick) && ($pop_nick_history_network(3,8) != $anick),$style(1)) &temp nickname : tnick $pop_nick_history_network(3,8)
  ....$iif(($pop_nick_history_network(3,8) == $mnick) && ($pop_nick_history_network(3,8) == $me),$style(1)) current && m&ain : nick $pop_nick_history_network(3,8)
  ....-
  ....$iif(($pop_nick_history_network(3,8) == $mnick),$style(1)) m&ain nickname : mnick $pop_nick_history_network(3,8)
  ....$iif(($pop_nick_history_network(3,8) == $anick),$style(1)) &alternate nick : anick $pop_nick_history_network(3,8)  

  ..$pop_recent_network_nick_history(4)
  ...$pop_nick_history_network(4,1)
  ....$iif(($pop_nick_history_network(4,1) != $mnick) && ($pop_nick_history_network(4,1) != $anick),$style(1)) &temp nickname : tnick $pop_nick_history_network(4,1)
  ....$iif(($pop_nick_history_network(4,1) == $mnick) && ($pop_nick_history_network(4,1) == $me),$style(1)) current && m&ain : nick $pop_nick_history_network(4,1)
  ....-
  ....$iif(($pop_nick_history_network(4,1) == $mnick),$style(1)) m&ain nickname : mnick $pop_nick_history_network(4,1)
  ....$iif(($pop_nick_history_network(4,1) == $anick),$style(1)) &alternate nick : anick $pop_nick_history_network(4,1)
  ...$pop_nick_history_network(4,2)
  ....$iif(($pop_nick_history_network(4,2) != $mnick) && ($pop_nick_history_network(4,2) != $anick),$style(1)) &temp nickname : tnick $pop_nick_history_network(4,2)
  ....$iif(($pop_nick_history_network(4,2) == $mnick) && ($pop_nick_history_network(4,2) == $me),$style(1)) current && m&ain : nick $pop_nick_history_network(4,2)
  ....-
  ....$iif(($pop_nick_history_network(4,2) == $mnick),$style(1)) m&ain nickname : mnick $pop_nick_history_network(4,2)
  ....$iif(($pop_nick_history_network(4,2) == $anick),$style(1)) &alternate nick : anick $pop_nick_history_network(4,2)
  ...$pop_nick_history_network(4,3)
  ....$iif(($pop_nick_history_network(4,3) != $mnick) && ($pop_nick_history_network(4,3) != $anick),$style(1)) &temp nickname : tnick $pop_nick_history_network(4,3)
  ....$iif(($pop_nick_history_network(4,3) == $mnick) && ($pop_nick_history_network(4,3) == $me),$style(1)) current && m&ain : nick $pop_nick_history_network(4,3)
  ....-
  ....$iif(($pop_nick_history_network(4,3) == $mnick),$style(1)) m&ain nickname : mnick $pop_nick_history_network(4,3)
  ....$iif(($pop_nick_history_network(4,3) == $anick),$style(1)) &alternate nick : anick $pop_nick_history_network(4,3)
  ...$pop_nick_history_network(4,4)
  ....$iif(($pop_nick_history_network(4,4) != $mnick) && ($pop_nick_history_network(4,4) != $anick),$style(1)) &temp nickname : tnick $pop_nick_history_network(4,4)
  ....$iif(($pop_nick_history_network(4,4) == $mnick) && ($pop_nick_history_network(4,4) == $me),$style(1)) current && m&ain : nick $pop_nick_history_network(4,4)
  ....-
  ....$iif(($pop_nick_history_network(4,4) == $mnick),$style(1)) m&ain nickname : mnick $pop_nick_history_network(4,4)
  ....$iif(($pop_nick_history_network(4,4) == $anick),$style(1)) &alternate nick : anick $pop_nick_history_network(4,4)
  ...$pop_nick_history_network(4,5)
  ....$iif(($pop_nick_history_network(4,5) != $mnick) && ($pop_nick_history_network(4,5) != $anick),$style(1)) &temp nickname : tnick $pop_nick_history_network(4,5)
  ....$iif(($pop_nick_history_network(4,5) == $mnick) && ($pop_nick_history_network(4,5) == $me),$style(1)) current && m&ain : nick $pop_nick_history_network(4,5)
  ....-
  ....$iif(($pop_nick_history_network(4,5) == $mnick),$style(1)) m&ain nickname : mnick $pop_nick_history_network(4,5)
  ....$iif(($pop_nick_history_network(4,5) == $anick),$style(1)) &alternate nick : anick $pop_nick_history_network(4,5)
  ...$pop_nick_history_network(4,6)
  ....$iif(($pop_nick_history_network(4,6) != $mnick) && ($pop_nick_history_network(4,6) != $anick),$style(1)) &temp nickname : tnick $pop_nick_history_network(4,6)
  ....$iif(($pop_nick_history_network(4,6) == $mnick) && ($pop_nick_history_network(4,6) == $me),$style(1)) current && m&ain : nick $pop_nick_history_network(4,6)
  ....-
  ....$iif(($pop_nick_history_network(4,6) == $mnick),$style(1)) m&ain nickname : mnick $pop_nick_history_network(4,6)
  ....$iif(($pop_nick_history_network(4,6) == $anick),$style(1)) &alternate nick : anick $pop_nick_history_network(4,6)
  ...$pop_nick_history_network(4,7)
  ....$iif(($pop_nick_history_network(4,7) != $mnick) && ($pop_nick_history_network(4,7) != $anick),$style(1)) &temp nickname : tnick $pop_nick_history_network(4,7)
  ....$iif(($pop_nick_history_network(4,7) == $mnick) && ($pop_nick_history_network(4,7) == $me),$style(1)) current && m&ain : nick $pop_nick_history_network(4,7)
  ....-
  ....$iif(($pop_nick_history_network(4,7) == $mnick),$style(1)) m&ain nickname : mnick $pop_nick_history_network(4,7)
  ....$iif(($pop_nick_history_network(4,7) == $anick),$style(1)) &alternate nick : anick $pop_nick_history_network(4,7)
  ...$pop_nick_history_network(4,8)
  ....$iif(($pop_nick_history_network(4,8) != $mnick) && ($pop_nick_history_network(4,8) != $anick),$style(1)) &temp nickname : tnick $pop_nick_history_network(4,8)
  ....$iif(($pop_nick_history_network(4,8) == $mnick) && ($pop_nick_history_network(4,8) == $me),$style(1)) current && m&ain : nick $pop_nick_history_network(4,8)
  ....-
  ....$iif(($pop_nick_history_network(4,8) == $mnick),$style(1)) m&ain nickname : mnick $pop_nick_history_network(4,8)
  ....$iif(($pop_nick_history_network(4,8) == $anick),$style(1)) &alternate nick : anick $pop_nick_history_network(4,8)  


  ..$pop_recent_network_nick_history(5)
  ...$pop_nick_history_network(5,1)
  ....$iif(($pop_nick_history_network(5,1) != $mnick) && ($pop_nick_history_network(5,1) != $anick),$style(1)) &temp nickname : tnick $pop_nick_history_network(5,1)
  ....$iif(($pop_nick_history_network(5,1) == $mnick) && ($pop_nick_history_network(5,1) == $me),$style(1)) current && m&ain : nick $pop_nick_history_network(5,1)
  ....-
  ....$iif(($pop_nick_history_network(5,1) == $mnick),$style(1)) m&ain nickname : mnick $pop_nick_history_network(5,1)
  ....$iif(($pop_nick_history_network(5,1) == $anick),$style(1)) &alternate nick : anick $pop_nick_history_network(5,1)
  ...$pop_nick_history_network(5,2)
  ....$iif(($pop_nick_history_network(5,2) != $mnick) && ($pop_nick_history_network(5,2) != $anick),$style(1)) &temp nickname : tnick $pop_nick_history_network(5,2)
  ....$iif(($pop_nick_history_network(5,2) == $mnick) && ($pop_nick_history_network(5,2) == $me),$style(1)) current && m&ain : nick $pop_nick_history_network(5,2)
  ....-
  ....$iif(($pop_nick_history_network(5,2) == $mnick),$style(1)) m&ain nickname : mnick $pop_nick_history_network(5,2)
  ....$iif(($pop_nick_history_network(5,2) == $anick),$style(1)) &alternate nick : anick $pop_nick_history_network(5,2)
  ...$pop_nick_history_network(5,3)
  ....$iif(($pop_nick_history_network(5,3) != $mnick) && ($pop_nick_history_network(5,3) != $anick),$style(1)) &temp nickname : tnick $pop_nick_history_network(5,3)
  ....$iif(($pop_nick_history_network(5,3) == $mnick) && ($pop_nick_history_network(5,3) == $me),$style(1)) current && m&ain : nick $pop_nick_history_network(5,3)
  ....-
  ....$iif(($pop_nick_history_network(5,3) == $mnick),$style(1)) m&ain nickname : mnick $pop_nick_history_network(5,3)
  ....$iif(($pop_nick_history_network(5,3) == $anick),$style(1)) &alternate nick : anick $pop_nick_history_network(5,3)
  ...$pop_nick_history_network(5,4)
  ....$iif(($pop_nick_history_network(5,4) != $mnick) && ($pop_nick_history_network(5,4) != $anick),$style(1)) &temp nickname : tnick $pop_nick_history_network(5,4)
  ....$iif(($pop_nick_history_network(5,4) == $mnick) && ($pop_nick_history_network(5,4) == $me),$style(1)) current && m&ain : nick $pop_nick_history_network(5,4)
  ....-
  ....$iif(($pop_nick_history_network(5,4) == $mnick),$style(1)) m&ain nickname : mnick $pop_nick_history_network(5,4)
  ....$iif(($pop_nick_history_network(5,4) == $anick),$style(1)) &alternate nick : anick $pop_nick_history_network(5,4)
  ...$pop_nick_history_network(5,5)
  ....$iif(($pop_nick_history_network(5,5) != $mnick) && ($pop_nick_history_network(5,5) != $anick),$style(1)) &temp nickname : tnick $pop_nick_history_network(5,5)
  ....$iif(($pop_nick_history_network(5,5) == $mnick) && ($pop_nick_history_network(5,5) == $me),$style(1)) current && m&ain : nick $pop_nick_history_network(5,5)
  ....-
  ....$iif(($pop_nick_history_network(5,5) == $mnick),$style(1)) m&ain nickname : mnick $pop_nick_history_network(5,5)
  ....$iif(($pop_nick_history_network(5,5) == $anick),$style(1)) &alternate nick : anick $pop_nick_history_network(5,5)
  ...$pop_nick_history_network(5,6)
  ....$iif(($pop_nick_history_network(5,6) != $mnick) && ($pop_nick_history_network(5,6) != $anick),$style(1)) &temp nickname : tnick $pop_nick_history_network(5,6)
  ....$iif(($pop_nick_history_network(5,6) == $mnick) && ($pop_nick_history_network(5,6) == $me),$style(1)) current && m&ain : nick $pop_nick_history_network(5,6)
  ....-
  ....$iif(($pop_nick_history_network(5,6) == $mnick),$style(1)) m&ain nickname : mnick $pop_nick_history_network(5,6)
  ....$iif(($pop_nick_history_network(5,6) == $anick),$style(1)) &alternate nick : anick $pop_nick_history_network(5,6)
  ...$pop_nick_history_network(5,7)
  ....$iif(($pop_nick_history_network(5,7) != $mnick) && ($pop_nick_history_network(5,7) != $anick),$style(1)) &temp nickname : tnick $pop_nick_history_network(5,7)
  ....$iif(($pop_nick_history_network(5,7) == $mnick) && ($pop_nick_history_network(5,7) == $me),$style(1)) current && m&ain : nick $pop_nick_history_network(5,7)
  ....-
  ....$iif(($pop_nick_history_network(5,7) == $mnick),$style(1)) m&ain nickname : mnick $pop_nick_history_network(5,7)
  ....$iif(($pop_nick_history_network(5,7) == $anick),$style(1)) &alternate nick : anick $pop_nick_history_network(5,7)
  ...$pop_nick_history_network(5,8)
  ....$iif(($pop_nick_history_network(5,8) != $mnick) && ($pop_nick_history_network(5,8) != $anick),$style(1)) &temp nickname : tnick $pop_nick_history_network(5,8)
  ....$iif(($pop_nick_history_network(5,8) == $mnick) && ($pop_nick_history_network(5,8) == $me),$style(1)) current && m&ain : nick $pop_nick_history_network(5,8)
  ....-
  ....$iif(($pop_nick_history_network(5,8) == $mnick),$style(1)) m&ain nickname : mnick $pop_nick_history_network(5,8)
  ....$iif(($pop_nick_history_network(5,8) == $anick),$style(1)) &alternate nick : anick $pop_nick_history_network(5,8)  


  ..$pop_recent_network_nick_history(6)
  ...$pop_nick_history_network(6,1)
  ....$iif(($pop_nick_history_network(6,1) != $mnick) && ($pop_nick_history_network(6,1) != $anick),$style(1)) &temp nickname : tnick $pop_nick_history_network(6,1)
  ....$iif(($pop_nick_history_network(6,1) == $mnick) && ($pop_nick_history_network(6,1) == $me),$style(1)) current && m&ain : nick $pop_nick_history_network(6,1)
  ....-
  ....$iif(($pop_nick_history_network(6,1) == $mnick),$style(1)) m&ain nickname : mnick $pop_nick_history_network(6,1)
  ....$iif(($pop_nick_history_network(6,1) == $anick),$style(1)) &alternate nick : anick $pop_nick_history_network(6,1)
  ...$pop_nick_history_network(6,2)
  ....$iif(($pop_nick_history_network(6,2) != $mnick) && ($pop_nick_history_network(6,2) != $anick),$style(1)) &temp nickname : tnick $pop_nick_history_network(6,2)
  ....$iif(($pop_nick_history_network(6,2) == $mnick) && ($pop_nick_history_network(6,2) == $me),$style(1)) current && m&ain : nick $pop_nick_history_network(6,2)
  ....-
  ....$iif(($pop_nick_history_network(6,2) == $mnick),$style(1)) m&ain nickname : mnick $pop_nick_history_network(6,2)
  ....$iif(($pop_nick_history_network(6,2) == $anick),$style(1)) &alternate nick : anick $pop_nick_history_network(6,2)
  ...$pop_nick_history_network(6,3)
  ....$iif(($pop_nick_history_network(6,3) != $mnick) && ($pop_nick_history_network(6,3) != $anick),$style(1)) &temp nickname : tnick $pop_nick_history_network(6,3)
  ....$iif(($pop_nick_history_network(6,3) == $mnick) && ($pop_nick_history_network(6,3) == $me),$style(1)) current && m&ain : nick $pop_nick_history_network(6,3)
  ....-
  ....$iif(($pop_nick_history_network(6,3) == $mnick),$style(1)) m&ain nickname : mnick $pop_nick_history_network(6,3)
  ....$iif(($pop_nick_history_network(6,3) == $anick),$style(1)) &alternate nick : anick $pop_nick_history_network(6,3)
  ...$pop_nick_history_network(6,4)
  ....$iif(($pop_nick_history_network(6,4) != $mnick) && ($pop_nick_history_network(6,4) != $anick),$style(1)) &temp nickname : tnick $pop_nick_history_network(6,4)
  ....$iif(($pop_nick_history_network(6,4) == $mnick) && ($pop_nick_history_network(6,4) == $me),$style(1)) current && m&ain : nick $pop_nick_history_network(6,4)
  ....-
  ....$iif(($pop_nick_history_network(6,4) == $mnick),$style(1)) m&ain nickname : mnick $pop_nick_history_network(6,4)
  ....$iif(($pop_nick_history_network(6,4) == $anick),$style(1)) &alternate nick : anick $pop_nick_history_network(6,4)
  ...$pop_nick_history_network(6,5)
  ....$iif(($pop_nick_history_network(6,5) != $mnick) && ($pop_nick_history_network(6,5) != $anick),$style(1)) &temp nickname : tnick $pop_nick_history_network(6,5)
  ....$iif(($pop_nick_history_network(6,5) == $mnick) && ($pop_nick_history_network(6,5) == $me),$style(1)) current && m&ain : nick $pop_nick_history_network(6,5)
  ....-
  ....$iif(($pop_nick_history_network(6,5) == $mnick),$style(1)) m&ain nickname : mnick $pop_nick_history_network(6,5)
  ....$iif(($pop_nick_history_network(6,5) == $anick),$style(1)) &alternate nick : anick $pop_nick_history_network(6,5)
  ...$pop_nick_history_network(6,6)
  ....$iif(($pop_nick_history_network(6,6) != $mnick) && ($pop_nick_history_network(6,6) != $anick),$style(1)) &temp nickname : tnick $pop_nick_history_network(6,6)
  ....$iif(($pop_nick_history_network(6,6) == $mnick) && ($pop_nick_history_network(6,6) == $me),$style(1)) current && m&ain : nick $pop_nick_history_network(6,6)
  ....-
  ....$iif(($pop_nick_history_network(6,6) == $mnick),$style(1)) m&ain nickname : mnick $pop_nick_history_network(6,6)
  ....$iif(($pop_nick_history_network(6,6) == $anick),$style(1)) &alternate nick : anick $pop_nick_history_network(6,6)
  ...$pop_nick_history_network(6,7)
  ....$iif(($pop_nick_history_network(6,7) != $mnick) && ($pop_nick_history_network(6,7) != $anick),$style(1)) &temp nickname : tnick $pop_nick_history_network(6,7)
  ....$iif(($pop_nick_history_network(6,7) == $mnick) && ($pop_nick_history_network(6,7) == $me),$style(1)) current && m&ain : nick $pop_nick_history_network(6,7)
  ....-
  ....$iif(($pop_nick_history_network(6,7) == $mnick),$style(1)) m&ain nickname : mnick $pop_nick_history_network(6,7)
  ....$iif(($pop_nick_history_network(6,7) == $anick),$style(1)) &alternate nick : anick $pop_nick_history_network(6,7)
  ...$pop_nick_history_network(6,8)
  ....$iif(($pop_nick_history_network(6,8) != $mnick) && ($pop_nick_history_network(6,8) != $anick),$style(1)) &temp nickname : tnick $pop_nick_history_network(6,8)
  ....$iif(($pop_nick_history_network(6,8) == $mnick) && ($pop_nick_history_network(6,8) == $me),$style(1)) current && m&ain : nick $pop_nick_history_network(6,8)
  ....-
  ....$iif(($pop_nick_history_network(6,8) == $mnick),$style(1)) m&ain nickname : mnick $pop_nick_history_network(6,8)
  ....$iif(($pop_nick_history_network(6,8) == $anick),$style(1)) &alternate nick : anick $pop_nick_history_network(6,8)  


}
