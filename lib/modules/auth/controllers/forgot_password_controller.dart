import 'package:flutter/widgets.dart';
import 'package:get/get.dart';

import '../../../core/errors/app_exception.dart';
import '../repositories/auth_repository.dart';

class ForgotPasswordController extends GetxController {
  ForgotPasswordController(this._repository);
  final AuthRepository _repository;

  final formKey = GlobalKey<FormState>();
  final emailCtrl = TextEditingController();
  final isLoading = false.obs;
  final sent = false.obs;
  final errorMessage = RxnString();

  @override
  void onInit() {
    super.onInit();
    final args = Get.arguments;
    if (args is Map && args['email'] is String) emailCtrl.text = args['email'] as String;
  }

  Future<void> send() async {
    if (isLoading.value) return;
    errorMessage.value = null;
    if (!(formKey.currentState?.validate() ?? false)) return;
    isLoading.value = true;
    try {
      await _repository.sendPasswordReset(emailCtrl.text);
      sent.value = true;
    } on AppException catch (e) {
      errorMessage.value = e.message;
    } finally {
      isLoading.value = false;
    }
  }

  @override
  void onClose() {
    emailCtrl.dispose();
    super.onClose();
  }
}
