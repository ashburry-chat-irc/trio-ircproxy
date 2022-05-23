on *:socklisten:test.*: {
  if ($sockerr > 0) { echo error $sockname | return }
  sockaccept test.accept. $+ $r(100,99999)
}
on *:sockopen:test.*: {
  if ($sockerr > 0) { echo sockopen error: $sockname | return }
  echo >> sockopen : $sockname  
}
on *:sockclose:test.*: {
  echo >> sockclose : $sockname
}
