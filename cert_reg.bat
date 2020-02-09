@echo off
color 0A
cls
rem Register cert in OS
certutil -addstore -enterprise Root server.crt
pause
exit
