# Three representations, one snapshot

```
YAML/JSON  →  agent / scripts     (data)
Markdown   →  humans / GitHub     (explanation)
HTML       →  humans locally      (visualization)
```

Never compute a number in HTML or MD that is not in `analysis/latest.yaml` + `dashboard/data.json`.

GitHub Pages is optional and out of v0.2.

## After every review

1. Write structured snapshot (`analysis/latest.yaml`, `requirements/coverage.yaml`, `activity/repository.json`).
2. Merge into `.dashproject/dashboard/data.json`.
3. Run [scripts/render-reports.py](../scripts/render-reports.py) `--root <repo>`.

That script writes:

| File | Role |
|---|---|
| `.dashproject/README.md` | GitHub entry — progress bar, pulse, link to HTML |
| `.dashproject/dashboard.md` | Official readable report |
| `.dashproject/analysis/latest.md` | This burst |
| `.dashproject/history/daily/YYYY-MM-DD.md` | One file per day (overwrite same day) |
| `.dashproject/history/daily/YYYY-MM-DD.json` | Same snapshot, structured |
| `.dashproject/dashboard.html` | Visual, opens with `firefox` / `xdg-open` |
| `.dashproject/dashboard/data.js` | Data for the HTML |

## History density

One analysis per commit burst (10 min). One **daily** markdown, not one file per commit.

Weekly rollup is optional later (`history/weekly/`). Do not add it unless asked.

## Agent vs human

- Agent reads YAML/JSON.
- Human on GitHub reads README.md / dashboard.md / history.
- Human at the desk opens `dashboard.html`.

Do not maintain a fourth set of numbers in `agent-docs/`. Those files stay qualitative (Reality Map, gaps).
