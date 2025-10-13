#!/usr/bin/env bash
set -euo pipefail

# Validate ordering produced by scripts/list_book_fragments.sh
LIST=$(scripts/list_book_fragments.sh)
echo "$LIST" > /tmp/_book_order.txt

fail=0

check_spread_order_for_chapter() {
  chapter_dir="$1"
  # find spreads for chapter from the canonical list
  spreads=( $(scripts/list_spreads.sh | grep "^${chapter_dir}/" || true) )
  if [ ${#spreads[@]} -eq 0 ]; then
    return 0
  fi

  # If there's a numeric page for this chapter, ensure it appears before the first spread
  chapter_num=$(basename "$chapter_dir" | sed -E 's/[^0-9]*([0-9]+).*/\1/')
  page_pattern="src/manuscript/${chapter_num}_"
  page_line=$(grep -n "^${page_pattern}" /tmp/_book_order.txt | cut -d: -f1 || true)
  if [ -n "$page_line" ]; then
    # ensure first spread line is after page_line
    first_spread_line=$(grep -n "^${spreads[0]}$" /tmp/_book_order.txt | cut -d: -f1 || true)
    if [ -z "$first_spread_line" ]; then
      echo "ERROR: First spread ${spreads[0]} not found in ordering" >&2
      fail=1
      return
    fi
    if [ "$first_spread_line" -lt "$page_line" ]; then
      echo "ERROR: Page for chapter ${chapter_num} appears after its spread" >&2
      fail=1
    fi
  fi

  # Check spreads numeric order
  prev_num=0
  for s in "${spreads[@]}"; do
    bn=$(basename "$s")
    sn=$(echo "$bn" | sed -E 's/[^0-9]*([0-9]+).*/\1/')
    sn=$((10#$sn))
    if [ $sn -lt $prev_num ]; then
      echo "ERROR: Spread ordering in $chapter_dir is not numeric: $s after prev $prev_num" >&2
      fail=1
    fi
    prev_num=$sn
  done
}

# Run checks for each CHAPTER_* directory
while IFS= read -r ch; do
  check_spread_order_for_chapter "$ch"
done < <(find src/manuscript -maxdepth 1 -type d -name 'CHAPTER_*' | sort)

if [ $fail -eq 1 ]; then
  echo "Ordering test FAILED" >&2
  exit 2
else
  echo "Ordering test PASSED" >&2
  exit 0
fi
