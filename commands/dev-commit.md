# dev-commit — Préparation du commit

Tu es un développeur senior qui prépare un commit propre et bien documenté.

## Contexte du projet

Lis le `CLAUDE.md` à la racine du projet pour connaître :
- `COMMIT_FORMAT` : `conventional` ou format custom décrit dans CLAUDE.md
- `BRANCH_PREFIX` : pour extraire l'identifiant du ticket depuis le nom de branche

## Numéro de ticket

$ARGUMENTS

Si un identifiant est fourni en argument, il doit apparaître dans le message de commit.
Si aucun argument n'est fourni, tente d'extraire l'identifiant depuis le nom de la branche courante.
Si aucun identifiant n'est trouvable, demande à l'utilisateur avant de continuer.

## Ce que tu dois faire

### 1. Vérification de la branche

Vérifie la branche courante : `git branch --show-current`

- Si la branche est `main`/`master` — **stoppe et avertis** : il ne faut pas committer directement sur la branche principale.
- Sinon, continue.

### 2. Analyse des changements

Lance `git diff --staged` pour voir les fichiers stagés.
Si rien n'est stagé, lance `git status` et `git diff` pour voir les changements non stagés.

### 3. Proposition de staging

Si des fichiers ne sont pas encore stagés :
- Identifie les fichiers qui font partie de ce commit
- Signale les fichiers qui semblent hors scope (à exclure ou à committer séparément)
- Propose la commande `git add` appropriée

### 4. Message de commit

**Si `COMMIT_FORMAT: conventional`** ou absent — utiliser Conventional Commits :

```
type(scope): #{id} description courte en impératif
```

Types : `fix`, `feat`, `refactor`, `test`, `docs`, `chore`
Scope : nom du module ou fichier principal touché

**Si format custom** — appliquer le format décrit dans CLAUDE.md.

Règles du message :
- Le message décrit le "pourquoi", pas seulement le "quoi"
- Un seul sujet par commit (si les changements couvrent plusieurs sujets, proposer de splitter)
- Description en impératif présent : "Ajoute", "Corrige", "Supprime"

### 5. Push

Une fois le commit effectué, pousse sur le remote :

```bash
git push
```

La PR draft est déjà ouverte — le push met à jour la PR automatiquement.
