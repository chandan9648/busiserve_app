import 'package:firebase_core/firebase_core.dart';

import 'app_env.dart';

/// Per-flavor wiring passed in from `main_<flavor>.dart`.
class FlavorConfig {
  const FlavorConfig({
    required this.flavor,
    required this.appTitle,
    required this.firebaseOptions,
  });

  final AppFlavor flavor;
  final String appTitle;

  /// Returns the generated options for this flavor. Throws [UnsupportedError]
  /// until `flutterfire configure` has been run (see README).
  final FirebaseOptions Function() firebaseOptions;

}

/// Whether Firebase initialised successfully at startup.
///
/// Public screens (home, services, portfolio, contact) keep working when it
/// did not, so the app is browsable during setup. Account features show a
/// clear configuration error instead of crashing.
class FirebaseStatus {
  FirebaseStatus._();
  static bool isReady = false;
}
