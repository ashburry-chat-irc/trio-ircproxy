@echo off
echo Starting trio-ircproxy.py in virtual-environment. While this window is open, the bouncer server will be available and running.
echo.
call .\venv\Scripts\activate.bat
py -3 .\trio-ircproxy.py