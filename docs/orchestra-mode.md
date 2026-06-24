# Mode Orchestre — Guide d'utilisation

Le mode orchestre est conçu pour les tickets nécessitant une analyse approfondie avant de coder.
Il utilise plusieurs agents Claude en parallèle et sépare le travail en **4 contextes distincts**,
chacun avec un rôle précis.

---

## Pourquoi des contextes séparés ?

Chaque contexte Claude a une fenêtre de contexte limitée et un rôle différent :
- **Context 1** (analyse + plan) : exploite la base de code pour comprendre
- **Context 2** (implémentation) : contexte propre, focalisé uniquement sur le code à écrire
- **Context 3** (review) : contexte propre, lit le diff avec un œil neuf
- **Context 4** (challenge) : contexte propre, challenge la review sans biais

Le fichier `analysis/` est l'**artefact de handoff** entre les contextes.

---

## Flux complet

```
┌─────────────────────────────────────────────────────────────────────┐
│  CONTEXT 1 — Analyse & Plan                                         │
│                                                                     │
│  /dev-analyse {ticket}                                              │
│    ├── Agent 🎯 Business    ─┐                                      │
│    ├── Agent 🔍 Code        ─┼── (parallèle)                       │
│    ├── Agent 🏗️ Architecture ─┤                                      │
│    └── Agent 🔒 Sécurité   ─┘                                      │
│         → Rapport consolidé + feu vert                             │
│                                                                     │
│  /dev-plan                                                          │
│    → Découpage en tâches                                            │
│    → Création branche + draft PR                                    │
│    → 📄 Génère : analysis/YYYYMMDD-{slug}.md                       │
└─────────────────────────────────────────────────────────────────────┘
                          │
                          │  📄 analysis/YYYYMMDD-{slug}.md
                          ▼
┌─────────────────────────────────────────────────────────────────────┐
│  CONTEXT 2 — Implémentation                                         │
│                                                                     │
│  /dev-implement analysis/YYYYMMDD-{slug}.md                        │
│    → Lit analyse + plan du fichier                                  │
│    → Implémente tâche par tâche                                     │
│    → Commits intermédiaires                                         │
│    → /dev-test (scripts PHP + plan manuel)                         │
└─────────────────────────────────────────────────────────────────────┘
                          │
                          ▼
┌─────────────────────────────────────────────────────────────────────┐
│  CONTEXT 3 — Review du code                                         │
│                                                                     │
│  /dev-review                                                        │
│    ├── Agent 📐 Qualité    ─┐                                       │
│    ├── Agent 🐛 Bugs       ─┼── (parallèle sur git diff)           │
│    └── Agent 🔒 Sécurité  ─┘                                       │
│         → Rapport : bloquant / à corriger / à noter                │
└─────────────────────────────────────────────────────────────────────┘
                          │
                          │  Rapport de review
                          ▼
┌─────────────────────────────────────────────────────────────────────┐
│  CONTEXT 4 — Challenge de la review                                 │
│                                                                     │
│  /challenge-review (coller le rapport, ou numéro PR)               │
│    → Challenge chaque point                                         │
│    → Verdict : valide / discutable / invalide                       │
│    → Identifie les faux positifs                                    │
└─────────────────────────────────────────────────────────────────────┘
                          │
                          ▼
              /dev-pr → PR en ready for review
```

---

## Quand utiliser le mode orchestre ?

✅ **Recommandé pour :**
- Nouvelles features avec impact multi-fichiers
- Tickets impliquant des zones sensibles (auth, upload, permissions)
- Tickets où l'architecture n'est pas évidente
- Code review important avant merge dans main

❌ **Pas nécessaire pour :**
- Corrections de typo ou de style (< 5 lignes)
- Fixes de bugs évidents et isolés
- Tâches de configuration / infra

---

## Commandes rapides

```bash
# Context 1
/dev-analyse {ticket-url-ou-texte}
/dev-plan

# Context 2 (nouveau contexte)
/dev-implement analysis/{slug}.md
/dev-test

# Context 3 (nouveau contexte)
/dev-review

# Context 4 (nouveau contexte)
/challenge-review

# Finalisation
/dev-pr
```

---

## Le fichier analysis/

Ce fichier contient :
- Rapport complet des 4 agents (business, code, architecture, sécurité)
- Synthèse de l'orchestrateur
- Plan d'implémentation approuvé
- Nom de branche et lien vers la PR draft

Il est créé dans le dossier `analysis/` à la racine du projet.
Ne le commitez pas — ajoutez `analysis/` à votre `.gitignore` si vous ne souhaitez pas le versionner.
