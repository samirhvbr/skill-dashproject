# Changelog

Formato [Keep a Changelog](https://keepachangelog.com/pt-BR/1.1.0/).
Versionamento derivado de `SKILL.md` → `metadata.version`.

## [0.3] — 2026-08-21

Release de consolidação: o comportamento do auditor não mudou; o repositório
saiu do improviso e passou a ter padrão de documentação, verificação automática
e decisões registradas.

### Adicionado

- `docs/adr/0006` a `0009` — quatro decisões mineradas da conversa de concepção
  que nunca tinham sido escritas: default de status no commit e recusa de
  inferir o verbo do subject; um número de progresso em vez de índice composto
  de seis dimensões, e três estados em vez de sete; timeline retrospectiva sem
  previsão de conclusão; três saídas projetando o mesmo snapshot.
- `references/dashboard.md` — contrato campo a campo entre o snapshot e
  `data.js` / `data.json`, com os campos reservados marcados. Antes o modelo
  reescrevia `data.js` a cada review lendo o `index.html` para descobrir os
  nomes.
- Schemas que faltavam em `references/ledger.md`: ponteiros de evidência
  (`evidence.implementation|tests|docs`), bloco `coverage` da precision,
  `delta`, `regressions` e o schema de `divergences.yaml`.
- `references/scoring.md` — como cada um dos quatro fatores de precision é
  calculado a partir dos contadores (antes havia peso e nenhuma fórmula), e a
  distinção entre regressão, pretensão recusada e crescimento de escopo.
- `references/cycles.md` — as condições de escalonamento por risco
  (`low_confidence`, `major_divergence`), que existiam no `config.yaml` como
  chaves sem gatilho escrito.
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

- Protocolo de commit: `feat(REQ-102): ...` sem corpo não movia nada **e** ainda
  derrubava traceability, o fator de maior peso na precision. Agora um `REQ`
  único no subject significa `IN_PROGRESS`; `COMPLETED` continua exigindo
  declaração explícita. Os quatro exemplos canônicos usavam
  `complete boleto generation` no subject sem avisar que o verbo é decorativo —
  sugeriam ao leitor exatamente a inferência que o parser não faz.
- O empty state do Gantt instruía `Add start/due on epics in project.yaml` —
  era a única orientação escrita sobre a timeline no repositório inteiro, e
  pedia datas planejadas, o cronograma que o desenho recusou. `start:` sai do
  template de épico.
- `assets/templates/project.yaml` distribuía um bloco `tracking:` que nenhum
  arquivo do repositório lia e que nenhuma documentação mencionava — resíduo do
  índice ponderado de seis dimensões que foi abandonado. Também trazia `weight:`
  em épico, que contradiz o rollup por média.
- Roadmap declarava a v0.3 como "histórico/Gantt por requisito, rejeições mais
  ricas, regressão explícita" enquanto o próprio CHANGELOG dizia que o
  comportamento do auditor não mudou. A v0.3 passa a descrever o que ela é, e
  esses itens vão para v0.4/v0.5.
- Pilar "Dashboard" prometia histórico; o `index.html` nunca leu `D.history`.
- `verification` era o único campo do ledger sem definição em português.
- `index.html` tinha fallbacks silenciosos para o vocabulário da v0.1
  (`D.overall`, `D.dimensions`), removido do restante do repositório na própria
  v0.3. Um nome de campo errado renderizaria certo e a violação de contrato
  nunca apareceria. `scripts/check-docs.sh` passa a reprovar qualquer campo
  lido pelo `index.html` que não esteja em `references/dashboard.md`.
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
