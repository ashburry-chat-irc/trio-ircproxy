#!/usr/bin/python
# -*- coding: utf-8 -*-
from __future__ import annotations

from flask import render_template, make_response, request, url_for, redirect
from flask import Blueprint, flash, jsonify
from flask_login import login_required, current_user
import sys

from website import APP_DIR, STATIC_DIR
from user_db import Note
from user_db import db
import json


def no_cache(resp):
    resp.headers['Cache-Control'] = 'max-age=1, No-Store'

views = Blueprint('views', __name__)

@views.errorhandler(404)
def not_found(e):
    return make_response(render_template('404.html', user=current_user), 404)

@views.route('/images/screenshot00.jpg', methods=['GET', 'POST', 'HEAD'])
def screen00():
    resp = make_response(open('./static/images/Screenshot00.jpg', 'rb').read(), 200, {'Content-Type':
                                                                                          'image/jpeg; charset=utf-8'})
    return resp


@views.route('/images/background.jpg', methods=['GET', 'HEAD'])
def background():
    with open(STATIC_DIR[0] / 'background.jpg', 'rb') as sfopen:
        resp = make_response(sfopen.read(), 200, {'Content-Type': 'image/jpeg; charset=utf-8'})
    return resp


@views.route('/favicon.ico', methods=['GET', 'HEAD'])
def favicon():
    with open(STATIC_DIR[0] / 'favicon.ico', 'rb') as sfopen:
        resp = make_response(sfopen.read(), 200, {'Content-Type': 'image/jpeg; charset=utf-8'})
    return resp


@views.route('/site.webmanifest', methods=['GET', 'HEAD'])
def manifest():
    with open(STATIC_DIR[0] / 'site.webmanifest', 'r') as sfopen:
        resp = make_response(sfopen.read(), 200, {'Content-Type': 'text/ascii; charset=utf-8'})
    return resp


@views.route('/android-chrome-192x192.png', methods=['GET', 'HEAD'])
def androidchrome192():
    with open(STATIC_DIR[0] / 'android-chrome-192x192.png', 'rb') as sfopen:
        resp = make_response(sfopen.read(), 200, {'Content-Type': 'image/png; charset=utf-8'})
    return resp


@views.route('/android-chrome-512x512.png', methods=['GET', 'HEAD'])
def androidchrome512():
    with open(STATIC_DIR[0] / 'android-chrome-512x512.png', 'rb') as sfopen:
        resp = make_response(sfopen.read(), 200, {'Content-Type': 'image/png; charset=utf-8'})
    return resp


@views.route('/apple-touch-icon.png', methods=['GET', 'HEAD'])
def androidappletouch():
    with open(STATIC_DIR[0] / 'apple-touch-icon.png', 'rb') as sfopen:
        resp = make_response(sfopen.read(), 200, {'Content-Type': 'image/png; charset=utf-8'})
    return resp


@views.route('/favicon-16x16.png', methods=['GET', 'HEAD'])
def androidfavicon16():
    with open(STATIC_DIR[0] / 'favicon-16x16.png', 'rb') as sfopen:
        resp = make_response(sfopen.read(), 200, {'Content-Type': 'image/png; charset=utf-8'})
    return resp


@views.route('/favicon-32x32.png', methods=['GET', 'HEAD'])
def androidfavicon32():
    with open(STATIC_DIR[0] / 'favicon-32x32.png', 'rb') as sfopen:
        resp = make_response(sfopen.read(), 200, {'Content-Type': 'image/png; charset=utf-8'})
    return resp
@views.route('/coc/index.py', methods=['GET', 'HEAD'])
@views.route('/coc/index.htm', methods=['GET', 'HEAD'])
@views.route('/coc/index.html', methods=['GET', 'HEAD'])
@views.route('/coc/', methods=['GET', 'HEAD'])
@views.route('/code-of-conduct/', methods=['GET', 'HEAD'])
@views.route('/code_of_conduct/', methods=['GET', 'HEAD'])
@views.route('/codeofconduct/', methods=['GET', 'HEAD'])
@views.route('/coc/code-of-conduct.py', methods=['GET', 'HEAD'])
@views.route('/coc/code-of-conduct.htm', methods=['GET', 'HEAD'])
@views.route('/coc/code-of-conduct.html', methods=['GET', 'HEAD'])
@views.route('/coc/code_of_conduct.py', methods=['GET', 'HEAD'])
@views.route('/coc/code_of_conduct.htm', methods=['GET', 'HEAD'])
@views.route('/coc/code_of_conduct.html', methods=['GET', 'HEAD'])
def coc():
    resp = make_response(render_template('coc.html', user=current_user), 200)
    no_cache(resp)
    return resp

@views.route('/xdcc-search.html', methods=['GET', 'HEAD'])
@views.route('/xdcc-search.py', methods=['GET', 'HEAD'])
@views.route('/xdcc-search/', methods=['GET', 'HEAD'])
@views.route('/xdcc-search.htm', methods=['GET', 'HEAD'])
@views.route('/xdccsearch/', methods=['GET', 'HEAD'])
@views.route('/search/xdcc.py', methods=['GET', 'HEAD'])
@views.route('/search/xdcc.htm', methods=['GET', 'HEAD'])
@views.route('/search/xdcc.html', methods=['GET', 'HEAD'])
def xdcc_search():
    resp = make_response(render_template('xdcc-search.html', user=current_user), 200)
    no_cache(resp)
    return resp


@views.route('/licence/', methods=['GET', 'HEAD'])
@views.route('/licence/index.htm', methods=['GET', 'HEAD'])
@views.route('/licence/index.html', methods=['GET', 'HEAD'])
@views.route('/licence/index.py', methods=['GET', 'HEAD'])
@views.route('/licence.py', methods=['GET', 'HEAD'])
@views.route('/licence.htm', methods=['GET', 'HEAD'])
@views.route('/licence.html', methods=['GET', 'HEAD'])
def lic_root():
    resp = make_response(render_template('licence.html', user=current_user),200)
    no_cache(resp)
    return resp


@views.route('/flood.py', methods=['GET', 'HEAD'])
@views.route('/flood.html', methods=['GET', 'HEAD'])
@views.route('/flood/', methods=['GET', 'HEAD'])
@views.route('/flood/index.html', methods=['GET', 'HEAD'])
@views.route('/flood/index.htm', methods=['GET', 'HEAD'])
@views.route('/flood.htm', methods=['GET', 'HEAD'])
def flood():
    resp = make_response(render_template('flood.html', user=current_user),200)
    no_cache(resp)
    return resp


@views.route('/googlea65989cd75834c79.html/', methods=['GET', 'HEAD'])
def sitemap_google():
    resp = make_response(render_template('keep-this-sitemap-verification.html'), 200)
    no_cache(resp)
    return resp


@views.route('/delete-note', methods=['POST'])
def delete_note():
    note = json.loads(request.data)
    noteId = note['noteId']
    note = Note.query.get(noteId)
    if note:
        if note.user_id == current_user.id:
            db.session.delete(note)
            db.session.commit()

    return jsonify({})


@views.route('/home/index.html', methods=['GET', 'HEAD'])
@views.route('/home/index.htm', methods=['GET', 'HEAD'])
@views.route('/home/', methods=['GET', 'HEAD'])
@views.route('/home.htm', methods=['GET', 'HEAD'])
@views.route('/home.html', methods=['GET', 'HEAD'])
@views.route('/home.py', methods=['GET', 'HEAD'])
@views.route('/index.html', methods=['GET', 'HEAD'])
@views.route('/index.htm', methods=['GET', 'HEAD'])
@views.route('/index/', methods=['GET', 'HEAD'])
@views.route('/index.py', methods=['GET', 'HEAD'])
@views.route('/home/index.py', methods=['GET', 'HEAD'])
@views.route('/', methods=['GET', 'HEAD'])
def home():
    resp = make_response(render_template('index.html', user=current_user), 200)
    no_cache(resp)
    return resp


@views.route('/about/', methods=['GET', 'HEAD'])
@views.route('/about.py', methods=['GET', 'HEAD'])
@views.route('/about.htm', methods=['GET', 'HEAD'])
@views.route('/about.html', methods=['GET', 'HEAD'])
def about():
    resp = make_response(render_template('about.html', user=current_user), 200)
    no_cache(resp)
    return resp



@views.route('/bouncers/', methods=['GET', 'HEAD'])
@views.route('/vhost/', methods=['GET', 'HEAD'])
@views.route('/vhosts/', methods=['GET', 'HEAD'])
@views.route('/proxy/', methods=['GET', 'HEAD'])
@views.route('/proxies/', methods=['GET', 'HEAD'])
@views.route('/vhosts.html', methods=['GET', 'HEAD'])
@views.route('/vhosts.htm', methods=['GET', 'HEAD'])
@views.route('/vhosts.py', methods=['GET', 'HEAD'])
@views.route('/vhost.html', methods=['GET', 'HEAD'])
@views.route('/vhost.htm', methods=['GET', 'HEAD'])
@views.route('/vhost.py', methods=['GET', 'HEAD'])
@views.route('/bounce/', methods=['GET', 'HEAD'])
@views.route('/bounce.htm', methods=['GET', 'HEAD'])
@views.route('/bouncers.htm', methods=['GET', 'HEAD'])
@views.route('/bouncers.html', methods=['GET', 'HEAD'])
@views.route('/bouncers.py', methods=['GET', 'HEAD'])
@views.route('/bounce.html', methods=['GET', 'HEAD'])
@views.route('/bounce.py', methods=['GET', 'HEAD'])
@views.route('/proxy.py', methods=['GET', 'HEAD'])
@views.route('/proxy.htm', methods=['GET', 'HEAD'])
@views.route('/proxy.html', methods=['GET', 'HEAD'])
@views.route('/proxies.py', methods=['GET', 'HEAD'])
@views.route('/proxies.htm', methods=['GET', 'HEAD'])
@views.route('/proxies.html', methods=['GET', 'HEAD'])
@views.route('/bnc/bouncers/', methods=['GET', 'HEAD'])
@views.route('/bnc/bounce/', methods=['GET', 'HEAD'])
@views.route('/bnc/vhost/', methods=['GET', 'HEAD'])
@views.route('/bnc/vhosts/', methods=['GET', 'HEAD'])
@views.route('/bnc/proxy/', methods=['GET', 'HEAD'])
@views.route('/bnc/proxies/', methods=['GET', 'HEAD'])
@views.route('/bnc/vhosts.html', methods=['GET', 'HEAD'])
@views.route('/bnc/vhosts.htm', methods=['GET', 'HEAD'])
@views.route('/bnc/vhosts.py', methods=['GET', 'HEAD'])
@views.route('/bnc/vhost.html', methods=['GET', 'HEAD'])
@views.route('/bnc/vhost.htm', methods=['GET', 'HEAD'])
@views.route('/bnc/vhost.py', methods=['GET', 'HEAD'])
@views.route('/bnc/bounce.htm', methods=['GET', 'HEAD'])
@views.route('/bnc/bouncers.htm', methods=['GET', 'HEAD'])
@views.route('/bnc/bouncers.html', methods=['GET', 'HEAD'])
@views.route('/bnc/bouncers.py', methods=['GET', 'HEAD'])
@views.route('/bnc/bounce.html', methods=['GET', 'HEAD'])
@views.route('/bnc/bounce.py', methods=['GET', 'HEAD'])
@views.route('/bnc/proxy.py', methods=['GET', 'HEAD'])
@views.route('/bnc/proxy.htm', methods=['GET', 'HEAD'])
@views.route('/bnc/proxy.html', methods=['GET', 'HEAD'])
@views.route('/bnc/proxies.py', methods=['GET', 'HEAD'])
@views.route('/bnc/proxies.html', methods=['GET', 'HEAD'])
@views.route('/bnc/proxies.htm', methods=['GET', 'HEAD'])
def bounce():
    vj: dict
    with open(APP_DIR[0] / 'bnc.json', 'r') as sfopen:
        vj = json.load(sfopen)
    resp = make_response(render_template('bounce.html', user=current_user, bnc_list=vj), 200)
    no_cache(resp)
    return resp
