# snakemat

First-class MATLAB support for [Snakemake](https://snakemake.readthedocs.io) pipelines.

Snakemake's `script:` directive runs Python, R, Rmd, Julia, Rust, Bash, Xonsh and Hy
scripts with a `snakemake` object injected (input, output, params, wildcards, threads,
resources, log, config). MATLAB is not on that list, so MATLAB steps today are written
as hand-built `shell: "matlab -batch '...'"` strings, with quoting, path setup and
argument passing redone in every rule.

snakemat aims to close that gap:

- **MATLAB-side `snakemake` object**: a struct/class exposing `input`, `output`,
  `params`, `wildcards`, `threads`, `resources`, `log`, `config` inside MATLAB,
  mirroring what R and Julia scripts get.
- **Rule-side helper**: run a `.m` script or function from a rule without
  string-building `matlab -batch` commands by hand.
- **Runtime hygiene**: configurable MATLAB executable and toolbox paths (e.g. labbox),
  `maxNumCompThreads` tied to `threads`, non-zero exit on MATLAB error, and log
  redirection to the rule's `log:`.

## Status

Scaffolded (2026-10-09). The design is still open. See `docs/log/` for design notes.

## Layout

```
src/snakemat/      Python package (Snakemake side)
tests/             pytest suite
docs/              mkdocs site + projio notes (docs/log/)
```

## Development

```bash
pixi install
pixi run pytest
```

MATLAB on gamma2: `/storage/share/bin/R2023a/bin/matlab`.
