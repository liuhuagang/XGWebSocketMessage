@echo off
rem ============================================
rem [Deploy] Production - Start client (L_Lobby)
rem Usage: Deploy_Client.bat [PublicIP]   (default 47.108.203.10)
rem Requires package: Package\Client\Windows\XGMultiPlayer.exe
rem ============================================
set PUBLIC_IP=47.108.203.10
if not "%1"=="" set PUBLIC_IP=%1

set CLIENT_EXE=%~dp0..\..\Package\Client\Windows\XGMultiPlayer.exe

if not exist "%CLIENT_EXE%" (
    echo [Error] Client exe not found: %CLIENT_EXE%
    echo [Error] Run ..\..\Package_Client.bat first, or deploy the package to the server.
    pause
    exit /b 1
)

cd /d %~dp0..\..\Package\Client\Windows

echo [Client] Starting L_Lobby - PublicIP=%PUBLIC_IP%
XGMultiPlayer.exe L_Lobby -PublicIP=%PUBLIC_IP%
pause
