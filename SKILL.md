---
name: skill-dashproject
description: Evidence-based project progress auditor (DASHPROJECT). Use when the user asks for DASHPROJECT, requirement map from docs, 0/50/100 progress, measurement precision, commit guidelines, Gantt, or a progress dashboard. Bootstrap writes the requirement ledger from documentation. Incremental review after a 10-minute commit burst only applies declared REQ ids (PLANNED 0, IN_PROGRESS 50, COMPLETED 100). Never invent intra-requirement percentages. Validate the declaration; do not trust the commit blindly.
license: MIT
metadata:
  product: DASHPROJECT
  version: "0.1"
  type: auditor
---

# DASHPROJECT

Independent progress auditor. Progress is **measured**, not estimated.

The requirement is the smallest unit. A requirement is only **0, 50 or 100**. Never 63%.

```
Progress = sum(req.progress) / (count(requirements) * 100)
```

`Measurement Precision` is separate: how reliable that number is (docs, granularity, commit traceability).

`.dashproject/` is an observer, not canonical docs. Coding agents must not edit the ledger to inflate progress.

Read [references/scoring.md](references/scoring.md), [references/ledger.md](references/ledger.md), [references/cycles.md](references/cycles.md), and [references/commit-protocol.md](references/commit-protocol.md) when needed.

## When this skill is active

- First run (`bootstrap`) — write the requirement map from existing documentation
- Progress, precision, dashboard, scope change, gaps
- Pending review after the 10-minute commit burst
- Install hook or inject commit guidelines into `README.md`

## Isolation

- Implementer writes code, tests, official `docs/`, and **declared** commits.
- DASHPROJECT writes only under `.dashproject/` plus a DASHPROJECT section in `README.md` (commit protocol).
- A commit declaration is a **claim**. Apply 0/50/100 only after a short plausibility check.
- If the claim is COMPLETED but there is no plausible implementation in the diff, keep IN_PROGRESS (50) and flag.
- Missing tests do not block 100. They lower confidence and set `verification.tests: pending`.

## Requirement states

| Status | Progress |
|---|---|
| `PLANNED` | 0 |
| `IN_PROGRESS` | 50 |
| `COMPLETED` | 100 |

`verification` (`implementation` / `tests` / `documentation`) is confidence, not percent.

IDs are `REQ-NNN` (stable, never recycled). Prefer IDs already in docs; otherwise assign them once at bootstrap.

## Bootstrap (first job)

Do not start from commits. Start from documentation.

1. Copy templates from `assets/templates/` into `.dashproject/`.
2. Read specs, architecture, ADRs, `docs/**`, README, tests (as hints of what already exists).
3. Write `.dashproject/requirements/requirements.yaml` — one row per testable requirement (a user-visible behavior or a hard infra contract, not "rename variable").
4. For each req, set initial status from evidence already in the tree: existing + tested → COMPLETED; work started → IN_PROGRESS; else PLANNED.
5. Snapshot baseline scope count. Compute progress and measurement precision.
6. Append commit guidelines to project `README.md` (see commit protocol). Do not rewrite the rest of the README.
7. Generate the static dashboard.

Baseline % is "this much of the identified scope is already at 50/100", not "the project started today".

## Incremental (after debounce)

Token budget is the point. Do **not** reread all requirements.

1. Lock. `git log BASE..HEAD` (skip `chore(dashproject)`).
2. Parse each commit for `REQ-…` and `Status: IN_PROGRESS|COMPLETED` (see protocol).
3. For each declared req only: read that ledger row, the commit diff, and the listed source doc if needed.
4. Short validation: does the diff touch files that can belong to that req?
   - yes + IN_PROGRESS → 50
   - yes + COMPLETED + plausible implementation → 100
   - COMPLETED + no plausible implementation → stay previous status (or 50), flag
   - commit with no REQ ids → no progress change; lower commit-traceability for this burst
5. Update those rows' `commits`, `confidence`, `verification`.
6. Recompute overall from the full ledger (cheap arithmetic). Recompute precision.
7. Snapshot, delta, dashboard. Unlock.

`feat` / `fix` may change status. `test` / `docs` only change verification/confidence. `refactor` / `chore` do not change 0/50/100 unless they also declare a req status.

Multiple IDs in one commit are allowed (`feat(REQ-102,REQ-103):`). Discourage unrelated batches (precision penalty if >5 reqs or mixed epics without explanation).

## Scope vs progress

Adding requirements increases the denominator. That is **not** a regression.

Record in the snapshot: `scope.original`, `scope.current`, `scope.added`, `scope.removed`, and explain a drop in % when scope grew.

Removing a req needs an explicit reason in `agent-docs`. Do not delete IDs; mark `withdrawn: true` and exclude from the denominator.

## Measurement precision

Score 0–100 from four factors (see scoring): clarity, granularity, commit traceability, documentation quality. Show it next to progress. A 73% with 57% precision is a weak number.

## Debounce

Commit burst: reset a 10-minute timer on every non-ignored commit; run one incremental over `BASE..HEAD`. Hook scripts only write `pending` + timestamp.

## Layout

```
.dashproject/
  config.yaml
  project.yaml
  baseline/project-baseline.yaml
  requirements/requirements.yaml
  requirements/coverage.yaml
  analysis/latest.yaml
  analysis/history/<iso>.yaml
  analysis/divergences.yaml
  agent-docs/project-state.md
  agent-docs/implementation-map.md
  agent-docs/gap-analysis.md
  dashboard/index.html
  dashboard/data.json
  dashboard/data.js
```

## Commands

- `dashproject init` — bootstrap + README guidelines
- `dashproject review` — incremental
- `dashproject deep` — rediscover reqs / precision only when asked
- `dashproject dashboard` — regenerate from ledger
- `dashproject hook` — install git hook
- `dashproject status` — print progress, precision, scope, delta

## Say this to the user

```
PROGRESS 64.8%   PRECISION 94%
172 COMPLETED · 14 IN_PROGRESS · 101 PLANNED   (287 reqs)
+7 completed this burst   BASE abc123 → HEAD jkl012
scope 287 → 287 (no change)
```

If a COMPLETED claim was rejected, list it. Do not lead with commit counts or LOC.

