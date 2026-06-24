# Référence — Bonnes pratiques PHP génériques

## Standards

- **PSR-12** : style de code (indentation, accolades, espaces)
- **PSR-4** : autoloading (namespace → chemin de fichier)
- **PSR-3** : interface de logging (`LoggerInterface`)

---

## Sécurité PHP — Checklist obligatoire

### Validation des entrées utilisateur

```php
// Toujours filtrer et valider les données externes
$id = filter_input(INPUT_GET, 'id', FILTER_VALIDATE_INT);
if ($id === false || $id === null) {
    // Entrée invalide
}
```

### Injection SQL

```php
// ❌ Jamais de concaténation directe
$query = "SELECT * FROM users WHERE id = " . $_GET['id'];

// ✅ Toujours des requêtes préparées
$stmt = $pdo->prepare("SELECT * FROM users WHERE id = :id");
$stmt->execute([':id' => $id]);
```

### XSS — Échappement à l'affichage

```php
// ❌ Dangereux
echo $_GET['name'];

// ✅ Toujours échapper
echo htmlspecialchars($_GET['name'], ENT_QUOTES, 'UTF-8');
```

### Upload de fichiers — Checklist

1. Vérifier `UPLOAD_ERR_OK` avant tout traitement
2. Valider le type MIME côté serveur via `mime_content_type()` — **pas l'extension**
3. Utiliser une liste **blanche** de types MIME acceptés (pas une liste noire)
4. Valider la taille contre une constante nommée
5. Renommer le fichier — jamais conserver le nom original
6. Déplacer avec `move_uploaded_file()` uniquement
7. Stocker hors webroot ou dans un dossier non exécutable

### CSRF

- Toujours vérifier un token CSRF sur les formulaires POST modifiant des données
- Ne jamais faire une action d'écriture via GET

### Sessions

- `session_regenerate_id(true)` après login/changement de privilège
- Timeout explicite configuré
- Données sensibles non stockées en clair en session

---

## Gestion des erreurs

```php
// Pattern standard — retourner les erreurs, ne pas les afficher directement
public function save(array $data): array
{
    $errors = [];

    if (empty($data['title'])) {
        $errors[] = 'Le titre est obligatoire.';
    }

    if (!empty($errors)) {
        return ['success' => false, 'errors' => $errors];
    }

    // ... traitement
    return ['success' => true];
}
```

- Distinguer erreurs utilisateur (mauvaise saisie) et erreurs système (BDD down)
- Erreurs utilisateur → affichage dans la vue
- Erreurs système → log (`error_log()` ou logger PSR-3), jamais affichées à l'utilisateur

---

## Typage PHP

Activer le typage strict en tête de fichier :

```php
<?php
declare(strict_types=1);
```

Typer les paramètres et retours de fonction :

```php
// ✅ Bon
public function findById(int $id): ?User
{
    // ...
}
```

---

## Autoloading PSR-4

Structure de namespace recommandée :

```
src/
  Controller/   → App\Controller\
  Service/      → App\Service\
  Repository/   → App\Repository\
  Entity/       → App\Entity\
  Exception/    → App\Exception\
```

---

## Conventions à surcharger dans CLAUDE.md

Le fichier `CLAUDE.md` du projet prend le dessus sur ces conventions génériques.
Si votre projet a des règles différentes (framework legacy, conventions d'équipe), documentez-les dans `CLAUDE.md` > section "Conventions spécifiques au projet".
