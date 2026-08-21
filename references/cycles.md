# Cycles

## Bootstrap

Input: existing documentation (and code only to classify already-done work).

Output: full `requirements.yaml`, baseline scope, precision, README commit section, dashboard.

This is the expensive pass. Prefer the configured bootstrap model.

Discovery order:

1. `docs/specs`, `docs/requirements`, `docs/**/*.md`
2. ADRs
3. README / OPERATIONS / architecture
4. tests and routes as hints for COMPLETED vs PLANNED

Granularity rule: one requirement = one completable behavior. Split "WhatsApp F1" into webhook, job/IA, aba Canais, persistência — do not keep a single mega-req.

## Commit burst

```
commit → reset debounce (default 10 min)
another commit → restart
timer fires → one incremental over BASE..HEAD
```

Hook writes `.dashproject/pending` and `last-commit-ts` only.

## Incremental

Input: commits in the burst + ledger rows they name.

Do not reload the whole repo. Arithmetic over the ledger is enough for the new %.

`test`/`docs` commits that cite a REQ only update `verification` and precision.

Untraced commits do not move progress; they lower traceability.

## Deep (on request)

Rediscover requirements (scope may grow), re-score precision, rebuild Reality Map. Does not rewrite COMPLETED to PLANNED without evidence of removal.

## Model routing

| Situation | Default |
|---|---|
| incremental | sonnet |
| bootstrap / deep / release | opus |

Honor `config.yaml`. A local Ollama model is valid; record it on the snapshot.
