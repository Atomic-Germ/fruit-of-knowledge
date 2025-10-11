---
applyTo: "**/*.md"
description: Instructions for drafting and reviewing "through-the-lens" spreads.
---
# through-the-lens — Copilot / Contribution Instructions

Purpose
- Assist contributors and Copilot in.  drafting, editing, and reviewing "spreads" for the workbook-style book "Through the Lens." Provide clear constraints and templates so suggestions align with the project's editorial rules, sourcing requirements, tone, and formatting.

High-level rules
- Two-column spread format: left = Received Teaching; right = Jesus' Public Words. Center a short neutral "Tension" statement between them, followed by Reflection prompts and one Practice.
- Right column must use only public-domain Gospel translations (ASV, KJV, WEB) and document verse references and pericope context. Exclude private explanations (e.g., private dialogues with disciples), transfiguration, post-resurrection appearances, and narrator summaries.
- Left column must represent received teachings fairly and charitably. Prefer public-domain quotes or paraphrase when permissions are unclear. Avoid substantial copyrighted extracts. Mark permission status in YAML front matter.
- Tone: invitational, non-accusatory, concrete, and accessible. Avoid reward/punishment framing and polemical language.

YAML front matter (required)
- Every spread file must include YAML front matter matching the template below. Copilot should fill fields when generating content and refuse to create a spread without them.

---
slug: <slug>
number: <nn>
title: <Title>
status: draft | review | final
right_sources: ["<Book> <verses> (ASV|KJV|WEB)", ...]
left_sources:
  - {title: <source>, type: quote|paraphrase, permission: ok|pending|none}
updated: <YYYY-MM-DD>
---

Required Spread Sections
- # <Title>

- ## Received Teaching
  - One short paragraph (1-3 lines). If using a quoted left-source, ensure it's public domain or permission: ok. Otherwise paraphrase and cite the source.
  - Add a single-line context note: `- Context: <1-2 lines>`.

- ## Jesus' Public Words
  - Include a short PD translation excerpt (1-3 lines) and verse reference(s). Always include `- Reference: <Gospel and verses>` and `- Context: <1-2 lines>` noting audience and setting.
  - Confirm public setting in the pericope; if ambiguous, add reviewer note to YAML: `public_only_check: pending`.

- ## Tension
  - One concise neutral sentence naming the contrast. Do not resolve the tension.

- ## Reflection
  - Three prompts labelled: 1. Observe; 2. Empathize; 3. Act. Prompts should be short, specific, and written to invite concrete practice.

- ## Practice
  - One micro-experiment (2-7 days) with a clear, doable action.

- ## Notes
  - Citations, permissions notes, and any editorial caveats.

Sourcing rules (detailed)
- Right column: Use ASV, KJV, or WEB only. Prefer ASV by default when generating. Include verse ranges and pericope context (e.g., "Sermon on the Mount, public address").
- Public-only rule: include sayings addressed to crowds, mixed audiences, or in public settings. Exclude private instructive material unless an editorial reviewer marks `public_only_check: ok`.
- Left column: If quoting a modern copyrighted text, set `permission: pending` and prefer paraphrase until permission is obtained.

Tone and fairness checklist
- Is the left-side received teaching represented fairly and without caricature? (yes/no)
- Does the tension sentence avoid accusatory language? (yes/no)
- Are the prompts concrete and non-shaming? (yes/no)

PR checklist (automatable)
- YAML front matter present and valid
- Right column includes PD translation text and exact verse refs
- `public_only_check` set to `ok` or `pending` with reviewer assigned
- Left sources have permission state (ok|pending|none)
- 3 reflection prompts + 1 practice included
- Tone checklist set in a `qa:` block in front matter when marking `status: review`

Examples and templates
- When asked to generate a spread, always produce the YAML front matter plus the required sections. Use brief PD excerpts (1-3 lines) and conservative paraphrase for left-side texts.

Edge cases and guidance
- When a pericope's "public" status is ambiguous (e.g., private teaching recorded shortly after a public scene), add `public_only_check: pending` to YAML and include a short note in `Notes` explaining the ambiguity.
- If a requested left-source is copyrighted and permission is not yet granted, paraphrase and set permission: pending.
- If a spread could be misconstrued politically, reframe examples to interpersonal, local, and concrete actions.

How Copilot should respond to prompts in this repo
- If asked to draft a spread for a theme, generate a complete markdown file with YAML front matter and all required sections. Default to ASV translation snippets for Jesus' words and conservative paraphrase for left sources unless the contributor supplies PD left-source text.
- If asked to suggest reflection prompts or practices, return three Observe/Empathize/Act prompts and one micro-practice with explicit steps or constraints.
- If asked to convert an existing plan into a spread, preserve original phrasing in `Notes`, paraphrase copyrighted left-side quotes, and mark permission states.

Maintenance notes
- Keep `through-the-lens.instructions.md` up to date with any changes to the public-only rule, choice of PD translations, or PR checklist.
- For any ambiguous translation/citation decisions, tag `editorial: needs-legal-review` in YAML.

Contact/Review flow
- Assign a human reviewer for public-only checks and permissions checks. Tag PRs that require legal review with the `permissions` label.

---

Minimal contributor example (fill-in)

---
slug: example-power
number: 01
title: Greatness Redefined
status: draft
right_sources: ["Matt 20:25-28 (ASV)"]
left_sources:
  - {title: "Common leadership manual (paraphrase)", type: paraphrase, permission: none}
updated: 2025-10-10
---

# Greatness Redefined

## Received Teaching
> "Leaders must exercise authority to maintain order." (paraphrase)
- Context: general leadership norms and church governance.

## Jesus' Public Words
> "But it shall not be so among you: but whosoever would be great among you, shall be your minister." (Matt 20:26 ASV)
- Reference: Matt 20:25-28
- Context: spoken publicly while traveling; others present.

## Tension
From ruling-over leadership to serving-under authority.

## Reflection
1. Observe: Which words signal control in your context?
2. Empathize: Who loses when leadership is performative?
3. Act: Name one hidden service you can do this week.

## Practice
One week of unnoticed service for someone of lower status at work or home.

## Notes
- Left quote paraphrased; permission: none.
- public_only_check: ok

