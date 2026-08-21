# ADR-0006 — Declaração de status no commit: default no subject, COMPLETED explícito

**Status:** Aceito · v0.3

## Contexto

O protocolo precisa decidir quanto o commit pode declarar sozinho. Havia uma
proposta de ler a intenção do subject: `[WIP]` para começar, o verbo
`complete` para concluir. É ergonômico e foi **recusado**, por um motivo
linguístico concreto:

> Em português o agente vai escrever "conclui", "finaliza", "fecha boleto" —
> parser de intenção quebra a precisão que estamos tentando ganhar.

Esse motivo nunca foi escrito. E o repositório estava nas duas pontas erradas
ao mesmo tempo:

- `references/scoring.md` fechava a porta inteira — commit sem bloco
  `Requirements:` não mudava nada. Como consequência, o commit mais frequente
  do dia a dia (`feat(REQ-102): ...`, sem body) não movia o requisito **e**
  ainda derrubava *traceability*, o fator de maior peso na precision (35).
- Ao mesmo tempo, os quatro exemplos canônicos escreviam
  `feat(REQ-102): complete boleto generation` — sugerindo ao leitor
  exatamente a inferência de verbo que o parser não faz e não deve fazer.

## Decisão

1. `feat` ou `fix` com **exatamente um** `REQ-NNN` no subject e sem body →
   `IN_PROGRESS`. Nunca COMPLETED.
2. `COMPLETED` só com bloco `Requirements:` explícito no body (ou os aliases
   já documentados em `commit-protocol.md`).
3. Body permanece obrigatório para: qualquer COMPLETED, mais de um ID, e
   `test`/`docs` que pretendam alterar `verification`.
4. O parser **nunca** lê o verbo do subject. `complete`, `conclui`,
   `finaliza`, `fecha` são texto livre e decorativo — e os exemplos passam a
   dizer isso.

## Consequências

- O commit barato passa a mover 0 → 50 sem cerimônia, e a traceability sobe
  junto: o agente é premiado por citar o ID, não punido por não escrever o
  body.
- O erro caro continua caro de cometer: falso 100 exige declaração explícita.
- Quatro arquivos de exemplo mudam juntos, em dois idiomas — o
  [ADR-0005](0005-idioma-hibrido.md) já avisou que o protocolo de commit vive
  em três públicos e que os três se movem em conjunto.
- Assimetria proposital: começar é barato de declarar, concluir não é. Essa é
  a assimetria do risco, não uma inconsistência.

## Alternativas descartadas

- **Inferir o verbo do subject, ou `[WIP]`** — o motivo linguístico acima. Um
  parser de intenção em português erra em silêncio, e o erro produz 100 falso.
- **Marcador `[done]` como segunda sintaxe** — duas gramáticas para a mesma
  declaração multiplicam o parser sem ganho.
- **Manter body obrigatório para tudo** (status quo até aqui) — penaliza o
  commit mais comum justamente no fator de maior peso.
- **Aceitar COMPLETED pelo subject** — o falso 100 é o erro mais caro do
  sistema; é literalmente a razão de o protocolo existir.
