import pytest

from ssl_py_platform.cli import SCRIPTS_MAP, _get_script


def test_all_mapped_scripts_exist():
    for command in SCRIPTS_MAP:
        path = _get_script(command)
        assert path.endswith(".sh")


def test_unknown_command_raises():
    with pytest.raises(ValueError):
        _get_script("does-not-exist")
