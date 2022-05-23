on *:signal:baud_unload: {
  !.timer -m 1 220 /unload -rs $qw($script)
}
alias pop_config_Preset_list {
  return $me ! nickname
}
raw 321:*: {
  set %chan_count 0
  set %time $ctime
}
raw 322:*: {
  set %chan_count $calc(%chan_count + 1)
}
raw 323:*: {
  var %new_time = $calc($ctime - %time)
  echo -s It took mirc $duration(%new_time) to list %chan_count channels.
}
alias bdr_version_numbers return 5ioE.3
alias qw {
  ; $qw(text)
  ; Adds quotations to text
  ; Removes all quotes incase the they are intertwined.
  ;  
  var %text = $1
  while ($left(%text,1) isin '"`) { %text = $right(%text,-1) }
  while ($right(%text,1) isin '"`) { %text = $left(%text,-1) }
  %text = " $+ %text
  %text = %text $+ "
  return %text
}
on *:signal:bauderr_startup: {
  varset_global list-setup-names counting $!default Ash+Defaults
  if ($is_on_off($getvar_global(startup-adjust-volume)).off == 1) { vol -u2v 45000 }
  !.sound on
  !.pdcc on
  !.dcc packetsize 16384
  !.fsend on
}
alias comma {
  return ,
}

on *:NOSOUND: {
  ; uses cprivmsg to avoid target change limits for chan ops
  if ($getvar_cid(nosound-noflood,blank) > 5) { return }
  var %file = ! $+ $nick $noqt($filename)
  inc -u13 $varname_cid(nosound-noflood,blank) 1
  if ($getvar_cid(005,cprivmsg)) {
    var %cop = $comchan_op($nick)
    if (%cop == $null) { msg $nick %file | return }
  }
  cprivmsg $nick $chan %file
}
on *:sendfail:*: {
  .timer -moi 1 1234 /scid -a /close -is
}
on ^*:text:$(! $+ $me *?.???):?: {
  $+(.timersound_req_,$left($nick,8),_net_,$left($network,8)) -m 1 1345 /sound_req $nick $2-
  haltdef
}
alias is_sent_file {
  ; $is_send_file(nickname,filename)
  var %i = $send($1,0),%file,%status
  :loop
  if (%i <= 0) { return $false }
  %file = $send($1,%i).file
  if (%file != $2) { dec %i | goto loop }
  %status = $send($1,%i).status
  if (%status == active) { return $true }
  if (%status == waiting) { return $true }
  var %done = $send($1,%i).done
  if (%done == $true) { return $true }
  if (%status == inactive) { return $false }
  dec %i
  goto loop
}
alias -l sound_req {
  ; ex. /sound_req <nick> <file name>
  if (!$sound($2-)) { return }
  var -n %sound = $nopath($noqt($2-))
  var -n %sound = $remove(%sound,\,/)
  if ($len(%sound) >= 100) { return }
  while (.* iswm %sound) {
    var -n %sound = $right(%sound,-1)
  }
  if (!%sound) { return }
  var -n %sound_file = $qw($findfile($sound($2-),%sound,1))
  if (%sound_file == "") { return }
  if ($is_sent_file($1,%sound_file) == $true) { return }
  dcc send $1 %sound_file

}
alias comchan_op {
  var %i = $comchan($1,0)
  :loop
  if (%i <= 0) { return }
  if ($me !isop $comchan($1,%i)) { dec %i | goto loop }
  else { return $comchan($1,%i) }
}
alias strip_all {
  var -n %text = $1-
  if ($prop == hy) { %text = $strip_hy(%text) }
  %text = $remove($strip_some(%text),<,>,$chr(123),$chr(125),[,],`,",',:,/,\,|,$chr(44))
  return %text
}
alias strip_some {
  var -n %text = $1-
  if ($prop == hy) { %text = $strip_hy(%text) }
  %text = $remove(%text,@,#,$,%,&,*,!,^,=,?,+)
  return %text
}

alias strip_hy {
  ;description: replaces duplicate hyphen, underscore (__) and spaces with single hyphen
  var -n %text = $1-
  %text = $replace(%text,$str($chr(32),2),$chr(32),_,-,--,-,- $+ $chr(32),-,$chr(32) $+ -,-,--,-)
  while (-- isin %text) || ($str($chr(32),2) isin %text) || ($chr(32) $+ - isin %text) || (- $+ $chr(32) isin %text) {
    %text = $replace(%text,$str($chr(32),2),$chr(32),_,-,--,-,- $+ $chr(32),-,$chr(32) $+ -,-,--,-)
  }
  return %text
}
alias exec_alias_network {
  var %i = 0
  :loop
  inc %i
  if ($scon(%i)) { 
    if ($scon(%i).$network == $1) { /scon -t1 %i $2- }
  }
  else { return }
  goto loop
}
;@ = global # = cid & = network = is setup
alias varname_global {
  return $+(%,bde_glob_,$1,!,$iif(($2 == $null),blank,$2),@,$iif(($3 == $null),blank,$3))
}
alias varname_cid {
  ; to the connection id only
  return $+(%,bde_cid_,$1,!,$iif(($2 == $null),blank,$2),$chr(35),$activecid)
}
alias varname_network {
  return $+(%,bde_net_,$1,!,$iif(($2 == $null),blank,$2),&,$network)
}
alias varname_setup {
  return $+(%,bde_setup_,$1,!,$iif(($2 == $null),blank,$2),=,$active_setup_id)
}
alias active_setup {
  return $getvar_cid(active-setup,blank)
}
; #####
;  CHANGE $getvar_* TO EVALUATE RESULT OR RETURN $prop
;
; #####
alias getvar_global {
  var %value = [ [ $varname_global($1,$2,$3) ] ]
  if (%value == $null) { return $prop }
  return [ [ %value ] ]
}
alias getvar_cid {
  return [ [ $varname_cid($1,$2) ] ]
}
alias getvar_network {
  return [ [ $varname_network($1,$2) ] ]
}
alias getvar_setup {
  return [ [ $varname_setup($1,$2,$active_setup) ] ]
}
alias varset_global {
  set -ngp $varname_global($1,$2,$3) $4-
}
alias setvar_global varset_global $1-
alias setvar_cid varset_cid $1-
alias setvar_set varset_setup $1-
alias setvar_network varset_network $1-

alias varset_cid {
  set -ngep $varname_cid($1,$2) $3-
}
alias varset_network {
  set -ngp $varname_network($1,$2) $3-
}
alias varset_setup {
  set -ngp $varname_setup($1,$2) $3-
}
alias config_saveas_net {
  var %i = 1
  var %setname = $network @ network
  :loop
  $var(bde_*_

}
alias config_new {
  ; $config_new(setup-name)
  var %i = 1
  :loop
  %set = $getvar_global(config-list,%i,blank)
  if (%i > 12) || (%set == $1) { goto save }
  goto loop
  :save
  var %bde_*!*#1

}
on *:open:status window: {
  ; ######
  ; load the defaults setup instead of $default
  ;
  ; ######
  varset_cid active-setup-cid blank $default
}
alias active_setup_name {
  var %ac = $getvar_cid(active-setup-cid,blank)
  if (%ac == $null) { varset_cid active-setup-cid blank $default | return $default }
  return %ac
}
alias active_setup_name {
  var %cid = $active_setup_cid
  var %count = $active_setup_cid
  return  [ [ $getvar_global(list-setup-names,counting,%count) ] ]
}
alias active_setup_cid {
  ; returns the setup number for saving as.
  var %active_setup = $getvar_cid(active-setup,blank)
  if (%active_setup == $null) {
    varset_cid active-setup blank $default
    return $default
  }
  return [ [ %active_setup ] ]
}
alias -l max_setups_hard_limit return 13

alias add_new_setup {
  ; /add_new_setup My Setup OR    guest* ! nickname    OR network @ Undernet

  tokenize 32 $strip_all($1-).hy
  if (!$1) { gecho -sa-e invalid setup name for configurations. | return }
  var %free,%i = $max_setups_hard_limit
  :loop
  dec %i
  if (%i == 0) {
    if (!%free) {
      gecho -sa-e problem: you have too many configurations ( $+ $max_setups_hard_limit files). erase one then try to save, $&
        or overwrite an existing configuration.
      return
    }
    varset_global list-setup-names counting %free $1-
    return
  }
  var %cur = $getvar_global(list-setup-names,counting,%i)
  if (!%cur) { %free = %i | goto loop }
  if (%cur == $1-) { gecho -sa-e /add_new_setup : error, that config name is already existing. | return }
  goto loop
}
alias default_setup_name {
  varset_global list-setup-names counting $default Ash+Defaults
  return Ash+Defaults
}
alias load_setup_name {
  ; load from text file
  ; ex. /load_setup_name Ash+Defaults

  if ($1 == $default) || ($1 == $default_setup_name) {
    gecho -sa-e loaded setup: $1
    varset_cid active-setup blank $default  
  }
  var %ii = $max_setups_hard_limit
  :loop
  dec %ii
  if (%ii <= 0) {
    gecho -sa-e there is no configuration file with that name.
    return
  }
  if ($getvar_global(list-setup-names,counting,%ii) == $1-) {
    gecho -sa-e loaded setup: $1-
    varset_cid active-setup blank %ii
    return
  }
  goto loop

}
alias active_setup_id return $active_setup
alias save_load_setup_name {
  var %ii = $max_setups_hard_limit, %free = 0
  :loop
  dec %ii
  if (%ii <= 0) {
    if (!%free) {
      gecho -sa-e problem: you have too many configurations ( $+ $max_setups_hard_limit files). erase one then try to save, $&
        or overwrite an existing configuration.
      return
    }
    goto write
    return
  }
  var %name = $getvar_global(list-setup-names,counting,%ii)
  if (%name == $1-) { var %free = %ii | goto write }
  if (!%name) {
    var %free = %ii
  }
  goto loop
  :write
  varset_global list-setup-names counting %free $1-
  varset_cid active-setup blank %free
  gecho -sa-e created new setup file: $1-

}
;@ = global # = cid & = network = is setup
alias active_setup_name {
  return $active_setup
}
alias is_on_off {
  ; echo >> $is_on_off($getvar_cid(test,blank)).$default
  :start
  if ($1- == on) || (($1- isnum) && ($1- > 0)) || (ok* iswm $1) || (y == $1-) || (yes == $1-) || (enable == $1-) || ($1 == $true) $&
    || (enabled == $1-) || ($1- == allow) || ($1- == allowed) { return 1 }
  elseif ($1- == off) || ($1- == of) || (($1- isnum) && ($1- < 1)) || (no* iswm $1) || (n == $1-) || (disable == $1-) $&
    || ($1 == $false) || ($1 == halt) || (disabled == $1-) || ($1- == disallowed) || ($1- == disallow) { return 0 }
  else { if ($1 == $null) && ($prop != $null) { tokenize 32 $prop | goto start } }

}
alias bdr_describe {
  return is using Bauderr msl script. try .bauderr to receive your copy or download from https://ashburry.pythonanywhere.com/.
}

alias config_saveas {
  writeini -n $+(",$scriptdirconfiguration\,$1-,.conf") config name $1-
  var %i = 0
  :loop
  inc %i
  if (%i > 10) { gecho out of space! unable to save configuration | return }
  if ($getvar_global(config-list,%i,blank) == $1-) { goto done }
  if ($getvar_global(config-list,%i,blank) != $null) { goto loop }
  :done
  varset_global config-list %i blank $1-
  varset_cid cid-setup-using blank %i
  config_save
}
alias config_load {
  var %setup = $qw($scriptdirconfiguration\ $+ $active_setup_name $+ .conf)
  if (!$exists(%setup)) {
    gecho unable to load. configuration file $active_setup_name does not exist.
    return
  }
  var %var_name $ini(%setup,vars,1)
  var %var = $ini(%setup,vars,1)
  echo var : %var
  set -np [ [ %var ] ] $readini(%setup,vars,%var)
}
alias config_save {
  gecho -as saved config data to $+(",$active_setup_name,")
  writeini -n $+(",$scriptdirconfiguration\,$active_setup_name,.conf") config name $active_setup_name
  writeini -n $+(",$scriptdirconfiguration\,$active_setup_name,.conf") config author $pop_author_nobrace
  writeini -n $+(",$scriptdirconfiguration\,$active_setup_name,.conf") config short_version $bdr_version_short
  writeini -n $+(",$scriptdirconfiguration\,$active_setup_name,.conf") config version $bdr_version
  writeini -n $+(",$scriptdirconfiguration\,$active_setup_name,.conf") vars % $+ away_idle on

}
alias gecho {
  if ($left($1,1) == -) {
    if (s isin $1) && (a isin $1) && ($active != Status Window) { echo 41 -casn $+ $iif((-e isin $1),e) $+ $iif((-notime !isin $1),t) info $iif((h isin $1),-+,*) $2- | return }
    if (s isin $1) && (a isin $1) && ($active == Status Window) { echo 41 -csn $+ $iif((-e isin $1),e) $+ $iif((-notime !isin $1),t) info $iif((h isin $1),-+,*) $2- | return }

    if (s isin $1) { echo -csn $+ $iif((e isin $1),e) $+ $iif((-notime !isin $1),t) info $iif((h isin $1),-+,*) $2- }
    if (a isin $1) { echo -can $+ $iif((e isin $1),e) $+ $iif((-notime !isin $1),t) info $iif((h isin $1),-+,*) $2- }

  }
  else {

  }
}
alias wallchops {
  if ($1 == $null) { return }
  if (#* iswm $1) { %chan = $1 | %parms = $2- }
  else { var %chan = #, %parms = $1- }

  if (!%chan) || (!%parms) { goto syntax }
  if ($active == status window) { 
    echo -te -> @ $+ %chan $+ : %parms
  }
  else {
    echo -t -> @ $+ %chan $+ : %parms
  }
  .raw wallchops %chan : $+ %parms
  return
  :syntax
  gecho -sa syntax: /wallchops [#channel] <message>
}
