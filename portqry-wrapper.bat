@ECHO OFF

:: NAME: DCPortTest.CMD v1.0

:: DATE: 03/29/2009

:: PURPOSE:  Test connectivity from one DC to one or more remote DCs

:: using PORTQRY utility.  TBURKE@AMGEN.COM

:: The SERVERS.TXT contains a list of servers (one server per line)

:: to check connectivity to.

 

 

ECHO     DATE: %DATE% > DC_PORTQRY.TXT

ECHO     TIME: %TIME% >> DC_PORTQRY.TXT

ECHO     USER: %USERNAME% >> DC_PORTQRY.TXT

ECHO COMPUTER: %COMPUTERNAME% >> DC_PORTQRY.TXT

ECHO. >> DC_PORTQRY.TXT

ECHO. >> DC_PORTQRY.TXT

ECHO. >> DC_PORTQRY.TXT

FOR /F "tokens=1" %%i in (servers.txt) DO (

ECHO ::::::::::::::::::::::  %%i  :::::::::::::::::::::::::: >> DC_PORTQRY.TXT

 ECHO Testing %%i

ECHO. >> DC_PORTQRY.TXT

U:\PORTQRY\PortQry.exe -n %%i -e 53 -p TCP | findstr /i "53"  >> DC_PORTQRY.TXT

U:\PORTQRY\PortQry.exe -n %%i -e 88 -p TCP | findstr /i "88"  >> DC_PORTQRY.TXT

U:\PORTQRY\PortQry.exe -n %%i -e 445 -p TCP | findstr /i "445" >> DC_PORTQRY.TXT

U:\PORTQRY\PortQry.exe -n %%i -e 389 -p TCP | findstr /i "389" >> DC_PORTQRY.TXT

U:\PORTQRY\PortQry.exe -n %%i -e 3268 -p TCP | findstr /i "3268"  >> DC_PORTQRY.TXT

U:\PORTQRY\PortQry.exe -n %%i -e 135 -p TCP | findstr /i "135" >> DC_PORTQRY.TXT

ECHO. >> DC_PORTQRY.TXT 

 ECHO. >> DC_PORTQRY.TXT 

)