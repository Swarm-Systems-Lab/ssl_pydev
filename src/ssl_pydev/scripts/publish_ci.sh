#!/usr/bin/env bash
set -euo pipefail
unset VIRTUAL_ENV

# CI-friendly publish using twine with credentials from the environment.
# SCRIPT_DIR: where this script is located (for finding setup-env.sh)
SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
ROOT_DIR="$(pwd)"

if [ ! -d "$ROOT_DIR/.venv" ]; then
	"$SCRIPT_DIR/setup-env.sh" --extras dev,release
fi

. .venv/bin/activate

if [ -z "${TWINE_USERNAME-}" ] || [ -z "${TWINE_PASSWORD-}" ] || [ -z "${TWINE_REPOSITORY_URL-}" ]; then
	echo "Missing publishing credentials (TWINE_USERNAME / TWINE_PASSWORD / TWINE_REPOSITORY_URL)" >&2
	exit 1
fi

if [ ! -d dist ] || [ -z "$(ls -A dist 2>/dev/null)" ]; then
	echo "No artifacts found in dist/ - nothing to publish" >&2
	exit 1
fi

echo "Publishing artifacts from dist/ using twine"
python -m twine upload --verbose --non-interactive --repository-url "$TWINE_REPOSITORY_URL" dist/*

echo "Publish finished"
