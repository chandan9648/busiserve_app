import 'dart:async';

import 'package:flutter/widgets.dart';
import 'package:get/get.dart';

import '../../../core/constants/app_limits.dart';
import '../../../core/errors/app_exception.dart';
import '../../../core/errors/failure.dart';
import '../../../core/state/view_state.dart';
import '../models/ticket_model.dart';
import '../repositories/support_repository.dart';

class TicketDetailController extends GetxController {
  TicketDetailController(this._repository, {String? id}) : ticketId = id ?? Get.parameters['id'] ?? '';
  final SupportRepository _repository;
  final String ticketId;

  final ticket = Rx<ViewState<TicketModel>>(const InitialState());
  final messages = Rx<ViewState<List<TicketMessage>>>(const InitialState());
  final replyCtrl = TextEditingController();
  final scrollCtrl = ScrollController();
  final canSend = false.obs;
  final isSending = false.obs;
  final List<StreamSubscription<dynamic>> _subs = [];

  /// Kept for a failed send so retrying the same text reuses the same id.
  String? _pendingMessageId;
  String? _pendingText;

  @override
  void onInit() {
    super.onInit();
    replyCtrl.addListener(_onTextChanged);
    load();
  }

  void _onTextChanged() {
    final t = replyCtrl.text.trim();
    canSend.value = t.isNotEmpty && t.length <= AppLimits.chatMessageMax;
  }

  Failure _f(Object e) =>
      e is AppException ? Failure.fromException(e) : const Failure('Something went wrong.', retryable: true);

  void load() {
    for (final s in _subs) {
      s.cancel();
    }
    _subs.clear();
    ticket.value = const LoadingState();
    messages.value = const LoadingState();
    try {
      _subs
        ..add(_repository.watch(ticketId).listen(
              (t) => ticket.value = SuccessState(t),
              onError: (Object e) => ticket.value = ErrorState(_f(e)),
            ))
        ..add(_repository.watchMessages(ticketId).listen(
              (m) {
                messages.value = listState(m);
                _scrollToEnd();
              },
              onError: (Object e) => messages.value = ErrorState(_f(e)),
            ));
    } on AppException catch (e) {
      ticket.value = ErrorState(Failure.fromException(e));
    }
  }

  Future<void> send() async {
    final text = replyCtrl.text.trim();
    if (isSending.value || text.isEmpty || text.length > AppLimits.chatMessageMax) return;
    if (_pendingText != text) {
      _pendingText = text;
      _pendingMessageId = _repository.newMessageId(ticketId);
    }
    isSending.value = true;
    try {
      await _repository.send(ticketId: ticketId, messageId: _pendingMessageId!, text: text);
      replyCtrl.clear();
      _pendingText = null;
      _pendingMessageId = null;
    } on AppException catch (e) {
      Get.snackbar('Message not sent', e.message);
    } finally {
      isSending.value = false;
    }
  }

  void _scrollToEnd() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (scrollCtrl.hasClients) {
        scrollCtrl.animateTo(
          scrollCtrl.position.maxScrollExtent,
          duration: const Duration(milliseconds: 250),
          curve: Curves.easeOut,
        );
      }
    });
  }

  @override
  void onClose() {
    for (final s in _subs) {
      s.cancel();
    }
    replyCtrl.removeListener(_onTextChanged);
    replyCtrl.dispose();
    scrollCtrl.dispose();
    super.onClose();
  }
}
