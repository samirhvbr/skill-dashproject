# Commit protocol

This is how coding agents declare work so incremental review stays cheap.

On bootstrap, append [assets/templates/README-COMMIT-GUIDELINES.md](../assets/templates/README-COMMIT-GUIDELINES.md) to the project `README.md` if that section is missing. Do not replace the rest of the README.

## Subject

```
<type>(REQ-102): short description
<type>(REQ-102,REQ-103): short description
```

Types: `feat` `fix` `test` `docs` `refactor` `chore`.

Avoid mixing many unrelated IDs. Prefer ≤3; >5 is a precision penalty.

## Body (required for feat/fix that change status)

```
Requirements:
- REQ-102: IN_PROGRESS
```

or

```
Requirements:
- REQ-102: COMPLETED
- REQ-103: IN_PROGRESS
```

Aliases accepted when parsing: `Implements: REQ-102` plus `Status: REQ-102: COMPLETED`.

## Default when only the subject declares

`feat` or `fix` with exactly one `REQ-NNN` in the subject and no body →
`IN_PROGRESS`. Never COMPLETED.

The body stays required for: any COMPLETED, more than one ID, and `test`/`docs`
commits meant to change `verification`.

Starting is cheap to declare; finishing is not. That asymmetry mirrors the cost
of being wrong — see [ADR-0006](../docs/adr/0006-declaracao-de-status-no-commit.md).

## No verb inference

The parser never reads the verb in the subject. `complete`, `conclui`,
`finaliza`, `fecha` are free text and carry no meaning to the auditor — a
Portuguese-writing agent produces all four, and an intent parser would fail
silently in the direction that manufactures false 100s.

`COMPLETED` comes from the `Requirements:` block. Nowhere else.

## What the auditor reads

1. IDs in the subject or `Requirements:` list
2. Declared status — from the body; absent, a single-ID subject means IN_PROGRESS
3. File list of that commit (plausibility)

It does not walk the entire tree.

COMPLETED is a claim. The auditor sets `completion` to declared, accepted, or rejected. Rejected does not stay COMPLETED. A later `test(REQ-102)` may upgrade declared to accepted.

## Ignored

- `chore(dashproject):` snapshots
- Merge commits unless they declare REQs

## Examples

Subject only — no body needed to start:

```
feat(REQ-102): boleto generation
```

→ `REQ-102: IN_PROGRESS`


```
feat(REQ-102): implement boleto generation

Requirements:
- REQ-102: IN_PROGRESS
```

```
feat(REQ-102): complete boleto generation

Requirements:
- REQ-102: COMPLETED
```

The word `complete` in that subject is decorative. What sets the status is the
`Requirements:` block. Drop the block and this commit means IN_PROGRESS.

```
test(REQ-102): cover boleto emission

Requirements:
- REQ-102: COMPLETED
```

(`test` alone does not flip PLANNED → COMPLETED unless status is declared and implementation already exists.)

```
fix(REQ-102,REQ-103): correct boleto cancel path

Requirements:
- REQ-102: COMPLETED
- REQ-103: IN_PROGRESS
```
