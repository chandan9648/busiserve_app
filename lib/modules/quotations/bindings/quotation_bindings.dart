import 'package:get/get.dart';

import '../../../core/services/auth_session.dart';
import '../../enquiry/bindings/enquiry_binding.dart';
import '../controllers/my_enquiries_controller.dart';
import '../controllers/quotation_detail_controller.dart';
import '../datasources/quotation_remote_datasource.dart';
import '../repositories/quotation_repository.dart';

void _registerQuotationRepository() {
  if (Get.isRegistered<QuotationRepository>()) return;
  Get.lazyPut(
    () => QuotationRepository(remote: FirestoreQuotationDataSource(), session: Get.find<AuthSession>()),
    fenix: true,
  );
}

class MyEnquiriesBinding extends Bindings {
  @override
  void dependencies() {
    registerEnquiryRepository();
    _registerQuotationRepository();
    Get.lazyPut(() => MyEnquiriesController(Get.find(), Get.find()));
  }
}

class QuotationDetailBinding extends Bindings {
  @override
  void dependencies() {
    _registerQuotationRepository();
    Get.lazyPut(() => QuotationDetailController(Get.find()));
  }
}
