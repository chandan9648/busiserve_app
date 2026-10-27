import 'package:flutter/widgets.dart';
import 'package:get/get.dart';

import '../../../core/errors/app_exception.dart';
import '../../../routes/app_routes.dart';
import '../repositories/auth_repository.dart';

class LoginController extends GetxController {
  LoginController(this._repository, {String? redirect})
      : redirect = redirect ??
            (Get.arguments is Map ? (Get.arguments as Map)['redirect'] as String? : null);

  final AuthRepository _repository;
  final String? redirect;

  final formKey = GlobalKey<FormState>();
  final emailCtrl = TextEditingController();
  final passwordCtrl = TextEditingController();
  final passwordFocus = FocusNode();
  final isLoading = false.obs;
  final errorMessage = RxnString();

  Future<void> signIn() async {
    if (isLoading.value) return;
    errorMessage.value = null;
    if (!(formKey.currentState?.validate() ?? false)) return;
    isLoading.value = true;
    try {
      await _repository.signIn(emailCtrl.text, passwordCtrl.text);
      passwordCtrl.clear();
      final target = redirect;
      if (target != null && target != Routes.login) {
        await Get.offNamed<void>(target);
      } else {
        Get.back<void>();
      }
    } on AppException catch (e) {
      errorMessage.value = e.message;
    } finally {
      isLoading.value = false;
    }
  }

  void goToRegister() => Get.offNamed<void>(Routes.register, arguments: {'redirect': redirect});
  void goToForgotPassword() =>
      Get.toNamed<void>(Routes.forgotPassword, arguments: {'email': emailCtrl.text.trim()});

  @override
  void onClose() {
    emailCtrl.dispose();
    passwordCtrl.dispose();
    passwordFocus.dispose();
    super.onClose();
  }
}
