---
name: Convenção de commit
alwaysApply: true
---

# Commits neste repositório

Conventional Commits com escopo por área. Este repositório é a **ferramenta**,
não um projeto auditado — **não** use `REQ-NNN` aqui.

```
docs(adr): registra decisão de idioma híbrido
fix(activity): classifica .sh e .html como source
feat(scripts): adiciona build-release.sh
chore(release): v0.3
```

Escopos usados: `skill`, `references`, `scripts`, `activity`, `dashboard`,
`templates`, `docs`, `adr`, `claude`, `continue`, `release`.

## No projeto auditado é diferente

Lá o commit declara requisitos, e o formato é outro:

```
feat(REQ-102): implement boleto generation

Requirements:
- REQ-102: IN_PROGRESS
```

- `feat` / `fix` podem mover 0 → 50 → 100
- `test` / `docs` não movem o estado; podem promover `declared` → `accepted`
- `refactor` / `chore` não mexem em progresso, salvo se declararem um REQ
- `chore(dashproject)` é reservado ao auditor: é com esse assunto que ele commita
  o próprio snapshot, e é o que o hook ignora

Referência: `references/commit-protocol.md`.
