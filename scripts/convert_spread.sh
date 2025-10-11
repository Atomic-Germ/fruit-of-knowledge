#!/usr/bin/env bash
set -euo pipefail

if [ "$#" -lt 1 ]; then
  echo "Usage: $0 input.md [output.pdf]"
  exit 1
fi

INPUT="$1"
OUTPUT="${2:-${INPUT%.md}.pdf}"
mkdir -p "$(dirname "$OUTPUT")"

pandoc "$INPUT" \
  --from markdown+yaml_metadata_block \
  --lua-filter=filters/split_columns.lua \
  --template=templates/spread-template.tex \
  --pdf-engine=xelatex \
  -V geometry:margin=1in \
  -o "$OUTPUT"

echo "Wrote $OUTPUT"
