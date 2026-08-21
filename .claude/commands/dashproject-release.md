---
description: Prepara uma release da skill (versão, changelog, pacote)
argument-hint: "<nova-versao>  ex.: 0.4"
---

Prepare a release `$ARGUMENTS` desta skill.

1. Confirme que a árvore está limpa (`git status`).
2. Rode `scripts/check-docs.sh` e resolva tudo antes de seguir.
3. Atualize a versão canônica em `SKILL.md` → `metadata.version`.
4. Propague para `README.md` (linha `Versão:`) e para a tabela de roadmap,
   movendo a linha da versão anterior para `entregue`.
5. Escreva a entrada em `CHANGELOG.md` no formato Keep a Changelog, a partir de
   `git log <ultima-tag>..HEAD`. Agrupe em Adicionado / Corrigido / Alterado /
   Removido. Descreva efeito para quem usa, não o diff.
6. Rode `scripts/check-docs.sh` de novo — a versão precisa estar consistente
   nos três arquivos.
7. Gere o pacote: `scripts/build-release.sh`.
8. Commit `chore(release): v$ARGUMENTS` e tag `v$ARGUMENTS`.

Não commite o `.zip` — `dist/` está no `.gitignore` de propósito.
