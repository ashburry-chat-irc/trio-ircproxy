#!/usr/bin/python
# -*- coding: utf-8 -*-
from __future__ import annotations
from typing import Dict, List
import trio
from scripts.website_and_proxy.system_data import SystemData as system_data
from .xdcc_link import XdccBotSLL
from .xdcc_link import XdccBot
from scripts.website_and_proxy.socket_data import SocketData as socket_data
from . import circular


def cs_send_notice(client_socket: trio.SSLStream | trio.SocketStream, msg):
    """Send an server notice to the client"""
    if not client_socket:
        return
    msg = ":ashburry.pythonanywhere.com NOTICE " + socket_data.mynick[client_socket] + " :" + msg
    circular.sc_send(client_socket, msg)


class Xdcc_System:
    xdcc_settings: Dict[str, Dict[str, str]] = dict()
    xdcc_settings["settings"] = dict()
    xdcc_chan_network: Dict[str, str] = {"#5ioE": "Undernet"}
    xdcc_chan_chat = system_data.xdcc_chan_chat
    xdcc_chan_chat.update({"#5ioE-chat": "#5ioE"})
    xdcc_chan_count = system_data.xdcc_chan_count
    xdcc_chan_count.update({"#5ioE-chat": 1, '#5ioE': 1, '#5ioE-w3': 1})
    xdcc_www_chans = system_data.xdcc_www_chans
    xdcc_www_chans.add('#5ioE-w3')
    xdcc_bot_list = XdccBotSLL()
    xbot = XdccBot("ashburry", "#5ioE", "Undernet")
    xdcc_bot_list.add(xbot)
    xdcc_bot_list.add_pack('ashburry', '#5ioE', '109G', '#521 Bauderr mSL script - Ashburry')
    xbot2 = XdccBot("ash2", "#channel", "Undernet")
    xdcc_bot_list.add_pack('ash2', '#channel', '10M', '#11 Trio_ircproxy.py with Bauderr mSL script - Ashburry')
    xbot32 = XdccBot("ash540", "#5ioE-w3", "Undernet")
    xdcc_bot_list.add_pack('ash540', '#5ioE-w3', '540M', '#66 Trio_ircproxy.py - Ashburry')
    xdcc_bot_list.save_list()
    xdcc_bot_list.load_list()


def xdcc_commands(client_socket: trio.SocketStream | trio.SSLStream, server_socket: trio.SocketStream | trio.SSLStream,
                  single_line: str, split_line: List[str]) -> None:
    """The *xdcc?* commands"""
    single_line_mod: str
    if single_line[0] == '@':
        single_line_mod = ' '.join(single_line.split(' ')[1:])
    else:
        single_line_mod = single_line

    if "xdcc-add" in split_line[0]:
        # xdcc-add chat=#elite-chat #elitewarez
        if '=' in single_line_mod and len(split_line) >= 3:
            split_line_str = ' '.join(split_line)
            while '  ' in split_line_str:
                split_line_str = split_line_str.replace('  ', ' ')
            split_line_str = split_line_str.replace(' =','=').replace('= ','=')
            split_line_chat = ' '.join(split_line).split('=')[0].split(' ')[-1] + '=' + ' '.join(split_line).split('=')[1].split(' ')[0]
            split_line_str = split_line_str.replace(split_line_chat, '')
            split_line_list = split_line_str[-1]
            del split_line_str
            if split_line_list[0] != '#':
                cs_send_notice(
                    client_socket,
                    "syntax: /xdcc-add #xdcc-list chat=#chat-search - note: " \
                    + "the #chat-search channel is optional and is \x02NOT\x02 used when searching by website.")
        else:
            cs_send_notice(
                client_socket,
                "syntax: /xdcc-add #xdcc-list chat=#chat-search - note: " \
                + "the #chat-search channel is optional and is not used when searching by website.")

        if len(split_line) == 3:
            cs_send_notice(client_socket,
                           "Adding pack lists in {} and providing search in {} and website.".format(
                               split_line[1], split_line[3]))
            cs_send_notice(
                client_socket,
                "join the xdcc channels on the correct irc network. To specify " \
                + 'which nickname will respond to searches use "/proxy-add-responder ' \
                + split_line[3]
            )
            Xdcc_System.xdcc_chan_chat[split_line[3]] = split_line[1]
            Xdcc_System.xdcc_www_chans.add(split_line[1])

        elif len(split_line) == 2:
                cs_send_notice(
                    client_socket,
                    "Syntax Error: /proxy-xdcc-add #xdcc-lists " \
                    + "Will add the xdcc lists to the website only. " \
                    + "Use /proxy-xdcc-add help for full usage information.",
                    )
                cs_send_notice(
                    client_socket,
                    "the xdcc channel was added to website search engine, join " \
                    + "channel {} on the correct irc network to begin the indexing".format(split_line[1])
                )
                Xdcc_System.xdcc_www_chans.add(split_line[1])
    if "xdcc-stop" in split_line[0] or 'xdcc-rem' in split_line[0]:
        for rem_chan in split_line[1:]:
            if rem_chan[0] != '#':
                continue
            Xdcc_System.xdcc_www_chans.discard(rem_chan)
            try:
                del Xdcc_System.xdcc_chan_chat[rem_chan]
            except KeyError:
                pass
            for chat_chan, xchan in Xdcc_System.xdcc_chan_chat.items():
                if xchan == rem_chan:
                    del Xdcc_System.xdcc_chan_chat[chat_chan]

    if split_line[0].startswith('xdcc-disa') or split_line[0].endswith("xdcc-off"):
        Xdcc_System.xdcc_settings["settings"]["running"] = 'off'
        cs_send_notice(client_socket, "Xdcc Search is now OFF")

    if split_line[0].startswith('xdcc-ena') or split_line[0].endswith("xdcc-on"):
        Xdcc_System.xdcc_settings["settings"]["running"] = 'on'
        cs_send_notice(client_socket, "Xdcc Search is now ON")

    return None
