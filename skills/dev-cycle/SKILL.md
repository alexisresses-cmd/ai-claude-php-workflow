---
name: dev-cycle
description: >
  Orchestrateur autonome du cycle de développement. Enchaîne automatiquement
  implement → test → review avec contrôle du modèle et de l'effort par agent
  (Opus/high pour la sécurité, Sonnet/medium pour l'implémentation et les tests,
  Sonnet/low pour les corrections mécaniques). Gates G1/G2/G3 avec corrections
  auto max 2×. Déclencher après /dev-analyse + /dev-plan quand le plan est approuvé.
---

# dev-cycle

Utilise l'outil **Workflow** pour lancer le workflow nommé `dev-cycle`.

Passe `$ARGUMENTS` comme valeur de `args` (chemin vers le fichier `analysis/` produit par `/dev-plan`).

Si `$ARGUMENTS` est absent, demande le chemin du fichier d'analyse avant de lancer le workflow.

---

## Modèles et effort par agent

| Agent | Modèle | Effort |
|---|---|---|
| Implémentation | Sonnet | medium |
| Tests | Sonnet | medium |
| Review — qualité | Sonnet | medium |
| Review — bugs | Sonnet | medium |
| Review — sécurité | **Opus** | **high** |
| Corrections (G1/G2/G3) | Sonnet | low |
| PR | Sonnet | low |

---

## Flux

```
Initialisation → vérification git + lecture de l'analyse

Phase 1 — Implement (Sonnet/medium)
  Gate G1 — 7 critères, correction auto max 2× (Sonnet/low)

Phase 2 — Tests (Sonnet/medium)
  Gate G2 — couverture + erreurs fatales, correction auto max 2× (Sonnet/low)

Phase 3 — Review via workflow dev-review
  Agent qualité (Sonnet/medium)
  Agent bugs    (Sonnet/medium)
  Agent sécurité (Opus/high)    ← en parallèle
  Gate G3 — zéro bloquant, correction auto max 2× (Sonnet/low)

Phase 4 — PR (Sonnet/low)
  → PR ready for review ✅
```
