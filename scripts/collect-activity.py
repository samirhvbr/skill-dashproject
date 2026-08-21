#!/usr/bin/env python3
"""Collect Git-tracked repository activity. No LLM. Progress is not computed here."""
from __future__ import annotations

import argparse
import json
import subprocess
from collections import defaultdict
from datetime import datetime, timedelta, timezone
from pathlib import Path


# Extensions counted as "source" activity. Shell and markup were missing before
# v0.3, which pushed every script and page into "other".
SOURCE_EXTENSIONS = (
    ".php",
    ".py",
    ".js",
    ".mjs",
    ".cjs",
    ".ts",
    ".tsx",
    ".jsx",
    ".vue",
    ".svelte",
    ".go",
    ".rs",
    ".java",
    ".kt",
    ".swift",
    ".c",
    ".h",
    ".cpp",
    ".cs",
    ".rb",
    ".sh",
    ".bash",
    ".sql",
    ".html",
    ".htm",
    ".css",
    ".scss",
    ".sass",
    ".less",
)


def git(args: list[str], cwd: str) -> str:
    r = subprocess.run(
        ["git", *args],
        cwd=cwd,
        check=False,
        capture_output=True,
        text=True,
    )
    return r.stdout


def git_ok(args: list[str], cwd: str) -> bool:
    r = subprocess.run(["git", *args], cwd=cwd, capture_output=True, text=True)
    return r.returncode == 0


def classify(path: str) -> str:
    p = path.replace("\\", "/").lower()
    name = p.rsplit("/", 1)[-1]
    if (
        "/tests/" in f"/{p}/"
        or p.startswith("tests/")
        or p.startswith("test/")
        or name.endswith("_test.php")
        or name.endswith("_test.py")
        or ".test." in name
        or name.startswith("test_")
    ):
        return "tests"
    if (
        p.startswith("docs/")
        or name.endswith(".md")
        or name.startswith("readme")
    ):
        return "documentation"
    if p.startswith("deploy/") or name in {
        "dockerfile",
        "docker-compose.yml",
        "docker-compose.yaml",
    } or name.endswith(".service") or "/systemd/" in p or "/apache/" in p:
        return "infrastructure"
    if name.endswith(
        (".yml", ".yaml", ".toml", ".ini", ".env", ".example", ".json", ".lock")
    ) or name in {"composer.json", "package.json", "pyproject.toml"}:
        return "configuration"
    if name.endswith(SOURCE_EXTENSIONS):
        return "source"
    return "other"


def unique_dirs(files: list[str]) -> set[str]:
    dirs: set[str] = set()
    for f in files:
        parts = f.replace("\\", "/").split("/")
        acc = []
        for part in parts[:-1]:
            acc.append(part)
            dirs.add("/".join(acc))
    return dirs


def names_since(cwd: str, diff_filter: str, since: str) -> list[str]:
    out = git(
        [
            "log",
            f"--diff-filter={diff_filter}",
            f"--since={since}",
            "--pretty=format:",
            "--name-only",
            "--no-renames",
        ],
        cwd,
    )
    return [ln for ln in out.splitlines() if ln.strip()]


def unique_names(names: list[str]) -> int:
    return len(set(names))


def files_at(cwd: str, when: datetime) -> tuple[int, int]:
    sha = git(
        ["rev-list", "-1", f"--before={when.strftime('%Y-%m-%d %H:%M:%S')}", "HEAD"],
        cwd,
    ).strip()
    if not sha:
        return 0, 0
    files = [ln for ln in git(["ls-files", "--with-tree", sha], cwd).splitlines() if ln]
    return len(files), len(unique_dirs(files))


def loc_count(cwd: str, files: list[str]) -> int | None:
    if not files:
        return 0
    total = 0
    for i in range(0, len(files), 200):
        chunk = files[i : i + 200]
        r = subprocess.run(
            ["wc", "-l", *chunk],
            cwd=cwd,
            capture_output=True,
            text=True,
        )
        if r.returncode != 0:
            continue
        lines = r.stdout.strip().splitlines()
        if not lines:
            continue
        last = lines[-1].strip().split()
        if last and last[-1] == "total":
            total += int(last[0])
        elif len(chunk) == 1 and last:
            total += int(last[0])
    return total


def main() -> None:
    ap = argparse.ArgumentParser()
    ap.add_argument("--root", default=".")
    ap.add_argument("--weeks", type=int, default=8)
    ap.add_argument("--loc", action="store_true")
    ap.add_argument("-o", "--output")
    args = ap.parse_args()
    cwd = str(Path(args.root).resolve())

    if not git_ok(["rev-parse", "--is-inside-work-tree"], cwd):
        raise SystemExit("not a git repository")

    files = [ln for ln in git(["ls-files"], cwd).splitlines() if ln]
    dirs = unique_dirs(files)
    now = datetime.now(timezone.utc)
    week_ago = (now - timedelta(days=7)).strftime("%Y-%m-%d")

    added_w = names_since(cwd, "A", week_ago)
    deleted_w = names_since(cwd, "D", week_ago)
    modified_w = names_since(cwd, "M", week_ago)

    by_kind: dict[str, int] = defaultdict(int)
    for f in set(added_w):
        by_kind[classify(f)] += 1

    commits_week = git(["rev-list", "--count", f"--since={week_ago}", "HEAD"], cwd).strip()
    commits_all = git(["rev-list", "--count", "HEAD"], cwd).strip()
    contributors = [
        ln
        for ln in git(["shortlog", "-sn", "HEAD"], cwd).splitlines()
        if ln.strip()
    ]
    active_days = git(
        ["log", "--pretty=format:%ad", "--date=short"],
        cwd,
    )
    n_active_days = len(set(ln for ln in active_days.splitlines() if ln.strip()))

    series = []
    for i in range(args.weeks, -1, -1):
        when = now - timedelta(weeks=i)
        fc, dc = files_at(cwd, when)
        series.append(
            {
                "date": when.date().isoformat(),
                "files": fc,
                "directories": dc,
            }
        )

    payload = {
        "source": "git",
        "head": git(["rev-parse", "--short", "HEAD"], cwd).strip(),
        "generated": now.isoformat(),
        "current": {
            "files": len(files),
            "directories": len(dirs),
            "loc": loc_count(cwd, files) if args.loc else None,
        },
        "git": {
            "commits": int(commits_all or 0),
            "contributors": len(contributors),
            "active_days": n_active_days,
        },
        "week": {
            "since": week_ago,
            "files_created": unique_names(added_w),
            "files_deleted": unique_names(deleted_w),
            "files_modified": unique_names(modified_w),
            "churn": unique_names(added_w) + unique_names(modified_w) + unique_names(deleted_w),
            "directories_created": None,
            "commits": int(commits_week or 0),
            "created_by_kind": dict(by_kind),
        },
        "growth": series,
    }

    dirs_before = series[-2]["directories"] if len(series) >= 2 else 0
    payload["week"]["directories_created"] = max(0, payload["current"]["directories"] - dirs_before)

    text = json.dumps(payload, indent=2, ensure_ascii=False)
    if args.output:
        out = Path(args.output)
        out.parent.mkdir(parents=True, exist_ok=True)
        out.write_text(text + "\n", encoding="utf-8")
    print(text)


if __name__ == "__main__":
    main()
