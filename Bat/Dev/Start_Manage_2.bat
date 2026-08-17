@echo off
rem ============================================
rem [Dev] Local test - Start Manage server #2 (L_Manage :8033 / HTTP 8034)
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

echo [ChengDu] Starting L_Manage - WS 8033 / HTTP 8034 ...
XGMultiPlayerServer.exe L_Manage -server -log -Manage -ListenPort=8033 -HTTPPort=8034 -ManageName=ChengDu
pause
