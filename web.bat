@echo off
echo If you haven't done so already, run "py -3 venv venv" (only if directory "trio-ircproxy\venv\" does not exist).
echo If you haven't done so already, run .\venv\Scripts\activate.bat to activate your venv shell, before running web.bat
py -3 .\scripts\www\flask_app.py