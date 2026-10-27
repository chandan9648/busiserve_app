/// Build-time environment values supplied with `--dart-define-from-file=env/<flavor>.json`.
///
/// Nothing in here is secret. Privileged keys never belong in the app binary.
enum AppFlavor { dev, staging, prod }

class AppEnv {
  AppEnv._();

  static const String _flavorRaw = String.fromEnvironment('APP_FLAVOR', defaultValue: 'dev');

  static const String apiBaseUrl = String.fromEnvironment('API_BASE_URL', defaultValue: '');

  static const bool useFirebaseEmulator = bool.fromEnvironment('USE_FIREBASE_EMULATOR', defaultValue: false);

  static const String functionsRegion = String.fromEnvironment('FUNCTIONS_REGION', defaultValue: 'asia-south1');

  // Firebase web client configuration: public identifiers, not server credentials.
  static const String firebaseApiKey = String.fromEnvironment('FIREBASE_API_KEY');
  static const String firebaseAuthDomain = String.fromEnvironment('FIREBASE_AUTH_DOMAIN');
  static const String firebaseProjectId = String.fromEnvironment('FIREBASE_PROJECT_ID');
  static const String firebaseStorageBucket = String.fromEnvironment('FIREBASE_STORAGE_BUCKET');
  static const String firebaseMessagingSenderId = String.fromEnvironment('FIREBASE_MESSAGING_SENDER_ID');
  static const String firebaseAppId = String.fromEnvironment('FIREBASE_APP_ID');

  /// reCAPTCHA v3 site key backing App Check on web. The callables deploy with
  /// `enforceAppCheck`, so a web build without this key cannot reach them.
  static const String appCheckRecaptchaSiteKey = String.fromEnvironment('FIREBASE_APPCHECK_RECAPTCHA_SITE_KEY');

  static AppFlavor get flavor => switch (_flavorRaw) {
        'prod' => AppFlavor.prod,
        'staging' => AppFlavor.staging,
        _ => AppFlavor.dev,
      };

  static bool get isProd => flavor == AppFlavor.prod;
  static bool get hasRestApi => apiBaseUrl.isNotEmpty;

  /// Firebase keys the build did not supply, so a misconfigured build can say
  /// which env entry is blank instead of failing with an opaque Firebase error.
  static List<String> get missingFirebaseKeys => const {
        'FIREBASE_API_KEY': firebaseApiKey,
        'FIREBASE_AUTH_DOMAIN': firebaseAuthDomain,
        'FIREBASE_PROJECT_ID': firebaseProjectId,
        'FIREBASE_STORAGE_BUCKET': firebaseStorageBucket,
        'FIREBASE_MESSAGING_SENDER_ID': firebaseMessagingSenderId,
        'FIREBASE_APP_ID': firebaseAppId,
      }.entries.where((e) => e.value.isEmpty).map((e) => e.key).toList();

  static bool get hasFirebaseConfig => missingFirebaseKeys.isEmpty;
}
