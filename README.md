# ssl_pydev

Shared local-dev CLI for `Swarm-Systems-Lab` Python projects. Wraps the same build/publish/docs-validation logic that `ssl_ci`'s composite actions run in CI, packaged here so it can be installed **once per machine** instead of copy-pasted into every project's `scripts/` directory.

## Install

```bash
uv tool install ssl_pydev
```

This installs a single `ssl-pydev` command, available from any project directory, independent of that project's own virtualenv/dependencies.

> **Using VS Code installed via snap on Linux?** Run the command above from a regular system terminal, **not** VS Code's integrated terminal. Snap confinement redirects `$HOME`/`$XDG_DATA_HOME` for processes spawned inside VS Code's snap, so `uv tool install` ends up putting `ssl-pydev` somewhere only visible from inside that snap (e.g. `~/snap/code/<rev>/.local/share/uv/tools/...`), invisible to any other terminal.

## Usage

```bash
ssl-pydev -h

ssl-pydev new my-project       # scaffold a new project from ssl_py_template
ssl-pydev new-sim my-project   # scaffold a new ssl_simulator research project
ssl-pydev prune                # find and interactively remove files orphaned by a template update

ssl-pydev setup-env --extras dev,tests
ssl-pydev build
ssl-pydev build-native     # for compiled-extension (pybind11/scikit-build-core) projects
ssl-pydev publish          # uv-based publish, requires UV_PUBLISH_* env vars
ssl-pydev publish-ci       # twine-based publish, requires TWINE_* env vars
ssl-pydev validate-docs
ssl-pydev generate-stubs --module mypkg._core --output src/   # pybind11 type stubs
```

Every command operates on the current working directory, so run it from the root of the project you want to act on.

A project's `justfile` recipes become one-liners, e.g.:

```just
setup:
    ssl-pydev setup-env --extras dev,lint,tests,type-checking,pre-commit
```

## Versioning

Released the same way as the other `Swarm-Systems-Lab` packages: tag `vX.Y.Z`,
push, and `ssl_ci`'s `publish.yml` builds and uploads to PyPI.
