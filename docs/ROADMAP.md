# 🗺️ PDF Organizer - Roadmap d'Implémentation

> Document de suivi pour l'implémentation des fonctionnalités MVP et Pro.  
> Dernière mise à jour : 2025-12-11 (Mourad)

---

## Vue d'ensemble du Pipeline

```
┌─────────────┐    ┌──────────────────┐    ┌──────────┐    ┌──────────┐
│   Camera    │───▶│ Image Processing │───▶│  Editor  │───▶│  Export  │
│   Module    │    │   (Transforms)   │    │  (Pages) │    │   (PDF)  │
└─────────────┘    └──────────────────┘    └──────────┘    └──────────┘
```

---

## Phase 1 : Camera Module 📷

**Objectif :** Capturer des documents via la caméra avec détection automatique des bords en temps réel.

### Stack technique

| Package | Rôle |
|---------|------|
| `camerawesome: ^2.0.0` | UI caméra 100% customisable |
| `google_mlkit_document_scanner: ^0.3.0` | Détection des bords (Android) |
| Note: iOS utilise `VNDocumentCameraViewController` nativement |

### Architecture

```
┌─────────────────────────────────────────────────────────┐
│                    CameraAwesomeBuilder                  │
│  ┌─────────────────────────────────────────────────────┐│
│  │              Camera Preview Stream                   ││
│  │  ┌─────────────────────────────────────────────┐    ││
│  │  │     CustomPaint (Polygon Overlay)           │    ││
│  │  │     - 4 corner points from ML Kit           │    ││
│  │  │     - Animated path drawing                  │    ││
│  │  └─────────────────────────────────────────────┘    ││
│  └─────────────────────────────────────────────────────┘│
│  ┌────────────┐  ┌────────────┐  ┌────────────────────┐ │
│  │   Flash    │  │  Capture   │  │  Gallery/Batch     │ │
│  └────────────┘  └────────────┘  └────────────────────┘ │
└─────────────────────────────────────────────────────────┘
```

### Checklist

- [x] **1.1 Setup CameraAwesome**
  - [x] Ajouter `camerawesome: ^2.0.0` au pubspec.yaml
  - [x] Ajouter les permissions caméra dans `AndroidManifest.xml` et `Info.plist`
  - [x] Créer `lib/features/camera/camera_screen.dart`
  - [x] Implémenter `CameraAwesomeBuilder` avec UI custom
  - [x] Ajouter le toggle caméra avant/arrière
  - [x] Implémenter le contrôle du flash (auto/on/off)

- [x] **1.2 Edge Detection Overlay (Real-time)**
  - [x] Ajouter `google_mlkit_document_scanner: ^0.3.0`
  - [x] Créer `lib/features/camera/painters/document_overlay_painter.dart`
  - [x] Connecter `imageStream` de camerawesome à ML Kit (Simulated for now)
  - [x] Dessiner le polygon en overlay avec `CustomPaint`
  - [x] Ajouter animation fluide lors de la détection
  - [x] Feedback visuel (couleur verte) quand document stable

- [x] **1.3 Capture d'image**
  - [x] Bouton de capture avec animation
  - [ ] Appliquer perspective transform automatiquement après capture (Blocked by real ML Kit)
  - [x] Prévisualisation de l'image capturée
  - [x] Option "Retake" ou "Confirm"
  - [x] Sauvegarde temporaire dans le cache

- [x] **1.4 Batch Scanning Mode**
  - [x] Mode multi-page (continuer après chaque capture)
  - [x] Compteur de pages scannées avec miniatures
  - [x] Bouton "Terminer le batch"
  - [x] Navigation vers l'éditeur avec toutes les pages

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
  - [x] Persistance de l'ordre

- [x] **3.3 Actions sur les pages**
  - [x] **Rotation** : 90° horaire/anti-horaire
  - [ ] **Crop** : Recadrage manuel avec resize handles (Blocked)
  - [x] **Delete** : Suppression avec confirmation
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
- `share_plus: ^7.2.1` (déjà installé)
- `path_provider: ^2.1.2`

### Checklist

- [x] **4.1 Génération PDF**
  - [x] Créer `lib/core/services/pdf_service.dart`
  - [x] Convertir les images en pages PDF
  - [x] Respecter l'orientation de chaque page
  - [x] Optimiser la taille du fichier (compression JPEG)

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
  - [ ] Sauvegarder les PDFs exportés localement
  - [ ] Afficher dans la liste "Récents" de HomeScreen
  - [ ] Option de ré-export/modification

---

## Phase 5 : Pro Features (Post-MVP) 💎

> Ces fonctionnalités sont verrouillées derrière le paywall RevenueCat.

### 5.1 On-Device OCR
- [ ] Intégrer `google_mlkit_text_recognition`
- [ ] Extraire le texte de chaque page
- [ ] Afficher/copier le texte extrait
- [ ] Rendre le PDF "searchable"

### 5.2 Signature Pad
- [ ] Créer un canvas de dessin vectoriel
- [ ] Sauvegarder les signatures
- [ ] Placement libre sur les pages PDF
- [ ] Redimensionnement de la signature

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

# Phase 1 - Camera (Custom UI + ML Kit)
camerawesome: ^2.0.0
google_mlkit_document_scanner: ^0.3.0

# Phase 2 - Image Processing
image: ^4.1.7
flutter_image_compress: ^2.1.0

# Phase 4 - Export
pdf: ^3.10.8
printing: ^5.12.0
path_provider: ^2.1.2

# Phase 5 - Pro Features
google_mlkit_text_recognition: ^0.11.0
signature: ^5.4.1
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
