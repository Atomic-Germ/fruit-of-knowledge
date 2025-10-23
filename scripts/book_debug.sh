#!/usr/bin/env bash
set -euo pipefail

OUT_DIR="${1:-out/book}"
FRAG_DIR="$OUT_DIR/fragments"
PANDOC="${PANDOC:-pandoc}"
PDF_ENGINE="${PDF_ENGINE:-/Library/TeX/texbin/xelatex}"

mkdir -p "$FRAG_DIR"

echo "Generating per-spread fragments in $FRAG_DIR"
for f in $(find src/manuscript -name '*.md' | sort); do
  bn=$(echo "$f" | sed 's#src/manuscript/##; s#/#_#g')
  bn="${bn%.md}.tex"
  echo "  $f -> $FRAG_DIR/$bn"
  if echo "$f" | grep -q '/SPREAD_'; then
    "$PANDOC" "$f" --to=latex --from markdown+yaml_metadata_block+definition_lists+footnotes+pipe_tables+grid_tables+fenced_divs+bracketed_spans+inline_code_attributes+fenced_code_attributes+strikeout+superscript+subscript+task_lists+smart --lua-filter=filters/footnotes_to_footer.lua --lua-filter=filters/custom_divs.lua --lua-filter=filters/split_columns.lua --lua-filter=filters/blockquote_box.lua --template=templates/fragment-template.tex -o "$FRAG_DIR/$bn"
  else
    "$PANDOC" "$f" --to=latex --from markdown+yaml_metadata_block+definition_lists+footnotes+pipe_tables+grid_tables+fenced_divs+bracketed_spans+inline_code_attributes+fenced_code_attributes+strikeout+superscript+subscript+task_lists+smart --lua-filter=filters/footnotes_to_footer.lua --lua-filter=filters/custom_divs.lua --lua-filter=filters/blockquote_box.lua --template=templates/fragment-template.tex -o "$FRAG_DIR/$bn"
  fi
done

frags=("$(ls -1 "$FRAG_DIR" | sort)")
IFS=$'\n' read -rd '' -a fraglist <<<"$(ls -1 "$FRAG_DIR" | sort)" || true
total=${#fraglist[@]}

echo "Found $total fragments; testing incremental builds..."
for ((i=1;i<=total;i++)); do
  echo "Testing first $i fragments..."
  test_tex="$OUT_DIR/test_book.tex"
  test_pdf="$OUT_DIR/test_book.pdf"
  test_log="$OUT_DIR/test_book.log"
  # build test tex
  # Use a minimal header for incremental tests (omit tableofcontents/clearpage)
  sed -e '/\\tableofcontents/d' -e '/\\clearpage/d' templates/book-header.tex > "$test_tex"
  for idx in $(seq 0 $((i-1))); do
    cat "$FRAG_DIR/${fraglist[$idx]}" >> "$test_tex"
  done
  cat templates/book-footer.tex >> "$test_tex"
  # compile
  (cd "$OUT_DIR" && rm -f test_book.aux test_book.toc test_book.log test_book.out test_book.pdf || true && "$PDF_ENGINE" -interaction=nonstopmode -file-line-error "test_book.tex" >"test_book.log" 2>&1) || true
  if [ -f "$test_pdf" ]; then
    echo "  OK (produced test_book.pdf for first $i fragments)"
    rm -f "$test_pdf" "$OUT_DIR/test_book.aux" "$OUT_DIR/test_book.log" "$OUT_DIR/test_book.out" || true
  else
    echo "FAIL: LaTeX failed when compiling first $i fragments"
    echo "Failing fragment: ${fraglist[$((i-1))]} (index $i)"
    echo "Last 200 lines of log:"; tail -n 200 "$test_log" || true
    exit 2
  fi
done

echo "All fragments compiled incrementally — no single-fragment failure detected."
echo "You can now try building the entire book normally."
