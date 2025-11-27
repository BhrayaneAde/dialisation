# PowerShell script to setup and run the API server
# Usage: .\bin\run_api.ps1

param(
    [switch]$Prewarm = $false,
    [string]$Port = "5002",
    [string]$Host = "0.0.0.0"
)

$ErrorActionPreference = "Stop"

# Get script directory
$ScriptDir = Split-Path -Parent $MyInvocation.MyCommand.Path
$RootDir = Split-Path -Parent $ScriptDir
$VenvPath = Join-Path $RootDir ".venv"
$ActivateScript = Join-Path $VenvPath "Scripts\Activate.ps1"

# Check if venv exists
if (-not (Test-Path $ActivateScript)) {
    Write-Host "❌ Virtual environment not found at: $VenvPath"
    Write-Host "Run setup first:"
    Write-Host "  python -m venv .venv"
    Write-Host "  .\.venv\Scripts\Activate.ps1"
    Write-Host "  pip install -r requirements.txt"
    Write-Host "  pip install fastapi uvicorn[standard]"
    exit 1
}

# Activate venv
Write-Host "🔧 Activating virtual environment..."
& $ActivateScript

# Check if PYANNOTE_TOKEN is set
if ([string]::IsNullOrEmpty($env:PYANNOTE_TOKEN)) {
    Write-Host "⚠️  WARNING: PYANNOTE_TOKEN not set!"
    Write-Host "   Set it with: `$env:PYANNOTE_TOKEN = 'hf_xxx...'"
    Write-Host ""
}

# Pre-warm models if requested
if ($Prewarm) {
    Write-Host "📥 Pre-warming models (downloading to cache)..."
    python "$RootDir\bin\prewarm_models.py"
    if ($LASTEXITCODE -ne 0) {
        Write-Host "❌ Failed to pre-warm models"
        exit 1
    }
}

# Run API server
Write-Host ""
Write-Host "🚀 Starting API server on $Host`:$Port"
Write-Host "   Frontend will connect to: http://localhost:$Port"
Write-Host "   Press Ctrl+C to stop"
Write-Host ""

python -m uvicorn src.api:app --host $Host --port $Port --reload
