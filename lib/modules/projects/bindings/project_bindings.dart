import 'package:get/get.dart';

import '../../../core/services/auth_session.dart';
import '../controllers/project_detail_controller.dart';
import '../controllers/projects_controller.dart';
import '../datasources/project_remote_datasource.dart';
import '../repositories/project_repository.dart';

void _registerProjectRepository() {
  if (Get.isRegistered<ProjectRepository>()) return;
  Get.lazyPut(
    () => ProjectRepository(remote: FirestoreProjectDataSource(), session: Get.find<AuthSession>()),
    fenix: true,
  );
}

class ProjectsBinding extends Bindings {
  @override
  void dependencies() {
    _registerProjectRepository();
    Get.lazyPut(() => ProjectsController(Get.find()));
  }
}

class ProjectDetailBinding extends Bindings {
  @override
  void dependencies() {
    _registerProjectRepository();
    Get.lazyPut(() => ProjectDetailController(Get.find()));
  }
}
