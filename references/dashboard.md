# Dashboard projection contract

The snapshot is the only source. `data.js`, `data.json` and the Markdown under
`agent-docs/` are **projections** of it. None of them computes a percentage, an
average or a count on its own. A field name that differs from the snapshot is a
projection bug, not a style choice.

Read this on `dashproject dashboard`, and whenever a review regenerates the
dashboard.

## Sources

| Source | Provides |
|---|---|
| `analysis/latest.yaml` | progress, precision, scope, counts, delta, rejected_claims, regressions, base/head, level, model, snapshot |
| `requirements/coverage.yaml` | precision factors, coverage counters, totals |
| `activity/repository.json` | everything under `activity` (written by `collect-activity.py`, never by the model) |
| `requirements/requirements.yaml` | epic rollup, timeline |

## Field map — `data.js`

`data.js` is what `index.html` loads. It assigns `window.DASHPROJECT_DATA`.

| `data.js` key | Comes from | Note |
|---|---|---|
| `project` | `project.yaml` → `project.name` | |
| `generated` | snapshot write time, ISO 8601 | |
| `snapshot` | `latest.yaml` → `snapshot` | integer, monotonic |
| `base` / `head` | `latest.yaml` → `base` / `head` | short SHAs, `null` on bootstrap |
| `level` | `latest.yaml` → `level` | `bootstrap` \| `incremental` \| `deep` |
| `model` | `latest.yaml` → `model` | |
| `progress` | `latest.yaml` → `progress` | **copied, never recomputed** |
| `precision` | `coverage.yaml` → `precision.overall` | |
| `precision_factors` | `coverage.yaml` → `precision.{clarity,granularity,traceability,documentation}` | flattened; the nesting differs on purpose — this row is the mapping |
| `scope` | `latest.yaml` → `scope` | `{original, current, added, removed}` |
| `delta` | `latest.yaml` → `delta` | `{progress, completed, started}` vs the previous snapshot |
| `counts` | `latest.yaml` → `counts` + `coverage.yaml` → `totals.active` | `active` comes from coverage |
| `baseline_confidence` | `latest.yaml` → `baseline_confidence` | `null` outside the bootstrap snapshot |
| `epics` | derived from `requirements.yaml` | see **Epic rollup** |
| `timeline` | derived from `requirements.yaml` + git | see **Timeline** |
| `divergences` | `analysis/divergences.yaml` | |
| `rejected_claims` | `latest.yaml` → `rejected_claims` | claims refused in this burst |
| `regressions` | `latest.yaml` → `regressions` | **reserved** — no producer yet |
| `history` | `analysis/history/*.yaml` | **reserved** — no producer yet |
| `activity` | `activity/repository.json`, verbatim | plus `week.requirements_completed` and `week.requirements_started` from the snapshot |

`week.requirements_completed` and `week.requirements_started` are the only keys
the model adds under `activity`. Everything else there is git output — never
edit it by hand.

## `data.json`

Same snapshot, plain JSON, for consumption by other tools. Written in the same
step as `data.js`. It carries the stable subset: `project`, `generated`,
`snapshot`, `progress`, `precision`, `scope`, `counts`, `epics`.

The dashboard does **not** load it. On divergence, `analysis/latest.yaml`
decides.

## Reserved fields

`regressions` and `history` have a schema and no producer. Keep them present
and empty. Do not remove them, and do not fill them with placeholder data — a
reader must be able to tell "no regressions this burst" from "this version does
not compute regressions".

## The `why` line

The hero carries one KPI plus the arithmetic that produced it. This exists to
answer "why this number?" — it is auditability, not decoration.

```
62.4% = (172 × 100 + 14 × 50 + 101 × 0) / 287. Precision 91%. 151 accepted / 21 declared.
```

Never render a progress figure without the terms that produce it.

`baseline_confidence` does not belong in the hero. It goes in
`analysis/latest.yaml` and in one line of `agent-docs/project-state.md`.

## Epic rollup

An epic is a grouper, not a weight. Its progress is the mean of the derived
progress of the **active** requirements carrying that `epic:` — the same
formula as the project, over a subset.

An epic never has its own weight, and epic progress never feeds the project
figure: the project figure is computed once, over all active requirements.

## Timeline

Retrospective, derived from git — see
[ADR-0008](../docs/adr/0008-timeline-retrospectiva.md).

- start: first commit declaring the requirement `IN_PROGRESS`
- end: the commit or snapshot marking it `COMPLETED`
- a requirement with no commit does not appear
- `due` may be drawn as a marker; it never enters a computation

There is no forecast, no velocity, no projected completion date. Until the git
derivation exists, `timeline` stays `[]` and the section renders empty. Empty
is the correct state, not a defect.

## Invariants

1. No projection recomputes a number. Copy it.
2. A new field in `index.html` requires a field in the snapshot first.
3. A field with no producer is marked reserved here.
4. `activity` is git output. The model never writes counts into it.
