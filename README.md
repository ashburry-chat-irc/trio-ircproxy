Trio-ircproxy.py - an proxy server for your IRC client.
Copyright (c) 2022, sire Kenggi Peters

This is a work in progress, if you wish to help then submit a pull request and/or write issues
for all and any requests.  The issues is working as an to-do list of features.

Issues (requests) List : `https://github.com/ashburry-chat-irc/trio-ircproxy/issues` 
# Setup
- Download and Install `Python 3.9` or later from `https://www.python.org/downloads/`
  -- Extract to your home directory, extract to "%userprofile%"
- then cmd.exe and type `py -3 trio-ircproxy\trio-ircproxy.py`
- to run the website, open another `cmd.exe` and type `cd trio-ircproxy\scripts\www`
- then type `py -3 flask_app.py`

To deploy on `PythonAnywhere.com`:

- Create an zip file of two directories, first is `trio-ircproxy\scripts\www` and  second is `trio-ircproxy\scripts\website_and_proxy`
- Upload zip file to PythonAnywhere.com in the `/home/username/` directory.
- Open an terminal on `PythonAnywhere`
- In terminal type `unzip file.zip -d .` (notice the unzip command ends with an period)
- Edit the `www\www-server-config.ini` so the `hostname` is that of your webserver not `127.0.0.1`
- `Reload your web-server` from the `WEB` tab.



# Copyright License

BSD 3-Clause License
Copyright (c) 2022, sire Kenggi J.P.
All rights reserved.
See file LICENCE for further reading.

