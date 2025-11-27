#!/usr/bin/env pwsh
<#
.SYNOPSIS
    Transcribe Suite - One-click setup and launch script
    
.DESCRIPTION
    Sets up the entire environment in one command:
    1. Creates virtual environment
    2. Installs all dependencies
    3. Pre-downloads and caches models
    4. Launches API server (port 5002)
    5. Launches frontend (port 5173)

.PARAMETER SkipModels
    Skip model pre-download (useful if models are already cached)

.PARAMETER Port
    API server port (default: 5002)

.EXAMPLE
    .\setup_and_run.ps1
    .\setup_and_run.ps1 -SkipModels
    .\setup_and_run.ps1 -Port 5003

.NOTES
    Requires: Python 3.9+, Git, Node.js
    Token: Set $env:PYANNOTE_TOKEN before running
#>

param(
    [switch]$SkipModels = $false,
    [int]$Port = 5002,
    [switch]$DevMode = $false  # Skip npm install (faster for dev)
)

$ErrorActionPreference = "Stop"
$ProgressPreference = "SilentlyContinue"

# Colors for output
$colors = @{
    success = "Green"
    error = "Red"
    warning = "Yellow"
    info = "Cyan"
}

function Write-Log {
    param(
        [string]$Message,
        [string]$Type = "info"
    )
    $color = $colors[$Type] ?? "White"
    $prefix = @{
        success = "✅"
        error = "❌"
        warning = "⚠️ "
        info = "ℹ️ "
    }[$Type] ?? "▶️ "
    
    Write-Host "$prefix $Message" -ForegroundColor $color
}

function Test-Requirements {
    Write-Log "Checking requirements..." "info"
    
    # Check Python
    try {
        $pythonVersion = python --version 2>&1
        Write-Log "Found $pythonVersion" "success"
    } catch {
        Write-Log "Python not found. Please install Python 3.9+" "error"
        exit 1
    }
    
    # Check Node.js (optional, for frontend)
    try {
        $nodeVersion = node --version 2>&1
        Write-Log "Found Node.js $nodeVersion" "success"
    } catch {
        Write-Log "Node.js not found. Frontend will not run." "warning"
    }
    
    # Check Git
    try {
        $gitVersion = git --version 2>&1
        Write-Log "Found $gitVersion" "success"
    } catch {
        Write-Log "Git not found (optional)" "warning"
    }
}

function Setup-Venv {
    $VenvPath = ".venv"
    
    if (Test-Path $VenvPath) {
        Write-Log "Virtual environment already exists at $VenvPath" "info"
    } else {
        Write-Log "Creating virtual environment..." "info"
        python -m venv $VenvPath
        
        if ($LASTEXITCODE -ne 0) {
            Write-Log "Failed to create virtual environment" "error"
            exit 1
        }
        Write-Log "Virtual environment created" "success"
    }
    
    return $VenvPath
}

function Activate-Venv {
    param([string]$VenvPath)
    
    $ActivateScript = Join-Path $VenvPath "Scripts\Activate.ps1"
    
    if (-not (Test-Path $ActivateScript)) {
        Write-Log "Activate script not found at $ActivateScript" "error"
        exit 1
    }
    
    Write-Log "Activating virtual environment..." "info"
    & $ActivateScript
}

function Install-Dependencies {
    Write-Log "Installing Python dependencies..." "info"
    
    # Upgrade pip
    Write-Log "Upgrading pip..." "info"
    python -m pip install --upgrade pip --quiet
    
    if ($LASTEXITCODE -ne 0) {
        Write-Log "Failed to upgrade pip" "error"
        exit 1
    }
    
    # Install requirements
    Write-Log "Installing requirements.txt..." "info"
    pip install -r requirements.txt --quiet
    
    if ($LASTEXITCODE -ne 0) {
        Write-Log "Failed to install requirements" "error"
        exit 1
    }
    
    # Install FastAPI + Uvicorn
    Write-Log "Installing FastAPI and Uvicorn..." "info"
    pip install fastapi "uvicorn[standard]" --quiet
    
    if ($LASTEXITCODE -ne 0) {
        Write-Log "Failed to install FastAPI/Uvicorn" "error"
        exit 1
    }
    
    Write-Log "All dependencies installed" "success"
}

function Check-Token {
    if ([string]::IsNullOrEmpty($env:PYANNOTE_TOKEN)) {
        Write-Log "PYANNOTE_TOKEN environment variable not set" "warning"
        Write-Log "Diarization will fail without it" "warning"
        Write-Log ""
        Write-Log "Set it with:" "info"
        Write-Log '  $env:PYANNOTE_TOKEN = "hf_xxx..."' "info"
        Write-Log ""
        
        $response = Read-Host "Continue anyway? (y/n)"
        if ($response -ne "y" -and $response -ne "Y") {
            exit 0
        }
    } else {
        Write-Log "PYANNOTE_TOKEN is set ✓" "success"
    }
}

function Prewarm-Models {
    if ($SkipModels) {
        Write-Log "Skipping model pre-download (--SkipModels)" "info"
        return
    }
    
    Write-Log "Pre-warming models (this may take a few minutes on first run)..." "info"
    
    $prewarmScript = "bin\prewarm_models.py"
    if (-not (Test-Path $prewarmScript)) {
        Write-Log "prewarm_models.py not found" "warning"
        return
    }
    
    python $prewarmScript
    
    if ($LASTEXITCODE -ne 0) {
        Write-Log "Model pre-warm failed (but API may still work)" "warning"
    } else {
        Write-Log "Models ready for offline use" "success"
    }
}

function Show-Startup-Info {
    Write-Host ""
    Write-Log "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━" "info"
    Write-Log "🎙️  Transcribe Suite - Ready to go!" "success"
    Write-Log "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━" "info"
    Write-Host ""
    Write-Log "API Server:" "info"
    Write-Host "  🌐 http://localhost:$Port" -ForegroundColor Cyan
    Write-Host "  📡 /health - health check" -ForegroundColor Cyan
    Write-Host "  📝 /diarize - upload and diarize audio" -ForegroundColor Cyan
    Write-Host "  ⚙️  /config - view diarization config" -ForegroundColor Cyan
    Write-Host ""
    Write-Log "Frontend:" "info"
    Write-Host "  🌐 http://localhost:5173" -ForegroundColor Cyan
    Write-Host ""
    Write-Log "Models:" "info"
    Write-Host "  🎤 Whisper: medium (~1.5 GB)" -ForegroundColor Cyan
    Write-Host "  👥 Pyannote: speaker-diarization-3.1 (~500 MB)" -ForegroundColor Cyan
    Write-Host "  📍 WhisperX: alignment (~350 MB)" -ForegroundColor Cyan
    Write-Host ""
    Write-Log "Press Ctrl+C to stop the server" "warning"
    Write-Log "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━" "info"
    Write-Host ""
}

function Start-API-Server {
    param([int]$Port)
    
    Write-Log "Starting API server on port $Port..." "info"
    Write-Log ""
    
    python -m uvicorn src.api:app --host 0.0.0.0 --port $Port --reload
}

function Start-Frontend {
    # Check if we're in a separate terminal/process
    Write-Log "Frontend setup..." "info"
    
    $frontendPath = "..\frontend-react"
    
    if (-not (Test-Path $frontendPath)) {
        Write-Log "Frontend path not found at $frontendPath" "warning"
        return
    }
    
    Push-Location $frontendPath
    
    if (-not $DevMode) {
        Write-Log "Installing frontend dependencies (npm install)..." "info"
        npm install --silent 2>&1 | Out-Null
        
        if ($LASTEXITCODE -ne 0) {
            Write-Log "npm install failed" "warning"
            Pop-Location
            return
        }
    }
    
    Write-Log "Starting frontend dev server on port 5173..." "info"
    npm run dev
    
    Pop-Location
}

# ==================== Main Script ====================

Write-Host ""
Write-Log "╔════════════════════════════════════════════════════════╗" "info"
Write-Log "║  Transcribe Suite - One-Click Setup & Launch           ║" "info"
Write-Log "╚════════════════════════════════════════════════════════╝" "info"
Write-Host ""

# Get current directory
$scriptPath = Split-Path -Parent $MyInvocation.MyCommand.Path
$isInTranscribeSuite = (Split-Path -Leaf $scriptPath) -eq "bin"

if ($isInTranscribeSuite) {
    # Script is in transcribe-suite/bin
    Set-Location (Split-Path -Parent $scriptPath)
} elseif ((Test-Path "transcribe-suite\bin\setup_and_run.ps1") -and 
          $MyInvocation.MyCommand.Path -eq (Get-Item "transcribe-suite\bin\setup_and_run.ps1").FullName) {
    # Script is in root/transcribe-suite/bin, running from root
    Set-Location "transcribe-suite"
} elseif (Test-Path "bin\setup_and_run.ps1") {
    # Already in transcribe-suite root
} else {
    Write-Log "Please run this script from transcribe-suite/ directory" "error"
    Write-Log "Usage: cd transcribe-suite; .\bin\setup_and_run.ps1" "info"
    exit 1
}

# Verify we're in the right place
if (-not (Test-Path "src\api.py")) {
    Write-Log "Cannot find src\api.py - are we in the transcribe-suite directory?" "error"
    exit 1
}

# Run setup steps
Test-Requirements
$venv = Setup-Venv
Activate-Venv $venv
Install-Dependencies
Check-Token
Prewarm-Models
Show-Startup-Info

# Launch API server
Start-API-Server $Port
