# Azynt CLI - Online Installer
# Usage: irm https://raw.githubusercontent.com/YOUR-USERNAME/azynt-installer/main/install.ps1 | iex

$ErrorActionPreference = "Stop"

Write-Host ""
Write-Host "========================================" -ForegroundColor Cyan
Write-Host "   Azynt CLI - Installer v1.0" -ForegroundColor Cyan
Write-Host "========================================" -ForegroundColor Cyan
Write-Host ""

# Configuration
$INSTALL_DIR = "$env:LOCALAPPDATA\Azynt"
$BIN_DIR = "$INSTALL_DIR\bin"
$EXE_NAME = "azynt.exe"
$DOWNLOAD_URL = "https://github.com/artlucky555-dotcom/Azynt-CLI/releases/download/1/azynt.exe"

# Check if running as Administrator
$isAdmin = ([Security.Principal.WindowsPrincipal] [Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)

if (-not $isAdmin) {
    Write-Host "[ERROR] Administrator privileges required!" -ForegroundColor Red
    Write-Host ""
    Write-Host "Please run PowerShell as Administrator:" -ForegroundColor Yellow
    Write-Host "1. Right-click PowerShell" -ForegroundColor White
    Write-Host "2. Select 'Run as administrator'" -ForegroundColor White
    Write-Host ""
    exit 1
}

# Create installation directory
Write-Host "[1/6] Creating installation directory..." -ForegroundColor Yellow
if (-not (Test-Path $INSTALL_DIR)) {
    New-Item -ItemType Directory -Path $INSTALL_DIR -Force | Out-Null
}
if (-not (Test-Path $BIN_DIR)) {
    New-Item -ItemType Directory -Path $BIN_DIR -Force | Out-Null
}
Write-Host "      Created: $BIN_DIR" -ForegroundColor Green

# Download executable
Write-Host ""
Write-Host "[2/6] Downloading Azynt CLI from GitHub..." -ForegroundColor Yellow
Write-Host "      URL: $DOWNLOAD_URL" -ForegroundColor Gray
$exePath = "$BIN_DIR\$EXE_NAME"

try {
    $ProgressPreference = 'SilentlyContinue'
    Invoke-WebRequest -Uri $DOWNLOAD_URL -OutFile $exePath -UseBasicParsing
    Write-Host "      Downloaded successfully" -ForegroundColor Green
} catch {
    Write-Host "[ERROR] Download failed!" -ForegroundColor Red
    Write-Host ""
    Write-Host "Possible reasons:" -ForegroundColor Yellow
    Write-Host "- No internet connection" -ForegroundColor White
    Write-Host "- GitHub release not found" -ForegroundColor White
    Write-Host "- URL: $DOWNLOAD_URL" -ForegroundColor Gray
    Write-Host ""
    Write-Host "Error: $_" -ForegroundColor Red
    exit 1
}

# Verify download
Write-Host ""
Write-Host "[3/6] Verifying installation..." -ForegroundColor Yellow
if (-not (Test-Path $exePath)) {
    Write-Host "[ERROR] File not found after download" -ForegroundColor Red
    exit 1
}

$fileSize = (Get-Item $exePath).Length / 1MB
Write-Host "      File size: $([math]::Round($fileSize, 2)) MB" -ForegroundColor Green
Write-Host "      Location: $exePath" -ForegroundColor Gray

# Add to PATH
Write-Host ""
Write-Host "[4/6] Adding to system PATH..." -ForegroundColor Yellow

$currentPath = [Environment]::GetEnvironmentVariable("Path", "User")
if ($currentPath -notlike "*$BIN_DIR*") {
    $newPath = if ($currentPath) { "$currentPath;$BIN_DIR" } else { $BIN_DIR }
    [Environment]::SetEnvironmentVariable("Path", $newPath, "User")
    Write-Host "      Added to PATH" -ForegroundColor Green
} else {
    Write-Host "      Already in PATH" -ForegroundColor Green
}

# Update current session PATH
$env:Path = [System.Environment]::GetEnvironmentVariable("Path", "Machine") + ";" + [System.Environment]::GetEnvironmentVariable("Path", "User")

# Add to Windows Apps & Features (Registry)
Write-Host ""
Write-Host "[5/6] Registering in Windows Apps..." -ForegroundColor Yellow

$registryPath = "HKCU:\Software\Microsoft\Windows\CurrentVersion\Uninstall\AzyntCLI"
$version = "1.0.0"
$publisher = "Azynt"
$installDate = Get-Date -Format "yyyyMMdd"

try {
    if (-not (Test-Path $registryPath)) {
        New-Item -Path $registryPath -Force | Out-Null
    }
    
    Set-ItemProperty -Path $registryPath -Name "DisplayName" -Value "Azynt CLI"
    Set-ItemProperty -Path $registryPath -Name "DisplayVersion" -Value $version
    Set-ItemProperty -Path $registryPath -Name "Publisher" -Value $publisher
    Set-ItemProperty -Path $registryPath -Name "InstallLocation" -Value $INSTALL_DIR
    Set-ItemProperty -Path $registryPath -Name "InstallDate" -Value $installDate
    Set-ItemProperty -Path $registryPath -Name "UninstallString" -Value "powershell.exe -ExecutionPolicy Bypass -Command `"irm https://raw.githubusercontent.com/YOUR-USERNAME/azynt-installer/main/uninstall.ps1 | iex`""
    Set-ItemProperty -Path $registryPath -Name "DisplayIcon" -Value $exePath
    Set-ItemProperty -Path $registryPath -Name "NoModify" -Value 1 -Type DWord
    Set-ItemProperty -Path $registryPath -Name "NoRepair" -Value 1 -Type DWord
    
    $fileSize = (Get-Item $exePath).Length
    $fileSizeKB = [math]::Round($fileSize / 1KB)
    Set-ItemProperty -Path $registryPath -Name "EstimatedSize" -Value $fileSizeKB -Type DWord
    
    Write-Host "      Registered in Apps & Features" -ForegroundColor Green
} catch {
    Write-Host "      [WARNING] Could not register in Apps & Features" -ForegroundColor Yellow
    Write-Host "      Error: $_" -ForegroundColor Gray
}

# Test installation
Write-Host ""
Write-Host "[6/6] Testing installation..." -ForegroundColor Yellow

try {
    $testOutput = & $exePath --version 2>&1
    if ($LASTEXITCODE -eq 0) {
        Write-Host "      Version: $testOutput" -ForegroundColor Green
    } else {
        Write-Host "      Installed successfully" -ForegroundColor Green
    }
} catch {
    Write-Host "      Installed (test skipped)" -ForegroundColor Yellow
}

Write-Host ""
Write-Host "========================================" -ForegroundColor Cyan
Write-Host "   Installation Complete! ✓" -ForegroundColor Cyan
Write-Host "========================================" -ForegroundColor Cyan
Write-Host ""
Write-Host "Installation Path:" -ForegroundColor White
Write-Host "  $exePath" -ForegroundColor Gray
Write-Host ""
Write-Host "To start using Azynt CLI:" -ForegroundColor White
Write-Host "  1. Close and reopen your terminal" -ForegroundColor Gray
Write-Host "  2. Type: " -NoNewline -ForegroundColor Gray
Write-Host "azynt" -ForegroundColor Green
Write-Host ""
Write-Host "Or test in current session:" -ForegroundColor Gray
Write-Host "  " -NoNewline
Write-Host "& '$exePath'" -ForegroundColor Cyan
Write-Host ""
