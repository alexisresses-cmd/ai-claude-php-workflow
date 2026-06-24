# Mode Séquentiel — Guide d'utilisation

Le mode séquentiel est le workflow pas-à-pas pour les tickets simples à moyens.
Un seul contexte Claude, chaque skill s'enchaîne sur le précédent.

---

## Flux complet

```
/dev-plan {contexte ou ticket}
    → Découpage en tâches
    → Approbation → branche + draft PR

/dev-implement
    → Implémentation tâche par tâche
    → Commits intermédiaires

/dev-test
    → Scripts PHP + plan manuel

/dev-review
    → Revue multi-agents (qualité, bugs, sécurité)

/dev-pr
    → Finalisation + ready for review
```

---

## Différences avec le mode orchestre

| Mode orchestre | Mode séquentiel |
|----------------|-----------------|
| 4 contextes séparés | 1 seul contexte |
| Analyse multi-agents (4 agents) | Plan direct |
| Review multi-agents | Review multi-agents |
| Challenge séparé dans Context 4 | Challenge optionnel dans le même contexte |
| Fichier `analysis/` généré | Pas de fichier handoff |
| Pour tickets complexes | Pour tickets simples à moyens |

---

## Quand utiliser le mode séquentiel ?

✅ **Adapté pour :**
- Bugs isolés avec cause claire
- Petites features sur des zones connues
- Tâches techniques simples (migration de config, ajout d'un champ, etc.)
- Quand on connaît déjà les fichiers à toucher

---

## Commandes rapides

```bash
# Dans un seul contexte
/dev-plan {description ou numéro de ticket}
/dev-implement
/dev-test
/dev-review
/dev-pr

# Si besoin de challenger la review
/challenge-review
```

---

## Outils complémentaires

```bash
# Créer une branche manuellement (si /dev-plan ne l'a pas fait)
/dev-branch {numéro-du-ticket}

# Préparer un commit propre
/dev-commit

# Traiter les retours de review
/review-return {url-ou-numéro-pr}

# Challenger les retours d'une review
/challenge-review
```
