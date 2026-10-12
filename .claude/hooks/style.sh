#!/usr/bin/env bash
# PostToolUse hook: format the edited file; send lint/spelling problems back to Claude (exit 2).
f=$(jq -r '.tool_input.file_path // empty')
bin="$CLAUDE_PROJECT_DIR/.pixi/envs/quality/bin"
case "$f" in
  "$CLAUDE_PROJECT_DIR"/docs/log/* | */.pixi/*) exit 0 ;;
  "$CLAUDE_PROJECT_DIR"/*) ;;
  *) exit 0 ;;
esac
[ -f "$f" ] && [ -d "$bin" ] && cd "$CLAUDE_PROJECT_DIR" || exit 0

case "$f" in
  *.py) "$bin/black" -q "$f"; out=$("$bin/ruff" check -q --output-format concise "$f" 2>&1) ;;
  */Snakefile | *.smk) out=$("$bin/snakefmt" "$f" 2>&1 >/dev/null) ;;
  *.m) out=$("$bin/mh_style" --fix --brief "$f" 2>&1) ;;
esac || { echo "$out" >&2; exit 2; }

case "$f" in
  *.py | *.m | *.md | *.toml | *.yml | *.yaml | */Snakefile | *.smk)
    out=$("$bin/codespell" "$f" 2>&1) || { echo "$out" >&2; exit 2; } ;;
esac
exit 0
