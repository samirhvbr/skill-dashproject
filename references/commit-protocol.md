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

## What the auditor reads

1. IDs in the subject or `Requirements:` list
2. Declared status
3. File list of that commit (plausibility)

It does not walk the entire tree.

## Ignored

- `chore(dashproject):` snapshots
- Merge commits unless they declare REQs

## Examples

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
