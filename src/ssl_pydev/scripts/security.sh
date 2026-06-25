#!/usr/bin/env bash
set -euo pipefail

# Run semgrep security scans against the calling project's cwd.
#
# Runs semgrep via `uvx` (ephemeral, cached across projects by uv - no
# per-project dependency to install) with the standard `p/ci` registry pack
# plus ssl_pydev's bundled generic rules (secret detection etc., shared by
# every SSL project). If the calling project has its own .semgrep.yml, it is
# layered on top additively for project-specific rules.
#
# Usage: security.sh [extra semgrep args...]

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

CONFIGS=(--config p/ci --config "$SCRIPT_DIR/semgrep-rules.yml")
if [ -f .semgrep.yml ]; then
	CONFIGS+=(--config .semgrep.yml)
fi

uvx semgrep "${CONFIGS[@]}" "$@"
