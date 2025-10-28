# Extended Markdown Features

This build system now supports extensive Pandoc markdown extensions beyond basic markdown.

## Enabled Extensions

- **definition_lists** - Definition list syntax
- **footnotes** - Inline and reference footnotes
- **pipe_tables** - Simple pipe-separated tables
- **grid_tables** - Complex grid tables
- **fenced_divs** - Custom div containers with `:::`
- **bracketed_spans** - Inline spans with `[text]{.class}`
- **inline_code_attributes** - Code with attributes
- **fenced_code_attributes** - Code blocks with language/attributes
- **strikeout** - ~~strikethrough text~~
- **superscript** - text^superscript^
- **subscript** - text~subscript~
- **task_lists** - GitHub-style task lists
- **smart** - Smart quotes, dashes, ellipses

## Custom Div Boxes

Use fenced divs to create colored boxes:

```markdown
::: warning
This is a warning box (yellow)
:::

::: note
This is a note box (blue)
:::

::: info
This is an info box (cyan)
:::

::: tip
This is a tip box (green)
:::

::: caution
This is a caution box (red)
:::

::: example
This is an example box (purple)
:::

::: aside
This is an aside box (gray)
:::
```

## Two-Column Spread Layout

In SPREAD_* files, content is automatically distributed into two columns with these defaults:
- **Left column**: Received Teaching, Tension, Practice
- **Right column**: Jesus' Public Words, Reflection, Notes

### Column Override

Force a section to a specific column using div wrappers with `.left` or `.right` classes:

```markdown
::: {.left}
## Custom Section Name
This content will appear in the left column regardless of the section name.
:::

::: {.right}
## Tension
Normally "Tension" goes left, but this override forces it to the right column.
:::
```

This allows you to assert column placement independent of section naming conventions without affecting other visual layout elements.

## Tables

### Pipe Tables

```markdown
| Header 1 | Header 2 |
|----------|----------|
| Cell 1   | Cell 2   |
| Cell 3   | Cell 4   |
```

### Grid Tables

```markdown
+----------+----------+
| Header 1 | Header 2 |
+==========+==========+
| Cell 1   | Cell 2   |
+----------+----------+
```

## Footnotes

```markdown
Here's some text with a footnote.[^1]

[^1]: This is the footnote text.
```

## Definition Lists

```markdown
Term 1
:   Definition 1

Term 2
:   Definition 2a
:   Definition 2b
```

## Task Lists

```markdown
- [ ] Uncompleted task
- [x] Completed task
```

## Text Formatting

- ~~Strikethrough~~
- Superscript: E = mc^2^
- Subscript: H~2~O
- [Highlighted text]{.highlight} (inline span)

## Code Blocks

```{.python .numberLines}
def hello():
    print("Hello, world!")
```

## Smart Typography

- "Smart quotes"
- Em-dash: ---
- En-dash: --
- Ellipsis: ...

## Scripture Expansion Tool

The repository includes a script to automatically expand Bible references to full scripture text from the American Standard Version (ASV).

### Usage

```bash
# Expand references in a file and print to stdout
python scripts/expand_scripture.py input.md

# Expand and save to a new file
python scripts/expand_scripture.py input.md output.md
```

### Syntax

Use double brackets around scripture references:

```markdown
[[John 3:16]]
[[Luke 10:30-37]]
[[1 Corinthians 13:4-8]]
```

### Output Format

References are expanded to aside blocks with the scripture text:

```markdown
::: aside
"For God so loved the world, that he gave his only begotten Son, that whosoever believeth on him should not perish, but have eternal life."
:::
```

This will render as a gray aside box with the scripture formatted inside.

### Requirements

The script requires Python 3 and the `requests` library:

```bash
pip install requests
```
