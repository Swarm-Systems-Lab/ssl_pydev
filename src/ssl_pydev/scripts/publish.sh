#!/usr/bin/env bash
set -euo pipefail

# Local publish using uv's built-in publishing support.
# SCRIPT_DIR: where this script is located (for finding setup-env.sh)
SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
ROOT_DIR="$(pwd)"

if [ ! -d "$ROOT_DIR/.venv" ]; then
	"$SCRIPT_DIR/setup-env.sh" --extras dev,release
fi

. .venv/bin/activate

if [ -z "${UV_PUBLISH_USERNAME-}" ] || [ -z "${UV_PUBLISH_PASSWORD-}" ] || [ -z "${UV_PUBLISH_REPOSITORY_URL-}" ]; then
	echo "Missing publishing credentials (UV_PUBLISH_USERNAME / UV_PUBLISH_PASSWORD / UV_PUBLISH_REPOSITORY_URL)" >&2
	exit 1
fi

if [ ! -d dist ] || [ -z "$(ls -A dist 2>/dev/null)" ]; then
	echo "No artifacts found in dist/ - nothing to publish" >&2
	exit 1
fi

echo "Publishing artifacts from dist/ using uv"
uv publish --repository-url "$UV_PUBLISH_REPOSITORY_URL" --username "$UV_PUBLISH_USERNAME" --password "$UV_PUBLISH_PASSWORD" dist/*

echo "Publish finished"
