# Roadmap — Stockage des documents + métadonnées (Hive + fichiers)

## Objectif
Mettre en place un stockage **local, simple et robuste** pour :
- la **liste des documents** (métadonnées)
- les **fichiers** associés (PDF, miniatures, pages éventuelles)

Contraintes actées :
- **Pas de Web** (Android/iOS uniquement)
- Pas de base de données “complexe”
- **Jamais de chemin absolu en DB** : uniquement des **noms de fichiers relatifs** (ex: `scan_123.pdf`) car le chemin racine de l’app peut changer après update/réinstall.

---

## Décisions d’architecture (proposées)

### 1) Séparation “métadonnées vs fichiers”
- **Hive** stocke : id, titre, dates, flags, noms de fichiers relatifs, etc.
- Le **filesystem** stocke : PDF final, miniatures, pages/images (si nécessaire pour ré‑édition).

### 2) Dossiers locaux (dans `getApplicationDocumentsDirectory()`)
Proposition d’arborescence :
- `documents/` → PDFs (ex: `documents/<documentId>.pdf`)
- `thumbnails/` → miniatures (ex: `thumbnails/<documentId>.jpg`)
- `pages/` → pages image si on veut ré‑ouvrir l’éditeur plus tard (ex: `pages/<documentId>/<index>.jpg`)
- `tmp/` (optionnel) → staging avant commit (utile pour “transaction”)

> Règle : en Hive on stocke **uniquement** `"<documentId>.pdf"`, `"<documentId>.jpg"`, `"pages/<documentId>/0.jpg"` etc, jamais `/data/user/0/...`.

### 3) Accès aux données via une abstraction
Créer une API de type `DocumentRepository` (ou `DocumentManager`) pour éviter que l’UI touche directement Hive/FS.
- UI → `DocumentRepository` (via Riverpod)
- `DocumentRepository` → `Hive` + `FileStorage`

---

## Modèle de données (MVP)

### Document (métadonnées)
Champs recommandés (minimal mais suffisant) :
- `id: String` (UUID/ULID)
- `title: String`
- `createdAt: DateTime`
- `updatedAt: DateTime`
- `pdfFileName: String` (ex: `<id>.pdf`)
- `thumbnailFileName: String?` (ex: `<id>.jpg`)
- `pageCount: int`
- `isSigned: bool`
- `source: enum` (scan/import) *(optionnel mais utile)*
- `schemaVersion: int` *(ou version globale)*

### Page (si on persiste les pages pour ré‑édition)
Champs recommandés :
- `documentId: String`
- `index: int`
- `imageFileName: String` (ex: `pages/<id>/0.jpg`)
- `rotation: int` (0/90/180/270)
- `filter: enum` (original/bw/etc) *(si on implémente des filtres persistants)*

---

## Roadmap (checklist)

### Milestone 0 — Spécification finale (1/2 journée)
- [ ] Confirmer : on persiste **uniquement le PDF** ou **PDF + pages** (ré‑édition) ?
- [ ] Valider les champs de `Document` (ce qui est *MVP* vs *plus tard*).
- [ ] Valider l’arborescence des dossiers et conventions de nommage (id‑based).
- [ ] Définir les règles de tri (ex: `updatedAt desc`) + pagination (si nécessaire).
- [ ] Définir la politique “clean-up” (fichiers orphelins, thumbnails manquantes, etc).

**DoD**
- Champs figés + format stable (versionné).
- On sait exactement ce qui est sauvegardé et quand.

---

### Milestone 1 — Fondations techniques (1 journée)
- [ ] Ajouter dépendances (ex: `hive`, `hive_flutter`, éventuellement `uuid`, `path`).
- [ ] Initialiser Hive au démarrage (dans `main.dart`/bootstrap) + ouverture des `Box`.
- [ ] Créer le “service layer” : `DocumentRepository` + `FileStorage`.
- [ ] Ajouter un “app directory resolver” central (ex: `AppPaths`) pour construire les chemins.

**DoD**
- App démarre avec Hive initialisé.
- `DocumentRepository` exposé via Riverpod (API vide mais en place).

---

### Milestone 2 — Stockage fichiers (PDF, pages, thumbnails) (1–2 jours)
- [ ] Créer les dossiers `documents/`, `thumbnails/`, `pages/` si absents.
- [ ] Implémenter `FileStorage.copyPageImagesFromScan(paths)` vers `pages/<docId>/`.
- [ ] Générer le PDF final dans `documents/<docId>.pdf` (à partir des pages de l’éditeur).
- [ ] Générer une miniature (1ère page) dans `thumbnails/<docId>.jpg` (async).
- [ ] Mettre en place un **commit atomique** :
  - [ ] Écrire d’abord dans `tmp/`
  - [ ] Puis “promouvoir” vers `documents/`/`pages/`/`thumbnails/`
  - [ ] En cas d’échec : supprimer le staging

**DoD**
- On peut créer un PDF + thumbnail persistés dans le dossier app.
- Aucun chemin absolu n’est exposé à l’UI.

---

### Milestone 3 — Métadonnées Hive (1–2 jours)
- [ ] Définir les `Box` :
  - [ ] `documentsBox` (clé = `documentId`)
  - [ ] `pagesBox` (clé composite ou liste par document) *(si pages persistées)*
  - [ ] `metaBox` (ex: `schemaVersion`)
- [ ] Définir `TypeAdapter` (ou serialization) + stratégie de version/migration.
- [ ] Implémenter opérations CRUD :
  - [ ] `createDocument(...)` (écrit metadata après succès FS)
  - [ ] `updateTitle(...)`
  - [ ] `markSigned(...)`
  - [ ] `deleteDocument(...)` (metadata + fichiers)
- [ ] Implémenter “self-healing” au chargement :
  - [ ] Si PDF manquant → marquer doc “broken” ou supprimer (selon politique)
  - [ ] Si thumbnail manquante → régénérer lazy

**DoD**
- Relance app : la liste des documents revient (persistée).
- Suppression nettoie metadata + fichiers.

---

### Milestone 4 — Intégration UX/écrans (2–4 jours)
#### “Save” / “Create document” depuis l’éditeur
- [ ] Ajouter une action “Enregistrer” (ou “Terminer”) dans `EditorScreen`.
- [ ] Lors du save :
  - [ ] Créer `documentId`
  - [ ] Copier pages vers stockage app
  - [ ] Générer `documents/<id>.pdf` + thumbnail
  - [ ] Écrire metadata Hive
  - [ ] Retourner à Home avec le nouveau doc en tête

#### Home = vraie liste (remplacer DummyData)
- [ ] Remplacer `DummyData.recentDocuments` par un provider `documentsProvider`.
- [ ] Afficher : titre, taille (stockée ou calculée), date relative, pageCount, status.
- [ ] Tap sur un doc : ouvrir un écran “Document details / preview” (MVP).

#### Document details / actions (MVP)
- [ ] Ouvrir/partager le PDF (via `share_plus` / `printing`).
- [ ] Renommer (update metadata).
- [ ] Supprimer (delete).

**DoD**
- Flux complet : Scan → Editor → Save → Home (persistant) → Re-open/share/delete.

---

### Milestone 5 — Robustesse + maintenance (1–2 jours)
- [ ] Gestion erreurs UX (storage plein, permissions caméra, exceptions FS/Hive).
- [ ] Nettoyage orphelins au démarrage (optionnel) :
  - [ ] PDF sans metadata
  - [ ] metadata sans PDF
  - [ ] pages sans document
- [ ] Migration `schemaVersion` (au moins la structure et une stratégie claire).
- [ ] Option : exclure les PDFs/miniatures du backup iCloud si nécessaire (volumétrie).

**DoD**
- Cas bord : crash au milieu d’un save → pas de doc “fantôme” ou système récupérable.

---

### Milestone 6 — Performance (1–2 jours)
- [ ] Ne pas recalculer taille/thumbnail à chaque build : mettre en cache (metadata).
- [ ] Génération thumbnail en background (future + loader).
- [ ] Tri/index (si la liste grossit).
- [ ] Mesure : time-to-home, scroll perf, mémoire.

**DoD**
- Liste fluide avec 200+ documents, pas de jank au scroll.

---

## Tests / QA (checklist)
- [ ] Créer 10 documents, relancer l’app → tout est là.
- [ ] Supprimer un document → PDF + thumbnail + pages supprimés.
- [ ] Renommer → metadata change sans toucher aux fichiers.
- [ ] Simulation : supprimer manuellement un PDF → l’app gère (warning/cleanup).
- [ ] Gros scan (20+ pages) → save OK, UI reste responsive.
- [ ] Update app (build number) → chemins reconstruits correctement (car DB = relatif).

---

## Notes d’intégration avec l’existant
- Actuellement Home utilise `DummyData` (`lib/features/home/data/dummy_data.dart`) → à remplacer par un provider lié au `DocumentRepository`.
- L’éditeur manipule des `ScanResult` (images) → décider si on persiste ces pages pour ré‑édition, ou si on “aplatit” en PDF uniquement.

