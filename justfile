# justfile - placed in your project root

# ============================================================================
# Setup & Environment
# ============================================================================

# Setup the development environment
setup:
    uv lock
    uv sync --frozen --extra dev

# Build sdist and wheel
build:
    uv run tox -e build

# ============================================================================
# Development & Code Quality
# ============================================================================

# Run lint checks
lint:
    uv run ruff format .
    uv run ruff check . --fix

# Run type checks
typecheck:
    uv run ty check src/ssl_pydev

# Run pre-commit checks
pre-commit:
    uv run pre-commit run --all-files --show-diff-on-failure

# Run security scans
security:
    uv run ssl-pydev security

# ============================================================================
# Testing
# ============================================================================

# Run all tests
test:
    uv run tox -e tests

# Run tests across multiple Python versions
test-multi-py:
    uv run tox -e py312,py313,py314

# ============================================================================
# Publishing
# ============================================================================

# Publish with uv (requires UV_PUBLISH_* env vars)
publish:
    uv run ssl-pydev publish

# Publish with twine (CI-friendly; requires TWINE_* env vars)
publish-ci:
    uv run ssl-pydev publish-ci

# ============================================================================
# Utilities
# ============================================================================

# Clean build artifacts
clean:
    rm -rf build dist *.egg-info .pytest_cache .ruff_cache __pycache__ .venv cov.xml .coverage .tox

# ============================================================================
# Composite Commands
# ============================================================================

# Full CI simulation (do this before pushing!)
check-all: lint security typecheck pre-commit test
    @echo " - All checks passed!"
