"""ssl_pydev CLI - shared local-dev commands for Swarm Systems Lab Python projects.

These wrap the same scripts ssl_ci's composite actions use in CI, packaged here so
they can be installed once per machine (``uv tool install ssl-pydev``) instead
of being copy-pasted into every project's scripts/ directory.
"""

import argparse
import subprocess
import sys
from importlib import resources

SCRIPTS_MAP = {
    "setup-env": "setup-env.sh",
    "build": "build.sh",
    "build-native": "build_native.sh",
    "publish": "publish.sh",
    "publish-ci": "publish_ci.sh",
    "validate-docs": "validate_docs.sh",
}

EPILOG = """
Examples:
  ssl-pydev setup-env --extras dev,tests
  ssl-pydev build
  ssl-pydev build-native
  ssl-pydev publish-ci
  ssl-pydev validate-docs

All commands accept additional arguments which are passed through to the
underlying script. Commands run against the current working directory, so
invoke this from the root of the project you want to act on.
"""


def _get_script(command: str) -> str:
    """Return the path to a bundled script by command name."""
    if command not in SCRIPTS_MAP:
        raise ValueError(f"Unknown command: {command}")

    script_ref = resources.files("ssl_pydev.scripts").joinpath(SCRIPTS_MAP[command])
    if not script_ref.is_file():
        raise FileNotFoundError(f"Bundled script not found: {script_ref}")
    return str(script_ref)


def _run_script(command: str, args: list) -> int:
    """Execute a bundled script with the given arguments."""
    try:
        script_path = _get_script(command)
    except (FileNotFoundError, ValueError) as e:
        print(f"Error: {e}", file=sys.stderr)
        return 1

    result = subprocess.run(["bash", script_path, *args], check=False)
    return result.returncode


def main() -> int:
    """Main CLI entry point."""
    if len(sys.argv) < 2 or sys.argv[1] in ["-h", "--help", "help"]:
        parser = argparse.ArgumentParser(
            prog="ssl-pydev",
            description="Swarm Systems Lab shared local-dev CLI",
            formatter_class=argparse.RawDescriptionHelpFormatter,
            epilog=EPILOG,
        )
        subparsers = parser.add_subparsers(dest="command", help="Available commands")
        for cmd in sorted(SCRIPTS_MAP.keys()):
            subparsers.add_parser(cmd, help=f"Run {cmd}")
        parser.print_help()
        return 0

    command = sys.argv[1]
    script_args = sys.argv[2:]

    if command not in SCRIPTS_MAP:
        print(f"Error: Unknown command '{command}'", file=sys.stderr)
        print(f"Available commands: {', '.join(sorted(SCRIPTS_MAP.keys()))}", file=sys.stderr)
        return 1

    return _run_script(command, script_args)


if __name__ == "__main__":
    sys.exit(main())
