#!/usr/bin/python
# -*- coding: utf-8 -*-

from __future__ import annotations

# Change to .ini file
from configparser import ConfigParser
from os import environ
from os import path
_dir = path.dirname(path.abspath(__file__))
ini_file = path.join(_dir, '..', 'www-server-config.ini')

w3_server: ConfigParser = ConfigParser()
w3_server.read(ini_file)

if 'DEFAULT' not in w3_server:
    w3_server.add_section('DEFAULT')
if not 'url-prefix' in w3_server["DEFAULT"]:
    w3_server['DEFAULT']['url-prefix'] = '/'
if not 'web-server-hostname' in w3_server['DEFAULT']:
    w3_server['DEFAULT']['web-server-hostname'] = '127.0.0.1'
if not 'web-server-port' in w3_server['DEFAULT']:
    w3_server['DEFAULT']['web-server-port'] = '80'

if 'Service' not in w3_server:
    w3_server.add_section('Service')

if 'PYTHONANYWHERE_DOMAIN' in environ and 'USERNAME' in environ:
    url = environ['USERNAME'] + '.' + environ['PYTHONANYWHERE_DOMAIN']
    w3_server['Service']['web-server-hostname'] = url

with open(ini_file, 'w') as fpwrite:
    w3_server.write(fpwrite, space_around_delimiters=True)

w3_prefix: str = w3_server['Service']['url-prefix'] or '/'
website_named_host: str = w3_server['Service']['web-server-hostname'] or '127.0.0.1'
website_port: int = int(w3_server['Service']['web-server-port']) or 80
