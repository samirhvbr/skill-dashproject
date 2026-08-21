# Padrão de documentação

Este documento **é** o padrão. Qualquer repositório nosso deve conseguir ser
auditado contra esta página.

## 1. Arquivos obrigatórios na raiz

| Arquivo | Papel | Público |
|---|---|---|
| `README.md` | O que é, para que serve, como começar em 5 minutos | Quem chega de fora |
| `CLAUDE.md` | Contexto operacional para agentes de IA | Claude Code / agentes |
| `CONTRIBUTING.md` | Como contribuir, convenção de commit, checklist de PR | Quem vai editar |
| `CHANGELOG.md` | Histórico por versão, formato Keep a Changelog | Quem atualiza |
| `LICENSE` | Licença explícita | Jurídico / distribuição |
| `.gitignore` | Nada de artefato de build versionado | Todos |
| `.editorconfig` | Encoding, fim de linha, indentação | Todos |

Regra dura: **se o metadado declara uma licença, o arquivo `LICENSE` existe.**
Um `license: MIT` no frontmatter sem `LICENSE` na raiz é defeito.

## 2. Pastas

```
docs/            documentação humana — arquitetura, instalação, uso, decisões
docs/adr/        Architecture Decision Records, numerados e imutáveis
.claude/         configuração e comandos do Claude Code
.continue/       configuração e regras do Continue.dev
scripts/         automação executável (nunca documentação)
assets/          templates e artefatos estáticos distribuídos
references/      material que o agente carrega sob demanda (skills)
```

`docs/` descreve **o sistema pretendido**. `README.md` é a porta de entrada,
não o manual completo — se uma seção do README passa de ~40 linhas, ela vira
uma página em `docs/` e o README passa a linkar.

## 3. Idioma

Padrão **híbrido**, e ele é intencional:

| Alvo | Idioma | Por quê |
|---|---|---|
| `SKILL.md`, `references/**` | Inglês | São prompt. O modelo é mais estável e mais econômico em tokens em inglês. |
| `README.md`, `docs/**`, `CONTRIBUTING.md`, `CHANGELOG.md` | PT-BR | Leitor humano do time. |
| `CLAUDE.md`, `.claude/**`, `.continue/**` | PT-BR | Instrução operacional para quem configura. |
| Código, nomes de arquivo, IDs, chaves YAML/JSON | Inglês | Interoperabilidade. |

Nunca misture os dois idiomas dentro do mesmo arquivo.

## 4. Versão

A versão vive em **um** lugar canônico e todos os outros derivam dele.

Neste repositório o canônico é o frontmatter de `SKILL.md` (`metadata.version`).
`README.md`, `CHANGELOG.md` e o nome do pacote de release têm de bater com ele.

Antes de qualquer release:

```bash
scripts/check-docs.sh
```

## 5. ADRs

Toda decisão que é cara de reverter vira um ADR em `docs/adr/`:

- numeração sequencial `NNNN-titulo-em-kebab-case.md`;
- status `Proposto` / `Aceito` / `Substituído por ADR-NNNN`;
- ADR aceito **não é editado** — é substituído por um novo.

## 6. Exemplos numéricos

Todo exemplo com número na documentação precisa fechar a conta. Um exemplo que
não fecha ensina o agente a errar. Exemplo real corrigido na v0.3:

```
172 COMPLETED · 14 IN_PROGRESS · 101 PLANNED  (287 ativos)
(172×100 + 14×50 + 101×0) / 287 = 62,4%     ← a doc dizia 64,8%
```

## 7. Links

Links internos são **relativos** e apontam para arquivos que existem.
`scripts/check-docs.sh` quebra o build se um link relativo apontar para o vazio.

## 8. Checklist de revisão de documentação

- [ ] `README.md` responde: o que é, por que existe, como rodar, onde ler mais
- [ ] Árvore de arquivos do README bate com a árvore real
- [ ] Versão consistente entre `SKILL.md`, `README.md`, `CHANGELOG.md`
- [ ] Todo exemplo numérico fecha a conta
- [ ] Nenhum link relativo quebrado
- [ ] Nenhum artefato de build versionado
- [ ] `CHANGELOG.md` tem entrada para a versão atual
- [ ] Decisão nova tem ADR
