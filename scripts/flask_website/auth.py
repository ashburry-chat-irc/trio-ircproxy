from __future__ import annotations

from flask import Blueprint, make_response, render_template, request, flash, redirect, url_for
from werkzeug.security import generate_password_hash, check_password_hash
from flask_login import login_user, login_required, logout_user, current_user
from flask_sqlalchemy import BaseQuery
from time import time

from json_data import json_data

import json

import sys

from __init__ import APP_DIR
from user_db import User
from user_db import db
from json_data import json_data

auth = Blueprint('auth', __name__)


def no_cache(resp):
    resp.headers['Cache-Control'] = 'max-age=1, No-Store'


@auth.route('/admin-create/', methods=['GET', 'POST', 'HEAD'])
def admin_create():
    if hasattr(current_user, 'user_name'):
        if not current_user.type == 'admin-not-ready':
            redirect(url_for('views.bounce'))
    else:
        return redirect(url_for('auth.not_admin'))
    if request.method == 'POST':
        email = request.form.get('email').lower()
        password1 = request.form.get('password1')
        password2 = request.form.get('password2')
        if password1 != password2 or not password1 or not password2:
            flash('Passwords do not match.', category='error')
        elif not email and len(email) < 4:
            flash('Email is too short, must be longer than 3 characters.')
        elif ('@' not in email):
            flash('That is not an email address.', category='error')
        else:
            ip = request.environ['REMOTE_ADDR']
            admin = User.query.filter_by(user_name='admin').first()
            admin.type = 'admin'
            admin.email = email
            admin.ip = ip
            admin.password = generate_password_hash(password1, method='sha256')
            db.session.commit()
            login_user(admin, remember=True)
            flash('administrator account is created! pls remember your password.', category='success')
            return redirect(url_for('views.bounce'))
    resp = make_response(render_template("admin.html", user=current_user), 200)
    no_cache(resp)
    return resp


@auth.route('/settings/', methods=['GET', 'HEAD', 'POST'])
@auth.route('/settings.py', methods=['GET', 'HEAD', 'POST'])
@auth.route('/settings.html', methods=['GET', 'HEAD', 'POST'])
@auth.route('/settings.htm', methods=['GET', 'HEAD', 'POST'])
@auth.route('/bnc/settings.py', methods=['GET', 'HEAD', 'POST'])
@auth.route('/bnc/settings.html', methods=['GET', 'HEAD', 'POST'])
@auth.route('/bnc/settings.htm', methods=['GET', 'HEAD', 'POST'])
@auth.route('/admin/bnc-settings.htm', methods=['GET', 'HEAD', 'POST'])
@auth.route('/admin/bnc-settings.py', methods=['GET', 'HEAD', 'POST'])
@auth.route('/admin/bnc-settings.html', methods=['GET', 'HEAD', 'POST'])
def settings():
    if current_user.is_authenticated:
        resp = make_response(render_template('settings.html', user=current_user), 200)
        no_cache(resp)
        return resp
    else:
        return redirect(url_for('auth.login'))

@auth.route('/admin/post/home-data.html', methods=['POST'])
def home_data(xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx=None

























































































































































































































































































































































































































































              ccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc                                                                                 xxxxxxxxxxxxxxxxxxxxxxxxxxxxx                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                       ):
    if request.method != 'POST':
        return redirect(url_for('/admin/admin-settings.html'))
    if hasattr(current_user, 'user_name') and current_user.user_name != 'admin':
        flash('you MUST log-in as the Admin to post to this URL.')
        return redirect(url_for('auth.login'))
    home_err: bool = False
    if not request.form.get('server_name'):
        home_err = True
        flash('invalid Server Name.', category='error')
    for c in request.form.get('server_name'):
        c = c.lower()
        if ord(c) in range(48, 58) and ord(c) not in range(97, 123) and ord(c) != 95 and ord(c) != 46:
            home_err = True
            flash('Server Name contains invalid symbols.', category='error')
    if not home_err:
        json_data.home['home']['server_name'] = request.form.get('server_name')
    home_err: bool = False
    if not request.form.get('admin_name'):
        home_err = True
        flash('missing Admin NickName.', category='error')
    for c in request.form.get('admin_name'):
        c = c.lower()
        if ord(c) in range(48, 58) and ord(c) not in range(97, 123) and ord(c) != 95 and ord(c) != 46:
            home_err = True
            flash('Admin Name contains invalid symbols.', category='error')
    if not home_err:
        json_data.home['home']['admin'] = request.form.get('admin_name')
    home_err: bool = False
    if not request.form.get('email'):
        home_err = True
        flash("missing Admin Email Address.", category='error')
    if '@' not in request.form.get('email'):
        home_err = True
        flash('invalid Admin Email Address.', category='error')
    from fnmatch import fnmatch

    if not fnmatch(request.form.get('email'), '?*@?*'):
        home_err = True
        flash('invalid Admin Email Address.', category='error')
    if not home_err:
        json_data.home['home']['email'] = request.form.get('email').lower()

    home_err: bool = False
    if not request.form.get('smtp_password1'):
        home_err = True

    if not home_err:
        json_data.home
         xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx['home']['smtp_password1'] = request.form.get('smtp_password1')

    home_err: bool = False
    if not request.form.get('smtp_password2'):
        home_err = True

    if request.form.get('smtp_password2') != request.form.get('smtp_password1'):
        home_err = True
        flash("the Passwords you entered do not match, retype; then resend the form again.", category='error')
    if not home_err:
        json_data['home']['smtp_password2'] = request.form.get('smtp_password2')
    return redirect(url_for('auth.admin_settings'))

@auth.route('/admin-settings/', methods=['GET', 'POST', 'HEAD'])
@auth.route('/admin/admin-settings.htm', methods=['GET', 'POST', 'HEAD'])
@auth.route('/admin/admin-settings.html', methods=['GET', 'POST', 'HEAD'])
def admin_settings():
    if hasattr(current_user, 'user_name') and current_user.user_name == 'admin':
        from json_data import json_data
        resp = make_response(render_template("admin_settings.html", user=current_user, json_data=json_data), 200)
        no_cache(resp)
        return resp
    else:
        flash("you are not logged-in as administrator.", category='error')
        return redirect(url_for('auth.not_admin'))


from random import randrange

forgot_valid: dict[str, dict[str, bool]] = {}


@auth.route('/forgot/', methods=['GET', 'POST', 'HEAD'])
@auth.route('/forgot.py', methods=['GET', 'POST', 'HEAD'])
@auth.route('/forgot.html', methods=['GET', 'POST', 'HEAD'])
@auth.route('/forgot.htm', methods=['GET', 'POST', 'HEAD'])
@auth.route('/admin/forgot.py', methods=['GET', 'POST', 'HEAD'])
@auth.route('/admin/forgot.html', methods=['GET', 'POST', 'HEAD'])
@auth.route('/admin/forgot.htm', methods=['GET', 'POST', 'HEAD'])
def forgot():
    if request.method == 'POST':
        get_user_name = request.form.get('user_name').lower()
        get_email = request.form.get('email').lower()
        if not get_user_name and not get_email:
            flash("you need to enter your UserName and/or E-Mail address.")
        else:
            try:
                user: User | None = None
                email: BaseQuery | None = None
                if get_user_name:
                    user = User.query.filter_by(user_name=get_user_name).first()
                if get_email:
                    email = User.query.filter_by(email=get_email)
                if not user and get_email and email.count() == 0:
                    flash('unknown UserName and E-Mail address.', category='error')
                else:
                    ran: str = str(randrange(10000000, 999999999999999))
                    forgot_valid[ran] = {}
                    valid: bool = forgot_password_request(user, email, forgot_valid[ran])
                    return redirect(url_for("auth.forgot_accepted", valid_pass=ran))
            except:
                raise
                pass
    resp = make_response(render_template("forgot.html", user=current_user), 200)
    no_cache(resp)
    return resp


def forgot_password_request(user: User | bool, email: BaseQuery, ran: dict[str, bool]) -> bool:
    """

    """
    email_set: set[str] = set()
    if user and hasattr(user, 'email'):
        email_set.add(user.email)
        # send email
    if email:
        for e in email:
            email_set.add(e.email)
    for em in email_set:
        ran[em] = False
    if not email_set:
        return False
    else:
        if 'smtp_server' in json_data.home:
            smtp_server = json_data.home['smtp_server'][0]
        if not email:
            return True
        for user in email:
            pass
    return True


@auth.route('/admin/forgot-accepted/', methods=['GET', 'HEAD'])
@auth.route('/admin/forgot-accepted.html', methods=['GET', 'HEAD'])
@auth.route('/admin/forgot-accepted.py', methods=['GET', 'HEAD'])
@auth.route('/admin/forgot-accepted.htm', methods=['GET', 'HEAD'])
def forgot_accepted():
    q: str = request.environ['QUERY_STRING']
    q_split: list[str] = q.split('=')
    q_found: bool = False
    valid_pass: str = ''
    accounts: bool | dict[str, str] = False
    for q in q_split:
        if q_found:
            valid_pass = q
            break
        if q == 'valid_pass':
            q_found = True
            continue
    if valid_pass:
        accounts = forgot_valid.get(valid_pass, False)
        if accounts:
            del forgot_valid[valid_pass]
            resp = make_response(render_template("forgot-accepted.html",
                                                 user=current_user, accounts=accounts), 200)
            no_cache(resp)
            return resp
        else:
            return redirect(url_for('auth.link_expired'))
    else:
        return redirect(url_for('views.home'))


@auth.route("/forgot-expired/", methods=['GET', 'HEAD'])
@auth.route("/forgot-expired.py", methods=['GET', 'HEAD'])
@auth.route("/forgot-expired.html", methods=['GET', 'HEAD'])
@auth.route("/forgot-expired.htm", methods=['GET', 'HEAD'])
def link_expired():
    return make_response(render_template('forgot-expired.html', user=current_user), 200)


@auth.route('/admin/not-admin/', methods=['GET', 'POST', 'HEAD'])
@auth.route('/admin/not-admin.html', methods=['GET', 'POST', 'HEAD'])
@auth.route('/admin/not-admin.py', methods=['GET', 'POST', 'HEAD'])
@auth.route('/admin/not-admin.htm', methods=['GET', 'POST', 'HEAD'])
def not_admin():
    if not hasattr(current_user, 'user_name') or current_user.user_name != 'admin':
        resp = make_response(render_template("not_admin.html", user=current_user), 200)
        no_cache(resp)
        return resp
    if hasattr(current_user, 'user_name') and current_user.user_name == 'admin':
        return redirect(url_for('auth.admin'))


@auth.route('/admin/', methods=['GET', 'POST', "HEAD"])
@auth.route('/admin/index.html', methods=['GET', 'POST', "HEAD"])
@auth.route('/admin/index.htm', methods=['GET', 'POST', "HEAD"])
@auth.route('/admin/index.py', methods=['GET', 'POST', "HEAD"])
@auth.route('/admin/admin.py', methods=['GET', 'POST', "HEAD"])
@auth.route('/admin/admin.htm', methods=['GET', 'POST', "HEAD"])
@auth.route('/admin/admin.html', methods=['GET', 'POST', "HEAD"])
def admin():
    if hasattr(current_user, 'user_name'):
        if current_user.type == 'admin-not-ready':
            return redirect(url_for('auth.admin_create'))
        if current_user.user_name == 'admin':
            return redirect(url_for('auth.admin_settings'))

    try:
        admin_exists = User.query.filter_by(user_name='admin').first()
        if admin_exists:
            return redirect(url_for('auth.not_admin'))
    except:
        ip = request.environ['REMOTE_ADDR']
        new_user = User(email='noadmin@yoursite.com', type="admin-not-ready", user_name='admin', ip=ip,
                        password=generate_password_hash('no-password', method='sha256'))
        db.session.add(new_user)
        db.session.commit()
        login_user(new_user, remember=True)
        flash('admin account created. change the password right now!', category='success')
        return redirect(url_for('auth.admin_create'))


@auth.route('/login.html', methods=['GET', 'POST', 'HEAD'])
@auth.route('/login/login.htm', methods=['GET', 'POST', 'HEAD'])
@auth.route('/login/login.html', methods=['GET', 'POST', 'HEAD'])
@auth.route('/login/index.htm', methods=['GET', 'POST', 'HEAD'])
@auth.route('/login/index.html', methods=['GET', 'POST', 'HEAD'])
@auth.route('/login/', methods=['GET', 'POST', 'HEAD'])
@auth.route('/login.htm', methods=['GET', 'POST', 'HEAD'])
@auth.route('/admin/login/', methods=['GET', 'POST', 'HEAD'])
@auth.route('/admin/login.html', methods=['GET', 'POST', 'HEAD'])
@auth.route('/admin/login.py', methods=['GET', 'POST', 'HEAD'])
@auth.route('/admin/login.htm', methods=['GET', 'POST', 'HEAD'])
def login():
    if request.method == 'POST':
        user_name = request.form.get('user_name').lower()
        password = request.form.get('password')
        if not user_name and not password:
            flash('you must enter your UserName and Password to log-in.')
        elif not user_name:
            flash('you did not enter your UserName.')
        elif not password:
            flash('you did not enter your Password.')
        else:
            user: User = User.query.filter_by(user_name=user_name).first()
            if user:
                if check_password_hash(user.password, password):
                    flash('logged-in successfully!', category='success')
                    login_user(user, remember=True)
                    return redirect(url_for('views.bounce'))
                else:
                    flash('incorrect Password, try again.', category='error')
            else:
                flash('UserName does not exist!', category='error')
    resp = make_response(render_template("login.html", user=current_user), 200)
    no_cache(resp)
    return resp

@auth.route('/logout/', methods=['GET', 'HEAD'])
@auth.route('/logout/logout.html', methods=['GET', 'HEAD'])
@auth.route('/logout/logout.htm', methods=['GET', 'HEAD'])
@auth.route('/logout/index.html', methods=['GET', 'HEAD'])
@auth.route('/logout/index.htm', methods=['GET', 'HEAD'])
@auth.route('/logout.htm', methods=['GET', 'HEAD'])
@auth.route('/logout.py', methods=['GET', 'HEAD'])
@auth.route('/logout.html', methods=['GET', 'HEAD'])
@auth.route('/admin/logout/', methods=['GET', 'HEAD'])
@auth.route('/admin/logout.py', methods=['GET', 'HEAD'])
@auth.route('/admin/logout.htm', methods=['GET', 'HEAD'])
@auth.route('/admin/logout.html', methods=['GET', 'HEAD'])
def logout():
    if current_user.is_authenticated:
        flash("you have logged-out.")
        logout_user()
        return redirect(url_for('views.home'))
    else:
        flash("you are not logged-in.")
        resp = make_response(render_template("logout.html", user=current_user), 200)
        no_cache(resp)
        return resp


@auth.route('/sign-up/', methods=['GET', 'POST', 'HEAD'])
@auth.route('/signup/', methods=['GET', 'POST', 'HEAD'])
@auth.route('/sign-up.htm', methods=['GET', 'POST', 'HEAD'])
@auth.route('/signup.html', methods=['GET', 'POST', 'HEAD'])
@auth.route('/sign-up.html', methods=['GET', 'POST', 'HEAD'])
@auth.route('/sign-up/index.htm', methods=['GET', 'POST', 'HEAD'])
@auth.route('/signup/index.htm', methods=['GET', 'POST', 'HEAD'])
@auth.route('/signup/index.html', methods=['GET', 'POST', 'HEAD'])
@auth.route('/sign-up/index.html', methods=['GET', 'POST', 'HEAD'])
@auth.route('/sign-up/sign-up.htm', methods=['GET', 'POST', 'HEAD'])
@auth.route('/sign-up/signup.html', methods=['GET', 'POST', 'HEAD'])
@auth.route('/signup/sign-up.htm', methods=['GET', 'POST', 'HEAD'])
@auth.route('/signup/signup.html', methods=['GET', 'POST', 'HEAD'])
@auth.route('/sign-up/sign-up.html', methods=['GET', 'POST', 'HEAD'])
@auth.route('/signup/sign-up.html', methods=['GET', 'POST', 'HEAD'])
@auth.route('/signup.htm', methods=['GET', 'POST', 'HEAD'])
@auth.route('/admin/sign-up/', methods=['GET', 'POST', 'HEAD'])
@auth.route('/admin/signup/', methods=['GET', 'POST', 'HEAD'])
@auth.route('/admin/sign-up.htm', methods=['GET', 'POST', 'HEAD'])
@auth.route('/admin/signup.html', methods=['GET', 'POST', 'HEAD'])
@auth.route('/admin/sign-up.html', methods=['GET', 'POST', 'HEAD'])
@auth.route('/admin/signup.htm', methods=['GET', 'POST', 'HEAD'])
def sign_up():
    if request.method == 'POST':
        ip = request.environ['REMOTE_ADDR']
        now: float = time()
        with open(APP_DIR[0] / "flood.json", 'r') as sfopen:
            flood: dict = json.load(sfopen)
        remove: list = []
        count: int = 1
        visits: int = -1

        if 'posts_time' not in flood:
            flood['posts_time'] = []
        flood['posts_time'].append(time())
        for visit in flood['posts_time']:
            visits += 1
            if now - visit > 120:
                remove.append(visits)
                continue
            count += 1
        if remove:
            sortlist = []
            remove = sorted(remove)
            for d in reversed(remove):
                sortlist.append(d)
            remove = sortlist
        for item in remove:
            del flood['posts_time'][item]
        if not 'ip_count' in flood:
            flood['ip_count'] = {}
        if ip in flood['ip_count']:
            flood['ip_count'][ip] = int(flood['ip_count'][ip])
            flood['ip_count'][ip] += 1
        else:
            flood['ip_count'][ip] = 1
        ip_count: int = int(flood['ip_count'][ip])
        ip_time: float = 0.0
        if 'ip_time' not in flood:
            flood['ip_time'] = {}
        if ip in flood['ip_time']:
            ip_time = float(flood['ip_time'][ip])
        else:
            flood['ip_time'][ip] = now
            ip_time = now
        if now - ip_time > 60:
            flood['ip_count'][ip] = 1
            flood['ip_time'][ip] = now
            ip_count = 1
        with open(APP_DIR[0] / "flood.json", 'w') as sfopen:
            sfopen.write(json.dumps(flood))
        if count > 30 or ip_count > 20:
            return redirect(url_for('views.flood'))
        del remove
        del ip_count
        del flood
        del count
        del now
        email = request.form.get('email').lower()
        user_name = request.form.get('userName').lower()
        password1 = request.form.get('password1')
        password2 = request.form.get('password2')

        user_email = User.query.filter_by(email=email)
        used_username = User.query.filter_by(user_name=user_name).first()
        user_ip = User.query.filter_by(ip=ip)

        if user_email.count() > 5:
            flash('email already has the maximum of accounts allowed.', category='error')
        elif user_ip.count() > 4:
            flash('this host address already made 5 accounts.', category='error')
        elif 'admin' in user_name.lower():
            flash('UserName must not contain the word "admin".', category='error')
        elif used_username:
            flash('UserName already exists.', category='error')
        elif len(email) < 4:
            flash('email must be greater than 3 characters long.', category='error')
        elif len(email) > 139:
            flash('email must be shorter than 140 characters long.', category='error')
        elif len(user_name) < 2:
            flash('UserName must be greater than 1 character long.', category='error')
        elif len(user_name) > 39:
            flash('UserName must be less than 40 characters long.', category='error')
        elif password1 != password2:
            flash('Passwords do not match.', category='error')
        elif len(password1) < 6:
            flash('Password must be at least 6 characters long.', category='error')
        elif len(password1) >= 40:
            flash('Password must be less than 40 characters long.', category='error')

        else:
            new_user = User(email=email.lower(), type="normal", user_name=user_name.lower(), ip=ip, password=generate_password_hash(
                password1, method='sha256'))
            db.session.add(new_user)
            db.session.commit()

            login_user(new_user, remember=True)
            flash('account created! pls remember your Password.', category='success')
            return redirect(url_for('views.bounce'))
    resp = make_response(render_template("sign_up.html", user=current_user))
    no_cache(resp)
    return resp
0