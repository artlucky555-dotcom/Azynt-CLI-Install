# Azynt CLI - Online Installer
# Usage: irm https://raw.githubusercontent.com/artos555/NoxCLi/main/install-online.ps1 | iex

$ErrorActionPreference = "Stop"

Write-Host ""
Write-Host "========================================" -ForegroundColor Cyan
Write-Host "   Azynt CLI - Online Installer" -ForegroundColor Cyan
Write-Host "========================================" -ForegroundColor Cyan
Write-Host ""

# Configuration
$INSTALL_DIR = "$env:LOCALAPPDATA\Azynt"
$BIN_DIR = "$INSTALL_DIR\bin"
$EXE_NAME = "azynt.exe"
$GITHUB_REPO = "artlucky555-dotcom/Azynt-CLI"
$DOWNLOAD_URL = "https://github.com/$GITHUB_REPO/releases/latest/download/azynt-windows-x64.exe"

# Check if running as Administrator
$isAdmin = ([Security.Principal.WindowsPrincipal] [Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)

if (-not $isAdmin) {
    Write-Host "[ERROR] Please run PowerShell as Administrator!" -ForegroundColor Red
    Write-Host "Right-click PowerShell and select 'Run as administrator'" -ForegroundColor Yellow
    exit 1
}

# Create installation directory
Write-Host "[1/4] Creating installation directory..." -ForegroundColor Yellow
if (-not (Test-Path $INSTALL_DIR)) {
    New-Item -ItemType Directory -Path $INSTALL_DIR -Force | Out-Null
}
if (-not (Test-Path $BIN_DIR)) {
    New-Item -ItemType Directory -Path $BIN_DIR -Force | Out-Null
}
Write-Host "[OK] Directory created: $BIN_DIR" -ForegroundColor Green

# Download executable
Write-Host ""
Write-Host "[2/4] Downloading Azynt CLI..." -ForegroundColor Yellow
$exePath = "$BIN_DIR\$EXE_NAME"

try {
    # Use WebClient for better progress display
    $webClient = New-Object System.Net.WebClient
    $webClient.DownloadFile($DOWNLOAD_URL, $exePath)
    Write-Host "[OK] Downloaded successfully" -ForegroundColor Green
} catch {
    Write-Host "[ERROR] Failed to download: $_" -ForegroundColor Red
    Write-Host ""
    Write-Host "Please check:" -ForegroundColor Yellow
    Write-Host "1. Internet connection is working" -ForegroundColor Yellow
    Write-Host "2. GitHub release exists at: $DOWNLOAD_URL" -ForegroundColor Yellow
    exit 1
}

# Verify download
if (-not (Test-Path $exePath)) {
    Write-Host "[ERROR] Download failed - file not found" -ForegroundColor Red
    exit 1
}

# Add to PATH
Write-Host ""
Write-Host "[3/4] Adding to PATH..." -ForegroundColor Yellow

$currentPath = [Environment]::GetEnvironmentVariable("Path", "User")
if ($currentPath -notlike "*$BIN_DIR*") {
    $newPath = "$currentPath;$BIN_DIR"
    [Environment]::SetEnvironmentVariable("Path", $newPath, "User")
    Write-Host "[OK] Added to PATH successfully" -ForegroundColor Green
} else {
    Write-Host "[OK] Already in PATH" -ForegroundColor Green
}

# Update current session PATH
$env:Path = [System.Environment]::GetEnvironmentVariable("Path", "Machine") + ";" + [System.Environment]::GetEnvironmentVariable("Path", "User")

# Test installation
Write-Host ""
Write-Host "[4/4] Testing installation..." -ForegroundColor Yellow

try {
    $version = & $exePath --version 2>&1
    Write-Host "[OK] Installation successful!" -ForegroundColor Green
} catch {
    Write-Host "[WARNING] Installation completed but test failed" -ForegroundColor Yellow
}

Write-Host ""
Write-Host "========================================" -ForegroundColor Cyan
Write-Host "   Installation Complete!" -ForegroundColor Cyan
Write-Host "========================================" -ForegroundColor Cyan
Write-Host ""
Write-Host "Installation Directory: $INSTALL_DIR" -ForegroundColor White
Write-Host "Executable Location: $exePath" -ForegroundColor White
Write-Host ""
Write-Host "To use Azynt CLI, type: " -NoNewline -ForegroundColor White
Write-Host "azynt" -ForegroundColor Green
Write-Host ""
Write-Host "NOTE: Restart your terminal or run: " -NoNewline -ForegroundColor Yellow
Write-Host "refreshenv" -ForegroundColor Cyan
Write-Host ""
