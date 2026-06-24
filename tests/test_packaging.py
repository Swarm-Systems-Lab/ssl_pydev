"""End-to-end check that the built wheel actually exposes a working CLI.

Catches packaging mistakes (wrong `packages =` path, missing scripts/__init__.py,
stale entry point, ...) that unit tests against the source tree can't see, since
those import the package directly rather than going through a real install.
"""

import shutil
import subprocess
from pathlib import Path

import pytest

from ssl_pydev.cli import SCRIPTS_MAP

PROJECT_ROOT = Path(__file__).parent.parent


@pytest.mark.slow
def test_built_wheel_installs_and_runs(tmp_path):
    dist_dir = tmp_path / "dist"
    subprocess.run(
        ["uv", "build", "--wheel", "--out-dir", str(dist_dir)],
        cwd=PROJECT_ROOT,
        check=True,
    )

    wheels = list(dist_dir.glob("*.whl"))
    assert len(wheels) == 1, f"expected exactly one wheel, found {wheels}"

    venv_dir = tmp_path / "venv"
    subprocess.run(["uv", "venv", str(venv_dir), "-q"], check=True)
    subprocess.run(
        ["uv", "pip", "install", "--python", str(venv_dir / "bin" / "python"), str(wheels[0])],
        check=True,
    )

    cli = venv_dir / "bin" / "ssl-pydev"
    assert cli.is_file(), "console script 'ssl-pydev' was not installed by the wheel"

    help_result = subprocess.run([str(cli), "--help"], capture_output=True, text=True, check=True)
    for command in SCRIPTS_MAP:
        assert command in help_result.stdout, f"'{command}' missing from --help output"

    # Exercise a real subcommand end-to-end: validate-docs against a directory with
    # no mkdocs.yml should fail cleanly (exit 1, clear message), not crash.
    docs_result = subprocess.run(
        [str(cli), "validate-docs"], capture_output=True, text=True, cwd=tmp_path
    )
    assert docs_result.returncode == 1
    assert "mkdocs config not found" in docs_result.stderr

    shutil.rmtree(venv_dir, ignore_errors=True)
