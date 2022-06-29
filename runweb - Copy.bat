@echo off
echo Starting flask_app.py in virtual-environment. While this window is open, the web-server will be available and running.
echo.
call .\venv\Scripts\activate.bat
py -3 .\scripts\www\flask_app.py

