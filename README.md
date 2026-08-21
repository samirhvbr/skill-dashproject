# DASHPROJECT

**Inteligência de progresso baseada em evidências para projetos desenvolvidos com agentes de IA.**

Skill: `skill-dashproject`  
Versão: 0.1

O DASHPROJECT não pergunta ao agente quanto o projeto está pronto. Ele **mede** o estado dos requisitos.

> Progresso = resultado da medição.  
> Precision = qualidade dessa medição.

Um requisito só assume **0%, 50% ou 100%**. Não existe “63% desta feature”.

```
R001  100%
R002  100%
…
R101  100%
R102   50%   ← em desenvolvimento
R103    0%
…
R287    0%

progress = (101×100 + 1×50 + 185×0) / 287  →  35,4%
```

---

## Para que serve

Em desenvolvimento com Claude Code (e agentes semelhantes), o implementador tende a declarar “feito”. O dashboard passa a ser um **observador independente**:

1. lê a documentação e **cria o mapa de requisitos**
2. ensina o agente a commitar com `REQ-NNN`
3. depois de um burst de commits (debounce 10 min) atualiza só os requisitos declarados
4. valida a declaração contra o diff
5. regenera um dashboard HTML estático

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
| Dashboard | HTML estático — progresso, escopo, precisão, histórico |

---

## Estados

| Status | Progresso |
|---|---|
| `PLANNED` | 0 |
| `IN_PROGRESS` | 50 |
| `COMPLETED` | 100 |

`verification` (implementação / testes / docs) e `confidence` **não** alteram o percentual. Teste faltando em um `COMPLETED` aceito baixa confiança e gera flag; não devolve o requisito para 63%.

Se o commit diz `COMPLETED` e o diff não toca nada relacionado, o estado **não** sobe. Fica 50 (ou o anterior) e entra em `rejected_claims`.

---

## Measurement Precision

O % de progresso pode ser aritmeticamente exato e mesmo assim pouco confiável.

| Fator | O que mede |
|---|---|
| Requirement clarity | Requisitos são comportamentos testáveis, com fonte na doc |
| Granularity | Nem um produto inteiro num único REQ, nem um rename |
| Commit traceability | Commits citam `REQ-` e o novo estado |
| Documentation quality | Docs oficiais existem, estão estruturados e mapeiam o ledger |

Um projeto com 287 requisitos claros e commits padronizados pode ter precision 94%. Outro com 47 itens vagos e `fix stuff` fica perto de 50% — e o 73% de progresso deve ser lido com essa ressalva.

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
DEBOUNCE 10 min (burst A+B+C+D vira uma análise)
     │
     ▼
REVIEW incremental  →  só os REQ citados + diff
     │
     ▼
SNAPSHOT + dashboard/index.html
```

O review incremental **não** relê os 287 requisitos. É isso que segura o custo de tokens.

---

## Commit (obrigatório no repositório alvo)

No `dashproject init` esta seção é **acrescentada** ao `README.md` do projeto alvo (o restante não é reescrito).

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

```
feat(REQ-102,REQ-103): boleto generation and cancellation

Requirements:
- REQ-102: IN_PROGRESS
- REQ-103: IN_PROGRESS
```

- `feat` / `fix` — podem mudar 0 → 50 → 100
- `test` / `docs` — só evidência / confiança
- `refactor` / `chore` — sem progresso, salvo se declararem um REQ
- `chore(dashproject)` — reservado ao auditor (o hook ignora)

Evite misturar dezenas de requisitos não relacionados (penalidade na precision).

Texto completo: [assets/templates/README-COMMIT-GUIDELINES.md](assets/templates/README-COMMIT-GUIDELINES.md) e [references/commit-protocol.md](references/commit-protocol.md).

---

## Como usar (Claude Code / agente)

1. Copie esta pasta para as skills do agente (`skill-dashproject/`).
2. No repositório do produto: peça `dashproject init`.
3. Instale o hook: `dashproject hook` (grava pending; não chama o modelo).
4. Desenvolva com a convenção de commit acima.
5. Após 10 minutos sem commit novo: `dashproject review`.
6. Abra `.dashproject/dashboard/index.html` no navegador.

Comandos:

| Comando | Efeito |
|---|---|
| `dashproject init` | Bootstrap: ledger + guidelines no README + dashboard |
| `dashproject review` | Análise incremental do burst |
| `dashproject deep` | Redescoberta de requisitos / precision (quando pedido) |
| `dashproject dashboard` | Regenera o HTML a partir do ledger |
| `dashproject hook` | Instala `post-commit` |
| `dashproject status` | Imprime progresso, precision, escopo, delta |

Modelo padrão: Sonnet no incremental. Opus (ou o que estiver em `config.yaml`) no bootstrap / deep / release. Provedor é configurável (`anthropic`, `ollama`, …).

---

## Árvore desta skill

```
skill-dashproject/
├── SKILL.md                          # protocolo do auditor
├── README.md                         # este arquivo
├── references/
│   ├── scoring.md                    # 0/50/100, precision, escopo
│   ├── ledger.md                     # schemas YAML
│   ├── cycles.md                     # bootstrap, burst, modelos
│   └── commit-protocol.md            # parse do commit
├── scripts/
│   ├── install-git-hook.sh
│   ├── post-commit.sh
│   └── pending-ready.sh
└── assets/
    ├── templates/                    # copiados para .dashproject/
    └── dashboard/                    # index.html estático
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
- O DASHPROJECT só escreve `.dashproject/` e a seção de commit no README.
- Snapshot do próprio auditor não conta como evidência de implementação.
- Se o mesmo modelo acabou de escrever o código, a confidence daquele requisito cai.

---

## Roadmap

| Versão | Foco |
|---|---|
| **v0.1** | Bootstrap, 0/50/100, debounce, commits com REQ, dashboard, snapshots, precision |
| v0.2 | Histórico/Gantt por requisito, rejeições mais ricas, regressão explícita |
| v0.3 | Drift de spec/doc, ADRs, dependências entre requisitos |
| v0.4 | Release readiness, riscos |
| v1.0 | Project Intelligence Dashboard estável para engenharia assistida por agentes |

---

## Licença

MIT (skill). O software auditado permanece sob a licença do repositório alvo.
