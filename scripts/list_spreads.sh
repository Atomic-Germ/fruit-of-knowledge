#!/usr/bin/env bash
set -euo pipefail

# List all manuscript spread files sorted by chapter number then spread number (numerically).
# Output: one file path per line, suitable for iteration in Makefile or scripts.

ROOT_DIR="src/manuscript"

if [ ! -d "$ROOT_DIR" ]; then
  echo "" >&2
  exit 0
fi

# Find files named SPREAD_*.md under src/manuscript
find "$ROOT_DIR" -type f -name 'SPREAD_*.md' | while read -r f; do
  chapter_dir=$(basename "$(dirname "$f")")
  # extract first number sequence from chapter dir (e.g., CHAPTER_02 -> 02)
  chapter_num=$(echo "$chapter_dir" | sed -E 's/[^0-9]*([0-9]+).*/\1/')
  bn=$(basename "$f")
  spread_num=$(echo "$bn" | sed -E 's/[^0-9]*([0-9]+).*/\1/')
  # fallback to 0 if not found
  chapter_num=${chapter_num:-0}
  spread_num=${spread_num:-0}
  # Force base-10 parsing to avoid issues with numbers like 08 being treated as octal
  chapter_num=$((10#$chapter_num))
  spread_num=$((10#$spread_num))
  printf "%04d %04d %s\n" "$chapter_num" "$spread_num" "$f"
done | sort -n -k1,1 -k2,2 | awk '{print $3}'
