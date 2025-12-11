// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for French (`fr`).
class AppLocalizationsFr extends AppLocalizations {
  AppLocalizationsFr([String locale = 'fr']) : super(locale);

  @override
  String get appName => 'PDF Organizer';

  @override
  String get goodMorning => 'Bonjour';

  @override
  String get goodAfternoon => 'Bon après-midi';

  @override
  String get goodEvening => 'Bonsoir';

  @override
  String greeting(String name) {
    return 'Bonsoir, $name';
  }

  @override
  String newScansToday(int count) {
    return 'Vous avez $count nouveaux scans aujourd\'hui';
  }

  @override
  String get searchPlaceholder => 'Rechercher documents, PDFs, OCR';

  @override
  String get scanNew => 'Scanner';

  @override
  String get import => 'Importer';

  @override
  String get tools => 'Outils';

  @override
  String get recentDocuments => 'Documents récents';

  @override
  String get seeAll => 'Voir tout';

  @override
  String get home => 'Accueil';

  @override
  String get files => 'Fichiers';

  @override
  String get settings => 'Paramètres';

  @override
  String get export => 'Exporter';

  @override
  String get addPage => 'AJOUTER PAGE';

  @override
  String get sign => 'Signer';

  @override
  String get compress => 'Compresser';

  @override
  String get extract => 'Extraire';

  @override
  String get more => 'Plus';

  @override
  String pages(int count) {
    return '$count Pages';
  }

  @override
  String get settingsTitle => 'Paramètres';

  @override
  String get purchases => 'Achats';

  @override
  String get upgradeToPro => 'Passer à Pro';

  @override
  String get unlockAllFeatures => 'Débloquer toutes les fonctionnalités';

  @override
  String get restorePurchases => 'Restaurer les achats';

  @override
  String get purchasesRestoredSuccess => 'Achats restaurés avec succès !';

  @override
  String get noPreviousPurchases => 'Aucun achat précédent trouvé.';

  @override
  String get general => 'Général';

  @override
  String get rateApp => 'Noter l\'application';

  @override
  String get shareWithFriends => 'Partager avec des amis';

  @override
  String get contactSupport => 'Contacter le support';

  @override
  String get legal => 'Mentions légales';

  @override
  String get privacyPolicy => 'Politique de confidentialité';

  @override
  String get termsOfService => 'Conditions d\'utilisation';

  @override
  String get moreAppsByUs => 'NOS AUTRES APPLICATIONS';

  @override
  String get proUser => 'Utilisateur Pro';

  @override
  String get allFeaturesUnlocked => 'Toutes les fonctionnalités débloquées';

  @override
  String unlockProTitle(String appName) {
    return 'Débloquer $appName Pro';
  }

  @override
  String get oneTimePayment => 'Paiement unique. Accès à vie.';

  @override
  String get getLifetimeAccess => 'Obtenir l\'accès à vie';

  @override
  String get thankYouPurchase => 'Merci pour votre achat !';

  @override
  String get purchaseCancelledOrUnavailable => 'Achat annulé ou indisponible';

  @override
  String get restoring => 'Restauration...';

  @override
  String get featureUnlimitedPdf => 'Traitement PDF illimité';

  @override
  String get featureCloudSync => 'Synchronisation cloud multi-appareils';

  @override
  String get featureAdvancedEncryption => 'Chiffrement avancé';

  @override
  String get featurePrioritySupport => 'Support prioritaire';

  @override
  String get featureFreeUpdates => 'Mises à jour gratuites à vie';

  @override
  String get skip => 'Passer';

  @override
  String get continue_ => 'Continuer';

  @override
  String get getStarted => 'Commencer';

  @override
  String get onboardingTitle1 => 'Scanner des documents';

  @override
  String get onboardingDesc1 =>
      'Scannez rapidement des documents avec votre appareil photo et convertissez-les en PDF haute qualité.';

  @override
  String get onboardingTitle2 => 'Organiser les fichiers';

  @override
  String get onboardingDesc2 =>
      'Gardez tous vos documents organisés avec des dossiers, des tags et une recherche intelligente.';

  @override
  String get onboardingTitle3 => 'Éditer et signer';

  @override
  String get onboardingDesc3 =>
      'Ajoutez des signatures, des annotations et fusionnez plusieurs PDFs facilement.';

  @override
  String get onboardingTitle4 => 'Synchroniser partout';

  @override
  String get onboardingDesc4 =>
      'Accédez à vos documents depuis n\'importe quel appareil avec une synchronisation cloud sécurisée.';

  @override
  String get statusSynced => 'SYNCHRONISÉ';

  @override
  String get statusOcrReady => 'OCR PRÊT';

  @override
  String get statusSecured => 'SÉCURISÉ';

  @override
  String minsAgo(int count) {
    return 'il y a $count min';
  }

  @override
  String get hourAgo => 'il y a 1 heure';

  @override
  String get yesterday => 'Hier';

  @override
  String daysAgo(int count) {
    return 'il y a $count jours';
  }
}
