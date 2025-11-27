# 🚀 Transcribe Suite - One-Click Launch

## Quick Start

### Windows

Double-click or run from PowerShell:

```powershell
cd transcribe-suite
.\bin\setup_and_run.ps1
```

Or simply double-click:
```
transcribe-suite\start.bat
```

### macOS / Linux

```bash
cd transcribe-suite
chmod +x bin/setup_and_run.sh
./bin/setup_and_run.sh
```

## What it does

The script automatically:

1. ✅ Checks Python/Node.js/Git requirements
2. ✅ Creates Python virtual environment
3. ✅ Installs all dependencies (requirements.txt + FastAPI)
4. ✅ Pre-downloads and caches ML models (~2.3 GB)
5. ✅ Validates Hugging Face token
6. ✅ Launches API server on http://localhost:5002

## Usage

### First Time (with models download)

```powershell
# Set your HF token first
$env:PYANNOTE_TOKEN = "hf_xxx..."

# Run setup (includes model download ~15 min)
.\bin\setup_and_run.ps1
```

### Subsequent Runs (models already cached)

```powershell
# Just run again - models are in local cache
$env:PYANNOTE_TOKEN = "hf_xxx..."
.\bin\setup_and_run.ps1 -SkipModels
```

## Options

```powershell
# Skip model download (faster)
.\bin\setup_and_run.ps1 -SkipModels

# Use different port
.\bin\setup_and_run.ps1 -Port 5003

# Dev mode (skip npm install for frontend)
.\bin\setup_and_run.ps1 -DevMode
```

## Access the services

Once running, open in your browser:

- **Frontend**: http://localhost:5173
- **API Health**: http://localhost:5002/health
- **API Docs**: http://localhost:5002/docs (Swagger)

## Frontend (separate terminal)

If you want to run the frontend separately:

```powershell
cd frontend-react
npm install  # first time only
npm run dev
```

## Troubleshooting

### "PYANNOTE_TOKEN not set"

```powershell
$env:PYANNOTE_TOKEN = "hf_votre_token"
```

### "Python not found"

Install Python from https://python.org (3.9+)

### "Port already in use"

```powershell
# Use different port
.\bin\setup_and_run.ps1 -Port 5003
```

### "npm not found"

Install Node.js from https://nodejs.org (optional, frontend won't run)

## What's installed

- **Whisper `medium`**: ~1.5 GB (speech-to-text)
- **Pyannote 3.1**: ~500 MB (speaker diarization)
- **WhisperX**: ~350 MB (word-level alignment)

**Total**: ~2.3 GB cached locally

## Offline Usage

After the first setup run:
- ✅ Works completely offline (no internet needed)
- ✅ Models cached in `~/.cache/huggingface/hub/`
- ✅ Process audio files without internet connection

---

**Issues?** Check logs in `logs/api_server.log`
