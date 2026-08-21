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
      implementation: [app/Finance/Boleto.php]
      tests: []
      docs: [docs/financeiro.md]
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

`evidence.implementation`, `evidence.tests` and `evidence.docs` are repo-relative
paths. They are what makes the auditor auditable — and they are where
[scoring.md](scoring.md) reads `implementation_pointer` and `tests_present`
from. Without them that formula scores a pointer the schema cannot hold.

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
coverage:
  with_source: 281
  cited_in_commit: 252
  with_implementation_pointer: 186
  with_tests: 151
progress: 62.4
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
progress: 62.4
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
delta:
  progress: 1.4
  completed: 7
  started: 2
rejected_claims:
  - { id: REQ-118, declared: COMPLETED, reason: "diff does not touch billing" }
regressions: []      # reserved — no producer yet
epics: []
```

`delta` compares against the previous snapshot. `regressions` has a schema and
no producer; keep it present and empty rather than removing it (see
[dashboard.md](dashboard.md)).

## divergences.yaml

Expected (docs) versus actual (code). One row per gap.

```yaml
version: 1
divergences:
  - requirement: REQ-118
    type: partial
    intended: "Cancel emits a webhook"
    actual: "Cancel updates status only"
    detected_at: 2026-08-21T15:18:00-03:00
```

`type` ∈ `missing` | `partial` | `unexpected_implementation`.
`spec_drift` and `doc_drift` are reserved for the drift version.

## Epic rollup

An epic is a grouper, never a weight. Epic progress is the mean of the derived
progress of the active requirements carrying that `epic:` — the same formula as
the project, over a subset. It never feeds the project figure.

Copy to `analysis/history/YYYY-MM-DDTHH-MM.yaml`.

## Reality Map

These three files are a **closed list**. Do not add a fourth.

`implementation-map.md` — what the code is.
`gap-analysis.md` — planned vs completed vs rejected vs unknown evidence, and
the reason for every `withdrawn` or added requirement. Scope justification
lives here; it does not get its own file.
`project-state.md` — progress, precision, completion split, baseline_confidence
if present, top flags. This is the human entry point that renders on GitHub.
