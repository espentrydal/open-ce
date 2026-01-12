# Open-CE Build Scripts

This directory contains scripts for building and managing Open-CE packages on ppc64le (POWER9) with CUDA 12.2 support.

## Main Build Scripts

### build_opence.sh
Production build script for the full ADNI training environment.

**Usage:**
```bash
./scripts/build_opence.sh [OPTIONS]

Options:
  -e, --env FILE     Environment file to build
  -j, --jobs N       Number of parallel jobs
  -n, --dry-run      Skip package builds, only resolve dependencies
  -h, --help         Show help message
```

### test_build.sh
Quick validation build with minimal resources for testing.

### test_minimal_env.sh
Simple test script for dry-run validation of minimal environment.

## Setup Scripts

### setup_opence.sh
Initial setup script for Open-CE build environment. Run this once on a new server.

### common_setup.sh
Common environment setup sourced by other scripts. Do not run directly.

## Utility Scripts

### cleanup.sh
Removes build artifacts, cloned feedstocks, and logs.

### apply_patches.sh
Applies patches from feedstock-patches/ directory to feedstocks.

## Output

Built packages are placed in:
- condabuild/linux-ppc64le/ - Architecture-specific packages  
- condabuild/noarch/ - Platform-independent packages

See individual scripts for detailed usage information.
