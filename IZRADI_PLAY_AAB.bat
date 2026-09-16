@echo off
setlocal
cd /d "%~dp0"
powershell.exe -NoProfile -ExecutionPolicy Bypass -File "%~dp0IZRADI_PLAY_AAB.ps1"
set "BUILD_RESULT=%ERRORLEVEL%"
echo.
if not "%BUILD_RESULT%"=="0" (
    echo Build nije uspio. Procitaj poruku iznad.
) else (
    echo Korak 3 je zavrsen.
)
pause
exit /b %BUILD_RESULT%
