# Through the Lens: Project Plan

## Overview
A workbook-style book that juxtaposes commonly received Christian teachings alongside only the public words of Jesus of Nazareth (from the canonical Gospels), presented in a two‑column spread. Each spread includes reflection prompts and a small weekly practice. The aim is to cultivate a Jesus‑like outlook without reward/punishment framing.

## Problem
- Readers often inherit summaries, slogans, or institutional positions that may not align with Jesus’ public teaching.
- Typical study materials synthesize or harmonize; few place sources in tension without resolving them.

## Solution
- Two‑column system per spread: left = received teaching; right = Jesus’ public words; centered tension statement, followed by reflection prompts and a micro‑practice.
- Strict sourcing: right column uses only public sayings of Jesus, with citations and minimal historical context; left column cites original sources or representative formulations.

## Goals
- Invite honest comparison without polemics.
- Encourage observation, empathy, and concrete practice over abstract doctrine.
- Maintain accessibility, brevity, and transparency of sources.

## Non‑Goals
- Not a systematic theology, commentary, or apologetic.
- No claims about salvation, orthodoxy, or denominational correctness.
- No private sayings, post‑resurrection words, or editorial narrator summaries on the right column.

## Audience
- Curious readers, small groups, inter‑tradition discussions, and deconstructing/reconstructing Christians.

## Book Structure
- Part I: Orientation (how to use the book, sourcing rules, reflection method).
- Part II: Spreads organized by themes (12–20 core themes). Each theme may have 1–3 spreads.
- Part III: Practices toolkit, bibliography, notes on method.

## Spread Anatomy
1. Theme/Title
2. Left Column: Received Teaching
   - Source and exact quote (or representative paraphrase if PD constraints require), 1–2 lines context.
3. Right Column: Jesus’ Public Words
   - Public‑domain translation (KJV/ASV/WEB). Gospel references listed. 1–2 lines historical context.
4. Juxtapose/Tension: 1–2 lines naming the contrast without resolving it.
5. Reflection: 3 prompts (observe, empathize, act) with space to write.
6. Practice: one micro‑experiment for the week.
7. Notes: citations and footnotes.

## Sourcing and Permissions
- Right column translations: KJV, ASV, or WEB (public domain). Include verse refs and pericope context.
- Public‑only filter: include sayings spoken to crowds, adversaries, or mixed public settings; exclude private explanations to disciples, transfiguration, post‑resurrection, and editorial narrator summaries.
- Left column quotes: prefer public domain or obtain permission; otherwise paraphrase and cite the idea, avoiding substantial copyrighted text. Keep fair‑use limits conservative; when uncertain, summarize and link.

## Theme Set (initial)
- Power and authority; Enemies and retaliation; Money and possessions; Status and greatness; Outsiders and inclusion; Sabbath and mercy; Oaths and truthfulness; Hypocrisy and show; Anxiety and trust; Leadership and service; Judging and forgiving; Violence and peace; Purity and compassion; Generosity and secrecy; Prayer and posture.

## Editorial Guardrails
- Tone: invitational, not accusatory; no punishment/reward framing.
- Language: plain, inclusive, concrete; avoid jargon.
- Context: keep Jesus’ sayings in pericope context; note audience and setting succinctly.
- Fairness: represent received teachings accurately and charitably.

## Research Workflow
1. Select theme; collect 3–6 representative received teachings with sources.
2. Identify 1–2 pericopes of Jesus’ public words addressing the theme; verify public setting.
3. Draft tension statement; write 3 reflection prompts and 1 practice.
4. Fact‑check citations; sensitivity read for fairness; legal review for permissions if needed.

## Git Workflow
- Branching
  - main: stable manuscript
  - docs/plan: planning documents
  - chap/<nn>-<slug>: chapter/theme work branches (e.g., chap/01-power)
- Structure
  - manuscript/
    - 00-orientation/
    - 01-power/
    - 02-enemies/
    - ...
  - references/
  - planning/
- File format: Markdown with YAML front matter.
- PR checklist (per spread)
  - Right column PD translation and refs present
  - Public‑only criterion confirmed
  - Left quotes permissions checked or paraphrased
  - 3 prompts + 1 practice included
  - Tension statement neutral and concise

## Front Matter (per spread)
---
slug: power
number: 01
title: Power and Authority
status: draft
right_sources: ["Matt 20:25–28 (ASV)", "Mark 10:42–45 (ASV)"]
left_sources:
  - {title: Denominational Catechism §123, type: quote, permission: pending}
  - {title: Common saying, type: paraphrase}
updated: 2025-10-10
---

## Drafting Definition of Done
- Accurate citations; PD translation confirmed; public‑only validated; prompts and practice field‑tested with 2 readers; copy‑edited.

## Testing/Pilot
- Conduct 2–3 pilot groups (3–6 readers each). Collect feedback on clarity, tone, and usability. Revise spreads with issues tagged and linked in PRs.

## Risks and Mitigations
- Permissions delays → prefer PD/paraphrase; track in references/permissions.csv
- Misclassification of “public” → require dual reviewer sign‑off
- Tone drift toward polemic → enforce tension‑only guideline in review

## Milestones
- M1: Outline finalized (themes + 3 sample spreads)
- M2: 12 core spreads drafted
- M3: Full edit pass + pilot feedback integrated
- M4: Design/layout pass for print/PDF

## Template: Spread Markdown
```
---
slug: <slug>
number: <nn>
title: <Title>
status: draft | review | final
right_sources: ["<Book> <verses> (ASV|KJV|WEB)", ...]
left_sources:
  - {title: <source>, type: quote|paraphrase, permission: ok|pending}
updated: <YYYY-MM-DD>
---

# <Title>

## Received Teaching
> "<Exact quote if PD/permission>"
- Source: <title, author, year>
- Context: <1–2 lines>

## Jesus’ Public Words
> "<PD translation excerpt>"
- Reference: <Gospel and verses>
- Context: <1–2 lines>

## Tension
<One concise sentence naming the contrast>

## Reflection
1. Observe: <prompt>
2. Empathize: <prompt>
3. Act: <prompt>

## Practice
<One micro‑experiment for the week>

## Notes
<citations/footnotes>
```

## Future Enhancements
- Optional sidebars for historical background.
- Digital companion with sources and context notes.
[../manuscript/CHAPTER_00/SPREAD_01.md](Spread 01)
[../manuscript/CHAPTER_00/SPREAD_02.md](Spread 02)
[../manuscript/CHAPTER_00/SPREAD_03.md](Spread 03)