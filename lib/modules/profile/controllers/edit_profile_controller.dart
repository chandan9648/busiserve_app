import 'dart:async';

import 'package:flutter/widgets.dart';
import 'package:get/get.dart';

import '../../../core/errors/app_exception.dart';
import '../repositories/profile_repository.dart';

class EditProfileController extends GetxController {
  EditProfileController(this._repository);
  final ProfileRepository _repository;

  final formKey = GlobalKey<FormState>();
  final nameCtrl = TextEditingController();
  final phoneCtrl = TextEditingController();
  final companyCtrl = TextEditingController();
  final isLoading = true.obs;
  final isSaving = false.obs;
  final errorMessage = RxnString();
  String email = '';

  @override
  void onInit() {
    super.onInit();
    _prefill();
  }

  Future<void> _prefill() async {
    try {
      final p = await _repository.watchMine().first.timeout(const Duration(seconds: 15));
      nameCtrl.text = p.name;
      phoneCtrl.text = p.phone ?? '';
      companyCtrl.text = p.company ?? '';
      email = p.email;
    } on AppException catch (e) {
      errorMessage.value = e.message;
    } on TimeoutException {
      errorMessage.value = 'Could not load your details. You can still edit and save.';
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> save() async {
    if (isSaving.value) return;
    errorMessage.value = null;
    if (!(formKey.currentState?.validate() ?? false)) return;
    isSaving.value = true;
    try {
      await _repository.update(name: nameCtrl.text, phone: phoneCtrl.text, company: companyCtrl.text);
      Get.back<void>();
      Get.snackbar('Profile updated', 'Your details have been saved.');
    } on AppException catch (e) {
      errorMessage.value = e.message;
    } finally {
      isSaving.value = false;
    }
  }

  @override
  void onClose() {
    nameCtrl.dispose();
    phoneCtrl.dispose();
    companyCtrl.dispose();
    super.onClose();
  }
}
