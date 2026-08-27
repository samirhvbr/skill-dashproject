# DASHPROJECT

**Inteligência de progresso baseada em evidências para projetos desenvolvidos com agentes de IA.**

Skill: `skill-dashproject`  
Versão: 0.5.1 (A prova não é só cenário)

🇬🇧 [Read in English](README.md) — o `README.md` em inglês é a porta de entrada do repositório.

O DASHPROJECT não pergunta ao agente quanto o projeto está pronto. Ele **mede** o estado dos requisitos.

> Progresso = resultado da medição.  
> Precision = qualidade dessa medição.

Um requisito só assume **0%, 50% ou 100%**. Não existe “63% desta feature”.

```
REQ-001  100%
REQ-002  100%
…
REQ-101  100%
REQ-102   50%   ← em desenvolvimento
REQ-103    0%
…
REQ-287    0%

progress = (101×100 + 1×50 + 185×0) / 287  →  35,4%
```

---

## Para que serve

Em desenvolvimento com Claude Code (e agentes semelhantes), o implementador tende a declarar “feito”. O dashboard passa a ser um **observador independente**:

1. lê a documentação e **cria o mapa de requisitos**
2. ensina o agente a commitar com `REQ-NNN`
3. depois de um burst de commits (debounce 10 min) atualiza só os requisitos declarados
4. valida a declaração contra o diff
5. regenera YAML + Markdown (GitHub) + HTML do mesmo snapshot

`.dashproject/` não é documentação canônica do produto. É a visão do auditor.

---

## Seis pilares

| Pilar | Função |
|---|---|
| Requirement Discovery | Bootstrap a partir da documentação existente |
| Requirement Tracking | `PLANNED` 0 → `IN_PROGRESS` 50 → `COMPLETED` 100 |
| Commit Protocol | O agente declara IDs e estado no commit |
| Evidence Validation | A declaração é pretensão; o diff precisa ser plausível |
| Measurement Precision | Clareza, granularidade, rastreio, qualidade da doc |
| Dashboard | Três vistas do mesmo snapshot — YAML, MD e HTML (progresso, escopo, precisão, atividade) |

---

## Estados

| Status | Progresso |
|---|---|
| `PLANNED` | 0 |
| `IN_PROGRESS` | 50 |
| `COMPLETED` | 100 |

`status` é a fonte da verdade. O ledger **não** guarda `progress`.

Em `COMPLETED` há um segundo campo:

| completion | Significado |
|---|---|
| `declared` | Implementação plausível; testes/docs ainda fracos — continua 100% |
| `accepted` | Implementação + testes |
| `rejected` | Pretensão recusada; o status **não** fica COMPLETED |

Bootstrap é conservador: arquivo que “parece o requisito” não vira COMPLETED. Sem evidência forte → `IN_PROGRESS` ou `PLANNED` com `evidence.knownness: unknown`. O snapshot inicial grava `baseline_confidence`.

---

## Measurement Precision

O % de progresso pode ser aritmeticamente exato e mesmo assim pouco confiável.

| Fator | O que mede |
|---|---|
| Requirement clarity | Requisitos são comportamentos testáveis, com fonte na doc |
| Granularity | Nem um produto inteiro num único REQ, nem um rename |
| Commit traceability | Commits citam `REQ-` e o novo estado |
| Documentation quality | Docs oficiais existem, estão estruturados e mapeiam o ledger |

Pesos padrão: clareza 25, granularidade 20, **rastreio 35**, documentação 20. Sem `REQ-` nos commits a precision cai mesmo com docs perfeitos.

---

## Escopo ≠ progresso

Novos requisitos aumentam o denominador. Isso **não** é regressão.

```
287 reqs, 172 completos  →  60,0%
+14 reqs no escopo
301 reqs, 172 completos  →  57,1%   (o projeto cresceu)
```

IDs nunca são reciclados. Requisito removido fica `withdrawn: true` e sai do denominador.

---

## Ciclo

```
DOCUMENTAÇÃO
     │
     ▼
BOOTSTRAP  →  requirements.yaml  +  seção de commit no README
     │
     ▼
AGENTE DESENVOLVE
     │
     ▼
COMMIT feat(REQ-102): …  /  Status: IN_PROGRESS|COMPLETED
     │
     ▼
HOOK (bloco marcado) → pending
     │
     ▼
WATCH opcional (10 min) → review-due   — não chama o modelo
     │
     ▼
REVIEW incremental  →  só os REQ citados + diff
                  →  declared | accepted | rejected
                  →  collect-activity.py (git, sem LLM)
     │
     ▼
SNAPSHOT + dashboard/index.html
```

O review incremental **não** relê os 287 requisitos. Atividade do repositório sai do Git, não da prosa do agente.

---

## Três saídas, uma verdade

| Saída | Quem lê | Arquivo |
|---|---|---|
| YAML/JSON | agente e scripts | `analysis/latest.yaml`, `dashboard/data.json` |
| Markdown | humano no GitHub | `.dashproject/README.md`, `dashboard.md`, `history/daily/` |
| HTML | humano no desktop | `dashboard.html` (`xdg-open` / `firefox`) |

O renderer [scripts/render-reports.py](scripts/render-reports.py) gera os MD e o HTML a partir de `data.json`. Um markdown por **dia**, não por commit. GitHub Pages fica para depois.

---

## Atividade do repositório ≠ progresso

`git ls-files` / `git log` alimentam o pulse. `node_modules` e afins não entram.

| | Progresso | Atividade |
|---|---|---|
| Fonte | requisitos 0/50/100 | arquivos e commits rastreados |
| Esta semana | +18 COMPLETED | +310 files, churn 859 |
| Pode ser alto juntos | sim | um refactor gera muita atividade e 0% de progresso |

LOC é opcional (`activity.loc: false`). Nunca vira %.

Script: [scripts/collect-activity.py](scripts/collect-activity.py).

---

## Commit (obrigatório no repositório alvo)

No `dashproject init` esta seção é **acrescentada** ao `README.md` do projeto alvo (o restante não é reescrito).

```
feat(REQ-102): boleto generation
```

Um `REQ` no subject, sem body, já significa `IN_PROGRESS`. Declarar o estado
explicitamente também vale:

```
feat(REQ-102): implement boleto generation

Requirements:
- REQ-102: IN_PROGRESS
```

```
feat(REQ-102): complete boleto generation

Requirements:
- REQ-102: COMPLETED
```

`COMPLETED` **só** sai do bloco `Requirements:`. O verbo do subject é
decorativo — o parser não lê `complete`, `conclui`, `finaliza` nem `fecha`
([ADR-0006](docs/adr/0006-declaracao-de-status-no-commit.md)).

```
feat(REQ-102,REQ-103): boleto generation and cancellation

Requirements:
- REQ-102: IN_PROGRESS
- REQ-103: IN_PROGRESS
```

- `feat` / `fix` — podem mudar 0 → 50 → 100
- `test` / `docs` — não mudam 0/50/100; podem promover `declared` → `accepted`
- `refactor` / `chore` — sem progresso, salvo se declararem um REQ
- `chore(dashproject)` — reservado ao auditor: é o assunto com que ele **commita o
  próprio snapshot**, e o que o hook ignora. Usar esse prefixo no seu trabalho o
  torna invisível para a auditoria.

Evite misturar dezenas de requisitos não relacionados (penalidade na precision).

### Projetos que não usam Conventional Commits

Repositório com padrão próprio mantém o padrão. O bloco `Requirements:` no
**corpo** basta para declarar estado — o subject é texto livre
([ADR-0010](docs/adr/0010-subject-livre-e-bloco-requirements.md)):

```
1.63.3 - fecha a duplicata da colheita automatica

Requirements:
- REQ-014: COMPLETED
```

É o caso dos repositórios da casa, cujo padrão é `X.Y.Z - descrição em
português` e que **proíbem** Conventional Commits.

Texto completo: [assets/templates/README-COMMIT-GUIDELINES.md](assets/templates/README-COMMIT-GUIDELINES.md) e [references/commit-protocol.md](references/commit-protocol.md).

---

## Como usar (Claude Code / agente)

1. Copie esta pasta para as skills do agente (`skill-dashproject/`).
2. No repositório do produto: peça `dashproject init`.
3. Instale o hook: `dashproject hook` (insere bloco marcado; não substitui hook existente; não chama o modelo).
4. Opcional: `dashproject watch` ou o unit `dashproject-watch.service` no Debian.
5. Desenvolva com a convenção de commit acima.
6. Quando `review-due` existir (ou `pending-ready.sh` sair 0): `dashproject review`.
7. Abra `.dashproject/dashboard/index.html`.

Comandos:

| Comando | Efeito |
|---|---|
| `dashproject init` | Bootstrap: ledger + guidelines no README + dashboard |
| `dashproject review` | Análise incremental do burst |
| `dashproject deep` | Redescoberta de requisitos / precision (quando pedido) |
| `dashproject dashboard` | Regenera o HTML a partir do ledger |
| `dashproject hook` | Insere/atualiza o bloco no `post-commit` |
| `dashproject watch` | Watcher de debounce (grava `review-due`, sem LLM) |
| `dashproject activity` | Só o snapshot Git de arquivos/churn |
| `dashproject status` | Progresso, precision, pulse, escopo, delta |

**Um modelo só — Sonnet. O que escalona é o esforço, não o modelo** ([ADR-0012](docs/adr/0012-escalonamento-por-esforco.md)). O frontmatter do `SKILL.md` fixa `model: sonnet` + `effort: medium` para o incremental rotineiro; `bootstrap` escalona para `xhigh`, `deep` / `release` para `high`. Escalonar é **hand-off**: o auditor para e pede que você rode de novo naquele esforço — nunca troca sozinho. Provedor é configurável (`anthropic`, `ollama`, …).

---

## Documentação

| Página | Quando ler |
|---|---|
| [README.md](README.md) | Esta página, em inglês (porta de entrada do repositório) |
| [version.md](version.md) | Convenção de versionamento e formato de commit |
| [CHANGELOG.md](CHANGELOG.md) | Histórico por versão |
| [docs/instalacao.md](docs/instalacao.md) | Instalar a skill, o hook e o watcher |
| [docs/uso.md](docs/uso.md) | Comandos do dia a dia e o ciclo de trabalho |
| [docs/arquitetura.md](docs/arquitetura.md) | Como as peças se encaixam e por quê |
| [docs/glossario.md](docs/glossario.md) | progress, precision, completion, knownness |
| [docs/troubleshooting.md](docs/troubleshooting.md) | Quando o hook, o watch ou o review não fazem o esperado |
| [docs/adr/](docs/adr/) | Decisões de arquitetura e o motivo delas |
| [docs/padrao-documentacao.md](docs/padrao-documentacao.md) | O padrão que este repositório segue |
| [CONTRIBUTING.md](CONTRIBUTING.md) | Contribuir, testar e publicar release |

Verificação automática do padrão:

```bash
scripts/check-docs.sh
```

---

## Árvore desta skill

```
skill-dashproject/
├── SKILL.md                          # protocolo do auditor (prompt, inglês)
├── README.md                         # porta de entrada, em inglês
├── README_br.md                      # este arquivo
├── CLAUDE.md                         # contexto operacional para agentes
├── AGENTS.md                         # espelho do CLAUDE.md
├── CONTRIBUTING.md                   # como contribuir e checklist de PR
├── version.md                        # fonte da verdade da versão
├── CHANGELOG.md                      # histórico por versão
├── LICENSE                           # MIT
├── references/                       # carregado sob demanda pelo agente
│   ├── scoring.md                    # 0/50/100, precision, escopo
│   ├── ledger.md                     # schemas YAML
│   ├── cycles.md                     # bootstrap, burst, modelos
│   ├── commit-protocol.md            # parse do commit
│   ├── activity.md                   # atividade Git ≠ progresso
│   ├── outputs.md                    # as três saídas
│   └── dashboard.md                  # contrato de projeção do snapshot
├── docs/                             # documentação humana (PT-BR)
│   ├── instalacao.md
│   ├── uso.md
│   ├── arquitetura.md
│   ├── padrao-documentacao.md
│   ├── glossario.md
│   ├── troubleshooting.md
│   └── adr/                          # decisões de arquitetura
├── scripts/
│   ├── install-git-hook.sh           # instala/atualiza o bloco marcado
│   ├── hook-block.sh                 # o bloco inserido no post-commit
│   ├── post-commit.sh                # equivalente avulso do bloco
│   ├── pending-ready.sh              # 0 = review devido, 2 = no debounce
│   ├── watch.sh                      # watcher de debounce (sem LLM)
│   ├── collect-activity.py           # atividade do repositório (sem LLM)
│   ├── render-reports.py             # MD + HTML a partir de data.json
│   ├── check-docs.sh                 # consistência da documentação
│   └── build-release.sh              # empacota em dist/
├── assets/
│   ├── templates/                    # copiados para .dashproject/
│   └── dashboard/                    # index.html + data.js + data.json
├── .claude/                          # settings e comandos do Claude Code
└── .continue/                        # config e regras do Continue.dev
```

No repositório alvo o auditor cria:

```
.dashproject/
├── config.yaml
├── project.yaml
├── baseline/
├── requirements/
├── analysis/
├── agent-docs/          # Reality Map (código) vs docs oficiais (esperado)
└── dashboard/           # abrir index.html — sem npm, Docker ou banco
```

---

## Isolamento

- Quem implementa escreve código, testes, `docs/` e commits declarados.
- O DASHPROJECT só escreve `.dashproject/` e a seção de commit no README — e
  **commita isso, ele mesmo**, com `chore(dashproject)` e sem push
  ([ADR-0014](docs/adr/0014-auditor-fecha-a-propria-arvore.md)). Auditor que deixa
  arquivo sujo terceiriza o próprio commit para quem passar.
- Snapshot do próprio auditor não conta como evidência de implementação.
- Se o mesmo modelo acabou de escrever o código, a confidence daquele requisito cai.

---

## Roadmap

| Versão | Estado | Foco |
|---|---|---|
| v0.1 | entregue | Bootstrap, 0/50/100, debounce, commits com REQ, dashboard, snapshots, precision |
| v0.2 | entregue | *Reliable Requirement Tracking* — bootstrap conservador, completion declared/accepted/rejected, progress derivado, hook composto, watch, atividade Git |
| v0.3 | entregue | *Documented Foundations* — padrão de documentação, ADRs 0001–0009, contratos de schema (evidência, delta, divergências, projeção do dashboard), default de subject no commit |
| **v0.4** | **atual** | *Three Outputs, One Snapshot* — `render-reports.py`, versionamento da casa (`version.md`), README bilíngue, subject livre + bloco `Requirements:`, modelo e esforço fixados no frontmatter |
| v0.5 | planejado | Regressão explícita, timeline derivada de commits, rejeições mais ricas, burn-up histórico |
| v0.6 | planejado | Drift de spec/doc, dependências entre requisitos |
| v0.7 | planejado | Release readiness e riscos. Qualidade e segurança **como eixo separado — nunca como dimensão de percentual** ([ADR-0007](docs/adr/0007-um-numero-e-tres-estados.md)) |
| v1.0 | planejado | Project Intelligence Dashboard estável para engenharia assistida por agentes |

---

## Empacotamento

O `.zip` de distribuição **não** é versionado. Gere sob demanda:

```bash
scripts/build-release.sh          # versão lida de version.md
scripts/build-release.sh 0.4.0    # versão explícita
# → dist/skill-dashproject_v0.4.0.zip
```

---

## Licença

MIT — veja [LICENSE](LICENSE). O software auditado permanece sob a licença do
repositório alvo.
