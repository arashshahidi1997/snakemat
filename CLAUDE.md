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
- There is no Makefile: the `make` targets in the projio section below don't exist. Save
  and push with the MCP datalad tools.
- Rules live in `.claude/rules/` (loaded automatically). `/tidy` runs the style, lean and
  DRY pass.

## Projio workspace

This project uses **projio** — a project-centric research assistance ecosystem.
All project knowledge (papers, notes, code libraries, search indexes) is managed
through MCP tools. **Always use MCP tools instead of direct file manipulation**
for projio-managed resources.

**Tool preference:** When an MCP tool exists for an operation, always prefer it
over the Bash equivalent — even for simple commands like `git status` or
`datalad status`. MCP tools return structured output and resolve environment
variables (Python paths, conda envs) that differ from the MCP server's own env.
Only fall back to Bash when no MCP tool covers the operation.

At the start of a session, call `project_context()` to understand the workspace
and `runtime_conventions()` to see available Makefile targets.

## Agent tool routing

| Intent | MCP tool | Do NOT |
|--------|----------|--------|
| Understand the project | `project_context()` | Read config files directly |
| See available commands | `runtime_conventions()` | Parse the Makefile manually |
| Search project knowledge | `rag_query(query)` | Grep through docs manually |
| Multi-facet search | `rag_query_multi(queries)` | Run multiple greps |
| Check indexed sources | `corpus_list()` | Inspect Chroma store directly |
| Rebuild search index | `indexio_build()` | Run `indexio build` in terminal |
| Check indexed sources | `indexio_sources_list()` | Inspect config files directly |
| Sync all subsystem sources | `indexio_sources_sync(build=True)` | Run sync commands manually |
| Ingest papers by DOI | `biblio_ingest(dois)` | Write BibTeX by hand |
| Look up a paper | `citekey_resolve(citekeys)` | Read .bib files directly |
| Get full paper context | `paper_context(citekey)` | Read docling/GROBID outputs directly |
| Find unresolved refs | `paper_absent_refs(citekey)` | Parse references.json manually |
| Check paper status | `library_get(citekey)` | Read library.yml directly |
| Update paper status | `biblio_library_set(citekeys)` | Edit library.yml directly |
| Normalize citekeys | `biblio_citekey_normalize(apply, enrich)` | Rename bib entries by hand |
| Merge bibliography | `biblio_merge()` | Run `biblio merge` in terminal |
| Fetch PDFs from BibTeX | `biblio_pdf_fetch(dry_run, force)` | Copy PDFs manually |
| Fetch PDFs via OA cascade | `biblio_pdf_fetch_oa(force, citekeys)` | Run `biblio bibtex fetch-pdfs-oa` |
| Extract full text | `biblio_docling(citekey)` | Run `biblio docling` in terminal |
| Batch extract full text | `biblio_docling_batch(force, background)` | Run docling loop manually |
| Check Docling job status | `biblio_docling_status(job_id)` | Poll job manually |
| Extract references | `biblio_grobid(citekey)` | Run `biblio grobid` in terminal |
| Check GROBID server | `biblio_grobid_check()` | Curl the GROBID API manually |
| Expand reference graph | `biblio_graph_expand(citekeys)` | Run `biblio graph expand` |
| Sync biblio sources to index | `biblio_rag_sync()` | Run `biblio rag sync` in terminal |
| Create a note/task/idea | `note_create(note_type)` | Create markdown files directly |
| List recent notes | `note_list()` | List files in notes/ directory |
| Read a note | `note_read(path)` | Read the file directly |
| Find note by ID/timestamp | `note_resolve(note_id)` | Grep filenames or semantic search |
| Search notes | `note_search(query)` | Grep through notes/ |
| Update note metadata | `note_update(path, fields)` | Edit frontmatter directly |
| See note types | `note_types()` | Read notio.toml directly |
| Rebuild note indexes | `notio_reindex(note_type?)` | Regenerate index.md manually |
| Scaffold a presentation deck | `present_init(name, format?, template?)` | Create deck.yml by hand |
| List decks | `present_list()` | Walk docs/deliverables/presentations/ manually |
| Deck status (sections, figures, citations) | `present_status(name)` | Inspect files manually |
| Rich deck dashboard | `present_overview(name)` | Compile stats manually |
| Assemble deck markdown | `present_assemble(name)` | Concatenate sections manually |
| Build deck via marp-cli | `present_build(name, format?)` | Run `marp` in terminal |
| Validate deck | `present_validate(name)` | Grep citekeys / figure ids manually |
| Section-drafting context | `present_section_context(name, section)` | Multiple reads manually |
| Insert figio figure into section | `present_figure_insert(name, section, figure_id)` | Edit markdown directly |
| Cite check (bib + docling) | `present_cite_check(name)` | Cross-ref manually |
| Diff vs last assembled.md | `present_diff(name)` | Run `diff` in terminal |
| Import section from another project | `present_section_import(name, from_project, source_deck, section)` | Copy files manually |
| Refresh imported section | `present_refresh_import(name, section)` | Re-copy manually |
| Freeze imported section | `present_freeze_import(name, section?)` | Edit deck.yml manually |
| Seed deck from a paper (LLM) | `present_seed_from_paper(name, citekey)` | Run `biblio present` in terminal |
| Add a library | `codio_add_urls(urls)` | Edit YAML registry files |
| Find libraries by capability | `codio_discover(query)` | Grep catalog.yml |
| Inspect a library | `codio_get(name)` | Read catalog + profiles manually |
| List all libraries | `codio_list()` | Parse registry files directly |
| Check registry vocabulary | `codio_vocab()` | Read schema docs |
| Validate registry | `codio_validate()` | Run consistency checks manually |
| Register a library (with role) | `codio_add(name, kind, role)` | Edit YAML registry files |
| Sync codio sources to index | `codio_rag_sync()` | Run `codio rag sync` in terminal |
| List figures | `figio_figure_list()` | Scan for YAML files manually |
| Inspect a figure | `figio_inspect(figure_id)` | Read spec files directly |
| Build a figure | `figio_build(figure_id)` | Run `figio build` in terminal |
| Validate a figure | `figio_validate(figure_id)` | Run `figio validate` in terminal |
| Edit a figure spec | `figio_edit_spec(figure_id, patch)` | Edit YAML directly |
| Query build output | `figio_query_output(figure_id, query)` | Parse SVG directly |
| List flows | `pipeio_flow_list(prefix?)` | Parse registry YAML directly |
| Flow status | `pipeio_flow_status(flow)` | Inspect flow dirs manually |
| Audit flow against pipeline-docs.md spec | `pipeio_flow_audit(flow)` — read-only; reports missing scaffold files, canonical docs/index.md sections, and mod facet gaps. Use before `pipeio_flow_new(flow)` to preview what idempotent scaffold would add | Manual file-by-file check |
| Scaffold new flow (also completes an existing flow) | `pipeio_flow_new(flow)` — idempotent; only writes missing files | Create flow skeleton manually |
| Fork an existing flow | `pipeio_flow_fork(src, dest)` | Copy flow dir manually |
| Deregister a flow | `pipeio_flow_deregister(flow)` | Edit registry.yml manually |
| Scan for pipelines | `pipeio_registry_scan()` | Walk filesystem manually |
| Validate registry | `pipeio_registry_validate()` | Check consistency manually |
| List mods | `pipeio_mod_list(flow)` | Parse registry manually |
| Resolve rule → mod | `pipeio_mod_resolve(flow, rule)` | Grep Snakefiles manually |
| Mod context (rules, scripts, doc, config) | `pipeio_mod_context(flow, mod)` | Multiple reads manually |
| Scaffold mod (script + docs) | `pipeio_mod_create(flow, mod, inputs, outputs)` | Create files manually |
| Add script to existing mod | `pipeio_script_create(flow, mod, script_name)` | Create script manually |
| Audit mod health | `pipeio_mod_audit(flow, mod?)` | Manual inspection |
| Refresh mod doc from code | `pipeio_mod_doc_refresh(flow, mod, facet, apply?)` | Rewrite spec.md manually |
| Record flow design change | Edit `code/pipelines/{flow}/CHANGELOG.md` — Keep-a-Changelog style, date + rationale + notio refs (see pipeline-docs.md) | Let strategy shifts get lost in git log |
| List rules | `pipeio_rule_list(flow)` | Parse Snakefiles manually |
| Generate rule stub | `pipeio_rule_stub(flow, rule_name)` | Write rule text manually |
| Insert rule into Snakefile | `pipeio_rule_insert(flow, rule_name)` | Edit Snakefiles manually |
| Patch existing rule | `pipeio_rule_update(flow, rule_name, add_inputs)` | Edit Snakefiles manually |
| Scaffold flow config | `pipeio_config_init(flow, input_dir, output_dir)` | Create config.yml manually |
| Read flow config | `pipeio_config_read(flow)` | Parse config.yml directly |
| Patch flow config | `pipeio_config_patch(flow, registry_entry, apply?)` | Edit config.yml directly |
| Scaffold notebook (kind-aware) | `pipeio_nb_create(flow, name, kind, mod?)` | Create .py files manually |
| Notebook status | `pipeio_nb_status(flow?, name?)` | Parse notebook.yml manually |
| Audit notebook quality | `pipeio_nb_audit()` | Manual inspection |
| Read notebook + metadata | `pipeio_nb_read(flow, name)` | Read .py + parse YAML manually |
| Analyze notebook structure | `pipeio_nb_analyze(flow, name)` | Parse .py files manually |
| Check sync state | `pipeio_nb_diff(flow, name)` | Compare mtimes manually |
| Update notebook metadata | `pipeio_nb_update(flow, name)` | Edit notebook.yml directly |
| Move notebook between flows | `pipeio_nb_move(flow_from, flow_to, name)` | Copy files + edit both notebook.yml |
| Sync notebook | `pipeio_nb_sync(flow, name, direction?)` | Run jupytext manually |
| Sync all in flow | `pipeio_nb_sync_flow(flow)` | Sync each manually |
| Scan for unregistered | `pipeio_nb_scan(register?)` | Walk filesystem manually |
| Publish notebook | `pipeio_nb_publish(flow, name)` | Copy files manually |
| Execute notebook | `pipeio_nb_exec(flow, name, params)` | Run papermill manually |
| Full notebook pipeline | `pipeio_nb_pipeline(flow, name)` | Chain sync/publish/collect |
| Build Jupyter Lab manifest | `pipeio_nb_lab(flow?, sync?)` | Create symlinks manually |
| Promote notebook to mod | `pipeio_nb_promote(flow, name, mod)` | Manual extraction |
| Validate notebook structure | `pipeio_nb_validate(flow, name)` | Eyeball notebook formatting |
| Open marimo notebook (launch or attach) | `pipeio_nb_open(flow, name)` | Hand-type `marimo edit --headless ...` |
| Live-edit marimo notebook | `pipeio_nb_watch(flow, name)` | Launch marimo CLI manually |
| Execute marimo + read outputs | `pipeio_nb_snapshot(flow, name)` | Run marimo + parse output manually |
| Extract figures from executed notebook | `pipeio_nb_extract(flow, name)` | Dig ipynb/marimo outputs by hand |
| Validate I/O contracts | `pipeio_contracts_validate()` | Check configs manually |
| Cross-flow manifest chains | `pipeio_cross_flow(flow?)` | Compare configs manually |
| Session completion | `pipeio_completion(flow)` | Glob output dirs manually |
| Resolve output paths | `pipeio_target_paths(flow, group, member)` | Construct BIDS paths manually |
| Export DAG | `pipeio_dag_export(flow, graph_type)` | Run snakemake --rulegraph |
| Generate snakemake HTML report (size pre-flight) | `pipeio_flow_report(flow)` | Run snakemake --report directly |
| Parse logs | `pipeio_log_parse(flow)` | Read log files manually |
| Collect pipeline docs | `pipeio_docs_collect()` | Copy doc files manually |
| Generate docs nav | `pipeio_docs_nav()` | Build nav YAML manually |
| Patch mkdocs nav | `pipeio_mkdocs_nav_patch()` | Edit mkdocs.yml manually |
| Generate modkey bibliography | `pipeio_modkey_bib()` | Write BibTeX manually |
| Launch Snakemake run | `pipeio_run(flow, wildcards?)` | Run snakemake in terminal |
| Check run progress | `pipeio_run_status(run_id?)` | Check screen sessions |
| Run dashboard | `pipeio_run_dashboard()` | Aggregate run info manually |
| Kill a run | `pipeio_run_kill(run_id)` | Kill screen sessions |
| Build doc site | `site_build()` | Run `make docs` or `mkdocs build` |
| Deploy to pages | `site_deploy(target)` | Run `make deploy` or push manually |
| Check git status | `git_status()` | Run `git status` in Bash |
| Save dataset changes | `datalad_save(message)` | Run `make save` or `datalad save` |
| Check dataset status | `datalad_status()` | Run `make status` or `datalad status` |
| Push to sibling | `datalad_push(sibling)` | Run `make push` or `datalad push` |
| Pull from sibling | `datalad_pull(sibling)` | Run `make pull` or `datalad update` |
| List siblings | `datalad_siblings()` | Run `datalad siblings` manually |

## Workflow conventions

1. **Search first** — check existing knowledge before creating new content
2. **Ingest pipeline** — after `biblio_ingest`, run `biblio_merge` → `biblio_pdf_fetch_oa` → `biblio_docling_batch` → `biblio_grobid` → `biblio_graph_expand` → `indexio_build`
3. **Record decisions** — create notes to capture analysis and decisions

## pipeio entity management

pipeio manages pipeline entities through MCP tools. Read `skill_read("pipeio-guide")` for the full ontology reference.

### Capability matrix

| Entity | Create | Read | Update | Audit |
|--------|--------|------|--------|-------|
| **Flow** | `flow_new` (CLI, idempotent) | `flow_list`, `flow_status` | agent edits | `registry_validate` |
| **Mod** | `mod_create` (script + docs) | `mod_list`, `mod_context` | agent edits | `mod_audit` |
| **Rule** | `rule_stub`, `rule_insert` | `rule_list` | `rule_update` | `mod_audit` |
| **Config** | `config_init` | `config_read` | `config_patch` | `contracts_validate` |
| **Script** | `mod_create`, `script_create` | `mod_context` | agent edits | `mod_audit` |
| **Notebook** | `nb_create` (kind-aware) | `nb_read`, `nb_status`, `nb_analyze` | `nb_update` (metadata) | `nb_audit` |
| **Mod docs** | `mod_create` (theory + spec) | `mod_context` | `mod_doc_refresh` | `mod_audit` |
| **Promote** | `nb_promote` | — | — | — |
| **Manifest** | config sets path | `cross_flow` | agent edits | `contracts_validate` |
| **Site docs** | `docs_collect` | `docs_nav` | re-collect | — |
| **Core library** | `codio_add(role="core")` | `codio_get`, `codio_list` | agent edits | — |
| **Project utils** | `projio sync` (auto-detect) | `project_context` | agent edits | — |

**Scaffolding tools produce correct starting points.** `nb_create` generates kind-aware templates (investigate vs demo), `mod_create` and `script_create` discover the project's compute library via codio (role=core) and include imports. **Structured write helpers** (`config_patch`, `rule_insert`, `rule_update`) validate input and produce diffs. **Free-form code editing** is agent territory.

### Code tiers

Projects organize code in three tiers (see `docs/specs/pipeio/code-tiers.md`):

| Tier | Location | codio role | Agent policy |
|------|----------|------------|-------------|
| Core library | `code/lib/{name}/` | `core` | Agents can add code here |
| Project utils | `code/utils/` | — | Project-specific glue |
| Flow scripts | `code/pipelines/{flow}/scripts/` | — | One script per rule |

`projio sync` auto-discovers `code/lib/*/` and registers in codio with `role=core`. `project_context()` returns the active code tier configuration.

### Notebook workspaces

Notebooks route to workspaces by `kind`:
- `investigate`/`explore` → `notebooks/explore/.src/` (never published)
- `demo`/`validate` → `notebooks/demo/.src/` (published to site)

### Notebook lifecycle

```
pipeio_nb_create(flow, name, kind="investigate", mod="filter")  # scaffold
pipeio_nb_update(flow, name, status="archived")                 # lifecycle transition
pipeio_nb_promote(flow, name, mod="filter")                     # extract to mod
pipeio_nb_pipeline(flow, name)                                  # sync → publish → collect
```

### Mod documentation facets

Each mod has `docs/{mod}/theory.md` (rationale + citations) and `spec.md` (I/O contracts). `mod_doc_refresh(flow, mod, facet="spec", apply=True)` regenerates spec.md from current mod_context.

### Agentic workflow

1. **Discover:** `pipeio_nb_scan()` → find unregistered notebooks
2. **Triage:** `pipeio_nb_status(flow)` or `pipeio_nb_audit()` → quality report
3. **Understand:** `pipeio_nb_read(flow, name)` → content + metadata + analysis
4. **Check sync:** `pipeio_nb_diff(flow, name)` → which file is newer
5. **Fix config:** `pipeio_nb_update(...)` → set status, kind, mod, kernel
6. **Sync:** `pipeio_nb_sync(flow, name, direction='py2nb')` after editing .py
7. **Audit mods:** `pipeio_mod_audit(flow)` → contract drift, missing docs/scripts

**Addressing:** All tools use `(flow, name)` — no `pipe` parameter. Never use raw file paths.

## Cross-project dispatch

When filing observations for another project via worklog MCP:

**Model selection:** haiku (trivial/typo) · sonnet (single-module, clear scope) · opus (default, multi-package, architectural)

**Dispatch decision:**
- Well-scoped bug with clear fix → `worklog_note(text, project_id, kind="issue", auto_dispatch=True, model="sonnet")`
- Complex/architectural issue → `worklog_note(text, project_id, kind="issue", auto_dispatch=True)` (opus is default)
- Direct task, no promotion needed → `worklog_note(text, project_id, kind="task", auto_dispatch=True)` (wraps body in ## Prompt, enqueues directly)
- Observation, no immediate action → `worklog_note(text, project_id)` (no auto_dispatch)
- Need result now → `run_prompt(project, prompt)` (synchronous)

Queue timeout is 30 minutes. Use `tail_task(queue_id)` to monitor running tasks.
`list_queue()` defaults to active entries only, newest-first, compact output.
Filter with `schedule_id=`, `since="24h"`, `project=`. Pass `status="all"` for history.
`schedule_queue` accepts `scheduled_at="now"` for immediate or `after="queue_id"` for dependency-based scheduling.
CLI: `worklog queue`, `worklog queue tail <id>`, `worklog queue cancel <id>`.

Use `note_resolve(note_id)` to find notes by timestamp/capture ID.

**Task promotion:** `promote_to_task` only uses LLM enrichment for voice captures.
Agent-written notes get a template prompt pointing at the source — no LLM call needed.

## Development

No Makefile exists yet (see Commands at the top), so `runtime_conventions()` returns nothing useful.
Use the MCP tools `datalad_save()`, `datalad_push()`, `datalad_pull()`, and `datalad_status()`.
