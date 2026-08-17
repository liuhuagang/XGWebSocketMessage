@echo off
rem ============================================
rem [Dev] Local test - Start client (L_Lobby)
rem Requires package: Package\Client\Windows\XGMultiPlayer.exe
rem NOTE: Package\Client currently only has WindowsServer (DS build).
rem       If the exe is missing, package the Client target first
rem       (Package_Client.bat), or run the client from the editor.
rem ============================================
set CLIENT_EXE=%~dp0..\..\Package\Client\Windows\XGMultiPlayer.exe

if not exist "%CLIENT_EXE%" (
    echo [Error] Client exe not found: %CLIENT_EXE%
    echo [Error] Package the Client target first, or run from editor.
    pause
    exit /b 1
)

cd /d %~dp0..\..\Package\Client\Windows

echo [Client] Starting L_Lobby - Manage IP:127.0.0.1 ...
XGMultiPlayer.exe L_Lobby
pause
