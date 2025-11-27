# 📦 Project Structure Summary

## 🎯 One-Click Launch

### Windows
- **`launch.bat`** (at project root) — Double-click to start everything
- `transcribe-suite/start.bat` — Alternative launcher
- `transcribe-suite/bin/setup_and_run.ps1` — PowerShell script with options

### macOS / Linux
- `transcribe-suite/bin/setup_and_run.sh` — One-click setup & launch

---

## 📂 Key Files

### Launchers (pick one)
```
launch.bat                              ← 🎯 EASIEST: Double-click this
transcribe-suite/start.bat              ← Alternative (Windows)
transcribe-suite/bin/setup_and_run.ps1  ← PowerShell with options
transcribe-suite/bin/setup_and_run.sh   ← Bash (Unix/macOS)
```

### Documentation
```
README_MAIN.md       ← 📖 MAIN README (architecture, features, API)
START_HERE.md        ← 🚀 Quick start reference
QUICKSTART.md        ← 📋 Detailed setup (in transcribe-suite/)
```

### Backend (Transcribe Suite)
```
transcribe-suite/
├─ src/api.py                ← FastAPI wrapper (port 5002)
├─ src/diarize.py            ← Speaker diarization (Pyannote)
├─ src/asr.py                ← Speech-to-text (Faster-Whisper)
├─ src/align.py              ← Word alignment (WhisperX)
├─ config/config.yaml        ← Configuration (models, thresholds)
├─ bin/
│  ├─ setup_and_run.ps1      ← Main setup script (PowerShell)
│  ├─ setup_and_run.sh       ← Main setup script (Bash)
│  ├─ prewarm_models.py      ← Download models to cache
│  └─ run_api.ps1            ← Run API server
├─ requirements.txt          ← Python dependencies
├─ .env.example              ← Example env vars (copy to .env.local)
└─ logs/                      ← Application logs
```

### Frontend (React)
```
frontend-react/
├─ src/
│  ├─ App.jsx
│  ├─ components/
│  │  ├─ FileUpload.jsx      ← Audio upload + diarization
│  │  └─ DiarizationResults.jsx ← Results display
│  └─ index.css
├─ package.json
├─ vite.config.js
└─ index.html
```

---

## 🚀 How to Use

### First Time Setup (~15 min)

1. **Set Hugging Face token** (required):
   ```powershell
   $env:PYANNOTE_TOKEN = "hf_your_token_here"
   ```

2. **Run launcher** (pick one):
   - Windows: Double-click `launch.bat` at project root
   - Or: `cd transcribe-suite && .\bin\setup_and_run.ps1`
   - Or: `cd transcribe-suite && bash bin/setup_and_run.sh` (macOS/Linux)

3. The script will:
   - ✅ Check Python/Node.js
   - ✅ Create virtual environment
   - ✅ Install dependencies
   - ✅ Download models (~2.3 GB)
   - ✅ Start API server (port 5002)

4. **Open in browser**:
   - Frontend: http://localhost:5173
   - API docs: http://localhost:5002/docs

### Subsequent Runs

Same command (models cached locally):
```powershell
$env:PYANNOTE_TOKEN = "hf_your_token_here"
cd transcribe-suite
.\bin\setup_and_run.ps1 -SkipModels  # Skip model check for speed
```

---

## ⚙️ Configuration

Edit `transcribe-suite/config/config.yaml`:

```yaml
defaults:
  model: medium                  # Whisper: tiny/base/small/medium/large-v3
  lang: auto                     # Language: auto/fr/en

diarization:
  max_speakers: 4                # Max speakers to identify
  min_speaker_turn: 1.2          # Min seconds for speaker switch
  device: cpu                    # Device: cpu/cuda

asr:
  compute_type: int8             # int8 for CPU
  chunk_length: 20.0             # Process audio in chunks
  max_workers: 8                 # Parallel processing
```

---

## 📊 Model Sizes

| Model | Size | Quality | Speed |
|-------|------|---------|-------|
| `tiny` | ~340 MB | Low | Very fast |
| `base` | ~720 MB | Medium | Fast |
| `small` | ~1.2 GB | Good | Medium |
| `medium` (default) | ~1.5 GB | Excellent | Slow |
| `large-v3` | ~3.1 GB | Best | Very slow |

Currently configured: **`medium` (~1.5 GB)**

---

## 🔌 API Endpoints

| Endpoint | Method | Purpose |
|----------|--------|---------|
| `/health` | GET | Server health check |
| `/diarize` | POST | Upload audio, get speaker segments |
| `/diarize-batch` | POST | Diarize with custom max_speakers |
| `/config` | GET | View current configuration |

**Example**:
```bash
curl -F "audio=@audio.wav" http://localhost:5002/diarize
```

---

## 📤 Outputs

After processing, files appear in: `TRANSCRIPT - <filename>/`

- **`.md`** — Markdown with sections/speakers (Obsidian-compatible)
- **`.txt`** — Plain readable text
- **`.json`** — RAG-ready structured JSON
- **`.srt`** / **`.vtt`** — Video subtitles
- **`.low_confidence.csv`** — QA audit (low-confidence words)
- **`.chunks.jsonl`** — LLM-friendly chunks

---

## 🔐 Environment Variables

Create `transcribe-suite/.env.local` (not committed):

```
PYANNOTE_TOKEN=hf_xxx...
DIAR_DEVICE=cpu
POST_THREADS=8
```

Or set in terminal:
```powershell
$env:PYANNOTE_TOKEN = "hf_xxx..."
```

---

## 📝 Logs

Check `transcribe-suite/logs/` for:
- `api_server.log` — API server output
- `asr_worker_*.log` — Transcription worker logs
- `run_manifest.json` — Pipeline run summary

---

## ❓ Common Tasks

### Change model size
```yaml
# In config.yaml
defaults:
  model: small  # or: tiny, base, small, medium, large-v3
```

### Change number of speakers
```yaml
diarization:
  max_speakers: 2  # or: 1, 3, 4, 5, etc.
```

### Run API on different port
```powershell
.\bin\setup_and_run.ps1 -Port 5003
```

### Skip model download (faster)
```powershell
.\bin\setup_and_run.ps1 -SkipModels
```

### Run frontend separately
```bash
cd frontend-react
npm install  # first time only
npm run dev
```

---

## 🧹 Cleanup

Remove everything and start fresh:

```bash
# Remove venv
rm -rf transcribe-suite/.venv

# Remove cache (optional, keeps models)
rm -rf transcribe-suite/work/

# Remove logs
rm -rf transcribe-suite/logs/

# Reinstall
cd transcribe-suite
.\bin\setup_and_run.ps1
```

---

## 🐛 Troubleshooting

| Problem | Solution |
|---------|----------|
| `PYANNOTE_TOKEN not set` | `$env:PYANNOTE_TOKEN = "hf_xxx"` |
| `Python not found` | Install from https://python.org |
| `Port already in use` | Use different port: `-Port 5003` |
| `Out of memory` | Reduce `max_workers` or use smaller model |
| `Slow transcription` | Check CPU usage; reduce workers if maxed |
| `Models won't download` | Check internet + token validity |

---

## 🎯 Next Steps

1. **Set token**: Get one at https://huggingface.co/settings/tokens
2. **Launch**: Run `launch.bat` or one of the setup scripts
3. **Upload audio**: Open http://localhost:5173 and upload
4. **View results**: Download transcription with speaker attribution

---

## 📚 More Info

- **Main README**: `README_MAIN.md`
- **Quick Start**: `START_HERE.md`
- **Detailed Setup**: `QUICKSTART.md` (in transcribe-suite/)
- **Config Docs**: `transcribe-suite/config/config.yaml` (commented)

---

**Ready?** Double-click `launch.bat` and go! 🚀
