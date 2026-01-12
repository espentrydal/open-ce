#!/bin/bash
# Cleanup script for open-ce repository
# Removes build artifacts, cloned feedstocks, and logs

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO_DIR="$(dirname "$SCRIPT_DIR")"

cd "$REPO_DIR"

echo "Cleaning up Open-CE repository at: $REPO_DIR"
echo ""

# Remove all build logs
echo "Removing build logs..."
find . -maxdepth 1 -name '*.log' -type f -delete 2>/dev/null || true
find . -maxdepth 1 -name 'build_*.log' -type f -delete 2>/dev/null || true
rm -f run_build.out 2>/dev/null || true

# Remove cloned feedstock directories
echo "Removing cloned feedstock directories..."
find . -maxdepth 1 -type d -name '*-feedstock' -exec rm -rf {} + 2>/dev/null || true

# Remove condabuild directory (build outputs)
echo "Removing condabuild directory..."
rm -rf condabuild 2>/dev/null || true

# Remove any other temporary files
echo "Removing other temporary files..."
find . -name '*.pyc' -delete 2>/dev/null || true
find . -name '__pycache__' -type d -exec rm -rf {} + 2>/dev/null || true
find . -name '.pytest_cache' -type d -exec rm -rf {} + 2>/dev/null || true

echo ""
echo "Cleanup complete!"
echo ""
echo "Summary:"
echo "- Removed all build logs"
echo "- Removed cloned feedstock directories"
echo "- Removed condabuild directory"
echo "- Removed Python cache files"
echo ""
echo "What remains:"
echo "- Git-tracked files (environment files, patches, scripts)"
echo "- Any custom local changes"
echo ""
echo "To build again, run:"
echo "  cd $REPO_DIR"
echo "  ./scripts/build_opence.sh"
