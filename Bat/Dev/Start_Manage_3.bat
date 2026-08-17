@echo off
rem ============================================
rem [Dev] Local test - Start Manage server #3 (L_Manage :7033 / HTTP 7034)
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

echo [ShangHai] Starting L_Manage - WS 7033 / HTTP 7034 ...
XGMultiPlayerServer.exe L_Manage -server -log -Manage -ListenPort=7033 -HTTPPort=7034 -ManageName=ShangHai
pause
