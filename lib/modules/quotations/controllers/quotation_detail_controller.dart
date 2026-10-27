import 'dart:async';

import 'package:get/get.dart';

import '../../../core/errors/app_exception.dart';
import '../../../core/errors/failure.dart';
import '../../../core/state/view_state.dart';
import '../../../routes/app_routes.dart';
import '../models/quotation_model.dart';
import '../repositories/quotation_repository.dart';

class QuotationDetailController extends GetxController {
  QuotationDetailController(this._repository, {String? id}) : _id = id ?? Get.parameters['id'] ?? '';
  final QuotationRepository _repository;
  final String _id;

  final state = Rx<ViewState<QuotationModel>>(const InitialState());
  StreamSubscription<QuotationModel>? _sub;

  @override
  void onInit() {
    super.onInit();
    load();
  }

  void load() {
    _sub?.cancel();
    state.value = const LoadingState();
    try {
      _sub = _repository.watch(_id).listen(
            (q) => state.value = SuccessState(q),
            onError: (Object e) => state.value = ErrorState(
              e is AppException ? Failure.fromException(e) : const Failure('Something went wrong.', retryable: true),
            ),
          );
    } on AppException catch (e) {
      state.value = ErrorState(Failure.fromException(e));
    }
  }

  /// Questions and acceptance go through a support conversation, so a person
  /// at Busiserve confirms scope before any work starts.
  void discuss() {
    final q = state.value.dataOrNull;
    if (q == null) return;
    Get.toNamed<void>(
      Routes.createTicket,
      arguments: {'subject': 'About quotation: ${q.title}', 'category': 'quotation', 'relatedId': q.id},
    );
  }

  @override
  void onClose() {
    _sub?.cancel();
    super.onClose();
  }
}
