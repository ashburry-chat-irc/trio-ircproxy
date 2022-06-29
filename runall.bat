@echo off
cls
echo Starting "runweb.bat" and "runproxy.bat" in the current directory in two seperate cmd.exe windows.
echo Please leave these windows open, they may look unresponsive but are actually functioning normally.
echo.
start runweb.bat
start runproxy.bat
pause
