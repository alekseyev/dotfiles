#!/usr/bin/env bash
# PostToolUse hook: formats Python files Claude writes, then lints them.
# Exit 2 hands ruff check's output back to Claude to fix; formatting is silent.
set -uo pipefail

file=$(jq -r '.tool_response.filePath // .tool_input.file_path // empty')
case "$file" in
    *.py) ;;
    *) exit 0 ;;
esac
[ -f "$file" ] || exit 0

if ! command -v uvx >/dev/null 2>&1; then
    echo "ruff hook: uvx not on PATH, skipping format/lint of $file" >&2
    exit 2
fi

# A syntax error fails format; let check report it rather than exiting quietly.
uvx ruff format -q "$file" >/dev/null 2>&1 || true

if ! output=$(uvx ruff check "$file" 2>&1); then
    printf '%s\n' "$output" | head -40 >&2
    exit 2
fi
