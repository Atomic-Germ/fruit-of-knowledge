# Quick Reference: Column Override in SPREAD Files

## Basic Usage

Force a section to the **left** column:
```markdown
::: {.left}
## My Section
Content here
:::
```

Force a section to the **right** column:
```markdown
::: {.right}
## My Section
Content here
:::
```

## Combining with Style Boxes

Column override works with any custom div box:

```markdown
::: {.right}
## Analysis
::: warning
This warning box appears in the right column
:::
:::
```

## Default Behavior (No Override Needed)

**Left column (default):**
- Received Teaching
- Tension  
- Practice

**Right column (default):**
- Jesus' Public Words
- Reflection
- Notes

## When to Use Overrides

✓ When a custom section name doesn't match the defaults  
✓ When visual balance requires non-standard placement  
✓ When you need to ensure placement regardless of classification logic changes  
✓ When working with special layouts or facing-page designs

## Examples

See the `tests/` directory:
- `test_column_override.md` - Basic examples
- `EXAMPLE_column_override.md` - Realistic usage
- `advanced_column_override.md` - Combined with styling boxes
