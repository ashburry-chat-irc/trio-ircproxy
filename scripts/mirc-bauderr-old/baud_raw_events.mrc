on *:signal:baud_unload: {
  !.timer -m 1 220 /unload -rs $qt($script)
}
on *:input:*: {
  if (@* iswm $active) { return }
}
alias silence_nicks {
  if ($0 == 0) { !.raw silence | return }
  tokenize 32 $replace($1-,$comma,$chr(32))
  if ($1 == $null) { .raw silence | return }
  var %i = 0,%item,%items
  :loop
  !inc %i
  if (%i > $0) { goto end }
  %item = $ [ $+ [ %i ] ]
  if (%item == $null) { goto loop }
  if ($left(%item,1) !isin -+) { %items = %items + $+ %item }
  else { %items = %items %item }
  goto loop
  :end
  %items = $replace(%items,$chr(32),$comma)
  !.raw silence %items
}

raw silence:*: {
  haltdef
  gecho -sa-e-notime 29Silence Update: $1
  if (!$getvar_cid(silence-copy,blank)) { goto fresh }
  tokenize 44 $1
  var %i = 0
  :loop
  inc %i
  var %item = $ [ $+ [ %i ] ]
  if (!%item) { goto done }
  if ($left(%item,1) == +) { varset_cid silence-copy blank $getvar_cid(silence-copy,blank) $right(%item,-1) }
  if ($left(%item,1) == -) { 
    var %list = $getvar_cid(silence-copy,blank)
    varset_cid silence-copy blank $deltok(%list,$findtok(%list,$right(%item,-1),32),32) 
  }
  goto loop
  :fresh
  varset_cid quiet_silence blank $true
  .timerquiet_silence_exec_ $+ $cid -om 1 1500 /unset $+(%,*quiet_silence*,$cid)
  :done
}
on *:close:status window: {
  .timer*_exec_ $+ $cid -e
  .timer*_ $+ $cid off
}
raw *:*: {
  if ($numeric == 5) {
    tokenize 32 $2-
    var %i = 0
    :loop
    inc %i
    var -n %item = $ [ $+ [ %i ] ]
    if (%item === $lower(%item)) || (%item == $null) { return }
    if (!%item) { goto loop }
    if (= isin %item) { var -n %parm = $gettok(%item,1,61) | var -n %value = $gettok(%item,2,61) }
    else { var -n %parm = %item | var -n %value = $true }
    varset_cid 005 %parm %value
    goto loop
  }
  elseif ($numeric == 271) {
    if (!$getvar_cid(005,silence)) { return }
    haltdef
    %item = $3
    .timerquiet_silence_exec_ $+ $cid -om 1 1500 /unset $+(%,*quiet_silence*,$cid)
    varset_cid silence-list blank $getvar_cid(silence-list,blank) %item
  }
  elseif ($numeric == 272) {
    if (!$getvar_cid(005,silence)) { return }
    haltdef
    var %list = $getvar_cid(silence-list,blank)
    if (%list) { varset_cid silence-copy blank %list }
    unset $+(%,*silence-list*,$cid)
    if ($is_on_off($getvar_cid(quiet_silence)).$false == 1) { goto quit }
    if ($getvar_cid(silence-copy,blank) == $null) { 
      gecho -sa-notime 29Silence list is empty
      goto quit 
    }
    linesep -sa
    echo 41 -sa * Silence List [29 $+ $calc($getvar_cid(005,silence) - $token($getvar_cid(silence-copy,blank),0,32)) of $getvar_cid(005,silence) $+ ]:     
    var %i = 0
    :loop
    inc %i
    if (%i > $iif(($token($getvar_cid(silence-copy,blank),0,32) > 0),$ifmatch,1)) { goto end }
    echo 41 -sa : %i $+ .29 $gettok($getvar_cid(silence-copy,blank),%i,32)
    goto loop
    :end
    if ($getvar_cid(silence-copy,blank) != $null) { linesep -sa | echo 41 -sa * Use 29/silence -* to clear the list }
    echo 41 -sa * End of Silence List
    linesep -sa
    :quit
    .timerquiet_silence_exec_ $+ $cid -e
    unset $+(%,*quiet_silence*,$cid)
  }
  else { ;echo 4 >> $numeric >> $1- }
}

; End of File
