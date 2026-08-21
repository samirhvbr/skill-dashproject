# Padrão de documentação

Este documento **é** o padrão. Qualquer repositório nosso deve conseguir ser
auditado contra esta página.

## 1. Arquivos obrigatórios na raiz

| Arquivo | Papel | Público |
|---|---|---|
| `README.md` | O que é, para que serve, como começar em 5 minutos — **em inglês** | Quem chega de fora |
| `README_br.md` | O mesmo conteúdo em PT-BR | O time |
| `version.md` | **Fonte da verdade da versão** + convenção de bump + formato de commit | Todos |
| `CLAUDE.md` | Contexto operacional para agentes de IA | Claude Code / agentes |
| `AGENTS.md` | Espelho do `CLAUDE.md` (symlink ou cópia sincronizada) | Outros agentes |
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
| **`README.md`** | **Inglês** | Porta de entrada do repositório público. Padrão da casa. |
| **`README_br.md`** | **PT-BR** | O mesmo conteúdo para o leitor do time. |
| `docs/**`, `version.md`, `CONTRIBUTING.md`, `CHANGELOG.md` | PT-BR | Leitor humano do time. |
| `CLAUDE.md`/`AGENTS.md`, `.claude/**`, `.continue/**` | PT-BR | Instrução operacional para quem configura. |
| Código, nomes de arquivo, IDs, chaves YAML/JSON | Inglês | Interoperabilidade. |

Nunca misture os dois idiomas dentro do mesmo arquivo.

**O par de READMEs é uma regra dura.** `README.md` (inglês) e `README_br.md`
(PT-BR) dizem a mesma coisa e são editados **no mesmo commit**. Vale para todos
os repositórios da casa — AUDITOR, COMMITTER, LOOP, EOP, pve-manager, LINUX e os
demais.

> Corrigido na v0.4.0: a v0.3 desta página declarava `README.md` como PT-BR e não
> previa o `README_br.md`. Estava fora do padrão dos projetos-irmãos.

## 4. Versão

A versão vive em **um** lugar canônico e todos os outros derivam dele.

O canônico da casa é **`version.md`**: o **primeiro semver `X.Y.Z`** do arquivo,
sempre na linha `**Versão atual:**`. `SKILL.md` → `metadata.version`,
`README.md`, `README_br.md`, `CHANGELOG.md` e o nome do pacote de release têm de
bater com ele.

O `version.md` traz três seções fixas: **§1** a convenção `X.Y.Z` com os gatilhos
de bump de `Z` e de `Y`, **§2** o formato de commit obrigatório, **§3** o
changelog — que pode ser desacoplado para o `CHANGELOG.md`, arranjo previsto pelo
ADR-009 do skill-COMMITTER (a *versão* continua saindo do `version.md`; as
*entradas* ficam no changelog).

Formato de commit da casa:

```
X.Y.Z - Descrição curta em português
```

**Proibido** Conventional Commits (`feat:`, `fix:`, `chore:`…) nos repositórios
da casa. Não confundir com o protocolo de commit que uma skill de auditoria
*ensina* ao repositório auditado — são gramáticas diferentes, em repositórios
diferentes.

Antes de qualquer release:

```bash
scripts/check-docs.sh
```

> Corrigido na v0.4.0: a v0.3 desta página elegia `SKILL.md` → `metadata.version`
> como canônico, em formato de dois componentes (`0.3`), e não mencionava
> `version.md`. Nenhum projeto-irmão faz assim.

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
- [ ] `README.md` (inglês) e `README_br.md` (PT-BR) dizem a mesma coisa
- [ ] Árvore de arquivos do README bate com a árvore real
- [ ] `version.md` existe, com §1 convenção, §2 formato de commit e §3 changelog
- [ ] Versão consistente entre `version.md`, `SKILL.md`, os dois READMEs e `CHANGELOG.md`
- [ ] Commit no formato `X.Y.Z - descrição em português`
- [ ] Todo exemplo numérico fecha a conta
- [ ] Nenhum link relativo quebrado
- [ ] Nenhum artefato de build versionado
- [ ] `CHANGELOG.md` tem entrada para a versão atual
- [ ] Decisão nova tem ADR
