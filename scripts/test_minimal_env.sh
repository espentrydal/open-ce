#\!/bin/bash
set -e
source ~/open-ce-build/common_setup.sh

echo "Testing minimal environment build..."
open-ce build env \
    --build_types cuda \
    --cuda_versions 12.2 \
    $OPENCE_ARCH_FLAGS \
    --skip_build_packages \
    envs/adni-minimal-env.yaml
