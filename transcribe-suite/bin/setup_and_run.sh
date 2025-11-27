#!/usr/bin/env bash
################################################################################
# Transcribe Suite - One-click setup and launch script
# 
# Usage: ./bin/setup_and_run.sh
# 
# Options:
#   --skip-models    Skip model pre-download
#   --port PORT      API server port (default: 5002)
#   --dev            Skip npm install (faster for dev)
################################################################################

set -e  # Exit on error

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
CYAN='\033[0;36m'
NC='\033[0m'  # No Color

# Logging functions
log_info() {
    echo -e "${CYAN}ℹ️  $1${NC}"
}

log_success() {
    echo -e "${GREEN}✅ $1${NC}"
}

log_warning() {
    echo -e "${YELLOW}⚠️  $1${NC}"
}

log_error() {
    echo -e "${RED}❌ $1${NC}"
}

# Parse arguments
SKIP_MODELS=false
PORT=5002
DEV_MODE=false

while [[ $# -gt 0 ]]; do
    case $1 in
        --skip-models) SKIP_MODELS=true; shift ;;
        --port) PORT="$2"; shift 2 ;;
        --dev) DEV_MODE=true; shift ;;
        *) echo "Unknown option: $1"; exit 1 ;;
    esac
done

# Check requirements
check_requirements() {
    log_info "Checking requirements..."
    
    if ! command -v python3 &> /dev/null; then
        log_error "Python 3 not found. Please install Python 3.9+"
        exit 1
    fi
    log_success "Found Python 3"
    
    if ! command -v node &> /dev/null; then
        log_warning "Node.js not found. Frontend will not run."
    else
        log_success "Found Node.js"
    fi
    
    if ! command -v git &> /dev/null; then
        log_warning "Git not found (optional)"
    else
        log_success "Found Git"
    fi
}

# Setup virtual environment
setup_venv() {
    if [ -d ".venv" ]; then
        log_info "Virtual environment already exists"
    else
        log_info "Creating virtual environment..."
        python3 -m venv .venv
        log_success "Virtual environment created"
    fi
}

# Activate venv
activate_venv() {
    log_info "Activating virtual environment..."
    source .venv/bin/activate
}

# Install dependencies
install_dependencies() {
    log_info "Installing Python dependencies..."
    
    log_info "Upgrading pip..."
    pip install --upgrade pip --quiet
    
    log_info "Installing requirements.txt..."
    pip install -r requirements.txt --quiet
    
    log_info "Installing FastAPI and Uvicorn..."
    pip install fastapi 'uvicorn[standard]' --quiet
    
    log_success "All dependencies installed"
}

# Check token
check_token() {
    if [ -z "$PYANNOTE_TOKEN" ]; then
        log_warning "PYANNOTE_TOKEN environment variable not set"
        log_warning "Diarization will fail without it"
        echo ""
        log_info "Set it with:"
        echo "  export PYANNOTE_TOKEN='hf_xxx...'"
        echo ""
        read -p "Continue anyway? (y/n) " -n 1 -r
        echo
        if [[ ! $REPLY =~ ^[Yy]$ ]]; then
            exit 0
        fi
    else
        log_success "PYANNOTE_TOKEN is set ✓"
    fi
}

# Pre-warm models
prewarm_models() {
    if [ "$SKIP_MODELS" = true ]; then
        log_info "Skipping model pre-download (--skip-models)"
        return
    fi
    
    log_info "Pre-warming models (this may take a few minutes on first run)..."
    
    if [ ! -f "bin/prewarm_models.py" ]; then
        log_warning "prewarm_models.py not found"
        return
    fi
    
    python bin/prewarm_models.py || log_warning "Model pre-warm failed (but API may still work)"
    log_success "Models ready for offline use"
}

# Show startup info
show_startup_info() {
    echo ""
    log_info "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
    log_success "🎙️  Transcribe Suite - Ready to go!"
    log_info "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
    echo ""
    
    log_info "API Server:"
    echo -e "  ${CYAN}🌐 http://localhost:$PORT${NC}"
    echo -e "  ${CYAN}📡 /health - health check${NC}"
    echo -e "  ${CYAN}📝 /diarize - upload and diarize audio${NC}"
    echo -e "  ${CYAN}⚙️  /config - view diarization config${NC}"
    echo ""
    
    log_info "Frontend:"
    echo -e "  ${CYAN}🌐 http://localhost:5173${NC}"
    echo ""
    
    log_info "Models:"
    echo -e "  ${CYAN}🎤 Whisper: medium (~1.5 GB)${NC}"
    echo -e "  ${CYAN}👥 Pyannote: speaker-diarization-3.1 (~500 MB)${NC}"
    echo -e "  ${CYAN}📍 WhisperX: alignment (~350 MB)${NC}"
    echo ""
    
    log_warning "Press Ctrl+C to stop the server"
    log_info "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
    echo ""
}

# Start API server
start_api_server() {
    log_info "Starting API server on port $PORT..."
    echo ""
    python -m uvicorn src.api:app --host 0.0.0.0 --port $PORT --reload
}

# ==================== Main ====================

echo ""
log_info "╔════════════════════════════════════════════════════════╗"
log_info "║  Transcribe Suite - One-Click Setup & Launch           ║"
log_info "╚════════════════════════════════════════════════════════╝"
echo ""

# Navigate to transcribe-suite if needed
SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
SUITE_DIR="$(dirname "$SCRIPT_DIR")"

if [ ! -f "$SUITE_DIR/src/api.py" ]; then
    log_error "Cannot find src/api.py in $SUITE_DIR"
    log_info "Please run this script from the transcribe-suite directory"
    log_info "Usage: cd transcribe-suite && bash bin/setup_and_run.sh"
    exit 1
fi

cd "$SUITE_DIR"

# Run setup steps
check_requirements
setup_venv
activate_venv
install_dependencies
check_token
prewarm_models
show_startup_info

# Launch API server
start_api_server
