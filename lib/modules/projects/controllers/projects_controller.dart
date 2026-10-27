import 'dart:async';

import 'package:get/get.dart';

import '../../../core/errors/app_exception.dart';
import '../../../core/errors/failure.dart';
import '../../../core/state/view_state.dart';
import '../../../routes/app_routes.dart';
import '../models/project_model.dart';
import '../repositories/project_repository.dart';

class ProjectsController extends GetxController {
  ProjectsController(this._repository);
  final ProjectRepository _repository;

  final state = Rx<ViewState<List<ProjectModel>>>(const InitialState());
  StreamSubscription<List<ProjectModel>>? _sub;

  @override
  void onInit() {
    super.onInit();
    load();
  }

  void load() {
    _sub?.cancel();
    state.value = const LoadingState();
    try {
      _sub = _repository.watchMine().listen(
            (list) => state.value = listState(list),
            onError: (Object e) => state.value = ErrorState(
              e is AppException ? Failure.fromException(e) : const Failure('Something went wrong.', retryable: true),
            ),
          );
    } on AppException catch (e) {
      state.value = ErrorState(Failure.fromException(e));
    }
  }

  void open(ProjectModel p) => Get.toNamed<void>(Routes.projectPath(p.id));
  void startProject() => Get.toNamed<void>(Routes.enquiry);

  @override
  void onClose() {
    _sub?.cancel();
    super.onClose();
  }
}
