# Scoring

Do not invent a second system. Progress is discrete. Precision is separate.

## Requirement progress

Only three values:

| status | progress |
|---|---|
| PLANNED | 0 |
| IN_PROGRESS | 50 |
| COMPLETED | 100 |

Never 63, 70, or 80. Verification does not change these numbers.

## Project progress

```
progress = sum(r.progress for r in active) / (n_active * 100) * 100
```

`active` = requirements with `withdrawn != true`.

Epic progress uses the same formula on that epic's subset.

## Status transitions

Allowed: PLANNED → IN_PROGRESS → COMPLETED. Backward only with an explicit flag (`regression: true`) when a later burst shows the implementation was removed.

A commit may skip PLANNED → COMPLETED in one shot if validation accepts COMPLETED.

## Validation vs percent

| Check | If it fails |
|---|---|
| Diff unrelated to the declared REQ | do not apply the new status; flag |
| COMPLETED but no plausible implementation | keep prior status (usually 50); flag |
| COMPLETED but tests missing | accept 100; `verification.tests: pending`; lower confidence |
| COMPLETED but official docs missing | accept 100; `verification.documentation: pending`; lower confidence |
| IN_PROGRESS with a related diff | accept 50 |

## Per-requirement confidence (0–100)

```
confidence =
  40 * (declaration_plausible) +
  25 * (implementation_pointer) +
  20 * (tests_present_or_passing) +
  15 * (docs_mention_req)
```

Subtract 15 if this session wrote the code being scored. Floor 5.

`verification.implementation|tests|documentation` ∈ `pending | partial | verified`.

## Measurement precision (project)

Four factors, equal weight unless `project.yaml` overrides:

1. **Requirement clarity** — titles are testable behaviors; source pointers exist.
2. **Granularity** — not too coarse (one req = a whole product) and not too fine (one req = a rename). Target: a req is completable in a small burst of commits.
3. **Commit traceability** — share of recent commits (last snapshot window + last 20) that cite `REQ-` and a status.
4. **Documentation quality** — official docs exist, are structured, and map to ledger sources.

Each factor 0–100. Overall precision = mean.

High precision needs both many well-cut requirements **and** commits that cite them. Vague docs + generic commits → low precision even if progress arithmetic is exact.

## Delta and scope

Delta is change in `progress` and in counts (completed / in_progress / planned).

If `n_active` grew, say so. A drop caused by new requirements is a **scope change**, not a regression.

Regressions are only status moving backward on the same id.

## What never changes progress

- commit count, LOC, files created
- TODO removal, formatting, renames
- `refactor` / `chore` without a REQ status
- `test` / `docs` without COMPLETED/IN_PROGRESS
- agent prose ("implemented successfully")
- dashboard / snapshot files
