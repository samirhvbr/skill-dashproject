# ADR-0008 — A timeline é retrospectiva; o DASHPROJECT não faz previsão

**Status:** Aceito · v0.3

## Contexto

O pedido original citava "gráficos ao estilo MS Project". MS Project é, antes
de tudo, uma ferramenta de **cronograma**: datas planejadas, duração estimada,
caminho crítico, data prevista de término.

A definição do Gantt no desenho fechado é outra: requisitos ao longo do
**histórico de commits**, sem estimar duração. E cronograma, velocity e
forecast entraram explicitamente na lista do que não fazer.

O repositório fazia o oposto. O empty state do dashboard instruía literalmente:

```
Add start/due on epics in project.yaml to draw the Gantt.
```

Essa era a **única** orientação escrita ao usuário sobre a timeline — e ela
pedia datas planejadas. O template de épico trazia `start:` e `due:` para
preencher à mão. Nenhuma linha em `docs/` ou `references/` dizia que previsão
está fora do escopo.

O detalhe que torna isso perigoso: `SKILL.md` diz "Progress is measured, not
estimated" e o ADR-0001 fala de **progresso**, não de **data**. Uma projeção de
conclusão não mexeria em nenhum percentual — passaria por baixo dos dois.

## Decisão

1. O eixo da timeline é **retrospectivo**, derivado do Git: início do requisito
   é o primeiro commit que o declara `IN_PROGRESS`; fim é o commit ou snapshot
   que o marca `COMPLETED`. Requisito sem commit não aparece na timeline.
2. `due` é marco **declarado por humano**. Pode ser desenhado como linha
   vertical, nunca entra em cálculo.
3. Não existem no modelo: velocity, data prevista de conclusão, "atrasa N
   dias", percentual de cronograma cumprido, burn-down com projeção.
4. Enquanto a derivação por commits não existir, o empty state deixa de
   instruir datas planejadas e passa a dizer que a timeline aparece quando
   houver commits declarados.

## Consequências

- O Gantt fica vazio no bootstrap. Isso é **correto**, não é bug: antes do
  primeiro commit declarado não há histórico a desenhar.
- `start` sai do template de épico. `due` fica, como marco.
- A seção Timeline permanece vazia até a derivação existir (roadmap v0.4). Isso
  é preferível a exibir um cronograma que o sistema não sabe sustentar.
- Qualquer pedido futuro de forecast tem resposta escrita, em vez de ser
  re-litigado do zero.

## Alternativas descartadas

- **Gantt por datas de épico digitadas à mão** — era o que o dashboard
  instruía. É exatamente o cronograma que foi recusado: transforma o auditor
  em planilha de planejamento e reintroduz estimativa numa ferramenta cujo
  propósito é medir evidência.
- **Forecast a partir de velocity de requisitos por semana** — reintroduz
  estimativa pela porta dos fundos e converte atividade em previsão, contra o
  [ADR-0004](0004-atividade-separada-de-progresso.md).
- **Remover a seção Timeline por completo** — a versão retrospectiva foi
  aprovada no desenho; ela só não foi construída ainda.
