on *:signal:baud_unload: {
  !unload -rs $qt($script)
}

alias proxy_listen {
  socklisten -p proxy_server_listen 1080
}
on *:socklisten:proxy_server_listen: {
  :next
  var %sa = proxy_accept_ $+ $r(11111,999999)
  if ($sock(%sa)) { goto next }
  sockaccept %sa
  proxy_accepted $gettok(%sa,-1,$asc(_))
}
alias proxy_accepted {
  if ($1 !isnum) { return }
  sockopen proxy_ircserver_ $+ $1
}
on *:sockread:proxy_*_*: {
  var %sr
  if ($sockerr > 0) return
  :nextread
  sockread -n %sr
  if ($sockbr == 0) return
  if (%sr == $null) { goto mextread }
  proxy_sockread $sockname $proxy_getother_sn($sockname) %sr
  goto nextread
}
alias proxy_sockead {
  ; # sockname = $1 & sockwrite socket = $1
  ; #  sockread data is $3-
  ; # halt to prevent sockwrite
  if ($2 == 
  proxy_sockwrite $2 $3-
}
alias -l proxy_sockwrite {
  if (*_ircserver_* iswm $1) {
    if ($sock($1).status != connected) {
      write $1 $+ .txt $2-
      return
    }
  }
  if ($sock($1).status == connected) {
    sockwrite -n $1 $2-
  }
  else {
    ; # close sockets they're not connected.
    return
  }
}
on *:sockopen:proxy_ircserver_*: {
  if ($exists($proxy_buff_file($sockname))) {
    send_buff_file($sockname)
  }
}
alias send_buff_file {
  var %read = $read($proxy_buff_file($1),nt,4096)
  erase $proxy_buff_file($1)
  proxy_sockwrite $proxy_getother_sn($1) %read

}
alias proxy_buff_file {
  var %num = $gettok($1,-1,$asc(_))
  return $+(proxy_accept_,%num,.txt)
}
alias -l proxy_getother_sn {
  var %num = $gettok(%sa,-1,$asc(_))
  if (proxy_ircserver_* iswm $1) {
    return proxy_accept_ $+ %num
  }
  elif (proxy_accepted_* iswm $1) {
    return proxy_ircserver_ $+ %num
  }

}
