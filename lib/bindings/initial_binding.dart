import 'package:get/get.dart';

import '../core/config/app_env.dart';
import '../core/network/dio_client.dart';
import '../core/services/auth_session.dart';
import '../core/services/prefs_service.dart';
import '../core/services/push_notification_service.dart';
import '../core/services/secure_storage_service.dart';
import '../modules/auth/datasources/auth_remote_datasource.dart';
import '../modules/auth/repositories/auth_repository.dart';

/// App-lifetime dependencies. Feature dependencies live in feature bindings.
class InitialBinding extends Bindings {
  @override
  void dependencies() {
    final prefs = Get.put(PrefsService(), permanent: true);
    final secure = Get.put(SecureStorageService(), permanent: true);

    final AuthSession session = Get.put<AuthSession>(AuthService(), permanent: true);
    final push = Get.put(PushNotificationService(session: session, prefs: prefs), permanent: true);

    Get.put(
      AuthRepository(
        remote: FirebaseAuthDataSource(),
        session: session,
        beforeSignOut: push.unregister,
      ),
      permanent: true,
    );

    if (AppEnv.hasRestApi) {
      Get.put(DioClient(secureStorage: secure), permanent: true);
    }
  }
}
