# Mode Orchestre — Guide d'utilisation

L'analyse (`/dev-analyse` + `/dev-plan`) est **toujours la première étape**, quel que soit le mode.
Le choix du mode se fait **après** l'analyse, au moment de lancer l'implémentation.

---

## Flux complet

```
┌─────────────────────────────────────────────────────────────────────┐
│  PHASE 1 — Analyse & Plan (toujours, dans les deux modes)           │
│                                                                     │
│  /dev-analyse {ticket}                                              │
│    ├── Agent 🎯 Business    ─┐                                      │
│    ├── Agent 🔍 Code        ─┼── (parallèle)                       │
│    ├── Agent 🏗️ Architecture ─┤                                      │
│    └── Agent 🔒 Sécurité   ─┘                                      │
│                                                                     │
│  /dev-plan                                                          │
│    → Découpage en tâches, approbation                               │
│    → Branche créée + draft PR                                       │
│    → 📄 analysis/YYYYMMDD-{slug}.md complété                       │
│    → ⬇️  Choix du mode d'exécution                                  │
└─────────────────────────────────────────────────────────────────────┘
```

En mode **orchestre**, chaque phase suivante s'exécute dans un **contexte Claude séparé** :

```
┌─────────────────────────────────────────────────────────────────────┐
│  CONTEXT 2 — Implémentation                                         │
│                                                                     │
│  /dev-implement analysis/YYYYMMDD-{slug}.md                        │
│    → Lit le fichier d'analyse + plan                                │
│    → Implémente tâche par tâche avec commits                        │
│    → /dev-test  (scripts PHP + plan manuel)                        │
└─────────────────────────────────────────────────────────────────────┘
                          ↓
┌─────────────────────────────────────────────────────────────────────┐
│  CONTEXT 3 — Review du code                                         │
│                                                                     │
│  /dev-review                                                        │
│    ├── Agent 📐 Qualité   ─┐                                        │
│    ├── Agent 🐛 Bugs      ─┼── (parallèle sur git diff)            │
│    └── Agent 🔒 Sécurité ─┘                                        │
│    → Rapport : bloquant / à corriger / à noter                     │
└─────────────────────────────────────────────────────────────────────┘
                          ↓ rapport de review
┌─────────────────────────────────────────────────────────────────────┐
│  CONTEXT 4 — Challenge                                              │
│                                                                     │
│  /challenge-review                                                  │
│    → Challenge chaque point                                         │
│    → Verdict : valide / discutable / invalide                       │
└─────────────────────────────────────────────────────────────────────┘
                          ↓
                       /dev-pr
```

---

## Pourquoi des contextes séparés ?

Chaque contexte repart d'une ardoise propre. Avantages :
- L'agent d'implémentation ne traîne pas le contexte de l'analyse (fenêtre plus disponible pour le code)
- L'agent de review lit le diff avec un œil neuf, sans biais des décisions prises en Context 2
- L'agent de challenge n'a pas l'historique de la review, il évalue les findings de façon indépendante

---

## Quand choisir le mode orchestre ?

- Le ticket touche plusieurs fichiers dont l'impact n'est pas évident
- La zone implique de la sécurité, des permissions, des uploads, du code partagé
- Tu veux une review et un challenge vraiment indépendants du contexte d'implémentation
- Le ticket est estimé Complexe par `/dev-plan`

---

## Commandes

```bash
# Phase 1 — toujours (Context 1 ou contexte courant)
/dev-analyse {ticket-url-ou-texte}
/dev-plan

# Phase 2 — nouveau contexte
/dev-implement analysis/{slug}.md
/dev-test

# Phase 3 — nouveau contexte
/dev-review

# Phase 4 — nouveau contexte
/challenge-review

# Finalisation
/dev-pr
```
