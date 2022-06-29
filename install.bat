@echo off
cls
echo.
echo Creating virtual environment in folder named "venv" in the current directory.
py -3 -m venv venv
call .\venv\Scripts\activate.bat
echo Installing requirments via "pip install -r requirements.txt"
pip install -r requirements.txt
echo.
:start
echo [ Y ]. Run web-server and irc bounce server by calling 'runall.bat'.
echo [ N ]. Finish installation and end.
echo.
choice /C yn /N /D y /T 35 /M "Would you like to run the web-server and the bounce server (by calling 'runall.bat')? It will open in two separate cmd.exe windows. [Y/n]?"
if %ERRORLEVEL% == 255 goto end
if %ERRORLEVEL% == 2 goto end
if %ERRORLEVEL% == 1 goto yes
if %ERRORLEVEL% == 0 goto end
:yes
call runall.bat
goto done
:end
echo.
echo finished installation. Type "runall.bat" to open the server apps.
goto complete
:done
echo.
echo finished installation.
:complete