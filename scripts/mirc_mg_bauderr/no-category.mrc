on *:start: {
  set $varname_cid(status-name) $+($r(a,z),$r(a,z),$r(a,z),$r(a,z),$r(a,z),$r(a,z),$r(a,z))
}
on *:active:*: {
  if (!$varname_cid(status-name).value) {
    set $varname_cid(status-name) $+($r(a,z),$r(a,z),$r(a,z),$r(a,z),$r(a,z),$r(a,z),$r(a,z))
  }
}

on *:start: {
  bde_start
}
alias bde_start {
  !.menubar on
  !.treebar on
  if ($vol(master) > 32767) { !.vol -u2v 32767 }
  if ($vol(master) < 9880) { !.vol -u2v 9880 }
  dcc maxcps $calc(1024 * 1024 * 12)
  .speak -lu Welcome
}
alias qw {
  var %text = $1
  while ($left(%text,1) isin '"`) { %text = $right(%text,-1) }
  while ($right(%text,1) isin '"`) { %text = $left(%text,-1) }
  return " $+ %text $+ "
}
on *:privmsg:*:* $+ $chr(42) $+ status: {
  tokenize 32 $strip($1-)
  if (Trio-ircproxy.py active* iswm $1-) { set $varname_cid(trio-ircproxy.py,active) $true }
}
on *:connect: {
  .localinfo -u
}
alias eecho {
  echo -s 54,93Bauderr : $$1-
  if ($active == Status Window) { return }
  if (@* iswm $active) { return }
  echo -a 54,93Bauderr : $$1-
}
alias varname_cid {
  ; to the connection id only
  var %varname = $+(%,bde_cid_,$1,!,$iif(($2 == $null),blank,$2),$chr(35),$activecid)
  if ($prop == value) { return [ [ %varname ] ] }
  return %varname
}
alias varname_network {
  var %varname = $+(%,bde_net_,$1,!,$iif(($2 == $null),blank,$2),&,$network)
  if ($prop == value) { return [ [ %varname) ] ] }
  return %varname
}
alias varname_global {
  var %varname = $+(%,bde_glob_,$1,!,$iif(($2 == $null),blank,$2))
  if ($prop == value) { return [ [ %varname ] ] }
  return %varname
}
alias varname_glob {
  var %varname = $+(%,bde_glob_,$1,!,$iif(($2 == $null),blank,$2))
  if ($prop == value) { return [ [ %varname ] ] }
  return %varname
}
alias script_info {
  tokenize 32 $strip($1-)
  if (!$0) { return }
  window -c @script_info
  /window -aCDe0g0k0rw2dDo +tf @Script_Info -1 -1 630 300 
  /titlebar @script_info
  if ($1 == -cmd_history) { 
    titlebar @script_info - command history information
    aline @script_info 54,93Command History
    aline 52 @script_info -
    aline -p @script_info - The command history shows the previously entered commands in any input editbox in status, channel and query windows.
    aline -p @script_info The raw history remembers commands as they were entered; and is only useful when you use mSL identifiers in your command. Such as $!me or $!chan in the input text.
    aline -p @script_info The eval history remembers commands in their evaluated state. For example, if you type //mode $!me -i the evaluated input will replace $!me with your actual nickname at the time the //mode command was used.
    aline -p @script_info - 
  }
  elseif ($1 == -flood) {
    titlebar @script_info - flood protection information
    aline @script_info 54,93Flood Protection
    aline 52 @script_info -
    aline -p @script_info - Some people on IRC take pleasure in attacking other people by means of flood bots. These flood bots are used to send hundereds of ctcps, ctcp replies, messages, actions, DCC chat/sends, join/part (cycle flood), nick changing (nick flood) and topic flood (if channel mode is -t); with the purpose of causing an disconnection of the victim IRC connections; or just to trouble other IRC users.
    aline -p @script_info Channel flood protection protects the channel from people who are sending too many messages too quickly; by banning (+b) and kicking the flood bots out of the channel. Trio-ircproxy.py will not relay flooding messages, so there is no need to /ignore the flood bots while channel flood protection is turned ON. There is also an /silence command you may employ if you want to ignore all messages (only on supported networks). Ctcp Ping replies are adjusted for an delayed reply, since Trio-ircproxy.py may delay the reply; to wait for an possible flood attempt. An ping is used to check a persons connection latency.
    aline -p @script_info Personal flood protection protects just yourself, by ignoring and silencing any floods to your personal nickname. Changing your nickname does not solve the problem but rather opens you up to another attack called an nick collision. Ignoring is your only hope, and Trio-ircproxy.py will always ignore floods and notify you of who is flooding. Trio-ircproxy.py is careful to not block legit activity even after the person has flooded. Flood bots are added to an seperate akick/ignore/notify list from the normal control lists.  Services and channel modes will be skillfully employed to stop channel floods. For channels needing extra security, invite an irc oper to idle in the channel as an modeless channel user because their logs may help put a stop to future floods and takeovers.
    aline -p @script_info Trio-ircproxxy.py keeps an history of people who have flooded you or your channels, even while flood protection is off. This way, you will be notified when an abuser joins a channel or sends you a message. In order for a flood to be determined as a flood in history there must be more than one nickname involved.  Trio-ircproxy.py is very quick to receive IRC messages and will log all barred flood & takeover activity, so reports can be quickly made to interested irc opers.
    aline -p @script_info -
    sline $active 4
  }
  elseif ($1 == -identity) {
    titlebar @script_info - server identity information
    aline @script_info 54,93Server Identity
    aline 52 @script_info -
    aline -p @script_info - Your server requires an identity, that is to say, you MUST have an name for your machines web-server and bnc servers. Part of this identity is contact information including the nickname and email address of the server admin. 
    aline -p @script_info This is the email address where the public, if you choose, will email you if there are any problems or suggestions regarding your web and bnc servers. Your email will not be shared with the public only when people fill out the feedback form on the website, and checkmark Send to Admin, will you receive emails. There is an strict limit of how many emails a registered user may send using the form per 24 hour period.
    aline -p @script_info -
  }
  elseif ($1 == -listen) {
    titlebar @script_info - listen ip information
    aline @script_info 54,93Listen IP
    aline 52 @script_info -
    aline -p @script_info - The IP you choose to listen on can be decided by asking yourself one question. Are people, other than myself, going to use Trio-IrcProxy.py server, or am I going to use that server from more than one computer either in the same household or across the internet. If you answered 'yes' to any of those questions then you should listen on an global IP (0.0.0.0). If you are going to access your Trio-IrcProxy.py server 
    aline -p @script_info across the internet then you should configure your router/switch hardware to route incomming connections to your bounce server port to your bounce servers local IP (ip: 192.168.x.x) and port. If you are going to use the bounce server on your personal computer without any outside access from any computer on your local network or across the internet then choose local IP 127.0.0.1 (you will not need to configure your 
    aline -p @script_info router/switch hardware). If you want computers in your household network to be able to connect to the bounce server then you can use global IP (0.0.0.0) and not configuring your router; will block outside access to your bounce server. To connect to your IP use either 127.0.0.1 or your local IPv4 address, or your public IP.
    aline -p @script_info -
  }
  elseif ($1 == -port) {
    titlebar @script_info - listen ip information
    aline @script_info 54,93Listen Port
    aline 52 @script_info - All connections on the internet are to an IP address on an specific port number. In this case it is the IP of the machine running the Trio-IrcProxy.py and the port number that Trio-IrcProxy.py is listening on. On Windows any port number is okay. On Linux only the ports between 1024 and 5000 are usable to an normal-priviledged user. If you wish to use port 80 on Linux you must run the flask_app.py with sudo.
    aline -p @script_info - 

  }

}
alias /op /mode # +ooo $$1 $2 $3
alias /dop /mode # -ooo $$1 $2 $3
alias /j /join #$$1 $2-
alias /p /part #
alias /n /names #$$1
alias /w /whois $$1
alias /k /kick # $$1 $2-
alias /q /query $$1
alias /send /dcc send $1 $2-
alias /chat /dcc chat $1
alias  /ping /ctcp $$1 ping
alias /s /server $$1-
