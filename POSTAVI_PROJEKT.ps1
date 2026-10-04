[CmdletBinding()]
param([switch]$OnlyDesktop)

$ErrorActionPreference = "Stop"
Set-StrictMode -Version 2.0
$projectRoot = $PSScriptRoot
$toolsRoot = Join-Path $projectRoot ".tools"
$downloads = Join-Path $toolsRoot "downloads"
$godotDirectory = Join-Path $toolsRoot "godot-4.7.1"
$godot = Join-Path $godotDirectory "Godot_v4.7.1-stable_win64_console.exe"
$javaHome = Join-Path $toolsRoot "jdk-17\jdk-17.0.20+8"
$androidSdk = Join-Path $toolsRoot "android-sdk"
$templateDirectory = Join-Path $godotDirectory "editor_data\export_templates\4.7.1.stable"

function Get-VerifiedDownload {
    param([string]$FileName, [string]$Url, [string]$Sha256)
    # Reuse either the new download cache or the original machine's archives.
    foreach ($candidate in @((Join-Path $downloads $FileName), (Join-Path $toolsRoot $FileName))) {
        if ((Test-Path -LiteralPath $candidate) -and
            (Get-FileHash -LiteralPath $candidate -Algorithm SHA256).Hash -eq $Sha256) {
            Write-Host "Koristim provjereni paket: $FileName"
            return $candidate
        }
    }
    $destination = Join-Path $downloads $FileName
    $partial = "$destination.partial"
    Write-Host "Preuzimam $FileName ..." -ForegroundColor Yellow
    $curl = Get-Command curl.exe -ErrorAction SilentlyContinue
    if ($curl) {
        & $curl.Source --fail --location --retry 3 --connect-timeout 30 --output $partial $Url
        if ($LASTEXITCODE -ne 0) { throw "Preuzimanje nije uspjelo: $Url" }
    } else {
        Invoke-WebRequest -UseBasicParsing -Uri $Url -OutFile $partial
    }
    if ((Get-FileHash -LiteralPath $partial -Algorithm SHA256).Hash -ne $Sha256) {
        throw "SHA256 provjera nije prosla za $FileName. Ponovno pokreni postavljanje."
    }
    Move-Item -LiteralPath $partial -Destination $destination -Force
    return $destination
}

function Assert-RequiredFiles {
    param([string[]]$Paths)
    foreach ($required in $Paths) {
        if (-not (Test-Path -LiteralPath $required -PathType Leaf)) {
            throw "Nedostaje potrebna datoteka: $required"
        }
    }
}

function Set-GodotAndroidSettings {
    $settingsPath = Join-Path $godotDirectory "editor_data\editor_settings-4.7.tres"
    $settings = if (Test-Path -LiteralPath $settingsPath) {
        Get-Content -LiteralPath $settingsPath -Raw -Encoding UTF8
    } else {
        "[gd_resource type=`"EditorSettings`" format=3]`n`n[resource]`n"
    }
    $values = [ordered]@{
        "export/android/java_sdk_path" = $javaHome
        "export/android/android_sdk_path" = $androidSdk
        "export/android/debug_keystore" = (Join-Path $godotDirectory "editor_data\keystores\debug.keystore")
        "export/android/debug_keystore_user" = "androiddebugkey"
        "export/android/debug_keystore_pass" = "android"
    }
    foreach ($key in $values.Keys) {
        $value = $values[$key].Replace('\', '/').Replace('"', '\"')
        $line = "$key = `"$value`""
        $pattern = '(?m)^' + [regex]::Escape($key) + ' = [^\r\n]*'
        if ($settings -match $pattern) {
            $settings = [regex]::Replace($settings, $pattern, $line.Replace('$', '$$'))
        } else {
            $settings = $settings.TrimEnd() + "`n$line`n"
        }
    }
    Set-Content -LiteralPath $settingsPath -Value $settings -Encoding UTF8
}

try {
    if ($env:OS -ne "Windows_NT" -or
        ($env:PROCESSOR_ARCHITECTURE -ne "AMD64" -and $env:PROCESSOR_ARCHITEW6432 -ne "AMD64")) {
        throw "Ova skripta je za Windows x64."
    }
    Assert-RequiredFiles @((Join-Path $projectRoot "project.godot"))
    New-Item -ItemType Directory -Force -Path $toolsRoot, $downloads, (Join-Path $projectRoot "tmp") | Out-Null
    $env:TEMP = Join-Path $projectRoot "tmp"
    $env:TMP = $env:TEMP
    $ProgressPreference = "SilentlyContinue"

    Write-Host "Raft Escape - postavljanje novog racunala" -ForegroundColor Cyan
    Write-Host "Alati se spremaju u .tools. Administratorske ovlasti nisu potrebne."
    if (-not $OnlyDesktop) {
        Write-Host "Potpuno postavljanje ukljucuje Android. Preuzimanja mogu biti veca od 1.5 GB."
        Write-Host "Za samo pokretanje na Windowsu: POSTAVI_PROJEKT.bat -OnlyDesktop"
    }

    if (-not (Test-Path -LiteralPath $godot)) {
        $archive = Get-VerifiedDownload "Godot_v4.7.1-stable_win64.exe.zip" `
            "https://github.com/godotengine/godot-builds/releases/download/4.7.1-stable/Godot_v4.7.1-stable_win64.exe.zip" `
            "C7A289051EAEFB460B0106B60E9CD5BEE0EF55FD102DCB2BED1EB356CF3D90A1"
        Expand-Archive -LiteralPath $archive -DestinationPath $godotDirectory -Force
    }
    Assert-RequiredFiles @($godot)
    # Self-contained mode keeps editor settings and templates beside Godot.
    $selfContainedMarker = Join-Path $godotDirectory "_sc_"
    if (-not (Test-Path -LiteralPath $selfContainedMarker)) {
        New-Item -ItemType File -Path $selfContainedMarker | Out-Null
    }
    $godotVersion = & $godot --version
    if ($LASTEXITCODE -ne 0 -or ($godotVersion -join "") -notmatch '^4\.7\.1\.stable') {
        throw "Godot u .tools nije ocekivana verzija 4.7.1 stable."
    }

    if (-not $OnlyDesktop) {
        $java = Join-Path $javaHome "bin\java.exe"
        if (-not (Test-Path -LiteralPath $java)) {
            $archive = Get-VerifiedDownload "OpenJDK17U-jdk_x64_windows_hotspot_17.0.20_8.zip" `
                "https://github.com/adoptium/temurin17-binaries/releases/download/jdk-17.0.20%2B8/OpenJDK17U-jdk_x64_windows_hotspot_17.0.20_8.zip" `
                "418497BE5CF585BDD2203D6486A565D66D3F5E992D5630D45104CB873FAB8122"
            Expand-Archive -LiteralPath $archive -DestinationPath (Join-Path $toolsRoot "jdk-17") -Force
        }
        Assert-RequiredFiles @($java, (Join-Path $javaHome "bin\keytool.exe"))
        $env:JAVA_HOME = $javaHome
        $env:ANDROID_HOME = $androidSdk
        $env:ANDROID_SDK_ROOT = $androidSdk
        $env:ANDROID_USER_HOME = Join-Path $toolsRoot "android-user"
        $env:GRADLE_USER_HOME = Join-Path $toolsRoot "gradle-user"
        $env:PATH = "$javaHome\bin;$androidSdk\platform-tools;$env:PATH"
        New-Item -ItemType Directory -Force -Path $env:ANDROID_USER_HOME, $env:GRADLE_USER_HOME | Out-Null

        $sdkManager = Join-Path $androidSdk "cmdline-tools\latest\bin\sdkmanager.bat"
        if (-not (Test-Path -LiteralPath $sdkManager)) {
            $archive = Get-VerifiedDownload "commandlinetools-win-15859902_latest.zip" `
                "https://dl.google.com/android/repository/commandlinetools-win-15859902_latest.zip" `
                "90AE805D20434428BFFCB699C290860F19BB5F66A67E6B330067E3DE801FB04A"
            $stage = Join-Path $toolsRoot "setup-stage\commandline"
            $latest = Join-Path $androidSdk "cmdline-tools\latest"
            Expand-Archive -LiteralPath $archive -DestinationPath $stage -Force
            New-Item -ItemType Directory -Force -Path $latest | Out-Null
            Get-ChildItem -LiteralPath (Join-Path $stage "cmdline-tools") -Force | Copy-Item -Destination $latest -Recurse -Force
        }
        $sdkFiles = @(
            (Join-Path $androidSdk "platform-tools\adb.exe"),
            (Join-Path $androidSdk "build-tools\36.1.0\aapt2.exe"),
            (Join-Path $androidSdk "platforms\android-36\android.jar")
        )
        $missingSdkFiles = @($sdkFiles | Where-Object { -not (Test-Path -LiteralPath $_) })
        if ($missingSdkFiles.Count -gt 0) {
            Write-Host "Instaliram Android SDK. Procitaj i prihvati licence ako se slazes." -ForegroundColor Yellow
            & $sdkManager "--sdk_root=$androidSdk" "platform-tools" "build-tools;36.1.0" "platforms;android-36"
            if ($LASTEXITCODE -ne 0) { throw "Android SDK nije instaliran. Provjeri internet i prihvacanje licenci." }
        }
        Assert-RequiredFiles $sdkFiles

        $templateFiles = @("android_debug.apk", "android_release.apk", "android_source.zip", "version.txt")
        $missingTemplates = @($templateFiles | Where-Object { -not (Test-Path -LiteralPath (Join-Path $templateDirectory $_)) })
        if ($missingTemplates.Count -gt 0) {
            # The official .tpz is a ZIP. Cache it with .zip for Windows tools.
            $archive = Get-VerifiedDownload "Godot_v4.7.1-stable_export_templates.zip" `
                "https://github.com/godotengine/godot-builds/releases/download/4.7.1-stable/Godot_v4.7.1-stable_export_templates.tpz" `
                "86409DB6200B6F8FD3230989C2D2002851F3DD18ACF11D7BDBAFDDF5A0DD0F72"
            New-Item -ItemType Directory -Force -Path $templateDirectory | Out-Null
            $tar = Get-Command tar.exe -ErrorAction SilentlyContinue
            if ($tar) {
                & $tar.Source -xf $archive -C $templateDirectory --strip-components 1 `
                    "templates/android_debug.apk" "templates/android_release.apk" "templates/android_source.zip" "templates/version.txt"
                if ($LASTEXITCODE -ne 0) { throw "Raspakiravanje Android predlozaka nije uspjelo." }
            } else {
                $stage = Join-Path $toolsRoot "setup-stage\templates"
                Expand-Archive -LiteralPath $archive -DestinationPath $stage -Force
                foreach ($file in $templateFiles) {
                    Copy-Item -LiteralPath (Join-Path $stage "templates\$file") -Destination $templateDirectory -Force
                }
            }
        }
        Assert-RequiredFiles @($templateFiles | ForEach-Object { Join-Path $templateDirectory $_ })
        if ((Get-Content -LiteralPath (Join-Path $templateDirectory "version.txt") -Raw).Trim() -ne "4.7.1.stable") {
            throw "Verzija Android predlozaka ne odgovara Godotu 4.7.1."
        }
        $androidBuild = Join-Path $projectRoot "android\build"
        $androidBuildVersion = Join-Path $projectRoot "android\.build_version"
        if (-not (Test-Path -LiteralPath $androidBuild)) {
            Write-Host "Postavljam Android Gradle projekt..."
            Expand-Archive -LiteralPath (Join-Path $templateDirectory "android_source.zip") -DestinationPath $androidBuild
            New-Item -ItemType File -Path (Join-Path $androidBuild ".gdignore") -Force | Out-Null
            Set-Content -LiteralPath $androidBuildVersion -Value "4.7.1.stable" -Encoding ASCII
        } elseif (-not (Test-Path -LiteralPath $androidBuildVersion) -or
            (Get-Content -LiteralPath $androidBuildVersion -Raw).Trim() -ne "4.7.1.stable") {
            throw "Postojeci android/build nije oznacen kao verzija 4.7.1.stable. Sacuvaj ga izvan projekta pa ponovi postavljanje."
        }
        Assert-RequiredFiles @((Join-Path $androidBuild "build.gradle"), (Join-Path $androidBuild "gradlew.bat"))
        $debugKey = Join-Path $godotDirectory "editor_data\keystores\debug.keystore"
        if (-not (Test-Path -LiteralPath $debugKey)) {
            New-Item -ItemType Directory -Force -Path (Split-Path $debugKey -Parent) | Out-Null
            & (Join-Path $javaHome "bin\keytool.exe") -genkeypair -keystore $debugKey `
                -alias androiddebugkey -storepass android -keypass android -keyalg RSA -keysize 2048 `
                -validity 10000 -dname "CN=Android Debug,O=Android,C=US"
            if ($LASTEXITCODE -ne 0) { throw "Izrada lokalnog debug kljuca nije uspjela." }
        }
        Assert-RequiredFiles @(
            (Join-Path $projectRoot "addons\AdmobPlugin\bin\debug\AdmobPlugin-debug.aar"),
            (Join-Path $projectRoot "addons\AdmobPlugin\bin\release\AdmobPlugin-release.aar")
        )
    }

    Write-Host "Importiram slike, zvukove i skripte u Godot..." -ForegroundColor Yellow
    & $godot --headless --path $projectRoot --import
    if ($LASTEXITCODE -ne 0) { throw "Godot import nije uspio. Pogledaj greske iznad." }
    if (-not $OnlyDesktop) { Set-GodotAndroidSettings }
    Write-Host ""
    Write-Host "SPREMNO: POKRENI_IGRU.bat / OTVORI_U_GODOTU.bat" -ForegroundColor Green
    if (-not $OnlyDesktop) {
        Write-Host "Android APK: IZRADI_ANDROID_APK.bat. Gradle preuzima svoje ovisnosti pri prvom buildu."
        Write-Host "Google Play AAB: IZRADI_PLAY_AAB.bat. Potreban je postojeci upload .jks kljuc i njegova lozinka."
    }
} catch {
    Write-Host ""
    Write-Host $_.Exception.Message -ForegroundColor Red
    exit 1
}
