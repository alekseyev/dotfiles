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

# Ruff finds pyproject.toml/ruff.toml by walking up from the file itself, but uvx
# always fetches the newest ruff. Prefer the venv's pinned version so formatting
# and rule set match what the project's CI enforces.
dir=$(cd "$(dirname "$file")" && pwd)
while :; do
    for candidate in "$dir/.venv/bin/ruff" "$dir/venv/bin/ruff"; do
        [ -x "$candidate" ] && ruff=("$candidate") && break 2
    done
    [ "$dir" = "/" ] && break
    dir=$(dirname "$dir")
done

# Poetry keeps its venv outside the tree, so the walk-up above misses it; an env
# activated before Claude started (direnv, poetry shell) is inherited here instead.
if [ -z "${ruff+x}" ] && [ -n "${VIRTUAL_ENV:-}" ] && [ -x "$VIRTUAL_ENV/bin/ruff" ]; then
    ruff=("$VIRTUAL_ENV/bin/ruff")
fi

if [ -z "${ruff+x}" ]; then
    if ! command -v uvx >/dev/null 2>&1; then
        echo "ruff hook: no venv ruff and no uvx on PATH, skipping format/lint of $file" >&2
        exit 2
    fi
    ruff=(uvx ruff)
fi

# A syntax error fails format; let check report it rather than exiting quietly.
"${ruff[@]}" format -q "$file" >/dev/null 2>&1 || true

if ! output=$("${ruff[@]}" check "$file" 2>&1); then
    printf '%s\n' "$output" | head -40 >&2
    exit 2
fi
