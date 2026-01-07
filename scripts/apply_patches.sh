#!/bin/bash
# Apply patches to feedstocks for ppc64le CUDA 12.2 builds
# Run this after feedstocks have been cloned

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO_DIR="$(dirname "$SCRIPT_DIR")"
PATCHES_DIR="$REPO_DIR/patches"

echo "Applying patches from $PATCHES_DIR"

# PyTorch CUDA_HOME detection
if [[ -d "$REPO_DIR/pytorch-feedstock" ]]; then
    echo "Applying pytorch-cuda-home.patch..."
    cd "$REPO_DIR/pytorch-feedstock"
    if git apply --check "$PATCHES_DIR/pytorch-cuda-home.patch" 2>/dev/null; then
        git apply "$PATCHES_DIR/pytorch-cuda-home.patch"
        echo "  Applied successfully"
    else
        echo "  Patch already applied or not applicable"
    fi
fi

# Sentencepiece setuptools fix
if [[ -d "$REPO_DIR/sentencepiece-feedstock" ]]; then
    echo "Applying sentencepiece-setuptools.patch..."
    cd "$REPO_DIR/sentencepiece-feedstock"
    if git apply --check "$PATCHES_DIR/sentencepiece-setuptools.patch" 2>/dev/null; then
        git apply "$PATCHES_DIR/sentencepiece-setuptools.patch"
        echo "  Applied successfully"
    else
        echo "  Patch already applied or not applicable"
    fi
fi

echo "Done applying patches"
