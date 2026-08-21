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
| `dashproject init` | Bootstrap: ledger + guidelines no README + dashboard | bootstrap (opus) |
| `dashproject review` | Análise incremental do burst | incremental (sonnet) |
| `dashproject deep` | Redescoberta de requisitos / precision | opus |
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

Regras que valem a pena decorar:

- `feat` / `fix` podem mover 0 → 50 → 100.
- `test` / `docs` **não** movem o estado; podem promover `declared` → `accepted`.
- `refactor` / `chore` não mexem em progresso, salvo se declararem um REQ.
- `chore(dashproject)` é reservado ao auditor — o hook ignora.
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

## Coletar atividade manualmente

```bash
python3 scripts/collect-activity.py --root . -o .dashproject/activity/repository.json
python3 scripts/collect-activity.py --root . --loc     # LOC é opcional e nunca vira %
```
