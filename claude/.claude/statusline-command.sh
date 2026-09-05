#!/bin/bash
# Claude Code status line
export LC_NUMERIC=C
input=$(cat)

cur_dir=$(echo "$input" | jq -r '.workspace.current_dir')
dir_name=$(basename "$cur_dir")
model_name=$(echo "$input" | jq -r '.model.display_name')

branch=""
if git --no-optional-locks -C "$cur_dir" rev-parse --is-inside-work-tree >/dev/null 2>&1; then
  branch=$(git --no-optional-locks -C "$cur_dir" branch --show-current 2>/dev/null)
  if [ -n "$branch" ] && [ -n "$(git --no-optional-locks -C "$cur_dir" status --porcelain 2>/dev/null)" ]; then
    branch="${branch}*"
  fi
fi

context_remaining=$(echo "$input" | jq -r '.context_window.remaining_percentage // empty')
five_hour=$(echo "$input" | jq -r '.rate_limits.five_hour.used_percentage // empty')

CYAN=$'\033[36m'
YELLOW=$'\033[33m'
MAGENTA=$'\033[35m'
GREEN=$'\033[32m'
RESET=$'\033[0m'

line="${CYAN}${dir_name}${RESET}"
[ -n "$branch" ] && line="${line} ${YELLOW}${branch}${RESET}"
line="${line} ${MAGENTA}${model_name}${RESET}"

if [ -n "$context_remaining" ]; then
  pct=$(printf '%.0f' "$context_remaining")
  line="${line} ${GREEN}${pct}% left${RESET}"
fi

if [ -n "$five_hour" ]; then
  five_pct=$(printf '%.0f' "$five_hour")
  line="${line} ${GREEN}5h:${five_pct}%${RESET}"
fi

printf "%s\n" "$line"
