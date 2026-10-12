"""Shared pytest setup: locate MATLAB and Octave, and skip tests that need a missing one."""

from __future__ import annotations

import os
import shutil

import pytest


def find_matlab() -> str | None:
    return shutil.which(os.environ.get("SNAKEMAKE_MATLAB_EXECUTABLE", "matlab"))


def find_octave() -> str | None:
    return shutil.which(
        os.environ.get("SNAKEMAKE_MATLAB_OCTAVE_EXECUTABLE", "octave-cli")
    )


_FINDERS = {"needs_matlab": find_matlab, "needs_octave": find_octave}


def pytest_collection_modifyitems(config, items):
    missing = {marker for marker, find in _FINDERS.items() if find() is None}
    for item in items:
        for marker in missing.intersection(item.keywords):
            item.add_marker(pytest.mark.skip(reason=f"{marker}: executable not found"))


@pytest.fixture(scope="session")
def matlab_executable() -> str | None:
    return find_matlab()


@pytest.fixture(scope="session")
def octave_executable() -> str | None:
    return find_octave()
