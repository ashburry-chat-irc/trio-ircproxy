#!/usr/bin/python
# -*- coding: utf-8 -*-

"""
This script runs the application using an production server on your local machine or as an app when imported
by PythonAnywhere.com.

On PythonAnywhere.com click on the "WEB" link and scroll down to where it says:
"Source Code:" and change it to "/home/username/www/" set your "Working directory" to /home/username/,
if not already set to such values.

This script provides an  "app" variable suitable for PythonAnywhere.com server and will not run as
an server if flask_app.py is imported, instead of executed on the command line.

Edit the www-server-config.ini file to set your

"""
from __future__ import annotations

# from werkzeug.datastructures import RequestCacheControl as RCC
import sys
from os import path
from os.path import exists

from flask import Flask
from flask_login import LoginManager

from website.cwd_flask import w3_prefix, website_named_host, website_port

_dir = path.dirname(path.abspath(__file__))
w3_dir = path.join(_dir, "website", "templates")
w3proxy_dir = path.join(_dir, "..", "website_and_proxy")
sys.path.insert(0, w3_dir)
sys.path.insert(0, w3proxy_dir)
from user_db import User
from user_db import db

app_new = Flask(__name__)

DB_NAME = "database.db"


def create_app():

    app_new.config['SECRET_KEY'] = 'p0ldogn678xkdmcvf876lopr45bgnmkiyfxzaqw345tyu8'
    app_new.config['SQLALCHEMY_DATABASE_URI'] = f'sqlite:///{DB_NAME}'
    app_new.config['SQLALCHEMY_TRACK_MODIFICATIONS'] = False
    app_new.config['SERVER_NAME'] = website_named_host or '127.0.0.1'
    db.init_app(app_new)
    w3_root: str = w3_prefix or '/'
    from website.views import views
    from website.auth import auth
    if not auth:
        return
    app_new.register_blueprint(views, url_prefix=w3_root)
    app_new.register_blueprint(auth, url_prefix=w3_root)

    create_database(app_new)

    login_manager = LoginManager()
    login_manager.login_view = '..auth.login'
    login_manager.init_app(app_new)

    @login_manager.user_loader
    def load_user(id):
        return User.query.get(int(id))

    _dir = path.dirname(path.abspath(__file__))
    app_new.template_folder = path.join(_dir, "website", "templates")
    app_new.static_folder = path.join(_dir, "website", "static")
    from website import APP_DIR, STATIC_DIR
    APP_DIR[0] = path.join(_dir, "app")
    STATIC_DIR[0] = app_new.static_folder
    return app_new


def create_database(app):
    if not exists(DB_NAME):
        db.create_all(app=app)


def begin_flask():
    try:
        from twisted.internet import reactor
        from twisted.web.server import Site
        from twisted.web.wsgi import WSGIResource
        from twisted.internet.error import CannotListenError, ReactorNotRestartable as RNR_Error
        i_port: int = int(website_port) or 80
        n_host: str = str(website_named_host) or '127.0.0.1'
        # Uncomment the 3 lines below and comment out the app.run() for Windows
        # compatable production server.
        flask_site = WSGIResource(reactor, reactor.getThreadPool(), app)
        reactor.listenTCP(i_port, Site(flask_site), 65535, n_host)
        print(f"-+\nOpening flask_app.py on port number {str(i_port)} on hostname {n_host}\n-+")
        reactor.run()
        #app.run(n_host, i_port, debug=True)
    except CannotListenError:
        print("\nERROR: Unable to listen on flask web-server port number " + str(i_port) + '.')
        print("flask_app.py must be already running somewhere,")
        print("or the listening port is in use by some other app.")
        print(f"Or, if you are using Linux, you may not have privileged access to listen on the port ({str(i_port)}).")
    except RNR_Error:
        pass


app = create_app()

if __name__ == '__main__':
    begin_flask()
