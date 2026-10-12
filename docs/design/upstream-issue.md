# Draft: upstream issue (not posted)

For snakemake/snakemake, feature-request template. Arash reviews, edits and posts it.

---

**Title:** Support MATLAB/Octave scripts (`.m`) in the `script:` directive

**Is your feature request related to a problem? Please describe.**
`script:` covers Python, R, R Markdown, Julia, Rust, Bash, Xonsh and Hy, but not MATLAB,
so MATLAB steps are hand-built `shell: "matlab -batch '...'"` strings. GitHub code search
finds about 190 Snakefiles that mention MATLAB, with the same problems each time:
quoting rebuilt in every rule, `-r` calls where an error hangs or passes as success, paths
rewritten after a `cd`, and thread workarounds (e.g.
[hippunfold](https://github.com/khanlab/hippunfold/blob/HEAD/gen_unfold_template/Snakefile#L145),
[ssps](https://github.com/gitter-lab/ssps/blob/HEAD/Snakefile#L354),
[alu-mobility](https://github.com/yichechang/alu-mobility/blob/HEAD/workflow/rules/piv.smk#L27)).
And `snakemake --report` can't show the code: `shell:` rules show only the command.

**Describe the solution you'd like**
`.m` support in `snakemake/script/__init__.py`, shaped like the Bash support (#1821):

- `get_language()`: `.m` → `"matlab"`. This alone makes the report show highlighted
  source, since Pygments has a MATLAB lexer.
- `MatlabEncoder`: Python values to MATLAB literals, like `REncoder` and `JuliaEncoder`.
- `MatlabScript(ScriptBase)`: a preamble builds a `snakemake` struct (`input`, `output`,
  `params`, `wildcards`, `log`, `resources` as small classes supporting both
  `snakemake.input{1}` and `snakemake.input.raw`; `threads`, `config`, `rule`,
  `scriptdir`) and sets `maxNumCompThreads(threads)`. It runs `matlab -batch` or
  `octave-cli --eval` through `_execute_cmd`, so `conda:`, `container:`, `envmodules:` and
  benchmarks apply.
- MATLAB only runs files whose names are valid identifiers, so the script is copied under
  such a name into a per-job folder and called by name. A small `ScriptBase` hook for the
  temp-file name would avoid overriding `evaluate()`.
- Tests in `tests/test_script_m/` with `envs/octave.yaml`, so CI needs no MATLAB license,
  and a "MATLAB and Octave" subsection in `rules.rst`.

A prototype that patches today's Snakemake already runs this way under MATLAB R2023a and
Octave 10.3 (Snakemake 9.15), report included. I'm developing it at
https://github.com/arashshahidi1997/snakemat and would be glad to open a PR.

**Describe alternatives you've considered**
- Shell helpers: the report still can't show the code, and quoting and error handling stay
  per rule.
- A plugin interface for script languages instead of a built-in class. I'm happy to go that
  way if you prefer.

**Questions**
1. Built-in class, or a script-language plugin interface?
2. How should a `.m` script choose between MATLAB and Octave: whichever the rule's
   environment provides, or an explicit setting?
3. Should the encoder live in core, or in `snakemake-object`?

**Additional context**
The implementation ships no MathWorks code, and the MATLAB license stays the user's
concern. Octave keeps CI license-free.
