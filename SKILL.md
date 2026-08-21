---
name: skill-dashproject
description: Evidence-based project progress auditor (DASHPROJECT). Use when the user asks for DASHPROJECT, requirement map from docs, 0/50/100 progress, completion declared/accepted/rejected, measurement precision, repository activity, git file growth, project pulse, churn, commit guidelines, hook install, dashproject watch, Gantt, or a progress dashboard. Bootstrap is conservative. Incremental review after a 10-minute commit burst only applies declared REQ ids. Status is the source of truth. Progress is derived. File counts are activity, never progress.
license: MIT
metadata:
  product: DASHPROJECT
  version: "0.3"
  type: auditor
---

# DASHPROJECT

Independent progress auditor. Progress is **measured**, not estimated.

The requirement is the smallest unit. A requirement is only **0, 50 or 100**. Never 63%.

```
progress(status) = PLANNED→0 | IN_PROGRESS→50 | COMPLETED→100
Progress = mean(progress(status) for active requirements)
```

Do not store `progress` on the ledger row. Derive it from `status`.

`Measurement Precision` is separate: how reliable that number is (docs, granularity, commit traceability).

`.dashproject/` is an observer, not canonical docs. Coding agents must not edit the ledger to inflate progress.

Read [references/scoring.md](references/scoring.md), [references/ledger.md](references/ledger.md), [references/cycles.md](references/cycles.md), [references/commit-protocol.md](references/commit-protocol.md), and [references/activity.md](references/activity.md) when needed.

Progress and activity are independent. Never raise or lower % because files were added.

## When this skill is active

- First run (`bootstrap`) — write the requirement map from existing documentation
- Progress, precision, dashboard, scope change, gaps
- Repository activity, pulse, churn, file/folder growth
- Pending review after the 10-minute commit burst
- Install hook or inject commit guidelines into `README.md`

## Isolation

- Implementer writes code, tests, official `docs/`, and **declared** commits.
- DASHPROJECT writes only under `.dashproject/` plus a DASHPROJECT section in `README.md` (commit protocol).
- A commit declaration is a **claim**. Status changes only after a short plausibility check.
- COMPLETED without plausible implementation stays at the previous status. Set `completion: rejected` and flag.
- COMPLETED with plausible implementation and tests missing becomes `COMPLETED` + `completion: declared` (still 100).
- COMPLETED with plausible implementation and tests present becomes `completion: accepted`.
- `test`/`docs` commits do not change status. They may upgrade `declared` → `accepted`.

## Requirement states

| Status | Derived progress | Meaning |
|---|---|---|
| `PLANNED` | 0 | Not started (or evidence unknown at bootstrap) |
| `IN_PROGRESS` | 50 | Work started |
| `COMPLETED` | 100 | Behavior treated as done |

On `COMPLETED` also set `completion`:

| completion | Meaning |
|---|---|
| `declared` | Claim accepted as plausible; tests/docs not fully verified |
| `accepted` | Implementation + tests present |
| `rejected` | Claim refused; **do not** leave status as COMPLETED |

`verification` and `confidence` never change the 0/50/100 value.

`evidence.knownness` ∈ `unknown | partial | known` — quality of information, not progress. Bootstrap uses this so a file that merely exists does not become COMPLETED.

IDs are `REQ-NNN` (stable, never recycled). Prefer IDs already in docs; otherwise assign them once at bootstrap.

## Bootstrap (first job)

Do not start from commits. Start from documentation.

1. Copy `config.yaml`, `project.yaml` and `README.md` from `assets/templates/` into `.dashproject/`. `README-COMMIT-GUIDELINES.md` is not copied there — it is appended to the project `README.md` in step 7.
2. Read specs, architecture, ADRs, `docs/**`, README, tests (as hints of what already exists).
3. Write `.dashproject/requirements/requirements.yaml` — one row per testable requirement (a user-visible behavior or a hard infra contract, not a rename).
4. Classify **conservatively** (see scoring). File existence is not COMPLETED.
5. Snapshot baseline scope, progress, precision, and `baseline_confidence`.
6. Run [scripts/collect-activity.py](scripts/collect-activity.py) → `.dashproject/activity/`.
7. Append commit guidelines to project `README.md`. Do not rewrite the rest of the README.
8. Generate the static dashboard (progress + activity). Offer `dashproject hook` and `dashproject watch`.

Baseline % is a conservative reading of already-done scope, not "the project started today". Prefer under-count. Record `baseline_confidence` on that snapshot only.

## Incremental (after debounce)

Token budget is the point. Do **not** reread all requirements.

1. Lock. `git log BASE..HEAD` (skip `chore(dashproject)`).
2. Parse each commit for `REQ-…` and `Status: IN_PROGRESS|COMPLETED` (see protocol).
3. For each declared req only: read that ledger row, the commit diff, and the listed source doc if needed.
4. Short validation against the diff only (see scoring). Apply status + `completion`. Never write a `progress` field.
5. Update `commits`, `verification`, `evidence.knownness`, `confidence`.
6. Recompute overall from statuses. Recompute precision.
7. Run `collect-activity.py` (git only). Merge into the dashboard. Do not ask the implementer how many files they created.
8. Snapshot, delta, dashboard. Unlock. Remove `pending` / `review-due` after a successful review.

`feat` / `fix` may change status. `test` / `docs` only change verification/confidence. `refactor` / `chore` do not change 0/50/100 unless they also declare a req status.

Multiple IDs in one commit are allowed (`feat(REQ-102,REQ-103):`). Discourage unrelated batches (precision penalty if >5 reqs or mixed epics without explanation).

## Scope vs progress

Adding requirements increases the denominator. That is **not** a regression.

Record in the snapshot: `scope.original`, `scope.current`, `scope.added`, `scope.removed`, and explain a drop in % when scope grew.

Removing a req needs an explicit reason in `agent-docs`. Do not delete IDs; mark `withdrawn: true` and exclude from the denominator.

## Measurement precision

Score 0–100 from four factors (see scoring): clarity, granularity, commit traceability, documentation quality. Show it next to progress. A 73% with 57% precision is a weak number.

## Debounce and watch

Commit burst: reset a 10-minute timer on every non-ignored commit; one incremental over `BASE..HEAD`.

- Hook writes `pending` + timestamp only. It never calls a model.
- Install with [scripts/install-git-hook.sh](scripts/install-git-hook.sh) — inserts a marked block; does not replace an existing hook.
- Optional [scripts/watch.sh](scripts/watch.sh) (`dashproject watch`) polls until debounce elapses, then writes `review-due`. On Debian, install the user systemd unit from `assets/templates/dashproject-watch.service`.
- A Claude Code / agent session that sees `review-due` or `pending-ready.sh` exit 0 must run `dashproject review`. The watcher does not invoke the LLM.

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
  activity/repository.json
  activity/history/YYYY-MM-DD.json
  agent-docs/project-state.md
  agent-docs/implementation-map.md
  agent-docs/gap-analysis.md
  dashboard/index.html
  dashboard/data.json
  dashboard/data.js
```

Written by the hook and the watcher, not by the model: `pending`,
`last-commit-ts`, `review-due`, plus executable copies of `watch.sh`,
`pending-ready.sh` and `collect-activity.py`.

## Commands

- `dashproject init` — bootstrap + README guidelines
- `dashproject review` — incremental
- `dashproject deep` — rediscover reqs / precision only when asked
- `dashproject dashboard` — regenerate from ledger + activity
- `dashproject hook` — install or refresh the marked post-commit block
- `dashproject watch` — start the debounce watcher (optional, no LLM)
- `dashproject activity` — refresh git activity only
- `dashproject status` — print progress, precision, completion breakdown, scope, pulse

## Say this to the user

```
PROGRESS 62.4%   PRECISION 94%
172 COMPLETED (151 accepted / 21 declared) · 14 IN_PROGRESS · 101 PLANNED
+7 completed this burst   BASE abc123 → HEAD jkl012
scope 287 → 287
PULSE  1842 files  +310 this week  71 commits  churn 859
rejected: REQ-118 (diff unrelated)
```

On bootstrap also print `baseline_confidence`. Do not lead with commit counts or LOC.

