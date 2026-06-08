---
name: ggplot-hourglass
description: >-
  Unified hourglass skill fusing ggplot-skills, scientific-plotting-skill,
  awesome-rosetta data-visualization, and agent-figure-gallery into one funnel.
  Use when the user asks to visualize a table or xlsx, plot for a manuscript or
  journal PDF, review or fix a ggplot figure, pick reference styles from a gallery,
  or export publication PNG/PDF from R (ggplot2) or Python (matplotlib/seaborn).
  Routes via waist record (mode, data, chart, delivery, stack, overlay), T0 profile,
  T1 BIND gate, belt overlays, and leaf pointers — not four parallel skills.
---

# ggplot Hourglass — Four-Skill Unified Funnel

One **hourglass**, four upstream repos as **belt / stack branch / mode branch / R leaves**.

| Upstream | Role in funnel | Trigger |
|----------|----------------|---------|
| **ggplot-skills** | Primary R positive-tree leaves + review checklist | `stack=r`, modes explore/manuscript/review |
| **scientific-plotting-skill** | Belt overlay (not a second funnel) | `mode=manuscript` or paper/PDF keywords |
| **rosetta data-visualization** | Python stack branch + journal size table | `stack=python` |
| **agent-figure-gallery** | Gallery mode entire positive branch | `mode=gallery` |

## When to use

- Visualize table / xlsx / dataframe → **explore**
- Manuscript, journal, thesis PDF figure → **manuscript** + scientific belt
- Fix plot, review aesthetics, publication readiness → **review** (short path)
- Reference style, gallery, Nature-like look → **gallery** (STOP for human select)
- Python / matplotlib / seaborn figure → **explore** + `stack=python`

## Do not

- Load all four upstream SKILL files every turn — open **one leaf** after BIND
- Silent fork bar vs heatmap — run **BIND** (Γ → δ → commit) and log assumptions
- Enable scientific belt on pure explore unless user asks for paper/PDF
- Run gallery render before human **select** in gallery mode

---

## Phase pipeline (single funnel)

```text
Inverse tree   utterance → waist.mode (+ stack, overlay)
T0 profile     columns/types → waist.data
T1 BIND ★       Γ(data) → δ default → commit → waist.chart + leaf
Belt           overlay scientific-plotting if manuscript
T2 STOP        gallery only — until prefer/select
T3 render      one leaf from upstream repo
T4 review      checklist path (review mode)
```

**BIND locus**: `T1 × Z2` — chart type is decided here, not in inverse tree.

---

## Step 1 — Inverse tree (entries)

Map user phrase → waist fields using `hourglass-waist-registry.yaml` → `entries`.

| Entry id | Typical phrase | → waist |
|----------|----------------|---------|
| `visualize_table` | visualize this table | mode=explore |
| `plot_xlsx` | plot xlsx | mode=explore |
| `eda` | EDA / quick look | mode=explore |
| `ggplot` | ggplot / R plot | mode=explore, stack=r |
| `manuscript_figure` | manuscript PDF | mode=manuscript, overlay=scientific |
| `journal_pdf` | journal figure | mode=manuscript, overlay=scientific |
| `plot_for_paper` | plot for paper | mode=manuscript, overlay=scientific |
| `fix_this_plot` / `fix_plot` | fix this plot | mode=review |
| `review_figure` | review figure | mode=review |
| `pick_reference_style` / `pick_style` | gallery / reference style | mode=gallery |
| `nature_style` | Nature style | mode=gallery |
| `python_figure` | python figure | mode=explore, stack=python |
| `comorbidity_heatmap` | comorbidity heatmap | mode=explore, chart=heatmap (P0) |

**Mutex**: keywords `manuscript`, `journal`, `paper`, `thesis`, `PDF` → `mode=manuscript` wins over explore.

Full alias table: `references/inverse-entries.md`

---

## Step 2 — T0 profile → `waist.data`

| Profile | Detection | Default chart family |
|---------|-----------|----------------------|
| `threshold-categorical` | Ordered bins, TSB tiers, severity bands | bar, heatmap |
| `discrete-heavy` | Many low-cardinality factors | bar, stacked-bar |
| `continuous` | Numeric axes, distributions | scatter, box, violin |
| `binary-matrix` | 0/1 comorbidity grid | heatmap |

Log inferred profile; state assumptions if x/y not specified.

---

## Step 3 — T1 BIND (Γ → δ → commit)

Skip if `mode=review`. Defer chart commit if `mode=gallery` until after gallery select.

| `waist.data` | Γ allow | δ default | Deny |
|--------------|---------|-----------|------|
| threshold-categorical | bar, heatmap | bar-template | scatter-raw |
| discrete-heavy | bar, stacked-bar | bar-template | — |
| continuous | scatter, box, violin | scatter-repel | — |
| binary-matrix | heatmap | heatmap-tile | — |

**P0 override**: user words like comorbidity / matrix / heatmap → heatmap even on threshold data.

On commit set `waist.chart` and resolve **leaf** (see registry `leaves`).

---

## Step 4 — Positive tree by mode

### explore (long)

T0 → T1 BIND → T3 render → leaf  
- `stack=r` → `ggplot-skills/SKILL_ggplot.md` § matching template  
- `stack=python` → `awesome-rosetta-skills/.../data-visualization/SKILL.md` § Fig1/2/3  
- delivery default: `png-dpi-800`

### manuscript (medium)

T0 → T1 BIND → **belt scientific** → T3 render  
- Merge `scientific-plotting-skill/SKILL.md`: no title, 85 mm PDF, Wong ≤8, viridis quantile, parameter block  
- delivery default: `pdf-mm-85`

### review (short)

T4 → `ggplot-skills/SKILL_ggplot.md` § Figure Review Checklist only (skip BIND unless user requests geom change)

### gallery (longest + STOP)

T1 query → T2 gallery serve → **STOP until select** → T3 bundle → render  
- `AgentFigureGallery/skills/agent-figure-gallery/SKILL.md` workflow  
- delivery: `bundle-only` then render from bundle

Details: `references/positive-paths.md`

---

## Step 5 — Open exactly one leaf

| Leaf id | Upstream file |
|---------|---------------|
| bar-template | `ggplot-skills/SKILL_ggplot.md` § Bar Chart with Error Bars |
| scatter-repel | § Scatter Plot with Labels |
| box-jitter | § Box Plot with Points |
| heatmap-tile | § Heatmap |
| review-checklist | § Figure Review Checklist |
| fig1-scatter / fig2-violin / fig3-multipanel | rosetta `data-visualization/SKILL.md` |
| gallery-bundle | agent-figure-gallery `SKILL.md` § Minimal Workflow |

Paths relative to `blog1-ggplot2/`.

---

## Required log (create / render paths)

```text
[hourglass] funnel=ggplot-hourglass-unified
[inverse]  entry=<id> → mode=<>, stack=<>, overlay=<>
[T0]       data=<profile>
[BIND T1]  Γ allow=[...] δ=<default> → chart=<>, leaf=<>
[belt]     overlay=<none|scientific-plotting>
[T3]       leaf=<path § section> | delivery=<>
```

---

## Default example (vague “visualize this table”, threshold xlsx)

```yaml
entry: visualize_table
waist:
  mode: explore
  data: threshold-categorical
  chart: bar-template
  delivery: png-dpi-800
  stack: r
  overlay: []
leaf: ggplot-skills/SKILL_ggplot.md § Bar Chart with Error Bars
assumption: "No x/y specified; default tier × severity bar chart"
```

---

## Canonical docs & visualization

| Asset | Purpose |
|-------|---------|
| `../hourglass-waist-registry.yaml` | Machine-readable entries, Γ, leaves |
| `../hourglass-unified-funnel.md` | Master mermaid diagram |
| `../hourglass-skill-architecture.md` | Architecture theory |
| `../hourglass-graph-viewer.html` | **Full interactive graph** (regenerate via `tools/open-graph-viewer.ps1`) |
| `../hourglass-chart-selection.html` | **ggplot2 chart type selection** (BIND flow · `tools/open-chart-selection.ps1`) |
| `../hourglass-graph-viz-readme.md` | CSV source + rebuild HTML viewer |
| `references/` | Routing tables for agents |

**Refresh visualization**:

```powershell
powershell -File e:\HDAT9800\blog1-ggplot2\tools\refresh-hourglass-viz.ps1
```

---

## Reference files

- `references/inverse-entries.md` — all utterance aliases
- `references/bind-gamma.md` — Γ / δ / conflict matrix
- `references/positive-paths.md` — four mode roots
- `references/upstream-roles.md` — what each repo owns
