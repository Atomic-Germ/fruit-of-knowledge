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

declare -a root_pages=()
declare -A pages_in_ch=()

# Collect root-level pages (e.g., src/manuscript/02_EATING_THE_FRUIT.md)
while IFS= read -r p; do
  root_pages+=("$p")
done < <(find "$ROOT" -maxdepth 1 -type f -name '[0-9]*_*.md' -print)

# Collect chapter directories and sort them numerically by their digits
declare -a chapter_pairs=()
while IFS= read -r d; do
  dbn=$(basename "$d")
  if [[ $dbn =~ ([0-9]+) ]]; then
    dd=$((10#${BASH_REMATCH[1]}))
  else
    dd=0
  fi
  chapter_pairs+=("$dd|$d")
done < <(find "$ROOT" -maxdepth 1 -type d -name 'CHAPTER_*' -print)

IFS=$'\n' chapter_pairs=($(printf '%s\n' "${chapter_pairs[@]}" | sort -n -t'|' -k1,1))

# Helper to sort files by numeric prefix (NN_name.md)
sort_by_prefix() {
  # expects file paths on stdin
  awk -F/ '{print $0"\t"$NF}' | awk -F'_' '{ if ($1 ~ /[0-9]+/) {printf "%s\t%d\n", $0, $1+0} else {printf "%s\t0\n", $0}}' | sort -k2,2n | cut -f1
}

# Print root-level pages first (sorted by prefix)
if [ ${#root_pages[@]} -gt 0 ]; then
  printf '%s\n' "${root_pages[@]}" | sort_by_prefix
fi

# For each chapter in numeric order, print chapter-local pages (prefix-sorted) then spreads
for pair in "${chapter_pairs[@]}"; do
  chpath=${pair#*|}
  # pages inside this chapter directory matching NN_name.md
  mapfile -t ch_pages < <(find "$chpath" -maxdepth 1 -type f -name '[0-9]*_*.md' -print 2>/dev/null || true)
  if [ ${#ch_pages[@]} -gt 0 ]; then
    printf '%s\n' "${ch_pages[@]}" | sort_by_prefix
  fi

  # spreads in this chapter (use canonical numeric listing and filter for this chapter path)
  scripts/list_spreads.sh | grep "^${chpath}/" || true
done

# Any pages not printed yet (e.g., numeric pages in other locations) — print at end sorted
other_pages=()
while IFS= read -r p; do
  # ignore files already in root_pages or in a CHAPTER_* folder
  case "$p" in
    $ROOT/*) # already handled root or chapter entries
      # but ensure we don't double-print; skip
      ;;
    *) other_pages+=("$p") ;;
  esac
done < <(find "$ROOT" -type f -name '[0-9]*_*.md' -print)

if [ ${#other_pages[@]} -gt 0 ]; then
  printf '%s\n' "${other_pages[@]}" | sort_by_prefix
fi
