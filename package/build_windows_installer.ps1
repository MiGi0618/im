param(
    [string]$BuildDir = "",
    [string]$QtBinDir = "",
    [string]$IsccPath = "",
    [string]$Version = "0.1.0",
    [string]$Publisher = "IMSystem"
)

$ErrorActionPreference = "Stop"

function Resolve-IsccPath {
    param([string]$ProvidedPath)

    if ($ProvidedPath -and (Test-Path $ProvidedPath)) {
        return (Resolve-Path $ProvidedPath).Path
    }

    $candidates = @(
        "D:\Program Files\Inno Setup 6\ISCC.exe",
        "D:\Program Files (x86)\Inno Setup 6\ISCC.exe",
        "C:\Program Files (x86)\Inno Setup 6\ISCC.exe",
        "C:\Program Files\Inno Setup 6\ISCC.exe"
    )

    foreach ($candidate in $candidates) {
        if (Test-Path $candidate) {
            return $candidate
        }
    }

    throw "Cannot find ISCC.exe. Install Inno Setup 6 or pass -IsccPath."
}

function Resolve-WindeployqtPath {
    param([string]$ProvidedQtBinDir)

    if ($ProvidedQtBinDir) {
        $candidate = Join-Path $ProvidedQtBinDir "windeployqt.exe"
        if (Test-Path $candidate) {
            return (Resolve-Path $candidate).Path
        }
    }

    $command = Get-Command windeployqt.exe -ErrorAction SilentlyContinue
    if ($command) {
        return $command.Source
    }

    $fallback = "D:\Qt\6.8.3\mingw_64\bin\windeployqt.exe"
    if (Test-Path $fallback) {
        return $fallback
    }

    throw "Cannot find windeployqt.exe. Pass -QtBinDir or add Qt bin to PATH."
}

$repoRoot = (Resolve-Path (Join-Path $PSScriptRoot "..")).Path
$projectDir = Join-Path $repoRoot "client_Qt"
$defaultBuildDir = Join-Path $projectDir "build\Desktop_Qt_6_8_3_MinGW_64_bit-Release"
$resolvedBuildDir = if ($BuildDir) { (Resolve-Path $BuildDir).Path } else { $defaultBuildDir }

$exeName = "IMClientMVP.exe"
$sourceExe = Join-Path $resolvedBuildDir $exeName
$stageDir = Join-Path $repoRoot "package\stage"
$outDir = Join-Path $repoRoot "package\out"
$issFile = Join-Path $repoRoot "package\im.iss"

if (!(Test-Path $issFile)) {
    throw "Cannot find Inno script: $issFile"
}

Write-Host "[1/5] Build release target..."
cmake --build $resolvedBuildDir --config Release

if (!(Test-Path $sourceExe)) {
    throw "Release executable not found: $sourceExe"
}

Write-Host "[2/5] Prepare clean staging directory..."
if (Test-Path $stageDir) {
    Remove-Item $stageDir -Recurse -Force
}
New-Item -ItemType Directory -Path $stageDir | Out-Null
New-Item -ItemType Directory -Path $outDir -Force | Out-Null

Copy-Item $sourceExe (Join-Path $stageDir $exeName) -Force

$windeployqtPath = Resolve-WindeployqtPath -ProvidedQtBinDir $QtBinDir
$isccResolvedPath = Resolve-IsccPath -ProvidedPath $IsccPath

Write-Host "[3/5] Deploy Qt runtime and QML modules..."
& $windeployqtPath --release --qmldir $projectDir (Join-Path $stageDir $exeName)

Write-Host "[4/5] Build installer with Inno Setup..."
& $isccResolvedPath "/DMyAppDir=$stageDir" "/DMyAppVersion=$Version" "/DMyAppPublisher=$Publisher" "/O$outDir" $issFile

Write-Host "[5/5] Done. Installer output:"
Get-ChildItem $outDir -Filter "im*.exe" | Select-Object FullName, Length, LastWriteTime
