# Versão — skill-DASHPROJECT

**Versão atual:** `0.4.1`

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
