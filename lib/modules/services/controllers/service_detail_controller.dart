import 'package:get/get.dart';

import '../../../core/errors/app_exception.dart';
import '../../../core/errors/failure.dart';
import '../../../core/state/view_state.dart';
import '../../../core/utils/launcher.dart';
import '../../../routes/app_routes.dart';
import '../models/service_model.dart';
import '../repositories/service_repository.dart';

class ServiceDetailController extends GetxController {
  ServiceDetailController(this._repository, {String? serviceId})
      : _serviceId = serviceId ?? Get.parameters['id'] ?? '';

  final ServiceRepository _repository;
  final String _serviceId;
  final state = Rx<ViewState<ServiceModel>>(const InitialState());

  @override
  void onInit() {
    super.onInit();
    load();
  }

  Future<void> load() async {
    if (state.value.isLoading) return;
    state.value = const LoadingState();
    try {
      state.value = SuccessState(await _repository.getService(_serviceId));
    } on AppException catch (e) {
      state.value = ErrorState(Failure.fromException(e));
    }
  }

  void startEnquiry() =>
      Get.toNamed(Routes.enquiry, arguments: {'subjectId': _serviceId});

  void openWebsite() {
    final s = state.value.dataOrNull;
    if (s != null) Launcher.web(s.websiteUrl);
  }
}
