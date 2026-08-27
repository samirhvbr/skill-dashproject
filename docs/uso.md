# Uso

## Ciclo de trabalho

```
documentação → dashproject init → agente desenvolve com commits declarados
            → hook grava pending → debounce 10 min → review-due
            → dashproject review → snapshot + dashboard
```

O review é **incremental**: ele lê apenas os requisitos citados nos commits do
burst, nunca os 287 do ledger. É isso que mantém o custo em tokens previsível.

## Comandos

| Comando | Efeito | Modelo sugerido |
|---|---|---|
| `dashproject init` | Bootstrap: ledger + guidelines no README + dashboard | sonnet · effort `xhigh` |
| `dashproject review` | Análise incremental do burst | sonnet · effort `medium` |
| `dashproject deep` | Redescoberta de requisitos / precision | sonnet · effort `high` |
| `dashproject dashboard` | Regenera o HTML a partir do ledger | — |
| `dashproject hook` | Insere ou atualiza o bloco no `post-commit` | — |
| `dashproject watch` | Watcher de debounce (grava `review-due`) | — |
| `dashproject activity` | Só o snapshot Git de arquivos e churn | — |
| `dashproject status` | Progresso, precision, pulse, escopo, delta | — |

`dashboard`, `hook`, `watch` e `activity` não consomem tokens.

## Declarando trabalho no commit

```
feat(REQ-102): implement boleto generation

Requirements:
- REQ-102: IN_PROGRESS
```

Quando o comportamento estiver pronto:

```
feat(REQ-102): complete boleto generation

Requirements:
- REQ-102: COMPLETED
```

Para **começar** um requisito o body é dispensável — o subject basta:

```
feat(REQ-102): boleto generation
```

→ `REQ-102: IN_PROGRESS`

Regras que valem a pena decorar:

- Um `REQ` no subject, sem body, em `feat`/`fix` → `IN_PROGRESS`.
- `COMPLETED` **só** com o bloco `Requirements:` no body. O verbo do subject
  (`complete`, `conclui`, `finaliza`) é decorativo e nunca é lido —
  [ADR-0006](adr/0006-declaracao-de-status-no-commit.md).
- `feat` / `fix` podem mover 0 → 50 → 100.
- `test` / `docs` **não** movem o estado; podem promover `declared` → `accepted`.
- `refactor` / `chore` não mexem em progresso, salvo se declararem um REQ.
- `chore(dashproject)` é reservado ao auditor — é o assunto com que ele commita o
  próprio snapshot ao fim do review, e o que o hook ignora
  ([ADR-0014](adr/0014-auditor-fecha-a-propria-arvore.md)).
- Prefira ≤3 IDs por commit. Acima de 5 há penalidade de precision.

Referência completa: [`references/commit-protocol.md`](../references/commit-protocol.md).

## Lendo o resultado

```
PROGRESS 62.4%   PRECISION 94%
172 COMPLETED (151 accepted / 21 declared) · 14 IN_PROGRESS · 101 PLANNED
+7 completed this burst   BASE abc123 → HEAD jkl012
scope 287 → 287
PULSE  1842 files  +310 this week  71 commits  churn 859
rejected: REQ-118 (diff unrelated)
```

Duas leituras independentes:

- **PROGRESS** é aritmética sobre `status`. Sempre exato.
- **PRECISION** é o quanto aquele número merece confiança. `62,4%` com
  precision `57%` é um número fraco — provavelmente os commits não citam `REQ-`.

`PULSE` é atividade de repositório. Alta atividade com pouco movimento de
requisito é normal em semanas de refactor e **não** derruba o progresso.

## Qual modelo e qual esforço roda cada ciclo

**Um modelo só — `sonnet`. O que escalona é o esforço, não o modelo**
([ADR-0012](adr/0012-escalonamento-por-esforco.md)). Custo contra frequência: o
que roda a cada burst leva o orçamento pequeno; o que é lido uma vez e é caro de
desfazer leva o grande.

| Situação | Esforço |
|---|---|
| review incremental (todo burst) | `medium` — o default do frontmatter |
| `bootstrap` | `xhigh` — escreve o mapa inteiro e o baseline |
| `deep`, `release` | `high` |
| `low_confidence` — confidence < 60, ou `knownness: unknown` num COMPLETED | `high` |
| `major_divergence` — diff contradiz o requisito, ou > 5 reqs num commit | `high` |

Escalonar **não é automático**: o auditor para, nomeia a condição e o requisito,
e pede que você rode de novo naquele esforço (ADR-0011 §3). Os valores válidos
são `low` · `medium` · `high` · `xhigh` · `max` — nome de modelo ali é erro, e o
`scripts/check-docs.sh` reprova.

O escalonamento vale para **aquele requisito**, não para o burst inteiro.
Configurável em `.dashproject/config.yaml` → `analysis.escalate`.

## Coletar atividade manualmente

```bash
python3 scripts/collect-activity.py --root . -o .dashproject/activity/repository.json
python3 scripts/collect-activity.py --root . --loc     # LOC é opcional e nunca vira %
```
