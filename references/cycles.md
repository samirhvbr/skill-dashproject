# Cycles

## Bootstrap

Conservative classification only. See scoring.

Output: `requirements.yaml`, baseline scope, precision, `baseline_confidence`, README commit section, dashboard.

Prefer the configured bootstrap model.

## Commit burst

```
commit → hook writes pending + timestamp
       → watch (optional) waits debounce_minutes
       → review-due
       → agent runs incremental (never the hook, never the watcher)
```

`scripts/pending-ready.sh` exits 0 when a review is owed.

## Incremental

Input: burst commits + named ledger rows. Do not reread the whole repo.

Apply status + `completion` from scoring. `test`/`docs` may upgrade `declared` → `accepted`.

Also check for regression: a requirement that was COMPLETED in
`analysis/history` and no longer is goes to `latest.yaml` → `regressions`. That
is not the same as the percentage falling because scope grew.

On every bootstrap and review, run `collect-activity.py` (git-tracked files only). Activity never changes requirement status. See [activity.md](activity.md).

Regenerate all three outputs from the same snapshot, per
[dashboard.md](dashboard.md). One Markdown per review — never per commit.

## Watch

`dashproject watch` runs [scripts/watch.sh](../scripts/watch.sh). It only writes `.dashproject/review-due`. Optional `review_notify` in config is a local command (e.g. `systemctl --user start …`); it must not be treated as “call the model”.

Debian user unit: `assets/templates/dashproject-watch.service`.

## Hook install

[scripts/install-git-hook.sh](../scripts/install-git-hook.sh) inserts or refreshes the block between `# >>> DASHPROJECT >>>` and `# <<< DASHPROJECT <<<`. Existing hook body outside the markers is left untouched.

## Deep

Rediscover requirements on request. Do not demote COMPLETED without evidence of removal.

## Model routing

incremental → sonnet. bootstrap / deep / release → opus. Honor `config.yaml`.

The principle is cost against frequency and reversibility: what runs on every
burst uses the cheap model; what is read once and hard to undo uses the
expensive one.

`config.yaml` → `analysis.escalate` also names two risk conditions, and they
are conditions, not decoration:

| Condition | Escalate when |
|---|---|
| `low_confidence` | the burst produces requirements with `confidence` below 60, or `evidence.knownness: unknown` on a COMPLETED claim |
| `major_divergence` | the diff contradicts the declared requirement, or more than 5 reqs are declared in one commit |

On escalation, redo that requirement's validation with the escalated model
before writing status. Do not escalate the whole burst.
