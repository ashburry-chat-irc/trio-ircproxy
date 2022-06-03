Trio-ircproxy.py - an proxy server for your IRC client.
Copyright (c) 2022, sire Kenggi Peters

This is a work in progress, if you wish to help then submit a pull request and/or write issues
for all and any requests.  The issues is working as an to-do list of features.

Issues (requests) List : `https://github.com/ashburry-chat-irc/trio-ircproxy/issues` 
# Setup
- Download and Install `Python 3.9` or later from `https://www.python.org/downloads/`
-- Extract to your home directory, cd master; `%userprofile%`
- When the Terminal is done working type `py` or `python3`
- then cmd.exe and type `py -3 trio-ircproxy\trio-ircproxy.py`
- to run the website, open another `cmd.exe` and type `cd scripts\www`
- py -3 then type `py -3 flask_app.py`
- In an console type `unzip -d . deploy_www.zip`
- If you have unzipped to /home/user/deploy_www/ then type `cd deploy_wwww`
- type `mv * ..` then `rm deploy_www`
- edit the `home.ini` and enter `server_hostname = user.pythonanywhere.com`

# Copyright License
BSD 3-Clause License
Copyright (c) 2022, sire Kenggi J.
All rights reserved.
See file LICENCE for further reading.

flask_app.py