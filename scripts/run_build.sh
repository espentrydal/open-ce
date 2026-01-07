#!/bin/bash
cd ~/open-ce-build
source ~/miniforge3/bin/activate open-ce-builder-env
source common_setup.sh
cd ~/open-ce-build/open-ce  # Ensure we're in the right directory
LOG=build_$(date +%Y%m%d_%H%M%S).log
echo "Starting build, log: $LOG"
# Use the correct relative path from open-ce directory
open-ce build env --python_versions 3.11 --build_types cuda --cuda_versions 12.2 envs/adni-core-env.yaml 2>&1 | tee $LOG
echo "Build finished with exit code $?"
