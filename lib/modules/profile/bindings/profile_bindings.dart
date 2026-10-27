import 'package:get/get.dart';

import '../../../core/services/auth_session.dart';
import '../controllers/edit_profile_controller.dart';
import '../datasources/profile_remote_datasource.dart';
import '../repositories/profile_repository.dart';

void registerProfileRepository() {
  if (Get.isRegistered<ProfileRepository>()) return;
  Get.lazyPut(
    () => ProfileRepository(remote: FirestoreProfileDataSource(), session: Get.find<AuthSession>()),
    fenix: true,
  );
}

class EditProfileBinding extends Bindings {
  @override
  void dependencies() {
    registerProfileRepository();
    Get.lazyPut(() => EditProfileController(Get.find()));
  }
}
