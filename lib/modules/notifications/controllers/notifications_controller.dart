import 'dart:async';

import 'package:get/get.dart';

import '../../../core/errors/app_exception.dart';
import '../../../core/errors/failure.dart';
import '../../../core/services/push_notification_service.dart';
import '../../../core/state/view_state.dart';
import '../models/notification_model.dart';
import '../repositories/notification_repository.dart';

class NotificationsController extends GetxController {
  NotificationsController(this._repository);
  final NotificationRepository _repository;

  final state = Rx<ViewState<List<NotificationModel>>>(const InitialState());
  final isMarkingAll = false.obs;
  StreamSubscription<List<NotificationModel>>? _sub;

  int get unreadCount => state.value.dataOrNull?.where((n) => !n.read).length ?? 0;

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

  Future<void> open(NotificationModel n) async {
    if (!n.read) {
      try {
        await _repository.markRead(n.id);
      } on AppException {
        // Opening still works; the dot clears on next sync.
      }
    }
    final route = n.route;
    if (route != null && PushNotificationService.isAllowedRoute(route)) {
      await Get.toNamed<void>(route);
    }
  }

  Future<void> markAllRead() async {
    if (isMarkingAll.value) return;
    final ids = state.value.dataOrNull?.where((n) => !n.read).map((n) => n.id).toList() ?? const [];
    isMarkingAll.value = true;
    try {
      await _repository.markAllRead(ids);
    } on AppException catch (e) {
      Get.snackbar('Could not update', e.message);
    } finally {
      isMarkingAll.value = false;
    }
  }

  @override
  void onClose() {
    _sub?.cancel();
    super.onClose();
  }
}
