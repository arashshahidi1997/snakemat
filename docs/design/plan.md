# snakemake-matlab plan

Background and evidence: `docs/log/idea/idea-arash-20261009-192036-757067.md`.
Spec (from Phase 0): `docs/design/spec.md`. Rules: `.claude/rules/`.

## Target

```python
import snakemake_matlab
snakemake_matlab.enable()

rule scale:
    input: raw="data/{sub}.mat"
    output: "results/{sub}_scaled.mat"
    params: gain=2.5
    script: "scripts/scale.m"
```

```matlab
data = load(snakemake.input.raw);
y = data.x * snakemake.params.gain;
save(snakemake.output{1}, 'y');
```

Runs under MATLAB or Octave; `snakemake --report` shows the `.m` source.

## Snakemake internals (checked 2026-10-09 on 9.15.0 and `main`/9.27.0)

- `script/__init__.py::get_language()` maps extensions to languages, and `script()` maps
  languages to `ScriptBase` subclasses through a dict literal. No plugin type covers
  script languages.
- The report loads `script:` code via `get_source()` → `get_language()` and highlights it
  with Pygments, which has a `matlab` lexer. `shell:` rules show only the command.
- Snakefiles run in `snakemake.workflow`'s globals, which bound `script` at import, so
  patch `snakemake.workflow.script` as well as `snakemake.script.*`. Cluster jobs re-parse
  the Snakefile, so `enable()` must be called there.
- MATLAB won't run files named like Snakemake's temp scripts (`tmpXXXX.foo.m`) or names
  starting with a digit.
- `ScriptBase` internals drift between versions (`Snakemake` moved to
  `snakemake.iocontainers` on `main`): bind arguments by name and pin a tested range.

## Strategy

- **Upstream first.** No plugin type covers script languages, so MATLAB belongs in
  Snakemake's script module. `MatlabEncoder` and `MatlabScript` are written to drop in
  there unchanged; this package adds only the patch that installs them (`enable()`) and
  extras.
- **Template:** the merged Bash PR (snakemake/snakemake#1821): encoder + `ScriptBase`
  subclass, exact-string encoder tests, a `rules.rst` section, a conda-env test. File
  layout from the merged Xonsh PR (#3310).
- **Octave from the start.** Snakemake tests languages through conda envs; Octave is on
  conda-forge, MATLAB isn't.
- **Review is slow** (Perl #4164 and marimo #4302 have waited months), so the upstream
  issue goes out after Phase 0.
- **Parked:** a MATLAB software-deployment plugin, once that interface is released.

## Loop

Each phase repeats implement → test → revise spec until its exit holds. Every MUST clause
in the spec has an ID and a test that names it; spec changes go in its changelog. Save
each pass with `datalad_save`.

## Decisions (settle in Phase 0)

| | Decision | Why |
|---|---|---|
| D1 | `snakemake_matlab.enable()` in the Snakefile; importing alone patches nothing | Visible; re-applies when cluster jobs re-parse the Snakefile |
| D2 | Patch `snakemake.script.get_language` (`.m` → `"matlab"`); wrap `snakemake.script.script` and `snakemake.workflow.script`, binding args by name | See internals above |
| D3 | `MatlabEncoder` writes MATLAB literals into the preamble | Exact types, no sidecar files, upstream shape; `jsondecode` mangles lists and arrays |
| D4 | `NamedList` class (`input{1}`, `input.raw`) if it works in Octave; else struct + cell | Parity with R and Julia |
| D5 | Per-job dir with valid-identifier file names; verbatim script copy called by name after `addpath` | See internals above; `run()` changes folder; line numbers stay right |
| D6 | Run via `_execute_cmd`: `matlab -batch` / `octave-cli --eval`; executable from `enable()`, `SNAKEMAKE_MATLAB_EXECUTABLE` / `SNAKEMAKE_MATLAB_OCTAVE_EXECUTABLE`, or `PATH` | Both exit 1 on error; conda, containers and envmodules for free |
| D7 | Cap threads: `maxNumCompThreads` in MATLAB; Octave to be checked | MATLAB grabs every core |
| D8 | No log redirection; document `diary(snakemake.log{1})` | Parity |
| D9 | Mangle invalid keys like `makeValidName`; error on collision | Matches `jsondecode` |
| D10 | MATLAB by default; `enable(runtime="octave")` or `SNAKEMAKE_MATLAB_RUNTIME` | `.m` can't tell them apart |

## Phases

**0. Spike and spec v0.** One `.m` rule under both runtimes. Check the report, `NamedList`
in Octave, `run()` and file names, Octave threads. Write spec v0. Exit: each decision
settled or deferred. Then draft the upstream issue (built-in class tested via
`envs/octave.yaml`, or a script-plugin interface; MATLAB vs Octave choice; encoder in core
or `snakemake-object`).

**1. Core.** `enable()`, patch, `MatlabEncoder`, `MatlabScript`. Tests: encoder golden
strings, file names, patch idempotency; one workflow case per runtime covering every
`snakemake` field, errors failing the job, relative paths, `01_x.m`, local functions,
threads. Tests reuse the package's executable lookup instead of `conftest.py`'s copy.
Exit: `examples/basic/` runs.

**2. Parity.** Report shows `.m`; `--rerun-triggers code`; `--skip-script-cleanup`;
wildcard script paths; `github(...)` scripts; Octave via `conda:`. Exit: each behaves as
for `.py`, or the spec says why not.

**3. Dogfood.** Port one pixecog rule from `sutil.matlab.matlab2shell`, adding only what it
needs (extra paths, function files, per-rule runtime, logging). Test cluster-style
re-parsing and `envmodules:`.

**4. CI.** `conventional-prs.yml` and `release-please.yml` (as in every Snakemake repo); format and lint; unit and Octave tests across the Snakemake range (including
10); MATLAB via `setup-matlab`. Warn outside the tested range; state supported versions.

**5. Release.** Docs; release-please writes the changelog; TestPyPI, then PyPI 0.1.0. Upstream PR in the Bash PR's
shape against post-v10 `main`.

Source layout: `src/snakemake_matlab/{_patch,_script,_encoder}.py`.

## Risks

- Snakemake internals drift (v10 rework): name binding, version gate, CI matrix, upstream.
- MATLAB startup time per job: out of scope for 0.1.
- Octave narrows the MATLAB-side design: `mh_style` and the spike catch problems.
