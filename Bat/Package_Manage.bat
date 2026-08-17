@echo off
rem ============================================
rem One-click package - Manage server (XGMultiPlayerServer) -> Package\Manage
rem Also used as the DS executable (Manage launches DS from this exe)
rem ENGINE must match your local UE installation.
rem ============================================
set ENGINE=D:\UES\UES_5.8.0
set PROJECT=%~dp0..\XGMultiPlayer.uproject
set OUTDIR=%~dp0..\Package\Manage

call "%ENGINE%\Engine\Build\BatchFiles\RunUAT.bat" BuildCookRun -nop4 -utf8output -nocompileeditor -skipbuildeditor -cook -project="%PROJECT%" -target=XGMultiPlayerServer -unrealexe="%ENGINE%\Engine\Binaries\Win64\UnrealEditor-Cmd.exe" -platform=Win64 -zenstore -stage -archive -package -build -pak -iostore -compressed -prereqs -archivedirectory="%OUTDIR%" -server -noclient -serverconfig=Development -nocompile -nocompileuat

if %ERRORLEVEL% EQU 0 (
    echo [OK] Manage packaged to %OUTDIR%
) else (
    echo [FAIL] Package failed, see log above.
)
pause
