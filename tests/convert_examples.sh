#!/usr/bin/env bash
# Example test script to convert two canonical spreads. This is a convenience script — it does not run by default.
set -euo pipefail

OUTDIR="out/tests"
mkdir -p "$OUTDIR"

scripts/convert_spread.sh src/manuscript/CHAPTER_01/SPREAD_01.md "$OUTDIR/CH01_SP01.pdf"
scripts/convert_spread.sh src/manuscript/CHAPTER_04/SPREAD_02.md "$OUTDIR/CH04_SP02.pdf"

echo "Converted test spreads to $OUTDIR"
