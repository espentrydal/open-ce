#!/bin/bash
# Common setup for Open-CE build scripts
# Source this file: source common_setup.sh

set -e

# ============================================
# Configuration - Modify these as needed
# ============================================
PROXY_URL="http://proxy.ihelse.net:3128"
CUDA_VERSION="12.2"
CONDA_BASE="$HOME/miniforge3"
OPENCE_DIR="$HOME/open-ce-build/open-ce"

# ============================================
# Proxy Configuration
# ============================================
export http_proxy="$PROXY_URL"
export https_proxy="$PROXY_URL"
export HTTP_PROXY="$PROXY_URL"
export HTTPS_PROXY="$PROXY_URL"

# ============================================
# CUDA Configuration
# ============================================
export CUDA_HOME="/usr/local/cuda-${CUDA_VERSION}"

if [[ ! -d "$CUDA_HOME" ]]; then
    echo "ERROR: CUDA_HOME=$CUDA_HOME does not exist"
    echo "Available CUDA installations:"
    ls -d /usr/local/cuda* 2>/dev/null || echo "  None found in /usr/local/"
    exit 1
fi

# Add CUDA to PATH so nvcc is findable in conda-build isolated envs
export PATH="$CUDA_HOME/bin:$PATH"
export LD_LIBRARY_PATH="$CUDA_HOME/lib64:${LD_LIBRARY_PATH:-}"

# ============================================
# CPU Configuration
# ============================================
# Use 75% of available cores, minimum 4
TOTAL_CORES=$(nproc)
RECOMMENDED_CORES=$(( TOTAL_CORES * 3 / 4 ))
[[ $RECOMMENDED_CORES -lt 4 ]] && RECOMMENDED_CORES=4

export CPU_COUNT="${CPU_COUNT:-$RECOMMENDED_CORES}"
export MAX_JOBS="${MAX_JOBS:-$RECOMMENDED_CORES}"

# ============================================
# Conda Setup
# ============================================
if [[ ! -f "$CONDA_BASE/etc/profile.d/conda.sh" ]]; then
    echo "ERROR: Conda not found at $CONDA_BASE"
    exit 1
fi

source "$CONDA_BASE/etc/profile.d/conda.sh"

if ! conda activate open-ce-builder-env 2>/dev/null; then
    echo "ERROR: Could not activate open-ce-builder-env"
    echo "Create it with: conda create -n open-ce-builder-env python=3.10"
    exit 1
fi

# Configure conda (idempotent)
conda config --set solver libmamba 2>/dev/null || true
conda config --set channel_priority flexible 2>/dev/null || true
conda config --set proxy_servers.http "$PROXY_URL" 2>/dev/null || true
conda config --set proxy_servers.https "$PROXY_URL" 2>/dev/null || true

# Ensure channels are set correctly (remove defaults, add required)
# Only modify if not already configured
if conda config --show channels | grep -q "defaults"; then
    conda config --remove channels defaults 2>/dev/null || true
fi

# Add channels if not present (prepend to avoid duplicates)
for channel in anaconda conda-forge; do
    if ! conda config --show channels | grep -q "^  - $channel\$"; then
        conda config --prepend channels "$channel" 2>/dev/null || true
    fi
done

# ============================================
# Working Directory
# ============================================
if [[ ! -d "$OPENCE_DIR" ]]; then
    echo "ERROR: Open-CE directory not found: $OPENCE_DIR"
    exit 1
fi

cd "$OPENCE_DIR"

# ============================================
# Architecture Detection
# ============================================
ARCH=$(uname -m)
case "$ARCH" in
    x86_64)
        OPENCE_ARCH_FLAGS=""
        ;;
    ppc64le)
        OPENCE_ARCH_FLAGS="--ppc_arch p9"
        ;;
    aarch64)
        OPENCE_ARCH_FLAGS=""
        ;;
    *)
        echo "WARNING: Unknown architecture: $ARCH"
        OPENCE_ARCH_FLAGS=""
        ;;
esac

export OPENCE_ARCH_FLAGS

# ============================================
# Summary
# ============================================
echo "========================================"
echo "Open-CE Build Environment"
echo "========================================"
echo "Architecture:  $ARCH"
echo "CUDA Version:  $CUDA_VERSION"
echo "CUDA Home:     $CUDA_HOME"
echo "CUDA in PATH:  $(which nvcc 2>/dev/null || echo 'not found')"
echo "CPU Count:     $CPU_COUNT"
echo "Max Jobs:      $MAX_JOBS"
echo "Working Dir:   $OPENCE_DIR"
echo "Arch Flags:    ${OPENCE_ARCH_FLAGS:-none}"
echo "========================================"
