---
name: hourglass-skill-merge-skill
description: >-
  Meta-architecture for merging multiple conflicting Cursor Agent Skills into one
  hourglass funnel—inverse tree (utterance → waist), weak-convergence waist record,
  BIND commit gate, belt overlays, positive tree to leaf pointers. Use when the user
  asks to merge, fuse, or combine skills; design hourglass / funnel / waist routing;
  resolve parallel skill conflicts; or build a registry plus thin fused SKILL.md.
  Reference case: blog1-ggplot2/ggplot-hourglass. Not for single-skill edits or
  upstream SKILL body rewrites.
---

# Hourglass Skill Merge — Meta Architecture

Merge **N upstream skills** into **one Cursor entry** without concatenating their bodies.

**Reference implementation (ggplot, four repos):** `blog1-ggplot2/ggplot-hourglass/SKILL.md`  
**Full theory (Chinese):** `blog1-ggplot2/hourglass-skill-architecture.md`  
**Registry example:** `blog1-ggplot2/hourglass-waist-registry.yaml`

---

## When to use this skill

| Use hourglass merge | Skip hourglass |
|---------------------|----------------|
| 2+ skills trigger on overlapping utterances | Single skill, one path |
| Conflicting deliverables (PDF vs PNG, CLI vs template) | No routing ambiguity |
| Need maintainer-visible map (triggers, decisions, leaves) | Prose + description is enough |
| Human-in-the-loop branch (gallery, approval STOP) | Linear checklist only |

---

## What fusion produces (three layers)

| Layer | What | Relation to upstream |
|-------|------|---------------------|
| **Linked** | Upstream `SKILL.md`, scripts, templates | **Not copied**; leaf points to `§` section |
| **Merged** | Thin fused `SKILL.md` + `references/` + **registry YAML** | **New** routing protocol (~hundreds of lines) |
| **Meta** | Architecture `.md`, funnel diagrams, HTML viewer | Maintainer map; optional |

**Mount ≠ read all:** registry lists all upstream skills; Agent opens **one leaf after commit**, never loads every upstream body each turn.

Fusion is **not just an index**. It adds: mode taxonomy, staged waist commit, BIND/Γ, belt, mutex, conflict matrix, STOP/skip_bind, funnel log.

Details: `references/merged-vs-linked.md`

---

## Hourglass topology (one funnel)

```text
        ╱  Inverse tree: utterance → waist fields (wide → narrow)  ╲
                        ▼  Waist record (weak convergence)
        ╱  Positive tree: waist → one leaf pointer (narrow → wide)  ╲
        Belt (orthogonal overlays, not a fifth funnel)
```

| Segment | Decides |
|---------|---------|
| **Inverse tree** | Task class (`mode`), stack, overlay hints; alias many phrases → one field |
| **Waist** | Structured record; fields commit at phases (not one mega-enum) |
| **BIND gate** | Critical cross-skill decision (e.g. chart type after data profile) |
| **Positive tree** | Which upstream section / CLI to open |
| **Leaf** | Deliverable lives in **linked** upstream file |

Layers cheat sheet: `references/waist-layers.md`

---

## Merge workflow (Agent steps)

### 1. Inventory upstream skills

For each skill read `SKILL.md` (+ description):

- Trigger phrases / description overlap with others?
- Deliverable type (template, belt rules, CLI workflow, review checklist)?
- Exclusive paths (human STOP, skip main pipeline)?

Assign **one role** per upstream (not all primary):

| Role | Meaning | Example (ggplot case) |
|------|---------|------------------------|
| `primary_positive_tree` | Default leaves | ggplot-skills |
| `belt_overlay` | Cross-cutting rules; no chart pick | scientific-plotting |
| `stack_branch` | Conditional fork (language, stack) | rosetta @ `stack=python` |
| `mode_workflow` | Own positive root + STOP | agent-figure-gallery |

### 2. Design waist record (single funnel preferred)

Use **one** waist record with field layers (Z0–Z3), not one file per upstream repo:

```yaml
# Logical fields (rename for domain)
mode:      # Z0 — inverse tree
data:      # Z1 — after profile/T0
chart:     # Z2 — after BIND (nullable until commit)
delivery:  # Z3 — export / bundle
stack:     # optional fork
overlay: [] # belt ids
```

Prefer **one unified funnel** over four parallel funnel files when skills share one domain.

### 3. Write registry (`hourglass-waist-registry.yaml`)

Skeleton: `references/registry-skeleton.yaml`

Required sections:

- `entries` — utterance alias → waist fields; `priority: P0` for explicit overrides
- `mutex` — winner when fields conflict
- `gamma` (or domain Γ) — feasibility constraints before commit
- `positive_roots` — per-mode phases; `skip_bind`, `stop_until`
- `skills` — upstream role + path
- `leaves` — registry id → `upstream/SKILL.md § Section`
- `conflict_matrix` — cross-mode field allow/deny

### 4. Thin fused `SKILL.md`

- YAML `description`: fused triggers only; mention waist + BIND + single leaf
- **Do not** paste upstream bodies
- Pipeline: inverse → T0 → BIND → belt → render / STOP
- **Do not load all upstream SKILL files every turn**

### 5. Split references (progressive disclosure)

Copy pattern from `ggplot-hourglass/references/`:

- `inverse-entries.md` — alias table
- `upstream-roles.md` — fusion map
- `bind-gamma.md` — Γ, δ, conflict matrix
- `positive-paths.md` — mode depths

### 6. Visualize (maintainer)

- Master funnel diagram (Mermaid or HTML)
- Optional BIND decision diagram
- Diagram is **maintainer's map**, not the agent's only spec

Refresh ggplot example: `powershell -File blog1-ggplot2/tools/refresh-hourglass-viz.ps1`

### 7. Register for Cursor

Project stub: `.cursor/skills/<fused-name>/SKILL.md` → pointer to full skill under `blog1-ggplot2/` or project path.

---

## Correctness (not "AI guarantees")

| Mechanism | Ensures |
|-----------|---------|
| Leaf pointers | Deliverable traceable to upstream `§`; diff when upstream changes |
| Registry as source of truth | Human-reviewable routes |
| BIND: Γ → δ → commit | No silent fork between valid alternatives |
| Funnel log | `[inverse]` → `[T0]` → `[BIND]` → `[leaf]` replay |
| STOP / skip_bind | Gallery/review paths cannot wrong-commit |
| Stated assumptions | Default path written in output |
| Walkthrough example | One domain case as regression narrative |

Registry drift breaks correctness — sync leaves when upstream renames sections.

---

## Multi-path policy (fuse / kill / dual-track)

| Situation | Policy |
|-----------|--------|
| Same waist, same leaf | **Fuse** — entry alias table |
| Rule conflict | **Kill** — mutex or deny in conflict matrix |
| Different deliverables, wrong default | **Dual-track** — one question or STOP |
| Strict special case of another | Merge as default params |
| Overlay without trigger | **Kill** silent overlay |

Anti-patterns: `references/anti-patterns.md`

---

## Trade-off (tell the user when relevant)

Hourglass **helps** maintainers and multi-skill routing; **costs** Agent steps and registry upkeep.

- **Functionality:** thin entry defers upstream prose → one leaf after commit
- **Visualization:** triggers, BIND, leaves on one diagram
- Simple single-chart tasks may be better with one upstream skill only

---

## Related skills

| Skill | Role |
|-------|------|
| `ggplot-hourglass` | Domain-fused instance (four plotting repos) |
| `hourglass-skill-merge-skill` | This meta skill — design any hourglass merge |

Blog narrative: `blog1-ggplot2/blog1-content-plan.md` §2.1, §5, §7.
