#!/usr/bin/env bash
set -euo pipefail

# List manuscript files in the order they should appear in the concatenated book
# - Pages named with a numeric prefix and underscore (e.g., 03_WHATS_AT_STAKE.md)
#   are treated as chapter-level pages and placed before the spreads of the
#   matching chapter number.
# - Spread files live under chapter directories and are named SPREAD_*.md

ROOT="src/manuscript"

if [ ! -d "$ROOT" ]; then
  exit 0
fi

declare -A pages_by_chapter
declare -a unmatched_pages=()

# Collect page files at the manuscript root matching NNN_name.md pattern
while IFS= read -r p; do
  # strip trailing newline
  bn=$(basename "$p")
  if [[ $bn =~ ^([0-9]+)_(.+)\.md$ ]]; then
    num=${BASH_REMATCH[1]}
    num=$((10#$num))
    existing=${pages_by_chapter[$num]:-}
    if [ -n "$existing" ]; then
      pages_by_chapter[$num]="$existing|$p"
    else
      pages_by_chapter[$num]="$p"
    fi
  else
    unmatched_pages+=("$p")
  fi
done < <(find "$ROOT" -maxdepth 1 -type f -name '[0-9]*_*.md' -print)

# Build a sorted list of chapter directories (CHAPTER_XX)
mapfile -t chapters < <(find "$ROOT" -maxdepth 1 -type d -name 'CHAPTER_*' -print | sort)

# Helper: print pages list for a chapter num (if any), sorted by name
print_pages_for_chapter() {
  local chapnum=$1
  local list=${pages_by_chapter[$chapnum]:-}
  if [ -n "$list" ]; then
    IFS='|' read -r -a arr <<< "$list"
    # sort by filename stable
    printf '%s\n' "${arr[@]}" | sort
  fi
}

# Print unmatched pages first (those not matching NN_ pattern under root)
if [ ${#unmatched_pages[@]} -gt 0 ]; then
  printf '%s\n' "${unmatched_pages[@]}" | sort
fi

# For each chapter in numeric order, print pages for that chapter, then spreads
for ch in "${chapters[@]}"; do
  chbn=$(basename "$ch")
  if [[ $chbn =~ ([0-9]+) ]]; then
    chnum=$((10#${BASH_REMATCH[1]}))
  else
    chnum=0
  fi

  # pages for this chapter (e.g., 03_*.md)
  print_pages_for_chapter "$chnum"

  # spreads in this chapter, use the canonical numeric listing and filter for this chapter
  if [ -d "$ch" ]; then
    scripts/list_spreads.sh | grep "^$ch/" || true
  fi
done

# Any pages whose chapter number doesn't match an existing chapter (leftover)
# e.g., page with prefix for a chapter that doesn't exist — print at end
for key in "${!pages_by_chapter[@]}"; do
  found=0
  for ch in "${chapters[@]}"; do
    chbn=$(basename "$ch")
    if [[ $chbn =~ ([0-9]+) ]] && [ $((10#${BASH_REMATCH[1]})) -eq $key ]; then
      found=1
      break
    fi
  done
  if [ $found -eq 0 ]; then
    # print these pages
    IFS='|' read -r -a arr <<< "${pages_by_chapter[$key]}"
    printf '%s\n' "${arr[@]}" | sort
  fi
done
