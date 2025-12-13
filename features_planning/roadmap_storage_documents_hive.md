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
- [x] Décision : persister **PDF + pages (images)** pour permettre édition, merge, split, reorder même après relance.
- [x] Décision (Option A) : à l’import d’un PDF, **rasteriser** chaque page en image puis traiter exactement comme un scan (pipeline unifié).
- [x] Valider les champs de `Document` (ce qui est *MVP* vs *plus tard*).
- [x] Valider l’arborescence des dossiers et conventions de nommage (id‑based).
- [x] Définir les règles de tri (ex: `updatedAt desc`) + pagination (si nécessaire).
- [ ] Définir la politique “clean-up” (fichiers orphelins, thumbnails manquantes, etc).

**DoD**
- Champs figés + format stable (versionné).
- On sait exactement ce qui est sauvegardé et quand.
- Pipeline unique (scan/import) basé sur des pages images persistées.

---

### Milestone 1 — Fondations techniques (1 journée)
- [x] Ajouter dépendances (`hive`, `hive_flutter`, `file_picker`, etc).
- [x] Initialiser Hive au démarrage (dans `main.dart`) + ouverture des `Box`.
- [x] Créer le “service layer” : `DocumentManager` (API unique) + staging FS.
- [x] Centraliser la résolution des chemins dans `DocumentManager` (baseDir + dossiers).

**DoD**
- App démarre avec Hive initialisé.
- `DocumentRepository` exposé via Riverpod (API vide mais en place).

---

### Milestone 2 — Stockage fichiers (PDF, pages, thumbnails) (1–2 jours)
- [x] Créer les dossiers `documents/`, `thumbnails/`, `pages/` (et `tmp/`) si absents.
- [x] Copier les pages vers `pages/<docId>/` lors du save.
- [x] Générer le PDF final dans `documents/<docId>.pdf` (à partir des pages de l’éditeur).
- [x] Générer une miniature (1ère page) dans `thumbnails/<docId>.jpg`.
- [x] Mettre en place un **commit atomique** :
  - [x] Écrire d’abord dans `tmp/`
  - [x] Puis “promouvoir” vers `documents/`/`pages/`/`thumbnails/`
  - [x] En cas d’échec : supprimer le staging

**DoD**
- On peut créer un PDF + thumbnail persistés dans le dossier app.
- Aucun chemin absolu n’est exposé à l’UI.

---

### Milestone 3 — Métadonnées Hive (1–2 jours)
- [x] Définir les `Box` :
  - [x] `documents_data` (clé = `documentId`, contient document + pages persistées)
  - [x] `documents_meta` (ex: `schema_version`)
- [x] Serialization JSON versionnée (sans TypeAdapter pour l’instant).
- [x] Implémenter opérations CRUD :
  - [x] `createDocumentFromPages(...)` (écrit metadata après succès FS)
  - [x] `updateDocumentFromPages(...)`
  - [x] `updateTitle(...)`
  - [x] `deleteDocument(...)` (metadata + fichiers)
- [ ] Implémenter “self-healing” au chargement :
  - [ ] Si PDF manquant → marquer doc “broken” ou supprimer (selon politique)
  - [ ] Si thumbnail manquante → régénérer lazy

**DoD**
- Relance app : la liste des documents revient (persistée).
- Suppression nettoie metadata + fichiers.

---

### Milestone 4 — Intégration UX/écrans (2–4 jours)
#### “Save” / “Create document” depuis l’éditeur
- [x] Ajouter une action “Enregistrer” dans `EditorScreen`.
- [x] Lors du save :
  - [x] Créer `documentId`
  - [x] Copier pages vers stockage app
  - [x] Générer `documents/<id>.pdf` + thumbnail
  - [x] Écrire metadata Hive
  - [x] Retourner à Home avec le nouveau doc en tête

#### Home = vraie liste (remplacer DummyData)
- [x] Remplacer les données factices par `documentsProvider` (stream Hive).
- [x] Afficher : titre, taille, date relative, status.
- [x] Tap sur un doc : ouvrir l’éditeur en mode “document existant”.

#### Document details / actions (MVP)
- [x] Partager le PDF (via `share_plus`).
- [ ] Renommer (update metadata) — service prêt (`updateTitle`) mais UI à ajouter.
- [x] Supprimer (Home, multi-sélection).

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
- Home est connecté à Hive via `documentsProvider` (plus de `DummyData` pour la liste).
- L’éditeur manipule des `ScanResult` (pages images) et persiste ces pages pour ré‑édition.

---

## Signatures (implémenté)

Approche : **non-destructive** (overlay UI + flatten à l’export PDF).

- Stockage signatures :
  - PNG transparent dans `signatures/<id>.png`
  - Métadonnées Hive : `signatures_data`
- Placements :
  - Persistés par page (`signaturePlacements`) avec coordonnées normalisées (0..1)
  - Affichés dans les previews (Editor + détail page) et exportés dans le PDF
