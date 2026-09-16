$ErrorActionPreference = "Stop"
Set-StrictMode -Version 2.0

$projectRoot = $PSScriptRoot
$godot = Join-Path $projectRoot ".tools\godot-4.7.1\Godot_v4.7.1-stable_win64_console.exe"
$javaHome = Join-Path $projectRoot ".tools\jdk-17\jdk-17.0.20+8"
$androidSdk = Join-Path $projectRoot ".tools\android-sdk"
$gradleHome = Join-Path $projectRoot ".tools\gradle-user"
$buildDirectory = Join-Path $projectRoot "builds"
$outputBundle = Join-Path $buildDirectory "raft-escape-play.aab"
$keystore = "C:\Users\nenom\OneDrive\Documents\RaftEscapeKeys\raftescape-upload.jks"
$keyAlias = "raftescape-upload"

$requiredPaths = @(
    $godot,
    (Join-Path $javaHome "bin\java.exe"),
    (Join-Path $javaHome "bin\jarsigner.exe"),
    (Join-Path $androidSdk "platforms\android-36\android.jar"),
    $keystore
)

foreach ($requiredPath in $requiredPaths) {
    if (-not (Test-Path -LiteralPath $requiredPath)) {
        throw "Nedostaje potrebna datoteka: $requiredPath"
    }
}

New-Item -ItemType Directory -Force -Path $buildDirectory, $gradleHome | Out-Null

Write-Host ""
Write-Host "Raft Escape - potpisani Google Play AAB" -ForegroundColor Cyan
Write-Host "Lozinka se nece prikazati niti spremiti u projekt." -ForegroundColor DarkGray
$securePassword = Read-Host "Upisi lozinku za raftescape-upload.jks" -AsSecureString

$passwordPointer = [IntPtr]::Zero
$plainPassword = $null

try {
    $passwordPointer = [Runtime.InteropServices.Marshal]::SecureStringToBSTR($securePassword)
    $plainPassword = [Runtime.InteropServices.Marshal]::PtrToStringBSTR($passwordPointer)

    if ([string]::IsNullOrWhiteSpace($plainPassword)) {
        throw "Lozinka nije unesena."
    }

    $env:JAVA_HOME = $javaHome
    $env:ANDROID_HOME = $androidSdk
    $env:ANDROID_SDK_ROOT = $androidSdk
    $env:GRADLE_USER_HOME = $gradleHome
    $env:GODOT_ANDROID_KEYSTORE_RELEASE_PATH = $keystore
    $env:GODOT_ANDROID_KEYSTORE_RELEASE_USER = $keyAlias
    $env:GODOT_ANDROID_KEYSTORE_RELEASE_PASSWORD = $plainPassword
    $env:PATH = "$(Join-Path $javaHome 'bin');$(Join-Path $androidSdk 'platform-tools');$env:PATH"

    if (Test-Path -LiteralPath $outputBundle) {
        Remove-Item -LiteralPath $outputBundle -Force
    }

    Write-Host ""
    Write-Host "Izradujem release AAB... Prvi build moze potrajati nekoliko minuta." -ForegroundColor Yellow
    & $godot --headless --path $projectRoot --export-release "Android Play" $outputBundle

    if ($LASTEXITCODE -ne 0) {
        throw "Godot export nije uspio (exit code $LASTEXITCODE)."
    }

    if (-not (Test-Path -LiteralPath $outputBundle)) {
        throw "Godot nije stvorio ocekivani AAB: $outputBundle"
    }

    Write-Host ""
    Write-Host "Provjeravam digitalni potpis..." -ForegroundColor Yellow
    $signatureCheck = & (Join-Path $javaHome "bin\jarsigner.exe") -verify $outputBundle 2>&1

    if ($LASTEXITCODE -ne 0) {
        $signatureCheck | Write-Host
        throw "AAB je izraden, ali provjera potpisa nije uspjela."
    }

    Write-Host "Digitalni potpis je potvrden (jar verified)." -ForegroundColor Green

    $bundle = Get-Item -LiteralPath $outputBundle
    $bundleHash = Get-FileHash -LiteralPath $outputBundle -Algorithm SHA256

    Write-Host ""
    Write-Host "USPJEH: potpisani AAB je spreman." -ForegroundColor Green
    Write-Host "Datoteka: $($bundle.FullName)"
    Write-Host "Velicina: $([math]::Round($bundle.Length / 1MB, 2)) MB"
    Write-Host "SHA256: $($bundleHash.Hash)"
    Write-Host ""
    Write-Host "Nemoj ga jos slati na Play Console. Nakon finalne ikone napravit cemo zavrsni build." -ForegroundColor Yellow
}
finally {
    Remove-Item Env:GODOT_ANDROID_KEYSTORE_RELEASE_PASSWORD -ErrorAction SilentlyContinue
    Remove-Item Env:GODOT_ANDROID_KEYSTORE_RELEASE_USER -ErrorAction SilentlyContinue
    Remove-Item Env:GODOT_ANDROID_KEYSTORE_RELEASE_PATH -ErrorAction SilentlyContinue

    $plainPassword = $null
    $securePassword = $null

    if ($passwordPointer -ne [IntPtr]::Zero) {
        [Runtime.InteropServices.Marshal]::ZeroFreeBSTR($passwordPointer)
    }
}
