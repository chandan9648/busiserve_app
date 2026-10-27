import 'package:flutter/widgets.dart';
import 'package:get/get.dart';

import '../../../core/errors/app_exception.dart';
import '../../../routes/app_routes.dart';
import '../models/ticket_model.dart';
import '../repositories/support_repository.dart';

class CreateTicketController extends GetxController {
  CreateTicketController(this._repository, {Map<String, dynamic>? arguments})
      : _args = arguments ?? (Get.arguments is Map<String, dynamic> ? Get.arguments as Map<String, dynamic> : const {});

  final SupportRepository _repository;
  final Map<String, dynamic> _args;

  final formKey = GlobalKey<FormState>();
  final subjectCtrl = TextEditingController();
  final messageCtrl = TextEditingController();
  final category = TicketCategory.general.obs;
  final isSubmitting = false.obs;
  final errorMessage = RxnString();
  String? _relatedId;
  late String _ticketId;

  @override
  void onInit() {
    super.onInit();
    _ticketId = _repository.newTicketId();
    subjectCtrl.text = (_args['subject'] as String?) ?? '';
    category.value = TicketCategory.fromKey(_args['category'] as String?);
    _relatedId = _args['relatedId'] as String?;
  }

  Future<void> submit() async {
    if (isSubmitting.value) return;
    errorMessage.value = null;
    if (!(formKey.currentState?.validate() ?? false)) return;
    isSubmitting.value = true;
    try {
      await _repository.create(
        NewTicket(
          id: _ticketId,
          subject: subjectCtrl.text,
          category: category.value,
          message: messageCtrl.text,
          relatedId: _relatedId,
        ),
      );
      await Get.offNamed<void>(Routes.ticketPath(_ticketId));
    } on AppException catch (e) {
      errorMessage.value = e.message;
    } finally {
      isSubmitting.value = false;
    }
  }

  @override
  void onClose() {
    subjectCtrl.dispose();
    messageCtrl.dispose();
    super.onClose();
  }
}
