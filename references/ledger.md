# Requirement ledger

Source of progress. Lives only in `.dashproject/`. `status` is the source of truth; do not persist `progress`.

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
    withdrawn: false
    evidence:
      knownness: partial
    commits: [jkl012]
    verification:
      implementation: partial
      tests: pending
      documentation: pending
    confidence: 91
    notes: ""
```

Completed, declared vs accepted:

```yaml
  - id: REQ-101
    status: COMPLETED
    completion: declared
    evidence:
      knownness: partial
    verification:
      implementation: verified
      tests: pending
      documentation: pending

  - id: REQ-100
    status: COMPLETED
    completion: accepted
    evidence:
      knownness: known
    verification:
      implementation: verified
      tests: verified
      documentation: verified
```

Rejected claims live on the snapshot (`rejected_claims`), not as `status: COMPLETED`.

IDs: `REQ-NNN`, stable. Withdrawn rows stay with `withdrawn: true` and leave the denominator.

## coverage.yaml

Rollup only. Here `progress` is derived.

```yaml
totals:
  active: 287
  completed: 172
  completed_accepted: 151
  completed_declared: 21
  in_progress: 14
  planned: 101
  unknown_evidence: 40
  withdrawn: 0
progress: 64.8
precision:
  overall: 91
  clarity: 92
  granularity: 95
  traceability: 88
  documentation: 89
```

## analysis/latest.yaml

```yaml
snapshot: 22
level: incremental
model: sonnet
base: abc123
head: jkl012
progress: 64.8
precision: 91
baseline_confidence: null    # set only on the bootstrap snapshot
scope:
  original: 287
  current: 287
  added: 0
  removed: 0
counts:
  completed: 172
  completed_accepted: 151
  completed_declared: 21
  in_progress: 14
  planned: 101
rejected_claims:
  - { id: REQ-118, declared: COMPLETED, reason: "diff does not touch billing" }
```

Copy to `analysis/history/YYYY-MM-DDTHH-MM.yaml`.

## Reality Map

`implementation-map.md` — what the code is.
`gap-analysis.md` — planned vs completed vs rejected vs unknown evidence.
`project-state.md` — progress, precision, completion split, baseline_confidence if present, top flags.
