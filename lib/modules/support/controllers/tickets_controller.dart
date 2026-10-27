import 'dart:async';

import 'package:get/get.dart';

import '../../../core/errors/app_exception.dart';
import '../../../core/errors/failure.dart';
import '../../../core/state/view_state.dart';
import '../../../routes/app_routes.dart';
import '../models/ticket_model.dart';
import '../repositories/support_repository.dart';

class TicketsController extends GetxController {
  TicketsController(this._repository);
  final SupportRepository _repository;

  final state = Rx<ViewState<List<TicketModel>>>(const InitialState());
  StreamSubscription<List<TicketModel>>? _sub;

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

  void open(TicketModel t) => Get.toNamed<void>(Routes.ticketPath(t.id));
  void create() => Get.toNamed<void>(Routes.createTicket);

  @override
  void onClose() {
    _sub?.cancel();
    super.onClose();
  }
}
