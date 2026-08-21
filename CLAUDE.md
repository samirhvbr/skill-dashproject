# skill-DASHPROJECT — Instruções para agentes de IA

Contexto operacional deste repositório para agentes de IA.

> `CLAUDE.md` e `AGENTS.md` são o **mesmo arquivo** (`AGENTS.md` é symlink) —
> editar um edita os dois.
>
> **Leia também:** [README.md](README.md) (o produto, inglês) ·
> [README_br.md](README_br.md) (o mesmo, PT-BR) ·
> [version.md](version.md) (versão + formato de commit) ·
> [docs/padrao-documentacao.md](docs/padrao-documentacao.md) (o padrão) ·
> [docs/adr/](docs/adr/) (ADR-0001 a ADR-0010).

---

## 🔄 Antes de começar: `git pull`

**SEMPRE** verifique atualizações remotas antes de escrever ou alterar qualquer
coisa neste repositório:

```bash
git pull
```

Lição de 21/08/2026: a v0.3 inteira ficou numa branch com PR em **draft**, nunca
mergeada, enquanto a master seguia recebendo trabalho novo — e as duas pontas
editaram os mesmos três arquivos.

## O que este repositório é

A skill `skill-dashproject`: um **auditor de progresso** que outros projetos
instalam. Aqui não há aplicação, build de produção nem suíte de testes —
o produto é o protocolo em `SKILL.md` mais os scripts de apoio.

Distinção que causa confusão e precisa ficar clara:

| | |
|---|---|
| **este repositório** | o código-fonte da skill |
| `.dashproject/` | a saída do auditor **dentro de um projeto auditado** |

Não crie `.dashproject/` aqui a menos que esteja explicitamente auditando este
repositório com a própria skill (e está no `.gitignore`).

## Regras invioláveis do domínio

Ao editar qualquer documento ou script, estas quatro regras valem sempre:

1. Requisito vale **0, 50 ou 100**. Nunca 63, 70 ou 80.
2. `status` é a fonte da verdade. **Nunca** grave um campo `progress` numa
   linha de requisito — ele é sempre derivado.
3. Atividade de repositório (arquivos, LOC, churn, commits) **nunca** vira
   percentual de progresso.
4. `COMPLETED` recusado não permanece `COMPLETED` — volta ao status anterior e
   vai para `rejected_claims`.

Detalhes em [`references/scoring.md`](references/scoring.md).

## Idioma

Híbrido, e é intencional — veja [ADR-0005](docs/adr/0005-idioma-hibrido.md):

- **Inglês:** `SKILL.md`, `references/**` (são prompt), **`README.md`**, código,
  IDs, chaves YAML.
- **PT-BR:** **`README_br.md`**, `docs/**`, `CLAUDE.md`/`AGENTS.md`, `version.md`,
  `.claude/**`, `.continue/**`, `CONTRIBUTING.md`, `CHANGELOG.md`,
  `assets/templates/README-COMMIT-GUIDELINES.md`.

Nunca misture os dois no mesmo arquivo.

**Padrão da casa para o README** (igual a AUDITOR, COMMITTER, LOOP, EOP):
`README.md` é **inglês** e é a porta de entrada do repositório público;
`README_br.md` é o PT-BR. Os dois são editados **no mesmo commit** quando uma
regra muda — README que diverge do irmão é defeito.

## Antes de encerrar qualquer alteração

```bash
scripts/check-docs.sh        # versão, links, arquivos obrigatórios, artefatos
bash -n scripts/*.sh         # sintaxe dos shell scripts
python3 -m py_compile scripts/collect-activity.py
```

Se mexeu em `scripts/install-git-hook.sh` ou `scripts/hook-block.sh`, teste o
caminho de **refresh** (rodar duas vezes) num repositório descartável — é onde
mora o risco:

```bash
tmp=$(mktemp -d) && git -C "$tmp" init -q .
git -C "$tmp" commit -q --allow-empty -m init
(cd "$tmp" && bash /caminho/scripts/install-git-hook.sh >/dev/null)
(cd "$tmp" && bash /caminho/scripts/install-git-hook.sh >/dev/null)
bash -n "$tmp/.git/hooks/post-commit" && echo "hook OK"
```

## Versão

Canônica em **[`version.md`](version.md)** — o **primeiro semver `X.Y.Z`** do
arquivo, mesma mecânica dos projetos-irmãos (AUDITOR, COMMITTER, LOOP).
`SKILL.md` → `metadata.version`, `README.md`, `README_br.md`, `CHANGELOG.md` e o
nome do pacote de release **derivam** dela. `scripts/check-docs.sh` reprova
divergência.

Ao concluir uma entrega: bumpe o `version.md` **no mesmo commit**, com a entrada
correspondente no `CHANGELOG.md`. Os gatilhos de bump de `Z` e de `Y` estão no
próprio `version.md` §1.

## Onde não mexer

- `assets/dashboard/data.js` e `data.json` são **fixtures de exemplo** com
  valores zerados. São o esqueleto que o auditor sobrescreve, não dados reais.
- Não versione `.zip`. Release é `scripts/build-release.sh` → `dist/`.

## Convenção de commit deste repositório

**Padrão da casa** — o mesmo de AUDITOR, COMMITTER, LOOP e EOP:

```
X.Y.Z - Descrição curta em português
```

A versão vem de [`version.md`](version.md), bumpada no mesmo commit.
**Proibido** Conventional Commits (`feat:`, `fix:`, `chore:`…) e mensagens
vagas. Regras completas em [`version.md`](version.md) §2.

⚠️ **Duas gramáticas de commit convivem neste repositório, e confundi-las é o
erro fácil:**

| | Onde vale | Formato |
|---|---|---|
| commit **deste** repo | aqui, sempre | `0.4.0 - descrição em português` |
| protocolo que o **produto** ensina | no repositório **auditado** | `feat(REQ-102): …` ou subject livre + bloco `Requirements:` |

Este repositório é a **ferramenta**, não um projeto auditado — não use `REQ-NNN`
aqui. Até a v0.3 os commits daqui eram Conventional Commits, fora do padrão da
casa; o histórico anterior a `0.4.0` fica como está.
