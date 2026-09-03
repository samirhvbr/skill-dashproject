# Versão — skill-DASHPROJECT

**Versão atual:** `0.5.4`

> Este arquivo é a **fonte da verdade** da versão do projeto. Qualquer lugar que
> precise exibir ou reportar a versão extrai o **primeiro número semver (`X.Y.Z`)**
> encontrado aqui. Mantenha a linha **"Versão atual"** sempre como a primeira
> ocorrência de um número de versão. Mesma mecânica dos projetos-irmãos
> (AUDITOR, COMMITTER, LOOP).
>
> `SKILL.md` → `metadata.version`, `README.md`, `README_br.md` e o nome do pacote
> de release **derivam** daqui. `scripts/check-docs.sh` reprova divergência.

---

## 1. Convenção de Versionamento (`X.Y.Z`)

| Componente | Significado | Como sobe |
|---|---|---|
| **X** | Release estável — auditor operando em projeto real da casa | Manual |
| **Y** | Mudança estrutural — fase concluída, quebra de contrato (`.dashproject/`, schema do ledger, projeção do dashboard), ADR aceito que muda a direção | Manual |
| **Z** | Incremento a cada entrega | A cada entrega |

Enquanto `X` for `0`, contratos podem quebrar entre versões `0.Y`.

### Gatilhos de bump do `Z`

- Alterar `SKILL.md` — é o **prompt do produto**, e qualquer regra nova ali muda o
  comportamento do auditor.
- Alterar regra em `references/**`: scoring, protocolo de commit, ciclos, ledger,
  atividade, projeção do dashboard.
- Alterar o schema de `.dashproject/**` (requirements, analysis, coverage,
  divergences, activity, `data.json`).
- Alterar `scripts/` que o repositório alvo executa: hook, watch, coleta de
  atividade, renderer.
- Alterar `assets/templates/**` — são copiados para dentro do projeto auditado.
- Criar ou alterar documento em `docs/` que **muda uma regra** (não vale corrigir
  redação).

### Gatilhos de bump do `Y`

- Fase do roadmap concluída (ver o roadmap do [README.md](README.md)).
- Quebra de compatibilidade num `.dashproject/` já existente em algum repo.
- ADR novo com status **Aceito** que muda a direção.

> Correções de texto, typo e formatação **não** exigem bump.

---

## 2. Formato de Commit Obrigatório

```
X.Y.Z - Descrição curta em português
```

**Regras inegociáveis:**

1. A versão **sempre** vem deste `version.md`, bumpada **no mesmo commit**.
2. Mensagem em **português**, descritiva o suficiente para `git log --grep`.
3. **Proibido** Conventional Commits (`feat:`, `fix:`, `chore:`…) e mensagens vagas.
4. Um objetivo por commit; mudanças pequenas e atômicas.

O bump entra em **um único commit** por entrega (o primeiro). Commits adicionais
da mesma entrega repetem a versão.

> **Não confundir com o protocolo que o produto ensina.** O DASHPROJECT instrui o
> repositório **auditado** a declarar requisitos no commit — lá o subject pode ser
> `feat(REQ-102): …`. Isto aqui é o commit **deste** repositório, que segue o
> padrão da casa como todos os outros. Um repositório da casa que instala o
> DASHPROJECT mantém `X.Y.Z - descrição` no subject e declara os requisitos no
> **body**, pelo bloco `Requirements:`
> ([ADR-0010](docs/adr/0010-subject-livre-e-bloco-requirements.md)).

---

## 3. Changelog

O changelog deste repositório vive em **[CHANGELOG.md](CHANGELOG.md)**, no formato
[Keep a Changelog](https://keepachangelog.com/pt-BR/1.1.0/) — arranjo previsto pelo
**ADR-009 do skill-COMMITTER** (changelog desacoplado do `version.md`): a **versão**
continua saindo daqui, que é a fonte da verdade; as **entradas** ficam lá.

Entrega corrente:

### `0.5.1` — 2026-08-27 — o auditor fecha a própria árvore

Bump de **`Z`** (gatilhos: script novo, `SKILL.md`, regra em `references/**` e
`assets/templates/config.yaml`, que é copiado para dentro do projeto auditado).

O review passa a commitar o próprio snapshot com `chore(dashproject)` — o assunto
que o hook ignora — e devolve a árvore limpa
([ADR-0014](docs/adr/0014-auditor-fecha-a-propria-arvore.md)). Corrigido também o
`install-git-hook.sh`, cujo caminho de *refresh* corrompia o hook silenciosamente.
Detalhe no [CHANGELOG.md](CHANGELOG.md).

### `0.4.2` — 2026-08-21 — o escalonamento muda o esforço, não o modelo

Bump de **`Z`** (gatilhos: `SKILL.md`, regra em `references/**`, e
`assets/templates/**`, que é copiado para dentro do projeto auditado).

A `0.4.1` impôs o modelo rotineiro e deixou o **eixo** do escalonamento como
estava desde a v0.1: `escalate` nomeava **outro modelo** (`opus`). Aquele desenho
é de quando modelo era a única alavanca — "mais difícil" e "modelo maior" viravam
a mesma frase. Hoje `effort` é eixo próprio.

- **[ADR-0012](docs/adr/0012-escalonamento-por-esforco.md)** — um modelo só
  (`sonnet`); `escalate` passa a declarar **nível de esforço**. `bootstrap` sobe
  para `xhigh` (escreve o mapa inteiro e o baseline), `deep` / `release` /
  `low_confidence` / `major_divergence` para `high`.
- **`deep` entra no `escalate`** — o `cycles.md` dizia "bootstrap / deep /
  release" e o schema só listava três dos quatro. A condição existia na prosa e
  não no contrato.
- **`check-docs.sh` reprova valor de `escalate` que não seja nível de esforço** —
  inclusive nome de modelo — e passa a comparar `effort` entre o frontmatter e o
  `config.yaml`. Provado por mutação: plantar `bootstrap: opus` derruba a
  verificação (exit 1); restaurar devolve verde.
- **`effort` ganha lugar no schema**: `analysis/latest.yaml`, o contrato de
  projeção, o `data.json`, o `index.html` e o `render-reports.py` passam a
  carregar o esforço que **de fato rodou**, ao lado do modelo — pela mesma razão
  do ADR-0011 §4: declaração que nada observa não é controle.
- Consertos de rastro da 0.4.0: `/dashproject-release` ainda mandava bumpar
  `SKILL.md → metadata.version` (a fonte da verdade é o `version.md` desde a
  0.4.0) e fechar com `chore(release):`, que o §2 proíbe; `.continue/config.yaml`
  ainda declarava `0.3.0`.

⛔ **Não medido:** se `sonnet`/`xhigh` classifica um bootstrap tão bem quanto
`opus`/`medium`. Nenhum bootstrap real rodou — o do EOP está adiado por decisão.
É escolha de desenho com o eixo certo, não resultado.

### `0.4.1` — 2026-08-21 — o modelo do auditor deixa de ser um comentário em YAML

Bump de **`Z`** (gatilho: alteração no `SKILL.md`, o prompt do produto).
`config.yaml` declarava `analysis.model: sonnet` desde a v0.1 e **nada impunha**:
não havia agente, o frontmatter não declarava `model` nem `effort`, e a skill
herdava o modelo da sessão. `SKILL.md` passa a declarar `model: sonnet` +
`effort: medium`, o `check-docs.sh` reprova divergência entre os dois lugares, e
o escalonamento vira hand-off explícito —
[ADR-0011](docs/adr/0011-modelo-e-esforco-no-frontmatter.md).

*Não* consome o `v0.5` do roadmap, que continua reservado para regressão
explícita, timeline derivada de commits e burn-up histórico.

### `0.4.0` — 2026-08-21 — três saídas do mesmo snapshot, e o padrão da casa aplicado

Bump de **`Y`**: o renderer fecha o ADR-0009 (que estava escrito e não
implementado) e o repositório passa a seguir o versionamento da casa.

- `scripts/render-reports.py` — o Markdown e o HTML deixam de ser reescritos pelo
  modelo a cada review e passam a ser **projetados** de `data.json`, conforme o
  contrato de [references/dashboard.md](references/dashboard.md).
- `references/outputs.md` — as três saídas (YAML/JSON, Markdown, HTML) e quem lê
  cada uma.
- **`version.md`** — este arquivo. O repositório usava `SKILL.md` →
  `metadata.version` como canônico, em formato de dois componentes (`0.3`); passa a
  `X.Y.Z` com a fonte da verdade no lugar onde todos os projetos-irmãos a têm.
- **`README.md` em inglês, `README_br.md` em PT-BR** — o padrão da casa. O README
  era só PT-BR, e o `docs/padrao-documentacao.md` da v0.3 declarava isso como
  regra; a regra estava errada em relação aos irmãos e foi corrigida.
- **[ADR-0010](docs/adr/0010-subject-livre-e-bloco-requirements.md)** — subject
  livre + bloco `Requirements:`. Sem isso nenhum repositório da casa consegue ser
  auditado: o padrão da casa **proíbe** Conventional Commits, que era a única
  sintaxe que o protocolo documentava.
- A branch `claude/project-documentation-review-b70si2` (PR #1, que ficou em
  **draft** e nunca foi mergeada) entra na master neste mesmo movimento.

Histórico completo: [CHANGELOG.md](CHANGELOG.md).
