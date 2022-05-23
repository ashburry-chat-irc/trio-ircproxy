#!/usr/bin/python
# -*- coding: utf-8 -*-
from __future__ import annotations
import trio
from random import randint
from collections import deque
from typing import Optional, Dict, Deque, Set, Union
import sys
import os
from system_data import SystemData as system_data

from socket import gaierror


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
            with trio.move_on_after(6):
                await sock.aclose()
                try:
                    del socket_data.mysockets[sock]
                except KeyError:
                    pass
        except (trio.TooSlowError, Exception):
            return


class SocketData:
    send_buffer: Dict[trio.SocketStream | trio.SSLStream, Deque[Union[str, bytes]]] = dict()
    mynick: Dict[trio.SocketStream | trio.SSLStream, str] = dict()
    myial: Dict[trio.SocketStream | trio.SSLStream, Dict[str, str]] = dict()
    myial_chan: Dict[trio.SocketStream | trio.SSLStream, Dict[str, str]] = dict()
    mychans: Dict[trio.SocketStream | trio.SSLStream, Set[str]] = dict()
    mysockets: Dict[trio.SocketStream | trio.SSLStream, trio.SocketStream | trio.SSLStream] = dict()
    raw_005: Dict[trio.SocketStream | trio.SSLStream, Dict[str, Union[str, int]]] = dict()
    dcc_send: Dict[trio.SocketStream | trio.SSLStream, Dict[str, str]] = dict()
    dcc_chat: Dict[trio.SocketStream | trio.SSLStream, Dict[str, str]] = dict()
    dcc_null: Dict[trio.SocketStream | trio.SSLStream, bool] = dict()
    conn_timeout: Dict[trio.SocketStream | trio.SSLStream, Optional[int]] = dict()
    state: Dict[trio.SocketStream | trio.SSLStream, Dict[str, str | int | Set[str]]] = dict()
    login: Dict[trio.SocketStream | trio.SSLStream, str | bool] = dict()
    hostname: Dict[trio.SocketStream | trio.SSLStream, str] = dict()
    which_socket: Dict[trio.SocketStream | trio.SSLStream, str] = dict()
    user_power: dict[str, list[trio.SocketStream | trio.SSLStream]] = dict()

    @classmethod
    def create_data(cls, client_socket: trio.SocketStream | trio.SSLStream,
                    server_socket: trio.SocketStream | trio.SSLStream):
        """Create socket data,
          ...  put all data into one location
        """
        cls.which_socket[client_socket] = 'cs'
        cls.which_socket[server_socket] = 'ss'
        cls.login[client_socket] = ''
        cls.conn_timeout[client_socket] = None
        cls.conn_timeout[server_socket] = None
        cls.mysockets[client_socket] = server_socket
        cls.mysockets[server_socket] = client_socket
        cls.dcc_chat[client_socket] = dict()
        cls.dcc_chat[server_socket] = dict()
        cls.dcc_send[server_socket] = {}
        cls.dcc_send[client_socket] = {}
        cls.dcc_null[client_socket] = True
        cls.dcc_null[server_socket] = True
        cls.myial[client_socket] = {}
        cls.myial_chan[client_socket] = {}
        cls.mychans[client_socket] = set([])
        cls.mynick[client_socket] = "no_nick"
        cls.raw_005[client_socket] = {}
        cls.raw_005[client_socket]["statusmsg"] = "+@"
        cls.raw_005[client_socket]["chantypes"] = "#"
        cls.raw_005[client_socket]["modes"] = 4
        cls.raw_005[client_socket]["channellen"] = 50
        cls.raw_005[client_socket]["topiclen"] = 390
        cls.raw_005[client_socket]["watch"] = 60
        cls.raw_005[client_socket]["awaylen"] = 180
        cls.raw_005[client_socket]["nicklen"] = 30
        cls.raw_005[client_socket]["prefix"] = "(ov)@+"
        cls.raw_005[client_socket]["chanlimit"] = "#:250"
        cls.raw_005[client_socket]["kicklen"] = 180
        cls.raw_005[client_socket]["maxtargets"] = 4
        cls.raw_005[client_socket]["maxlist"] = "bie:250"
        cls.raw_005[client_socket]["chanmodes"] = "b,k,l,psnmt"
        cls.raw_005[client_socket]["network"] = "no_network_" + str(randint(100, 9999))
        cls.send_buffer[server_socket] = deque()
        cls.send_buffer[client_socket] = deque()
        cls.state[client_socket] = dict()
        cls.state[client_socket]['face_nicknet'] = '[' + 'client_socket' + ']'
        cls.state[client_socket]['connected'] = 0
        cls.state[client_socket]['doing'] = 'connecting'
        cls.state[client_socket]['upper_nick'] = ''
        cls.state[client_socket]['new_user_authors'] = set()
        cls.state[client_socket]['motd_def'] = 0 if system_data.Settings_json['settings']['skip_motd'].lower() in \
                                                    ('yes', 'on', 'y', 1) else 1

    @classmethod
    async def raw_send(cls, to_socket: trio.SocketStream | trio.SSLStream,
                       other_socket: trio.SocketStream | trio.SSLStream | None, msg: str | bytes) -> bool:
        with trio.fail_after(25):
            try:
                await to_socket.send_all(bytes(msg))
            except (
                    trio.BrokenResourceError, trio.ClosedResourceError, gaierror, trio.TooSlowError,
                    trio.BusyResourceError):
                await aclose_sockets(sockets=(to_socket, other_socket))
                return False
            return True

    @classmethod
    def set_face_nicknet(cls, client_socket: trio.SocketStream | trio.SSLStream) -> None:
        face: str
        if client_socket not in cls.state or not cls.state[client_socket]['upper_nick']:
            face = '[' + 'client_socket' + ']'
        else:
            nick: str = cls.state[client_socket]['upper_nick']
            net: str = cls.raw_005[client_socket]['network']
            face = '[' + nick + '/' + net + ']'
        cls.state[client_socket]['face_nicknet'] = face
        return None

    @classmethod
    def echo(cls, client_socket, msg: str) -> None:
        if client_socket not in cls.state:
            face: str = '[' + cls.hostname[client_socket] + '] '
            print(face + msg)
        else:
            print(cls.state[client_socket]['face_nicknet'] + ' ' + msg)

    @classmethod
    def msg(cls, client_socket: trio.SocketStream | trio.SSLStream, msg: str):
        mynick = cls.mynick[client_socket]
        msg = system_data.Settings_json['settings']['status_nick'] + ' ' + 'privmsg' + ' ' + mynick + ' ' + msg
        cls.send_buffer[client_socket].append(msg)

    @classmethod
    def clear_data(cls, xxs):
        """Remove the client_socket and server_socket from
        the dictionaries which they reside
        """

        if xxs is None:
            return
        try:
            other = cls.mysockets[xxs]
        except KeyError:
            other = None
        print('clear_data: clearing...')
        try:
            if cls.which_socket[xxs] == "cs":
                client_socket = xxs
                server_socket = other
            else:
                server_socket = xxs
                client_socket = other
        except KeyError:
            try:
                if cls.which_socket[other] == "cs":
                    server_socket = xxs
                    client_socket = other
                else:
                    client_socket = xxs
                    server_socket = other
            except KeyError:
                return
        del xxs
        for power in cls.user_power:
            try:
                cls.user_power[power].remove(client_socket)
            except ValueError:
                continue
        try:
            del cls.hostname[client_socket]
            del cls.which_socket[client_socket]
            del cls.which_socket[server_socket]
        except (KeyError, AttributeError):
            pass
        try:
            del cls.mychans[client_socket]
        except KeyError:
            pass
        try:
            del cls.dcc_null[server_socket]
            del cls.dcc_null[client_socket]
        except KeyError:
            pass
        try:
            del cls.mynick[client_socket]
        except KeyError:
            pass
        try:
            del cls.mysockets[client_socket]
            del cls.mysockets[server_socket]
        except KeyError:
            pass
        try:
            del cls.raw_005[client_socket]
        except KeyError:
            pass
        try:
            del cls.myial[client_socket]
        except KeyError:
            pass

        try:
            if client_socket:
                del cls.send_buffer[client_socket]
            if server_socket:
                del cls.send_buffer[server_socket]
        except KeyError:
            pass
        try:
            if client_socket:
                del cls.dcc_send[client_socket]
                del cls.dcc_chat[client_socket]
        except KeyError:
            pass
        try:
            if server_socket:
                del cls.dcc_send[server_socket]
                del cls.dcc_chat[server_socket]
        except KeyError:
            pass
        try:
            if client_socket:
                del cls.myial_chan[client_socket]
        except KeyError:
            pass
        try:
            if client_socket:
                del cls.state[client_socket]
        except KeyError:
            pass
