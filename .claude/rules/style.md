# Style

Lean and DRY: short docs, minimal code, nothing speculative, every fact or piece of logic
in one place.

- **Owners.** README: public pitch. CLAUDE.md: commands. `.claude/rules/`: rules.
  `docs/design/plan.md`: design, decisions, Snakemake internals. `docs/design/spec.md`:
  behaviour. Link rather than restate. Dated notes in `docs/log/` are history; leave them.
- **Code.** Reuse instead of copying (tests import package helpers). No options, files or
  sections before something needs them.
- **Tools.** black, ruff, snakefmt, codespell, and `mh_style` for `.m`. The hook
  `.claude/hooks/style.sh` formats each edited file and reports lint errors; `/tidy` runs
  the full pass.
- **Snakemake conventions**, so code can move upstream: Python 3.11+, type hints, short
  plain-prose docstrings, Conventional Commits.
- **Upstream-bound code.** `MatlabScript` and `MatlabEncoder` import nothing else from
  this package.
- **Upstream contact.** No issues or PRs on snakemake/snakemake without Arash's go-ahead.
  Snakemake requires the human author to review every line and disclose AI assistance.
