# Mode Orchestre — Guide d'utilisation

L'analyse (`/dev-analyse` + `/dev-plan`) est **toujours la première étape**, quel que soit le mode.
Le choix du mode se fait **après** l'analyse, au moment de lancer l'implémentation.

---

## Flux complet

```
┌─────────────────────────────────────────────────────────────────────┐
│  PHASE 1 — Analyse & Plan (toujours, dans les trois modes)           │
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
│    → ⭐ Recommandation du mode selon complexité + risque sécu        │
│    → ⬇️  Choix du mode d'exécution                                  │
└─────────────────────────────────────────────────────────────────────┘
```

En mode **orchestre**, chaque phase suivante s'exécute dans un **contexte Claude séparé**.
Chaque contexte contient sa propre boucle de correction automatique (max 2 tentatives).

```
┌─────────────────────────────────────────────────────────────────────┐
│  CONTEXT 2 — Implémentation                                         │
│                                                                     │
│  /dev-implement analysis/YYYYMMDD-{slug}.md                        │
│    → Lit le fichier d'analyse + plan                                │
│    → Implémente tâche par tâche avec commits                        │
│    → /dev-test  (scripts PHP + plan manuel)                        │
│                                                                     │
│  ┌── GATE G1 ────────────────────────────────────────────────┐     │
│  │  all_tasks_covered · working_tree_clean · no_debug_code   │     │
│  │  no_new_todos · conventions_respected · commits_format    │     │
│  │                                                           │     │
│  │  FAIL → agent correctif → re-check (max 2x)              │     │
│  └───────────────────────────────────────────────────────────┘     │
│    ✅ PRÊT POUR CONTEXT 3  |  🛑 HALT — correction manuelle        │
└─────────────────────────────────────────────────────────────────────┘
                          ↓ (transition manuelle)
┌─────────────────────────────────────────────────────────────────────┐
│  CONTEXT 3 — Review du code                                         │
│                                                                     │
│  /dev-review                                                        │
│    ├── Agent 📐 Qualité   ─┐                                        │
│    ├── Agent 🐛 Bugs      ─┼── (parallèle sur git diff)            │
│    └── Agent 🔒 Sécurité ─┘                                        │
│    → Rapport : bloquant / à corriger / à noter                     │
│                                                                     │
│  ┌── GATE G2 ────────────────────────────────────────────────┐     │
│  │  findings_blocking = []                                   │     │
│  │                                                           │     │
│  │  FAIL → agent correctif → re-review (max 2x)             │     │
│  └───────────────────────────────────────────────────────────┘     │
│    ✅ PRÊT POUR CONTEXT 4  |  🛑 HALT — correction manuelle        │
└─────────────────────────────────────────────────────────────────────┘
                          ↓ rapport de review (transition manuelle)
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

`/dev-plan` le recommande automatiquement (⭐) quand :
- Complexité = **Complexe**
- Risque sécurité 🔴 ou 🟠 détecté dans l'analyse
- Code partagé impacté (lib commune, interface publique)
- Plus de 5 fichiers modifiés

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
