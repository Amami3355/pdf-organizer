🏭 Flutter Micro-SaaS Factory : Le "Master Plan"Objectif : Créer un Starter Kit universel pour lancer 1 app par semaine.Architecture : Offline-first, Lifetime Payment, Cross-Promotion.1. L'Architecture "Cookie Cutter" (Structure de Dossiers)L'objectif est de séparer ce qui est fixe (Core) de ce qui est variable (Features). Donnez cette structure à l'IA pour chaque nouveau projet.lib/
├── config/                 # ⚙️ Configuration Globale
│   ├── theme.dart          # Couleurs & Fonts (Une seule var à changer)
│   ├── routes.dart         # GoRouter configuration
│   └── constants.dart      # Clés API (RevenueCat), URLs (Privacy, Support)
│
├── core/                   # 🧱 Les Briques Inamovibles (Ne touchez jamais !)
│   ├── services/
│   │   ├── purchase_service.dart  # RevenueCat Logic
│   │   ├── storage_service.dart   # SharedPrefs / Local Database
│   │   └── analytics_service.dart # (Optionnel) PostHog / Firebase
│   │
│   └── widgets/            # UI Kit Réutilisable
│       ├── primary_button.dart    # Le gros bouton d'action
│       ├── app_card.dart          # Le conteneur style "Apple"
│       ├── settings_tile.dart     # Ligne de menu paramètre
│       └── loading_overlay.dart   # Spinner pendant l'achat
│
├── features/               # 🚀 Le Code Unique de l'App (À vider pour chaque projet)
│   ├── home/               # Écran principal
│   ├── onboarding/         # Tutoriel de démarrage
│   ├── paywall/            # Écran de vente (Déjà codé, juste le texte change)
│   └── settings/           # Menu Paramètres (Déjà codé + Cross-Promo)
│
└── main.dart               # Point d'entrée
2. La "Tech Stack" (Dépendances)Installez ces packages immédiatement. Ils couvrent 99% des besoins des apps utilitaires.dependencies:
  # Navigation & UI
  go_router: ^14.0.0       # Navigation moderne
  flutter_svg: ^2.0.0      # Icônes vectorielles pro
  google_fonts: ^6.0.0     # Typographie
  url_launcher: ^6.2.0     # Ouvrir liens (Support, Web)
  share_plus: ^9.0.0       # Bouton partager natif
  in_app_review: ^2.0.0    # Demander des étoiles

  # Data & Logic
  shared_preferences: ^2.2.0 # Sauvegarde simple (Settings)
  path_provider: ^2.1.0      # Gestion fichiers locaux
  
  # 💰 Money (Crucial)
  purchases_flutter: ^6.0.0  # RevenueCat (Achats In-App)
3. Les Modules "Prêts à l'Emploi" (À coder maintenant)A. Le Module Monétisation (purchase_service.dart)C'est le cœur du réacteur. Il doit gérer l'initialisation, l'achat, et la restauration.Singleton : Une seule instance accessible partout.Logique : * init() : Se connecte à RevenueCat.purchaseLifetime() : Déclenche la pop-up Apple/Google.restore() : Vérifie si l'user a déjà payé.isProUser (bool) : Variable stockée en cache pour accès hors-ligne instantané.B. Le Module Cross-Promotion (Settings)C'est votre moteur de pub gratuit. Dans features/settings/settings_screen.dart.Data : Un fichier other_apps.json (ou une liste Dart statique pour commencer).const otherApps = [
  {'name': 'PDF Organizer', 'icon': 'assets/pdf_icon.png', 'url': '[https://apps.apple.com](https://apps.apple.com)...'},
  {'name': 'QR Manager', 'icon': 'assets/qr_icon.png', 'url': '[https://apps.apple.com](https://apps.apple.com)...'},
];
UI : Une section "More Apps by Us" avec un scroll horizontal. Chaque app est une AppCard cliquable.C. Le Design System Atomique (theme.dart)Pour changer le look d'une app en 30 secondes.class AppColors {
  // C'est la seule ligne à changer pour une nouvelle app !
  static const Color primary = Color(0xFF3B82F6); // Bleu pour PDF, Vert pour QR, etc.
  
  static const Color background = Color(0xFF0F172A);
  static const Color surface = Color(0xFF1E293B);
  static const Color textMain = Colors.white;
}
4. Le Workflow "Vibe Coding" (Procédure de Lancement)Voici la procédure exacte à suivre chaque Lundi matin pour lancer une nouvelle app.Étape 1 : ClonageDupliquer le dossier FLUTTER_STARTER_KIT.Renommer le dossier en MY_NEW_APP.Changer le package_name (Android) et Bundle ID (iOS).Étape 2 : Configuration RapideAller dans config/theme.dart ➔ Changer la couleur primaire.Aller dans config/constants.dart ➔ Mettre la nouvelle clé API RevenueCat.Aller dans assets/ ➔ Remplacer app_icon.png.Étape 3 : L'IA prend le relaisOuvrez Cursor/Windsurf et collez ce System Prompt :"Tu es mon Lead Dev Flutter. Nous travaillons sur le projet MY_NEW_APP basé sur notre Starter Kit interne.CONTEXTE :Cette app sert à : [DÉCRIRE LA FONCTIONNALITÉ UNIQUE ICI, ex: Signer des documents].Toute la logique 'Core' (Paiement, Settings, Thème) est DÉJÀ faite. N'y touche pas sauf demande explicite.Ton travail est de construire le dossier /features/home et /features/editor.RÈGLES :Utilise PurchaseService.instance.isPro pour vérifier si l'user a payé avant une action critique.Si non payé, redirige vers /paywall via GoRouter.Utilise les composants AppPrimaryButton et AppCard du dossier /core/widgets.ACTION :Commence par analyser le fichier main.dart pour comprendre la structure, puis propose le code pour l'écran d'accueil."5. Checklist de Pré-Lancement (Launch Day)[ ] Screenshots : Faire 3 captures d'écran (Home, Feature, Paywall).[ ] App Store Connect : Créer l'app et l'achat In-App "Lifetime".[ ] RevenueCat : Créer le projet et lier le produit App Store.[ ] Privacy Policy : Générer une page Notion simple et coller le lien dans constants.dart.[ ] Cross-Promo : Mettre à jour la liste des apps dans vos autres applications existantes pour pointer vers celle-ci.