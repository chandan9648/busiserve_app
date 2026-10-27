import 'package:get/get.dart';

import '../../../core/errors/app_exception.dart';
import '../../../core/errors/failure.dart';
import '../../../core/state/view_state.dart';
import '../../../routes/app_routes.dart';
import '../models/case_study_model.dart';
import '../repositories/portfolio_repository.dart';

class PortfolioController extends GetxController {
  PortfolioController(this._repository);
  final PortfolioRepository _repository;

  final state = Rx<ViewState<List<CaseStudyModel>>>(const InitialState());
  final industry = RxnString();
  List<CaseStudyModel> _all = const [];

  List<String> get industries => {for (final c in _all) c.industry}.toList();

  @override
  void onInit() {
    super.onInit();
    load();
  }

  Future<void> load({bool refresh = false}) async {
    if (state.value.isLoading) return;
    state.value = const LoadingState();
    try {
      _all = await _repository.getCaseStudies(refresh: refresh);
      _apply();
    } on AppException catch (e) {
      state.value = ErrorState(Failure.fromException(e));
    }
  }

  void selectIndustry(String? value) {
    industry.value = industry.value == value ? null : value;
    _apply();
  }

  void _apply() {
    final i = industry.value;
    state.value = listState(i == null ? _all : _all.where((c) => c.industry == i).toList());
  }

  void open(CaseStudyModel c) => Get.toNamed(Routes.caseStudyPath(c.id));
}
