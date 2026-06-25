#!/usr/bin/env bash
set -euo pipefail
unset VIRTUAL_ENV

# Build sdist + wheel for a pure-Python project. Bootstraps the venv if needed.
SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
ROOT_DIR="$(pwd)"

if [ ! -d "$ROOT_DIR/.venv" ]; then
	"$SCRIPT_DIR/setup-env.sh" --extras dev,release
fi

. .venv/bin/activate

echo "Preparing build output directory"
rm -rf dist
mkdir -p dist

echo "Running tox build environment"
uv run tox -e build

echo "Build artifacts placed in dist/"
