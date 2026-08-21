---
description: Prepara uma release da skill (versão, changelog, pacote)
argument-hint: "<nova-versao>  ex.: 0.4"
---

Prepare a release `$ARGUMENTS` desta skill.

1. Confirme que a árvore está limpa (`git status`).
2. Rode `scripts/check-docs.sh` e resolva tudo antes de seguir.
3. Atualize a versão canônica em `version.md` (linha `**Versão atual:**`) —
   é a fonte da verdade da casa, não o `SKILL.md`.
4. Propague para `SKILL.md` → `metadata.version`, `README.md` (linha
   `Version:`), `README_br.md` (linha `Versão:`) e para a tabela de roadmap dos
   dois READMEs, movendo a versão anterior para `entregue` / `delivered`.
5. Escreva a entrada em `CHANGELOG.md` no formato Keep a Changelog, a partir de
   `git log <ultima-tag>..HEAD`. Agrupe em Adicionado / Corrigido / Alterado /
   Removido. Descreva efeito para quem usa, não o diff.
6. Rode `scripts/check-docs.sh` de novo — a versão precisa bater em
   `version.md`, `SKILL.md`, nos dois READMEs e no `CHANGELOG.md`.
7. Gere o pacote: `scripts/build-release.sh`.
8. Commit no padrão da casa — `X.Y.Z - descrição curta em português`, nunca
   Conventional Commits (`version.md` §2) — e tag `v$ARGUMENTS`.

Não commite o `.zip` — `dist/` está no `.gitignore` de propósito.
