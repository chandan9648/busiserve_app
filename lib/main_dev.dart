import 'core/config/app_env.dart';
import 'core/config/firebase/firebase_options_dev.dart' as firebase;
import 'core/config/flavor_config.dart';
import 'bootstrap.dart';

Future<void> main() => bootstrap(
      FlavorConfig(
        flavor: AppFlavor.dev,
        appTitle: 'Busiserve Dev',
        firebaseOptions: () => firebase.DefaultFirebaseOptions.currentPlatform,
      ),
    );
