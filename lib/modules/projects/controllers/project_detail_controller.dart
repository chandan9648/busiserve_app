import 'dart:async';

import 'package:get/get.dart';

import '../../../core/errors/app_exception.dart';
import '../../../core/errors/failure.dart';
import '../../../core/state/view_state.dart';
import '../../../routes/app_routes.dart';
import '../models/project_model.dart';
import '../repositories/project_repository.dart';

class ProjectDetailController extends GetxController {
  ProjectDetailController(this._repository, {String? id}) : projectId = id ?? Get.parameters['id'] ?? '';
  final ProjectRepository _repository;
  final String projectId;

  final project = Rx<ViewState<ProjectModel>>(const InitialState());
  final milestones = Rx<ViewState<List<MilestoneModel>>>(const InitialState());
  final List<StreamSubscription<dynamic>> _subs = [];

  @override
  void onInit() {
    super.onInit();
    load();
  }

  Failure _f(Object e) =>
      e is AppException ? Failure.fromException(e) : const Failure('Something went wrong.', retryable: true);

  void load() {
    for (final s in _subs) {
      s.cancel();
    }
    _subs.clear();
    project.value = const LoadingState();
    milestones.value = const LoadingState();
    try {
      _subs
        ..add(_repository.watch(projectId).listen(
              (p) => project.value = SuccessState(p),
              onError: (Object e) => project.value = ErrorState(_f(e)),
            ))
        ..add(_repository.watchMilestones(projectId).listen(
              (m) => milestones.value = listState(m),
              onError: (Object e) => milestones.value = ErrorState(_f(e)),
            ));
    } on AppException catch (e) {
      project.value = ErrorState(Failure.fromException(e));
    }
  }

  void askQuestion() {
    final p = project.value.dataOrNull;
    Get.toNamed<void>(
      Routes.createTicket,
      arguments: {'subject': 'About project: ${p?.title ?? ''}', 'category': 'project', 'relatedId': projectId},
    );
  }

  @override
  void onClose() {
    for (final s in _subs) {
      s.cancel();
    }
    super.onClose();
  }
}
