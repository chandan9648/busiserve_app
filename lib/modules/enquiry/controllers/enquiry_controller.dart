import 'package:flutter/widgets.dart';
import 'package:get/get.dart';

import '../../../core/errors/app_exception.dart';
import '../../../core/services/auth_session.dart';
import '../../../core/utils/idempotency.dart';
import '../../../routes/app_routes.dart';
import '../models/enquiry_model.dart';
import '../models/enquiry_subject.dart';
import '../repositories/enquiry_repository.dart';

class EnquiryController extends GetxController {
  EnquiryController(this._repository, this._session, {Map<String, dynamic>? arguments})
      : _arguments = arguments ?? (Get.arguments is Map<String, dynamic> ? Get.arguments as Map<String, dynamic> : null);

  final EnquiryRepository _repository;
  final AuthSession _session;
  final Map<String, dynamic>? _arguments;

  final formKey = GlobalKey<FormState>();
  final nameCtrl = TextEditingController();
  final emailCtrl = TextEditingController();
  final phoneCtrl = TextEditingController();
  final companyCtrl = TextEditingController();
  final messageCtrl = TextEditingController();

  final subject = Rxn<EnquirySubject>();
  final isSubmitting = false.obs;
  final errorMessage = RxnString();
  final fieldErrors = <String, String>{}.obs;

  /// One key per form session. Kept across failed attempts so a retry after a
  /// timeout cannot create a second enquiry; replaced only after success.
  String _idempotencyKey = IdempotencyKey.generate();
  String get idempotencyKeyForTest => _idempotencyKey;

  bool get isSignedIn => _session.isLoggedIn;

  @override
  void onInit() {
    super.onInit();
    subject.value = EnquirySubject.byId(_arguments?['subjectId'] as String?);
    if (_session.isLoggedIn) {
      nameCtrl.text = _session.displayName ?? '';
      emailCtrl.text = _session.email ?? '';
    }
  }

  String? serverError(String field) => fieldErrors[field];

  void clearServerError(String field) {
    if (fieldErrors.containsKey(field)) fieldErrors.remove(field);
  }

  Future<void> submit() async {
    if (isSubmitting.value) return;
    errorMessage.value = null;
    fieldErrors.clear();
    final valid = formKey.currentState?.validate() ?? false;
    if (!valid || subject.value == null) return;

    isSubmitting.value = true;
    try {
      final result = await _repository.submit(
        EnquiryRequest(
          idempotencyKey: _idempotencyKey,
          name: nameCtrl.text,
          email: emailCtrl.text,
          phone: phoneCtrl.text,
          company: companyCtrl.text,
          subjectId: subject.value!.id,
          message: messageCtrl.text,
        ),
      );
      _idempotencyKey = IdempotencyKey.generate();
      final email = emailCtrl.text.trim();
      messageCtrl.clear();
      await Get.offNamed<void>(
        Routes.enquirySuccess,
        arguments: {'reference': result.reference, 'email': email},
      );
    } on ValidationException catch (e) {
      fieldErrors.assignAll(e.fieldErrors);
      errorMessage.value = e.message;
      formKey.currentState?.validate();
    } on AppException catch (e) {
      errorMessage.value = e.message;
    } finally {
      isSubmitting.value = false;
    }
  }

  @override
  void onClose() {
    nameCtrl.dispose();
    emailCtrl.dispose();
    phoneCtrl.dispose();
    companyCtrl.dispose();
    messageCtrl.dispose();
    super.onClose();
  }
}
