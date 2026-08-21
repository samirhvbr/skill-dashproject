# ADR-0004 — Atividade do repositório é independente do progresso

**Status:** Aceito · v0.2

## Contexto

Agentes de código relatam volume: "criei 17 arquivos", "escrevi 2.300 linhas".
Isso é convincente e irrelevante — mede esforço, não resultado. Pior: convida a
converter volume em percentual, e aí uma semana de refactor "avança o projeto"
sem entregar nenhum comportamento novo.

Ao mesmo tempo, volume **é** informação útil de gestão: um repositório parado é
diferente de um repositório fervendo.

## Decisão

Manter os dois eixos, medidos por fontes diferentes, e nunca somá-los.

| | Progresso | Atividade |
|---|---|---|
| Fonte | `status` dos requisitos | `git ls-files`, `git log` |
| Quem produz | protocolo do auditor (modelo) | `collect-activity.py` (sem modelo) |
| Vira % do projeto? | é o % | **nunca** |

Regras de coleta:

- Só o que está rastreado pelo Git. `node_modules/`, `vendor/`, `dist/` ficam
  de fora a menos que alguém os tenha commitado.
- É **proibido** perguntar ao agente implementador quantos arquivos ele criou.
- LOC é opcional (`activity.loc: false` por padrão) e nunca vira percentual.
- Arquivos criados são classificados em `source`, `tests`, `documentation`,
  `configuration`, `infrastructure`, `other`.

Quando a semana tem muitos arquivos criados e pouco movimento de requisito, o
dashboard escreve uma nota. Ele **não** mexe no percentual.

## Consequências

- Atividade é barata: sai do Git, sem tokens.
- Refactor, testes e infra aparecem como trabalho legítimo sem falsear progresso.
- Um projeto pode mostrar pulse alto e progresso parado — e isso é uma leitura
  correta, não um bug.

## Alternativas descartadas

- **Ponderar progresso por LOC** — premia código verboso.
- **Contar arquivos como proxy de escopo** — um `index.ts` de reexport pesaria
  o mesmo que um módulo de domínio.
- **Varrer a árvore de trabalho em vez do Git** — contaria dependências
  instaladas e artefatos de build.
