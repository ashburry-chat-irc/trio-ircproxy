#!/usr/bin/python
# -*- coding: utf-8 -*-
from __future__ import annotations
from typing import Optional, Union
from pathlib import Path
import trio
import os
user_file_str: str = os.path.join('.', 'scripts', 'website_and_proxy', 'users.dat')
user_file = Path(user_file_str)

def sc_send(sc_socket: trio.SocketStream | trio.SSLStream, msg: Union[str, bytes]) -> None:
    from scripts.trio_ircproxy.socket_data import SocketData
    """Relay text to client
    """
    if not sc_socket:
        return
    if not isinstance(msg, bytes):
        msg = msg.encode("utf8", errors="replace")
    msg = msg.strip()
    msg = msg + b"\n"
    try:
        send_buffer = SocketData.send_buffer[sc_socket]
    except KeyError:
        return
    send_buffer.append(msg)


async def send_quit(sc_socket):
    from scripts.trio_ircproxy.socket_data import SocketData
    """Replace the quitmsg"""
    if not sc_socket:
        return

    print('send quit: ' + SocketData.which_socket[sc_socket])
    if SocketData.which_socket[sc_socket] == 'cs':
        client_socket = sc_socket
        try:
            other_socket = SocketData.mysockets[sc_socket]
        except KeyError:
            return
    else:
        other_socket = sc_socket
        try:
            client_socket = SocketData.mysockets[sc_socket]
        except KeyError:
            return
    sc_send(other_socket, quitmsg())
    sc_send(client_socket, quitmsg(to=client_socket))
    await trio.sleep(2)
    await aclose_sockets(sockets=(other_socket, client_socket))




def send_ping(sc_socket: trio.SocketStream | trio.SSLStream, msg: str = ':TIMEOUTCHECK') -> None:
    if len(msg) == 0:
        msg = ':'
    if msg[0] != ':':
        msg = ':' + msg
    sc_send(sc_socket, str('PING ' + msg).strip())


def quitmsg(msg: Optional[str] = None, to: Optional[socket] = None) -> Optional[str]:
    """The default quit message for the app"""
    from scripts.trio_ircproxy.socket_data import SocketData
    if not msg:
        # Send to server
        msg = "\x02trio-ircproxy.py\x02 from \x1fhttps://ashburry.pythonanywhere.com\x1f"
    msg = "QUIT :" + msg
    if to:
        # Send to client
        if SocketData.mynick[to]:
            msg = ':' + SocketData.mynick[to] + "!identd@ashburry.pythonanywhere.com " + msg
            print(" MY NICK IS : " + SocketData.mynick[to])
        else:
            return ''
    return msg


async def aclose_sockets(sockets=None) -> None:
    """Takes a list of sockets and closes them

        vars:
            :param sockets: a list of sockets to close
            :returns: None
    """
    if not sockets:
        return
    for sock in sockets:
        if not sock:
            continue
        try:
            await sock.aclose()
        except (AttributeError, OSError, BrokenPipeError):
            return



