import 'package:get/get.dart';

import '../../../core/constants/company_info.dart';
import '../../../core/errors/app_exception.dart';
import '../../../core/errors/failure.dart';
import '../../../core/state/view_state.dart';
import '../../../core/services/auth_session.dart';
import '../../../core/utils/launcher.dart';
import '../../../routes/app_routes.dart';
import '../../portfolio/models/case_study_model.dart';
import '../../portfolio/repositories/portfolio_repository.dart';
import '../../services/models/service_model.dart';
import '../../services/repositories/service_repository.dart';
import 'main_controller.dart';

class HomeController extends GetxController {
  HomeController(this._services, this._portfolio, this.session);

  final ServiceRepository _services;
  final PortfolioRepository _portfolio;
  final AuthSession session;

  final services = Rx<ViewState<List<ServiceModel>>>(const InitialState());
  final caseStudies = Rx<ViewState<List<CaseStudyModel>>>(const InitialState());

  @override
  void onInit() {
    super.onInit();
    refreshAll();
  }

  Future<void> refreshAll() => Future.wait([loadServices(refresh: true), loadCaseStudies(refresh: true)]);

  Future<void> loadServices({bool refresh = false}) async {
    if (services.value.isLoading) return;
    services.value = const LoadingState();
    try {
      services.value = listState(await _services.getServices(refresh: refresh));
    } on AppException catch (e) {
      services.value = ErrorState(Failure.fromException(e));
    }
  }

  Future<void> loadCaseStudies({bool refresh = false}) async {
    if (caseStudies.value.isLoading) return;
    caseStudies.value = const LoadingState();
    try {
      caseStudies.value = listState(await _portfolio.getCaseStudies(refresh: refresh));
    } on AppException catch (e) {
      caseStudies.value = ErrorState(Failure.fromException(e));
    }
  }

  void startProject() => Get.toNamed<void>(Routes.enquiry);
  void openService(ServiceModel s) => Get.toNamed<void>(Routes.serviceDetailPath(s.id));
  void openCaseStudy(CaseStudyModel c) => Get.toNamed<void>(Routes.caseStudyPath(c.id));
  void openNotifications() => Get.toNamed<void>(Routes.notifications);
  void showAllServices() => Get.find<MainController>().changeTab(MainController.services);
  void showAllWork() => Get.find<MainController>().changeTab(MainController.work);

  void callUs() => Launcher.call();
  void email() => Launcher.email(subject: 'Project enquiry');
  void openMap() => Launcher.web(CompanyInfo.mapsUrl);
}
