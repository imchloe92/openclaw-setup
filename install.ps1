# ============================================
# OpenClaw 1-Click Installer for Windows
# By Chloe 🌀
# ============================================
# 
# USAGE: Right-click → Run with PowerShell (as Admin)
# OR: irm https://raw.githubusercontent.com/imchloe92/openclaw-setup/main/install.ps1 | iex
#
# What it does:
# 1. Installs Node.js (if missing)
# 2. Installs OpenClaw
# 3. Runs setup wizard
# 4. Installs as background service
# ============================================

$ErrorActionPreference = "Continue"
Write-Host ""
Write-Host "  ╔══════════════════════════════════════╗" -ForegroundColor Cyan
Write-Host "  ║   🦞 OpenClaw 1-Click Installer     ║" -ForegroundColor Cyan
Write-Host "  ║   For Windows — by Chloe 🌀          ║" -ForegroundColor Cyan
Write-Host "  ╚══════════════════════════════════════╝" -ForegroundColor Cyan
Write-Host ""

# Step 1: Check Node.js
Write-Host "[1/5] Checking Node.js..." -ForegroundColor Yellow
$nodeVersion = $null
try { $nodeVersion = node -v 2>$null } catch {}

if ($nodeVersion) {
    Write-Host "  ✅ Node.js $nodeVersion found" -ForegroundColor Green
} else {
    Write-Host "  ⬇️ Installing Node.js..." -ForegroundColor Yellow
    
    # Download Node.js LTS installer
    $nodeUrl = "https://nodejs.org/dist/v22.16.0/node-v22.16.0-x64.msi"
    $nodeInstaller = "$env:TEMP\node-installer.msi"
    
    try {
        Invoke-WebRequest -Uri $nodeUrl -OutFile $nodeInstaller -UseBasicParsing
        Start-Process msiexec.exe -ArgumentList "/i `"$nodeInstaller`" /qn" -Wait -NoNewWindow
        
        # Refresh PATH
        $env:Path = [System.Environment]::GetEnvironmentVariable("Path", "Machine") + ";" + [System.Environment]::GetEnvironmentVariable("Path", "User")
        
        $nodeVersion = node -v 2>$null
        if ($nodeVersion) {
            Write-Host "  ✅ Node.js $nodeVersion installed!" -ForegroundColor Green
        } else {
            Write-Host "  ❌ Node.js install failed. Please install manually from https://nodejs.org" -ForegroundColor Red
            Write-Host "  After installing, re-run this script." -ForegroundColor Red
            Read-Host "Press Enter to exit"
            exit 1
        }
    } catch {
        Write-Host "  ❌ Download failed. Please install Node.js manually from https://nodejs.org" -ForegroundColor Red
        Read-Host "Press Enter to exit"
        exit 1
    }
}

# Step 2: Install OpenClaw
Write-Host ""
Write-Host "[2/5] Installing OpenClaw..." -ForegroundColor Yellow

npm i -g openclaw 2>&1 | Out-Null
$clawVersion = openclaw --version 2>$null

if ($clawVersion) {
    Write-Host "  ✅ OpenClaw $clawVersion installed!" -ForegroundColor Green
} else {
    Write-Host "  ❌ OpenClaw install failed" -ForegroundColor Red
    Read-Host "Press Enter to exit"
    exit 1
}

# Step 3: Run Doctor/Setup
Write-Host ""
Write-Host "[3/5] Running setup wizard..." -ForegroundColor Yellow
Write-Host "  Follow the prompts below to configure OpenClaw" -ForegroundColor Gray
Write-Host ""

openclaw doctor

# Step 4: Install as service
Write-Host ""
Write-Host "[4/5] Installing as background service..." -ForegroundColor Yellow

openclaw gateway install 2>&1

Write-Host "  ✅ OpenClaw service installed!" -ForegroundColor Green

# Step 5: Start gateway
Write-Host ""
Write-Host "[5/5] Starting OpenClaw..." -ForegroundColor Yellow

openclaw gateway start 2>&1

Write-Host ""
Write-Host "  ╔══════════════════════════════════════╗" -ForegroundColor Green
Write-Host "  ║   🎉 OpenClaw is READY!              ║" -ForegroundColor Green
Write-Host "  ║                                      ║" -ForegroundColor Green
Write-Host "  ║   Gateway: http://localhost:18789     ║" -ForegroundColor Green
Write-Host "  ║   Runs in background automatically   ║" -ForegroundColor Green
Write-Host "  ║                                      ║" -ForegroundColor Green
Write-Host "  ║   Next: Connect Discord/Telegram     ║" -ForegroundColor Green
Write-Host "  ║   Run: openclaw onboard              ║" -ForegroundColor Green
Write-Host "  ╚══════════════════════════════════════╝" -ForegroundColor Green
Write-Host ""
Read-Host "Press Enter to exit"
