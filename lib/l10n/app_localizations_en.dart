// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get appName => 'PDF Organizer';

  @override
  String get goodMorning => 'Good morning';

  @override
  String get goodAfternoon => 'Good afternoon';

  @override
  String get goodEvening => 'Good evening';

  @override
  String greeting(String name) {
    return 'Good evening, $name';
  }

  @override
  String newScansToday(int count) {
    return 'You have $count new scans today';
  }

  @override
  String get searchPlaceholder => 'Search documents, PDFs, OCR';

  @override
  String get scanNew => 'Scan New';

  @override
  String get import => 'Import';

  @override
  String get tools => 'Tools';

  @override
  String get recentDocuments => 'Recent Documents';

  @override
  String get seeAll => 'See All';

  @override
  String get home => 'Home';

  @override
  String get files => 'Files';

  @override
  String get settings => 'Settings';

  @override
  String get export => 'Export';

  @override
  String get addPage => 'ADD PAGE';

  @override
  String get sign => 'Sign';

  @override
  String get compress => 'Compress';

  @override
  String get extract => 'Extract';

  @override
  String get more => 'More';

  @override
  String pages(int count) {
    return '$count Pages';
  }

  @override
  String get settingsTitle => 'Settings';

  @override
  String get purchases => 'Purchases';

  @override
  String get upgradeToPro => 'Upgrade to Pro';

  @override
  String get unlockAllFeatures => 'Unlock all features';

  @override
  String get restorePurchases => 'Restore Purchases';

  @override
  String get purchasesRestoredSuccess => 'Purchases restored successfully!';

  @override
  String get noPreviousPurchases => 'No previous purchases found.';

  @override
  String get general => 'General';

  @override
  String get rateApp => 'Rate the App';

  @override
  String get shareWithFriends => 'Share with Friends';

  @override
  String get contactSupport => 'Contact Support';

  @override
  String get legal => 'Legal';

  @override
  String get privacyPolicy => 'Privacy Policy';

  @override
  String get termsOfService => 'Terms of Service';

  @override
  String get moreAppsByUs => 'MORE APPS BY US';

  @override
  String get proUser => 'Pro User';

  @override
  String get allFeaturesUnlocked => 'All features unlocked';

  @override
  String unlockProTitle(String appName) {
    return 'Unlock $appName Pro';
  }

  @override
  String get oneTimePayment => 'One-time payment. Lifetime access.';

  @override
  String get getLifetimeAccess => 'Get Lifetime Access';

  @override
  String get thankYouPurchase => 'Thank you for your purchase!';

  @override
  String get purchaseCancelledOrUnavailable =>
      'Purchase cancelled or unavailable';

  @override
  String get restoring => 'Restoring...';

  @override
  String get featureUnlimitedPdf => 'Unlimited PDF processing';

  @override
  String get featureCloudSync => 'Cloud sync across devices';

  @override
  String get featureAdvancedEncryption => 'Advanced encryption';

  @override
  String get featurePrioritySupport => 'Priority support';

  @override
  String get featureFreeUpdates => 'Free lifetime updates';

  @override
  String get skip => 'Skip';

  @override
  String get continue_ => 'Continue';

  @override
  String get getStarted => 'Get Started';

  @override
  String get onboardingTitle1 => 'Scan Documents';

  @override
  String get onboardingDesc1 =>
      'Quickly scan documents with your camera and convert them to high-quality PDFs.';

  @override
  String get onboardingTitle2 => 'Organize Files';

  @override
  String get onboardingDesc2 =>
      'Keep all your documents organized with folders, tags, and smart search.';

  @override
  String get onboardingTitle3 => 'Edit & Sign';

  @override
  String get onboardingDesc3 =>
      'Add signatures, annotations, and merge multiple PDFs with ease.';

  @override
  String get onboardingTitle4 => 'Sync Everywhere';

  @override
  String get onboardingDesc4 =>
      'Access your documents from any device with secure cloud sync.';

  @override
  String get statusSynced => 'SYNCED';

  @override
  String get statusOcrReady => 'OCR READY';

  @override
  String get statusSecured => 'SECURED';

  @override
  String minsAgo(int count) {
    return '$count mins ago';
  }

  @override
  String get hourAgo => '1 hour ago';

  @override
  String get yesterday => 'Yesterday';

  @override
  String daysAgo(int count) {
    return '$count days ago';
  }
}
