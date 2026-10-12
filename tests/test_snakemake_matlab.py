from __future__ import annotations


def test_import() -> None:
    import snakemake_matlab

    assert snakemake_matlab.__name__ == "snakemake_matlab"
