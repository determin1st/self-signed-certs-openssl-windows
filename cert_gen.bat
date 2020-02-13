@echo off
color 0A
cls
set OSSL=..\bin\openssl.exe
set OPENSSL_CONF=.\cert_gen.cnf
set EXTFILE=cert_gen.ext
set CNAME=CA
echo.
goto BEG

:BEG
rem Cleanup previous cert(?)
del %CNAME%.*
::%OSSL% rand -out .rnd -hex 256
goto ONE

:ONE
rem Use "%windir%\system32\drivers\etc\hosts" to set aliases
rem One cert
%OSSL% genrsa -des3 -out %CNAME%.secure 2048
%OSSL% rsa -in %CNAME%.secure -out %CNAME%.key
%OSSL% req -new -key %CNAME%.key -out %CNAME%.csr
%OSSL% x509 -req -days 365 -in %CNAME%.csr -signkey %CNAME%.key -extfile %EXTFILE% -out %CNAME%.pem.crt
rem Create .der cert for Android
%OSSL% x509 -inform PEM -outform DER -in %CNAME%.pem.crt -out %CNAME%_android.der.crt
rem Cleanup(?)
del %CNAME%.secure
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
