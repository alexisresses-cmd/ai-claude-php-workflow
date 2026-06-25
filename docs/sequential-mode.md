# Mode Séquentiel — Guide d'utilisation

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

En mode **séquentiel**, toutes les phases suivantes s'enchaînent dans le **même contexte** :

```
┌─────────────────────────────────────────────────────────────────────┐
│  MÊME CONTEXTE — Implémentation → Test → Review → PR               │
│                                                                     │
│  /dev-implement analysis/{slug}.md                                  │
│  /dev-test                                                          │
│  /dev-review                                                        │
│  /dev-pr                                                            │
└─────────────────────────────────────────────────────────────────────┘
```

---

## Comparaison des trois modes

| | dev-cycle | Séquentiel | Orchestre |
|---|---|---|---|
| **Analyse** | Identique — 4 agents en parallèle | Identique | Identique |
| **Exécution** | Automatisée | Manuelle, même contexte | Manuelle, contextes séparés |
| **Correction** | Auto (max 2x) | Manuelle | Auto dans chaque contexte (max 2x) |
| **Challenge** | Intégré dans la boucle | Optionnel | Contexte dédié |
| **PR** | Auto à la fin | Manuelle | Manuelle |
| **Recommandé si** | Simple/Moyenne, pas de risque sécu | Moyenne, contrôle souhaité | Complexe ou zone sensible |

---

## Quand choisir le mode séquentiel ?

- Ticket estimé Moyenne par `/dev-plan` avec un risque sécu faible
- Tu veux valider chaque étape manuellement sans changer de contexte
- Feature sur 1-3 fichiers que tu connais bien

---

## Commandes

```bash
# Phase 1 — toujours
/dev-analyse {ticket-url-ou-texte}
/dev-plan

# Phase 2 — dans le même contexte
/dev-implement analysis/{slug}.md
/dev-test
/dev-review
/dev-pr

# Si tu veux quand même challenger la review
/challenge-review
```
