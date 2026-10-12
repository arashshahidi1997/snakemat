# snakemake-matlab

MATLAB and GNU Octave scripts in [Snakemake](https://snakemake.readthedocs.io)'s `script:`
directive.

A community package; not part of Snakemake, and not affiliated with or endorsed by
MathWorks. MATLAB is a registered trademark of The MathWorks, Inc.

Snakemake's `script:` directive runs Python, R, Rmd, Julia, Rust, Bash, Xonsh and Hy
scripts with a `snakemake` object injected (input, output, params, wildcards, threads,
resources, log, config). MATLAB is not on that list, so MATLAB steps today are written
as hand-built `shell: "matlab -batch '...'"` strings, with quoting, path setup and
argument passing redone in every rule.

## Motivation

Hand-built `shell:` commands lose what `script:` gives other languages: structured access
to the rule's inputs and outputs, correct failure handling, and the script's source in
`snakemake --report`.

As of October 2026 nobody seems to have filed a feature request (there is none in the
Snakemake issue tracker or Discussions, or on Stack Overflow). The workarounds are
everywhere, though. GitHub code search finds about 190 Snakefiles that mention MATLAB,
and the same problems recur:

| Workaround | Seen in | What goes wrong |
|---|---|---|
| Hand-escaped `matlab -batch "addpath(...); f('{input}')"` | [khanlab/hippunfold](https://github.com/khanlab/hippunfold/blob/HEAD/gen_unfold_template/Snakefile#L145), [erjel/iterative-biofilm-annotation](https://github.com/erjel/iterative-biofilm-annotation/blob/HEAD/workflows/rules/analysis.smk#L181), [elhuhdron/emdrp](https://github.com/elhuhdron/emdrp/blob/HEAD/Snakefile#L143) | Quoting rebuilt in every rule |
| `-r` with a hand-written `try … catch, quit(1)` | [gitter-lab/ssps](https://github.com/gitter-lab/ssps/blob/HEAD/Snakefile#L354) | Exit codes handled by hand; `-singleCompThread` to stop MATLAB taking every core |
| `-r "…; exit"`, or `subprocess.run` without a return-code check | [timtroendle/geographic-scale](https://github.com/timtroendle/geographic-scale/blob/HEAD/rules/uncertainty.smk#L35), [cbg-ethz/FiTree](https://github.com/cbg-ethz/FiTree/blob/HEAD/workflows/AML.smk#L272), [wanglab-broad/starfinder](https://github.com/wanglab-broad/starfinder/blob/HEAD/workflow/rules/registration.smk#L14) | A MATLAB error can hang the job or let it pass as a success |
| `cd` into the script folder, then `'../../{input}'` | [timtroendle/geographic-scale](https://github.com/timtroendle/geographic-scale/blob/HEAD/rules/uncertainty.smk#L35) | Paths rewritten by hand |
| Workspace variables set before calling a script | [cbg-ethz/FiTree](https://github.com/cbg-ethz/FiTree/blob/HEAD/workflows/AML.smk#L272) | A hand-built version of what `script:` does for R or Julia |
| Thread workarounds | [yichechang/alu-mobility](https://github.com/yichechang/alu-mobility/blob/HEAD/workflow/rules/piv.smk#L27) | "matlab will fail at starting its parpool", so `threads: 1` |

A tutorial by [Kalenkovich & Levchenko](https://github.com/kalenkovich/reproducible-MEEG/blob/HEAD/manuscript/reproducible-meeg.tex)
notes that `script:` does not support MATLAB. Its own `shell:` example passes the paths
to MATLAB unquoted. None of these rules can show their `.m` code in the report.

## Goals

snakemake-matlab aims to close that gap:

- **`script: "foo.m"` with report support**: a MATLAB script runs from a rule like a
  Python or R script does, and `snakemake --report` shows its source, highlighted.
- **MATLAB-side `snakemake` object**: a struct/class exposing `input`, `output`,
  `params`, `wildcards`, `threads`, `resources`, `log`, `config` inside MATLAB,
  mirroring what R and Julia scripts get.
- **Rule-side helper**: run a `.m` script or function from a rule without
  string-building `matlab -batch` commands by hand.
- **Runtime hygiene**: configurable MATLAB executable and toolbox paths (e.g. labbox),
  `maxNumCompThreads` tied to `threads`, non-zero exit on MATLAB error, and log
  redirection to the rule's `log:`.

## Status

Scaffolded (2026-10-09; renamed from `snakemat` on 2026-10-12). The design is still open.
See `docs/log/` for design notes and `docs/design/plan.md` for the implementation plan.

## Layout

```
src/snakemake_matlab/  Python package (Snakemake side)
tests/                 pytest suite
docs/                  mkdocs site, design plan (docs/design/) and projio notes (docs/log/)
```

## Development

```bash
pixi install
pixi run test              # runtime tests skip when MATLAB/Octave is missing
pixi run -e octave test    # with GNU Octave from conda-forge (linux/macOS)
pixi run lint
```
