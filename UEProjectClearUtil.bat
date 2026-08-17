@ECHO OFF
TITLE UEProjectClearUtil
setlocal

rem ============================================================
rem  UE Project Cleanup Utility
rem  Usage:  UEProjectClearUtil.bat [ProjectPath] [/Y]
rem          (no argument  = current directory)
rem          (ProjectPath  = target UE project root)
rem          (/Y           = skip confirmation, for CI/scripting)
rem
rem  Removes UE-generated artifacts to keep the repo clean:
rem    dirs  : .vs  .idea  Build  Binaries  DerivedDataCache
rem            Intermediate  Saved  Plugins\*\Binaries
rem            Plugins\*\Intermediate
rem    files : .vsconfig  *.sln  *.slnx  *.sln.DotSettings.user
rem
rem  Safety: refuses to run if no .uproject file is found in the
rem  target directory. The .git / Content / Source / Package dirs
rem  and .uproject files are never touched.
rem ============================================================

set "TARGET=%~1"
if "%TARGET%"=="" set "TARGET=%cd%"

if not exist "%TARGET%" (
    echo [Error] Target path does not exist: %TARGET%
    pause
    exit /b 1
)

if not exist "%TARGET%\*.uproject" (
    echo [Error] No .uproject file found in: %TARGET%
    echo [Error] Refusing to clean a non-UE-project directory.
    pause
    exit /b 1
)

echo ============================================================
echo  UE Project Cleanup Utility
echo  Target : %TARGET%
echo ============================================================
echo Before:
dir /A/D /B "%TARGET%"
echo=

set /p CONFIRM="Delete the UE-generated artifacts listed above? [Y/N]: "
if /i "%CONFIRM%"=="Y" goto :confirmed
if /i "%~2"=="/Y" goto :confirmed
echo Aborted, nothing was deleted.
pause
exit /b 1

:confirmed
pushd "%TARGET%"
set /a DEL_DIRS=0
set /a DEL_FILES=0

echo --- Cleaning directories ---
call :DeleteDirectory ".vs"
call :DeleteDirectory ".idea"
call :DeleteDirectory "Build"
call :DeleteDirectory "Binaries"
call :DeleteDirectory "DerivedDataCache"
call :DeleteDirectory "Intermediate"
call :DeleteDirectory "Saved"

echo --- Cleaning files ---
call :DeleteFile ".vsconfig"
call :DeleteFile "*.sln"
call :DeleteFile "*.slnx"
call :DeleteFile "*.sln.DotSettings.user"

echo --- Cleaning plugin artifacts ---
for /d %%i in (Plugins\*) do (
    call :DeleteDirectory "%%i\Binaries"
    call :DeleteDirectory "%%i\Intermediate"
)
popd

echo ============================================================
echo After:
dir /A/D /B "%TARGET%"
echo=
echo Done. Deleted %DEL_DIRS% directorie(s), %DEL_FILES% file(s).
echo ============================================================
pause
exit /b 0

:DeleteFile
if exist "%~1" (
    echo   DeleteFile %~1
    del /s /q "%~1" >nul 2>&1
    set /a DEL_FILES+=1
)
goto :eof

:DeleteDirectory
if exist "%~1" (
    echo   DeleteDirectory %~1
    rd /s /q "%~1" >nul 2>&1
    set /a DEL_DIRS+=1
)
goto :eof
