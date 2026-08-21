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

On every bootstrap and review, run `collect-activity.py` (git-tracked files only) then `render-reports.py`. Activity never changes requirement status. See [activity.md](activity.md), [outputs.md](outputs.md) and [dashboard.md](dashboard.md).

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

**One model — `sonnet`. What escalation changes is the effort, not the model**
([ADR-0012](../docs/adr/0012-escalonamento-por-esforco.md)). Honor `config.yaml`.

| Cycle | Effort |
|---|---|
| incremental review (every burst) | `medium` |
| `bootstrap` | `xhigh` |
| `deep`, `release` | `high` |

The principle is cost against frequency and reversibility: what runs on every
burst gets the small budget; what is read once and hard to undo gets the large
one. `bootstrap` sits alone at the top because it writes the entire requirement
map and the baseline — the number everyone reads afterwards.

The **routine** half of that is imposed, not suggested: `SKILL.md` frontmatter
pins `model: sonnet` and `effort: medium`, and `scripts/check-docs.sh` fails if
either stops matching `config.yaml`, or if any `escalate` value is not a valid
effort level — a model name there is a failure
([ADR-0011](../docs/adr/0011-modelo-e-esforco-no-frontmatter.md) §2,
[ADR-0012](../docs/adr/0012-escalonamento-por-esforco.md) §5).

`config.yaml` → `analysis.escalate` also names two risk conditions, and they
are conditions, not decoration:

| Condition | Escalate when |
|---|---|
| `low_confidence` | the burst produces requirements with `confidence` below 60, or `evidence.knownness: unknown` on a COMPLETED claim |
| `major_divergence` | the diff contradicts the declared requirement, or more than 5 reqs are declared in one commit |

Both escalate to `high`.

**Escalation is a hand-off, not an automatic switch.** A skill cannot change its
own effort mid-run. So on `bootstrap` / `deep` / `release`, or on either
condition above: **stop, name the condition and the requirement, and ask the
operator to re-run at the escalated effort.** Then redo that requirement's
validation — not the whole burst — at the new effort.

Never write status from an escalation condition while still running at the
routine effort. Record the model and effort that actually ran in
`analysis/latest.yaml` → `model` / `effort`; they are observations, never copies
of `config.yaml`.
