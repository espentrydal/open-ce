#!/bin/bash
set -e
mkdir -p ~/open-ce-build
cd ~/open-ce-build
echo "Setting up in $(pwd)"

if [ ! -d "open-ce" ]; then
    git clone -b open-ce-v1.11.7 https://github.com/open-ce/open-ce.git
else
    echo "open-ce already cloned"
fi

if [ ! -d "open-ce-builder" ]; then
    git clone https://github.com/open-ce/open-ce-builder.git
else
    echo "open-ce-builder already cloned"
fi

source ~/miniforge3/etc/profile.d/conda.sh
if ! conda env list | grep -q open-ce-builder-env; then
    echo "Creating conda env..."
    conda create -y -n open-ce-builder-env python=3.10
else
    echo "Conda env open-ce-builder-env already exists"
fi

conda activate open-ce-builder-env
echo "Installing dependencies..."
conda install -y conda-build networkx junit-xml

echo "Installing open-ce-builder..."
pip install ./open-ce-builder

echo "Setup complete!"
