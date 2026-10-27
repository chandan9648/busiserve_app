import 'dart:async';
import 'dart:ui';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cloud_functions/cloud_functions.dart';
import 'package:firebase_app_check/firebase_app_check.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get_storage/get_storage.dart';

import 'app.dart';
import 'core/config/app_env.dart';
import 'core/config/flavor_config.dart';
import 'core/utils/app_logger.dart';

/// Shared startup for every flavor.
Future<void> bootstrap(FlavorConfig config) async {
  WidgetsFlutterBinding.ensureInitialized();
  await GetStorage.init();
  await SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp, DeviceOrientation.portraitDown]);

  await _initFirebase(config);

  FlutterError.onError = (details) {
    AppLogger.error('Flutter error', error: details.exception, stackTrace: details.stack);
    if (kDebugMode) FlutterError.presentError(details);
  };
  PlatformDispatcher.instance.onError = (error, stack) {
    AppLogger.error('Uncaught error', error: error, stackTrace: stack);
    return true;
  };

  runApp(BusiserveApp(config: config));
}

Future<void> _initFirebase(FlavorConfig config) async {
  try {
    await Firebase.initializeApp(options: config.firebaseOptions());
    FirebaseStatus.isReady = true;
  } catch (e) {
    // Expected until `flutterfire configure` has been run for this flavor.
    FirebaseStatus.isReady = false;
    AppLogger.warning('Firebase not initialised for ${config.flavor.name}: public mode only.');
    return;
  }

  if (AppEnv.useFirebaseEmulator) {
    final host = defaultTargetPlatform == TargetPlatform.android && !kIsWeb ? '10.0.2.2' : 'localhost';
    await FirebaseAuth.instance.useAuthEmulator(host, 9099);
    FirebaseFirestore.instance.useFirestoreEmulator(host, 8080);
    FirebaseFunctions.instanceFor(region: AppEnv.functionsRegion).useFunctionsEmulator(host, 5001);
  }

  try {
    await FirebaseAppCheck.instance.activate(
      androidProvider: kReleaseMode ? AndroidProvider.playIntegrity : AndroidProvider.debug,
      appleProvider: kReleaseMode ? AppleProvider.appAttestWithDeviceCheckFallback : AppleProvider.debug,
    );
  } catch (e, st) {
    AppLogger.error('App Check activation failed', error: e, stackTrace: st);
  }

  if (!kIsWeb) {
    // Off unless the user opted in under Privacy and data.
    final consent = GetStorage().read<bool>('crash_reporting_consent') ?? false;
    final enabled = consent && !kDebugMode;
    await FirebaseCrashlytics.instance.setCrashlyticsCollectionEnabled(enabled);
    AppLogger.crashlyticsEnabled = enabled;
  }
}
