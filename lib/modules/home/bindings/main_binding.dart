import 'package:get/get.dart';

import '../../../core/services/auth_session.dart';
import '../../portfolio/bindings/portfolio_binding.dart';
import '../../portfolio/controllers/portfolio_controller.dart';
import '../../profile/bindings/profile_bindings.dart';
import '../../profile/controllers/profile_controller.dart';
import '../../services/bindings/services_binding.dart';
import '../../services/controllers/services_controller.dart';
import '../controllers/home_controller.dart';
import '../controllers/main_controller.dart';

/// Registers the four tab controllers; they live as long as the main shell.
class MainBinding extends Bindings {
  @override
  void dependencies() {
    registerServiceRepository();
    registerPortfolioRepository();
    registerProfileRepository();
    Get.lazyPut(MainController.new);
    Get.lazyPut(() => HomeController(Get.find(), Get.find(), Get.find<AuthSession>()));
    Get.lazyPut(() => ServicesController(Get.find()));
    Get.lazyPut(() => PortfolioController(Get.find()));
    Get.lazyPut(
      () => ProfileController(
        profileRepository: Get.find(),
        authRepository: Get.find(),
        session: Get.find<AuthSession>(),
        prefs: Get.find(),
      ),
    );
  }
}
