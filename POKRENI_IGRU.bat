@echo off
setlocal
set "PROJECT_DIR=%~dp0."
set "GODOT_EXE=%~dp0.tools\godot-4.7.1\Godot_v4.7.1-stable_win64_console.exe"
set "JAVA_HOME=%~dp0.tools\jdk-17\jdk-17.0.20+8"
set "ANDROID_HOME=%~dp0.tools\android-sdk"
set "ANDROID_SDK_ROOT=%ANDROID_HOME%"
set "PATH=%JAVA_HOME%\bin;%ANDROID_HOME%\platform-tools;%ANDROID_HOME%\build-tools\36.1.0;%PATH%"
set "APPDATA=%~dp0.tools\runtime-profile\AppData\Roaming"
set "LOCALAPPDATA=%~dp0.tools\runtime-profile\AppData\Local"
set "TEMP=%~dp0.tools\runtime-profile\Temp"
set "TMP=%TEMP%"
if not exist "%GODOT_EXE%" (
  echo Godot nije pronaden. Pokreni POSTAVI_PROJEKT.bat.
  echo Za samo Windows igru mozes pokrenuti POSTAVI_PROJEKT.bat -OnlyDesktop.
  pause
  exit /b 1
)
if not exist "%APPDATA%" mkdir "%APPDATA%"
if not exist "%LOCALAPPDATA%" mkdir "%LOCALAPPDATA%"
if not exist "%TEMP%" mkdir "%TEMP%"

if not exist "%~dp0.godot\imported" (
  echo Prvi import slika i zvukova...
  "%GODOT_EXE%" --headless --path "%PROJECT_DIR%" --import
  if errorlevel 1 (
    echo Godot import nije uspio. Pogledaj greske iznad.
    pause
    exit /b 1
  )
)

"%GODOT_EXE%" --path "%PROJECT_DIR%" %*
set "GAME_EXIT=%ERRORLEVEL%"
if not "%GAME_EXIT%"=="0" (
  echo.
  echo Igra se nije uspjela pokrenuti. Kod greske: %GAME_EXIT%
  echo Fotografiraj ovaj prozor ili kopiraj poruku greske.
  pause
)
exit /b %GAME_EXIT%
