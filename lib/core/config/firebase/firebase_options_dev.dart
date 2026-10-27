import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart' show kIsWeb;

import '../app_env.dart';

/// Firebase web client configuration is supplied via env/dev.local.json at build time.
/// These values are public client identifiers, not server credentials.
class DefaultFirebaseOptions {
  static FirebaseOptions get currentPlatform {
    if (kIsWeb && AppEnv.hasFirebaseConfig) {
      return const FirebaseOptions(
        apiKey: AppEnv.firebaseApiKey,
        authDomain: AppEnv.firebaseAuthDomain,
        projectId: AppEnv.firebaseProjectId,
        storageBucket: AppEnv.firebaseStorageBucket,
        messagingSenderId: AppEnv.firebaseMessagingSenderId,
        appId: AppEnv.firebaseAppId,
      );
    }
    throw UnsupportedError(
      'Firebase is not configured for the dev flavor. See README > Firebase setup.',
    );
  }
}
