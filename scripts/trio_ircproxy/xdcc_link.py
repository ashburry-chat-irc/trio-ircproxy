#!/usr/bin/python
# -*- coding: utf-8 -*-
from __future__ import annotations
# from typing import List
from os.path import join as osjoin
from scripts.website_and_proxy.system_data import SystemData as system_data
from pickle import dumps
from pickle import load
from time import time
from stat import ST_MTIME
from os import stat as osstat


class XdccBotSLL:
    def __init__(self):
        self.head = None
        self.xchans: dict = {}
        self.xcount: int = 0

    def add(self, NewNode):
        """Add am XdccBpt object to the SSL"""
        if not isinstance(NewNode, XdccBot):
            return
        if self.head is not None:
            for node in self.head:
                if node.nick == NewNode.nick and node.network == NewNode.network:
                    print('WARNING: Xdcc Bot Already Exists IN LIST...')
                    return
        NewNode.nextdata = self.head
        self.head = NewNode

    def add_pack(self, nick, xchan, pack_num, pack_desc):
        """One of two ways of editing pack list, this one equires nicSk and xchan"""
        nextval = self.head
        while nextval:
            if nextval.nick == nick and nextval.xchan == xchan:
                nextval.add_pack(pack_num, pack_desc)
                return
            nextval = nextval.nextdata

    def new_nick(self, oldnick, newnick, network):
        """Change the nickname of a bot"""
        nextval = self.head
        while nextval:
            if nextval.network == network and nextval.nick.lower() == oldnick.lower():
                nextval.nick = newnick
                return
            nextval = nextval.nextdata

    def save_list(self) -> None:
        """Save the xdcc_list to the file every now and then"""
        if self.head == None: return
        xdcc_list: XdccBot = self.head
        xlist_file: str = osjoin(system_data.xdccdir_path, "xdcc_list.pkl")
        xchans_file: str = osjoin(system_data.xdccdir_path, "xchans.pkl")
        xcount_file: str = osjoin(system_data.xdccdir_path, "xcount.pkl")
        with open(xlist_file, 'wb') as xfile_open:
            xfile_open.write(dumps(xdcc_list))
        with open(xchans_file, 'wb') as xfile_open:
            xfile_open.write(dumps(self.xchans))
        with open(xcount_file, 'wb') as xfile_open:
            xfile_open.write(dumps(self.xcount))

    def load_list(self):
        xlist_file: str = osjoin(system_data.xdccdir_path, "xdcc_list.pkl")
        xchans_file: str = osjoin(system_data.xdccdir_path, "xchans.pkl")
        xcount_file: str = osjoin(system_data.xdccdir_path, "xcount.pkl")
        fileStatsObj = osstat(xlist_file)
        aged = time() - fileStatsObj[ST_MTIME]
        if aged > (3600 * 7):
            print("Packlist is over 7 hours old; starting new.")
            return
        try:
            with open(xlist_file, 'rb') as xfile_open:
                self.head = load(xfile_open)
            with open(xchans_file, 'rb') as xfile_open:
                self.xchans = load(xfile_open)
            with open(xcount_file, 'rb') as xfile_open:
                self.xcount = load(xfile_open)
        except EOFError:
            with open(xlist_file, 'rb') as xfile_open:
                self.head = load(xfile_open)
            with open(xchans_file, 'rb') as xfile_open:
                self.xchans = load(xfile_open)
            with open(xcount_file, 'rb') as xfile_open:
                self.xcount = load(xfile_open)


class XdccBot:
    highest_pack = 0
    """This object holds the data for a single xdcc bot"""

    def __init__(self, fullnick, xchan, network, *, chat_chan=None):
        if not chat_chan:
            chat_chan = ''
        self.fullnick = fullnick
        self.nick = fullnick.split("!")[0]
        self.xchan = xchan
        self.chat_chan = chat_chan
        self.network = network
        self.packlist = []
        self.nextdata = None
        # we need to know if we started in the middle
        # and came around to the beginning:
        self.prev_pack = 0
        self.high_pack = 0

    def __repr__(self):
        """Change the return value for a bot to something better"""
        return ('XdccBot', 'packs: ' + str(len(self.packlist)), 'channel: ' + self.xchan)

    def add_pack(self, packnum: str, packdesc: str) -> None:
        """Add a pack to the packlist for this bot"""
        if not packnum or not packdesc:
            return None
        try:
            pound: str = packnum[0:1]
            packnum_int: int
            if pound.isdigit() is False:
                packnum_int = int(packnum[1:])
            else:
                packnum_int = int(packnum)
        except (ValueError, IndexError, TypeError):
            return None

        if self.high_pack < packnum_int:
            self.high_pack = packnum_int
        if packnum_int < self.prev_pack:
            self.high_pack = self.prev_pack
        self.prev_pack = packnum_int

        packnum = '#' + str(packnum_int)
        pack = (packnum, packdesc)
        pack_n = 0
        for nextpack in self.packlist:
            if nextpack[0] == packnum:
                del self.packlist[pack_n]
                break
            pack_n += 1
        self.packlist.append(pack)
        self.packlist.sort()
        return None
