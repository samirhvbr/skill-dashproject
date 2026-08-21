# Requirement ledger

Source of progress. Lives only in `.dashproject/`.

## requirements.yaml

```yaml
version: 1
updated: 2026-08-21T15:18:00-03:00
project: shvia
scope:
  original: 287
  current: 287
requirements:
  - id: REQ-102
    title: Emissão de boleto
    epic: finance
    source:
      - path: docs/financeiro.md
        line: 42
    status: IN_PROGRESS
    progress: 50
    withdrawn: false
    commits: [jkl012]
    verification:
      implementation: partial
      tests: pending
      documentation: pending
    confidence: 91
    notes: ""
```

Completed example:

```yaml
  - id: REQ-102
    status: COMPLETED
    progress: 100
    verification:
      implementation: verified
      tests: verified
      documentation: verified
    confidence: 98
```

IDs: `REQ-NNN`, stable. Withdrawn rows stay in the file with `withdrawn: true` and are excluded from the denominator.

## coverage.yaml

```yaml
totals:
  active: 287
  completed: 172
  in_progress: 14
  planned: 101
  withdrawn: 0
progress: 64.8
precision:
  overall: 94
  clarity: 92
  granularity: 95
  traceability: 97
  documentation: 89
epics:
  finance: { n: 40, completed: 22, in_progress: 3, planned: 15, progress: 58.8 }
```

## analysis/latest.yaml

```yaml
snapshot: 22
timestamp: 2026-08-21T15:18:00-03:00
level: incremental
model: sonnet
base: abc123
head: jkl012
commits_in_burst: 4
progress: 64.8
precision: 94
scope:
  original: 287
  current: 287
  added: 0
  removed: 0
counts:
  completed: 172
  in_progress: 14
  planned: 101
delta:
  progress: 3.6
  completed: 7
  started: 3
rejected_claims:
  - { id: REQ-118, declared: COMPLETED, reason: "diff does not touch billing" }
regressions: []
```

Copy to `analysis/history/YYYY-MM-DDTHH-MM.yaml`.

## divergences.yaml

Flags only (do not invent extra percents):

- `rejected_completed`
- `untraced_commit`
- `unexpected_work` (code with no REQ)
- `scope_added` / `scope_removed`
- `docs_stale`
- `regression`

## Reality Map

`implementation-map.md` — what the code is, by epic.
`gap-analysis.md` — planned vs completed vs rejected claims.
`project-state.md` — one page: progress, precision, scope, top flags.
