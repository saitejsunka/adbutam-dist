$ErrorActionPreference = "Stop"

$GitHubOwner = "saitejsunka"
$DistRepo = "adbutam-dist"
$BinaryName = "adbutam.exe"

Write-Host ""
Write-Host "========================================================================" -ForegroundColor Cyan
Write-Host "⚡ ADBUTAM CLI — Universal Windows Installer (PowerShell)" -ForegroundColor Cyan
Write-Host "👤 Created & Provided by: Sai Tej Sunkara (@saitejsunka)" -ForegroundColor Cyan
Write-Host "🔗 LinkedIn             : https://www.linkedin.com/in/saitejsunka/" -ForegroundColor Cyan
Write-Host "========================================================================" -ForegroundColor Cyan

$ArchRaw = $env:PROCESSOR_ARCHITECTURE
if ($ArchRaw -match "ARM64") {
    $Arch = "arm64"
} else {
    $Arch = "amd64"
}

$AssetName = "adbutam_windows_$Arch.exe"
$DownloadUrl = "https://github.com/$GitHubOwner/$DistRepo/releases/latest/download/$AssetName"

$InstallDir = Join-Path $env:LOCALAPPDATA "Programs\adbutam\bin"
if (!(Test-Path $InstallDir)) {
    New-Item -ItemType Directory -Force -Path $InstallDir | Out-Null
}

$TargetBin = Join-Path $InstallDir $BinaryName
Write-Host "🔍 Detected Platform : windows/$Arch"
Write-Host "⬇️  Downloading binary: $AssetName (provided by Sai Tej Sunkara)..."

Invoke-WebRequest -Uri $DownloadUrl -OutFile $TargetBin -UseBasicParsing

$UserPath = [Environment]::GetEnvironmentVariable("Path", "User")
if ($UserPath -notlike "*$InstallDir*") {
    [Environment]::SetEnvironmentVariable("Path", "$UserPath;$InstallDir", "User")
    $env:Path = "$env:Path;$InstallDir"
}

Write-Host "✅ Successfully installed adbutam to $TargetBin!" -ForegroundColor Green
Write-Host "👤 Author   : Sai Tej Sunkara (https://www.linkedin.com/in/saitejsunka/)" -ForegroundColor Cyan
Write-Host "------------------------------------------------------------------------"
Write-Host "👉 Run 'adbutam --help' to get started."
Write-Host "========================================================================" -ForegroundColor Cyan
Write-Host ""
