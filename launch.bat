@echo off
REM Transcribe Suite - Simple Launcher
REM Just double-click this file to start everything!

title Transcribe Suite - Setup & Launch

echo.
echo ╔════════════════════════════════════════════════════════╗
echo ║   Transcribe Suite - One-Click Setup & Launch           ║
echo ╚════════════════════════════════════════════════════════╝
echo.

REM Set token if not already set
if "%PYANNOTE_TOKEN%"=="" (
    echo.
    echo IMPORTANT: You need a Hugging Face token for speaker diarization
    echo Get one at: https://huggingface.co/settings/tokens
    echo.
    set /p PYANNOTE_TOKEN="Enter your HF token (hf_xxx...): "
    echo.
)

REM Check if Python exists
python --version >nul 2>&1
if errorlevel 1 (
    echo Error: Python not found. Please install Python 3.9+ from https://python.org
    pause
    exit /b 1
)

REM Run the main setup script
cd transcribe-suite
powershell -ExecutionPolicy Bypass -NoProfile -File "bin\setup_and_run.ps1"

if errorlevel 1 (
    echo.
    echo ❌ Setup failed. See errors above.
    pause
    exit /b 1
)

echo.
echo ✅ Setup complete!
pause
