import importlib

import pytest

from ssl_pydev.cli import PY_COMMANDS, SCRIPTS_MAP, _get_script


def test_all_mapped_scripts_exist():
    for command in SCRIPTS_MAP:
        path = _get_script(command)
        assert path.endswith(".sh")


def test_unknown_command_raises():
    with pytest.raises(ValueError):
        _get_script("does-not-exist")


def test_no_command_overlaps_between_bash_and_python_dispatch():
    assert set(SCRIPTS_MAP) & set(PY_COMMANDS) == set()


def test_all_py_commands_resolve_to_a_callable_main():
    for target in PY_COMMANDS.values():
        module_name, func_name = target.split(":")
        module = importlib.import_module(module_name)
        assert callable(getattr(module, func_name))
