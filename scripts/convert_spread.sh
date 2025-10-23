#!/usr/bin/env bash
set -euo pipefail

if [ "$#" -lt 1 ]; then
  echo "Usage: $0 input.md [output.pdf]"
  exit 1
fi

INPUT="$1"
OUTPUT="${2:-${INPUT%.md}.pdf}"
mkdir -p "$(dirname "$OUTPUT")"

# Default executable names; allow overrides via environment
PANDOC="${PANDOC:-pandoc}"

PDF_ENGINE="${PDF_ENGINE:-}"
# Auto-detect a TeX engine if the user did not provide one.
if [ -z "$PDF_ENGINE" ] && [ "${OUTPUT##*.}" = "pdf" ]; then
  for e in xelatex lualatex pdflatex; do
    if command -v "$e" >/dev/null 2>&1; then
      PDF_ENGINE="$e"
      break
    fi
  done
fi

if [ "${OUTPUT##*.}" = "pdf" ]; then
  if [ -n "$PDF_ENGINE" ]; then
    echo "Using PDF engine: $PDF_ENGINE"
    "$PANDOC" "$INPUT" \
      --from markdown+yaml_metadata_block+definition_lists+footnotes+pipe_tables+grid_tables+fenced_divs+bracketed_spans+inline_code_attributes+fenced_code_attributes+strikeout+superscript+subscript+task_lists+smart \
      --lua-filter=filters/footnotes_to_footer.lua \
      --lua-filter=filters/custom_divs.lua \
      --lua-filter=filters/split_columns.lua \
      --lua-filter=filters/blockquote_box.lua \
      --template=templates/spread-template.tex \
      --pdf-engine="$PDF_ENGINE" \
      -V geometry:margin=1in \
      -o "$OUTPUT"
    echo "Wrote $OUTPUT"
  else
    OUTPUT_TEX="${OUTPUT%.pdf}.tex"
    echo "No TeX engine found. Producing LaTeX file instead: $OUTPUT_TEX"
    "$PANDOC" "$INPUT" \
      --from markdown+yaml_metadata_block+definition_lists+footnotes+pipe_tables+grid_tables+fenced_divs+bracketed_spans+inline_code_attributes+fenced_code_attributes+strikeout+superscript+subscript+task_lists+smart \
      --lua-filter=filters/footnotes_to_footer.lua \
      --lua-filter=filters/custom_divs.lua \
      --lua-filter=filters/split_columns.lua \
      --lua-filter=filters/blockquote_box.lua \
      --template=templates/spread-template.tex \
      -o "$OUTPUT_TEX"
    echo "Wrote $OUTPUT_TEX"
  fi
else
  "$PANDOC" "$INPUT" \
    --from markdown+yaml_metadata_block \
    --lua-filter=filters/split_columns.lua \
    --template=templates/spread-template.tex \
    -o "$OUTPUT"
  echo "Wrote $OUTPUT"
fi
