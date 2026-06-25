#!/usr/bin/env bash
set -euo pipefail

# Scaffold a new project from the ssl_py_template copier template.
#
# Usage: new.sh <destination> [extra copier args...]
#
# Runs copier via `uvx` (ephemeral, no persistent install to manage) so this
# has no extra prerequisite beyond uv itself, which ssl-pydev already requires.

if [ $# -lt 1 ]; then
	echo "Usage: $0 <destination> [extra copier args...]" >&2
	exit 1
fi

DESTINATION="$1"
shift

uvx copier copy gh:Swarm-Systems-Lab/ssl_py_template "$DESTINATION" "$@"
