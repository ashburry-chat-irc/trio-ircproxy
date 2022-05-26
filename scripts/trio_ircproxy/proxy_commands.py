#!/usr/bin/python
# -*- coding: utf-8 -*-
from fnmatch import fnmatch
from . import circular
from pendulum import duration
from ..website_and_proxy.socket_data import SocketData as socket_data
from time import time
from ..website_and_proxy.users import verify_user_pwdfile, add_new_user

def dur_replace(in_words: str) -> str:
    in_words = in_words.replace('week', 'wks')
    in_words = in_words.replace('day', 'dys')
    in_words = in_words.replace('hour', 'hrs')
    in_words = in_words.replace('minute', 'mins')
    in_words = in_words.replace('second', 'secs')
    in_words = in_words.replace('ss', 's')
    return in_words


def commands(client_socket, server_socket, single_line, split_line) -> None:
    command = split_line[0]
    if fnmatch(command, '*new*user*'):
        if len(split_line) < 3 or len(split_line) > 3:
            circular.sc_send(client_socket, 'Syntax: /proxy-new-user <username> <password>')

        try:
            add_new_user(split_line[1], split_line[2])
        except ValueError as exc:
            circular.sc_send(client_socket, "Error: " + exc.args[1])
    if fnmatch(command, '*time*'):
        if client_socket in socket_data.state and 'connected' in socket_data.state[client_socket]:
            ctime = time() - socket_data.state[client_socket]['connected']
            circular.sc_send(client_socket,
                             'You have been connected for \x02' + dur_replace(duration(seconds=ctime).in_words()))
    if fnmatch(command, '*commands*'):
        # /proxy-time    # Show the duration of how long you've been signed on for in weeks, days, hours, minutes
                         # and seconds.
        # /proxy-uptime Show how long the proxy server has been online for.

        # /proxy-help        # First use instructions. Disposable user : pass account.
        # ----- USERNAME AND PASSWORDS ------
        # /proxy-new-user <nick> [network]        # Queries the nickname to set unique username and password.
        # /proxy-remove-user <user>          # Remove the username and disconnect all logged in users for the username.
        # /.proxy-create-user <user> <pass>       # Overwrites username if it exists.
        # /.proxy-admin <password>           # Change login credentials.
        # /.proxy-login <user> <pass>        # change login credentials.
        # /.proxy-change-pass <new pass>     # Change your current password.
        # /.proxy-set-admin-pass <password>       # Sets the admin password. Can only be used from user : pass account.
        # /proxy-get-users <ip/host/nickname wild-text>   # Retreive the current and previous logged in usernames
        # or /proxy-get-names <ip or nick>                 # of the ip or nickname.
        # /proxy-show <user>                # Shows the details about the previous/current logged in session.
        # /proxy-list-users                 # List all usernames and how long since they've been used.
        # ----- GET IP ADDRESS ------
        # /proxy-get-public-ip              # Get the public IP address of the server and the listening port
        # /proxy-get-local-ip       # Get the local IP address of the server, and listening port. Same as 0.0.0.0,
                                    # 192.168.*, 10.11.*. May also be 127.* if reconfigured.

        # ----- IRC SERVER ------
        # /proxy-set-away [* | UnderNet] <away msg | N>
        # /proxy-set-back [* | UnderNet]    # if no params then just the connection is set back/away
        # /proxy-auto-identify [* | UnderNet]   <on | off | forget>
        # /proxy-auto-join [* | UnderNet] #5ioE   # If no network specified then the current network is used.
        # ----- CONTROL LISTS ------
        # /proxy-auto-op-add [UnderNet] [#5ioE,#Python,*] [nickmask]
        # /proxy-protect-add [UnderNet] [#5ioE,#Python,*] [nickmask]
        # /proxy-auto-op-except [nickmask]
        # /proxy-protect-except [nickmask]
        # /proxy-auto-op-except-remove [nickmask]
        # /proxy-protect-except-remove [nickmask]
        # /proxy-auto-op-remove [UnderNet] [#5ioE,#Python,*] [nickmask]
        # /proxy-protect-remove [UnderNet] [#5ioE,#Python,*] [nickmask]

        # /proxy-notify-add [* | UnderNet] <nickname>         # Add network for nickname to notify list.
        # /proxy-notify-remove [* | UnderNet] <nickname>      # Remove network for nickname from notify list.
        # /proxy-list-control <op | protect | notify>      # List the entries of control lists. include exceptions.
        # /proxy-flood <* | private | channel> ON | OFF     # Turn on/off flood protection
        pass
    if fnmatch(command, '*admin*pass*'):
        # Set admin password, only works from 'user' and 'admin' accounts.
        pass
    if fnmatch(command, '*login*'):
        if len(split_line) < 3 or len(split_line) > 3:
            circular.status_msg(client_socket, 'Syntax: /proxy-login <username> <password>')
            return None
        try:
            if not verify_user_pwdfile(split_line[1], split_line[2]):
                circular.status_msg(client_socket, 'Bad Login. Incorrect username or password.')
            else:
                circular.status_msg(client_socket, f'Login accepted. You are now logged in as "{split_line[1]}"')
                socket_data.login[client_socket] = split_line[1]
        except ValueError:
            circular.status_msg(client_socket, 'Bad Login. Incorrect username or password.')



