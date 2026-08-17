@echo off
rem ============================================
rem [Dev] Local test - Start DS (L_Game_Fire :7777)
rem Requires package: Package\Server\WindowsServer (standalone Server package),
rem or falls back to Package\Manage\WindowsServer (reuse Manage exe, same build)
rem ============================================
set DS_EXE=%~dp0..\..\Package\Server\WindowsServer\XGMultiPlayerServer.exe
if not exist "%DS_EXE%" set DS_EXE=%~dp0..\..\Package\Manage\WindowsServer\XGMultiPlayerServer.exe

if not exist "%DS_EXE%" (
    echo [Error] DS exe not found: %DS_EXE%
    echo [Error] Currently reuse the Manage package exe as DS; or build a standalone Server package to Package\Server.
    pause
    exit /b 1
)

for %%F in ("%DS_EXE%") do cd /d %%~dpF

echo [DS] Starting L_Game_Fire :7777 ...
XGMultiPlayerServer.exe L_Game_Fire -server -log -ManageIP=127.0.0.1 -PublicIP=127.0.0.1 -Port=7777
pause
