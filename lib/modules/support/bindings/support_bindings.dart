import 'package:get/get.dart';

import '../../../core/services/auth_session.dart';
import '../controllers/create_ticket_controller.dart';
import '../controllers/ticket_detail_controller.dart';
import '../controllers/tickets_controller.dart';
import '../datasources/support_remote_datasource.dart';
import '../repositories/support_repository.dart';

void _registerSupportRepository() {
  if (Get.isRegistered<SupportRepository>()) return;
  Get.lazyPut(
    () => SupportRepository(remote: FirestoreSupportDataSource(), session: Get.find<AuthSession>()),
    fenix: true,
  );
}

class TicketsBinding extends Bindings {
  @override
  void dependencies() {
    _registerSupportRepository();
    Get.lazyPut(() => TicketsController(Get.find()));
  }
}

class CreateTicketBinding extends Bindings {
  @override
  void dependencies() {
    _registerSupportRepository();
    Get.lazyPut(() => CreateTicketController(Get.find()));
  }
}

class TicketDetailBinding extends Bindings {
  @override
  void dependencies() {
    _registerSupportRepository();
    Get.lazyPut(() => TicketDetailController(Get.find()));
  }
}
