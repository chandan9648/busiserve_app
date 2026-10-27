import 'dart:async';

import 'package:get/get.dart';

import '../../../core/errors/app_exception.dart';
import '../../../core/errors/failure.dart';
import '../../../core/state/view_state.dart';
import '../../../routes/app_routes.dart';
import '../../enquiry/models/enquiry_model.dart';
import '../../enquiry/repositories/enquiry_repository.dart';
import '../models/quotation_model.dart';
import '../repositories/quotation_repository.dart';

/// Two live lists: the customer's enquiries and the quotations sent to them.
class MyEnquiriesController extends GetxController {
  MyEnquiriesController(this._enquiries, this._quotations);

  final EnquiryRepository _enquiries;
  final QuotationRepository _quotations;

  final enquiries = Rx<ViewState<List<EnquiryModel>>>(const InitialState());
  final quotations = Rx<ViewState<List<QuotationModel>>>(const InitialState());

  StreamSubscription<List<EnquiryModel>>? _enqSub;
  StreamSubscription<List<QuotationModel>>? _quoteSub;

  @override
  void onInit() {
    super.onInit();
    load();
  }

  void load() {
    loadEnquiries();
    loadQuotations();
  }

  void loadEnquiries() {
    _enqSub?.cancel();
    enquiries.value = const LoadingState();
    try {
      _enqSub = _enquiries.watchMine().listen(
            (list) => enquiries.value = listState(list),
            onError: (Object e) => enquiries.value = ErrorState(_failure(e)),
          );
    } on AppException catch (e) {
      enquiries.value = ErrorState(Failure.fromException(e));
    }
  }

  void loadQuotations() {
    _quoteSub?.cancel();
    quotations.value = const LoadingState();
    try {
      _quoteSub = _quotations.watchMine().listen(
            (list) => quotations.value = listState(list),
            onError: (Object e) => quotations.value = ErrorState(_failure(e)),
          );
    } on AppException catch (e) {
      quotations.value = ErrorState(Failure.fromException(e));
    }
  }

  Failure _failure(Object e) =>
      e is AppException ? Failure.fromException(e) : const Failure('Something went wrong. Try again.', retryable: true);

  void openQuotation(QuotationModel q) => Get.toNamed<void>(Routes.quotationPath(q.id));
  void newEnquiry() => Get.toNamed<void>(Routes.enquiry);

  @override
  void onClose() {
    _enqSub?.cancel();
    _quoteSub?.cancel();
    super.onClose();
  }
}
