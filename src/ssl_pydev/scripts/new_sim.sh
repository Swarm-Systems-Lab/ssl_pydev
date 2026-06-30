#!/usr/bin/env bash
set -euo pipefail

# Scaffold a new ssl_simulator research project from ssl_py_template
# (project_kind=simulator: notebooks/, output/, controllers/robot_models/
# visualization scaffolding, package-only tooling like docs/Docker/publish
# defaulted off - see ssl_py_template's copier.yml for the full set of
# project_kind=simulator behavior).
#
# Usage: new_sim.sh <destination> [extra copier args...]
#
# Runs copier via `uvx` (ephemeral, no persistent install to manage) so this
# has no extra prerequisite beyond uv itself, which ssl-pydev already requires.

if [ $# -lt 1 ]; then
	echo "Usage: $0 <destination> [extra copier args...]" >&2
	exit 1
fi

DESTINATION="$1"
shift

uvx copier copy gh:Swarm-Systems-Lab/ssl_py_template "$DESTINATION" --data project_kind=simulator "$@"
