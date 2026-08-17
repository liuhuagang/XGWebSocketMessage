@echo off
rem ============================================
rem [Dev] Local test - Start Manage server #1 (L_Manage :9033 / HTTP 9034)
rem Requires package: Package\Manage\WindowsServer (run Package_Manage.bat first)
rem ============================================
set MANAGE_EXE=%~dp0..\..\Package\Manage\WindowsServer\XGMultiPlayerServer.exe

if not exist "%MANAGE_EXE%" (
    echo [Error] Manage exe not found: %MANAGE_EXE%
    echo [Error] Run ..\..\Package_Manage.bat first.
    pause
    exit /b 1
)

cd /d %~dp0..\..\Package\Manage\WindowsServer

echo [BeiJing] Starting L_Manage - WS 9033 / HTTP 9034 ...
XGMultiPlayerServer.exe L_Manage -server -log -Manage -ListenPort=9033 -HTTPPort=9034 -ManageName=BeiJing
pause
