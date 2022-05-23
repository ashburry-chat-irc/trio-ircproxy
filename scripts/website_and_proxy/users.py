from __future__ import annotations

from hashlib import sha256
from typing import List
from os.path import realpath, exists
from pathlib import Path
import os
import sys
from socket_data import SocketData as socket_data
import os
from cwd_flask import w3_proxy_root_path
user_file_str: str = os.path.join(w3_proxy_root_path, 'users.dat')
user_file = Path(user_file_str)


def status_msg(client_socket: trio.SocketStream | trio.SSLStream, msg: str):
    from scripts.trio_ircproxy.socket_data import SocketData
    if not msg:
        return
    msg = ':*STATUS!trio-ircproxy.py@mgscript.com PRIVMSG ' + SocketData.mynick[client_socket] + ' '+msg + '\n'
    if client_socket in SocketData.send_buffer:
        SocketData.send_buffer[client_socket].append(msg)




def remove_user(name: str) -> bool:
    removed: set[int] = set()
    sfread_list: list[str]
    if exists(user_file):
        with open(user_file, 'r') as sfopen:
            sfread: str = sfopen.read()
            sfread_list = sfread.split('\n')
        i: int = 0
        line: str
        for line in sfread_list:
            line = line.strip()
            if ':' not in line:
                removed.add(i)
                continue
            line_split: list[str] = line.split(':')
            if line_split[0].lower() == name.lower():
                removed.add(i)
            i += 1
    for i in removed:
        del sfread_list[i]
    with open(user_file, 'w') as sfopen:
        sfopen.write('\n'.join(sfread_list) + '\n')
        return True


def validate_login(name: str, email: str, password: str):
    if not name or not password or not email:
        raise ValueError('missing UserName and/or Password and/or E-mail address.')
    if len(email) > 49:
        raise ValueError('E-Mail address must be less than 50 characters in length.')
    if len(name) > 20 or len(password) > 20:
        raise ValueError('Username and Password must not exceed 20 characters in length each.')
    if (':' or ' ' or '*' or '?' in password) or (':' or ' ' or '*' or '?' in name):
        raise ValueError('colon (:), star (*), question mark ' \
        + '(?), and whitespace ( ) are \x02NOT\x02 allowed in Password or UserName.')
    if len(name) < 2:
        raise ValueError("UserName is too short. Must be longer than 1 characters.")
    if len(password) < 7:
        raise ValueError("Password is too short. Must be atleast 7 characters.")
    if len(email) < 3 or len(email.split('@')[0]) < 1 or len(email.split('@')[1]) < 1 or email.count('@') > 1 or email.count('@') < 1:
        raise ValueError('not an valid email, try again. (username email password')
    if name.find('admin') > -1:
        raise ValueError("UserName must not contain the word 'admin'.")
    if name == 'user':
        raise ValueError('UserName cannot be "user".')


def verify_user_pwdfile(name: str, password: str) -> bool | str:
    password = sha256(bytes(password.encode("utf8"))).hexdigest()
    if exists(user_file):
        with open(user_file, 'r') as sfopen:
            sfread: str = sfopen.read().strip()
            sfread_list: List[str] = sfread.split('\n')
        i = 0
        line: str
        line_split: List[str]
        for line in sfread_list:
            line = line.strip()
            if ':' not in line:
                continue
            line_split = line.split(':')
            if line_split[0] == name.lower():
                if line_split[3] == password:
                    return line_split[2]
                else:
                    return False
    return False


def add_new_user(name: str, email: str, password: str, /, account_power: str = 'normal', *, force: bool = False) -> bool:
    name = name.lower()
    login: str = name + ':' + email + ':' + account_power + ':' + sha256(bytes(password.encode('utf8'))).hexdigest()
    added_user: bool = False
    sfread_list: List[str] = []
    if exists(user_file):
        with open(user_file, 'r') as sfopen:
            sfread: str = sfopen.read().strip()
            sfread_list: List[str] = sfread.split('\n')
        i = 0
        line: str
        remove: List[int] = []
        for line in sfread_list:
            line = line.strip()
            if line.count(':') != 3:
                remove.append(i)
                continue
            line_split: List[str] = line.split(':')
            if line_split[0] == name:
                if force is True:
                    sfread_list[i] = login
                    added_user = True
                else:
                    raise ValueError(f'UserName already exists: "{name}".')
            i += 1
        for i in remove:
            del sfread_list[i]
    if not added_user:
        sfread_list.append(login)
    with open(user_file, 'w') as sfopen:
        sfopen.write('\n'.join(sfread_list) + '\n')
        return True



def admin_echo(client_socket: trio.SocketStream | trio.SSLStream, msg: str | bytes) -> None:
    if client_socket in socket_data.user_power['admin']:
        status_msg(client_socket, msg)
    return None