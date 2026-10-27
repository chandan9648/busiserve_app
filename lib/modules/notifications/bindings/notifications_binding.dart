import 'package:get/get.dart';

import '../../../core/services/auth_session.dart';
import '../controllers/notifications_controller.dart';
import '../datasources/notification_remote_datasource.dart';
import '../repositories/notification_repository.dart';

class NotificationsBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut(
      () => NotificationRepository(remote: FirestoreNotificationDataSource(), session: Get.find<AuthSession>()),
    );
    Get.lazyPut(() => NotificationsController(Get.find()));
  }
}
