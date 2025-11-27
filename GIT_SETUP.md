# Git Configuration Guide

## .gitignore Setup ✅

The `.gitignore` file at the project root is configured to exclude:

### Python
- ✅ `.venv/` — Virtual environment
- ✅ `transcribe-suite/.venv/` — Specific venv
- ✅ `__pycache__/` — Python bytecode
- ✅ `.pytest_cache/` — Test cache
- ✅ `*.pyc`, `*.pyo` — Compiled files

### Node.js
- ✅ `node_modules/` — NPM packages (frontend)
- ✅ `frontend-react/node_modules/` — Frontend packages
- ✅ `frontend-react/dist/` — Build output
- ✅ `frontend-react/.vite/` — Vite cache

### Backend
- ✅ `transcribe-suite/build/` — Build artifacts
- ✅ `transcribe-suite/logs/` — Application logs
- ✅ `transcribe-suite/work/` — Working directory
- ✅ `transcribe-suite/exports/` — Generated exports

### Media & Models
- ✅ `*.wav`, `*.mp3`, `*.mp4` — Audio/video files (too large)
- ✅ `*.pt`, `*.bin`, `*.onnx` — Model weights (downloaded on setup)

### Environment & Secrets
- ✅ `.env` — Environment variables
- ✅ `.env.local` — Local overrides
- ✅ `.env.*.local` — Environment-specific

### Cache & Temp
- ✅ `*.log` — Log files
- ✅ `*.tmp` — Temporary files
- ✅ `*.swp` — Editor swap files
- ✅ `.DS_Store` — macOS folder metadata
- ✅ `Thumbs.db` — Windows image cache

---

## What Gets Committed ✅

Only these directories get committed to Git:

```
.
├─ .gitignore              ← Git configuration
├─ .env.example            ← Example env vars (for reference)
├─ README_MAIN.md          ← Main documentation
├─ START_HERE.md           ← Quick start guide
├─ QUICKSTART.md           ← Detailed setup
├─ STRUCTURE.md            ← Project structure
├─ launch.bat              ← Windows launcher
├─ 
├─ frontend-react/
│  ├─ src/                 ← React source code
│  ├─ public/              ← Static assets
│  ├─ package.json         ← NPM config (not node_modules!)
│  ├─ vite.config.js       ← Vite config
│  └─ index.html           ← Entry point
│
└─ transcribe-suite/
   ├─ src/                 ← Python backend code
   ├─ config/              ← Configuration YAML
   ├─ bin/                 ← Scripts and launchers
   ├─ tests/               ← Unit tests
   ├─ requirements.txt     ← Python dependencies (not venv!)
   └─ .env.example         ← Example environment

NOT committed:
- node_modules/ (auto-install with `npm install`)
- .venv/ (auto-create with `python -m venv .venv`)
- *.log files
- Generated audio/model files
- .env.local (your secrets)
```

---

## First Clone (After pulling from Git)

When someone clones this repository for the first time, they need to:

### 1. Install Frontend Dependencies
```bash
cd frontend-react
npm install  # Recreates node_modules/
```

### 2. Create Python Venv
```bash
cd transcribe-suite
python -m venv .venv
.venv\Scripts\Activate.ps1  # Windows
# or: source .venv/bin/activate  # macOS/Linux
```

### 3. Install Backend Dependencies
```bash
pip install -r requirements.txt
pip install fastapi uvicorn[standard]
```

### 4. Run One-Click Setup
```bash
.\bin\setup_and_run.ps1  # Windows
# or: bash bin/setup_and_run.sh  # macOS/Linux
```

---

## Git Best Practices

### Before committing, check:
```bash
# See what will be committed
git status

# Check for accidental secrets
git diff --staged | grep -i "token\|password\|key"

# Don't commit these files
git checkout .env.local
git rm --cached transcribe-suite/.venv/
git rm --cached frontend-react/node_modules/
```

### Useful Git Commands
```bash
# See what changed
git status

# Stage changes
git add .

# Commit with message
git commit -m "Your message"

# See history
git log --oneline

# Revert file
git checkout -- path/to/file

# Check ignored files
git check-ignore -v *
```

### If you accidentally committed large files:
```bash
# Remove from history (careful!)
git rm --cached large_file.bin
echo "large_file.bin" >> .gitignore
git commit --amend
```

---

## Collaboration

When working with others:

1. **Pull regularly**: `git pull origin main`
2. **Create branches**: `git checkout -b feature/my-feature`
3. **Keep .env.local local**: Never commit it
4. **Document setup**: Update this guide if setup changes
5. **Use meaningful commit messages**:
   ```
   ✅ Good:  "Add FastAPI diarization endpoint"
   ❌ Bad:   "fix"
   ```

---

## Ignore File Not Working?

If Git is still tracking ignored files:

```bash
# Remove from tracking (but keep locally)
git rm --cached transcribe-suite/.venv/

# Or for directory
git rm -r --cached transcribe-suite/.venv/

# Then commit
git add .gitignore
git commit -m "Update gitignore and remove venv from tracking"
```

---

## Summary

✅ **Committed**: Source code, config, documentation
❌ **Not committed**: Dependencies (venv, node_modules), logs, builds, secrets

**Everything else is automatic!** 🎉
