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
| none | any | no status change; lower traceability |
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

## What never changes status

- commit count, LOC, formatting, renames
- `refactor` / `chore` without a REQ status
- agent prose
- dashboard / snapshot files
