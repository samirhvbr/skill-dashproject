# Changelog

Formato [Keep a Changelog](https://keepachangelog.com/pt-BR/1.1.0/).
Versão canônica em [`version.md`](version.md) — `SKILL.md`, os dois READMEs e o
nome do pacote derivam dela.

## 0.5.2 - Regra de Releases no doc de agente: bump e Release sao um ato so

Eco marcado da norma unica em samirhvbr/repodocs (docs/versioning.md). O
`version.md` da branch padrao NO GITHUB e o que as Releases no GitHub mostram, e
um commit que bumpa o `version.md` nao esta terminado ate aquela versao ter tag,
Release e o badge `Latest`.

Bloco delimitado por marcador: rodar de novo substitui, nao duplica.

## 0.5.1 - Releases automaticas: o version.md da master vira tag e Release

O GitHub nao deduz versao de mensagem de commit: sem tag, o numero e string no
`git log` e `git diff` entre versoes nao existe. Entram o
`.github/workflows/release.yml` e o `tools/release.sh`.

**A regra:** o `version.md` da branch padrao **no GitHub** e o que as Releases
**no GitHub** refletem. Checkout local nao entra na conta. Um PR nao publica
nada; no merge, o push do `version.md` dispara o workflow e a Release vira
aquela versao.

Tag e titulo = a versao pura, sem prefixo `v`. Norma:
[samirhvbr/repodocs](https://github.com/samirhvbr/repodocs/blob/master/docs/versioning.md).

## [0.5.0] — 2026-08-24

### Mudado

- **A prova de `COMPLETED` deixa de ser só cenário** ([ADR-0013](docs/adr/0013-prova-que-nao-e-cenario.md)).
  Regra de **ArchUnit**, **fitness de arquitetura** e **perna de CI** passam a
  contar como prova executável, sob uma condição de três partes: a prova tem de
  ser **NOMEADA** (o ledger cita o artefato — classe, método ou código da
  checagem, nunca "há testes"), **EXISTENTE** (está no disco hoje) e **VERDE NO
  CI** (a esteira declarada a executa).

  O que forçou a emenda foi **inconsistência medida, não teoria**: no primeiro
  projeto grande auditado, quatro requisitos ficaram `PLANNED` com prova no
  disco por essas classes — enquanto **seis linhas já eram `COMPLETED`
  exatamente por elas**. O caso sem defesa: a mesma checagem provava um
  invariante em três pacotes e valia `COMPLETED` em dois, `PLANNED` no terceiro.
  O ledger já lia as três classes; o que faltava era a régua estar escrita.

  O corte deixa de ser *"é cenário?"* e passa a ser *"é prova executável,
  endereçável e executada?"*. **O eixo 0/50/100 não muda** e nenhum estado novo
  nasce — o grau continua em `completion` (`declared` × `accepted`). E a parte
  "EXISTENTE" tem caso real de estreia: uma spec que declarava uma fitness
  **inexistente** — sem ela, viraria `accepted` por prova imaginária.

- **Contradição entre requisitos irmãos vira achado.** Se o mesmo artefato prova
  A e não é creditado a um B equivalente, o auditor diz qual par diverge em vez
  de deixar os dois como estão.

## [0.4.4] — 2026-08-22

### Corrigido

- **O exemplo do bloco `Requirements:` usava `REQ-014`, e num repositório real
  esse ID existe.** No primeiro bootstrap de verdade (EOP, 214 requisitos) o
  `REQ-014` virou `accounting/F6 — Lançamento registra a versão da regra`, num
  módulo de **dinheiro**: quem copiasse o exemplo declararia `COMPLETED` um
  requisito real e alheio. Passa a `REQ-000`, que **nunca** existe porque os IDs
  começam em `REQ-001`, com a razão escrita ao lado. Exemplo que aponta para
  artefato real deixa de ser exemplo no dia em que o artefato nasce.

## [0.4.3] — 2026-08-22

O primeiro bootstrap real da skill, num repositório de verdade — e ele achou um
defeito do renderer.

### Corrigido

- **`render-reports.py` escrevia o relatório diário com links relativos do
  diretório errado.** O `history/daily/AAAA-MM-DD.md` reusa o texto de
  `dashboard.md` inteiro, e o rodapé aponta para `dashboard.html` por caminho relativo —
  que, de dois níveis abaixo, resolve para `history/daily/dashboard.html` e não
  existe. `dashboard_md()` passa a receber um prefixo, e o diário o chama com
  `../../`. Achado pela `L1` do docs-lint do EOP no primeiro `dashproject init`
  de verdade: nenhum teste da skill pegaria, porque ela não valida os links que
  emite.

## [0.4.2] — 2026-08-21

A `0.4.1` impôs o modelo rotineiro e deixou o **eixo** do escalonamento como
estava desde a v0.1: `escalate` nomeava outro **modelo**. Esta entrega troca o
eixo — um modelo só, e o que escalona é o esforço.

### Alterado

- **`analysis.escalate` declara nível de esforço, nunca nome de modelo**
  ([ADR-0012](docs/adr/0012-escalonamento-por-esforco.md)). `bootstrap` → `xhigh`;
  `deep`, `release`, `low_confidence`, `major_divergence` → `high`. O modelo é
  `sonnet` no caminho rotineiro e no escalado.
- `analysis.effort: medium` entra no `config.yaml`, igual ao frontmatter.
- `analysis/latest.yaml`, `dashboard/data.json`, `index.html` e
  `render-reports.py` passam a carregar `effort` ao lado de `model` — o que de
  fato rodou, nunca cópia do `config.yaml`.

### Adicionado

- `deep` no bloco `escalate`. O `references/cycles.md` dizia "bootstrap / deep /
  release" e o schema listava três dos quatro.
- Duas pernas novas no `scripts/check-docs.sh`: `effort` tem de bater entre
  frontmatter e `config.yaml`, e todo valor de `escalate` tem de ser
  `low|medium|high|xhigh|max`. Verificado por mutação — `bootstrap: opus`
  derruba a verificação.

### Corrigido

- `/dashproject-release` mandava bumpar `SKILL.md → metadata.version` e fechar
  com `chore(release):` — a fonte da verdade é o `version.md` desde a 0.4.0, e o
  formato de commit da casa proíbe Conventional Commits.
- `.continue/config.yaml` declarava `version: 0.3.0`.

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
