# Building Open-CE for ppc64le with CUDA 12.2

This guide documents building Open-CE packages for IBM POWER9 (ppc64le) architecture with CUDA 12.2 support.

## Prerequisites

- POWER9 system with CUDA 12.2 installed
- Miniforge/Mambaforge for ppc64le
- Git

### CUDA Setup

Ensure CUDA 12.2 is installed at `/usr/local/cuda-12.2`:

```bash
nvcc --version  # Should show CUDA 12.2
```

## Quick Start

```bash
# Clone the fork
git clone https://github.com/espentrydal/open-ce.git
cd open-ce
git checkout ppc64le-cuda12.2-fixes

# Create and activate the builder environment
conda create -n open-ce-builder-env python=3.10
conda activate open-ce-builder-env
pip install open-ce

# Source environment and apply patches
source scripts/common_setup.sh
./scripts/apply_patches.sh

# Run the build
./scripts/build.sh
```

## Directory Structure

```
open-ce/
├── envs/
│   ├── adni-core-env.yaml      # Main build environment (PyTorch focus)
│   ├── adni-minimal-env.yaml   # Minimal PyTorch build
│   └── ...
├── patches/
│   ├── pytorch-cuda-home.patch       # CUDA_HOME detection fix
│   └── sentencepiece-setuptools.patch # Modern setuptools fix
├── scripts/
│   ├── common_setup.sh         # Environment setup
│   ├── build.sh                # Main build script
│   └── apply_patches.sh        # Apply feedstock patches
└── docs/
    └── ppc64le-cuda12.2-build.md  # This file
```

## Build Scripts

### common_setup.sh

Sets up the build environment with proper CUDA paths:

```bash
export CUDA_VERSION="12.2"
export CUDA_HOME="/usr/local/cuda-${CUDA_VERSION}"
export PATH="$CUDA_HOME/bin:$PATH"
export LD_LIBRARY_PATH="$CUDA_HOME/lib64:${LD_LIBRARY_PATH:-}"
```

### Applying Patches

Before building, apply the patches to the feedstocks:

```bash
# After feedstocks are cloned by open-ce
cd pytorch-feedstock
git apply ../patches/pytorch-cuda-home.patch

cd ../sentencepiece-feedstock
git apply ../patches/sentencepiece-setuptools.patch
```

Or use the provided script:

```bash
./scripts/apply_patches.sh
```

## Patches Explained

### pytorch-cuda-home.patch

**Problem**: conda-build runs in an isolated environment and doesn't pass through `CUDA_HOME`, causing PyTorch to build with `cuda = None`.

**Solution**: Auto-detect CUDA_HOME in the build script by searching common CUDA installation paths.

### sentencepiece-setuptools.patch

**Problem**: Modern setuptools (80+) deprecated `setup.py install` and doesn't create egg directories, breaking the hardcoded patchelf path.

**Solution**: Use pip install and dynamically find the .so file for patchelf.

## Building Specific Environments

### Core PyTorch Stack

```bash
open-ce build env \
  --python_versions 3.11 \
  --build_types cuda \
  --cuda_versions 12.2 \
  envs/adni-core-env.yaml
```

This builds:
- pytorch-base (with CUDA 12.2)
- torchvision
- torchtext
- torchdata
- sentencepiece
- cryptography, tokenizers, safetensors

### Minimal Build (PyTorch only)

```bash
open-ce build env \
  --python_versions 3.11 \
  --build_types cuda \
  --cuda_versions 12.2 \
  envs/adni-minimal-env.yaml
```

## Using Built Packages

### Index the channel

```bash
conda index condabuild/
```

### Create environment from built packages

```bash
conda create -n myenv \
  -c file:///path/to/open-ce/condabuild \
  -c anaconda \
  pytorch torchvision
```

### Add as permanent channel

```bash
conda config --add channels file:///path/to/open-ce/condabuild
```

## Troubleshooting

### PyTorch shows cuda = None

Verify the patch was applied:
```bash
grep -A5 "Detect CUDA_HOME" pytorch-feedstock/pytorch-*/recipe/build.sh
```

### sentencepiece build fails with patchelf error

Verify the patch was applied:
```bash
grep "pip install" sentencepiece-feedstock/recipe/build.sh
```

### Build uses wrong CUDA version

Check environment:
```bash
echo $CUDA_HOME
nvcc --version
```

## Package Versions (Open-CE 1.11.7)

| Package | Version | CUDA |
|---------|---------|------|
| pytorch-base | 2.1.2 | 12.2 |
| torchvision-base | 0.16.2 | 12.2 |
| torchtext-base | 0.16.2 | 12.2 |
| sentencepiece | 0.1.99 | - |
| tokenizers | 0.15.2 | - |
| safetensors | 0.4.1 | - |

## References

- [Open-CE GitHub](https://github.com/open-ce/open-ce)
- [Open-CE Documentation](https://open-ce.github.io/)
- Tag used: `open-ce-v1.11.7` (consider `open-ce-v1.11.7-p9` for Power9-specific fixes)
