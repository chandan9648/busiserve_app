import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart' show kIsWeb;

/// Firebase web client configuration is supplied via env/dev.local.json at build time.
/// These values are public client identifiers, not server credentials.
class DefaultFirebaseOptions {
  static FirebaseOptions get currentPlatform {
    const apiKey = String.fromEnvironment('FIREBASE_API_KEY');
    if (kIsWeb && apiKey.isNotEmpty) {
      return const FirebaseOptions(
        apiKey: apiKey,
        authDomain: String.fromEnvironment('FIREBASE_AUTH_DOMAIN'),
        projectId: String.fromEnvironment('FIREBASE_PROJECT_ID'),
        storageBucket: String.fromEnvironment('FIREBASE_STORAGE_BUCKET'),
        messagingSenderId: String.fromEnvironment('FIREBASE_MESSAGING_SENDER_ID'),
        appId: String.fromEnvironment('FIREBASE_APP_ID'),
      );
    }
    throw UnsupportedError(
      'Firebase is not configured for the dev flavor. See README > Firebase setup.',
    );
  }
}
