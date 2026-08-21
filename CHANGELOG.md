# Changelog

Formato [Keep a Changelog](https://keepachangelog.com/pt-BR/1.1.0/).
Versionamento derivado de `SKILL.md` → `metadata.version`.

## [0.3] — 2026-08-21

Release de consolidação: o comportamento do auditor não mudou; o repositório
saiu do improviso e passou a ter padrão de documentação, verificação automática
e decisões registradas.

### Adicionado

- `docs/` — arquitetura, instalação, uso, glossário, troubleshooting e o padrão
  de documentação que o repositório passa a seguir.
- `docs/adr/` — cinco ADRs registrando as decisões que já estavam implícitas no
  código: progresso discreto, `status` como fonte da verdade, hook sem LLM,
  atividade separada de progresso e idioma híbrido.
- `CLAUDE.md`, `.claude/settings.json` e dois comandos (`/dashproject-check`,
  `/dashproject-release`).
- `.continue/` com `config.yaml` e três regras (domínio, commits, documentação).
- `CONTRIBUTING.md`, `LICENSE` (MIT — o `SKILL.md` já declarava, faltava o
  arquivo), `CHANGELOG.md`, `.gitignore` e `.editorconfig`.
- `scripts/check-docs.sh` — falha se a versão divergir entre `SKILL.md`,
  `README.md` e `CHANGELOG.md`, se houver link relativo quebrado, se faltar
  arquivo obrigatório na raiz ou se houver artefato de build versionado.
- `scripts/build-release.sh` — empacota em `dist/` sob demanda.

### Corrigido

- Aritmética errada no exemplo canônico de `SKILL.md` e `references/ledger.md`:
  172 COMPLETED + 14 IN_PROGRESS + 101 PLANNED em 287 ativos dá **62,4%**, não
  64,8%. O número aparecia como saída modelo para o agente imitar.
- `scripts/collect-activity.py` classificava `.sh`, `.html`, `.vue`, `.svelte`,
  `.kt`, `.swift`, `.sql` e outros como `other`. Neste repositório isso jogava
  8 de 11 arquivos de código no balde errado.
- `assets/templates/README.md` estava em inglês num arquivo lido por pessoas do
  projeto auditado; passou para PT-BR conforme o ADR-0005.
- Roadmap do `README.md` listava `v0.2` duas vezes — uma como entregue e outra
  como futura — e nunca mencionava a v0.3 em curso.
- Versão declarada como `0.2` em `SKILL.md` e `README.md` enquanto o commit e o
  pacote diziam v0.3.
- IDs de exemplo no `README.md` usavam `R001`, formato que o próprio protocolo
  não aceita. Agora `REQ-001`.
- Árvore de arquivos do `README.md` omitia `scripts/watch.sh`,
  `scripts/collect-activity.py`, `scripts/hook-block.sh` e os dois arquivos de
  dados do dashboard.

### Removido

- `skill-dashproject_v0.3.zip` do controle de versão. Era build do próprio tree,
  commitado como blob. Agora se gera com `scripts/build-release.sh`.

## [0.2] — 2026-08-21

### Adicionado

- Bootstrap conservador: existência de arquivo deixa de ser conclusão.
  `evidence.knownness` (`unknown`/`partial`/`known`) e `baseline_confidence`.
- Campo `completion` em `COMPLETED`: `declared`, `accepted`, `rejected`.
  Pretensão recusada volta ao status anterior e vai para `rejected_claims`.
- Hook composto com bloco delimitado por marcadores, preservando hooks
  existentes; `watch.sh`, `pending-ready.sh` e o unit systemd de usuário.
- `collect-activity.py`: atividade do repositório a partir do Git, sem LLM.

### Alterado

- `progress` deixa de ser persistido na linha do requisito — passa a ser sempre
  derivado de `status`.

## [0.1] — 2026-08-21

### Adicionado

- Bootstrap a partir da documentação, progresso 0/50/100, debounce de commits,
  protocolo de commit com `REQ-NNN`, dashboard HTML estático, snapshots e
  Measurement Precision.
