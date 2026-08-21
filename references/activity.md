# Repository activity

Independent of progress. **Progress = requirements. Activity = git-tracked tree.**

The agent must not count files by hand and must not write “criei 17 arquivos” as evidence. Run [scripts/collect-activity.py](../scripts/collect-activity.py).

## Source

`git ls-files` and `git log` only. Ignored / untracked trees (`node_modules`, `vendor`, `dist`, `.cache`) do not count unless someone committed them.

## When

Same cycle as bootstrap and incremental review. Cheap. No extra model tokens.

```
python3 scripts/collect-activity.py --root <repo> -o .dashproject/activity/repository.json
```

`--loc` is optional and off by default. LOC is never progress.

## Output

`.dashproject/activity/repository.json` plus a copy under `.dashproject/activity/history/YYYY-MM-DD.json` (one per calendar day is enough).

Merge the JSON into `dashboard/data.js` as `activity`. Add requirement deltas from the ledger (`week.requirements_completed`, `week.requirements_started`) — those come from the snapshot, not from git.

## Pulse

If this week `files_created` is high and `requirements_completed` is low, add a dashboard note: high repository activity, little requirement movement. Do not lower progress. Refactors, tests, and infra are legitimate.

## Classification of created files

`source` `tests` `documentation` `configuration` `infrastructure` `other`.

## Forbidden

- Using file count, churn, or LOC as `%` of the project
- Scanning the working tree without git
- Asking the coding agent to describe how many files it created
