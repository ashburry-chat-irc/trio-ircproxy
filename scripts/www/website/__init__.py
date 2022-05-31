#!/usr/bin/python
# -*- coding: utf-8 -*-
from __future__ import annotations

from pathlib import Path

STATIC_DIR: list[Path | str] = ['']
TEMPLATE_DIR: list[Path | str] = ['']
APP_DIR: list[Path | str] = ['']


def set_dirs(static: str, template: str, app: str):
    STATIC_DIR[0] = Path(static)
    TEMPLATE_DIR[0] = Path(template)
    APP_DIR[0] = Path(app)

w3_prefix: str = '/'    # The root path in the URL for the trio-ircproxy website.
website_named_host: str = '127.0.0.1'
website_port: int = 80
