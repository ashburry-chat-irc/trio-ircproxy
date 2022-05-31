#!/usr/bin/python
# -*- coding: utf-8 -*-

# Change to .ini file
from configparser import ConfigParser
w3_server: ConfigParser = ConfigParser()
w3_server.read('www-server-config.ini')

class Server_INI(ConfigParser):
    def __init__(self):
        self.w3_server: ConfigParser = super(ConfigParser)
        self.w3_server.read('www-server-config.ini')
        if 'DEFAULT' not in self.w3_server:
            self.w3_server.add_section(self.w3_server, 'DEFAULT')
        if not 'url-prefix' in self.w3_server["DEFAULT"]:
            self.w3_server['DEFAULT']['url-prefix'] = '/'
        if not 'web-server-hostname' in self.w3_server['DEFAULT']:
            self.w3_server['DEFAULT']['web-server-hostname'] = '127.0.0.1'
        else:
            if not 'web-server-port' in self.w3_server['DEFAULT']:
                self.w3_server['DEFAULT']['web-server-port'] = '80'
        super().__init__(self)

S
    def save_w3_server(self):
        super().__init__(self)


w3_ini: Server_INI = Server_INI()

w3_prefix: str = w3_server['DEFAULT']['url-prefix'] or '/'
website_named_host: str = w3_server['DEFAULT']['web-server-hostname'] or '127.0.0.1'
website_port: int = int(w3_server['DEFAULT']['web-server-port']) or '80'
