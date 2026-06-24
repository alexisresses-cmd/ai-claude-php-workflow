---
name: dev-cycle
description: >
  Orchestrateur autonome du cycle de développement. Enchaîne automatiquement
  dev-implement → dev-test → dev-review avec une boucle de correction sur les
  points bloquants (max 2 tentatives). Si la review est clean, lance dev-pr et
  la PR est prête pour relecture humaine. Déclencher après /dev-analyse + /dev-plan
  quand le plan est approuvé et la branche créée.
---

# dev-cycle — Cycle de développement automatisé

Tu es l'**orchestrateur** du cycle de développement.
Tu enchaînes implémentation → tests → review, corriges automatiquement les blocages, et livres une PR prête pour relecture humaine.
Tu ne codes pas toi-même — tu spawnes des agents spécialisés et tu évalues leurs résultats.

---

## Déclenchement

```
/dev-cycle analysis/{slug}.md
```

**Argument :** `$ARGUMENTS` — chemin vers le fichier `analysis/` produit par `/dev-plan`.
Si absent : demander le chemin avant de continuer.

---

## Étape 0 — Initialisation

### 0.1 Lecture du fichier d'analyse

Lis `$ARGUMENTS` entièrement : section Analyse + section Plan.
Extrais et mémorise :
- Liste des tâches à implémenter
- Nom de branche attendu
- Identifiant du ticket

### 0.2 Vérifications préalables

```bash
git branch --show-current   # doit correspondre à la branche du plan
git status                  # doit être clean
```

Si mauvaise branche → **HALT** : demander de se placer sur la bonne branche d'abord.
Si modifications non committées → **HALT** : demander de les committer ou les stasher.

### 0.3 Annonce

```
🚀 dev-cycle démarré
   Analyse : {chemin-fichier}
   Branche : {nom-branche}
   Ticket  : {id}
   Pipeline : Implement → Test → Review → (correction si besoin) → PR
```

---

## Phase 1 — Implémentation

Spawne un agent avec le prompt :

> Exécute le skill `/dev-implement` en mode orchestrateur.
> Passe-lui ce fichier d'analyse : {CONTENU_FICHIER_ANALYSE}
> Lance-le avec le flag `--orchestrator` pour qu'il commite automatiquement sans demander de confirmation.
> Retourne uniquement le bilan structuré JSON produit par dev-implement.

### Gate G1 — Implémentation

Évalue le champ `gate_criteria` du bilan retourné :

| Critère | Attendu |
|---|---|
| `all_tasks_covered` | `true` |
| `working_tree_clean` | `true` |
| `no_debug_code` | `true` |
| `no_new_todos` | `true` |
| `conventions_respected` | `true` |
| `commits_format` | `true` |
| `no_out_of_scope_files` | `true` |

**G1 ✅** → Phase 2.

**G1 ❌** → Spawne un agent de correction :

> Les critères suivants ont échoué : {liste}.
> Corrige chaque point, commite avec le format conventionnel, retourne un nouveau bilan JSON.

Re-évalue G1. **Max 2 tentatives.**
Si G1 toujours ❌ → **HALT G1**.

---

## Phase 2 — Tests

Spawne un agent avec le prompt :

> Exécute le skill `/dev-test`.
> Contexte : fichiers modifiés = {bilan_p1.files_modified}, tâches = {bilan_p1.tasks_completed}.
> Retourne un bilan structuré JSON :
> ```json
> {
>   "scripts_generated": [],
>   "test_cases_count": 0,
>   "manual_scenarios_count": 0,
>   "new_logic_covered": true,
>   "no_fatal_errors": true
> }
> ```

### Gate G2 — Tests

| Critère | Attendu |
|---|---|
| `new_logic_covered` | `true` — au moins 1 test si nouvelle logique métier |
| `no_fatal_errors` | `true` — aucune erreur fatale PHP dans les scripts |

**G2 ✅** → Phase 3.

**G2 ❌** → Spawne un agent de correction ciblé sur les scripts défaillants. Re-évalue. **Max 2 tentatives.**
Si G2 toujours ❌ → **HALT G2**.

---

## Phase 3 — Review (avec boucle de correction)

### 3.1 Lancer la review

Spawne un agent avec le prompt :

> Exécute le skill `/dev-review`.
> Retourne un bilan structuré JSON :
> ```json
> {
>   "findings_blocking": [],
>   "findings_to_fix": [],
>   "findings_notes": [],
>   "verdict": "go | go_with_reserves | no_go"
> }
> ```
> `findings_blocking` : points de niveau Bloquant uniquement.
> `findings_to_fix` : points "à corriger" avec correction suggérée.

### Gate G3 — Review

| Critère | Attendu |
|---|---|
| `findings_blocking` | `[]` — zéro point bloquant |

**G3 ✅** → Phase 4 (PR).

**G3 ❌** → Boucle de correction :

Spawne un agent de correction :

> Les points bloquants suivants ont été détectés par la review :
> {findings_blocking}
>
> Pour chaque point :
> 1. Lis le fichier concerné
> 2. Applique la correction en respectant les conventions du projet (CLAUDE.md)
> 3. Commite avec le format conventionnel
>
> Retourne un bilan des corrections effectuées.

Re-lance la review (retour en 3.1). **Max 2 boucles review → correction.**

Si G3 toujours ❌ après 2 boucles → **HALT G3**.

---

## Phase 4 — PR

Spawne un agent avec le prompt :

> Exécute le skill `/dev-pr`.
> Contexte disponible :
> - Analyse du ticket : {extrait synthèse du fichier d'analyse}
> - Tâches réalisées : {bilan_p1.tasks_completed}
> - Tests générés : {bilan_p2.scripts_generated}, {bilan_p2.manual_scenarios_count} scénarios manuels
> - Review : {findings_to_fix} points à noter, {findings_notes}
> Retourne l'URL de la PR une fois passée en ready.

---

## Rapport final

```
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
✅ dev-cycle terminé — {ticket-id}
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

📋 Implémentation
   Tâches    : {bilan_p1.tasks_completed}
   Commits   : {bilan_p1.commits}
   Fichiers  : {bilan_p1.files_modified}

🧪 Tests
   Scripts   : {bilan_p2.scripts_generated}
   Scénarios : {bilan_p2.manual_scenarios_count} manuels

🔍 Review
   Bloquants corrigés : {N}
   À corriger (non bloquant) : {findings_to_fix}
   À noter   : {findings_notes}

🔗 PR
   {url-pr}
   Statut : ready for review ✅

⚠️  Avertissements : {warnings ou "Aucun"}
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
```

---

## Protocole HALT

À chaque HALT, afficher :

```
🛑 HALT dev-cycle — Gate {GN} non passé

Critères en échec :
  - {critère} : attendu {valeur}
Tentatives de correction : {N}/2

Action requise :
  Corrige manuellement les points ci-dessus,
  puis relance /dev-cycle.
```
