# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

# snakemake-matlab

MATLAB and GNU Octave support for Snakemake's `script:` directive (`snakemake-matlab` on
PyPI, imported as `snakemake_matlab`): `script: "foo.m"` runs with a `snakemake` object
injected, and `snakemake --report` shows the `.m` source. Scaffold only so far. Renamed
from `snakemat` on 2026-10-12; the repo folder, projio project and GitHub repo keep the
old name.

Read `docs/design/plan.md` before coding: it holds the design, the decisions and the
Snakemake internals they rest on. Evidence and history: the design note
`docs/log/idea/idea-arash-20261009-192036-757067.md` (read it with `note_read`).

## Commands

```bash
pixi run test                    # runtime tests skip if MATLAB/Octave is missing
pixi run test-unit               # tests that need neither runtime
pixi run -e octave test          # with Octave 10.3 (conda-forge, linux/macOS)
pixi run pytest tests/test_snakemake_matlab.py::test_import
pixi run format                  # black + snakefmt
pixi run format-check
pixi run lint                    # ruff, codespell, mh_style
```

- MATLAB R2023a is on `PATH` on gamma2 (`/storage/share/bin/R2023a/bin/matlab`). Override
  with `SNAKEMAKE_MATLAB_EXECUTABLE` / `SNAKEMAKE_MATLAB_OCTAVE_EXECUTABLE`.
- Plain git (no datalad); `origin` is GitHub. Commit each pass with Conventional Commits.
- Rules live in `.claude/rules/` (loaded automatically). `/tidy` runs the style, lean and
  DRY pass.

## Notes

Design notes live in `docs/log/`, managed by notio (projio), which worklog also writes to.
Create and change them with the projio MCP tools (`note_create`, `note_read`,
`note_search`, `note_list`, `note_update`), not by editing frontmatter by hand. No other
projio subsystem is used here.
