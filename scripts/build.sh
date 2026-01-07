#!/bin/bash
# Build Open-CE packages for ppc64le with CUDA 12.2
#
# Usage: ./build.sh [env_file]
#   env_file: Environment YAML to build (default: envs/adni-core-env.yaml)

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO_DIR="$(dirname "$SCRIPT_DIR")"

# Default environment file
ENV_FILE="${1:-envs/adni-core-env.yaml}"

# Source common setup if not already done
if [[ -z "$CUDA_HOME" ]]; then
    source "$SCRIPT_DIR/common_setup.sh"
fi

cd "$REPO_DIR"

# Create log file
LOG_FILE="build_$(date +%Y%m%d_%H%M%S).log"
echo "Build log: $LOG_FILE"

# Run the build
echo "Starting Open-CE build..."
echo "  Environment: $ENV_FILE"
echo "  Python: 3.11"
echo "  CUDA: 12.2"
echo "  Build type: cuda"

open-ce build env \
    --python_versions 3.11 \
    --build_types cuda \
    --cuda_versions 12.2 \
    "$ENV_FILE" 2>&1 | tee "$LOG_FILE"

BUILD_EXIT_CODE=${PIPESTATUS[0]}

echo ""
echo "Build finished with exit code $BUILD_EXIT_CODE"
echo "Log saved to: $LOG_FILE"

# Index the channel if build succeeded
if [[ $BUILD_EXIT_CODE -eq 0 ]]; then
    echo "Indexing conda channel..."
    conda index condabuild/
    echo ""
    echo "Packages available at: $REPO_DIR/condabuild"
    echo "Use with: conda install -c file://$REPO_DIR/condabuild <package>"
fi

exit $BUILD_EXIT_CODE
