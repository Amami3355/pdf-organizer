# 🗺️ PDF Organizer - Roadmap d'Implémentation

> Document de suivi pour l'implémentation des fonctionnalités MVP et Pro.  
> Dernière mise à jour : 2025-12-13 (Mourad)

---

## Vue d'ensemble du Pipeline

```
┌─────────────┐    ┌──────────────────┐    ┌──────────┐    ┌──────────────┐    ┌──────────┐
│ Scan/Import │───▶│ Image Processing │───▶│  Editor  │───▶│ Library (FS+DB)│───▶│  Export  │
│ (Scanner/PDF)│    │   (Transforms)   │    │  (Pages) │    │ (Hive + files) │    │   (PDF)  │
└─────────────┘    └──────────────────┘    └──────────┘    └──────────────┘    └──────────┘
```

---

## Phase 0 : Bibliothèque & stockage local (Hive + fichiers) 📚

**Objectif :** Persister les documents (métadonnées + fichiers) pour permettre réouverture, merge/split/reorder, et export.

### Décisions clés
- ✅ **Pas de Web** (Android/iOS uniquement)
- ✅ Stockage **local-first** : Hive (métadonnées) + filesystem (PDF/pages/thumbnails)
- ✅ En DB : **uniquement des noms relatifs** (jamais de chemins absolus)
- ✅ Pipeline unifié : scan et import PDF deviennent des **pages image** (Option A = rasterisation)

### Implémentation (référence code)
- `lib/core/services/document_manager.dart` (Hive + FS + staging `tmp/`)
- `lib/core/services/document_models.dart` (Document + pages persistées)
- Import PDF → `DocumentManager.rasterizePdfToPages(...)` (via `Printing.raster`)

### Checklist
- [x] Dossiers app : `documents/`, `thumbnails/`, `pages/`, `tmp/`
- [x] CRUD documents (create/update/delete) + watch stream pour Home
- [x] Réouverture d'un document existant dans l'éditeur
- [x] Merge de documents (Home, multi-sélection)
- [x] Split/extract de pages (Editor → nouveau document)
- [x] Reorder persistant (écran dédié “Manage pages” pour documents sauvegardés)

---

## Phase 1 : Camera Module 📷

**Objectif :** Scanner des documents avec détection automatique des bords et recadrage natif (UX type iScanner).

### Stack technique

| Package | Rôle |
|---------|------|
| `cunning_document_scanner: ^1.4.0` | Scanner natif (Android ML Kit / iOS VisionKit) |
| `permission_handler: ^12.0.1` | Gestion des permissions caméra |

> iOS : nécessite iOS 13+, `NSCameraUsageDescription`, et l'activation de `PERMISSION_CAMERA=1` dans le Podfile (permission_handler).

### Architecture

```
┌──────────────────┐    ┌──────────────────────────────┐    ┌──────────┐
│  CameraScreen    │───▶│  Scanner natif (UI intégrée)  │───▶│  Editor  │
│ (Flutter route)  │    │  - Auto edges + crop + filter │    │ (Pages)  │
└──────────────────┘    └──────────────────────────────┘    └──────────┘
```

### Checklist

- [x] **1.1 Scanner natif (clé en main)**
  - [x] Ajouter `cunning_document_scanner: ^1.4.0`
  - [x] Permissions caméra via `permission_handler`
  - [x] Lancer le scanner depuis `lib/features/camera/camera_screen.dart`
  - [x] Multi-pages (limite configurable) + import galerie (Android)
  - [x] Retourner les images recadrées vers l'éditeur (nouveau doc + ajout de pages)

---

## Phase 2 : Image Processing 🎨

**Objectif :** Appliquer des transformations pour améliorer la qualité des scans.

**Packages requis :**
- `image: ^4.1.7`
- `opencv_dart: ^1.0.0` (optionnel, pour perspective transform avancée)

### Checklist

- [ ] **2.1 Perspective Transform**
  - [x] Créer `lib/core/services/image_processing_service.dart`
  - [ ] Implémenter la correction de perspective (4 points → rectangle)
  - [ ] Appliquer automatiquement après détection des bords
  - [ ] Option de recadrage manuel

- [x] **2.2 Filtres d'image**
  - [x] Créer `lib/features/camera/widgets/filter_selector.dart` (UI in EditPageScreen)
  - [x] Implémenter filtre **Original** (aucune modification)
  - [x] Implémenter filtre **Black & White** (seuillage adaptatif)
  - [x] Implémenter filtre **Magic Color** (amélioration du contraste)
  - [x] Implémenter filtre **Grayscale** (niveaux de gris)
  - [x] Prévisualisation en temps réel des filtres

- [x] **2.3 Optimisations**
  - [x] Traitement en arrière-plan avec `compute()`
  - [x] Indicateur de chargement pendant le traitement
  - [ ] Caching des images traitées

---

## Phase 3 : Editor ✏️

**Objectif :** Permettre l'organisation et la modification des pages avant export.

**Note :** L'UI de base existe déjà dans `editor_screen.dart`.

### Checklist

- [x] **3.1 Gestion des pages**
  - [x] Créer `lib/features/editor/models/document_page.dart` (Using ScanResult)
  - [x] Créer `lib/features/editor/providers/editor_provider.dart` (Riverpod)
  - [x] Charger les images depuis le batch de scan
  - [x] Affichage en grille avec miniatures

- [x] **3.2 Réorganisation (Drag & Drop)**
  - [x] Implémenter `ReorderableGridView` ou équivalent
  - [x] Animation de drag fluide
  - [x] Feedback visuel de la position cible
  - [x] Persistance de l'ordre (documents sauvegardés)
  - [x] Écran “Manage pages” (drag & drop, puis save)

- [x] **3.3 Actions sur les pages**
  - [x] **Rotation** : 90° horaire/anti-horaire
  - [ ] **Crop** : Recadrage manuel avec resize handles (Blocked)
  - [x] **Delete** : Suppression avec confirmation
  - [x] **Extract/Split** : Extraire une sélection en nouveau document
  - [ ] **Duplicate** : Copie d'une page

- [x] **3.4 Ajout de pages**
  - [x] Bouton "+" pour ajouter depuis la caméra
  - [ ] Option d'import depuis la galerie
  - [ ] Insertion à une position spécifique

---

## Phase 4 : Export PDF 📄

**Objectif :** Générer un fichier PDF à partir des pages éditées.

**Packages requis :**
- `pdf: ^3.10.8`
- `printing: ^5.12.0`
- `share_plus: ^11.0.0` (pinned: compat Android/Kotlin)
- `path_provider: ^2.1.2`

### Checklist

- [x] **4.1 Génération PDF**
  - [x] Créer `lib/core/services/pdf_generator_service.dart`
  - [x] Convertir les images en pages PDF
  - [x] Respecter l'orientation de chaque page
  - [x] Optimiser la taille du fichier (compression JPEG)
  - [x] Support signatures (flatten à l'export)

- [ ] **4.2 Options d'export**
  - [ ] Créer `lib/features/export/export_options_sheet.dart`
  - [ ] Choix du nom de fichier
  - [ ] Sélection du format de page (A4, Letter, Original)
  - [ ] Qualité d'image (Haute, Moyenne, Basse)

- [x] **4.3 Share Sheet**
  - [x] Intégrer `share_plus` pour le partage système
  - [x] Option "Sauvegarder dans Fichiers"
  - [x] Option "Envoyer par email"
  - [x] Prévisualisation avant partage (optionnel)

- [ ] **4.4 Historique des documents**
  - [x] Sauvegarder les PDFs et pages localement (DocumentManager)
  - [x] Afficher dans la liste "Récents" de HomeScreen
  - [x] Réouverture/modification + ré-export

---

## Phase 5 : Pro Features (Post-MVP) 💎

> Ces fonctionnalités sont verrouillées derrière le paywall RevenueCat.

### 5.1 On-Device OCR
- [ ] Intégrer `google_mlkit_text_recognition`
- [ ] Extraire le texte de chaque page
- [ ] Afficher/copier le texte extrait
- [ ] Rendre le PDF "searchable"

### 5.2 Signature Pad
- [x] Créer un canvas de signature (doigt) via `signature`
- [x] Sauvegarder les signatures (PNG transparent + Hive metadata)
- [x] Placement libre sur les pages (drag + pinch)
- [x] Affichage en preview (overlay UI) + flatten lors de l'export PDF

### 5.3 Compression
- [ ] Slider de qualité (0-100%)
- [ ] Affichage de la taille estimée
- [ ] Compression par lot

### 5.4 Security (PDF Password)
- [ ] Chiffrement AES du PDF
- [ ] UI pour définir le mot de passe
- [ ] Confirmation du mot de passe

### 5.5 Remove Watermark/Ads
- [ ] Désactiver le watermark sur les PDFs
- [ ] Supprimer les bannières publicitaires

---

## Dépendances à ajouter

```yaml
# pubspec.yaml - Stack recommandée

# Phase 1 - Camera (Scanner natif)
cunning_document_scanner: ^1.4.0
permission_handler: ^12.0.1

# Phase 2 - Image Processing
image: ^4.1.7
flutter_image_compress: ^2.1.0

# Phase 4 - Export
pdf: ^3.10.8
printing: ^5.12.0
path_provider: ^2.1.2
share_plus: ^11.0.0

# Library (local storage)
hive: ^2.2.3
hive_flutter: ^1.1.0
file_picker: ^8.1.2

# Phase 5 - Pro Features
google_mlkit_text_recognition: ^0.11.0
signature: ^6.3.0
```

---

## Estimation du temps

| Phase | Durée estimée | Complexité |
|-------|---------------|------------|
| Phase 1 - Camera | 3-4 jours | 🔴 Haute |
| Phase 2 - Image Processing | 2-3 jours | 🟠 Moyenne |
| Phase 3 - Editor | 2-3 jours | 🟠 Moyenne |
| Phase 4 - Export | 1-2 jours | 🟢 Basse |
| **Total MVP** | **8-12 jours** | |
| Phase 5 - Pro Features | 5-7 jours | 🟠 Moyenne |

---

## Notes techniques

1. **State Management** : Utiliser Riverpod pour gérer l'état des pages dans l'éditeur.
2. **Performance** : Les traitements d'image lourds doivent utiliser `compute()` pour ne pas bloquer l'UI.
3. **Permissions** : Demander les permissions caméra/stockage au premier lancement.
4. **Tests** : Tester sur iOS et Android car le comportement de la caméra diffère.
