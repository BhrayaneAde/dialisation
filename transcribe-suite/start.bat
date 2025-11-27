@echo off
REM Transcribe Suite - One-click launcher for Windows
REM This batch file sets up and runs everything

setlocal enabledelayedexpansion

REM Check if we're in the right directory
if not exist "src\api.py" (
    echo Error: Please run this from the transcribe-suite directory
    echo Usage: cd transcribe-suite ^&^& start.bat
    pause
    exit /b 1
)

REM Determine the PowerShell execution policy
echo Launching Transcribe Suite setup...
powershell -ExecutionPolicy Bypass -NoProfile -File "bin\setup_and_run.ps1" %*

if errorlevel 1 (
    echo Setup failed. Press any key to exit.
    pause
    exit /b 1
)
