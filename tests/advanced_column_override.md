---
slug: advanced-column-override
number: ADV.1
title: Advanced Column Override with Styling
status: draft
---

## Standard Left Section (Received Teaching)
::: aside
"This appears on the left with an aside box."
:::

::: {.right}
## Override: Analysis on Right
::: warning
This section uses both column override AND a custom warning box.
The override places it on the right, while the warning box adds yellow styling.
:::
:::

## Standard Right Section (Jesus' Public Words)
::: aside
"This appears on the right by default."
:::

::: {.left}
## Override: Special Note on Left
::: note
This is a "Special Note" that would normally go right, but we've:
1. Forced it to the **left** column with `.left` class
2. Added a blue **note** box for emphasis
3. Used **markdown** formatting inside

The column override is *independent* of the box styling!
:::
:::

## Tension
Standard left placement with regular text.

## Notes
Standard right placement.

---

Full-width content after the horizontal rule demonstrates that overrides don't affect the HR behavior.
