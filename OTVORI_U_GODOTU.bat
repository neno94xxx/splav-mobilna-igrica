@echo off
setlocal
set "PROJECT_DIR=%~dp0."
set "GODOT_EXE=%~dp0.tools\godot-4.7.1\Godot_v4.7.1-stable_win64_console.exe"
set "JAVA_HOME=%~dp0.tools\jdk-17\jdk-17.0.20+8"
set "ANDROID_HOME=%~dp0.tools\android-sdk"
set "ANDROID_SDK_ROOT=%ANDROID_HOME%"
set "PATH=%JAVA_HOME%\bin;%ANDROID_HOME%\platform-tools;%ANDROID_HOME%\build-tools\35.0.1;%PATH%"
set "APPDATA=%~dp0.tools\runtime-profile\AppData\Roaming"
set "LOCALAPPDATA=%~dp0.tools\runtime-profile\AppData\Local"
set "TEMP=%~dp0.tools\runtime-profile\Temp"
set "TMP=%TEMP%"
if not exist "%GODOT_EXE%" (
  echo Godot nije pronaden. Procitaj README.md ili ponovno pokreni postavljanje.
  pause
  exit /b 1
)
if not exist "%APPDATA%" mkdir "%APPDATA%"
if not exist "%LOCALAPPDATA%" mkdir "%LOCALAPPDATA%"
if not exist "%TEMP%" mkdir "%TEMP%"

"%GODOT_EXE%" --editor --path "%PROJECT_DIR%" %*
set "GODOT_EXIT=%ERRORLEVEL%"
if not "%GODOT_EXIT%"=="0" (
  echo.
  echo Godot editor se nije uspio pokrenuti. Kod greske: %GODOT_EXIT%
  echo Fotografiraj ovaj prozor ili kopiraj poruku greske.
  pause
)
exit /b %GODOT_EXIT%
