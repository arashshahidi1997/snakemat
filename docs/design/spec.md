# snakemake-matlab spec

v0, 2026-10-12. The behaviour this package, and the classes bound for Snakemake, must
have. Tests name the clause IDs they cover. Status: **stable** (tested; change only with a
changelog entry), **settled** (decided with evidence; tests pending), **open** (phase in
brackets). Design and rationale: `plan.md`.

## Activation

- **ACT-1** (settled) `snakemake_matlab.enable()` in a Snakefile makes `script:` accept
  `.m` files. Importing the package alone changes nothing.
- **ACT-2** (settled) Non-`.m` scripts behave exactly as without the package.
- **ACT-3** (settled) Calling `enable()` twice has the same effect as calling it once.
- **ACT-4** (open, Phase 3) Jobs that re-parse the Snakefile in a fresh process run `.m`
  scripts too.

## Runtime

- **RUN-1** (settled) Scripts run under MATLAB, unless `enable(runtime="octave")` or
  `SNAKEMAKE_MATLAB_RUNTIME=octave` selects Octave.
- **RUN-2** (settled) The executable is `enable(matlab=…)` / `enable(octave=…)`, else
  `SNAKEMAKE_MATLAB_EXECUTABLE` / `SNAKEMAKE_MATLAB_OCTAVE_EXECUTABLE`, else `matlab` /
  `octave-cli` on `PATH`.
- **RUN-3** (settled) MATLAB runs as `<matlab> -batch <statement>`, Octave as
  `<octave-cli> --eval <statement>`, through Snakemake's shell, so `conda:`,
  `container:`, `envmodules:` and benchmarks apply.
- **RUN-4** (settled) An uncaught error fails the job, with the runtime's message in the
  log.
- **RUN-5** (settled) The script runs in the workflow's working directory.
- **RUN-6** (settled) `maxNumCompThreads` equals the rule's `threads`.

## Script files

- **FILE-1** (settled) Each job gets its own folder under `.snakemake/scripts/`, removed
  afterwards unless `--skip-script-cleanup` is given.
- **FILE-2** (settled) The script is copied there verbatim (so error line numbers match)
  under a valid MATLAB name: its own base name if valid, else a valid variant. It is called
  by name after `addpath`, never with `run()`.

## The `snakemake` object

- **OBJ-1** (settled) Scripts see a struct `snakemake` with `input`, `output`, `params`,
  `wildcards`, `log` and `resources` (each a `NamedList`), `threads` and
  `bench_iteration` (double), `config` (struct), and `rule` and `scriptdir` (char).
- **OBJ-2** (stable) A `NamedList` supports `x{i}`, `x.name`, `x{end}`, `length(x)`,
  `fieldnames(x)`, `cell(x)` and chained indexing, in both runtimes.
- **OBJ-3** (open, Phase 1) A name covering several values returns them as a cell array.
- **OBJ-4** (open, Phase 1) Python values map to MATLAB types by a fixed table. Strings
  with quotes, newlines and non-ASCII characters round-trip.
- **OBJ-5** (open, Phase 1) Keys that aren't valid MATLAB names are mangled like
  `matlab.lang.makeValidName`; a collision after mangling is an error.

## Report and logs

- **REP-1** (settled) `snakemake --report` shows the `.m` source with MATLAB highlighting.
- **LOG-1** (open, Phase 3) No automatic log redirection; `diary(snakemake.log{1})` is the
  documented pattern.

## Evidence

Phase 0, 2026-10-12, Snakemake 9.15, MATLAB R2023a, Octave 10.3. A throwaway spike
patched the three names in plan.md's internals and ran a workflow under both runtimes:
- Named and positional input/output, wildcards, and params containing `'` and `µ` all
  arrived intact.
- `threads: 2` gave `maxNumCompThreads == 2`, and the working directory was the
  workflow's.
- `01_hello.m` ran via a renamed copy.
- `error()` failed the job, left no output and removed the job folder; the report showed
  the highlighted `.m` source.
- Probes: `NamedList`, `run()` changing folder while a call by name doesn't, setting
  `maxNumCompThreads`, and quote/newline/unicode literals behaved identically in both
  runtimes.
- Startup: Octave ~1.4 s; MATLAB 14 s warm, 62 s cold.

## Changelog

- **v0** (2026-10-12): clauses from plan decisions D1–D10 and the Phase 0 spike. FILE-2
  keeps the script's own name after error traces showed the temp name instead.
