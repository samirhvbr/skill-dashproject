---
name: Padrão de documentação
globs:
  - "**/*.md"
  - "docs/**"
---

# Padrão de documentação

Regra completa em `docs/padrao-documentacao.md`. O essencial:

## Idioma (ADR-0005)

- **Inglês:** `SKILL.md`, `references/**` — são prompt, o modelo os carrega.
- **PT-BR:** `README.md`, `docs/**`, `CLAUDE.md`, `.claude/**`, `.continue/**`,
  `CONTRIBUTING.md`, `CHANGELOG.md`.
- **Inglês sempre:** código, nomes de arquivo, IDs, chaves YAML/JSON.

Nunca misture os dois idiomas dentro do mesmo arquivo.

## Versão

Canônica em `SKILL.md` → `metadata.version`. `README.md` e `CHANGELOG.md`
derivam dela. Alterou uma, alinhe as três e rode `scripts/check-docs.sh`.

## Estrutura

- `README.md` é porta de entrada, não manual. Seção passando de ~40 linhas vira
  página em `docs/` e o README linka.
- Decisão cara de reverter vira ADR em `docs/adr/`, numerado e sequencial.
- ADR aceito não se edita — escreva o próximo e marque o anterior como
  substituído.
- Links internos relativos e apontando para arquivos que existem.
- Árvore de arquivos citada no README tem de bater com a árvore real.

## Antes de fechar

```bash
scripts/check-docs.sh
```
