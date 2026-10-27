import 'package:get/get.dart';

import '../../../core/services/auth_session.dart';
import '../../../core/services/prefs_service.dart';
import '../../../core/services/push_notification_service.dart';
import '../controllers/delete_account_controller.dart';
import '../controllers/privacy_controller.dart';
import '../datasources/privacy_remote_datasource.dart';
import '../repositories/privacy_repository.dart';

class PrivacyBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut(
      () => PrivacyController(
        prefs: Get.find<PrefsService>(),
        session: Get.find<AuthSession>(),
        push: Get.isRegistered<PushNotificationService>() ? Get.find<PushNotificationService>() : null,
      ),
    );
  }
}

class DeleteAccountBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut(() => PrivacyRepository(remote: FirebasePrivacyDataSource(), session: Get.find<AuthSession>()));
    Get.lazyPut(() => DeleteAccountController(Get.find(), Get.find()));
  }
}
