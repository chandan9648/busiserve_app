import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart' show TargetPlatform, defaultTargetPlatform, kIsWeb;

import '../app_env.dart';

/// Firebase web client configuration is supplied via env/prod.json at build time.
/// These values are public client identifiers, not server credentials.
/// On Android, `null` lets the SDK read `android/app/google-services.json`.
class DefaultFirebaseOptions {
  static FirebaseOptions? get currentPlatform {
    if (!kIsWeb && defaultTargetPlatform == TargetPlatform.android) return null;
    if (!kIsWeb) {
      throw UnsupportedError(
        'Firebase native options are not configured for the prod flavor.',
      );
    }
    final missing = AppEnv.missingFirebaseKeys;
    if (missing.isNotEmpty) {
      throw StateError(
        'env/prod.json is incomplete: ${missing.join(', ')}. '
        'Copy env/prod.example.json and fill every value before building prod.',
      );
    }
    return const FirebaseOptions(
      apiKey: AppEnv.firebaseApiKey,
      authDomain: AppEnv.firebaseAuthDomain,
      projectId: AppEnv.firebaseProjectId,
      storageBucket: AppEnv.firebaseStorageBucket,
      messagingSenderId: AppEnv.firebaseMessagingSenderId,
      appId: AppEnv.firebaseAppId,
    );
  }
}
