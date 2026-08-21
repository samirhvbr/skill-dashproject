# ADR-0001 — Progresso discreto 0/50/100 por requisito

**Status:** Aceito · v0.1

## Contexto

Percentual por feature estimado por quem implementa é opinião disfarçada de
métrica. "Essa feature está em 70%" não é auditável: não existe evidência que
distinga 70% de 60%, e o número tende a subir monotonicamente até travar em
"90% há três semanas".

## Decisão

Um requisito assume exatamente três valores:

```
PLANNED → 0    IN_PROGRESS → 50    COMPLETED → 100
```

O progresso do projeto é a média aritmética sobre os requisitos ativos.
Valores intermediários (63, 70, 80) são proibidos em qualquer camada.

## Consequências

- Cada valor tem um teste observável: existe implementação? existem testes?
- A resolução por requisito é baixa, mas a resolução **do projeto** é fina —
  com 287 requisitos cada passo vale ~0,17 ponto percentual.
- Requisito grande demais vira um degrau visível de 0,17pp para vários pontos.
  Isso é detectado pelo fator *granularity* da precision, e é uma feature: ele
  denuncia requisito mal recortado.
- Não é possível expressar "quase pronto". Por decisão: "quase pronto" é
  `IN_PROGRESS`.

## Alternativas descartadas

- **Percentual livre por requisito** — reintroduz a estimativa subjetiva.
- **Story points** — medem esforço, não estado; e continuam sendo estimativa.
- **Escala de cinco níveis (0/25/50/75/100)** — os níveis 25 e 75 não têm teste
  observável que os separe de 0 e 100. Precisão falsa.
