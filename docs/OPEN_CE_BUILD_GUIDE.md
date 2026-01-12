# Open-CE Build Guide (ppc64le / POWER9)

This guide documents the procedure for building and updating Open-CE packages on `ai-smil1`.

## 1. Prerequisites & Environment
- **Architecture:** `ppc64le` (POWER9)
- **Conda:** Use `miniforge3` or `miniconda`.
- **Builder Compatibility:** `open-ce-builder` (v13+) often requires `conda < 24.0.0`.
  - Current working version: `conda 23.11.0`.
- **Proxy Settings:** Required for external downloads.
  ```bash
  export http_proxy=http://proxy.ihelse.net:3128/
  export https_proxy=http://proxy.ihelse.net:3128/
  ```

## 2. Setup the Builder Environment
If setting up from scratch:
```bash
conda create -y -n open-ce-builder-env python=3.10
conda activate open-ce-builder-env
conda install -y "conda<24" conda-build networkx junit-xml
pip install ./open-ce-builder
```

## 3. Configuration Files
Open-CE uses YAML files in the `envs/` directory to define the package tree.

### Important: Feedstock Format Compatibility
Modern `conda-forge` feedstocks are migrating to a new `recipe.yaml` format. **Open-CE 1.11.7 requires the older `meta.yaml` format.**
- When adding new packages to `adni-extras.yaml`, you **must** pin the `git_tag` to a commit that still contains `recipe/meta.yaml`.
- Use `git ls-tree -r <commit_hash> | grep meta.yaml` to verify before building.

## 4. Resource Optimization
With 160 CPUs and 630GB RAM, always use parallel builds:
- Set `export CPU_COUNT=144` (90% utilization).
- Set `export MAX_JOBS=144`.

## 5. Execution Command
The standard build command for CUDA 12.2:
```bash
open-ce build env \
    --build_types cuda \
    --cuda_versions 12.2 \
    --channels "anaconda,conda-forge" \
    --ppc_arch p9 \
    envs/adni-training-env.yaml
```
- **Channels:** Use `anaconda` and `conda-forge`. Avoid `defaults` if `repo.anaconda.com` connection issues persist.
- **Output:** Packages are saved to `~/open-ce-build/open-ce/condabuild`.

## 6. Troubleshooting Common Errors
- **ModuleNotFoundError: 'conda.cli.python_api'**: Conda is too new. Downgrade to `23.11.0`.
- **OSError: No meta files found**: The feedstock has moved to `recipe.yaml`. Find an older commit hash for that feedstock and update your `envs/*.yaml` file.
- **Connection Reset by Peer**: Ensure the proxy exports are active in the current shell.

## 7. Adding a New Version of Open-CE
1. `cd ~/open-ce-build/open-ce`
2. `git fetch --tags`
3. `git checkout open-ce-vX.Y.Z`
4. Update `adni-training-env.yaml` to point to the new version tags.
