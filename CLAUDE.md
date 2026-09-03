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

---

<!-- COMMIT-RULE:repodocs -->

## Commits — you commit, and nothing is delivered until you have

> Marked echo. The single source is **[samirhvbr/repodocs](https://github.com/samirhvbr/repodocs/blob/master/docs/versioning.md#who-commits-and-when)**
> — change it there, not here. This block is regenerated.

**Committing is your job.** Not "leave the tree ready and something downstream
packages it" — you run `git commit`, and `git push`, as the last step of the work
you were asked to do. The COMMITTER skill that used to commit on an agent's
behalf is `enabled: false` in every repository of this fleet since 03/09/2026;
what is left of it is a kill-switch, not a scheduler. **If you do not commit,
nobody does.**

**Do not report a task as finished before the commit exists.** "Done",
"delivered", "concluded" mean the work is in `git log` — never that it is sitting
uncommitted where only this session can see it. The commit is the last step *of
the task*, not a follow-up for someone else. If you are about to write
"finished", commit first, then write it.

**Every commit obeys the versioning rules**, with no exception:

- Subject `X.Y.Z - short description in English (US)`, the version taken from
  `version.md` and **bumped in the same commit**.
- The `CHANGELOG.md` entry is written first — its `## X.Y.Z - description`
  heading *is* the subject.
- No Conventional Commits prefix (`feat:`, `fix:`, `chore:`) and no vague
  subject ("update", "ajuste", "wip", "changes", "several improvements").

**One subject per commit.** The subject has to describe the whole commit
honestly. The moment your description needs an "and" to be true, it is two
commits.

**Split a large delivery into blocks.** A complex task is committed as a series
of commits grouped by subject, each small enough to be described in one line and
read on its own. They may share a version — bump `version.md` in the first and
repeat the number in the rest; two commits carrying one version is expected, not
a mistake. **Splitting is the default** for anything non-trivial, because the
history is the documentation of *how* the work was done, and one commit touching
six unrelated subjects documents none of them.

**The standard you are keeping:** someone reading `git log` alone — a year from
now, without the conversation that produced the work — can say what happened,
when, why, and at which version. If your commit would fail that test, it is too
big or its subject is too vague, and both are fixed the same way.

<!-- /COMMIT-RULE -->

---

<!-- RELEASES-RULE:repodocs -->

## Releases — the `version.md` on GitHub is what the Releases show

> Marked echo. The single source is **[samirhvbr/repodocs](https://github.com/samirhvbr/repodocs/blob/master/docs/versioning.md)**
> — change it there, not here. This block is regenerated.

**The `version.md` of the default branch, on GitHub, is what the GitHub Releases
must show.** The local checkout does not enter the calculation: it can be behind,
ahead or mid-work, and none of that is published — GitHub cannot tag a commit it
does not have.

**The bump and the Release are one act.** A commit that bumps `version.md` is not
finished until that version has a tag, a published Release, and the **`Latest`
badge on it** — the same push, not "later". A badge sitting on an older release
tells whoever looks that the project is at a version it is not.

- `.github/workflows/release.yml` does it on any push that touches `version.md`.
- `./tools/release.sh` does it by hand. It is **idempotent and self-healing**:
  it publishes whatever is missing and moves a drifted badge back. Running it is
  always safe, so it is both the check and the fix.

A PR publishes nothing while it is a PR. The moment it merges, the push moves
`version.md` on the default branch and the Release becomes that version.

Tag and Release title are the **bare version — no `v` prefix**.

## Language — English (US), everywhere in the repository

**Everything that lives in this repository, or in GitHub's interface around it,
is written in English (US)**: documents, **commit messages**, pull request titles
and bodies, issues, code comments, changelog entries, release notes.

Commit format: `X.Y.Z - short description in English`. The version comes from
`version.md` and is bumped in the same commit. Conventional Commits prefixes
(`feat:`, `fix:`, `chore:`) and vague one-word messages are forbidden.

**Exactly one carve-out:** end-user-facing strings — UI text, transactional
email, product copy. That is product i18n for a Brazilian audience, not
repository content.

History is not rewritten: Portuguese messages already in the log stay as they
are.

<!-- /RELEASES-RULE -->
