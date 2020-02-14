@echo off
color 0A
cls
set OSSL=..\bin\openssl.exe
set OPENSSL_CONF=.\cert_gen.conf
set CNAME=alias.local
set FNAME=test
set K_E1=basicConstraints=CA:TRUE,pathlen:0
set K_E2=keyUsage=digitalSignature,nonRepudiation,keyEncipherment,dataEncipherment
set K_E3=authorityKeyIdentifier=keyid,issuer
set K_E4=subjectAltName=DNS:%CNAME%
set K_SUBJ=-subj "/CN=%CNAME%/O=opensourceclub/OU=dev/L=none/ST=NO/C=US"
set K_EXT=-addext "%K_E1%" -addext "%K_E2%"
echo.
goto BEG

:BEG
:: Cleanup previous
del %FNAME%.*
goto ONE

:ONE
:: stage 1
%OSSL% genrsa -des3 -passout pass:12345 -out %FNAME%.secure 2048
%OSSL% rsa -passin pass:12345 -in %FNAME%.secure -out %FNAME%.key
:: stage 2
%OSSL% req -new -key %FNAME%.key -out %FNAME%.csr -outform PEM %K_SUBJ% %K_EXT%
echo %K_E1%> %FNAME%.ext
echo %K_E2%>> %FNAME%.ext
echo %K_E3%>> %FNAME%.ext
echo %K_E4%>> %FNAME%.ext
%OSSL% x509 -req -in %FNAME%.csr -signkey %FNAME%.key -out %FNAME%.pem.crt -outform PEM -days 365 -extfile %FNAME%.ext
del %FNAME%.ext
:: stage 3
%OSSL% x509 -inform PEM -outform DER -in %FNAME%.pem.crt -out %FNAME%_android.der.crt
goto END

:END
pause
exit
