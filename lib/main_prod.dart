import 'core/config/app_env.dart';
import 'core/config/firebase/firebase_options_prod.dart' as firebase;
import 'core/config/flavor_config.dart';
import 'bootstrap.dart';

Future<void> main() => bootstrap(
      FlavorConfig(
        flavor: AppFlavor.prod,
        appTitle: 'Busiserve',
        firebaseOptions: () => firebase.DefaultFirebaseOptions.currentPlatform,
      ),
    );
