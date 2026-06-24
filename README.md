# AI Claude PHP Workflow

> Claude Code configuration for PHP developers — clean code, SOLID principles, two-mode workflow.

A ready-to-use [Claude Code](https://claude.ai/code) configuration designed for PHP development.
It provides a structured skill suite covering the full development cycle, from ticket analysis to pull request submission.

---

## Overview

### Two modes, one workflow

**Orchestra mode** — For complex tickets requiring deep analysis before coding.
Four agents work in parallel across four separate Claude contexts:

```
Context 1: /dev-analyse + /dev-plan  →  analysis/YYYYMMDD-{slug}.md
Context 2: /dev-implement            →  Code written and committed
Context 3: /dev-review               →  Multi-agent code review
Context 4: /challenge-review         →  Review findings challenged
                                     →  /dev-pr — PR ready for review
```

**Sequential mode** — For simple to medium tickets, all in a single context:

```
/dev-plan → /dev-implement → /dev-test → /dev-review → /dev-pr
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
git clone https://github.com/your-username/ai-claude-php-workflow.git
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

### Orchestra mode skills

| Skill | Trigger | What it does |
|-------|---------|-------------|
| `dev-analyse` | `/dev-analyse {ticket}` | Spawns 4 agents in parallel (business, code, architecture, security). Generates `analysis/` file. |
| `dev-plan` | `/dev-plan` | Transforms analysis into a task breakdown. Creates branch and draft PR. Completes the analysis file. |
| `dev-review` | `/dev-review` | Spawns 3 agents in parallel (quality, bugs, security) on the full diff. |
| `challenge-review` | `/challenge-review` | Challenges every review finding. Delivers a verdict table (valid / debatable / invalid). |

### Sequential mode skills

| Skill | Trigger | What it does |
|-------|---------|-------------|
| `dev-implement` | `/dev-implement {analysis-file}` | Implements the approved plan task by task. Applies clean code and SOLID principles. |
| `dev-test` | `/dev-test` | Generates PHP test scripts (no framework) for testable logic + manual test plan. |
| `dev-pr` | `/dev-pr` | Pushes, updates PR description, passes PR to ready for review. |

### Utility skills

| Skill | Trigger | What it does |
|-------|---------|-------------|
| `review-return` | `/review-return {pr}` | Handles PR review feedback from the main reviewer. Challenges each comment, applies valid corrections, drafts responses. |

### Commands

| Command | Trigger | What it does |
|---------|---------|-------------|
| `dev-branch` | `/dev-branch {id}` | Manual branch creation (fallback if `/dev-plan` didn't do it). |
| `dev-commit` | `/dev-commit` | Prepares a clean, well-formatted commit following project conventions. |

---

## Workflow in practice

### Orchestra mode (complex ticket)

```bash
# Context 1 — Analysis & planning
# In Claude Code, with your project open
/dev-analyse https://github.com/owner/repo/issues/42
# → Agents run in parallel, report generated
/dev-plan
# → Approve the task breakdown
# → Branch created: feat/42-user-profile-upload
# → Draft PR created
# → File generated: analysis/20260624-user-profile-upload.md

# Context 2 — Implementation (open a new Claude Code context)
/dev-implement analysis/20260624-user-profile-upload.md
# → Implements task by task with commits
/dev-test
# → Test scripts + manual test plan

# Context 3 — Code review (new context)
/dev-review
# → 3 agents review the full diff in parallel

# Context 4 — Challenge review findings (new context)
/challenge-review
# → Paste the review report or provide the PR number
# → Each finding challenged: valid / debatable / invalid

# Finalize
/dev-pr
# → PR description updated, passed to ready for review
```

### Sequential mode (simple ticket)

```bash
# All in one Claude Code context
/dev-plan Fix the login session timeout bug
/dev-implement
/dev-test
/dev-review
/dev-pr
```

### Handle incoming PR feedback

```bash
# After a reviewer comments on your PR
/review-return 42
# → Fetches comments from the configured MAIN_REVIEWER
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
claude-php-dev/
├── README.md
├── CLAUDE.template.md          ← Copy to each project as CLAUDE.md
├── settings.json               ← Claude Code settings (merged, not replaced)
├── install.sh                  ← Non-destructive installer
│
├── commands/                   ← Slash commands
│   ├── dev-branch.md
│   └── dev-commit.md
│
├── skills/
│   ├── _shared/                ← Shared references across skills
│   │   ├── clean-code.md
│   │   └── php-conventions.md
│   │
│   ├── dev-analyse/            ← Orchestra: ticket analysis
│   │   ├── SKILL.md
│   │   └── agents/
│   │       ├── business.md
│   │       ├── code.md
│   │       ├── architecture.md
│   │       └── security.md
│   │
│   ├── dev-plan/               ← Planning + branch/PR creation
│   │   ├── SKILL.md
│   │   └── agents/
│   │       ├── architect.md
│   │       ├── challenger.md
│   │       └── developer.md
│   │
│   ├── dev-implement/          ← Task-by-task implementation
│   │   └── SKILL.md
│   │
│   ├── dev-test/               ← PHP test scripts + manual test plan
│   │   ├── SKILL.md
│   │   └── references/
│   │       └── php-test-patterns.md
│   │
│   ├── dev-review/             ← Orchestra: multi-agent code review
│   │   ├── SKILL.md
│   │   └── agents/
│   │       ├── bugs.md
│   │       ├── quality.md
│   │       └── security.md
│   │
│   ├── dev-pr/                 ← PR finalization
│   │   └── SKILL.md
│   │
│   ├── challenge-review/       ← Challenge review findings
│   │   ├── SKILL.md
│   │   └── references/
│   │       ├── grille-analyse.md
│   │       └── patterns-bikeshedding.md
│   │
│   └── review-return/          ← Handle incoming PR review feedback
│       └── SKILL.md
│
└── docs/
    ├── orchestra-mode.md       ← Orchestra mode detailed guide
    └── sequential-mode.md      ← Sequential mode reference
```

---

## Contributing

Skills are plain Markdown files — they're easy to read, fork, and adapt.

To adapt for your team:
1. Fork the repo
2. Update `CLAUDE.template.md` with your team's conventions
3. Edit `BRANCH_PREFIX`, `COMMIT_FORMAT`, and skill prompts as needed
4. Run `./install.sh --force` to update

---

## License

MIT — use, fork, and adapt freely.
