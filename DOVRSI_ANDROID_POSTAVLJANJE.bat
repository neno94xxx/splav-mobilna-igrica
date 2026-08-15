@echo off
setlocal
set "JAVA_HOME=%~dp0.tools\jdk-17\jdk-17.0.20+8"
set "ANDROID_HOME=%~dp0.tools\android-sdk"
set "ANDROID_SDK_ROOT=%ANDROID_HOME%"
set "SDKMANAGER=%ANDROID_HOME%\cmdline-tools\latest\bin\sdkmanager.bat"

if not exist "%SDKMANAGER%" (
  echo Android command-line alati nisu pronadeni.
  pause
  exit /b 1
)

echo.
echo Ovaj korak preuzima sluzbene Android SDK pakete.
echo Google ce prikazati Android SDK licencu. Procitaj je i prihvati samo ako se slazes.
echo.
call "%SDKMANAGER%" --sdk_root="%ANDROID_HOME%" "platform-tools" "build-tools;35.0.1" "platforms;android-35"
if errorlevel 1 (
  echo.
  echo Android SDK nije dovrsen. Provjeri internet i odgovor na licencu.
  pause
  exit /b 1
)

echo.
echo Android SDK je spreman. Sada pokreni IZRADI_ANDROID_APK.bat.
pause

