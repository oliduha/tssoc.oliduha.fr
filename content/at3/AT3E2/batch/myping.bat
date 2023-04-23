@echo off

:MYPING
ECHO.
set /p MYIP=" [36m IP Address or FQDN to ping (x to quit): [92m"
IF %MYIP%==x GOTO EXIT
ECHO [0m&ping %MYIP%
GOTO MYPING

:EXIT
ECHO [1;35mBye! [0m
EXIT /B %ERRORLEVEL%