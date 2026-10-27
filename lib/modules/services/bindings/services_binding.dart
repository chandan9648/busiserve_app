import 'package:get/get.dart';

import '../../../core/config/flavor_config.dart';
import '../controllers/service_detail_controller.dart';
import '../datasources/service_local_datasource.dart';
import '../datasources/service_remote_datasource.dart';
import '../repositories/service_repository.dart';

/// Registers the catalogue repository once; it is shared by home, services
/// and enquiry, so it lives for the app session.
void registerServiceRepository() {
  if (Get.isRegistered<ServiceRepository>()) return;
  Get.put(
    ServiceRepository(
      local: const ServiceLocalDataSource(),
      remote: FirebaseStatus.isReady ? FirestoreServiceDataSource() : null,
    ),
    permanent: true,
  );
}

class ServiceDetailBinding extends Bindings {
  @override
  void dependencies() {
    registerServiceRepository();
    Get.lazyPut(() => ServiceDetailController(Get.find()));
  }
}
