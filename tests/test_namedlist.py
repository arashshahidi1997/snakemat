from pathlib import Path

import pytest
from conftest import RUNTIMES, run_m

import snakemake_matlab

PACKAGE_M = Path(snakemake_matlab.__file__).parent / "matlab"
TEST_M = Path(__file__).parent / "matlab"


@pytest.mark.parametrize("runtime", RUNTIMES)
def test_namedlist(runtime):
    """OBJ-2: NamedList indexing works in both runtimes."""
    run_m(runtime, f"addpath('{PACKAGE_M}', '{TEST_M}'); check_namedlist")
