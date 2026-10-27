import 'core/config/app_env.dart';
import 'core/config/firebase/firebase_options_staging.dart' as firebase;
import 'core/config/flavor_config.dart';
import 'bootstrap.dart';

Future<void> main() => bootstrap(
      FlavorConfig(
        flavor: AppFlavor.staging,
        appTitle: 'Busiserve Staging',
        firebaseOptions: () => firebase.DefaultFirebaseOptions.currentPlatform,
      ),
    );
