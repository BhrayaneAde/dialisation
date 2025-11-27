# 🎙️ Transcribe Suite

> **Local high-quality transcription** with **multi-speaker diarization**, **word-level alignment**, **intelligent chaptering**, and **RAG-ready exports** — all offline.

## ⚡ Quick Start (30 seconds)

### Windows
```powershell
cd transcribe-suite
.\bin\setup_and_run.ps1
```

### macOS / Linux
```bash
cd transcribe-suite
./bin/setup_and_run.sh
```

Then open: **http://localhost:5173** (frontend) + **http://localhost:5002** (API)

---

## 📋 What's Included

| Component | Version | Size | Status |
|-----------|---------|------|--------|
| **Whisper (ASR)** | medium | ~1.5 GB | ✅ CPU-optimized |
| **Pyannote (Diarization)** | 3.1 | ~500 MB | ✅ Multi-speaker |
| **WhisperX (Alignment)** | latest | ~350 MB | ✅ Word-level |
| **React Frontend** | Vite | - | ✅ Responsive UI |
| **FastAPI Backend** | latest | - | ✅ Local API |

**Total footprint**: ~2.3 GB after first setup

---

## 🎯 Features

✨ **Transcription**
- OpenAI Whisper large model (high accuracy)
- Auto language detection (FR/EN/multi)
- Word-level confidence scores

🎤 **Diarization** (Who's speaking?)
- Identifies up to 4 speakers by default
- Configurable thresholds
- Robust in noisy environments

📍 **Alignment**
- Precise word timestamps
- Syllable-level accuracy
- Perfect for video/editing workflows

📚 **Chaptering**
- Auto-detect sections (3–8 min per chapter)
- Generate summaries per chapter
- Preserve speaker attribution

📤 **Exports**
- `.md` (Obsidian-ready with sections)
- `.txt` (readable transcription)
- `.json` (RAG-ready structure)
- `.srt` / `.vtt` (subtitles)
- `.low_confidence.csv` (QA audit)
- `.chunks.jsonl` (LLM-friendly chunks)

---

## 🏗️ Architecture

```
frontend-react/        ← React + Vite (port 5173)
    ├─ FileUpload.jsx
    ├─ DiarizationResults.jsx
    └─ LiveTranscription.jsx

transcribe-suite/      ← Backend (port 5002)
    ├─ src/
    │  ├─ api.py           ← FastAPI wrapper
    │  ├─ diarize.py       ← Pyannote orchestration
    │  ├─ asr.py           ← Faster-Whisper parallel
    │  ├─ align.py         ← WhisperX alignment
    │  ├─ clean.py         ← Text normalization
    │  └─ pipeline.py      ← Full pipeline
    ├─ config/
    │  └─ config.yaml      ← Configuration
    └─ bin/
       ├─ setup_and_run.ps1 ← One-click setup (Windows)
       ├─ setup_and_run.sh  ← One-click setup (Unix)
       ├─ start.bat         ← Windows launcher
       └─ prewarm_models.py ← Model downloader

.cache/huggingface/hub/  ← Local model cache (~2.3 GB)
```

---

## 📖 Setup Explained

### 1. First Time (with internet required)

The one-click setup does:

1. **Create venv** — Python virtual environment
2. **Install deps** — `pip install -r requirements.txt + fastapi`
3. **Download models** — Whisper, Pyannote, WhisperX to local cache (~15 min)
4. **Validate token** — Check PYANNOTE_TOKEN from Hugging Face
5. **Launch API** — FastAPI server on port 5002
6. **Launch frontend** — React dev server on port 5173

### 2. Subsequent Runs (offline)

Just run the same command again — everything is cached!

```powershell
.\bin\setup_and_run.ps1 -SkipModels  # Skip model check
```

---

## 🔧 Configuration

Edit `transcribe-suite/config/config.yaml`:

```yaml
defaults:
  model: medium              # Whisper model size
  lang: auto                 # auto, fr, en, etc.

diarization:
  max_speakers: 4            # Max speakers to identify
  min_speaker_turn: 1.2      # Min seconds for speaker switch

asr:
  compute_type: int8         # int8 (CPU opt), float16, auto
  chunk_length: 20.0         # Process audio in 20s chunks
  beam_size: 1               # Speed over quality
```

---

## 💻 API Endpoints

### `/health` (GET)
Health check
```bash
curl http://localhost:5002/health
# {"status": "ok", "service": "Transcribe Suite Diarization API"}
```

### `/diarize` (POST)
Upload audio, get speaker segments
```bash
curl -F "audio=@podcast.wav" http://localhost:5002/diarize
# Returns: {segments, speakers_summary, rttm_path}
```

### `/config` (GET)
View current diarization config
```bash
curl http://localhost:5002/config
```

---

## 🌐 Frontend

**URL**: http://localhost:5173

**Features**:
- Drag-and-drop audio upload
- Real-time processing status
- Speaker timeline visualization
- Confidence score heatmap
- Export transcription

---

## 🔑 Requirements

### Hugging Face Token

Get a **read-only token** from https://huggingface.co/settings/tokens

Then set it (before running):

```powershell
# Windows (PowerShell)
$env:PYANNOTE_TOKEN = "hf_xxx..."

# macOS/Linux (bash)
export PYANNOTE_TOKEN="hf_xxx..."
```

### System Requirements

| Requirement | Minimum | Recommended |
|-------------|---------|-------------|
| Python | 3.9 | 3.11+ |
| RAM | 4 GB | 8+ GB |
| Disk | 5 GB | 10+ GB |
| CPU | 2 cores | 4+ cores |
| GPU | None | Optional (not configured) |

---

## 📚 Usage Examples

### Transcribe with frontend

1. Run one-click setup
2. Open http://localhost:5173
3. Upload audio file (MP3, WAV, M4A)
4. View speaker timeline + download transcription

### Use API directly

```bash
# Upload and diarize
curl -F "audio=@meeting.wav" http://localhost:5002/diarize > output.json

# Get speaker breakdown
jq '.speakers' output.json
# {
#   "SPEAKER_00": {"duration": 125.5, "segment_count": 8},
#   "SPEAKER_01": {"duration": 89.3, "segment_count": 6}
# }
```

### Batch processing

Process multiple files in a loop:

```bash
for file in *.wav; do
    echo "Processing: $file"
    curl -F "audio=@$file" http://localhost:5002/diarize | \
        jq '.speakers' > "${file%.wav}_speakers.json"
done
```

---

## 🚨 Troubleshooting

| Issue | Solution |
|-------|----------|
| **"PYANNOTE_TOKEN not set"** | `$env:PYANNOTE_TOKEN = "hf_xxx"` |
| **"Port 5002 already in use"** | `.\bin\setup_and_run.ps1 -Port 5003` |
| **"Python not found"** | Install from https://python.org |
| **"Models won't download"** | Check internet + token validity |
| **"Slow transcription"** | Reduce `max_workers` in config.yaml |
| **"Out of memory"** | Use `small` model instead of `medium` |

Check logs: `transcribe-suite/logs/api_server.log`

---

## 📄 Exports

After transcription, find outputs in: `TRANSCRIPT - <audio_name>/`

- **`.md`** — Sections, speakers, timestamps (Obsidian-ready)
- **`.txt`** — Clean readable text (copy-paste friendly)
- **`.json`** — RAG-ready JSON (sections, paragraphs, chunks, speaker)
- **`.srt`** / **`.vtt`** — Subtitles for video
- **`.low_confidence.csv`** — Words with low confidence (QA)
- **`.chunks.jsonl`** — LLM-friendly chunks (~400 tokens, with overlap)
- **`.chapters.json`** — Auto-detected chapters with timestamps

---

## 🔒 Privacy & Security

✅ **Fully local** — No cloud uploads
✅ **Offline after setup** — Models cached locally
✅ **Open source** — Inspect what you run
✅ **No telemetry** — No tracking or analytics

---

## 🛠️ Development

### Run frontend in dev mode
```bash
cd frontend-react
npm run dev
```

### Run API with hot-reload
```bash
cd transcribe-suite
source .venv/bin/activate  # or .venv\Scripts\Activate.ps1 on Windows
python -m uvicorn src.api:app --reload
```

### Run tests
```bash
cd transcribe-suite
pytest tests/
```

---

## 📖 Additional Resources

- **QUICKSTART.md** — Detailed setup instructions
- **START_HERE.md** — Quick reference
- **transcribe-suite/docs/** — Technical docs
- **transcribe-suite/config/config.yaml** — All options explained

---

## 📝 License

Open source. See LICENSE file.

## 🙏 Credits

Built with:
- [OpenAI Whisper](https://github.com/openai/whisper)
- [Faster-Whisper](https://github.com/guillaumekln/faster-whisper)
- [Pyannote.audio](https://github.com/pyannote/pyannote-audio)
- [WhisperX](https://github.com/m-bain/whisperX)

---

## 🤝 Support

**Issues?** Check:
1. `transcribe-suite/logs/` for error details
2. `PYANNOTE_TOKEN` is set correctly
3. Python version ≥ 3.9
4. Sufficient disk space for models

---

**Ready to transcribe?** Run:

```powershell
cd transcribe-suite
.\bin\setup_and_run.ps1
```

🎯 Everything else is automated!
