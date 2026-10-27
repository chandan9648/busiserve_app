import 'package:flutter/widgets.dart';
import 'package:get/get.dart';

import '../../../core/errors/app_exception.dart';
import '../../../routes/app_routes.dart';
import '../../auth/repositories/auth_repository.dart';
import '../models/deletion_request_model.dart';
import '../repositories/privacy_repository.dart';

class DeleteAccountController extends GetxController {
  DeleteAccountController(this._privacy, this._auth);
  final PrivacyRepository _privacy;
  final AuthRepository _auth;

  final formKey = GlobalKey<FormState>();
  final passwordCtrl = TextEditingController();
  final reasonCtrl = TextEditingController();
  final confirmed = false.obs;
  final isDeleting = false.obs;
  final errorMessage = RxnString();

  Future<void> deleteAccount() async {
    if (isDeleting.value) return;
    errorMessage.value = null;
    if (!(formKey.currentState?.validate() ?? false)) return;
    if (!confirmed.value) {
      errorMessage.value = 'Tick the box to confirm you understand this cannot be undone.';
      return;
    }
    isDeleting.value = true;
    try {
      await _auth.reauthenticate(passwordCtrl.text);
      await _privacy.deleteAccount(DeletionRequest(reason: reasonCtrl.text));
      passwordCtrl.clear();
      await _auth.signOut().catchError((Object _) {});
      await Get.offAllNamed<void>(Routes.main);
      Get.snackbar('Account deleted', 'Your account and personal data have been removed.');
    } on AppException catch (e) {
      errorMessage.value = e.message;
    } finally {
      isDeleting.value = false;
    }
  }

  @override
  void onClose() {
    passwordCtrl.dispose();
    reasonCtrl.dispose();
    super.onClose();
  }
}
