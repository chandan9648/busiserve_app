import '../../../core/errors/error_handler.dart';
import '../../../core/services/auth_session.dart';
import '../datasources/notification_remote_datasource.dart';
import '../models/notification_model.dart';

class NotificationRepository {
  NotificationRepository({required NotificationRemoteDataSource remote, required AuthSession session})
      : _remote = remote,
        _session = session;

  final NotificationRemoteDataSource _remote;
  final AuthSession _session;

  Stream<List<NotificationModel>> watchMine() =>
      guardStream(_remote.watch(_session.requireUid()), context: 'watch notifications');

  Future<void> markRead(String id) =>
      guard(() => _remote.markRead(_session.requireUid(), id), context: 'mark notification read');

  Future<void> markAllRead(List<String> ids) async {
    if (ids.isEmpty) return;
    return guard(() => _remote.markAllRead(_session.requireUid(), ids), context: 'mark all read');
  }
}
