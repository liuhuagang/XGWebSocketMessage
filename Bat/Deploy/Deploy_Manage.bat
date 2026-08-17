@echo off
rem ============================================
rem [Deploy] Production - Start Manage server (L_Manage :9033 / HTTP 9034)
rem Usage: Deploy_Manage.bat [PublicIP]   (default 47.108.203.10)
rem Requires package: Package\Manage\WindowsServer (run Package_Manage.bat first)
rem ============================================
set PUBLIC_IP=47.108.203.10
if not "%1"=="" set PUBLIC_IP=%1

set MANAGE_EXE=%~dp0..\..\Package\Manage\WindowsServer\XGMultiPlayerServer.exe

if not exist "%MANAGE_EXE%" (
    echo [Error] Manage exe not found: %MANAGE_EXE%
    echo [Error] Run ..\..\Package_Manage.bat first, or deploy the package to the server.
    pause
    exit /b 1
)

cd /d %~dp0..\..\Package\Manage\WindowsServer

echo [Manage] Starting L_Manage - WS 9033 / HTTP 9034 - PublicIP=%PUBLIC_IP%
XGMultiPlayerServer.exe L_Manage -server -log -Manage -ListenPort=9033 -HTTPPort=9034 -ManageName=BeiJing -PublicIP=%PUBLIC_IP%
pause
