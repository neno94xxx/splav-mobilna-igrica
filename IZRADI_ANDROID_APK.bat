@echo off
setlocal
set "JAVA_HOME=%~dp0.tools\jdk-17\jdk-17.0.20+8"
set "ANDROID_HOME=%~dp0.tools\android-sdk"
set "ANDROID_SDK_ROOT=%ANDROID_HOME%"
set "ANDROID_USER_HOME=%~dp0.tools\android-user"
set "GRADLE_USER_HOME=%~dp0.tools\gradle-user"
set "TEMP=%~dp0tmp"
set "TMP=%TEMP%"
set "GODOT_EXE=%~dp0.tools\godot-4.7.1\Godot_v4.7.1-stable_win64_console.exe"

if not exist "%ANDROID_HOME%\platform-tools\adb.exe" (
  echo Android SDK jos nije dovrsen. Prvo pokreni DOVRSI_ANDROID_POSTAVLJANJE.bat.
  pause
  exit /b 1
)

if not exist "%~dp0builds" mkdir "%~dp0builds"
if not exist "%TEMP%" mkdir "%TEMP%"
"%GODOT_EXE%" --headless --path "%~dp0" --export-debug "Android" "%~dp0builds\raft-escape-admob-test.apk"
if errorlevel 1 (
  echo.
  echo APK nije izraden. Pogledaj greske iznad.
  pause
  exit /b 1
)

echo.
echo APK je spreman: builds\raft-escape-admob-test.apk
pause
