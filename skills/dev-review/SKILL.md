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

## Étape 3 — Gate G2 : correction automatique des bloquants

> **Ce gate s'applique toujours** (mode séquentiel et mode orchestre).
> Si aucun bloquant : passer directement à la transition finale.

### Évaluation du gate

```
GATE G2
  ┌─────────────────────────────────────────────────┐
  │  findings_blocking = []    →  ✅ PASS           │
  │  findings_blocking ≠ []    →  ❌ FAIL           │
  └─────────────────────────────────────────────────┘
```

### Protocole de correction (si FAIL)

**Compteur d'essais : max 2 corrections automatiques.**

Pour chaque cycle de correction :

1. Spawn un agent de correction avec ces instructions :
   ```
   Tu es un développeur correctif.
   Voici les points bloquants identifiés par la review :

   {liste complète des bloquants}

   Ta mission :
   - Corriger chacun de ces points dans le code
   - Ne rien modifier hors de ces corrections (pas de nettoyage opportuniste)
   - Committer chaque correction : fix(scope): correction review — {description courte}
   - Retourner la liste des corrections effectuées
   ```

2. Re-lancer les 3 agents de review sur le nouveau diff (retour à l'Étape 1).

3. Réévaluer le gate.

Si le gate repasse ✅ → continuer.
Si le gate échoue encore et que le compteur est épuisé → HALT.

### Signal final

**Gate G2 ✅ (0 bloquant)** :

```
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
✅ GATE G2 — PASS
   0 point bloquant.

➡️  PRÊT POUR CONTEXT 4
    Dans un nouveau contexte Claude Code :
    /challenge-review
    Colle le rapport ci-dessus ou donne le numéro/URL de la PR.
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
```

**Gate G2 ✅ après correction(s)** :

```
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
✅ GATE G2 — PASS (après {N} correction(s) automatique(s))
   Corrections appliquées :
     • {correction 1}
     • {correction 2}

➡️  PRÊT POUR CONTEXT 4
    Dans un nouveau contexte Claude Code :
    /challenge-review
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
```

**Gate G2 ❌ (2 tentatives épuisées)** :

```
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
🛑 GATE G2 — HALT
   Les bloquants suivants n'ont pas pu être résolus
   après 2 tentatives de correction automatique :

     ❌ {bloquant 1}
     ❌ {bloquant 2}

   Action requise : corriger manuellement ces points,
   puis relancer /dev-review dans ce contexte.
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
```

---

## Notes d'orchestration

- Un point Bloquant = gate G2 FAIL automatiquement.
- Si deux agents remontent le même problème, fusionner en un seul point dans le rapport.
- Les corrections automatiques ne touchent que les bloquants listés — pas de refactoring opportuniste.
