---
name: dev-review
description: >
  Revue de code approfondie via 3 sous-agents spécialisés en parallèle (qualité code, bugs,
  sécurité) avant de passer la PR en ready. Analyse le diff complet, challenge chaque choix,
  cherche les bugs et failles de sécurité, produit un verdict par niveaux (bloquant / à corriger
  / à noter). Déclencher dans Context 3 après /dev-implement et /dev-test, avant /dev-pr.
---

# dev-review — Revue de code multi-agents

Tu es l'**orchestrateur** d'une revue de code approfondie.
Ton rôle : coordonner 3 agents spécialisés, collecter leurs rapports, et rendre un verdict final go/no-go avant `/dev-pr`.

> **IMPORTANT — Phase lecture seule.**
> Ni toi ni les agents ne modifiez de fichiers.
> Si des corrections sont nécessaires, elles sont listées dans le rapport.

---

## Étape 0 — Initialisation

Récupère le diff complet :

```bash
git diff main...HEAD
git diff main...HEAD --name-only
git log main..HEAD --oneline
```

(Remplace `main` par `master` si c'est la branche principale du projet.)

Lis le `CLAUDE.md` à la racine pour rappeler les conventions du projet.

---

## Étape 1 — Lancement des agents en parallèle

Lance les 3 agents simultanément.
Passe à chacun : diff complet + liste des fichiers modifiés + contenu du CLAUDE.md.
Lis chaque fichier `agents/*.md` avant de spawner l'agent correspondant.

| Agent | Fichier | Mission |
|---|---|---|
| Qualité | `agents/quality.md` | Clean code, SOLID, conventions du projet, dette technique |
| Bugs | `agents/bugs.md` | Logique incorrecte, cas limites, régressions |
| Sécurité | `agents/security.md` | Failles OWASP, surfaces d'attaque, vulnérabilités |

---

## Étape 2 — Rapport consolidé

Produis le rapport final :

```
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
🔍 REVIEW — {branche} vs {branche principale}
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
```

### 📐 Qualité du code
> Rapport de l'agent qualité

### 🐛 Bugs détectés
> Rapport de l'agent bugs

### 🔒 Sécurité
> Rapport de l'agent sécurité

---

### ⚡ Synthèse — Verdict final

**Bloquant** (doit être corrigé avant /dev-pr) :
- [liste ou "Aucun"]

**À corriger** (devrait être corrigé, non bloquant) :
- [liste ou "Aucun"]

**À noter** (observation, amélioration future) :
- [liste ou "Aucun"]

**Feu vert pour /dev-pr** : ✅ Oui / ⚠️ Oui avec réserves / ❌ Non

---

## Étape 3 — Transition

Si feu vert ✅ ou ⚠️ :

```
✅ Review terminée.

➡️  Dans un nouveau contexte Claude Code (Context 4) :
    /challenge-review
    Colle le rapport ci-dessus, ou donnez le numéro/URL de la PR.
```

Si feu vert ❌ :

```
❌ Des points bloquants ont été détectés.
   Corrige-les dans ce contexte, puis relance /dev-review.
   Ou passe en Context 4 pour /challenge-review si tu veux d'abord
   valider si les bloquants sont de vrais bloquants.
```

---

## Notes d'orchestration

- Un point Bloquant = feu vert Non automatiquement.
- Si deux agents remontent le même problème, fusionner en un seul point.
- En cas de Non : proposer à l'utilisateur de corriger puis relancer `/dev-review`.
