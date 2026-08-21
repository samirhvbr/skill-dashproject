# DASHPROJECT

**Evidence-based progress intelligence for projects built with AI agents.**

Skill: `skill-dashproject`  
Version: 0.4.1 (Three Outputs, One Snapshot)

🇧🇷 [Leia em português](README_br.md)

DASHPROJECT does not ask the agent how done the project is. It **measures** the state of the requirements.

> Progress = the result of the measurement.  
> Precision = the quality of that measurement.

A requirement is only ever **0%, 50% or 100%**. There is no "63% of this feature".

```
REQ-001  100%
REQ-002  100%
…
REQ-101  100%
REQ-102   50%   ← in progress
REQ-103    0%
…
REQ-287    0%

progress = (101×100 + 1×50 + 185×0) / 287  →  35.4%
```

---

## What it is for

When developing with Claude Code (and similar agents), the implementer tends to declare "done". The dashboard becomes an **independent observer**:

1. reads the documentation and **builds the requirement map**
2. teaches the agent to commit with `REQ-NNN`
3. after a commit burst (10-minute debounce) updates only the declared requirements
4. validates the claim against the diff
5. regenerates YAML + Markdown (GitHub) + HTML from the same snapshot

`.dashproject/` is not the product's canonical documentation. It is the auditor's view.

---

## Six pillars

| Pillar | Function |
|---|---|
| Requirement Discovery | Bootstrap from existing documentation |
| Requirement Tracking | `PLANNED` 0 → `IN_PROGRESS` 50 → `COMPLETED` 100 |
| Commit Protocol | The agent declares IDs and state in the commit |
| Evidence Validation | A declaration is a claim; the diff has to be plausible |
| Measurement Precision | Clarity, granularity, traceability, documentation quality |
| Dashboard | Three views of the same snapshot — YAML, MD and HTML (progress, scope, precision, activity) |

---

## States

| Status | Progress |
|---|---|
| `PLANNED` | 0 |
| `IN_PROGRESS` | 50 |
| `COMPLETED` | 100 |

`status` is the source of truth. The ledger does **not** store `progress`.

On `COMPLETED` there is a second field:

| completion | Meaning |
|---|---|
| `declared` | Plausible implementation; tests/docs still weak — still 100% |
| `accepted` | Implementation + tests |
| `rejected` | Claim refused; the status does **not** stay COMPLETED |

Bootstrap is conservative: a file that "looks like the requirement" does not become COMPLETED. Without strong evidence → `IN_PROGRESS` or `PLANNED` with `evidence.knownness: unknown`. The initial snapshot records `baseline_confidence`.

---

## Measurement Precision

The progress % can be arithmetically exact and still be unreliable.

| Factor | What it measures |
|---|---|
| Requirement clarity | Requirements are testable behaviors, sourced from the docs |
| Granularity | Neither a whole product in a single REQ, nor a rename |
| Commit traceability | Commits cite `REQ-` and the new state |
| Documentation quality | Official docs exist, are structured, and map to the ledger |

Default weights: clarity 25, granularity 20, **traceability 35**, documentation 20. Without `REQ-` in the commits, precision falls even with perfect docs.

---

## Scope ≠ progress

New requirements increase the denominator. That is **not** a regression.

```
287 reqs, 172 complete  →  60.0%
+14 reqs in scope
301 reqs, 172 complete  →  57.1%   (the project grew)
```

IDs are never recycled. A removed requirement is marked `withdrawn: true` and leaves the denominator.

---

## Cycle

```
DOCUMENTATION
     │
     ▼
BOOTSTRAP  →  requirements.yaml  +  commit section in the README
     │
     ▼
AGENT DEVELOPS
     │
     ▼
COMMIT feat(REQ-102): …  /  Status: IN_PROGRESS|COMPLETED
     │
     ▼
HOOK (marked block) → pending
     │
     ▼
OPTIONAL WATCH (10 min) → review-due   — never calls the model
     │
     ▼
INCREMENTAL REVIEW  →  only the cited REQs + diff
                    →  declared | accepted | rejected
                    →  collect-activity.py (git, no LLM)
     │
     ▼
SNAPSHOT + dashboard/index.html
```

The incremental review does **not** reread all 287 requirements. Repository activity comes from Git, not from the agent's prose.

---

## Three outputs, one truth

| Output | Who reads it | File |
|---|---|---|
| YAML/JSON | agent and scripts | `analysis/latest.yaml`, `dashboard/data.json` |
| Markdown | human on GitHub | `.dashproject/README.md`, `dashboard.md`, `history/daily/` |
| HTML | human on the desktop | `dashboard.html` (`xdg-open` / `firefox`) |

The renderer [scripts/render-reports.py](scripts/render-reports.py) generates the MD and the HTML from `data.json`. One markdown per **day**, not per commit. GitHub Pages is out of scope for now.

---

## Repository activity ≠ progress

`git ls-files` / `git log` feed the pulse. `node_modules` and friends are excluded.

| | Progress | Activity |
|---|---|---|
| Source | requirements 0/50/100 | tracked files and commits |
| This week | +18 COMPLETED | +310 files, churn 859 |
| Can both be high | yes | a refactor produces plenty of activity and 0% progress |

LOC is optional (`activity.loc: false`). It never becomes a %.

Script: [scripts/collect-activity.py](scripts/collect-activity.py).

---

## Commit (required in the target repository)

On `dashproject init` this section is **appended** to the target project's `README.md` (the rest is not rewritten).

```
feat(REQ-102): boleto generation
```

One `REQ` in the subject, with no body, already means `IN_PROGRESS`. Declaring the state explicitly also works:

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

`COMPLETED` comes **only** from the `Requirements:` block. The subject verb is decorative — the parser does not read `complete`, `conclui`, `finaliza` or `fecha` ([ADR-0006](docs/adr/0006-declaracao-de-status-no-commit.md)).

```
feat(REQ-102,REQ-103): boleto generation and cancellation

Requirements:
- REQ-102: IN_PROGRESS
- REQ-103: IN_PROGRESS
```

- `feat` / `fix` — may move 0 → 50 → 100
- `test` / `docs` — do not move 0/50/100; may promote `declared` → `accepted`
- `refactor` / `chore` — no progress, unless they declare a REQ
- `chore(dashproject)` — reserved for the auditor (the hook ignores it)

Avoid mixing dozens of unrelated requirements (precision penalty).

### Projects that do not use Conventional Commits

A repository with its own commit standard keeps it. The `Requirements:` block in the **body** is enough to declare state — the subject is free text ([ADR-0010](docs/adr/0010-subject-livre-e-bloco-requirements.md)):

```
1.63.3 - fecha a duplicata da colheita automatica

Requirements:
- REQ-014: COMPLETED
```

Full text: [assets/templates/README-COMMIT-GUIDELINES.md](assets/templates/README-COMMIT-GUIDELINES.md) and [references/commit-protocol.md](references/commit-protocol.md).

---

## How to use it (Claude Code / agent)

1. Copy this folder into the agent's skills (`skill-dashproject/`).
2. In the product repository: ask for `dashproject init`.
3. Install the hook: `dashproject hook` (inserts a marked block; does not replace an existing hook; never calls the model).
4. Optional: `dashproject watch` or the `dashproject-watch.service` unit on Debian.
5. Develop using the commit convention above.
6. When `review-due` exists (or `pending-ready.sh` exits 0): `dashproject review`.
7. Open `.dashproject/dashboard/index.html`.

Commands:

| Command | Effect |
|---|---|
| `dashproject init` | Bootstrap: ledger + guidelines in the README + dashboard |
| `dashproject review` | Incremental analysis of the burst |
| `dashproject deep` | Requirement / precision rediscovery (on request) |
| `dashproject dashboard` | Regenerates the HTML from the ledger |
| `dashproject hook` | Inserts/updates the block in `post-commit` |
| `dashproject watch` | Debounce watcher (writes `review-due`, no LLM) |
| `dashproject activity` | Git snapshot of files/churn only |
| `dashproject status` | Progress, precision, pulse, scope, delta |

Default model: Sonnet for the incremental. Opus (or whatever is in `config.yaml`) for bootstrap / deep / release. The provider is configurable (`anthropic`, `ollama`, …).

---

## Documentation

The human documentation is in PT-BR ([ADR-0005](docs/adr/0005-idioma-hibrido.md) — hybrid language is intentional).

| Page | When to read it |
|---|---|
| [README_br.md](README_br.md) | This page, in Portuguese |
| [docs/instalacao.md](docs/instalacao.md) | Installing the skill, the hook and the watcher |
| [docs/uso.md](docs/uso.md) | Day-to-day commands and the work cycle |
| [docs/arquitetura.md](docs/arquitetura.md) | How the pieces fit together and why |
| [docs/glossario.md](docs/glossario.md) | progress, precision, completion, knownness |
| [docs/troubleshooting.md](docs/troubleshooting.md) | When the hook, watch or review misbehave |
| [docs/adr/](docs/adr/) | Architecture decisions and their rationale |
| [docs/padrao-documentacao.md](docs/padrao-documentacao.md) | The standard this repository follows |
| [version.md](version.md) | Versioning convention and commit format |
| [CHANGELOG.md](CHANGELOG.md) | History by version |
| [CONTRIBUTING.md](CONTRIBUTING.md) | Contributing, testing and publishing a release |

Automatic standard check:

```bash
scripts/check-docs.sh
```

---

## Tree of this skill

```
skill-dashproject/
├── SKILL.md                          # auditor protocol (prompt, English)
├── README.md                         # this file (English, entry point)
├── README_br.md                      # the same page in PT-BR
├── CLAUDE.md                         # operational context for agents
├── AGENTS.md                         # mirror of CLAUDE.md
├── CONTRIBUTING.md                   # how to contribute and the PR checklist
├── version.md                        # source of truth for the version
├── CHANGELOG.md                      # history by version
├── LICENSE                           # MIT
├── references/                       # loaded on demand by the agent
│   ├── scoring.md                    # 0/50/100, precision, scope
│   ├── ledger.md                     # YAML schemas
│   ├── cycles.md                     # bootstrap, burst, models
│   ├── commit-protocol.md            # commit parsing
│   ├── activity.md                   # Git activity ≠ progress
│   ├── outputs.md                    # the three outputs
│   └── dashboard.md                  # snapshot projection contract
├── docs/                             # human documentation (PT-BR)
│   ├── instalacao.md
│   ├── uso.md
│   ├── arquitetura.md
│   ├── padrao-documentacao.md
│   ├── glossario.md
│   ├── troubleshooting.md
│   └── adr/                          # architecture decisions
├── scripts/
│   ├── install-git-hook.sh           # installs/updates the marked block
│   ├── hook-block.sh                 # the block inserted into post-commit
│   ├── post-commit.sh                # standalone equivalent of the block
│   ├── pending-ready.sh              # 0 = review due, 2 = within debounce
│   ├── watch.sh                      # debounce watcher (no LLM)
│   ├── collect-activity.py           # repository activity (no LLM)
│   ├── render-reports.py             # MD + HTML from data.json
│   ├── check-docs.sh                 # documentation consistency
│   └── build-release.sh              # packages into dist/
├── assets/
│   ├── templates/                    # copied into .dashproject/
│   └── dashboard/                    # index.html + data.js + data.json
├── .claude/                          # Claude Code settings and commands
└── .continue/                        # Continue.dev config and rules
```

In the target repository the auditor creates:

```
.dashproject/
├── config.yaml
├── project.yaml
├── baseline/
├── requirements/
├── analysis/
├── agent-docs/          # Reality Map (code) vs official docs (expected)
└── dashboard/           # open index.html — no npm, Docker or database
```

---

## Isolation

- Whoever implements writes code, tests, `docs/` and declared commits.
- DASHPROJECT only writes `.dashproject/` and the commit section in the README.
- The auditor's own snapshot does not count as evidence of implementation.
- If the same model just wrote the code, that requirement's confidence drops.

---

## Roadmap

| Version | State | Focus |
|---|---|---|
| v0.1 | delivered | Bootstrap, 0/50/100, debounce, REQ commits, dashboard, snapshots, precision |
| v0.2 | delivered | *Reliable Requirement Tracking* — conservative bootstrap, completion declared/accepted/rejected, derived progress, composite hook, watch, Git activity |
| v0.3 | delivered | *Documented Foundations* — documentation standard, ADRs 0001–0009, schema contracts (evidence, delta, divergences, dashboard projection), subject default on commit |
| **v0.4** | **current** | *Three Outputs, One Snapshot* — `render-reports.py`, house versioning (`version.md`), bilingual README, free subject + `Requirements:` block |
| v0.5 | planned | Explicit regression, commit-derived timeline, richer rejections, historical burn-up |
| v0.6 | planned | Spec/doc drift, dependencies between requirements |
| v0.7 | planned | Release readiness and risk. Quality and security **as a separate axis — never as a percentage dimension** ([ADR-0007](docs/adr/0007-um-numero-e-tres-estados.md)) |
| v1.0 | planned | Stable Project Intelligence Dashboard for agent-assisted engineering |

---

## Packaging

The distribution `.zip` is **not** versioned. Generate it on demand:

```bash
scripts/build-release.sh          # version read from version.md
scripts/build-release.sh 0.4.0    # explicit version
# → dist/skill-dashproject_v0.4.0.zip
```

---

## License

MIT — see [LICENSE](LICENSE). The audited software stays under the target repository's license.
