# ssl_pydev

Shared local-dev CLI for `Swarm-Systems-Lab` Python projects. Wraps the same
build/publish/docs-validation logic that `ssl_ci`'s composite actions run in CI,
packaged here so it can be installed **once per machine** instead of copy-pasted
into every project's `scripts/` directory.

## Install

```bash
uv tool install ssl_pydev
```

This installs a single `ssl-pydev` command, available from any project
directory, independent of that project's own virtualenv/dependencies.

> **Using VS Code installed via snap on Linux?** Run the command above from a
> regular system terminal, **not** VS Code's integrated terminal. Snap
> confinement redirects `$HOME`/`$XDG_DATA_HOME` for processes spawned inside
> VS Code's snap, so `uv tool install` ends up putting `ssl-pydev` somewhere
> only visible from inside that snap (e.g.
> `~/snap/code/<rev>/.local/share/uv/tools/...`), invisible to any other
> terminal.

## Usage

```bash
ssl-pydev setup-env --extras dev,tests
ssl-pydev build
ssl-pydev build-native     # for compiled-extension (pybind11/scikit-build-core) projects
ssl-pydev publish          # uv-based publish, requires UV_PUBLISH_* env vars
ssl-pydev publish-ci       # twine-based publish, requires TWINE_* env vars
ssl-pydev validate-docs
ssl-pydev generate-stubs --module mypkg._core --output src/   # pybind11 type stubs
```

Every command operates on the current working directory, so run it from the
root of the project you want to act on - same as the `scripts/*.sh` files it
replaces. A project's `justfile` recipes become one-liners, e.g.:

```just
setup:
    ssl-pydev setup-env --extras dev,lint,tests,type-checking,pre-commit
```

## Relationship to `ssl_ci`

- `ssl_ci` holds the **GitHub Actions** side: reusable workflows and composite
  actions that CI calls directly via `uses:`.
- `ssl_pydev` (this repo) holds the **local-dev** side: the same logic,
  installed once per developer machine via `uv tool install`.

Today the two are maintained in parallel (the underlying `.sh` scripts started
as copies of each other). Once this package has at least one published
release, the plan is to update `ssl_ci`'s composite actions to install and
call `ssl_pydev` themselves, so there's a single source of truth used by
both CI and local dev.

## Versioning

Released the same way as the other `Swarm-Systems-Lab` packages: tag `vX.Y.Z`,
push, and `ssl_ci`'s `publish.yml` builds and uploads to PyPI.
