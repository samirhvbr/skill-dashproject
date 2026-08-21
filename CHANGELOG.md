# Changelog

Formato [Keep a Changelog](https://keepachangelog.com/pt-BR/1.1.0/).
Versão canônica em [`version.md`](version.md) — `SKILL.md`, os dois READMEs e o
nome do pacote derivam dela.

## [0.4.1] — 2026-08-21

O modelo do auditor deixa de ser um comentário em YAML.

### Corrigido

- **`SKILL.md` passa a declarar `model: sonnet` e `effort: medium` no
  frontmatter.** A medição no primeiro repositório real da casa (`~/x/EOP`)
  mostrou que não existia agente algum e que a skill herdava o modelo da sessão —
  Opus 5 em `effort: high`, o oposto do que `config.yaml` → `analysis.model`
  declarava para o caminho incremental desde a v0.1. Declarado ≠ imposto.
  [ADR-0011](docs/adr/0011-modelo-e-esforco-no-frontmatter.md).

### Adicionado

- `SKILL.md` §*Model and effort* — `analysis.escalate` **não se executa
  sozinho**: uma skill não troca o próprio modelo no meio da execução, então
  `bootstrap` / `deep` / `release` / `low_confidence` / `major_divergence` viram
  **hand-off explícito** (para e pede a troca), nunca continuação silenciosa no
  modelo rotineiro.
- O campo `model` de `analysis/latest.yaml` e de `dashboard/data.json` passa a ser
  o modelo **que de fato rodou**, nunca uma cópia de `config.yaml`; divergência
  aparece na linha de relato.
- `scripts/check-docs.sh` — perna nova: reprova se `SKILL.md` não declarar
  `model`/`effort`, se o `effort` não for `low|medium|high|xhigh|max`, ou se o
  `model` divergir de `assets/templates/config.yaml` → `analysis.model`.
- `references/cycles.md` §*Model routing* alinhado ao ADR-0011.

### Limite conhecido

- `model` e `effort` são campos do Claude Code. O empacotador oficial da
  Anthropic valida um conjunto fechado de 6 campos e falha duro com campo extra;
  `scripts/build-release.sh` é um `zip` e não valida, então o pacote da casa
  continua saindo. Registrado nas consequências do ADR-0011.

## [0.4.0] — 2026-08-21

O renderer que faltava, e o repositório entrando no padrão de versionamento da
casa. A partir daqui a versão é `X.Y.Z` e mora em `version.md`.

### Adicionado

- `scripts/render-reports.py` — projeta Markdown e HTML a partir de
  `dashboard/data.json`, fechando o [ADR-0009](docs/adr/0009-tres-saidas-do-mesmo-snapshot.md),
  que estava escrito e não implementado. Antes o modelo reescrevia os relatórios
  à mão a cada review.
- `references/outputs.md` — as três saídas e quem lê cada uma.
- **`version.md`** — fonte da verdade da versão, no padrão dos projetos-irmãos
  (AUDITOR, COMMITTER, LOOP): §1 convenção `X.Y.Z` com gatilhos de bump, §2
  formato de commit obrigatório, §3 changelog.
- **`README.md` em inglês** — porta de entrada do repositório público, padrão da
  casa. O conteúdo PT-BR passou para `README_br.md`.
- `AGENTS.md` — symlink para `CLAUDE.md`, como nos irmãos.
- [ADR-0010](docs/adr/0010-subject-livre-e-bloco-requirements.md) — subject livre
  e bloco `Requirements:` como única sintaxe obrigatória.

### Corrigido

- **`docs/padrao-documentacao.md` estava fora do padrão da casa em dois pontos**,
  e como ele *é* o padrão, o erro se propagava: declarava `README.md` como PT-BR
  (sem prever `README_br.md`) e elegia `SKILL.md` → `metadata.version` como
  versão canônica, em formato de dois componentes.
- **O protocolo de commit só documentava Conventional Commits** — a única sintaxe
  que os repositórios da casa não podem produzir, já que o padrão deles é
  `X.Y.Z - descrição` e o validador do skill-COMMITTER recusa `feat:`/`fix:`.
  Nenhum projeto da casa era auditável. Ver ADR-0010.
- `CLAUDE.md` prescrevia Conventional Commits para os commits **deste**
  repositório, contra o padrão da casa. Passa a distinguir explicitamente as duas
  gramáticas (commit deste repo × protocolo que o produto ensina).
- `scripts/check-docs.sh` valida `version.md` como canônico, o par de READMEs e a
  compilação de `render-reports.py`.
- `scripts/build-release.sh` lê a versão de `version.md` e empacota
  `README_br.md` e `version.md`.

### Integração

- A branch `claude/project-documentation-review-b70si2` (PR #1) entra na master.
  O PR ficou em **draft** e nunca foi mergeado: os 10 commits da v0.3 viveram
  fora da master enquanto ela recebia o trabalho do renderer, e as duas pontas
  editaram `SKILL.md`, `README.md` e `references/cycles.md`.

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
