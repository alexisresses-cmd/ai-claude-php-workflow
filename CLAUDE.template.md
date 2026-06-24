# Profil Développeur — [Nom du projet]

> Copier ce fichier en `CLAUDE.md` à la racine de chaque projet et compléter les sections.
> Les skills lisent ce fichier pour adapter leur comportement à votre projet.

---

## Identité

- **Rôle** : Développeur [Fullstack / Backend / Frontend] confirmé
- **Expérience** : [X] ans
- **Langages principaux** : PHP [, JavaScript, TypeScript…]

---

## Stack technique

### Backend
- **Langage** : PHP [version, ex: 8.2]
- **Framework** : [Symfony / Laravel / Custom / Aucun]
- **Architecture** : [MVC / Hexagonale / DDD / Layered]
- **ORM / BDD** : [Doctrine / Eloquent / PDO natif] + [MySQL / PostgreSQL]

### Frontend
- [JavaScript / TypeScript / Vue / React / jQuery / Twig / Blade…]

### Outils
- Git / GitHub
- [PHPStorm / VS Code]
- [Docker / Vagrant / WAMP / autre]

---

## Conventions de code

- **Standard** : PSR-12, PSR-4
- **Style** : [Décrire ici vos conventions spécifiques — nommage, préfixes, patterns…]

Exemples de conventions à documenter :
- Nommage des méthodes : `getXxx()` pour lecture, `setXxx()` pour écriture
- Nommage des variables : camelCase / snake_case
- Taille max d'une méthode : ~20 lignes
- [Ajoutez vos règles ici]

---

## Conventions Git

```
BRANCH_PREFIX: feat/
# Exemples : feat/, fix/, hotfix/, TEAM/TB#, feature/
# Le skill /dev-branch utilisera ce préfixe
# Convention complète : {BRANCH_PREFIX}{ticket-id}-{slug}
# Exemple : feat/42-user-profile-upload

COMMIT_FORMAT: conventional
# conventional → type(scope): description
# custom       → décrire le format ci-dessous
```

---

## Gestion de tickets

```
ISSUE_TRACKER: github
# github  → gh issue view {id} (nécessite gh CLI configuré)
# trello  → fournir l'URL de la carte Trello
# text    → coller le contenu directement dans le prompt
```

---

## Workflow de review

```
MAIN_REVIEWER: @github-handle
# Handle GitHub du reviewer principal (utilisé par /review-return)
# Laisser vide si non applicable
```

---

## Conventions spécifiques au projet

> Documentez ici tout ce qui est propre à ce projet et non dérivable du code.
> Les skills injectent ce contenu dans les agents pour contextualiser leur analyse.

### Architecture
- [Décrire l'organisation des dossiers, les layers, les patterns principaux]

### Patterns récurrents
- [Ex : "Les services sont dans src/Service/, injectés par constructor injection"]
- [Ex : "Toujours passer par le Repository, jamais l'EntityManager directement"]

### Pièges connus
- [Ex : "Ne pas modifier la signature de XxxInterface — partagée avec l'API"]
- [Ex : "Les migrations sont irréversibles en prod — double-check avant tout ALTER"]

### Points d'attention sécurité
- [Ex : "Toujours valider les uploads côté serveur (MIME + taille + renommage)"]
- [Ex : "Les routes admin sont protégées par le middleware AdminMiddleware"]

---

## Comment je préfère travailler avec Claude

- Répondre en **français** par défaut
- Privilégier des **explications concises** avec du code commenté si nécessaire
- Proposer des **alternatives** quand plusieurs approches existent
- Signaler les **bonnes pratiques** et les pièges courants
- Ne pas sur-expliquer les bases — niveau confirmé
