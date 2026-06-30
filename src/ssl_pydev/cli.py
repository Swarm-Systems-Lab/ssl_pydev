"""ssl_pydev CLI - shared local-dev commands for Swarm Systems Lab Python projects.

These wrap the same scripts ssl_ci's composite actions use in CI, packaged here so
they can be installed once per machine (``uv tool install ssl-pydev``) instead
of being copy-pasted into every project's scripts/ directory.
"""

import argparse
import importlib
import subprocess
import sys
from importlib import resources

SCRIPTS_MAP = {
    "new": "new.sh",
    "new-sim": "new_sim.sh",
    "act": "act.sh",
    "setup-env": "setup-env.sh",
    "build": "build.sh",
    "build-native": "build_native.sh",
    "publish": "publish.sh",
    "publish-ci": "publish_ci.sh",
    "validate-docs": "validate_docs.sh",
    "generate-stubs": "generate_stubs.sh",
    "security": "security.sh",
}

# Python-backed commands (need real logic - TOML/YAML parsing, etc. - rather
# than a bundled bash script). Value is "module:function".
PY_COMMANDS = {
    "prune": "ssl_pydev.prune:main",
}

EPILOG = """
Examples:

  Scaffolding:
    ssl-pydev new my-project                       Generate a new project from ssl_py_template
    ssl-pydev new-sim my-project                    Generate a new ssl_simulator research project
                                                    (ssl_py_template with project_kind=simulator)
    ssl-pydev prune                                 Find and interactively remove files orphaned by a template update

  Environment & CI:
    ssl-pydev setup-env --extras dev,tests         uv lock + sync (mirrors ssl_ci's env-setup action)
    ssl-pydev act                                  Run .github/workflows locally with act

  Build & publish:
    ssl-pydev build                                Build sdist + wheel (pure-Python project)
    ssl-pydev build-native                         Build sdist + cibuildwheel wheels (compiled extension)
    ssl-pydev publish                              Publish with uv (requires UV_PUBLISH_* env vars)
    ssl-pydev publish-ci                           Publish with twine (requires TWINE_* env vars)

  Quality:
    ssl-pydev security                             Run semgrep (p/ci pack + bundled rules + local .semgrep.yml)
    ssl-pydev generate-stubs --module pkg._core --output src/
                                                    Regenerate .pyi stubs for a native extension

  Docs:
    ssl-pydev validate-docs                        Sanity-check an already-built mkdocs site/ directory

Every command runs against the current working directory - invoke this from
the root of the project you want to act on. Extra arguments are passed
through unchanged to the underlying script, e.g. `ssl-pydev security --verbose`.
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


def _run_py_command(command: str, args: list) -> int:
    """Import and call a Python-backed command's entry point."""
    module_name, func_name = PY_COMMANDS[command].split(":")
    module = importlib.import_module(module_name)
    func = getattr(module, func_name)
    return func(args)


def main() -> int:
    """Main CLI entry point."""
    all_commands = sorted({*SCRIPTS_MAP.keys(), *PY_COMMANDS.keys()})

    if len(sys.argv) < 2 or sys.argv[1] in ["-h", "--help", "help"]:
        parser = argparse.ArgumentParser(
            prog="ssl-pydev",
            description="Swarm Systems Lab shared local-dev CLI",
            formatter_class=argparse.RawDescriptionHelpFormatter,
            epilog=EPILOG,
        )
        subparsers = parser.add_subparsers(dest="command", help="Available commands")
        for cmd in all_commands:
            subparsers.add_parser(cmd, help=f"Run {cmd}")
        parser.print_help()
        return 0

    command = sys.argv[1]
    command_args = sys.argv[2:]

    if command in PY_COMMANDS:
        return _run_py_command(command, command_args)

    if command not in SCRIPTS_MAP:
        print(f"Error: Unknown command '{command}'", file=sys.stderr)
        print(f"Available commands: {', '.join(all_commands)}", file=sys.stderr)
        return 1

    return _run_script(command, command_args)


if __name__ == "__main__":
    sys.exit(main())
