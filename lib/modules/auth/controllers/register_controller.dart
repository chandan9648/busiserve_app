import 'package:flutter/widgets.dart';
import 'package:get/get.dart';

import '../../../core/errors/app_exception.dart';
import '../../../routes/app_routes.dart';
import '../repositories/auth_repository.dart';

class RegisterController extends GetxController {
  RegisterController(this._repository, {String? redirect})
      : redirect = redirect ??
            (Get.arguments is Map ? (Get.arguments as Map)['redirect'] as String? : null);

  final AuthRepository _repository;
  final String? redirect;

  final formKey = GlobalKey<FormState>();
  final nameCtrl = TextEditingController();
  final emailCtrl = TextEditingController();
  final phoneCtrl = TextEditingController();
  final passwordCtrl = TextEditingController();
  final confirmCtrl = TextEditingController();

  final acceptedTerms = false.obs;
  final isLoading = false.obs;
  final errorMessage = RxnString();

  Future<void> register() async {
    if (isLoading.value) return;
    errorMessage.value = null;
    final valid = formKey.currentState?.validate() ?? false;
    if (!valid) return;
    if (!acceptedTerms.value) {
      errorMessage.value = 'Accept the Terms of Service and Privacy Policy to continue.';
      return;
    }
    isLoading.value = true;
    try {
      await _repository.register(
        name: nameCtrl.text,
        email: emailCtrl.text,
        password: passwordCtrl.text,
        phone: phoneCtrl.text,
      );
      passwordCtrl.clear();
      confirmCtrl.clear();
      Get.snackbar('Account created', 'We sent a verification link to ${emailCtrl.text.trim()}.');
      final target = redirect;
      if (target != null && target != Routes.register) {
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

  void goToLogin() => Get.offNamed<void>(Routes.login, arguments: {'redirect': redirect});

  @override
  void onClose() {
    nameCtrl.dispose();
    emailCtrl.dispose();
    phoneCtrl.dispose();
    passwordCtrl.dispose();
    confirmCtrl.dispose();
    super.onClose();
  }
}
