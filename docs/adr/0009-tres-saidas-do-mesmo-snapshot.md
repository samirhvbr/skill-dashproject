# ADR-0009 — Três saídas, um snapshot

**Status:** Aceito · v0.3

## Contexto

A regra arquitetural das saídas foi enunciada assim:

> YAML é o dado. Markdown é a explicação. HTML é a visualização.

Com o motivo declarado: **evitar que o dashboard tenha uma "verdade" diferente
do relatório.** Todos derivam do mesmo snapshot.

As três representações existem no repositório, mas a regra nunca foi escrita —
e já estava quebrada. Quem escreve `agent-docs/*.md` e `dashboard/data.js` a
cada review é o modelo, à mão, sem contrato:

- `data.js` carregava `delta`, que não existe em nenhum schema YAML
  documentado.
- `data.js` chamava `precision_factors` o que `coverage.yaml` chama
  `precision:`.
- `data.json` e `data.js` tinham schemas diferentes, e a única declaração do
  papel do `data.json` vivia **dentro do próprio arquivo** — que é sobrescrito
  na primeira regeneração.
- `data.js` carregava `history` e `regressions`, campos que o `index.html`
  nunca lê e que nenhum ciclo produz.

Duas decisões de apresentação já implementadas também nunca foram registradas:
o hero com **um** KPI mais a linha que mostra a conta que o produz —
respondendo à exigência original ("o ponto importante é: **por que** 64%?") — e
a recusa do terceiro KPI no topo, porque três barras competem entre si.

## Decisão

1. O snapshot (`analysis/latest.yaml` + `requirements/coverage.yaml` +
   `activity/repository.json`) é a única fonte. As três saídas são
   **projeções**: nenhuma calcula percentual, média ou contagem por conta
   própria.
2. Nome de campo divergente é erro de projeção, não questão de estilo. O
   contrato campo a campo vive em
   [`references/dashboard.md`](../../references/dashboard.md) e é obrigatório
   no comando `dashproject dashboard`.
3. `data.js` é o que o `index.html` carrega. `data.json` é o mesmo snapshot em
   JSON puro, para consumo por outra ferramenta, escrito no mesmo passo. Em
   divergência, `analysis/latest.yaml` decide.
4. O hero tem **um** KPI (progresso) mais a linha com a conta que o produz.
   Precision fica ao lado; `baseline_confidence` fica fora do topo.
5. A camada Markdown para nos três arquivos de `agent-docs/` mais o
   `README.md` do observador. Um Markdown por review, nunca por commit.
6. Campo sem produtor é marcado como **reservado** no contrato, não removido em
   silêncio nem preenchido com placeholder.

## Consequências

- `dashproject dashboard` deixa de ser transformação sem mapa.
- Campo novo no HTML exige, antes, campo no snapshot. A ordem importa: o
  contrato é pré-requisito do gerador, não o contrário.
- Custo: mais um arquivo em `references/`, em inglês, carregado só no comando
  `dashboard`.

## Alternativas descartadas

- **`dashboard.md`, `requirements.md` e `history/*.md` no observador** — o
  próprio desenho já recusou documentação paralela demais dentro de
  `.dashproject/`, e `agent-docs/project-state.md` já renderiza no GitHub.
- **Três KPIs no hero** — progress, precision e baseline competem pela mesma
  atenção. Baseline confidence cabe em `analysis/latest.yaml` e numa linha do
  `project-state.md`.
- **Dados embutidos no HTML** — perde o consumo externo do snapshot.
- **Eliminar o `data.json`** — o consumo por outra ferramenta é barato de
  manter e não custa nada ao dashboard.
- **Escrever o gerador em script antes do contrato** — exigiria um parser YAML
  numa camada que hoje não tem dependência nenhuma, e resolveria a ordem
  errada do problema.
