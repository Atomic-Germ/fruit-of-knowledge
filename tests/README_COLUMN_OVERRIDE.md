# Column Override Feature for SPREAD Files

This directory contains test files demonstrating the column override feature for two-column spread layouts.

## Feature Overview

SPREAD_* files automatically distribute content into two columns based on section names:
- **Left column** (default): Received Teaching, Tension, Practice
- **Right column** (default): Jesus' Public Words, Reflection, Notes

## Using Column Overrides

You can force a section to appear in a specific column by wrapping it in a div with `.left` or `.right` class:

### Syntax

```markdown
::: {.left}
## Section Name
Content here will appear in the left column
:::

::: {.right}
## Another Section
Content here will appear in the right column
:::
```

### Example Use Cases

1. **Force a non-standard section to a specific column:**
   ```markdown
   ::: {.right}
   ## Custom Analysis
   This analysis needs to be on the right for visual balance.
   :::
   ```

2. **Override default section placement:**
   ```markdown
   ::: {.right}
   ## Tension
   Normally "Tension" goes left, but this override forces it right.
   :::
   ```

3. **Ensure placement regardless of naming:**
   ```markdown
   ::: {.left}
   ## Reflection
   "Reflection" usually goes right, but we need it on the left here.
   :::
   ```

## Test Files

- `test_column_override.md` - Basic test with various overrides
- `EXAMPLE_column_override.md` - Practical example with real content

## How It Works

The `filters/split_columns.lua` Pandoc filter:
1. Detects divs with `.left` or `.right` classes
2. Extracts the content from the div
3. Places it in the specified column, overriding default classification
4. Does not interfere with other visual elements (boxes, styling, etc.)

## Benefits

- Independent of section naming conventions
- Non-invasive to existing layout
- Allows fine-grained control for special cases
- Maintains backward compatibility with existing SPREAD files
