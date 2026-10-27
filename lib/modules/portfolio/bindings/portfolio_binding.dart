import 'package:get/get.dart';

import '../../../core/config/flavor_config.dart';
import '../controllers/case_study_detail_controller.dart';
import '../datasources/portfolio_local_datasource.dart';
import '../datasources/portfolio_remote_datasource.dart';
import '../repositories/portfolio_repository.dart';

void registerPortfolioRepository() {
  if (Get.isRegistered<PortfolioRepository>()) return;
  Get.put(
    PortfolioRepository(
      local: const PortfolioLocalDataSource(),
      remote: FirebaseStatus.isReady ? FirestorePortfolioDataSource() : null,
    ),
    permanent: true,
  );
}

class CaseStudyDetailBinding extends Bindings {
  @override
  void dependencies() {
    registerPortfolioRepository();
    Get.lazyPut(() => CaseStudyDetailController(Get.find()));
  }
}
