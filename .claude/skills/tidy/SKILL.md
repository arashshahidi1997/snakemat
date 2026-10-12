---
name: tidy
description: Style, lean and DRY pass for snakemake-matlab. Formats and lints, then cuts bloat and removes duplication across docs and code, following .claude/rules/style.md. Use when asked to tidy, clean up, de-bloat, make DRY or restyle, or before committing.
---

# Tidy

Apply `.claude/rules/style.md` and the path-scoped rules; don't restate them.

1. **Scope.** Files changed since the last commit (`git status`), or the whole repo if
   asked. Skip `docs/log/`, `.pixi/` and lock files.
2. **Format and lint.** `pixi run format`, then `pixi run lint`; fix what lint reports.
3. **Lean.** In each file, cut what nothing needs: sentences, sections, options, dead
   code. Shorten wording; keep the substance.
4. **DRY.** Find facts, rules or logic stated in more than one place (grep distinctive
   names, numbers and phrases across the scope and the owner files). Keep each in its
   owner; elsewhere link to it, or import instead of copying.
5. **Verify.** `pixi run format-check`, `pixi run lint`, `pixi run test`.
6. **Report** in a few lines: what was cut, what moved where, and anything left for the
   user to decide.
