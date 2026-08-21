# Scoring

Status is the source of truth. Progress is derived. Precision is separate.

## Derived progress

| status | progress |
|---|---|
| PLANNED | 0 |
| IN_PROGRESS | 50 |
| COMPLETED | 100 |

Never store `progress` on a requirement row. Never invent 63, 70, or 80.

```
Progress = mean(derived_progress(r.status) for r in active)
```

`active` = `withdrawn != true`.

## Completion (only when deciding COMPLETED)

| completion | status | progress |
|---|---|---|
| accepted | COMPLETED | 100 |
| declared | COMPLETED | 100 |
| rejected | previous (usually IN_PROGRESS) | 0 or 50 |

Rejected must not remain `status: COMPLETED`.

## Incremental validation

| Claim | Diff | Result |
|---|---|---|
| IN_PROGRESS | related files | status IN_PROGRESS |
| COMPLETED | no plausible implementation | reject; keep previous status |
| COMPLETED | implementation plausible, tests absent | COMPLETED + declared |
| COMPLETED | implementation + tests | COMPLETED + accepted |
| none, single REQ in subject | related files | status IN_PROGRESS (see commit-protocol) |
| no REQ at all | any | no status change; lower traceability |
| test/docs only | cites REQ | verification only; may upgrade declared → accepted |

## Conservative bootstrap

Do **not** treat file existence as done.

| Evidence | status | knownness | completion |
|---|---|---|---|
| Source + implementation that matches the req **and** tests that cover it | COMPLETED | known | accepted |
| Implementation files clearly for this req, tests missing or weak | IN_PROGRESS | partial | — |
| Name coincidence, similar path, or only a mention in docs | PLANNED | unknown | — |
| Nothing in the tree | PLANNED | unknown | — |

Prefer IN_PROGRESS over COMPLETED. Prefer PLANNED + unknown over IN_PROGRESS when unsure.

`baseline_confidence` (bootstrap snapshot only), 0–100:

```
40 * (share of reqs with source pointers) +
30 * (share classified known or partial, not unknown) +
20 * (share of COMPLETED that have tests) +
10 * (docs are structured)
```

This is not precision and not progress.

## Per-requirement confidence (0–100)

```
confidence =
  40 * (declaration_or_bootstrap_plausible) +
  25 * (implementation_pointer) +
  20 * (tests_present) +
  15 * (docs_mention_req)
```

Subtract 15 if this session wrote the code. Floor 5.

## Measurement precision

Defaults (override in `config.yaml`):

| Factor | Weight |
|---|---|
| clarity | 25 |
| granularity | 20 |
| commit traceability | 35 |
| documentation quality | 20 |

Traceability is the most important factor for incremental reviews.

Each factor is scored from the counters in `coverage.yaml`, not by impression:

| Factor | Scored from |
|---|---|
| clarity | share of active reqs with a `source` pointer into docs |
| granularity | share of active reqs that are a single testable behavior — penalise reqs spanning a whole module, and renames |
| traceability | share of active reqs cited by at least one commit (`cited_in_commit / active`) |
| documentation | share of active reqs whose source doc exists and is structured |

## Regression

A requirement that was `COMPLETED` in `analysis/history` and no longer is gets
recorded in `latest.yaml` → `regressions`.

Three things that look alike and are not:

| | What it is |
|---|---|
| `regressions` | a req lost COMPLETED across snapshots |
| `rejected_claims` | a claim refused inside this burst; status never became COMPLETED |
| scope growth | denominator grew; the percentage fell and **nothing regressed** |

Never fold the third into the first.

## What never changes status

- commit count, LOC, formatting, renames
- `refactor` / `chore` without a REQ status
- agent prose
- dashboard / snapshot files
