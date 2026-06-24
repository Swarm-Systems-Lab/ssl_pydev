#!/usr/bin/env bash
set -euo pipefail

# Generate Python type stubs for a pybind11 extension module using pybind11-stubgen.
# Rebuilds the package in editable mode first, then introspects the built module.
#
# Usage: generate_stubs.sh --module <dotted.module.path> [--output <dir>]
#
# Exits 1 if the regenerated stub differs from what's already on disk, so this
# can be used as a pre-commit hook / CI drift check, not just a one-off generator
# (mirrors how ruff-format reports "files were modified, review and re-stage").

MODULE=""
OUTPUT_DIR="src/"

usage() {
	echo "Usage: $0 --module <dotted.module.path> [--output <dir>]" >&2
	exit 1
}

while [[ $# -gt 0 ]]; do
	case "$1" in
		--module)
			[[ $# -ge 2 ]] || usage
			MODULE="$2"
			shift 2
			;;
		--output)
			[[ $# -ge 2 ]] || usage
			OUTPUT_DIR="$2"
			shift 2
			;;
		*)
			usage
			;;
	esac
done

[[ -n "$MODULE" ]] || usage

STUB_PATH="${OUTPUT_DIR%/}/$(echo "$MODULE" | tr '.' '/').pyi"

BEFORE_HASH=""
if [ -f "$STUB_PATH" ]; then
	BEFORE_HASH="$(sha256sum "$STUB_PATH")"
fi

echo "Installing dependencies and building package..."
uv sync --all-extras --frozen
uv pip install -e .

echo "Generating stubs for $MODULE..."
uv run pybind11-stubgen "$MODULE" -o "$OUTPUT_DIR"

echo "Stubs generated successfully at $STUB_PATH"

AFTER_HASH="$(sha256sum "$STUB_PATH")"
if [ "$BEFORE_HASH" != "$AFTER_HASH" ]; then
	echo "error: $STUB_PATH was out of date and has been regenerated." >&2
	echo "Review the changes and stage/commit the updated stub." >&2
	exit 1
fi
