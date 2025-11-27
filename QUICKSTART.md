# 🎙️ Transcribe Suite - Quick Start Guide

## 📋 Configuration actuelle

- **Modèle ASR**: `medium` (Whisper) ~1.5 GB
- **Modèle Diarisation**: `pyannote/speaker-diarization-3.1` (~500 MB)
- **Quantization**: `int8` (optimisé pour CPU)
- **Total taille modèles**: ~2–2.5 GB

## 🚀 Setup (une seule fois)

### 1. Créer et activer l'environnement virtuel

```powershell
cd transcribe-suite

# Créer venv
python -m venv .venv

# Activer (PowerShell)
.\.venv\Scripts\Activate.ps1

# Ou si vous utilisez cmd.exe:
# .venv\Scripts\activate.bat
```

### 2. Installer les dépendances

```powershell
# Mettre pip à jour
python -m pip install --upgrade pip

# Installer requirements
pip install -r requirements.txt

# Installer FastAPI + Uvicorn pour le serveur API
pip install fastapi uvicorn[standard]
```

### 3. Définir le token Hugging Face (obligatoire pour diarisation)

```powershell
# Temporaire (session actuelle)
$env:PYANNOTE_TOKEN = "hf_votre_token_ici"

# Vérifier que c'est bien défini
Write-Output $env:PYANNOTE_TOKEN
```

## 📥 Pré-télécharger les modèles (recommandé)

Cela télécharge les modèles une fois et les met en cache localement pour utilisation hors-ligne :

```powershell
cd transcribe-suite

# Activer venv
.\.venv\Scripts\Activate.ps1

# Pré-télécharger
python bin\prewarm_models.py
```

Les modèles seront mis en cache dans : `C:\Users\<Username>\.cache\huggingface\hub\`

## 🎬 Lancer le serveur API

### Option 1 : Avec pré-téléchargement des modèles

```powershell
cd transcribe-suite
.\.venv\Scripts\Activate.ps1
$env:PYANNOTE_TOKEN = "hf_xxx"

# Pré-télécharger (1ère fois) puis lancer le serveur
.\bin\run_api.ps1 -Prewarm
```

### Option 2 : Lancer directement

```powershell
cd transcribe-suite
.\.venv\Scripts\Activate.ps1
$env:PYANNOTE_TOKEN = "hf_xxx"

# Lancer le serveur (modèles téléchargés à la demande)
python src/api.py
```

### Option 3 : Avec uvicorn (avec hot reload)

```powershell
cd transcribe-suite
.\.venv\Scripts\Activate.ps1
$env:PYANNOTE_TOKEN = "hf_xxx"

python -m uvicorn src.api:app --host 0.0.0.0 --port 5002 --reload
```

## 🌐 Lancer le frontend

Dans une **nouvelle fenêtre PowerShell** :

```powershell
cd frontend-react

# Installer dépendances (1ère fois)
npm install

# Lancer dev server (Vite sur port 5173)
npm run dev
```

Puis ouvrez : http://localhost:5173

## 🧪 Tester l'API

### Health check

```powershell
# PowerShell
$response = Invoke-WebRequest -Uri "http://localhost:5002/health"
$response.Content | ConvertFrom-Json
```

### Diariser un fichier audio

```powershell
# Avec curl (PowerShell 7+)
$file = "C:\path\to\audio.wav"
curl -F "audio=@$file" http://localhost:5002/diarize

# Ou avec Invoke-WebRequest
$file = Get-Item "C:\path\to\audio.wav"
$form = @{
    audio = $file
}
Invoke-WebRequest -Uri "http://localhost:5002/diarize" -Form $form -Method Post
```

## 📊 Endpoints disponibles

| Endpoint | Méthode | Description |
|----------|---------|-------------|
| `/health` | GET | Vérifier que le serveur fonctionne |
| `/diarize` | POST | Diariser un fichier audio (frontend) |
| `/diarize-batch` | POST | Diariser avec override `max_speakers` |
| `/config` | GET | Afficher la config diarisation actuelle |

## 🔧 Configuration

Modifier `config/config.yaml` pour ajuster :

- `asr.model` : modèle Whisper (`tiny`, `base`, `small`, `medium`, `large-v3`)
- `diarization.max_speakers` : nombre max de locuteurs
- `diarization.min_speaker_turn` : durée min d'un tour de parole

## 📖 Notes

- **Modèle `medium`** : bon équilibre qualité/taille (~1.5 GB)
- **Total cache** : ~2–2.5 GB pour tous les modèles
- **Offline** : après 1er setup, fonctionne sans internet ✅
- **Token HF** : obligatoire au 1er lancement (pour Pyannote)

## ❓ Dépannage

### "PYANNOTE_TOKEN not set"

```powershell
$env:PYANNOTE_TOKEN = "hf_xxx"
```

### "faster-whisper not installed"

```powershell
pip install faster-whisper
```

### "Port 5002 already in use"

```powershell
# Changer le port
python src/api.py  # modifiez hardcoded port dans src/api.py
# Ou utilisez le script run_api.ps1 :
.\bin\run_api.ps1 -Port 5003
```

---

**Questions ?** Vérifiez les logs dans `logs/api_server.log`
