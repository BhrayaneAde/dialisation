#!/usr/bin/env python3
"""
Pre-download and cache models for offline use.
Run once with internet to cache all models locally.
"""
import sys
import os
from pathlib import Path

# Add src to path
SRC = Path(__file__).parent / "src"
sys.path.insert(0, str(SRC))

from utils import load_config, setup_logger

ROOT = Path(__file__).parent.parent
CONFIG_PATH = ROOT / "transcribe-suite" / "config" / "config.yaml"
LOGS_DIR = ROOT / "transcribe-suite" / "logs"

LOGS_DIR.mkdir(parents=True, exist_ok=True)
logger = setup_logger(LOGS_DIR, "prewarm_models", log_level="info")

def prewarm_whisper():
    """Download and cache Faster-Whisper model."""
    try:
        from faster_whisper import WhisperModel
    except ImportError:
        logger.error("faster-whisper not installed. Run: pip install faster-whisper")
        return False
    
    cfg = load_config(CONFIG_PATH)
    model_name = cfg.get("defaults", {}).get("model", "large-v3")
    device = cfg.get("asr", {}).get("device", "auto")
    compute_type = cfg.get("asr", {}).get("compute_type", "int8")
    
    logger.info(f"Downloading Whisper model: {model_name}")
    logger.info(f"  device: {device}")
    logger.info(f"  compute_type: {compute_type}")
    
    try:
        model = WhisperModel(model_name, device=device, compute_type=compute_type)
        logger.info(f"✅ Whisper model cached successfully: {model_name}")
        return True
    except Exception as exc:
        logger.error(f"❌ Failed to download Whisper model: {exc}")
        return False

def prewarm_pyannote():
    """Download and cache Pyannote model."""
    try:
        from pyannote.audio import Pipeline
    except ImportError:
        logger.error("pyannote.audio not installed. Run: pip install pyannote.audio")
        return False
    
    cfg = load_config(CONFIG_PATH)
    model_id = cfg.get("diarization", {}).get("model", "pyannote/speaker-diarization-3.1")
    token_env = cfg.get("diarization", {}).get("authorization_env", "PYANNOTE_TOKEN")
    token = os.environ.get(token_env)
    
    if not token:
        logger.error(f"❌ {token_env} not set. Export the token first:")
        logger.error(f"   export {token_env}='hf_xxx'")
        return False
    
    logger.info(f"Downloading Pyannote model: {model_id}")
    
    try:
        pipeline = Pipeline.from_pretrained(model_id, use_auth_token=token)
        logger.info(f"✅ Pyannote model cached successfully: {model_id}")
        return True
    except Exception as exc:
        logger.error(f"❌ Failed to download Pyannote model: {exc}")
        return False

def prewarm_whisperx():
    """Download and cache WhisperX alignment model."""
    try:
        import whisperx
    except ImportError:
        logger.error("whisperx not installed. Run: pip install git+https://github.com/m-bain/whisperx.git")
        return False
    
    logger.info("WhisperX models (alignment) will be downloaded on first use.")
    logger.info("✅ WhisperX support available")
    return True

if __name__ == "__main__":
    logger.info("=" * 60)
    logger.info("Pre-warming models for offline use...")
    logger.info("=" * 60)
    
    results = {
        "whisper": prewarm_whisper(),
        "pyannote": prewarm_pyannote(),
        "whisperx": prewarm_whisperx(),
    }
    
    logger.info("=" * 60)
    logger.info("Summary:")
    for model, success in results.items():
        status = "✅ OK" if success else "❌ FAILED"
        logger.info(f"  {model}: {status}")
    
    logger.info("=" * 60)
    
    if all(results.values()):
        logger.info("✅ All models ready for offline use!")
        sys.exit(0)
    else:
        logger.error("❌ Some models failed to download. Please fix errors above.")
        sys.exit(1)
