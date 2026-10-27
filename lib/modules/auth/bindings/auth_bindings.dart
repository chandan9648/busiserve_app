import 'package:get/get.dart';

import '../controllers/forgot_password_controller.dart';
import '../controllers/login_controller.dart';
import '../controllers/register_controller.dart';

// AuthRepository is app-wide and registered in InitialBinding.

class LoginBinding extends Bindings {
  @override
  void dependencies() => Get.lazyPut(() => LoginController(Get.find()));
}

class RegisterBinding extends Bindings {
  @override
  void dependencies() => Get.lazyPut(() => RegisterController(Get.find()));
}

class ForgotPasswordBinding extends Bindings {
  @override
  void dependencies() => Get.lazyPut(() => ForgotPasswordController(Get.find()));
}
