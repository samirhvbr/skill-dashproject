# CLAUDE.md

Contexto operacional deste repositório para agentes de IA.

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

- **Inglês:** `SKILL.md`, `references/**` (são prompt), código, IDs, chaves YAML.
- **PT-BR:** `README.md`, `docs/**`, `CLAUDE.md`, `.claude/**`, `.continue/**`,
  `CONTRIBUTING.md`, `CHANGELOG.md`, `assets/templates/README-COMMIT-GUIDELINES.md`.

Nunca misture os dois no mesmo arquivo.

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

Canônica em `SKILL.md` → `metadata.version`. `README.md`, `CHANGELOG.md` e o
nome do pacote derivam dela. `scripts/check-docs.sh` reprova divergência.

## Onde não mexer

- `assets/dashboard/data.js` e `data.json` são **fixtures de exemplo** com
  valores zerados. São o esqueleto que o auditor sobrescreve, não dados reais.
- Não versione `.zip`. Release é `scripts/build-release.sh` → `dist/`.

## Convenção de commit deste repositório

Conventional Commits com escopo por área. Este repositório é a **ferramenta**,
não um projeto auditado — não use `REQ-NNN` aqui.

```
docs(adr): registra decisão de idioma híbrido
fix(activity): classifica .sh e .html como source
feat(scripts): adiciona build-release.sh
```
