@echo off
color 0A
cls
set OSSL=..\bin\openssl.exe
set OPENSSL_CONF=.\cert_gen.cnf
set EXTFILE=cert_gen.ext
echo.
goto BEG

:BEG
rem Cleanup shit
del server.*
::%OSSL% rand -out .rnd -hex 256
goto ONE

:ONE
rem Use "%windir%\system32\drivers\etc\hosts" to set aliases
rem One cert
%OSSL% genrsa -des3 -out server.key.secure 2048
%OSSL% rsa -in server.key.secure -out server.key
%OSSL% req -new -key server.key -out server.csr
%OSSL% x509 -req -days 365 -in server.csr -signkey server.key -extfile makecert.ext -out server.crt
goto END

:TWO
rem Two certs (not working)
%OSSL% req -x509 -nodes -new -sha256 -days 1024 -newkey rsa:2048 -keyout RootCA.key -out RootCA.pem -subj "/C=US/CN=Custom-Root-CA"
%OSSL% x509 -outform pem -in RootCA.pem -out RootCA.crt
%OSSL% req -new -nodes -newkey rsa:2048 -keyout server.key -out server.csr -subj "/C=US/ST=State/L=City/O=Custom-Certificates/CN=localhost"
%OSSL% x509 -req -sha256 -days 1024 -in server.csr -CA RootCA.pem -CAkey RootCA.key -CAcreateserial -extfile makecert.ext -out server.crt
goto END

:END
pause
exit
