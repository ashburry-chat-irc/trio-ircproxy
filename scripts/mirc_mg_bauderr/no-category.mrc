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
    aline -p @script_info - The raw history remembers commands as they were entered; and is only useful when you use mSL identifiers in your command. Such as $!me or $!chan in the input text.
    aline -p @script_info - The eval history remembers commands in their evaluated state. For example, if you type //mode $!me -i the evaluated input will replace $!me with your actual nickname at the time the //mode command was used.
    aline -p @script_info - 
  }
  elseif ($1 == -flood) {
    titlebar @script_info - flood protection information
    aline @script_info 54,93Flood Protection
    aline 52 @script_info -
    aline -p @script_info - Some people on IRC take pleasure in attacking other people by means of flood bots. These flood bots are used to send hundereds of ctcps, ctcp replies, messages, actions, DCC chat/sends, join/part (cycle flood), nick changing (nick flood) and topic flood (if channel mode is -t); with the purpose of causing an disconnection of the victim IRC connections; or just to trouble other IRC users.
    aline -p @script_info - Channel flood protection protects the channel from people who are sending too many messages too quickly; by banning (+b) and kicking the flood bots out of the channel. Trio-ircproxy.py will not relay flooding messages, so there is no need to /ignore the flood bots while channel flood protection is turned ON. There is also an /silence command you may employ if you want to ignore all messages (only on supported networks). Ctcp Ping replies are adjusted for an delayed reply, since Trio-ircproxy.py may delay the reply; to wait for an possible flood attempt. An ping is used to check a persons connection latency.
    aline -p @script_info - Personal flood protection protects just yourself, by ignoring and silencing any floods to your personal nickname. Changing your nickname does not solve the problem but rather opens you up to another attack called an nick collision. Ignoring is your only hope, and Trio-ircproxy.py will always ignore floods and notify you of who is flooding. Trio-ircproxy.py is careful to not block legit activity even after the person has flooded. Flood bots are added to an seperate akick/ignore/notify list from the normal control lists.  Services and channel modes will be skillfully employed to stop channel floods. For channels needing extra security, invite an irc oper to idle in the channel as an modeless channel user because their logs may help put a stop to future floods and takeovers.
    aline -p @script_info - Trio-ircproxxy.py keeps an history of people who have flooded you or your channels, even while flood protection is off. This way, you will be notified when an abuser joins a channel or sends you a message. In order for a flood to be determined as a flood in history there must be more than one nickname involved.  Trio-ircproxy.py is very quick to receive IRC messages and will log all barred flood & takeover activity, so reports can be quickly made to interested irc opers.
    aline -p @script_info -
    sline $active 4
  }
  elseif ($1 == -register) {
    titlebar @script_info - register ip information
    aline @script_info 54,93Register IP
    aline 52 @script_info -
    aline -p @script_info - To register an IP address is to run an bnc server on that host and include the IP on the list of bounce servers for your network. 
    aline -p @script_info - The register command will only host a bnc on the default host for your machine. You may add IP addresses wih the add ip address menu item.
    aline -p @script_info - 
  }
  elseif ($1 == -links) {
    titlebar @script_info - server link information
    aline @script_info 54,93Server Link (merge)
    aline 52 @script_info -
    aline -p @script_info - You may merge your bounce servers with another persons bounce service or they may merge with yours. It is possible to change your merge login but it is not recommended to do so, try to share your merge login with trusted admins only. You must be sharing an public facing IP address in order to provide any service to an merge. Read the sticker on your router hardware and login to setup an static IP for your MAC addresses and port forwarding for your service ports to your static IP address. You may host the web-server on port 5000 but then do an port forward on port 80 to your static IP on port 5000, if you wish. Every computer on your network will need different ports configured if they are deployed as servers.
    aline -p @script_info - You only share your machines service with your merged links. None of your merged servers will be sharing their bounce servers with your other merged servers. You will need to merge, directly, with every server in your potential network. The person hosting the merged connection will keep their users file, duplicate user names will be replaced by the hosted connections users file. So if you do the merge, your users file may end up with some replaced passwords (if there are duplicate usernames within the two servers). Your servers have an identity which you may configure if you choose, the identity encompasses just your machine's website and your machine's bounce servers. No two merged servers can have the same server name, merged machines must have different server names. If you are hosting just a website, on say PythonAnywhere.com, then you may configure your machine to use an remote webserver; in this case it is part of your machines identity, any remote machine may share, and MUST share, identity with the remote webserver. Only ONE machine may use any one remote web-server--merged servers are shared with remote web-servers. The remote web-server may also host bounce servers as part of the same server name as your local machine.
    aline -p @script_info -
    sline @script_info 4
  }
  elseif ($1 == -identity) {
    titlebar @script_info - server identity information
    aline @script_info 54,93Server Identity
    aline 52 @script_info -
    aline -p @script_info - Your server requires an identity, that is to say, you MUST have an name for your machines web-server and bnc servers. Part of this identity is contact information including the nickname and email address of the server admin. This is the email address where the public, if you choose, will email you if there are any problems or suggestions regarding your web and bnc servers. Your email will not be shared with the public only when people fill out the feedback form on the website, and checkmark Send to Admin, will you receive emails. There is an strict limit of how many emails a registered user may send using the form per 24 hour period.
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
