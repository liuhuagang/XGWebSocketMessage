@echo off
rem ============================================
rem [Deploy] Production - Start DS (L_Game_Fire :7777)
rem Usage: Deploy_DS_Fire.bat [ManageIP] [PublicIP]
rem        (default ManageIP=47.108.203.10, PublicIP=47.108.203.10)
rem Requires package: Package\Server\WindowsServer (standalone Server package),
rem or falls back to Package\Manage\WindowsServer (reuse Manage exe, same build)
rem NOTE: In production the Manage server normally launches DS processes
rem       automatically; this script is for manual/standalone DS startup.
rem ============================================
set MANAGE_IP=47.108.203.10
if not "%1"=="" set MANAGE_IP=%1
set PUBLIC_IP=47.108.203.10
if not "%2"=="" set PUBLIC_IP=%2

set DS_EXE=%~dp0..\..\Package\Server\WindowsServer\XGMultiPlayerServer.exe
if not exist "%DS_EXE%" set DS_EXE=%~dp0..\..\Package\Manage\WindowsServer\XGMultiPlayerServer.exe

if not exist "%DS_EXE%" (
    echo [Error] DS exe not found: %DS_EXE%
    echo [Error] Currently reuse the Manage package exe as DS; or build a standalone Server package to Package\Server.
    pause
    exit /b 1
)

for %%F in ("%DS_EXE%") do cd /d %%~dpF

echo [DS] Starting L_Game_Fire :7777 - ManageIP=%MANAGE_IP% PublicIP=%PUBLIC_IP%
XGMultiPlayerServer.exe L_Game_Fire -server -log -ManageIP=%MANAGE_IP% -PublicIP=%PUBLIC_IP% -Port=7777
pause
