# AI Claude PHP Workflow — Recap GitHub Push

## Dépôt local

- **Chemin** : `C:\Users\ALE.RESSES\Documents\Perso\Claude`
- **Branche** : `master`
- **Commits** : 5 commits prêts à pousser

---

## Pousser sur GitHub

### 1. Créer le repo sur GitHub

- Nom : `ai-claude-php-workflow`
- Visibilité : Public
- **Ne pas** initialiser avec README, .gitignore ou licence

### 2. Configurer git (si pas déjà fait)

```bash
git config --global user.name "Ton Nom"
git config --global user.email "ton@email.com"
```

### 3. Lier et pousser

```bash
# Depuis Windows
cd "C:\Users\ALE.RESSES\Documents\Perso\Claude"

# Depuis WSL
cd /mnt/c/Users/ALE.RESSES/Documents/Perso/Claude

git remote add origin https://github.com/{ton-username}/ai-claude-php-workflow.git
git branch -M main
git push -u origin main
```

---

## Contenu du repo

```
ai-claude-php-workflow/
├── README.md                   ← Documentation GitHub (EN)
├── CLAUDE.template.md          ← Template à copier dans chaque projet
├── settings.json               ← Config Claude Code
├── install.sh                  ← Script d'installation
├── .gitignore / .gitattributes
│
├── commands/
│   ├── dev-branch.md
│   └── dev-commit.md
│
├── skills/
│   ├── _shared/
│   │   ├── clean-code.md
│   │   └── php-conventions.md
│   ├── dev-analyse/            ← Phase 1 : 4 agents parallèles
│   ├── dev-plan/               ← Phase 1 : plan + recommandation du mode
│   ├── dev-cycle/              ← Automatisé : implement→test→review → PR
│   ├── dev-implement/
│   ├── dev-test/
│   ├── dev-review/             ← 3 agents parallèles
│   ├── dev-pr/
│   ├── challenge-review/
│   └── review-return/
│
└── docs/
    ├── orchestra-mode.md
    └── sequential-mode.md
```

---

## Installer la config sur un poste

```bash
git clone https://github.com/{ton-username}/ai-claude-php-workflow.git
cd ai-claude-php-workflow
chmod +x install.sh
./install.sh
```

Options :
- `--force` → écrase les fichiers existants (backup `.bak` créé)
- `--cli`   → installe aussi Claude Code CLI (npm ou brew)

**Compatible** : Linux, macOS, WSL

---

## Configurer un projet

```bash
cp CLAUDE.template.md /chemin/vers/projet/CLAUDE.md
# Remplir : BRANCH_PREFIX, COMMIT_FORMAT, ISSUE_TRACKER, MAIN_REVIEWER
```

---

## Workflow

```
# Phase 1 — toujours obligatoire
/dev-analyse {ticket-url-ou-texte}
/dev-plan
# → Génère : analysis/YYYYMMDD-{slug}.md
# → Affiche une recommandation de mode ⭐

# Mode automatisé — dev-cycle
/dev-cycle analysis/{slug}.md
# → implement → test → review (boucle correction max 2x) → PR ready ✅

# Mode séquentiel (contrôle manuel, même contexte)
/dev-implement analysis/{slug}.md
/dev-test
/dev-review
/dev-pr

# Mode orchestre (contexte dédié par phase)
# Context 2 → /dev-implement analysis/{slug}.md + /dev-test
# Context 3 → /dev-review
# Context 4 → /challenge-review → /dev-pr
```
