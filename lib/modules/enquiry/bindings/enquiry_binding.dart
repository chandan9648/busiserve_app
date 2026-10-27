import 'package:get/get.dart';

import '../../../core/services/auth_session.dart';
import '../controllers/enquiry_controller.dart';
import '../datasources/enquiry_remote_datasource.dart';
import '../repositories/enquiry_repository.dart';

void registerEnquiryRepository() {
  if (Get.isRegistered<EnquiryRepository>()) return;
  Get.lazyPut(
    () => EnquiryRepository(remote: FirebaseEnquiryDataSource(), session: Get.find<AuthSession>()),
    fenix: true,
  );
}

class EnquiryBinding extends Bindings {
  @override
  void dependencies() {
    registerEnquiryRepository();
    Get.lazyPut(() => EnquiryController(Get.find(), Get.find<AuthSession>()));
  }
}
