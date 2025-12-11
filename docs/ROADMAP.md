# 🗺️ PDF Organizer - Roadmap d'Implémentation

> Document de suivi pour l'implémentation des fonctionnalités MVP et Pro.  
> Dernière mise à jour : 2025-12-11

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

**Objectif :** Capturer des documents via la caméra avec détection automatique des bords.

**Packages requis :**
- `camera: ^0.10.5+9`
- `image: ^4.1.7`
- `google_mlkit_document_scanner: ^0.3.0` (alternative native)

### Checklist

- [ ] **1.1 Setup Camera**
  - [ ] Ajouter les permissions caméra dans `AndroidManifest.xml` et `Info.plist`
  - [ ] Créer `lib/features/camera/camera_screen.dart`
  - [ ] Implémenter l'initialisation de la caméra avec `CameraController`
  - [ ] Ajouter le toggle caméra avant/arrière
  - [ ] Implémenter le contrôle du flash (auto/on/off)

- [ ] **1.2 Capture d'image**
  - [ ] Bouton de capture avec animation
  - [ ] Prévisualisation de l'image capturée
  - [ ] Option "Retake" ou "Confirm"
  - [ ] Sauvegarde temporaire dans le cache

- [ ] **1.3 Auto Edge Detection**
  - [ ] Intégrer une solution de détection de contours (OpenCV ou ML Kit)
  - [ ] Afficher le rectangle de détection en overlay
  - [ ] Permettre l'ajustement manuel des coins si nécessaire
  - [ ] Feedback visuel quand un document est détecté

- [ ] **1.4 Batch Scanning Mode**
  - [ ] Mode multi-page (continuer après chaque capture)
  - [ ] Compteur de pages scannées
  - [ ] Bouton "Terminer le batch"
  - [ ] Navigation vers l'éditeur avec toutes les pages

---

## Phase 2 : Image Processing 🎨

**Objectif :** Appliquer des transformations pour améliorer la qualité des scans.

**Packages requis :**
- `image: ^4.1.7`
- `opencv_dart: ^1.0.0` (optionnel, pour perspective transform avancée)

### Checklist

- [ ] **2.1 Perspective Transform**
  - [ ] Créer `lib/core/services/image_processing_service.dart`
  - [ ] Implémenter la correction de perspective (4 points → rectangle)
  - [ ] Appliquer automatiquement après détection des bords
  - [ ] Option de recadrage manuel

- [ ] **2.2 Filtres d'image**
  - [ ] Créer `lib/features/camera/widgets/filter_selector.dart`
  - [ ] Implémenter filtre **Original** (aucune modification)
  - [ ] Implémenter filtre **Black & White** (seuillage adaptatif)
  - [ ] Implémenter filtre **Magic Color** (amélioration du contraste)
  - [ ] Implémenter filtre **Grayscale** (niveaux de gris)
  - [ ] Prévisualisation en temps réel des filtres

- [ ] **2.3 Optimisations**
  - [ ] Traitement en arrière-plan avec `compute()`
  - [ ] Indicateur de chargement pendant le traitement
  - [ ] Caching des images traitées

---

## Phase 3 : Editor ✏️

**Objectif :** Permettre l'organisation et la modification des pages avant export.

**Note :** L'UI de base existe déjà dans `editor_screen.dart`.

### Checklist

- [ ] **3.1 Gestion des pages**
  - [ ] Créer `lib/features/editor/models/document_page.dart`
  - [ ] Créer `lib/features/editor/providers/editor_provider.dart` (Riverpod)
  - [ ] Charger les images depuis le batch de scan
  - [ ] Affichage en grille avec miniatures

- [ ] **3.2 Réorganisation (Drag & Drop)**
  - [ ] Implémenter `ReorderableGridView` ou équivalent
  - [ ] Animation de drag fluide
  - [ ] Feedback visuel de la position cible
  - [ ] Persistance de l'ordre

- [ ] **3.3 Actions sur les pages**
  - [ ] **Rotation** : 90° horaire/anti-horaire
  - [ ] **Crop** : Recadrage manuel avec resize handles
  - [ ] **Delete** : Suppression avec confirmation
  - [ ] **Duplicate** : Copie d'une page

- [ ] **3.4 Ajout de pages**
  - [ ] Bouton "+" pour ajouter depuis la caméra
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

- [ ] **4.1 Génération PDF**
  - [ ] Créer `lib/core/services/pdf_service.dart`
  - [ ] Convertir les images en pages PDF
  - [ ] Respecter l'orientation de chaque page
  - [ ] Optimiser la taille du fichier (compression JPEG)

- [ ] **4.2 Options d'export**
  - [ ] Créer `lib/features/export/export_options_sheet.dart`
  - [ ] Choix du nom de fichier
  - [ ] Sélection du format de page (A4, Letter, Original)
  - [ ] Qualité d'image (Haute, Moyenne, Basse)

- [ ] **4.3 Share Sheet**
  - [ ] Intégrer `share_plus` pour le partage système
  - [ ] Option "Sauvegarder dans Fichiers"
  - [ ] Option "Envoyer par email"
  - [ ] Prévisualisation avant partage (optionnel)

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
# pubspec.yaml - À ajouter progressivement

# Phase 1 - Camera
camera: ^0.10.5+9
image: ^4.1.7

# Phase 2 - Image Processing (optionnel pour OpenCV)
# opencv_dart: ^1.0.0

# Phase 4 - Export
pdf: ^3.10.8
printing: ^5.12.0
path_provider: ^2.1.2

# Phase 5 - Pro Features
google_mlkit_text_recognition: ^0.11.0
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
