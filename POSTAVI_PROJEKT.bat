@echo off
setlocal
cd /d "%~dp0"
powershell.exe -NoProfile -ExecutionPolicy Bypass -File "%~dp0POSTAVI_PROJEKT.ps1" %*
set "SETUP_RESULT=%ERRORLEVEL%"
echo.
if not "%SETUP_RESULT%"=="0" (
    echo Postavljanje nije uspjelo. Procitaj poruku iznad i pokusaj ponovno.
) else (
    echo Postavljanje je zavrseno. Sada mozes pokrenuti POKRENI_IGRU.bat.
)
pause
exit /b %SETUP_RESULT%
