#!/usr/bin/env bash
set -euo pipefail

# Test GitHub Actions workflows locally using act (https://github.com/nektos/act).
#
# Usage:
#   act.sh                          # interactively pick a workflow from .github/workflows
#   act.sh <workflow-file> [args]   # run a specific workflow directly, extra args passed to act
#
# Note: workflows that call Swarm-Systems-Lab/ssl_ci's reusable workflows/actions
# (uses: Swarm-Systems-Lab/ssl_ci/...@v1) need a GitHub token if ssl_ci is private -
# act fetches those itself via git and doesn't go through GitHub's own Actions
# backend, so it isn't subject to the org's Actions "Access" policy at all. Pass
# one with `-s GITHUB_TOKEN=<token>` (appended to extra args) if you hit fetch
# errors for a private ssl_ci.

if ! command -v act >/dev/null 2>&1; then
	echo "Installing act..."
	curl -s https://raw.githubusercontent.com/nektos/act/master/install.sh | bash -s -- -b "$HOME/.local/bin"
	export PATH="$HOME/.local/bin:$PATH"
fi

WORKFLOW_DIR=".github/workflows"
if [ ! -d "$WORKFLOW_DIR" ]; then
	echo "error: no workflows directory found at $WORKFLOW_DIR" >&2
	exit 1
fi

workflows=("$WORKFLOW_DIR"/*.yml)
if [ ${#workflows[@]} -eq 0 ]; then
	echo "error: no workflow files found in $WORKFLOW_DIR" >&2
	exit 1
fi

if [ $# -gt 0 ]; then
	WORKFLOW="$1"
	shift
	echo "Running workflow: $WORKFLOW"
	# --rm: act only removes containers on success by default, leaving them
	# behind on failure (or if the run is interrupted) for debugging. We'd
	# rather always clean up than accumulate dead containers.
	exec act -W "$WORKFLOW" --container-architecture linux/amd64 --rm "$@"
fi

echo "Available workflows:"
select workflow in "${workflows[@]}" "Quit"; do
	case $workflow in
		"Quit")
			echo "Exiting."
			exit 0
			;;
		*)
			if [ -n "$workflow" ]; then
				echo "Running workflow: $workflow"
				act -W "$workflow" --container-architecture linux/amd64 --rm
				break
			else
				echo "Invalid selection. Please try again."
			fi
			;;
	esac
done
