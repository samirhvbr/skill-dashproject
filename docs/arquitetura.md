# Arquitetura

## Princípio central

O implementador é parte interessada. Perguntar a ele "quanto está pronto?"
produz um número que ninguém pode auditar. O DASHPROJECT troca a pergunta por
uma **medição sobre evidência**.

```
declaração do agente  →  validação contra o diff  →  status  →  progresso derivado
     (pretensão)              (evidência)          (verdade)      (aritmética)
```

## Camadas

| Camada | Onde vive | Chama modelo? |
|---|---|---|
| Protocolo do auditor | `SKILL.md`, `references/**` | sim — é prompt |
| Captura de evento | `scripts/hook-block.sh` via `post-commit` | **não** |
| Debounce | `scripts/watch.sh`, `scripts/pending-ready.sh` | **não** |
| Atividade do repositório | `scripts/collect-activity.py` | **não** |
| Estado | `.dashproject/**` no projeto auditado | — |
| Apresentação | `assets/dashboard/index.html` + `data.js` | **não** |

Só a primeira camada custa tokens. Foi desenhado assim de propósito: o hook
dispara em todo commit, e um hook que chamasse um modelo seria caro e lento.
Veja [adr/0003-hook-sem-llm-e-debounce.md](adr/0003-hook-sem-llm-e-debounce.md).

## Fluxo de um burst de commits

```
commit ──▶ post-commit (bloco marcado)
            │  grava .dashproject/pending
            │  grava .dashproject/last-commit-ts
            │  remove .dashproject/review-due
            ▼
        watch.sh (poll, padrão 30s)
            │  pending-ready.sh: age >= debounce_minutes ?
            ▼
        .dashproject/review-due
            │
            ▼
        sessão do agente vê review-due ──▶ dashproject review
            │  git log BASE..HEAD, ignorando chore(dashproject)
            │  parse dos REQ declarados
            │  lê SÓ as linhas do ledger citadas + o diff
            │  aplica status + completion
            ▼
        snapshot + collect-activity.py + dashboard
            │
            ▼
        commit-snapshot.sh ──▶ commit `chore(dashproject): …`
            │  só `.dashproject/`, sem push
            ▼
        post-commit vê o assunto e NÃO rearma · árvore limpa
```

O watcher **não** invoca o modelo. Ele sinaliza. Quem invoca é a sessão do
agente ao encontrar `review-due` (ou `pending-ready.sh` saindo 0).

## Isolamento de escrita

| Ator | Pode escrever |
|---|---|
| Implementador | código, testes, `docs/` oficial, commits declarados |
| DASHPROJECT | `.dashproject/**` e a seção de commit do `README.md` — e **commita** isso, com `chore(dashproject)`, sem push ([ADR-0014](adr/0014-auditor-fecha-a-propria-arvore.md)) |

O auditor nunca edita código-fonte, e o implementador nunca edita o ledger.
Se o mesmo modelo escreveu o código e auditou o requisito, a `confidence`
daquele requisito cai 15 pontos.

## Estado no projeto auditado

```
.dashproject/
├── README.md                         porta de entrada do observador
├── config.yaml                       ajustes: debounce, modelo, pesos
├── project.yaml                      nome, fontes de documentação, épicos
├── baseline/project-baseline.yaml    escopo e confiança do bootstrap
├── requirements/requirements.yaml    o ledger — status é a verdade
├── requirements/coverage.yaml        rollup; aqui progress é derivado
├── analysis/latest.yaml              snapshot corrente
├── analysis/history/<iso>.yaml       histórico de snapshots
├── analysis/divergences.yaml         doc esperada × código real
├── activity/repository.json          saída do collect-activity.py
├── activity/history/YYYY-MM-DD.json  uma cópia por dia
├── agent-docs/                       lista FECHADA de três arquivos
│   └── project-state.md              leitura curta do estado
├── agent-docs/implementation-map.md  o que o código É
├── agent-docs/gap-analysis.md        planejado × completo × rejeitado,
│                                     e a justificativa de escopo
└── dashboard/index.html              abrir direto no navegador
```

Arquivos efêmeros criados pelo hook e pelo watcher, na raiz de `.dashproject/`:
`pending`, `last-commit-ts`, `review-due`, além das cópias executáveis
`watch.sh`, `pending-ready.sh` e `collect-activity.py`.

## Três representações do mesmo snapshot

> YAML é o dado. Markdown é a explicação. HTML é a visualização.

O motivo é um só: **evitar que o dashboard tenha uma verdade diferente do
relatório.** As três derivam do mesmo snapshot e nenhuma recalcula nada —
copiam. Nome de campo divergente é bug de projeção, não estilo. O contrato
campo a campo está em
[`references/dashboard.md`](../references/dashboard.md).

O hero carrega **um** KPI e a conta que o produz:

```
62.4% = (172 × 100 + 14 × 50 + 101 × 0) / 287
```

Isso responde à pergunta que justifica a ferramenta existir — *por que esse
número?* — e é o motivo de não haver um terceiro KPI competindo no topo.
Detalhes em [ADR-0009](adr/0009-tres-saidas-do-mesmo-snapshot.md).

## Escalonamento por risco

O modelo é escolhido por custo contra frequência e reversibilidade: o que roda
a cada burst usa o modelo barato; o que é lido uma vez e é caro de desfazer usa
o caro.

| Ciclo | Modelo |
|---|---|
| incremental (todo burst) | sonnet |
| bootstrap, deep, release | opus |
| `low_confidence`, `major_divergence` | escalona **aquele requisito**, não o burst |

## Por que 0/50/100

Um requisito em "70%" é opinião. Em `IN_PROGRESS` é fato observável. A perda de
resolução por requisito é recuperada pela **quantidade** de requisitos: com 287
linhas, a média move em passos de ~0,17 ponto percentual — resolução mais do que
suficiente. Veja [adr/0001-progresso-discreto.md](adr/0001-progresso-discreto.md).

## Progresso × atividade

São eixos ortogonais e o dashboard mostra os dois lado a lado.

| | Progresso | Atividade |
|---|---|---|
| Fonte | `status` dos requisitos | `git ls-files`, `git log` |
| Unidade | % derivado de 0/50/100 | arquivos, commits, churn |
| Semana de refactor | pode ficar em 0 | alta |
| Pode virar % do projeto? | é o % | **nunca** |

Ver [adr/0004-atividade-separada-de-progresso.md](adr/0004-atividade-separada-de-progresso.md).
