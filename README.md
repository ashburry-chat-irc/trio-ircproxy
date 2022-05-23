Trio-ircproxy.py - an proxy server for your IRC client.
Copyright (c) 2022, sire Kenggi Peters

This is a work in progress, if you wish to help then submit a pull request and/or write issues
for all and any requests.  The issues is working as an to-do list of features.

Issues (requests) List : `https://github.com/ashburry-chat-irc/trio-ircproxy/issues`

# Setup
- Download and Install `Python 3.9` from https://www.python.org/downloads/
- Download and Unzip `main.zip` to your `Home Folder` folder
  + Get it from https://github.com/ashburry-chat-irc/trio-ircproxy/archive/refs/heads/main.zip
- Open `Command Prompt` and type `cd %userprofile%\trio-ircproxy-main`
- To install type `pip install --user -U -r requirements.txt`

- Then to run the app, type: `python3 trio-ircproxy.py`
- Put your IPv4 192.168.x.x IP address as your proxy server in your irc client's settings with
username and password as `user : pass` and port `4321`.
- To get your IPv4 right click on your internet icon in your system tray and choose `Open 
  internet settings` click `status button` click `properties` and scroll down to the bottom and 
  read the text for IPv4 and enter as your proxy server IP in your irc client. IPv6 should also 
  work. Also put your `user : pass` and port `4321`. For the type choose `proxy` NOT SOCKS.
- Then to run the app, type: `python trio_ircproxy.py`
- Put your IPv4 192.168.x.x IP address as your proxy server in your irc client's settings with
username : password as `user : pass` and port `4321`. 
- Type in your irc client `/server irc.undernet.org 6667`
- To connect to an SSL port remove the '+' prefix from the port number. So its just 
`/server irc.libera.chat 6697` and NOT `+6697` or just use the standard 6667 port if possible.
- After connected type `/list`
- You can configure everything while connected under the `temporary` login `user : pass`. 
Type `/proxy-commands` for list of valid commands.
- Put a shortcut to `%userprofile%\trio-ircproxy-main` in your `%userprofile%\Documents` folder. 
Just `right click` on `trio-ircproxy-main` folder and choose `create shortcut`. `Right click` on
the new shortcut and choose `copy` and navigate to your Documents folder and `right click` in some 
open space and choose `paste`.
- To run with PyPy3 on Linux type `cd pypy3.8-v7.3.7-linux64/bin` then, to install, type 
`./pypy3 -mpip install -r ../../../trio-ircproxy-main/requirements.txt`
- After installed just type `./pypy3 ../../../trio-ircproxy-main/trio-ircproxy.py` the same is 
similar on Windows, except use `\\` instead of `/`

documentation started at: https://trio-ircproxy.readthedocs.io/en/latest/

# About Trio-ircproxy.py
Trio-ircproxy.py is an proxy server for your IRC (internet relay chat) client with security and
enhancements to the client server connections. Wish you had a script for Irssi or maybe xChat?
Well now you do! With an proxy server you can connect to an irc server, or use the built in
irc server; and send commands to trio-ircproxy.py, see '/proxy-commands' for a list of commands. 

The main benefits, over pure scripting, is speed and portability. Trio-ircproxy.py is lightening
quick compared to your irc client. Consider that mIRC spends over 5 minutes processing an channel
list and it takes trio-ircproxy.py only a few seconds.  Also, trio-ircproxy.py will work with every 
irc client. You can save and load settings, and auto load settings based on nickname or network.
Your irc connection is where trio-ircproxy.py sits, relaying all text between the local irc client
and the remote irc server. This allows you to send commands to trio-ircproxy.py without the command
reaching the remote irc server (where they are invalid). The proxy server will react to server and
client text coming through the connection. Protect your system, manage channels and users, broadcast
to all irc client & server connections, xdcc search server (http and irc bot), super quick flood and
takeover protection (makes good use of /silence cmnd), protect/auto-op/ignore/exceptions/notify 
lists (sync with irc client), 

There is no question, trio-ircproxy.py is the best irc script solution. Unfortunately, it only works
on Linux, Windows 7+, and MacOS and there is no plan to support anything below Windows 7; it's not 
my fault. In the distant near future it may change to only Windows 10+ (lets hope not), Linux and
MacOS and Python 3.10+ or higher.

You will need to have the Python 3.7+ application installed. Or a working copy of PyPy3.8+ version.
And please read the documentation to learn how to run python trio-ircproxy.py, and how to load
Bauderr msl script in your Adiirc/mIRC clients. Unlike other mIRC scripts Bauderr has a fail-proof
loading script to get everthing done correct on the first try, with the first file loaded, assuming you
click `okay` to initialise the script.

documentation started at: https://trio-ircproxy.readthedocs.io/en/latest/
official, non-beta, releases (none as of yet) at: https://ashburry.pythonanywhere.com/

# Copyright License
BSD 3-Clause License

Copyright (c) 2022, sire Kenggi Peters
All rights reserved.

See file LICENCE for further reading.
