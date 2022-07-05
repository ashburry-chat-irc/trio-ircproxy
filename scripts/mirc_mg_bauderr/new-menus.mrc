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
alias advertise-user {
  return all proxy user $varname_cid(trio-ircproxy.py, is_user).value
}
alias block {
  if (strip($1) == $null) { return }
  return $chr(91) $+ $1- $+ $chr(93)
}
menu Status,Channel {
  $chr(46) $chr(58) M&achine Gun $str($chr(58),2) $chr(58)
  .$style_proxy $chr(46) $chr(58) describe mg $str($chr(58),2) $chr(58)
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
  ..$advertise-this-connection : /bnc_msg advertise-connection
  ..$advertise-network : bnc_msg advertise-network
  ..$advertise-this-client : /scon -a /ame is using Machine Gun script named Bauderr with trio-ircproxy.py walker byte-code!
  ..$advertise-user : bnc_msg advertise-username
  ..everywhere possible : bnc_msg advertise-everywhere
  -
  &room menu
  .topi&c history
  ..$iif((!$topic_history_popup(1)),$style(3)) clear topic history : unset $varname_cid(topic_history_*,*) | eecho topic history cleared for room $chan
  ..-
  ..$submenu($topic_history_popup($1)))
  .&chanserv
  ..$identify_here_popup : /bnc_msg identify-chanserv $$chan 
  ..$popup-identify-founder-list
  ...$submenu($identify_chans_popup($1))
  .ir&c oper scan
  ..$iif($varname_global((oper-scan-join,$network).value == $true),$style(1)) scan on-join : set $varname_global(oper-scan-join,$network) $true
  &trio-ircproxy.py
  .&set server identity
  ..$style_proxy &server's name $block($varname_glob(admin-server-name,none).value) : /bnc_msg set-name $$?="enter your server's name (letters only):"
  ..$style_proxy &admin nickname $block($varname_glob(admin-nick,none).value) : /bnc_msg set-admin $$?="enter your contact nickname:"
  ..$style_proxy &admin email $block($varname_glob(admin-smtp-email,none).value) : /bnc_msg set-email $$?="enter your system email:"
  ..$style_proxy &smtp hostname $block($varname_glob(admin-smtp-hostname,none).value) : /bnc_msg set-smtp $$?="enter your smtp server hostname:"
  ..$style_proxy &smtp username $block($varname_glob(admin-smtp-user,none).value) : /bnc_msg set-username $$?="enter your smtp server username:"
  ..$style_proxy &smtp password : /.bnc_msg set-password $$?="enter your smtp server password:"
  ..-
  ..in&fo : /script_info -identity
  .-
  .$style_proxy &start web-server : /run $scriptdir../www/flask_app.py

  .$style_proxy &restart trio-ircproxy.py : /proxy-restart
  .$style_proxy &shutdown trio-ircproxy.py : /proxy-shutdown
  .$iif((!$varname_cid(trio-ircproxy.py,active).value),$style(2)) &start trio-ircproxy.py 
  .command line
  ..p&y -3 : set $varname_glob(python,none) py -3
  ..py&thon : set $varname_glob(python,none) python
  ..[py&thon3] : set $varname_glob(python,none) python3
  ..-
  ..&custom
  ...$iif(($right($varname_glob(python,none).value,32)),$ifmatch,select) : var %tmp = $sfile($envvar(userprofile) $+ \AppData\Local\Programs\Python\Python*.exe,Select your Python v3.8+ interpreter,Select) | if (!$sfstate) { set $varname_global(python,none) %tmp }

  .-
  .listen with ip
  ..$iif(($varname_glob(bind-ip).value == private),$style(1)) 127.0.0.1 (private/this computer only) : set $varname_global(bind-ip) private
  ..$iif(($varname_glob(bind-ip).value == global),$style(1)) [0.0.0.0 (public/local network)] : set $varname_global(bind-ip) global
  ..-
  ..info : script_info -listen

  .u&se port
  ..change $block($varname_glob(use-port,proxy).value,/,$varname_glob(use-port,http).value) : {
    var %pp = $$?="enter two port numbers; for proxy then http [4321 80]:" 
    %pp = $replace(%pp,/,$chr(32))
    %pp = $replace(%pp,$str($chr(32),2),$chr(32))
    var %p = $gettok(%pp,1,32)
    if (!%p) { errecho you must supply two port numbers; one for proxy and another for http | return }
    if (!$isnum(%p)) || (%p < 1) || (%p > 65535) { errecho invalid port number, port must be from 1 to 65535. | return }
    var %p = $gettok(%pp,2,32)
    if (!%p) { errecho you must supply two port numbers | return }
    if (!$isnum(%p)) || (%p < 1) || (%p > 65535) { errecho invalid port number, port must be from 1 to 65535. | return }
    set $varname_glob(use-port,proxy) $gettok(%pp,1,32)
    set $varname_glob(use-port,http) $gettok(%pp,2,32)
    eecho restart Trio-IrcProxy.py and the web-server for changes to take affect.
  }
  ..$iif(($varname_glob(use-port,proxy).value == 4321 && $varname_glob(use-port,http).value == 80),$style(1)) [4321/80] : {
    set $varname_glob(use-port,proxy) 4321
    set $varname_glob(use-port,http) 80
    eecho restart Trio-IrcProxy.py and the web-server for changes to take affect.
  }
  ..-
  ..info : script_info -port
  .-
  .u&se status nickname
  ..$status_usenick_pop(*status) *status : bnc_msg use-nick 1
  ..$status_usenick_pop(~status) [~status] : bnc_msg use-nick 2
  .-
  .$style_proxy running status : /bnc_msg status
  &connect irc
  .with proxy 
  ..192.168.0.17 4321 : /proxy on | var %net = $iif(($network),$network,$$?="enter network name:") | /server $$server(1, %net) $+ : $+ $remove($server(1, %net).port,+) 
  .with vhost
  ..38.242.206.227 7000 : /proxy off | var %net = $$?="enter network name:") | /server 38.242.206.227:7000 $$?="enter your username:" $+ / $+ %net $+ : $+ $$?="enter your password:"
  ..192.168.0.17 +6697 : /proxy off | var %net = $iif(($network),$network,$$?="enter network name:") | /server 192.168.0.17:+6697 $$?="enter your username:" $+ / $+ %net $+ : $+ $$?="enter your password:"

  ; command history
  ;.xcdcc send #899 : /msg [MG]-MISC|EU|S|RandomPunk xdcc send #899

}
alias -l identify_here_popup {
  if ($bool_using_proxy != $true) { return }
  if ($varname_global(identify-chanserv,$+($chan,-,$$network)).value == $chan) { return identify here }
}
alias -l identify_chans_popup {
  if ($1 == begin) { return }
  if ($1 == end) { return }
  var %chan = $var($varname_global(identify-chanserv,$+(*,-,$$network)),$1)
  %chan = [ [ %chan ] ]
  if (%chan == $null) && ($1 == 1) { return no channels : eecho you have not identified as founder of channel(s) on this network ( $+ $network $+ ). $chr(124) eecho after you identify as an founder your channel will be listed in the menu. }
  return %chan : /bnc_msg identify-chanserv %chan
}
on *:quit: {
  if ($nick == $me) { set $varname(trio_ircproxy.py,active) $false }
}
alias status_usenick_pop {
  if (!$varname_cid(trio-ircproxy.py,active).value) { return $style(2) }
  if ($varname_glob(status-nick,none).value == $1) { return $style(1) }
}
alias bool_using_proxy {
  if ($varname_cid(trio-ircproxy.py,active).value) { return $true }
  return $false
}
alias style_proxy {
  if (!$varname_cid(trio-ircproxy.py,active).value) { return $style(2) }
}
on *:text:*:?status: {
  if (!$is_status_nick) { return }
  tokenize 32 $strip($1-)
  if (status-nick == $1) { set $varname_glob(status-nick,none) $nick }
  if (!$is_status) { return }
  if ($1- == Trio-ircproxy.py active/running for this connection) { set $varname_cid(trio-ircproxy.py, active) $true }
  if ($1- == you are logged-in as Administrator) { set $varname_cid(trio-ircproxy.py, admin) $true }
  if ($4 != $null) && (*your username is ??* iswm $1-4) { set $varname_cid(trio-ircproxy.py, is_user) $4 }
  if ($1 == admin-nick) { set $varname_glob(admin-nick,none) $$2 }
  if ($1 == admin-smtp-email) { set $varname_glob(admin-smtp-email,none) $$2 }
  if ($1 == admin-smtp-hostname) { set $varname_glob(admin-smtp-hostname,none) $$2 }
  if ($1 == admin-smtp-server-name) { set $varname_glob(admin-server-name,none) $$2 }
  if ($1 == admin-smtp-user) { set $varname_glob(admin-smtp-user,none) $$2 }
  if ($1 == admin-smtp-password) { set $varname_glob(admin-smtp-password,none) $$2 }
  if (status-history-freeze-everywhere == $1) && ($2 isin $true$false) { set $varname_glob(status-history-freeze,everywhere) $$2 }
  if (status-history-freeze == $1) && (#* iswm $2) { set $varname_glob(status-history-freeze,$2) $$3 }
  if (status-history-clear == $1) && ($3 isin $true$false) { set $varname_glob(status-history-clear,$2) $$3 }
  if (status-history-clear-everywhere == $1) && ($2 isin $true$false) { set $varname_glob(status-history-clear,everywhere) $$2 }
  if (say-away == $1) && ($2 isin $true$false) { set $varname_glob(say-away,none) $2 }
  if (operscan-join == $1) && ($2 isin $true$false) { set $varname_glob(operscan-join,none) $2 }
  if ($1 == use-ports) { set $varname_global(use-port,proxy) $2 | set $varname_global(use-port,http) $3 }
  if ($1 == identify-chanserv) {
    var %i = 2
    var %chan = $ [ $+ [ %i ] ]
    while (%chan) {
      set $varname_global(identify-chanserv,$+(%chan,-,$$network)) %chan
      inc %i
      var %chan = $ [ $+ [ %i ] ]
    }
  }
  if ($1 == identify-nick) { return }
}
alias -l popup-identify-founder-list {
  if ($bool_using_proxy == $false) {  return $style(2) identify as &founder  }
  var %chan = $var($varname_global(identify-chanserv,$+(*,-,$$network)),1)
  var %chan = [ [ %chan ] ]
  if (%chan) { return identify as &founder }

}
alias true$false {
  return $true $+ $false
}
alias is_status_nick {
  ;check is active nick is either one of the two status nicks available.
  ;;

  if ($1) { var %nick = $1 }
  elseif ($nick != $null) { var %nick = $nick }
  if ($chr(42) $+ status != %nick) && (~status != %nick) { return $false }
  return $true
}
alias is_status {
  ; Checks if active nick == satus-nick
  ;;

  if ($1 != $null) { var %nick = $1 }
  elseif ($nick != $null) { var %nick = $nick }
  else { return $false }
  if ($varname_glob(status-nick,none).value == %nick) { return $true }
  else { return $false }
}
menu menubar {
  $iif((!$var(%bde_glob_*history*,0)),$style(2)) erase history : unset %bde_glob_*history* | eecho you have erased your history.
  $iif(($os isin 7,10,11),&set client faster) : eecho changed priority of all running $nopath($mircexe) and python.exe apps to 'High' | run -hn wmic process where name=" $+ $nopath($mircexe) $+ " CALL setpriority 128 | run -hn wmic process where name="python.exe" CALL setpriority 128

}
on *:input:$chan: {
  if (*?> $chr(35) $+ ?* !iswm $1-) { return }
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
  listen ip : script_info -listen
  listen port : script_info -port
}
alias bnc_msg {
  if (!$varname_glob(status-nick,none).value) { return }
  if ($bool_using_proxy != $true) { return }
  if ($strip($1) == $null) { return }
  if ($silence) { .msg $varname_glob(status-nick,none).value $1- }
  else { msg $varname_glob(status-nick,none).value $1- }
}
