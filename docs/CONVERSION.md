Conversion plan — pandoc + LaTeX two-column spread template

Overview
--------
This repository now contains a minimal Pandoc-based conversion pipeline to render a single "spread" (one manuscript Markdown file) into a two-column LaTeX/PDF spread using the paracol package.

What I added
- templates/spread-template.tex — Pandoc LaTeX template. Uses YAML metadata (title, number, slug, updated, public_only_check) to render the header and $body$ for the spread.
- filters/split_columns.lua — Pandoc Lua filter that groups H2 sections and splits them into left / right columns.
- scripts/convert_spread.sh — Convenience script that runs Pandoc + filter + template and outputs a PDF (or .tex if you change the output extension).

Mapping rules (default)
- Column assignment (default):
  - Left column: "Received Teaching", "Tension", "Practice"
  - Right column: "Jesus' Public Words", "Reflection", "Notes"
- Metadata mapping (YAML -> template): $title$, $number$, $slug$, $updated$, $public_only_check$ are rendered in the top header area.

Implementation notes
- The Lua filter scans the document for H2 headers (##) and groups blocks between H2s. It then classifies each H2 by name and assigns the corresponding blocks to left or right column content.
- The filter wraps the left/right material in a paracol environment by emitting raw LaTeX blocks:
  \begin{paracol}{2}
    <left content>
  \switchcolumn
    <right content>
  \end{paracol}
- The Pandoc template provides the LaTeX preamble and prints the title/metadata above $body$.

How to run (examples)
- Convert a single spread to PDF (requires a working TeX engine such as xelatex):

  scripts/convert_spread.sh src/manuscript/CHAPTER_01/SPREAD_01.md out/CHAPTER_01_SPREAD_01.pdf

- Produce a LaTeX file instead of PDF (good for iterative debugging):

  scripts/convert_spread.sh src/manuscript/CHAPTER_01/SPREAD_01.md out/CHAPTER_01_SPREAD_01.tex

  (then run your preferred LaTeX engine on the .tex file)

Customizing column mapping
- To change which section headings go to which column, edit `filters/split_columns.lua` and modify `classifyHeader()`.
- The filter uses simple substring matching (case-insensitive). If your headings vary, either normalize them in the manuscript or expand the `classifyHeader()` rules.

Testing & next steps
1. Run the script on 1–2 canonical spreads (start with CHAPTER_01/SPREAD_01.md). Review the output PDF for layout and typographic needs.
2. Tune the LaTeX template (fonts, spacing, heading styles) in `templates/spread-template.tex`.
3. If you prefer different column widths or more sophisticated parallel typesetting, update the template to pass options to paracol or switch to another package.
4. Batch conversion: create a small script that iterates over `src/manuscript/**` and converts a set (or the whole book). Consider producing a single LaTeX book file by concatenating spread-level LaTeX fragments.

Limitations & assumptions
- The filter assumes the spread Markdown follows the H2-based sectioning used in the manuscript (Received Teaching, Jesus' Public Words, etc.). If a document uses different headings, some content may fall into the default (right) column.
- The template and filter currently target LaTeX/PDF output; other formats will still work but the two-column split is implemented via raw LaTeX blocks and therefore only applies to LaTeX output.

If you'd like, next I can:
- Convert two canonical spreads and attach the generated .tex (or show a diff of the .tex) so you can review the precise LaTeX output.
- Tweak typographic choices (font, heading sizes, margins).
- Add a Makefile target or package.json script to automate batch conversion.
