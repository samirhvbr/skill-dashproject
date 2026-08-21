# ADR-0010 — Subject livre: o bloco `Requirements:` é a única sintaxe obrigatória

**Status:** Aceito · v0.4.0

## Contexto

Até a v0.3 o protocolo de commit documentava **uma** sintaxe:
`<type>(REQ-NNN): descrição`. O [ADR-0006](0006-declaracao-de-status-no-commit.md)
já tinha separado as duas fontes de declaração — o subject dá o default
`IN_PROGRESS`, o bloco `Requirements:` dá qualquer status — mas os exemplos, o
template de guidelines e o README mostravam só Conventional Commits.

O problema apareceu ao instalar o DASHPROJECT no primeiro repositório real da
casa (`~/x/EOP`, versão 1.63.2):

> O padrão de commit da casa é `X.Y.Z - Descrição curta em português` e ele
> **proíbe** explicitamente Conventional Commits — está escrito em `version.md`
> de todos os projetos, e o validador do **skill-COMMITTER** *recusa* mensagem
> que comece com `feat:`/`fix:`/`chore:`.

Ou seja: a única sintaxe que o DASHPROJECT documentava era a única que os
repositórios da casa não podem produzir. O auditor não leria requisito nenhum, o
fator *traceability* (peso 35, o maior da precision) ficaria zerado para sempre, e
o dashboard congelaria no baseline do bootstrap.

Não é um caso de borda da casa: qualquer projeto com padrão próprio de commit
(release-name, ticket-id, changelog-first) cai no mesmo lugar.

## Decisão

1. O **subject é texto livre**. O parser não exige `<type>(REQ-NNN)` e não exige
   formato nenhum.
2. O bloco `Requirements:` no **body** é a declaração canônica e suficiente:

   ```
   1.63.3 - fecha a duplicata da colheita automatica

   Requirements:
   - REQ-014: COMPLETED
   ```

3. O default do ADR-0006 (`feat`/`fix` + um único `REQ-NNN` no subject, sem body
   → `IN_PROGRESS`) **continua valendo onde há type**. É um atalho para quem usa
   Conventional Commits, não um requisito.
4. Sem type reconhecível no subject, as regras por tipo (`feat`/`fix` movem
   status; `test`/`docs` só movem `verification`) são lidas do **bloco**: o status
   declarado manda, e `verification` sobe quando o diff traz teste ou doc.
5. *Traceability* passa a contar **commits que declaram requisito**, por qualquer
   uma das duas sintaxes — nunca a presença de Conventional Commits.

## Consequências

- Repositório com padrão próprio de commit passa a ser auditável **sem abrir mão
  do padrão**, que era a condição para o EOP entrar.
- A ergonomia do atalho de subject fica restrita a quem usa Conventional Commits.
  Quem não usa paga o body sempre — e o body já era obrigatório para todo
  `COMPLETED`, que é a declaração que importa.
- O template `assets/templates/README-COMMIT-GUIDELINES.md` passa a ter as duas
  formas, e o `dashproject init` escolhe qual mostrar lendo o padrão do repositório
  alvo (histórico do `git log` + presença de `version.md` no formato da casa).
- Não muda schema, não muda `.dashproject/`, não invalida ledger existente: é
  ampliação do que o parser aceita.

## Alternativas descartadas

- **Pedir ao repositório alvo que adote Conventional Commits** — inverte a relação:
  o auditor é o observador, não a autoridade sobre o padrão de commit do projeto.
  No caso da casa é impossível na prática, porque o skill-COMMITTER *recusa*
  mecanicamente essa sintaxe.
- **Ler a declaração do `version.md`/`CHANGELOG.md` do alvo em vez do commit** —
  perde a amarração requisito ↔ diff, que é o que sustenta `completion: accepted`
  vs `declared`. A validação de plausibilidade precisa do diff daquele commit.
- **Um segundo marcador (`[REQ-014 done]`)** — mesma objeção do ADR-0006: duas
  gramáticas para a mesma declaração multiplicam o parser sem ganho.
- **Trailer git (`Requirements: REQ-014=COMPLETED`)** — mais limpo para máquina,
  mas ilegível no `git log --oneline` de quem revisa, e o bloco em lista já existe
  e já é parseado.
