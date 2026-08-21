# Contribuindo

## Preparando

```bash
git clone https://github.com/samirhvbr/skill-dashproject.git
cd skill-dashproject
scripts/check-docs.sh
```

Não há build nem instalação de dependências. Requisitos: `git`, `python3` 3.9+,
`bash` 4+. `zip` só para gerar release.

## Antes de abrir PR

```bash
scripts/check-docs.sh                          # versão, links, artefatos
bash -n scripts/*.sh                           # sintaxe dos shell scripts
python3 -m py_compile scripts/collect-activity.py
```

Mexeu em `install-git-hook.sh` ou `hook-block.sh`? Teste o caminho de **refresh**
num repositório descartável — rodar duas vezes é onde mora o risco:

```bash
tmp=$(mktemp -d); git -C "$tmp" init -q .
git -C "$tmp" commit -q --allow-empty -m init
(cd "$tmp" && bash "$OLDPWD/scripts/install-git-hook.sh" >/dev/null)
(cd "$tmp" && bash "$OLDPWD/scripts/install-git-hook.sh" >/dev/null)
bash -n "$tmp/.git/hooks/post-commit" && echo "hook OK"; rm -rf "$tmp"
```

## Convenção de commit

Conventional Commits com escopo. Este repositório é a ferramenta, não um projeto
auditado — **não** use `REQ-NNN` aqui.

```
docs(adr): registra decisão de idioma híbrido
fix(activity): classifica .sh e .html como source
feat(scripts): adiciona build-release.sh
```

Escopos: `skill`, `references`, `scripts`, `activity`, `dashboard`, `templates`,
`docs`, `adr`, `claude`, `continue`, `release`.

## Regras de domínio

Um PR que viole qualquer uma destas não passa, mesmo que o código funcione:

1. Requisito vale `0`, `50` ou `100`. Nunca 63, 70 ou 80.
2. `status` é a fonte da verdade. Não persista `progress` numa linha de
   requisito.
3. Atividade de repositório nunca vira percentual de progresso.
4. `COMPLETED` recusado não permanece `COMPLETED`.

Contexto: [`docs/adr/`](docs/adr/).

## Documentação

Segue [`docs/padrao-documentacao.md`](docs/padrao-documentacao.md). Em resumo:

- Idioma conforme o [ADR-0005](docs/adr/0005-idioma-hibrido.md): prompt em
  inglês, documentação humana em PT-BR, nunca misturados no mesmo arquivo.
- Todo exemplo numérico fecha a conta.
- Decisão cara de reverter vira ADR novo — ADR aceito não se edita.
- Links relativos apontando para arquivos que existem.

## Mudou o protocolo de commit?

Ele está descrito em três lugares, para públicos diferentes. Os três mudam
juntos:

1. `references/commit-protocol.md` — o que o agente lê (inglês)
2. `assets/templates/README-COMMIT-GUIDELINES.md` — colado no projeto auditado
3. `docs/uso.md` — a leitura do time

## Release

Use `/dashproject-release <versao>` no Claude Code, ou manualmente:

1. `SKILL.md` → `metadata.version` (fonte canônica)
2. `README.md` → linha `Versão:` e a tabela de roadmap
3. `CHANGELOG.md` → entrada nova
4. `scripts/check-docs.sh`
5. `scripts/build-release.sh` → `dist/`
6. `chore(release): vX.Y` + tag `vX.Y`

O `.zip` **não** é commitado. `dist/` está no `.gitignore`.
