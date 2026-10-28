import '../../../core/errors/app_exception.dart';
import '../../../core/errors/error_handler.dart';
import '../../../core/services/auth_session.dart';
import '../datasources/support_remote_datasource.dart';
import '../models/ticket_model.dart';

class SupportRepository {
  SupportRepository({required SupportRemoteDataSource remote, required AuthSession session})
      : _remote = remote,
        _session = session;

  final SupportRemoteDataSource _remote;
  final AuthSession _session;

  String newTicketId() => _remote.newTicketId();
  String newMessageId(String ticketId) => _remote.newMessageId(ticketId);

  String get _authorName => (_session.displayName?.trim().isNotEmpty ?? false) ? _session.displayName!.trim() : 'Customer';

  Stream<List<TicketModel>> watchMine() =>
      guardStream(_remote.watchForCustomer(_session.requireUid()), context: 'watch tickets');

  Stream<TicketModel> watch(String id) {
    _session.requireUid();
    return guardStream(
      _remote.watchById(id).map((t) => t ?? (throw const NotFoundException('This ticket is no longer available.'))),
      context: 'watch ticket',
    );
  }

  Stream<List<TicketMessage>> watchMessages(String ticketId) {
    _session.requireUid();
    return guardStream(_remote.watchMessages(ticketId), context: 'watch messages');
  }

  Future<void> create(NewTicket ticket) async {
    final uid = _session.requireUid();
    return guard(
      () async {
        await _requireVerified();
        return _remote.createTicket(uid, _authorName, ticket);
      },
      context: 'create ticket',
    );
  }

  Future<void> send({required String ticketId, required String messageId, required String text}) async {
    final uid = _session.requireUid();
    return guard(
      () async {
        await _requireVerified();
        return _remote.sendMessage(
          uid: uid,
          authorName: _authorName,
          ticketId: ticketId,
          messageId: messageId,
          text: text,
        );
      },
      context: 'send message',
    );
  }

  Future<void> _requireVerified() async {
    // Cheap after the first success: no reload once the token says verified.
    if (!await _session.refreshEmailVerified()) throw const EmailNotVerifiedException();
  }
}
