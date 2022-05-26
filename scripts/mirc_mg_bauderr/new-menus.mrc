on *:quit: {
  if ($nick == $me) { 
    unset $varname_cid(trio-ircproxy.py, active)
    unset $varname_cid(trio-ircproxy.py, admin)     
  }
}
alias advertise-chan {
  if ($status != connected) { return }
  if ($chan != $null) { return this channel }
}
alias advertise-in-channel {
  if ($status != connected) { return }
  if ($chan(0) > 0) { return in channel }
}
alias advertise-chan-00 {
  if ($status != connected) { return }
  if ($chan(1) != $null) { return $chan(1) }
}
alias advertise-chan-00 {
  if ($status != connected) { return }
  if ($chan(1) != $null) { return $chan(1) }
}
alias advertise-chan-01 {
  if ($status != connected) { return }
  if ($chan(2) != $null) { return $chan(2) }
}
alias advertise-chan-02 {
  if ($status != connected) { return }
  if ($chan(3) != $null) { return $chan(3) }
}
alias advertise-chan-03 {
  if ($status != connected) { return }
  if ($chan(4) != $null) { return $chan(4) }
}
alias advertise-chan-04 {
  if ($status != connected) { return }
  if ($chan(5) != $null) { return $chan(5) }
}
alias advertise-chan-05 {
  if ($status != connected) { return }
  if ($chan(6) != $null) { return $chan(6) }
}
alias advertise-chan-06 {
  if ($status != connected) { return }
  if ($chan(7) != $null) { return $chan(7) }
}
alias advertise-chan-07 {
  if ($status != connected) { return }
  if ($chan(8) != $null) { return $chan(8) }
}
alias advertise-chan-08 {
  if ($status != connected) { return }
  if ($chan(9) != $null) { return $chan(9) }
}
alias advertise-chan-09 {
  if ($status != connected) { return }
  if ($chan(10) != $null) { return $chan(10) }
}
alias advertise-this-connection {
  if ($status != connected) { return }
  if ($chan(0) == 0) { return }
  return all chans on this connection
}
alias advertise-network {
  if ($network == $null) { return }
  return chans on network $network
}
alias advertise-this-client {
  return everywhere on this client
}
alias advertise-everywhere {
  return all proxy user named [ [ $varname_cid(trio-ircproxy.py, is_user) ] ]
}
alias block {
  if (strip($1) == $null) { return }
  return $chr(91) $+ $1- $+ $chr(93)
}
menu Status,Channel {
  $chr(46) $chr(58) M&achine Gun $str($chr(58),2) $chr(58)
  .$chr(46) $str($chr(58),1) describe mg $str($chr(58),2) $chr(58)
  ..$advertise-chan : /describe $chan is using mSL Machine Gun script named Bauderr. send ctcp script/version for more info.
  ..$advertise-in-channel
  ...$advertise-chan-00 : /bauderr-advertise --chan $chan(1)
  ...$advertise-chan-01 : /bauderr-advertise --chan $chan(2)
  ...$advertise-chan-02 : /bauderr-advertise --chan $chan(3)
  ...$advertise-chan-03 : /bauderr-advertise --chan $chan(4)
  ...$advertise-chan-04 : /bauderr-advertise --chan $chan(5)
  ...$advertise-chan-05 : /bauderr-advertise --chan $chan(6)
  ...$advertise-chan-06 : /bauderr-advertise --chan $chan(7)
  ...$advertise-chan-07 : /bauderr-advertise --chan $chan(8)
  ...$advertise-chan-08 : /bauderr-advertise --chan $chan(9)
  ...$advertise-chan-09 : /bauderr-advertise --chan $chan(10)
  ..$advertise-this-connection : /proxy-advertise --connection
  ..$advertise-network : /proxy-advertise --network $network
  ..$advertise-this-client : /scon -a /ame is using Machine Gun script named Bauderr with trio-ircproxy.py walker byte-code!
  ..everywhere possible : /proxy-advertise -everywhere
  -
  &flood protection
  .p&ersonal : /proxy-noflood-personal on
  .&channel : /proxy-noflood-channel on
  .-
  .info : script_info -flood
  mirc &commands
  .interface
  ..$iif(($switchbar),$style(1)) show swichbar : switchbar $iif(($switchbar),off,on)
  ..$iif(($treebar),$style(1)) [show treebar] : treebar $iif(($treebar),off,on)
  ..$iif(($menubar),$style(1)) [show menubar] : menubar $iif(($menubar),off,on)
  channel &assistance
  .$bnc_active topi&c history
  ..$iif(($chan),$iif(($varname_glob(topic-history-clear,$chan).value || $varname_glob(topic-history-clear,everywhere).value),$style(2))) open reader history : bnc_msg topic-history $chan
  ..-
  ..$iif(($chan),$iif(($varname_glob(topic-history-clear,$chan).value || $varname_glob(topic-history-clear,everywhere).value),$style())) clear &channel's topic history : bnc_msg clear-topic-history $chan
  ..$iif((!$varname_glob(topic-history-clear,everywhere).value),$null,$style(3)) clear topic history &everywhere : bnc_msg clear-topic-history-everywhere
  ..$iif(($varname_glob(topic-history-freeze,$chan).value || $varname_glob(topic-history-freeze,everywhere).value),$style(1)) freeze &topic history
  ...$iif(($chan),$iif(($varname_glob(topic-history-freeze,$chan).value),$style(1)),$style(2)) this &channel : bnc_msg topic_history_freeze-toggle $chan
  ...$iif(($varname_glob(topic-history-freeze,everywhere).value),$style(1)) &everywhere : bnc_msg topic_history_freeze_everywhere-toggle
  ..-
  ..info : script_info -history
  .$bnc_active mode history
  ..$iif(($chan),$iif(($varname_glob(mode-history-clear,$chan).value || $varname_glob(mode-history-clear,everywhere).value),$style(2))) open reader history : bnc_msg mode-history $chan
  ..-
  ..$iif(($chan),$iif(($varname_glob(mode-history-clear,$chan).value || $varname_glob(mode-history-clear,everywhere).value),$style())) clear channel's mode history : bnc_msg clear-mode-history $chan
  ..$iif((!$varname_glob(mode-history-clear,everywhere).value),$null,$style(3)) clear mode history everywhere : bnc_msg clear-mode-history-everywhere
  ..$iif(($varname_glob(mode-history-freeze,$chan).value || $varname_glob(mode-history-freeze,everywhere).value),$style(1)) freeze mode history
  ...$iif(($chan),$iif(($varname_glob(mode-history-freeze,$chan).value),$style(1)),$style(2)) this channel : bnc_msg mode_history_freeze-toggle $chan
  ...$iif(($varname_glob(mode-history-freeze,everywhere).value),$style(1)) everywhere : bnc_msg mode_history_freeze_everywhere-toggle
  ..-
  ..info : script_info -history

  .$bnc_active user status history
  ..$iif(($chan),$iif(($varname_glob(status-history-clear,$chan).value || $varname_glob(status-history-clear,everywhere).value),$style(2))) open reader history : bnc_msg status-history $chan
  ..-
  ..$iif(($chan),$iif(($varname_glob(status-history-clear,$chan).value || $varname_glob(status-history-clear,everywhere).value),$style())) clear channel's status history : bnc_msg clear-status-history $chan
  ..$iif((!$varname_glob(status-history-clear,everywhere).value),$null,$style(3)) clear status history everywhere : bnc_msg clear-status-history-everywhere
  ..$iif(($varname_glob(status-history-freeze,$chan).value || $varname_glob(status-history-freeze,everywhere).value),$style(1)) freeze status history
  ...$iif(($chan),$iif(($varname_glob(status-history-freeze,$chan).value),$style(1)),$style(2)) this channel : bnc_msg status_history_freeze-toggle $chan
  ...$iif(($varname_glob(status-history-freeze,everywhere).value),$style(1)) everywhere : bnc_msg status_history_freeze_everywhere-toggle
  ..-
  ..info : script_info -history
  .-
  .$iif((!$chan),$style(2),$iif((!$bnc_active),$iif((!$varname_glob(say-away,none).value),$null,$style(1)),$style(2))) announce away in channels : bnc_msg say-away-toggle
  .-
  .$bnc_active ircoper scan
  ..scan now here : bnc_msg operscan$chan
  ..scan now everywhere : bnc_msg operscan-ecerywhere
  ..-
  ..scan on-join (all channels) : bnc_msg operscan-join-toggle
  .$iif((!$bnc_active),$iif((!$chan),$style(2))) /who status : bnc_msg who-status $chan

  &trio-ircproxy.py
  .$bnc_active &set server identity
  ..$iif(($varname_glob(admin-server-name,none).value != $null),$style(1)) &server's name $block($varname_glob(admin-server-name,none).value) : /bnc_msg set-name $$?="enter your server's name (only letters, numbers, period and lowline):"
  ..$iif(($varname_glob(admin-nick,none).value != $null),$style(1)) &admin nickname $block($varname_glob(admin-nick,none).value) : /bnc_msg set-admin $$?="enter your contact nickname:"
  ..$iif(($varname_glob(admin-smtp-email,none).value != $null),$style(1)) &admin email $block($varname_glob(admin-smtp-email,none).value) : /bnc_msg set-email $$?="enter your admin email:"
  ..$iif(($varname_glob(admin-smtp-hostname,none).value != $null),$style(1)) &smtp hostname $block($varname_glob(admin-smtp-hostname,none).value) : /bnc_msg set-smtp $$?="enter your smtp server hostname:"
  ..$iif(($varname_glob(admin-smtp-user,none).value != $null),$style(1)) &smtp username $block($varname_glob(admin-smtp-user,none).value) : /bnc_msg set-smtp $$?="enter your smtp server username:"
  ..$iif(($varname_glob(admin-smtp-pass,none).value == $true),$style(1)) &smtp password : /bnc_msg set-smtp $$?="enter your smtp server password:"
  ..-
  ..in&fo : /script_info -identity
  .-
  .$iif((!$varname_cid(trio-ircproxy.py,active).value),$style(2)) &shutdown trio-ircproxy : /proxy-shutdown
  .$iif(($varname_cid(trio-ircproxy.py,active).value),$style(2)) &start trio-ircproxy.py 
  ..p&y -3 : /run -n py -3 $qw($scriptdir..\..\trio-ircproxy.py)
  ..py&thon : /run -n python $qw($scriptdir..\..\trio-ircproxy.py)
  ..[py&thon3] : /run -n python3 $qw($scriptdir..\..\trio-ircproxy.py)
  ..-
  ..&custom
  ...$iif(($right($nofile($varname_global(python3,file_path).value),32) $+ $nopath($varname_global(python3,file_path).value) == $null), nothing,$ifmatch) : run -n $qw($varname_global(python3,file_path).value) $qw($scriptdir..\..\trio-ircproxy.py)
  ...-
  ...&change file path : var %tmp = $sfile($envvar(userprofile) $+ \AppData\Local\Programs\Python\Python*.exe,Select your Python v3.8+ interpreter,Select) | if (!$sfstate) { set $varname_global(python3,file_path) %tmp }
  .-
  .$iif((!$varname_cid(trio-ircproxy.py,active).value),$style(2)) u&se ip
  ..$iif(($varname_glob(bind-ip,private).value),$style(1)) 127.0.0.1 (private) : bnc_msg bind-ip private
  ..$iif(($varname_glob(bind-ip,global).value),$style(1)) [0.0.0.0 (global)] : bnc_msg bind-ip global
  .$iif((!$varname_cid(trio-ircproxy.py,active).value),$style(2)) u&se nickname
  ..$iif(($varname_glob(status-nick,none).value == *status),$style(1)) *status : bnc_msg use-nick *
  ..$iif(($varname_glob(status-nick,none).value == **status),$style(1)) [**status] : bnc_msg use-nick **

  .$iif((!$varname_cid(trio-ircproxy.py,active).value),$style(2)) u&se port
  ..change $block($varname_glob(use-port,proxy).value,/,$varname_glob(use-port,http).value) : {
    var %pp = $$?="enter two port numbers; for proxy and http [1-65535]:" 
    var %p = $gettok(%pp,1,32)
    if (!%p) { errecho you must supply two port numbers; one for proxy and another for http | return }
    if (!$isnum(%p)) || (%p < 1) or (%p > 65535) { errecho invalid port number. port must be from 1 to 65535 | return }
    var %p = $gettok(%pp,2,32)
    if (!%p) { errecho you must supply two port numbers | return }
    if (!$isnum(%p)) || (%p < 1) or (%p > 65535) { errecho invalid port number. port must be from 1 to 65535 | return }
    bnc_msg use-port $gettok(%pp,1-2,32)
  }
  ..$iif(($varname_glob(use-port,proxy).value == 4321 && $varname_glob(use-port,http).value == 80),$style(1)) [4321/80] : /bnc_msg use-port 4321 80
  .-
  .$iif((!$varname_cid(trio-ircproxy.py,active).value),$style(2)) running status : /bnc_msg status
  &connect irc
  .with proxy 
  ..192.168.0.17 4321 : /proxy on | var %net = $iif(($network),$network,$$?="enter network name:") | /server $$server(1, %net) $+ : $+ $remove($server(1, %net).port,+) 
  .with vhost
  ..38.242.206.227 7000 : /proxy off | var %net = $$?="enter network name:") | /server 38.242.206.227:7000 $$?="enter your username:" $+ / $+ %net $+ : $+ $$?="enter your password:"
  ..192.168.0.17 +6697 : /proxy off | var %net = $iif(($network),$network,$$?="enter network name:") | /server 192.168.0.17:+6697 $$?="enter your username:" $+ / $+ %net $+ : $+ $$?="enter your password:"

  ; command history
  ;.xcdcc send #899 : /msg [MG]-MISC|EU|S|RandomPunk xdcc send #899

}
on *:text:*:$+(*,$chr(42),status): {
  ; Must start with "status-inick"
  if (!$is_status_nick) { return }
  tokenize 32 $strip($1-)
  if (status-nick == $1) { set $varname_glob(status-nick,none) $nick }
  if ($1- == Trio-ircproxy.py active for this connection) { set $varname_cid(trio-ircproxy.py, active) $true }
  if ($1- == you are logged-in as Administrator) { set $varname_cid(trio-ircproxy.py, admin) $true }
  if ($4 != $null) && ($1-4 iswm *your username is ??*) { set $varname_cid(trio-ircproxy.py, is_user) $4 }
  if (!$is_status) { return }
  if ($1 == admin-nick) { set $varname_glob(admin-nick,none) $$2 }
  if ($1 == admin-smtp-email) { set $varname_glob(admin-smtp-email,none) $$2 }
  if ($1 == admin-smtp-hostname) { set $varname_glob(admin-smtp-hostname,none) $$2 }
  if ($1 == admin-smtp-server-name) { set $varname_glob(admin-server-name,none) $$2 }
  if ($1 == admin-smtp-user) { set $varname_glob(admin-smtp-user,none) $$2 }
  if ($1 == admin-smtp-password) { set $varname_glob(admin-smtp-password,none) $iif(($$2 == $true),$true,$false) }
  if (status-history-freeze-everywhere == $1) && ($2 isin $true$false) { set $varname_glob(status-history-freeze,everywhere) $$2 }
  if (status-history-freeze == $1) && (#* iswm $2) { set $varname_glob(status-history-freeze,$2) $$3 }
  if (status-history-clear == $1) && ($3 isin $true$false) { set $varname_glob(status-history-clear,$2) $$3 }
  if (status-history-clear-everywhere == $1) && ($2 isin $true$false) { set $varname_glob(status-history-clear,everywhere) $$2 }
  if (say-away == $1) && ($2 isin $true$false) { set $varname_glob(say-away,none) $2 }
  if (operscan-join == $1) && ($2 isin $true$false) { set $varname_glob(operscan-join,everywhere) $2 }

}
alias true$false {
  return $true $+ $false
}
alias is_status_nick {
  if ($1) { var %nick = $1 }
  elseif ($nick != $null) { var %nick = $nick }
  if ($chr(42) $+ status != %nick) && ($str($chr(42),2) $+ status != %nick) { return $false }
  return $true
}
alias is_status {
  if ($1 != $null) { var %nick = $1 }
  elseif ($nick != $null) { var %nick = $nick }
  else { return $false }
  if ($varname_glob(stauts-nick,none).value == %nick) { return $true }
  else { return $false }
}
menu menubar {
  $iif((!$var(%bde_glob_*history*,0)),$style(2)) erase history : unset %bde_glob_*history* | eecho you have erased your history.
  $iif(($os isin 7,10,11),&set client faster) : eecho changed priority of all running $nopath($mircexe) and python.exe apps to 'High' | run -hn wmic process where name=" $+ $nopath($mircexe) $+ " CALL setpriority 128 | run -hn wmic process where name="python.exe" CALL setpriority 128

}
on *:input:*?> $chr(35) $+ ?*: {
  tokenize 32 $strip($1-)
  if ($0 < 2) { return }
  var %num = $remove($2,$chr(35))
  if (!$isnum(%num)) { return }
  var %name = $remove($1,<,>,+,@,%,&,!)
  if (!%name) { return }
  msg %name xdcc send $chr(35) $+ %num
  halt
}
menu @script_info {
  close window : window -c $active
  -
  flood : /script_info -flood
  channel history : script_info -history
  identity : script_info -identity

}
alias bnc_active {
  return $iif((!$varname_cid(trio-ircproxy.py,active).value),$style(2))
}
alias bnc_msg {
  if (!$varname_glob(status-nick,none).value) { return }
  if ($strip($1) == $null) { return }
  msg $varname_glob(status-nick,none).value $1-
}
