#!/usr/bin/python
# -*- coding: utf-8 -*-

"""Copyright (c) 2022, sire Kenggi Peters

This is an async IRC proxy server. It augments the irc
clients server connection adding functionality. It also allows
communicating to the pythonanywhere.com website server. The proxy itself
is interfaced by an irc client by using your 192.168.x.x ip for proxy server
hostname/ip with the port number 12345 and default login "user : pass" in your irc client.
for help type "/raw proxy-help" or maybe "/quote proxy-help" or just "/proxy-help"
with your irc client after connecting to any irc server through the proxy server.

Read the

You must run; in the terminal (just once):
    cd trio_ircproxy
    pip install --user -U -r requirements.txt
before running 'python3 trio_ircproxy.py'

"""

from __future__ import annotations

from fnmatch import fnmatch

from scripts.website_and_proxy.json_data import json_data
from pendulum import duration
from base64 import b64decode
from typing import Optional, List
from os import chdir
from os.path import realpath
from os.path import dirname
from os.path import expanduser
from ssl import create_default_context
from random import randint
# from fnmatch import fnmatch
from time import time
from sys import argv
# from sys import excepthook
# from sys import exc_info
from socket import gaierror
from pif import get_public_ip
from scripts.trio_ircproxy.socket_data import SocketData as socket_data
from scripts.flask_website.system_data import SystemData as system_data
from scripts.trio_ircproxy import xdcc_system, circular
from scripts.trio_ircproxy import ial
from scripts.flask_website.flask_app import begin_flask
from scripts.website_and_proxy.users import validate_login, verify_user_pwdfile
import trio
import multiprocessing as mp
from scripts.website_and_proxy.socket_data import aclose_sockets

chdir(realpath(dirname(expanduser(argv[0]))))



# import sys, tty, termios
# try:
#     # On Windows, msvcrt.getch reads a single char without output.
#     import msvcrt
#
#
#     def getchar():
#         return msvcrt.getch()
# except ImportError:
#     # Unix getchr
#     import tty
#     import termios
#     import sys
#
#
#     def getchar():
#         fd = sys.stdin.fileno()
#         old_settings = termios.tcgetattr(fd)
#         try:
#             tty.setraw(sys.stdin.fileno())
#             ch = sys.stdin.read(1)
#         finally:
#             termios.tcsetattr(fd, termios.TCSADRAIN, old_settings)
#         return ch.lower()


def strtobool(char):
    if str(char)[0].lower() in 'yt1o':
        return 1
    elif str(char)[0].lower() in 'nf0o':
        return 0
    else:
        return str(char)[0].lower()


# def yes_or_no(question):
#     c = ""
#     print(question + " (y/N): ", end="", flush=True)
#     while c not in ('y', 'n'):
#         c = getchar()
#     return strtobool(c)


def colourstrip(data: str) -> str:
    """Strips the mIRC colour codes from the text in data
        vars:
            :param data: A string of text that contains mSL colour codes
            :returns: string
    """
    find = data.find("\x03")
    while find > -1:
        done = False
        data = data[:find] + data[find + 1:]
        if len(data) <= find:
            done = True
        try:
            if done:
                break
            if not int(data[find]) > -1:
                raise (ValueError("Not-an-Number"))
            data = data[:find] + data[find + 1:]
            try:
                if not int(data[find]) > -1:
                    raise (ValueError("Not-an-Number"))
            except IndexError:
                break
            except ValueError:
                data = data[:find] + data[find + 1:]
                continue
            data = data[:find] + data[find + 1:]
        except:
            if not done:
                if data[find] != ",":
                    done = True
        if (not done) and (len(data) >= find + 1) and (data[find] == ","):
            try:
                data = data[:find] + data[find + 1:]
                if not int(data[find]) > -1:
                    raise (ValueError("Not-an-Number"))
                data = data[:find] + data[find + 1:]
                if not int(data[find]) > -1:
                    raise (ValueError("Not-an-Number"))
                data = data[:find] + data[find + 1:]
            except ValueError:
                pass
            except IndexError:
                break
        find = data.find("\x03")
    data = data.replace("\x02", "")
    data = data.replace("\x1d", "")
    data = data.replace("\x1f", "")
    data = data.replace("\x16", "")
    data = data.replace("\x0f", "")
    return data


def check_mirc_exploit(proto) -> bool:
    """Verifies that the nickname portions of the protocol
    does not contain any binary data.

        Vars:
            :proto: The text before the second : hopefully a nickname.
            :returns: True if there is binary data and False if it is clean.
    """
    for let in str(proto):
        if ord(let) == 58:
            return False
        if ord(let) in (1, 3, 31, 2, 22, 15, 31, 42):
            continue
        if ord(let) < 29 or ord(let) > 500:
            return True
    return False


def is_socket(xs: trio.SocketStream | trio.SSLStream) -> bool:
    """Returns True if the socket is sane.
        vars:

        :param xs: The socket to check for sanity
        :returns: bool if the parm xs is a socket return True
    """
    if not isinstance(xs, trio.SocketStream) and not isinstance(xs, trio.socket.SocketType) and not isinstance(xs, trio.SSLStream):
        return False
    if xs not in socket_data.mysockets:
        return False
    if socket_data.which_socket[xs] == 'cs':
        if xs not in socket_data.dcc_null:
            return False
        if xs not in socket_data.mynick:
            return False
        if xs not in socket_data.send_buffer:
            return False
    return True


def ss_version_reply(nick) -> str:
    """The version reply sent to the server, just the text.
    @rtype: str
        Vars:
            :nick: a string of the nickname to send to
            :returns: string
    """
    return (
            "NOTICE "
            + nick
            + " :\x01VERSION \x02Trio-ircproxy.py\x02 5ioE.3 from \x1fhttps://ashburry.pythonanywhere.com\x1f\x01"
    )


def ss_send_version_reply(from_cs: trio.SocketStream | trio.SSLStream, to_nick: str) -> None:
    """Send a version reply to a nickname from a socket
    @rtype: None
    """
    ss_socket = from_cs
    if ss_socket.which_socket == 'cs':
        ss_socket = socket_data.mysockets[from_cs]
    circular.sc_send(ss_socket, ss_version_reply(to_nick))


async def aclose_both(socket: trio.SocketStream | trio.SSLStream):
    sc_socket = socket
    del socket
    try:
        await sc_socket.aclose()
    except Exception:
        pass
    try:
        await socket_data.mysockets[sc_socket].aclose()
    except Exception:
        pass




class EndSession(Exception):
    def __init__(self, args: Optional[str] = ''):
        self.args: List[str] = [str(args)]


def usable_decode(text: bytes) -> str:
    """Decode the text so it can be used.
        vars:
            :param text: a string of bytes that needs decoding
            :returns: string
    """
    try:
        decoded_text = text.decode("utf8")
    except:
        decoded_text = text.decode("latin1", errors="replace")
    return decoded_text


def get_words(text: str) -> list:
    """Returns the words list of the first line in list

        vars:
            :param text: A string of lines
            :returns: a list of words split on whitespace
    """
    try:
        text = text.rstrip()
        lower_string = text.lower()
        lower_string = lower_string.replace("\r", "\n")
        while "\n\n" in lower_string:
            lower_string = lower_string.replace("\n\n", "\n")
        return lower_string.split(' ')
    except ValueError:
        return ['', ]


async def before_connect_sent_connect(cs_sent_connect, byte_string) -> None:
    """The socket is in a state where the client has just sent the CONNECT
    protocol statement but has not received an reply yet.

        vars:
            :param cs_sent_connect: the client socket
            :param byte_string: the first line received from client_socket
    """
    lower_words: str = byte_string.strip().lower()
    words: List[str] = get_words(lower_words)

    if len(words) < 3 or len(words) > 3:
        await cs_sent_connect.send_all(
            "HTTP/1.0 400 Bad Request. Requires proper http/1.0 protocol.\r\n\r\n".encode()
        )
        await aclose_sockets(sockets=(cs_sent_connect,))
        return None
    if words[0] != "connect":
        await cs_sent_connect.send_all(
            "HTTP/1.0 400 Bad Request. This is an irc only proxy server.\r\n\r\n".encode()
        )
        await aclose_sockets(sockets=(cs_sent_connect,))
        return None
    host: str = words[1]

    if ":" not in host:
        await cs_sent_connect.send_all(
            "HTTP/1.0 400 Bad Request. Requires `server:port` to connect to.\r\n\r\n".encode()
        )
        await aclose_sockets(sockets=(cs_sent_connect,))
        return None
    server: str = ':'.join(host.split(":")[0:-1])
    port: str = host.split(":")[-1]
    try:
        port_num: int = int(port)
    except ValueError:
        await cs_sent_connect.send_all(
            "HTTP/1.0 400 bad request. requires integer port number.\r\n\r\n".encode()
        )
        await aclose_sockets(sockets=(cs_sent_connect,))
        return None

    await proxy_make_irc_connection(cs_sent_connect, server, port_num)


async def proxy_make_irc_connection(cs_waiting_connect: trio.SocketStream | trio.SSLStream, server: str, port: int):
    """Make a connection to the IRC network and fail (502) if unable to connect."""
    # print("making irc connection")
    server_socket: trio.SocketStream | trio.SSLStream
    client_socket: trio.SocketStream | trio.SSLStream
    server_socket_nossl: trio.SocketStream | trio.SSLStream
    client_socket_nossl: trio.SocketStream | trio.SSLStream
    try:
        server_socket_nossl = await trio.open_tcp_stream(server, port)
    except (gaierror, ConnectionRefusedError, OSError, ConnectionAbortedError, ConnectionError):
        send: bool = await socket_data.raw_send(cs_waiting_connect, None, b"HTTP/1.0 502 Unable to connect to remote host.\r\n\r\n")
        await aclose_sockets(sockets=(cs_waiting_connect,))
        return
    try:
        # Change to client_socket_nossl
        client_socket_nossl = cs_waiting_connect
        ss_hostname: str = server
        try:
            system_data.Settings_json['settings']['public_ip'] = get_public_ip()
        except (UnicodeError, UnicodeWarning, UnicodeDecodeError, UnicodeEncodeError, UnicodeTranslateError):
            pass
        granted = b"HTTP/1.0 200 connection started with irc server.\r\n\r\n"
        if not await socket_data.raw_send(client_socket_nossl, server_socket_nossl, granted):
            return

        if port in (6697, 9999, 443, 6699, 6999, 7070):
            ssl_context_ss = create_default_context()
            ssl_context_ss.check_hostname = False
            server_socket_ssl = trio.SSLStream(server_socket_nossl, ssl_context_ss, server_hostname=ss_hostname)
            server_socket = server_socket_ssl
            client_socket = client_socket_nossl
        else:
            server_socket = server_socket_nossl
            client_socket = client_socket_nossl

        socket_data.create_data(client_socket, server_socket)
        socket_data.hostname[server_socket] = server + ':' + str(port)
        async with trio.open_nursery() as nursery:
            nursery.start_soon(ss_received_chunk, client_socket, server_socket)
            nursery.start_soon(cs_received_chunk, client_socket, server_socket)
            nursery.start_soon(write_loop, client_socket, server_socket, socket_data.send_buffer[client_socket], 'cs')
            nursery.start_soon(write_loop, client_socket, server_socket, socket_data.send_buffer[server_socket], 'ss')
    except EndSession:
        return
    except Exception as exc:
        # pass
        print("Exception: " + str(exc.args))
        raise
    # except (trio.BrokenResourceError, trio.ClosedResourceError, Exception):
    #   pass
    finally:
        socket_data.clear_data(cs_waiting_connect)
        print("connections were closed. nursery finished!")


def exc_print(msg) -> str:
    """Removes excess brackets from exception message"""
    return str(msg).strip(str(chr(34) + chr(39) + chr(40) + chr(41) + chr(44)))


async def write_loop(client_socket, server_socket, send_buffer, which_sock):
    """The server sockwrite write loop.

    vars:
        :client_socket: client socket
        :server_socket: server socket
        :send_buffer: list of lines to send
        :which_sock: = 'cs' or 'ss' to know which to send to
    """
    while (client_socket in socket_data.mysockets) and (server_socket in socket_data.mysockets):
        try:
            line = send_buffer.popleft()
        except IndexError:
            await trio.sleep(0)
            continue
        line = line.strip()
        if not isinstance(line, bytes):
            line = line.encode("utf8", errors="replace")
        if line == b'':
            await trio.sleep(0)
            continue
        line += b"\n"
        with trio.fail_after(17):
            try:
                if which_sock == 'ss':
                    await server_socket.send_all(line)
                else:
                    await client_socket.send_all(line)
            except (trio.BrokenResourceError, trio.ClosedResourceError, gaierror, trio.TooSlowError,
                    trio.BusyResourceError, OSError) as exc:
                print('write error! ' + which_sock + ' ' + str(exc) + ' ' + str(exc.args) + ' LINE: ' + str(line))
                socket_data.clear_data(client_socket)
                await aclose_sockets(sockets=(client_socket, server_socket))
                raise EndSession('Disconnected.')
            await trio.sleep(0)
            continue


def send_join(server_socket, chan):
    """Join a channel"""
    if not server_socket:
        return
    circular.sc_send(server_socket, "join :" + chan)


def send_ctcpreply(server_socket, nick, ctcp, reply):
    """Send an ctcpreply to the nickname"""
    if not server_socket:
        return
    ctcp_reply = "NOTICE " + nick + " " + ":\x01" + ctcp + " " + reply + "\x01"
    circular.sc_send(server_socket, ctcp_reply)


def send_ctcp(server_socket, nick, ctcp):
    """Send an ctcp to the nickname"""
    if not server_socket:
        return
    ctcp_send = "PRIVMSG " + nick + " " + ":\x01" + ctcp + "\x01"
    circular.sc_send(server_socket, ctcp_send)


def send_msg(server_socket, nick, msg):
    """Send an msg to the nickname"""
    if not server_socket:
        return
    msg = "PRIVMSG " + nick + " :" + msg
    circular.sc_send(server_socket, msg)


def send_notice(server_socket, nick, msg):
    """Send an notice to the nickname"""
    if not server_socket:
        return
    msg = "NOTICE " + nick + " :" + msg
    circular.sc_send(server_socket, msg)


def cs_send_notice(client_socket, msg):
    """Send an server notice to the client"""
    if not client_socket:
        return
    msg = ":trio-ircproxy.py NOTICE " + socket_data.mynick[client_socket] + " :" + msg
    circular.sc_send(client_socket, msg)


async def ss_updateial(client_socket: trio.SocketStream | trio.SSLStream, server_socket: trio.SocketStream | trio.SSLStream, single_line: str, split_line: List[str]) -> \
        Optional[bool]:
    """The function execution chain in reverse is
    updateial...() -> ss_got_line...() then fast_line()
    there is also another one on the same path but instead
    of this function it is ss_parse_line(). Client data
    is not checked except for in the case of DCC connections.

    @param split_line: The split line for the incoming data
    @param single_line: the single str line with uppercase for relay to client
    @param client_socket: trio.SocketStream | trio.SSLStream client socket
    @param server_socket: trio.SocketStream | trio.SSLStream server socket

    warning: code is duplicated for different server protcols. This could be avoided by keeping multile different
    strings of the single_line variable. Im sure it can be worked out to just have one set of the code base. But for now
    it is like this. Two sets of the code, one for each set of irc protocols.

    """
    nick: str
    src_nick: str = ''
    newnick: str = ''
    awaymsg: str = ''
    return_silent: bool = False
    chan: str = ''
    upper_nick: str = ''
    original_line: str = single_line
    if original_line[0] == '@':
        single_line = ' '.join(single_line.split(' ')[1:])
        orig_upper_split = original_line.split(' ')[1:]
    else:
        orig_upper_split = original_line.split(' ')
    if orig_upper_split[0][0] != ':':
        orig_upper_split.insert(0, '')

    if '!' in orig_upper_split[0]:
        upper_nick: str = orig_upper_split[0].split('!')[0].strip(':')
        if split_line[1] == 'nick':
            upper_nick = orig_upper_split[2].strip(':\r\n')

    if not len(split_line) > 1:
        return None

    if '!' in split_line[0]:
        nick: str = split_line[0].split('!')[0]
        nick = nick.strip(':')
        src_nick: str = split_line[0]
        src_nick = src_nick.strip(':')

    if chan:
        chan = chan.lstrip(':')

    if split_line[1] == 'mode':
        return None
    if len(split_line[0]) > 1:
        if split_line[0][0] == '@':
            del split_line[0]

    if split_line[1] == "away":
        try:
            awaymsg = ' '.join(single_line.split(' ')[3:])
        except IndexError:
            awaymsg = ''
        finally:
            cs_away_msg_notify(client_socket, nick, awaymsg)

    if split_line[1] == "part":
        chan = split_line[2]
        if nick == socket_data.mynick[client_socket]:
            socket_data.mychans[client_socket].discard(chan)
            ial.IALData.ial_remove_chan(client_socket, chan)
        else:
            ial.IALData.ial_remove_nick(client_socket, nick, chan)
            ial.IALData.myial_count[client_socket][chan] -= 1

    if split_line[1] == "join":
        chan = split_line[2]
        chan = chan.strip(':')
        my_usernick = socket_data.mynick[client_socket]
        if nick != my_usernick:
            ial.IALData.myial_count[client_socket][chan] += 1
        ial.IALData.ial_add_nick(client_socket, nick, src_nick, chan=chan)
        if nick == my_usernick:
            socket_data.mychans[client_socket].add(chan)
            if client_socket not in ial.IALData.who:
                ial.IALData.who[client_socket] = dict()
            ial.IALData.who[client_socket][chan] = '0'
            if client_socket not in ial.IALData.myial_count:
                ial.IALData.myial_count[client_socket] = dict()
            ial.IALData.myial_count[client_socket][chan] = 0

    if split_line[1] == "352" and len(split_line) >= 8:
        # /who list
        nick = split_line[7]
        addr = split_line[5]
        identd = split_line[4]
        fulladdr = nick + "!" + identd + "@" + addr
        chan = split_line[3]
        if chan[0] != "#":
            return None
        if chan not in socket_data.mychans[client_socket]:
            return None
        ial.IALData.ial_add_nick(client_socket, nick, fulladdr, chan=chan)
        if ial.IALData.who[client_socket][chan] == '0':
            ial.IALData.who[client_socket][chan] = 'inwho'
        if ial.IALData.who[client_socket][chan] == 'inwho':
            return False
        return None

    if split_line[1] == "315":
        chan = split_line[3]
        if chan[0] != '#':
            return
        if ial.IALData.who[client_socket][chan] == 'inwho':
            ial.IALData.who[client_socket][chan] = '1'
            return False
        return None

    if split_line[1] == "353":
        # /names
        # print('Error With: '+single_line)
        if len(split_line) < 5:
            return None
        nicks: List[str]
        nicks = [split_line[5].lstrip(':')]
        if len(split_line) > 6:
            nicks += split_line[6:]
        chan = split_line[4]
        ial.IALData.myial_count[client_socket][chan] += len(nicks)

    if split_line[1] == "366":
        # End of /names
        chan = split_line[3]
        if ial.IALData.ial_count_nicks(client_socket, chan) == ial.IALData.myial_count[client_socket][chan]:
            return None
        else:
            from threading import Timer
            th = Timer(randint(3, 12), lambda: ial.IALData.sendwho(server_socket, th, chan))
            ial.IALData.timers.add(th)
            th.start()

    if split_line[1] == "nick":
        newnick = split_line[2]
        newnick = newnick.strip(':')
        src_nick = newnick + "!" + split_line[0].split("!")[1]
        if nick == socket_data.mynick[client_socket]:
            socket_data.mynick[client_socket] = newnick
            socket_data.state[client_socket]['upper_nick'] = upper_nick
            socket_data.set_face_nicknet(client_socket)
        ial.IALData.ial_add_newnick(client_socket, nick, newnick, src_nick)

    if split_line[1] == '322':
        # print('add chan')
        # /List channel usrs :topic
        pass
    if split_line[1] == '323':
        print('done list')
        # /List ENd of List
        pass

    if split_line[1] == '321':
        print('statr list')
        # /List starting list
        pass

    if split_line[1] == 'away':
        try:
            awaymsg = ' '.join(single_line.split(' ')[2:])
        except IndexError:
            awaymsg = ''
        finally:
            cs_away_msg_notify(client_socket, nick, awaymsg)

    if split_line[1] == "privmsg":
        chan = split_line[2]
        if chan[0] != '#':
            chan = ''
        if nick in socket_data.myial[client_socket]:
            return_silent = ial.IALData.ial_add_nick(client_socket, nick, src_nick, chan=chan)

    if return_silent is True:
        return False
    return None


def cs_away_msg_notify(client_socket: trio.SocketStream | trio.SSLStream, nick: str, msg: str):
    msg = msg.lstrip(':')
    cs_send_notice(client_socket, "User " + nick + " is set away: " + msg)


def lower_split(text: str):
    return lower_strip(text)


def lower_strip(text: str):
    """lower text, strip text, mirc colour removal"""
    text = text.lower()
    text = text.strip()
    text = colourstrip(text)
    return text.split(' ')


async def cs_received_chunk(client_socket: trio.SocketStream | trio.SSLStream, server_socket: trio.SocketStream | trio.SSLStream) -> Optional[bool]:
    bytes_cap: int = 0
    byte_string: str = ''
    MAX_RECV: int = 355350000
    bytes_data: bytes = b''
    while True:
        if len(bytes_data) == MAX_RECV:
            await trio.sleep(1)
        bytes_data = b''
        if not is_socket(client_socket) or not is_socket(server_socket):
            return None
        closed: bool = False
        try:
            bytes_data = await client_socket.receive_some(MAX_RECV)
        except (trio.ClosedResourceError, trio.BrokenResourceError, gaierror, OSError) as excep:
            closed = True

        if not bytes_data:
            if closed == False:
                print("trio-ircproxy: socket closed by client.")
            elif closed:
                print('trio-ircproxy: client socket crashed.')
            if client_socket in socket_data.mysockets:
                await circular.send_quit(client_socket)
                socket_data.clear_data(client_socket)
            return None
        bytes_cap += len(bytes_data)
        if ("mynick" in socket_data.dcc_send[client_socket] and "othernick" in socket_data.dcc_send[server_socket]) or \
                ("mynick" in socket_data.dcc_chat[client_socket] and "othernick" in socket_data.dcc_chat[
                    server_socket]):
            circular.sc_send(server_socket, bytes_data)
            continue

        byte_string += usable_decode(bytes_data)

        byte_string = byte_string.replace('\r', '\n')
        while '\n\n' in byte_string:
            byte_string = byte_string.replace('\n\n', '\n')

        byte_string = byte_string.lstrip('\n')
        find_n: int = byte_string.find('\n')
        single_line: str = ''
        while find_n > -1:
            byte_string = byte_string.lstrip('\n')
            single_line = byte_string[0:find_n + 1]
            split_line = lower_strip(single_line)
            cs_received_line(client_socket, server_socket, single_line, split_line)
            try:
                byte_string = byte_string[find_n + 1:]
            except IndexError:
                byte_string = ''
                break
            find_n = byte_string.find('\n')
        # continue


def sock_005(client_socket: trio.SocketStream | trio.SSLStream, single_line: str) -> None:
    upper_line_str: str = single_line.strip()
    upper_line: List[str] = upper_line_str.split(' ')
    if upper_line_str[0] == ':':
        upper_line = upper_line[3:]
    else:
        upper_line = upper_line[2:]
    key: str
    value: str | int
    if not upper_line:
        return None
    for name in upper_line:
        if name[0] == ":":
            break
        if "=" in name:
            key = name.split("=")[0]
            value = name.split("=")[1]
        else:
            key = name
            value = name
        if value.isdigit():
            value = int(value)
        key = key.lower()
        socket_data.raw_005[client_socket][key] = value
    socket_data.set_face_nicknet(client_socket)
    return None


async def exploit_triggered(cs, ss):
    print("mIRC exploit attempt from irc server.")
    await aclose_sockets(sockets=(cs, ss))


async def ss_received_chunk(client_socket: trio.SocketStream | trio.SSLStream, server_socket: trio.SocketStream | trio.SSLStream) -> Optional[bool]:
    """Read loop to receive data from the socket and pass it to
        fast_line_split_for_read_loop()

        :param client_socket: client socket stream
        :param server_socket: irc server socket stream
        :return: returns if the nursery needs to be closed.
    """
    try:
        if 'connecting' == socket_data.state[client_socket]['doing']:
            socket_data.state[client_socket]['doing'] = 'signing on'
            socket_data.echo(client_socket, 'Connected to ' + socket_data.hostname[server_socket])

        bytes_cap: int = 0
        byte_string: str = ''
        MAX_RECV: int = 25535000
        rcvd_bytes: bytes = b''
        while True:
            if len(rcvd_bytes) == MAX_RECV:
                await trio.sleep(1)
            rcvd_bytes = b''
            closed: bool = False
            try:
                rcvd_bytes = await server_socket.receive_some(MAX_RECV)
            except (trio.ClosedResourceError, trio.BrokenResourceError, gaierror, trio.TooSlowError, OSError):
                closed = True


            if not rcvd_bytes:
                if closed:
                    print('trio-ircproxy: server socket crashed.')
                elif closed is False:
                    print("trio-ircproxy: socket closed by irc server.")
                return None

            bytes_cap += len(rcvd_bytes)

            if ((client_socket in socket_data.dcc_send) and (server_socket in socket_data.dcc_send) and \
                ("mynick" in socket_data.dcc_send[client_socket] and "othernick" in socket_data.dcc_send[
                    server_socket])) or \
                    ((client_socket in socket_data.dcc_chat) and (server_socket in socket_data.dcc_chat) and \
                     ("mynick" in socket_data.dcc_chat[client_socket] and "othernick" in socket_data.dcc_chat[
                         server_socket])):
                circular.sc_send(client_socket, rcvd_bytes)
                continue

            if not is_socket(client_socket) or not is_socket(server_socket):
                return False

            byte_string += usable_decode(rcvd_bytes)
            byte_string = byte_string.replace('\r', '\n')
            while '\n\n' in byte_string:
                byte_string = byte_string.replace('\n\n', '\n')

            find_n = byte_string.find('\n')
            single_line: str
            while find_n > -1:
                single_line = byte_string[0:find_n + 1]
                if single_line != '\n':
                    split_line = lower_split(single_line)
                    await ss_received_line(client_socket, server_socket, single_line, split_line)
                try:
                    byte_string = byte_string[find_n + 1:]
                except IndexError:
                    byte_string = ''
                    break
                find_n = byte_string.find('\n')
    except (ValueError, KeyError):
        print('value, key error')
        raise
    finally:
        t.cancel_ping()
        print('error with ss_receive_chunk:')
        if server_socket in socket_data.mysockets:
            await circular.send_quit(server_socket)
            socket_data.clear_data(client_socket)


async def ss_received_line(client_socket: trio.SocketStream | trio.SSLStream, server_socket: trio.SocketStream | trio.SSLStream, single_line: str,
                           split_line: List[str]) -> None:
    # from above ss_received_chunk()
    # print('SS : '+single_line)
    nick: str = ''
    await trio.sleep(0)

    if len(split_line) == 2 and socket_data.dcc_null[server_socket] is False and (
            split_line[0] == "100" or split_line[0] == "101"):
        # 100 or 101 nickname
        socket_data.dcc_chat[server_socket]["othernick"] = split_line[1]
        socket_data.dcc_null[server_socket] = True
        circular.sc_send(client_socket, rcvd_bytes)
        return None

    elif len(split_line) >= 4 and socket_data.dcc_null[client_socket] is False and (
            split_line[0] == "120" or split_line[0] == "121"):
        # 120 _ashbrry 1427104089 100.Days.to.Live.2021.HDRip.XviD.AC3-EVO.avi
        socket_data.dcc_send[server_socket]["othernick"] = split_line[1]
        socket_data.dcc_null[server_socket] = True
        circular.sc_send(client_socket, rcvd_bytes)
        return None

    socket_data.dcc_null[server_socket] = True

    original_line: str = single_line
    orig_upper_split: List[str]
    if original_line[0] == '@':
        single_line = ' '.join(single_line.split(' ')[1:])
        orig_upper_split = original_line.split(' ')[1:]
    else:
        orig_upper_split = original_line.split(' ')

    if check_mirc_exploit(original_line) is True:
        await exploit_triggered(client_socket, server_socket)
        return None
    if split_line[0][0] == '@':
        del split_line[0]

    if orig_upper_split[0][0] != ':':
        orig_upper_split.insert(0, '')

    elif '!' in orig_upper_split[0]:
        nick = split_line[0].split('!')[0].strip(':\r\n ').lower()
        if split_line[1] == 'nick':
            upper_nick = orig_upper_split[2].strip(':\r\n ')
        else:
            upper_nick = orig_upper_split[0].split('!')[0].strip(':\r\n ')
    if split_line[0][0] != ':':
        split_line.insert(0, '')
    elif split_line[1:3] == 'privmsg ' + socket_data.mynick[client_socket]:
        if nick in socket_data.state[client_socket]['new_user_authors']:
            cmd: str = ' '.join(split_line[3:]).strip(':\r\n ')
            while '  ' in cmd:
                cmd = cmd.replace('  ', ' ')
            cmd_split: List[str] = cmd.split(' ')
            if fnmatch(cmd_split[0], '.cre*use*'):
                if len(cmd_split) < 4 or len(cmd_split) > 4:
                    circular.sc_send(server_socket,
                                     'privmsg ' + nick + ' :Error: Command must be entered with exactly 3 '
                                                         'parameters. ("username email password"). try again.')
                    return None
                try:
                    validate_login(cmd_split[1], cmd_split[2], cmd_split[3])
                except ValueError as exc:
                    circular.sc_send(server_socket, 'privmsg ' + nick + ' :ERROR: ' + exc.args[0] + ' try again.')
                    return None
                try:
                    proxy_commands.add_new_user(cmd_split[1], cmd_split[2], cmd_split[3])
                except ValueError as exc:
                    circular.sc_send(server_socket, 'privmsg ' + nick + ' :ERROR: ' + exc.args[0] + '. try again.')
                    return None

    ial_send = await ss_updateial(client_socket, server_socket, single_line, split_line)

    if len(split_line) == 1:
        if len(original_line):
            circular.sc_send(client_socket, original_line)
        return None

    if split_line[1] == 'ping' and len(split_line) >= 3:
        pong: str = str.strip(split_line[2].lstrip(':') + ' ' + ' '.join(split_line[3:]))
        circular.sc_send(server_socket, 'PONG :' + pong)
        circular.sc_send(client_socket, 'PING :' + str(time()))
        return None

    elif split_line[1] == 'pong' and len(split_line) >= 4:
        pong_str: str = split_line[3].lstrip(':')
        if len(pong_str) < 10:
            circular.sc_send(client_socket, original_line)
            return None
        try:
            pong: float = float(pong_str)
            dur: duration.Duration = duration(seconds=round(time() - pong, 2))
            dur_str: str = dur_replace(dur.in_words())
            socket_data.msg(client_socket, 'Server Lag: ' + dur_str)
            return None
        except ValueError:
            pass
    if split_line[1] == '375':
        # motd start 3rd param is nickname
        if not socket_data.state[client_socket]['motd_def']:
            send_motd(client_socket, split_line[2])
            return None

    if split_line[1] == '372':
        # motd msg
        if not socket_data.state[client_socket]['motd_def']:
            return None

    if split_line[1] == '376' or split_line[1] == "422":
        # End of /motd # keep track if it is the first motd (on connect) or already connected.
        if not socket_data.state[client_socket]['connected']:
            socket_data.state[client_socket]['connected'] = time()

    if split_line[1] == '376':
        # End of /motd
        if not socket_data.state[client_socket]['motd_def']:
            socket_data.state[client_socket]['motd_def'] = 1
            return None

    elif split_line[1] == '005':
        sock_005(client_socket, single_line)

    elif split_line[1] in ("001", "372", "005", "376", "375", "422"):
        socket_data.state[client_socket]['doing'] = 'signed on'
        socket_data.mynick[client_socket] = split_line[2].lower()
        socket_data.state[client_socket]['upper_nick'] = orig_upper_split[2]
        socket_data.set_face_nicknet(client_socket)

    elif split_line[1] == '301':
        reason = " ".join(orig_upper_split[4:]).strip(':\r\n ')
        msg = f":ashburry.pythonanywhere.com NOTICE {socket_data.mynick[client_socket]} :User {orig_upper_split[3]} is " \
              f"set away, reason: {reason}"
        circular.sc_send(client_socket, msg)

    if ial_send is True:
        # await exploit_triggered(client_socket, server_socket)
        return None
    if ial_send is False:
        return None
    circular.sc_send(client_socket, original_line)
    return None


def dur_replace(in_words: str) -> str:
    in_words = in_words.replace('week', 'wks')
    in_words = in_words.replace('day', 'dys')
    in_words = in_words.replace('hour', 'hrs')
    in_words = in_words.replace('minute', 'mins')
    in_words = in_words.replace('second', 'secs')
    in_words = in_words.replace('ss', 's')
    return in_words


def send_motd(client_socket, mynick):
    prefix = ':ashburry.pythonanywhere.com 375 ' + mynick + ' :- '
    circular.sc_send(client_socket, prefix + 'Ashburry.PythonAnywhere.com Message of the Day -')
    prefix = ':ashburry.pythonanywhere.com 372 ' + mynick + ' :- '
    circular.sc_send(client_socket, prefix + '\x02skipping MOTD\x02, for an quick connection startup. -')
    circular.sc_send(client_socket, prefix)
    circular.sc_send(client_socket, prefix + 'To connect to an SSL port, \x02DO NOT\x02 prefix the port with -')
    circular.sc_send(client_socket, prefix + 'an \x02+\x02 character. End-to-end encryption is not possible, -')
    circular.sc_send(client_socket, prefix + 'AFAIK. Trio-ircproxy.py \x02will\x02 use SSL for irc -')
    circular.sc_send(client_socket, prefix + 'server connections on specific ports. -')
    circular.sc_send(client_socket, prefix)
    circular.sc_send(client_socket, prefix + 'Type \x02/proxy-commands\x02 for list of valid commands. -')
    circular.sc_send(client_socket, prefix + 'Type \x02/xdcc-commands\x02 for list of xdcc commands. -')
    circular.sc_send(client_socket, prefix + "Type \x02/proxy-help\x02 for first use instructions. -")
    circular.sc_send(client_socket, prefix)
    circular.sc_send(client_socket, prefix + "To view the irc server's MOTD type \x02/motd\x02 -")
    circular.sc_send(client_socket, prefix + "Trio-ircproxy.py and Bauderr msl script official website: -")
    circular.sc_send(client_socket, prefix + "\x1fhttps://ashburry.pythonanywhere.com/\x1f -")
    circular.sc_send(client_socket, prefix)
    prefix = ':ashburry.pythonanywhere.com 376 ' + mynick + ' :- '
    circular.sc_send(client_socket, prefix + 'End of /MOTD -')


def cs_received_line(client_socket: trio.SocketStream | trio.SSLStream, server_socket: trio.SocketStream | trio.SSLStream, single_line: str, split_line: List[str]) \
        -> None:
    """Client socket received a line of data.
            Vars:
                :client_socket: client socket
                :server_socket: server socket
                :single_line: string of words
                :split_line: list of words
                :returns: None
    """
    # print("CS: " + single_line)
    # socket_data.conn_timeout[client_socket] = time()
    if len(split_line) == 2 and socket_data.dcc_null[client_socket] is False:
        if split_line[0] == "100" or split_line[0] == "101":
            # 100 or 101 nickname
            socket_data.dcc_chat[client_socket]["mynick"] = split_line[1]
            socket_data.dcc_null[client_socket] = True
            circular.sc_send(server_socket, bytes_data)

    elif len(split_line) >= 3 and socket_data.dcc_null[client_socket] is False:
        if split_line[0] == "120" or split_line[0] == "121":
            # 120 _ashbrry 1427104089 100.Days.to.Live.2021.HDRip.XviD.AC3-EVO.avi
            socket_data.dcc_send[client_socket]["mynick"] = split_line[1]
            socket_data.dcc_null[client_socket] = True
            circular.sc_send(server_socket, bytes_data)
    else:
        socket_data.dcc_null[client_socket] = True

        if split_line[0][0] != ':':
            split_line.insert(0, '')
        if single_line[1] == 'testecho':
            echo_text = ':ashburry.pythonanywhere.com ECHO ALL This is a reply from the proxy server.'
            circular.sc_send(client_socket, echo_text)
            return None
        if len(single_line) >= 3 and single_line[1] == '@':
            circular.sc_send(server_socket, single_line[2:])
            return None
        if split_line[1] == 'names':
            chan = split_line[2]
            ial.IALData.myial_count[client_socket][chan] = 0

        if split_line[1] == 'pong':
            pong_str = split_line[2].lstrip(':')
            if len(pong_str) < 10:
                circular.sc_send(server_socket, single_line)
                return None
            try:
                pong = float(pong_str)
                dur: duration.Duration = duration(seconds=round(time() - pong, 2))
                dur_str: str = dur_replace(dur.in_words())
                socket_data.echo(client_socket, 'Client Lag: ' + dur_str)
                return None
            except ValueError:
                pass

        if split_line[1] == 'ping' and len(split_line) >= 3:
            pong = str.strip(split_line[2].lstrip(':') + ' ' + ' '.join(split_line[3:]))
            circular.sc_send(client_socket, 'PONG ashburry.pythonanywhere.com :' + pong)
            circular.sc_send(server_socket, 'PING :' + str(time()))
            return None

        yes_halt: Optional[bool] = False
        if split_line[1].startswith('trio') or split_line[1].startswith('proxy') or split_line[1].startswith('xdcc'):
            yes_halt = cs_rcvd_command(client_socket, server_socket, single_line, split_line)
        if not yes_halt:
            circular.sc_send(server_socket, single_line)
        return None


from scripts.trio_ircproxy import proxy_commands


def cs_rcvd_command(client_socket, server_socket, single_line, split_line) -> Optional[bool]:
    # circular.sc_send(server_server, 'privmsg ashburry :This is a test!!')

    del split_line[0]

    if len(split_line) > 2 and split_line[0] == '.colour':
        circular.sc_send(server_socket,
                         'privmsg ashburry :colour is: ' + str(ord(split_line[1][0])) + ' = ' + split_line[1][0])
        # yes_halt = True to NOT send to server
        return True

    if 'xdcc' in split_line[0]:
        xdcc_system.xdcc_commands(client_socket, server_socket, single_line, split_line)
        return True
    if 'trio' in split_line[0] or 'proxy' in split_line[0]:
        proxy_commands.commands(client_socket, server_socket, single_line, split_line)
        return True
    return None


def verify_login(auth_userlogin) -> bool:
    """Validate user:pass login attempt
        parameters:

        :auth_userlogin: The `user: pass` login attempt

    """
    auth_pass: str = ''
    auth_user: str = ''
    try:
        auth_login: str = b64decode(auth_userlogin).decode("utf-8")
        print(auth_login)
        auth_pass = auth_login[auth_login.find(":") + 1:]
        auth_user = auth_login[:auth_login.find(":")]
        auth_user = auth_user.strip()
        auth_user = auth_user.lower()
        if not auth_pass or not auth_user or len(auth_user) > 40 or len(auth_pass) > 40:
            return False
        if auth_login.count(":") > 1 or auth_login.count(':') < 1 or auth_login.count(" ") > 1 \
                or verify_user_pwdfile(auth_user, auth_pass) is False:
            return False
        return True
    except ValueError:
        return False
    finally:
        auth_pass = "x" * len(auth_pass)
        auth_user = "x" * len(auth_user)
        del auth_pass
        del auth_user


async def authenticate_proxy(client_socket: trio.SocketStream, auth_lines: list[str]) -> bool | str:
    """Check for bad login attverify_userempt
        parameters:

        :client_socket: client socket
        :auth_lines: the remaining lines of text after the first line

    """
    i = 0
    while True:
        if i > len(auth_lines):
            socket_data.echo(client_socket, "Missing authentication attempt.")
            with trio.move_on_after(18):
                await client_socket.send_all(b"407 Proxy authentication required.\r\n")
                await client_socket.send_all(
                    b'WWW-Authenticate: Basic realm="trio-ircproxy user realm", \
                                    charset="UTF-8"\r\n\r\n'
                )
            await client_socket.aclose()
            return False
        auth: str = auth_lines[i].lower()
        if "authorization:basic" in auth:
            auth = auth.replace(":", ": ")
        auth = auth.replace("  ", " ")
        auth = auth.split(" ")[0]
        if auth not in ("authorization:", "proxy-authorization:"):
            i += 1
            continue
        break

    auth_words: str = auth_lines[i]
    auth_words = auth_words.replace(":", ": ")
    while "  " in auth_words:
        auth_words = auth_words.replace("  ", " ").strip()
    auth_words_split: list[str] = auth_words.split(" ")
    auth_words_split = auth_words_split[1:]
    if len(auth_words_split) != 2:
        with trio.move_on_after(18):
            socket_data.echo(client_socket, "Disconnected, missing username/password attempt.")
            await client_socket.send_all(b"407 You need an login to continue.\r\n")
            await client_socket.send_all(
                b'WWW-Authenticate: Basic realm="trio-ircproxy user'
                + b' realm", charset="UTF-8"\r\n\r\n'
            )
        await client_socket.aclose()
        return False
    if auth_words_split[0].lower() != "basic":
        socket_data.echo(client_socket, "Disconnected, invalid authentication type attempt.")
        with trio.move_on_after(18):
            await client_socket.send_all(b"407 you need Basic authentication type.\r\n\r\n")
            await client_socket.send_all(
                b'WWW-Authenticate: Basic realm="trio-ircproxy user'
                + b' realm", charset="UTF-8"\r\n\r\n'
            )
        await client_socket.aclose()
        return False
    name = verify_login(auth_words_split[1])
    if not name:
        socket_data.echo(client_socket, "Disconnected, bad username/password attempt. " + auth_words[1])
        with trio.move_on_after(18):
            await client_socket.send_all(b"401 Unauthorized. Bad username/password attempt.\r\n\r\n")
        await client_socket.aclose()
        return False
    return name


def check_fry_server(ip_addy) -> bool:
    """Makes sure the server is not being hammered
    by a specific IP address. Checks after 20 connections.
    If you plan on using the Proxy Server in a hammering fasion
    you can add an IP to the immune list see "/raw proxy-help immune"

    :param ip_addy: a list or string of an IP address
    :returns: True if IP is okay or False if the IP needs to be blocked.
    """

    if isinstance(ip_addy, (tuple, list)):
        ip_addy: str = ip_addy[0]
    if ip_addy in system_data.FryServer_json["immune"]:
        return True

    # int, number of connections
    max_cons: int = int(system_data.FryServer_json["settings"]['max_reconnections'])
    # int, within seconds of each other
    max_time: int = int(system_data.FryServer_json["settings"]["max_time"])
    new_time: str = str(int(time()))
    for old_ip in list(system_data.FryServer_json["ip_list"]):
        old_check: str = system_data.FryServer_json["ip_list"][old_ip]
        old_check_split: list[str] = old_check.split(" ")
        if len(old_check_split) != 2:
            del system_data.FryServer_json["ip_list"][old_ip]
            continue
        if int(new_time) - int(old_check_split[1]) >= max_time:
            del system_data.FryServer_json["ip_list"][old_ip]

    old_check: str = system_data.FryServer_json["ip_list"].get(ip_addy, "0 " + new_time)
    old_check_split: list[str] = old_check.split(" ")
    system_data.FryServer_json["ip_list"][ip_addy] = (
            str(int(old_check_split[0]) + 1) + " " + old_check_split[1]
    )
    if int(new_time) - int(old_check_split[1]) < max_time:
        system_data.FryServer_json["ip_list"][ip_addy] = (
                str(int(old_check_split[0]) + 1) + " " + new_time
        )
        if int(old_check_split[0]) + 1 >= max_cons:
            return False

    return True


async def proxy_server_handler(cs_before_connect) -> None:
    """Handle a connection to the proxy server.
                        Accept proxy http/1.0 protocol.
        parameters:

        :cs_before_connect: the live socket already accepted and
                        ready for reading (1 byte at a time).
    """
    # Write down tries per minute for this IP. And just close them all if its too many.
    hostname: str = cs_before_connect.socket.getpeername()[0]
    if not check_fry_server(hostname):
        await cs_before_connect.aclose()
        await trio.sleep(0)
        return None
    socket_data.hostname[cs_before_connect] = hostname
    port: str = system_data.Settings_json["settings"]["listen_port"]
    socket_data.echo(cs_before_connect, "Accepted an client connection on port " + port + '...')
    bytes_data: bytes
    byte_string: str = ""
    while True:
        bytes_data = b''
        with trio.move_on_after(18) as cancel_scope:
            bytes_data = await cs_before_connect.receive_some(1)
        if cancel_scope.cancelled_caught:
            socket_data.clear_data(cs_before_connect)
            await cs_before_connect.aclose()
            socket_data.echo(cs_before_connect, "Client is too slow to send data. Socket closed.")
            return None

        if not bytes_data:
            socket_data.clear_data(cs_before_connect)
            socket_data.echo(cs_before_connect, "Client closed connection.")
            await cs_before_connect.aclose()
            return None

        byte_string += usable_decode(bytes_data)
        if not byte_string.endswith("\r\n\r\n"):
            continue
        break
    byte_string = byte_string.strip()
    byte_string = byte_string.replace("\r", "\n")
    while "\n\n" in byte_string:
        byte_string = byte_string.replace("\n\n", "\n")
    while "  " in byte_string:
        byte_string = byte_string.replace("  ", " ")
    lines: list[str] = byte_string.split("\n")
    while '' in lines:
        lines.remove('')
    line_no: int = 0
    for line in lines:
        lines[line_no] = line.strip()
        line_no += 1
    auth: bool | None = None
    if len(lines) > 1:
        auth_list: list[str] = lines[1:]
        auth = await authenticate_proxy(cs_before_connect, auth_list)
    if auth is False:
        return None
    try:
        socket_data.login[cs_before_connect] = auth
        async with trio.open_nursery() as nursery:
            nursery.start_soon(before_connect_sent_connect, cs_before_connect, lines[0])
    except KeyboardInterrupt:
        socket_data.clear_data(cs_before_connect)
    except Exception as exc:
        print("handler EXCEPT: " + str(exc.args))
        socket_data.clear_data(cs_before_connect)
        await cs_before_connect.aclose()
        raise


async def start_proxy_listener():
    """
      Start the proxy server.
    """
    listen_port: int = int(system_data.Settings_json["settings"].get("listen_port", 4321))
    print("\ncopyright (c) -- [Authors: sire Kenggi] -- 3-Clause BSD -- (open source)")
    print("proxy is listening on port " + str(listen_port))
    print("press Ctrl+C to quit...\n")
    try:
        await trio.serve_tcp(proxy_server_handler, int(listen_port), host=None)
    except (Exception, KeyboardInterrupt, OSError, gaierror) as exc:
        if len(exc.args) > 1 and (exc.args[0] == 98 or exc.args[0] == 10048):
            print(
                '\nERROR: The listening port is being used somewhere else. Maybe trio-ircproxy.py is already running somewhere.')
        else:
            # Create a new list to to prevent modifying while looping
            sockets = [sock for sock in socket_data.mysockets]
            for sock in sockets:
                await aclose_sockets(sockets=(sock,))
        print("EXC: " + str(exc.args))
        print("\nTrio-ircproxy.py has Quit! -- good-bye bear ʕ•ᴥ•ʔ\n")


async def quit_all():
    """send quitmsg and close all sockets. 10 sockets
    closed in 30ms has a setting of 0.003 (3ms delay per socket closed).
    Should be adjustable to 0ms to prevent clones on quick reconnect.
    via /scon -a /server
    """
    for sock in socket_data.mysockets:
        await circular.send_quit(sock)


def begin_server() -> None:
    """Start the trio_ircproxy.py proxy server

    """
    system_data.make_user_file()
    system_data.make_settings()
    system_data.make_fryfile()
    system_data.make_nickhistory()
    system_data.make_xdcc_chan_chat()
    trio.run(start_proxy_listener)
    return None


if __name__ == "__main__":
    mp.set_start_method('spawn')
    remote_website: str | bool = json_data.home['home'].get('remote_website', False)
    local_website: str | bool = json_data.home['home'].get('local_website', False)
    if not remote_website[0] and not local_website[0]:
        json_data.home['home']['local_website'] = ["http://127.0.0.1:80"]
    #p1: mp.Process = mp.Process(target=begin_server)
    p2: mp.Process = mp.Process(target=begin_flask)
    if not remote_website[0]:
        p2.start()
        begin_server()
        try:
            p2.join()
        except KeyboardInterrupt:
            pass
    else:
        begin_server()
