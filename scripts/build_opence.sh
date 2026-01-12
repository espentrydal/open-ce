#!/bin/bash
# Open-CE Production Build Script
# Builds the full ADNI training environment

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
ENV_FILE="envs/adni-training-env.yaml"
LOG_FILE="$SCRIPT_DIR/build_$(date +%Y%m%d_%H%M%S).log"

# ============================================
# Parse Arguments
# ============================================
usage() {
    echo "Usage: $0 [OPTIONS]"
    echo ""
    echo "Options:"
    echo "  -e, --env FILE     Environment file to build (default: $ENV_FILE)"
    echo "  -j, --jobs N       Number of parallel jobs (default: auto)"
    echo "  -n, --dry-run      Skip package builds, only resolve dependencies"
    echo "  -h, --help         Show this help message"
    exit 1
}

SKIP_BUILD=""
while [[ $# -gt 0 ]]; do
    case $1 in
        -e|--env)
            ENV_FILE="$2"
            shift 2
            ;;
        -j|--jobs)
            export CPU_COUNT="$2"
            export MAX_JOBS="$2"
            shift 2
            ;;
        -n|--dry-run)
            SKIP_BUILD="--skip_build_packages"
            shift
            ;;
        -h|--help)
            usage
            ;;
        *)
            echo "Unknown option: $1"
            usage
            ;;
    esac
done

# ============================================
# Load Common Setup
# ============================================
if [[ ! -f "$SCRIPT_DIR/common_setup.sh" ]]; then
    echo "ERROR: common_setup.sh not found in $SCRIPT_DIR"
    exit 1
fi

source "$SCRIPT_DIR/common_setup.sh"

# ============================================
# Validate Environment File
# ============================================
if [[ ! -f "$ENV_FILE" ]]; then
    echo "ERROR: Environment file not found: $ENV_FILE"
    echo "Available environment files:"
    ls -1 envs/*.yaml 2>/dev/null | head -10
    exit 1
fi

# ============================================
# Build
# ============================================
echo ""
echo "Building: $ENV_FILE"
echo "Log file: $LOG_FILE"
echo ""

BUILD_CMD="open-ce build env \
    --build_types cuda \
    --cuda_versions 12.2 \
    $OPENCE_ARCH_FLAGS \
    $SKIP_BUILD \
    $ENV_FILE"

echo "Command: $BUILD_CMD"
echo ""

if [[ -n "$SKIP_BUILD" ]]; then
    echo "[SKIP BUILD MODE (dependencies only)]"
fi

# Run build with logging
START_TIME=$(date +%s)

$BUILD_CMD 2>&1 | tee "$LOG_FILE"
BUILD_STATUS=${PIPESTATUS[0]}

END_TIME=$(date +%s)
DURATION=$((END_TIME - START_TIME))

echo ""
echo "========================================"
if [[ $BUILD_STATUS -eq 0 ]]; then
    echo "BUILD SUCCESSFUL"
else
    echo "BUILD FAILED (exit code: $BUILD_STATUS)"
fi
echo "Duration: $((DURATION / 3600))h $((DURATION % 3600 / 60))m $((DURATION % 60))s"
echo "Log: $LOG_FILE"
echo "========================================"

exit $BUILD_STATUS
