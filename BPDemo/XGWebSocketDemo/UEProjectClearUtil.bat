@ECHO OFF
TITLE UEProjectClearUtil
echo=
echo=
echo ������ù�����Ŀ
echo ------------------------------------------------------------------
echo=
echo=
echo ��ǰ��Ŀ·��:%cd%
echo=
rem ��ͳ�Ƹ�·����������Ϣ
dir /A/D /B
echo=
echo=
rem �����Ŀ�ļ�
echo ------------------------------------------------------------------
echo ������Ŀ�ļ���
call :DeleteDirectory ".vs"
call :DeleteDirectory "Build"
call :DeleteDirectory "Binaries"
call :DeleteDirectory "DerivedDataCache"
call :DeleteDirectory "Intermediate"
call :DeleteDirectory "Saved"
echo ------------------------------------------------------------------
echo ������Ŀ�ļ�
call :DeleteFile ".vsconfig"
call :DeleteFile "*.sln"
echo ------------------------------------------------------------------
echo ������Ŀ����ļ���
for /d %%i in (Plugins\*) do ( 
call :DeleteDirectory  %%i\Binaries
call :DeleteDirectory  %%i\Intermediate
)
echo=
echo=

echo ------------------------------------------------------------------
echo=
echo ��ǰ��Ŀ·��:%cd%
echo=
dir /A/D /B
echo=
echo=
echo ------------------------------------------------------------------
echo �������
echo=
echo=


pause

goto :eof

:DeleteFile
if exist %~1 (
echo DeleteFile %~1
del /s /q %~1
)
goto :eof

:DeleteDirectory
if exist %~1 (
echo DeleteDirectory %~1
rd /s /q %~1
)
goto :eof
