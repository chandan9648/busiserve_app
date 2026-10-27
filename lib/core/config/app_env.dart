/// Build-time environment values supplied with `--dart-define-from-file=env/<flavor>.json`.
///
/// Nothing in here is secret. Privileged keys never belong in the app binary.
enum AppFlavor { dev, staging, prod }

class AppEnv {
  AppEnv._();

  static const String _flavorRaw =
      String.fromEnvironment('APP_FLAVOR', defaultValue: 'dev');

  static const String apiBaseUrl =
      String.fromEnvironment('API_BASE_URL', defaultValue: '');

  static const bool useFirebaseEmulator =
      bool.fromEnvironment('USE_FIREBASE_EMULATOR', defaultValue: false);

  static const String functionsRegion =
      String.fromEnvironment('FUNCTIONS_REGION', defaultValue: 'asia-south1');

  static AppFlavor get flavor => switch (_flavorRaw) {
        'prod' => AppFlavor.prod,
        'staging' => AppFlavor.staging,
        _ => AppFlavor.dev,
      };

  static bool get isProd => flavor == AppFlavor.prod;
  static bool get hasRestApi => apiBaseUrl.isNotEmpty;
}
