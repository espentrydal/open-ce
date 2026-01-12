#!/bin/bash
# Open-CE Test Build Script
# Quick validation build with minimal resources

set -ex

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
ENV_FILE="envs/test-minimal.yaml"
LOG_FILE="$SCRIPT_DIR/test_build_$(date +%Y%m%d_%H%M%S).log"

# ============================================
# Test Configuration (Override defaults)
# ============================================
# Use fewer resources for testing
export CPU_COUNT="${CPU_COUNT:-8}"
export MAX_JOBS="${MAX_JOBS:-8}"
export CONDA_VERBOSITY="${CONDA_VERBOSITY:-2}"

# ============================================
# Parse Arguments
# ============================================
usage() {
    echo "Usage: $0 [OPTIONS]"
    echo ""
    echo "Options:"
    echo "  -e, --env FILE     Environment file to test (default: $ENV_FILE)"
    echo "  -j, --jobs N       Number of parallel jobs (default: $CPU_COUNT)"
    echo "  -v, --verbose      Extra verbose output"
    echo "  -h, --help         Show this help message"
    exit 1
}

VERBOSE=""
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
        -v|--verbose)
            VERBOSE="1"
            export CONDA_VERBOSITY=3
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
    echo ""
    echo "Available test environments:"
    ls -1 envs/test*.yaml envs/*minimal*.yaml 2>/dev/null || echo "  None found"
    echo ""
    echo "All environments:"
    ls -1 envs/*.yaml 2>/dev/null | head -10
    exit 1
fi

# ============================================
# Test Build
# ============================================
echo ""
echo "=== TEST BUILD ==="
echo "Environment: $ENV_FILE"
echo "Log file:    $LOG_FILE"
echo "Start time:  $(date)"
echo ""

BUILD_CMD="open-ce build env \
    --build_types cuda \
    --cuda_versions 12.2 \
    $OPENCE_ARCH_FLAGS \
    $ENV_FILE"

echo "Command: $BUILD_CMD"
echo ""

START_TIME=$(date +%s)

$BUILD_CMD 2>&1 | tee "$LOG_FILE"
BUILD_STATUS=${PIPESTATUS[0]}

END_TIME=$(date +%s)
DURATION=$((END_TIME - START_TIME))

echo ""
echo "========================================"
echo "=== TEST BUILD COMPLETE ==="
if [[ $BUILD_STATUS -eq 0 ]]; then
    echo "Status:   SUCCESS"
else
    echo "Status:   FAILED (exit code: $BUILD_STATUS)"
fi
echo "Duration: $((DURATION / 60))m $((DURATION % 60))s"
echo "End time: $(date)"
echo "Log:      $LOG_FILE"
echo "========================================"

# Quick summary of what was built
if [[ $BUILD_STATUS -eq 0 ]]; then
    echo ""
    echo "Built packages:"
    ls -1 condabuild/*.tar.bz2 2>/dev/null | wc -l | xargs -I{} echo "  {} packages in condabuild/"
fi

exit $BUILD_STATUS
