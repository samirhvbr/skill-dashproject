#!/usr/bin/env python3
"""Render README.md + dashboard.md from dashboard/data.json. Same snapshot, three views."""
from __future__ import annotations

import argparse
import json
import shutil
from datetime import date
from pathlib import Path


def bar(pct: float, width: int = 22) -> str:
    n = max(0, min(width, round((pct or 0) / 100 * width)))
    return "█" * n + "░" * (width - n)


def pct(n) -> str:
    try:
        return f"{float(n):.1f}%"
    except (TypeError, ValueError):
        return "0.0%"


def load(path: Path) -> dict:
    return json.loads(path.read_text(encoding="utf-8"))


def readme(d: dict) -> str:
    c = d.get("counts") or {}
    a = d.get("activity") or {}
    cur = a.get("current") or {}
    wk = a.get("week") or {}
    git = a.get("git") or {}
    progress = d.get("progress") or 0
    name = d.get("project") or "project"
    return f"""# DASHPROJECT

> Evidence-based project progress tracking for **{name}**.

Observer only. Official docs stay in `docs/`. Do not edit this tree to inflate progress.

**[Open dashboard](dashboard.html)** · [dashboard.md](dashboard.md) · [latest](analysis/latest.md)

### Project Progress

**{pct(progress)}**

`{bar(progress)}`

### Measurement Precision

**{pct(d.get("precision") or 0)}**

### Requirements

```
{c.get("completed", 0)} Completed
{c.get("in_progress", 0)} In Progress
{c.get("planned", 0)} Planned
{c.get("active") or (c.get("completed", 0) + c.get("in_progress", 0) + c.get("planned", 0))} Total
```

Completed split: {c.get("completed_accepted", 0)} accepted / {c.get("completed_declared", 0)} declared.

### Repository

```
{cur.get("files", 0)} Files
{cur.get("directories", 0)} Directories
{git.get("commits", 0)} Commits
```

Git-tracked only. File counts are activity, not progress.

### This Week

```
+{wk.get("files_created", 0)} Files
+{wk.get("directories_created", 0)} Directories
+{wk.get("commits", 0)} Commits
+{wk.get("requirements_completed", 0)} Requirements completed
```

HEAD `{d.get("head") or "—"}` · snapshot #{d.get("snapshot") or "—"} · {d.get("generated") or ""}
"""


def dashboard_md(d: dict, prefixo: str = "") -> str:
    """O relatorio. `prefixo` corrige os links relativos quando o MESMO texto e
    escrito em `history/daily/`, dois niveis abaixo — sem ele o link para o
    `dashboard.html` aponta para dentro de `history/daily/`, e a L1 do docs-lint
    do EOP acusou isso no primeiro bootstrap real (22/08)."""
    c = d.get("counts") or {}
    a = d.get("activity") or {}
    cur = a.get("current") or {}
    wk = a.get("week") or {}
    git = a.get("git") or {}
    sc = d.get("scope") or {}
    active = c.get("active") or (
        c.get("completed", 0) + c.get("in_progress", 0) + c.get("planned", 0)
    )
    completed = c.get("completed", 0)
    in_prog = c.get("in_progress", 0)
    planned = c.get("planned", 0)
    den = active or 1
    epics = d.get("epics") or []
    epic_rows = "\n".join(
        f"| {e.get('name') or e.get('id')} | {pct(e.get('progress'))} |"
        for e in epics
    ) or "| — | — |"
    rejected = d.get("rejected_claims") or []
    rej = "\n".join(
        f"- `{r.get('id')}` {r.get('declared', '')} — {r.get('reason', '')}"
        for r in rejected
    ) or "_None._"
    kinds = wk.get("created_by_kind") or {}
    kind_rows = "\n".join(f"| {k} | {v} |" for k, v in kinds.items()) or "| — | 0 |"
    return f"""# DASHPROJECT

**Project Progress: {pct(d.get("progress"))}**

**Measurement Precision: {pct(d.get("precision"))}**

`{bar(d.get("progress") or 0)}`

| Status | Requirements | Share of scope |
| --- | ---: | ---: |
| Completed | {completed} | {pct(100 * completed / den)} |
| In Progress | {in_prog} | {pct(100 * in_prog / den)} |
| Planned | {planned} | {pct(100 * planned / den)} |
| Active total | {active} | 100% |

Accepted / declared among completed: {c.get("completed_accepted", 0)} / {c.get("completed_declared", 0)}.

Scope: original {sc.get("original", active)} → current {sc.get("current", active)} (added {sc.get("added", 0)}, removed {sc.get("removed", 0)}).

### Project Activity

| Metric | Total | This week |
| --- | ---: | ---: |
| Files | {cur.get("files", 0)} | +{wk.get("files_created", 0)} |
| Directories | {cur.get("directories", 0)} | +{wk.get("directories_created", 0)} |
| Commits | {git.get("commits", 0)} | +{wk.get("commits", 0)} |
| Churn | — | {wk.get("churn", 0)} |
| Requirements completed | — | +{wk.get("requirements_completed", 0)} |
| Requirements started | — | +{wk.get("requirements_started", 0)} |

Created this week by kind:

| Kind | Files |
| --- | ---: |
{kind_rows}

### Epics

| Epic | Progress |
| --- | ---: |
{epic_rows}

### Rejected claims

{rej}

YAML is the data. This file is the explanation. [dashboard.html]({prefixo}dashboard.html) is the visualization.
"""


def latest_md(d: dict) -> str:
    dlt = d.get("delta") or {}
    return f"""# Snapshot #{d.get("snapshot") or "—"}

- generated: {d.get("generated") or ""}
- level: {d.get("level") or ""}
- model: {d.get("model") or ""}{" · effort: " + str(d.get("effort")) if d.get("effort") else ""}
- base: `{d.get("base") or "—"}`
- head: `{d.get("head") or "—"}`
- progress: {pct(d.get("progress"))} ({dlt.get("progress", 0):+.1f})
- precision: {pct(d.get("precision"))}
- completed delta: +{dlt.get("completed", 0)}
- started delta: +{dlt.get("started", 0)}
- baseline_confidence: {d.get("baseline_confidence")}

See [dashboard.md](../dashboard.md).
"""


def write(path: Path, text: str) -> None:
    path.parent.mkdir(parents=True, exist_ok=True)
    path.write_text(text.rstrip() + "\n", encoding="utf-8")


def main() -> None:
    ap = argparse.ArgumentParser()
    ap.add_argument("--root", default=".")
    ap.add_argument("--data")
    args = ap.parse_args()
    root = Path(args.root).resolve()
    dash = root / ".dashproject"
    data_path = Path(args.data) if args.data else dash / "dashboard" / "data.json"
    d = load(data_path)

    write(dash / "README.md", readme(d))
    write(dash / "dashboard.md", dashboard_md(d))
    write(dash / "analysis" / "latest.md", latest_md(d))

    day = date.today().isoformat()
    write(dash / "history" / "daily" / f"{day}.md", dashboard_md(d, "../../"))
    dest_json = dash / "history" / "daily" / f"{day}.json"
    dest_json.write_text(json.dumps(d, indent=2, ensure_ascii=False) + "\n", encoding="utf-8")

    html_src = dash / "dashboard" / "index.html"
    html_dst = dash / "dashboard.html"
    if html_src.exists():
        text = html_src.read_text(encoding="utf-8")
        text = text.replace('src="data.js"', 'src="dashboard/data.js"')
        html_dst.write_text(text, encoding="utf-8")
    elif (Path(__file__).resolve().parent.parent / "assets" / "dashboard" / "index.html").exists():
        src = Path(__file__).resolve().parent.parent / "assets" / "dashboard" / "index.html"
        text = src.read_text(encoding="utf-8").replace('src="data.js"', 'src="dashboard/data.js"')
        html_dst.write_text(text, encoding="utf-8")
        shutil.copy(src, dash / "dashboard" / "index.html")

    js = dash / "dashboard" / "data.js"
    js.parent.mkdir(parents=True, exist_ok=True)
    js.write_text(
        "window.DASHPROJECT_DATA = " + json.dumps(d, indent=2, ensure_ascii=False) + ";\n",
        encoding="utf-8",
    )
    print(f"rendered reports under {dash}")


if __name__ == "__main__":
    main()
