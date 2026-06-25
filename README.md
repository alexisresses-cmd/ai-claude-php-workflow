# AI Claude PHP Workflow

> Claude Code configuration for PHP developers — clean code, SOLID principles, three-mode workflow.

A ready-to-use [Claude Code](https://claude.ai/code) configuration designed for PHP development.
It provides a structured skill suite covering the full development cycle, from ticket analysis to pull request submission.

---

## Overview

### Always start with analysis

`/dev-analyse` + `/dev-plan` are **mandatory in all modes**. They spawn agents in parallel, produce a structured analysis file, and recommend the best execution mode based on complexity and security risk.

```
/dev-analyse {ticket}  →  4 agents in parallel (business, code, architecture, security)
/dev-plan              →  Task breakdown + branch + draft PR + analysis/YYYYMMDD-{slug}.md
                              ↓
                    ⭐ Mode recommendation
```

### Three execution modes

After the analysis, choose the mode that fits the ticket:

**Automated — `dev-cycle`** — Claude handles everything. Recommended for simple/medium tickets with no security risk.

```
/dev-cycle analysis/{slug}.md
→ implement → test → review (auto-corrects blockers, max 2 attempts) → PR ready ✅
```

**Sequential** — Manual control, single context. For medium tickets where you want to validate each step.

```
/dev-implement → /dev-test → /dev-review → /dev-pr  (same context)
```

**Orchestra** — Dedicated context per phase. For complex tickets, security-sensitive areas, or when you want a fresh-eyes review. Each context has its own auto-correction loop (max 2 attempts) before signalling readiness for the next context.

```
Context 2: /dev-implement + Gate G1   Context 3: /dev-review + Gate G2   Context 4: /challenge-review → /dev-pr
```

---

## Prerequisites

| Tool | Required | Purpose |
|------|----------|---------|
| [Claude Code](https://claude.ai/code) | ✅ | Run the skills |
| [git](https://git-scm.com) | ✅ | Branch and commit management |
| [gh CLI](https://cli.github.com/) | Recommended | GitHub Issues integration, PR management |
| [jq](https://jqlang.github.io/jq/) | Optional | Smart settings.json merge during install |

---

## Installation

### Quick install (Linux / WSL / macOS)

```bash
git clone https://github.com/alexisresses-cmd/ai-claude-php-workflow.git
cd ai-claude-php-workflow
chmod +x install.sh
./install.sh
```

**Options:**

```bash
./install.sh            # Install config only, skip existing files
./install.sh --force    # Overwrite existing files (backups created as .bak)
./install.sh --cli      # Also install Claude Code CLI (requires npm or brew)
```

The installer is **non-destructive by default** — it skips any files that already exist in `~/.claude/`.
Your existing skills, commands, and settings are preserved.
Use `--force` only if you want to update to the latest version.

### Updating

When a new version is published, run:

```bash
./update.sh
```

This pulls the latest changes from `origin/main` and reinstalls the config automatically (`--force`).
If you are already up to date, the script exits without doing anything.
Existing files are backed up as `.bak` before being overwritten.

### Manual install

Copy the relevant directories to your `~/.claude/` folder:

```bash
cp -r skills/   ~/.claude/skills/
cp -r commands/ ~/.claude/commands/
```

For `settings.json`, **merge manually** — do not replace your existing settings:
- Add the `deny` rules from `settings.json` to your existing `~/.claude/settings.json`

---

## Project configuration

After installing, configure each project by creating a `CLAUDE.md` at its root:

```bash
cp CLAUDE.template.md /path/to/your/project/CLAUDE.md
```

Then edit `CLAUDE.md` to set your project-specific values:

```markdown
BRANCH_PREFIX: feat/          # Branch naming: feat/42-user-profile
COMMIT_FORMAT: conventional   # Commit format: feat(scope): #42 description
ISSUE_TRACKER: github         # github | trello | text
MAIN_REVIEWER: @your-handle   # For /review-return skill
```

The skills read `CLAUDE.md` to adapt their behavior to your project.
See [`CLAUDE.template.md`](CLAUDE.template.md) for the full template with all options.

---

## Skills reference

### Phase 1 — Always (all modes)

| Skill | Trigger | What it does |
|-------|---------|-------------|
| `dev-analyse` | `/dev-analyse {ticket}` | Spawns 4 agents in parallel (business, code, architecture, security). Accepts GitHub Issues URL, Trello URL, or plain text. Generates `analysis/` file. |
| `dev-plan` | `/dev-plan` | Transforms analysis into a task breakdown. Creates branch and draft PR. Completes the analysis file. **Recommends the best execution mode** based on complexity and security risk. |

### Phase 2 — Execution (choose one mode)

| Skill | Trigger | Mode | What it does |
|-------|---------|------|-------------|
| `dev-cycle` | `/dev-cycle {analysis-file}` | Automated | Chains implement → test → review. Auto-corrects blocking findings (max 2 attempts). Ends with PR ready for review. |
| `dev-implement` | `/dev-implement {analysis-file}` | Sequential / Orchestra | Implements the approved plan task by task with commits. Applies clean code and SOLID principles. **Gate G1** runs at the end: auto-corrects failing criteria (max 2 attempts), then signals `✅ Ready for Context 3` or `🛑 HALT`. |
| `dev-test` | `/dev-test` | Sequential / Orchestra | Generates PHP test scripts (no framework) for testable logic + manual test plan. |
| `dev-review` | `/dev-review` | Sequential / Orchestra | Spawns 3 agents in parallel (quality, bugs, security) on the full diff. **Gate G2** runs after the report: if blocking findings, auto-corrects and re-reviews (max 2 attempts), then signals `✅ Ready for Context 4` or `🛑 HALT`. |
| `challenge-review` | `/challenge-review` | Orchestra | Challenges every review finding. Delivers a verdict table (valid / debatable / invalid). |
| `dev-pr` | `/dev-pr` | Sequential / Orchestra | Pushes, updates PR description, passes PR to ready for review. |

### Utility skills

| Skill | Trigger | What it does |
|-------|---------|-------------|
| `review-return` | `/review-return {pr}` | Handles PR review feedback from the configured `MAIN_REVIEWER`. Challenges each comment, applies valid corrections, drafts ready-to-post responses. |

### Commands

| Command | Trigger | What it does |
|---------|---------|-------------|
| `dev-branch` | `/dev-branch {id}` | Manual branch creation (fallback if `/dev-plan` didn't do it). |
| `dev-commit` | `/dev-commit` | Prepares a clean, well-formatted commit following project conventions. |

---

## Workflow in practice

### Phase 1 — Always run first

```bash
# Accepts: GitHub Issues URL, Trello URL, or pasted text
/dev-analyse https://github.com/owner/repo/issues/42
/dev-plan
# → Task breakdown presented for approval
# → Branch created: feat/42-user-profile-upload
# → Draft PR created
# → File generated: analysis/20260624-user-profile-upload.md
# → ⭐ Mode recommendation displayed
```

### Automated mode (dev-cycle)

```bash
/dev-cycle analysis/20260624-user-profile-upload.md
# → Implements task by task (auto-commit)
# → Generates test scripts + manual plan
# → 3-agent code review
# → If blockers: auto-corrects and re-reviews (max 2 attempts)
# → If clean: PR ready for review ✅
# → If still blocked: HALT, manual fix required
```

### Sequential mode

```bash
# All in one Claude Code context
/dev-implement analysis/20260624-user-profile-upload.md
/dev-test
/dev-review
/dev-pr
```

### Orchestra mode

```bash
# Context 2 — new Claude Code context
/dev-implement analysis/20260624-user-profile-upload.md
/dev-test
# → Gate G1 runs automatically at the end
# → If criteria fail: auto-corrects and re-checks (max 2 attempts)
# → ✅ READY FOR CONTEXT 3  |  🛑 HALT (manual fix required)

# Context 3 — new context
/dev-review
# → Gate G2 runs automatically after the report
# → If blocking findings: auto-corrects and re-reviews (max 2 attempts)
# → ✅ READY FOR CONTEXT 4  |  🛑 HALT (manual fix required)

# Context 4 — new context
/challenge-review
/dev-pr
```

### Handle incoming PR feedback

```bash
/review-return 42
# → Fetches comments from MAIN_REVIEWER (configured in CLAUDE.md)
# → Challenges each comment
# → Applies valid corrections
# → Drafts ready-to-post responses
```

---

## Shared references

The `skills/_shared/` directory contains references injected into agents:

- **`clean-code.md`** — Clean code principles and SOLID applied to PHP (early returns, naming, single responsibility, DRY, YAGNI)
- **`php-conventions.md`** — Generic PHP best practices (PSR-12, PSR-4, SQL injection prevention, XSS, upload security, error handling)

Project-specific conventions are documented in each project's `CLAUDE.md`.

---

## Structure

```
ai-claude-php-workflow/
├── README.md
├── CLAUDE.template.md          ← Copy to each project as CLAUDE.md
├── settings.json               ← Claude Code settings (merged, not replaced)
├── install.sh                  ← Non-destructive installer
│
├── commands/
│   ├── dev-branch.md
│   └── dev-commit.md
│
├── skills/
│   ├── _shared/                ← Shared references injected into agents
│   │   ├── clean-code.md
│   │   └── php-conventions.md
│   │
│   ├── dev-analyse/            ← Phase 1: 4-agent parallel analysis
│   │   ├── SKILL.md
│   │   └── agents/
│   │       ├── business.md
│   │       ├── code.md
│   │       ├── architecture.md
│   │       └── security.md
│   │
│   ├── dev-plan/               ← Phase 1: task breakdown + mode recommendation
│   │   ├── SKILL.md
│   │   └── agents/
│   │       ├── architect.md
│   │       ├── challenger.md
│   │       └── developer.md
│   │
│   ├── dev-cycle/              ← Automated: implement→test→review loop → PR
│   │   └── SKILL.md
│   │
│   ├── dev-implement/          ← Sequential/Orchestra: task-by-task implementation
│   │   └── SKILL.md
│   │
│   ├── dev-test/               ← PHP test scripts + manual test plan
│   │   ├── SKILL.md
│   │   └── references/
│   │       └── php-test-patterns.md
│   │
│   ├── dev-review/             ← 3-agent parallel code review
│   │   ├── SKILL.md
│   │   └── agents/
│   │       ├── bugs.md
│   │       ├── quality.md
│   │       └── security.md
│   │
│   ├── dev-pr/                 ← PR finalization
│   │   └── SKILL.md
│   │
│   ├── challenge-review/       ← Orchestra: challenge review findings
│   │   ├── SKILL.md
│   │   └── references/
│   │       ├── grille-analyse.md
│   │       └── patterns-bikeshedding.md
│   │
│   └── review-return/          ← Handle incoming PR review feedback
│       └── SKILL.md
│
└── docs/
    ├── orchestra-mode.md
    └── sequential-mode.md
```

---

## Contributing

Skills are plain Markdown files — easy to read, fork, and adapt.

To adapt for your team:
1. Fork the repo
2. Update `CLAUDE.template.md` with your team's conventions
3. Edit `BRANCH_PREFIX`, `COMMIT_FORMAT`, and skill prompts as needed
4. Run `./install.sh --force` to update

---

## License

MIT — use, fork, and adapt freely.
