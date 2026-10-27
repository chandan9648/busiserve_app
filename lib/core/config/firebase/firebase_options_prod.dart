// PLACEHOLDER — replace this file by running (from the project root):
//
//   flutterfire configure \
//     --project=<your-busiserve-prod-project-id> \
//     --out=lib/core/config/firebase/firebase_options_prod.dart \
//     --ios-bundle-id=in.busiserve.app \
//     --android-package-name=in.busiserve.app
//
// Until then the app starts without Firebase: public browsing works and
// account features report that the service is not configured.
import 'package:firebase_core/firebase_core.dart';

class DefaultFirebaseOptions {
  static FirebaseOptions get currentPlatform => throw UnsupportedError(
        'Firebase is not configured for the prod flavor. See README > Firebase setup.',
      );
}
