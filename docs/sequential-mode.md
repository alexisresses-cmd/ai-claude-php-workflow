# Mode Séquentiel — Guide d'utilisation

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

## Différences avec le mode orchestre

| | Séquentiel | Orchestre |
|---|---|---|
| **Analyse** | Identique — 4 agents en parallèle | Identique — 4 agents en parallèle |
| **Contextes** | 1 seul après l'analyse | 1 par phase (implement / review / challenge) |
| **Review** | 3 agents, même contexte que l'implémentation | 3 agents, contexte propre |
| **Challenge** | Optionnel, même contexte | Contexte dédié, regard neuf |
| **Quand** | Ticket simple ou bien cerné | Ticket complexe ou risqué |

---

## Quand choisir le mode séquentiel ?

- Bug isolé avec cause claire
- Feature sur 1-3 fichiers que tu connais bien
- Ticket estimé Simple ou Moyenne par `/dev-plan`
- Tu préfères itérer rapidement sans changer de contexte

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
