---
paths:
  - "tests/**"
---
# Tests

- Tests that need a runtime carry `needs_matlab` or `needs_octave`; `tests/conftest.py`
  skips them when the executable is missing.
- Workflow cases use Snakemake's layout:
  `tests/test_script_<case>/{Snakefile,scripts/,expected-results/,envs/}`.
- A cold MATLAB start takes ~62 s on gamma2: put many rules in one workflow case, and
  iterate on Octave first.
