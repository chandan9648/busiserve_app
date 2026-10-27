import 'package:get/get.dart';

import '../../../core/errors/app_exception.dart';
import '../../../core/errors/failure.dart';
import '../../../core/state/view_state.dart';
import '../../../core/utils/launcher.dart';
import '../../../routes/app_routes.dart';
import '../models/case_study_model.dart';
import '../repositories/portfolio_repository.dart';

class CaseStudyDetailController extends GetxController {
  CaseStudyDetailController(this._repository, {String? id}) : _id = id ?? Get.parameters['id'] ?? '';
  final PortfolioRepository _repository;
  final String _id;

  final state = Rx<ViewState<CaseStudyModel>>(const InitialState());

  @override
  void onInit() {
    super.onInit();
    load();
  }

  Future<void> load() async {
    if (state.value.isLoading) return;
    state.value = const LoadingState();
    try {
      state.value = SuccessState(await _repository.getCaseStudy(_id));
    } on AppException catch (e) {
      state.value = ErrorState(Failure.fromException(e));
    }
  }

  void openWebsite() {
    final c = state.value.dataOrNull;
    if (c != null) Launcher.web(c.websiteUrl);
  }

  void startSimilarProject() => Get.toNamed(Routes.enquiry);
}
