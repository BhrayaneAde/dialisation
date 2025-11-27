"""
API wrapper FastAPI pour exposes la diarisation du pipeline Transcribe Suite.
Lance avec: uvicorn transcribe-suite.src.api:app --host 0.0.0.0 --port 5002 --reload
Ou directement: python transcribe-suite/src/api.py
"""
import os
import sys
import uuid
import tempfile
from pathlib import Path
from typing import Dict, Any, Optional

from fastapi import FastAPI, UploadFile, File, HTTPException
from fastapi.responses import JSONResponse
from fastapi.middleware.cors import CORSMiddleware

# Import pipeline components
from utils import load_config, setup_logger, PipelineError
from preproc import Preprocessor
from diarize import Diarizer

ROOT = Path(__file__).resolve().parent.parent.parent  # transcribe-suite/../..
TRANSCRIBE_ROOT = ROOT / "transcribe-suite"
CONFIG_PATH = TRANSCRIBE_ROOT / "config" / "config.yaml"
LOGS_DIR = TRANSCRIBE_ROOT / "logs"
WORK_DIR = TRANSCRIBE_ROOT / "work"

# Ensure directories exist
LOGS_DIR.mkdir(parents=True, exist_ok=True)
WORK_DIR.mkdir(parents=True, exist_ok=True)

# Create app and logger
app = FastAPI(
    title="Transcribe Suite - Diarization API",
    description="Expose speaker diarization (Pyannote) from Transcribe Suite",
    version="1.0.0"
)

# Add CORS middleware to allow frontend requests
app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],  # En production, restrict à localhost/origin spécifique
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)

# Initialize logger
_logger = setup_logger(LOGS_DIR, "api_server", log_level="info")

# Load configuration
if not CONFIG_PATH.exists():
    _logger.error("Config file not found: %s", CONFIG_PATH)
    raise RuntimeError(f"Config not found: {CONFIG_PATH}")

_cfg = load_config(CONFIG_PATH)

# Initialize components
_preproc = Preprocessor(_cfg, _logger)
_diarizer = Diarizer(_cfg, _logger)


@app.get("/health")
async def health() -> Dict[str, Any]:
    """Health check endpoint."""
    return {
        "status": "ok",
        "service": "Transcribe Suite Diarization API",
    }


@app.post("/diarize")
async def diarize(audio: UploadFile = File(...)) -> JSONResponse:
    """
    Upload an audio file and run diarization (speaker identification).
    
    Returns:
    - segments: list of {"start", "end", "speaker"}
    - speakers: dict {speaker_id: {"duration": float, "segments": [...]}}
    - rttm: path to RTTM file
    """
    work_session = WORK_DIR / f"api_{uuid.uuid4().hex}"
    audio_16k_path = work_session / "audio_16k.wav"
    
    try:
        work_session.mkdir(parents=True, exist_ok=True)
        
        # Save uploaded file temporarily
        tmp_file = work_session / audio.filename
        _logger.info(f"Saving uploaded file: {audio.filename}")
        with tmp_file.open("wb") as fh:
            content = await audio.read()
            fh.write(content)
        
        # Preprocess to 16kHz mono
        _logger.info(f"Preprocessing audio to 16kHz mono...")
        audio_16k_path = _preproc.run(tmp_file, work_session, force=False)
        _logger.info(f"Preprocessed audio: {audio_16k_path}")
        
        # Run diarization
        _logger.info(f"Running diarization...")
        diar_result = _diarizer.run(audio_16k_path, work_session)
        segments = diar_result.get("segments", [])
        rttm_path = diar_result.get("rttm")
        
        # Build speakers summary
        speakers: Dict[str, Any] = {}
        for seg in segments:
            spk = seg.get("speaker") or "unknown"
            start = float(seg.get("start", 0.0))
            end = float(seg.get("end", 0.0))
            duration = round(end - start, 3)
            
            if spk not in speakers:
                speakers[spk] = {"duration": 0.0, "segment_count": 0}
            
            speakers[spk]["duration"] = round(speakers[spk]["duration"] + duration, 3)
            speakers[spk]["segment_count"] += 1
        
        _logger.info(f"Diarization complete: {len(segments)} segments, {len(speakers)} speakers")
        
        return JSONResponse(content={
            "success": True,
            "segments": segments,
            "speakers": speakers,
            "rttm": str(rttm_path) if rttm_path else None,
            "session_id": work_session.name,
        })
    
    except Exception as exc:
        _logger.exception(f"Error processing file: {exc}")
        raise HTTPException(status_code=500, detail=str(exc))


@app.post("/diarize-batch")
async def diarize_batch(audio: UploadFile = File(...), max_speakers: Optional[int] = None) -> JSONResponse:
    """
    Diarize with optional override of max_speakers (for multi-speaker scenarios).
    """
    # Temporarily override config if max_speakers provided
    orig_max_speakers = _diarizer.cfg.get("max_speakers")
    try:
        if max_speakers is not None:
            _diarizer.cfg["max_speakers"] = max_speakers
            _logger.info(f"Override max_speakers to {max_speakers}")
        
        # Call the main diarize endpoint
        return await diarize(audio)
    finally:
        # Restore original config
        if max_speakers is not None and orig_max_speakers is not None:
            _diarizer.cfg["max_speakers"] = orig_max_speakers


@app.get("/config")
async def get_config() -> Dict[str, Any]:
    """Return current diarization configuration."""
    return {
        "diarization": _diarizer.cfg,
        "preproc": {
            "target_sr": _preproc.cfg.get("target_sr", 16000),
            "channels": _preproc.cfg.get("channels", 1),
        }
    }


if __name__ == "__main__":
    import uvicorn
    uvicorn.run(
        app,
        host="0.0.0.0",
        port=5002,
        log_level="info"
    )
