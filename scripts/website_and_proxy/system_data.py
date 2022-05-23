#!/usr/bin/python
# -*- coding: utf-8 -*-

from __future__ import annotations

from pathlib import Path
from os.path import realpath
# from os.path import dirname
from os.path import isfile
from os.path import isdir
from os import mkdir
from typing import List, Dict, Set
from hashlib import md5, sha256
from pathlib import Path
from pif import get_public_ip
import platformdirs as appdirs
import os
import json
from os import makedirs
import sys


user_file = Path('/home/xdcc/website_and_proxy/users.dat')

sysdir_path = os.path.join(appdirs.user_config_path(), "trio_ircproxy-5ioE.3")
xdccdir_path = os.path.join(appdirs.user_config_path(), "trio_ircproxy-5ioE.3", "xdcc_search")

makedirs(sysdir_path, exist_ok=True)
makedirs(xdccdir_path, exist_ok=True)

class SystemData:
    xdcc_chan_list: set[str] = set({})
    if not isdir(sysdir_path):
        mkdir(sysdir_path)
    if not isdir(xdccdir_path):
        mkdir(xdccdir_path)
    authfile_path: str = os.path.join(sysdir_path, "auth.json")
    fryserverfile_path: str = os.path.join(sysdir_path, "fryserver.json")
    settingsfile_path: str = os.path.join(sysdir_path, "settings.json")
    loggedinfile_path: str = os.path.join(sysdir_path, "logged_in.json")
    nickhistoryfile_path: str = os.path.join(sysdir_path, "nicknames_history.json")
    xdcc_chan_chat_file_path: str = os.path.join(xdccdir_path, "xdcc_chans_botsearch.json")
    xdcc_chans_www_file_path: str = os.path.join(xdccdir_path, "xdcc_chans_list.json")
    xbot_file_path: str = os.path.join(xdccdir_path, "xdcc_bots.json")
    xdcc_chansfile_path: str = os.path.join(xdccdir_path, "xdcc_chans.json")
    xdcc_bot_list: List[str | int] = ['nick', 'timeout']
    # keep track of chat & list channels
    xdcc_chan_chat: dict = {}
    # count how many bots I have working in the channels
    xdcc_chan_count: dict = {}

    FryServer_MAX_CONNECTIONS = 20  # int, all the connections within how many seconds
    FryServer_MAX_TIME = 500  # within how many seconds the connections are made. disconnects do not deincrement count

    # matter.
    FryServer_json: Dict[str, Dict[str, str]] = dict()
    FryServer_json['ip_list'] = {}
    FryServer_json['settings'] = {}
    FryServer_json['settings']['max_conns_per_host'] = '15'
    FryServer_json['settings']['max_conns_everyone'] = '1450'
    FryServer_json['settings']['no_data_timeout'] = '250'
    FryServer_json['settings']['max_reconnections'] = str(FryServer_MAX_CONNECTIONS)
    FryServer_json['settings']['max_time'] = str(FryServer_MAX_TIME)
    FryServer_json['settings']['max_line_length'] = '800'
    FryServer_json['settings']['max_protocol_length'] = '400'
    FryServer_json['settings']['max_protocol_word_length'] = '100'
    FryServer_json['immune'] = {}
    FryServer_json['immune']['192.168.*'] = 'true'
    Settings_json: Dict[str, Dict[str, str]] = dict()
    Settings_json['settings'] = {}
    Settings_json['settings']['allow_quitmsg'] = 'no'
    Settings_json['settings']['personal_flood'] = 'on'
    Settings_json['settings']['channel_flood'] = 'on'
    Settings_json['settings']['listen_port'] = str(4321)
    Settings_json['settings']['skip_motd'] = 'yes'
    Settings_json['settings']['public_ip'] = get_public_ip()
    Settings_json['settings']['status_nick'] = '*STATUS!trio-ircproxy@mgscript.com'
    Nick_History_json: Dict[str, Dict[str, str]] = dict()
    Nick_History_json['nicknames'] = {}

    Loggedin_json: Dict[str, Dict[str, str]] = dict()
    Loggedin_json['loggedin'] = {}

    xdcc_www_chans_file_path: os.path.join(sysdir_path, "xdcc_chans.json")
    xdcc_www_chans = set()
    xdcc_www_chans.update({'#5ioE'})

    @classmethod
    def save_xdcc_bot_list(cls) -> None:
        with open(cls.xbot_file_path, 'w') as fp:
            fp.write(json.dumps(cls.xdcc_bot_list))
        return None

    @classmethod
    def save_xdcc_www_chans(cls) -> None:
        with open(cls.xdcc_www_chans_file_path, 'w') as fp:
            fp.write(json.dumps(cls.xdcc_www_chans))
        return None

    @classmethod
    def load_xdcc_bot_list(cls) -> None:
        with open(cls.xbot_file_path, 'r') as fp:
            cls.xdcc_bot_list = json.loads(fp.read())
        return None

    @classmethod
    def make_xdcc_bot_list(cls) -> None:
        if not isfile(cls.xbot_file_path):
            cls.save_xdcc_bot_list()
        return None

    @classmethod
    def make_xdcc_chan_chat(cls) -> None:
        if not isfile(cls.xdcc_chan_chat_file_path):
            cls.save_xdcc_chan_chat()
            return None
        with open(cls.xdcc_chan_chat_file_path, 'r') as wp:
            read = wp.read()
        if not read:
            cls.save_xdcc_chan_chat()
            return None
        cls.xdcc_chan_chat = json.loads(read)
        return None

    @classmethod
    def load_xdcc_chan_chat(cls) -> None:
        with open(cls.xdcc_chan_chat_file_path, 'r') as wp:
            read = wp.read()
        if not read:
            return None
        cls.xdcc_chan_chat = json.loads(read)
        return None

    @classmethod
    def save_xdcc_chan_chat(cls) -> None:
        try:
            with open(cls.xdcc_chan_chat_file_path, 'w') as wp:
                wp.write(json.dumps(cls.xdcc_chan_chat))
        except FileNotFoundError:
            print('unable to save xdcc botsearch file.')
        return None

    @classmethod
    def make_xdcc_chans(cls) -> None:
        if not isfile(cls.xdcc_chansfile_path):
            cls.save_xdcc_chans()
            return None
        with open(cls.xdcc_chansfile_path, 'r') as wp:
            read = wp.read().strip()
        if not read:
            cls.save_xdcc_chans()
            return None
        cls.xdcc_chan_list = json.loads(read)
        return None

    @classmethod
    def load_xdcc_chans(cls) -> None:
        with open(cls.xdcc_chansfile_path, 'r') as wp:
            read = wp.read().strip()
        if not read:
            cls.save_xdcc_chans()
            return None
        cls.xdcc_chan_list = json.loads(read)
        return None

    @classmethod
    def save_xdcc_chans(cls) -> None:
        try:
            with open(cls.xdcc_chansfile_path, 'w') as wp:
                wp.write(json.dumps(cls.xdcc_chan_list))
        except FileNotFoundError:
            print('unable to save xdcc chan file.')
        return None

    @classmethod
    def save_settings(cls) -> None:
        try:
            with open(cls.settingsfile_path, 'w') as wp:
                wp.write(json.dumps(cls.Settings_json))
        except FileNotFoundError:
            print('unable to save settings.')
        return None

    @classmethod
    def make_settings(cls) -> None:
        try:
            if not isfile(cls.settingsfile_path):
                cls.save_settings()
                return None
            cls.load_settings()
        except FileNotFoundError:
            print('unable to make settings.')
        return None

    @classmethod
    def load_settings(cls) -> None:
        read: str
        with open(cls.settingsfile_path, 'r') as fp:
            read = fp.read()
        if not read:
            cls.save_settings()
            return None
        cls.Settings_json = json.loads(read)
        return None

    @classmethod
    def save_nickhistory(cls) -> None:
        try:
            with open(cls.nickhistoryfile_path, 'w') as fp:
                fp.write(json.dumps(cls.nickhistoryfile_path))
        except FileNotFoundError:
            print('unable to save your nickname history.')
        return None

    @classmethod
    def load_nickhistory(cls) -> None:
        with open(cls.nickhistoryfile_path, 'r') as fp:
            read = fp.read()
        if not read:
            cls.save_nickhistory()
            return None
        else:
            cls.Nick_History_json = json.loads(read)
        return None

    @classmethod
    def make_nickhistory(cls):
        try:
            cls.load_nickhistory()
        except FileNotFoundError:
            cls.save_nickhistory()
        return None

    @classmethod
    def nickhistory_add(cls, nick) -> None:
        """Add a nickname to the nickhistory file

            vars:
                nick: the nickname to add
        """
        if nick in cls.Nick_History_json['nicknames']:
            # move the old nickname to the end of the list
            del cls.Nick_History_json['nicknames'][nick]

        cls.Nick_History_json['nicknames'][nick] = nick

        while 11 - len(cls.Nick_History_json) < 0:
            for nick in cls.Nick_History_json:
                del cls.Nick_History_json['nicknames'][nick]
                break
        cls.save_nickhistory()
        return None

    @classmethod
    def make_user_file(cls) -> None:
        newlogin = 'user:email@no-host.com:admin:' + sha256(b'pass').hexdigest() + '\n'
        do_write = False
        if user_file.is_file():
            with open(user_file, 'r') as sfopen:
                sfread = sfopen.read()
                if sfread:
                    do_write = True
        if not do_write:
            with open(user_file, 'w') as sfopen:
                sfopen.write(newlogin)

        return None

    @classmethod
    def save_fryfile(cls) -> None:
        try:
            with open(cls.fryserverfile_path, 'w') as wpp:
                dump = json.dumps(cls.FryServer_json)
                wpp.write(dump)
        except FileNotFoundError:
            print('unable to save fry file.')
        return None

    @classmethod
    def make_fryfile(cls) -> None:
        if not isfile(cls.fryserverfile_path):
            cls.save_fryfile()
        else:
            cls.load_fryfile()

    @classmethod
    def load_fryfile(cls) -> None:
        with open(cls.fryserverfile_path, 'r') as fp:
            read = fp.read()
            if not read:
                cls.save_fryfile()
            else:
                cls.FryServer_json = json.loads(read)
        return None
