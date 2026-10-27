import '../../../core/errors/error_handler.dart';
import '../../../core/services/auth_session.dart';
import '../datasources/privacy_remote_datasource.dart';
import '../models/deletion_request_model.dart';

class PrivacyRepository {
  PrivacyRepository({required PrivacyRemoteDataSource remote, required AuthSession session})
      : _remote = remote,
        _session = session;

  final PrivacyRemoteDataSource _remote;
  final AuthSession _session;

  /// Not retried automatically: deletion is not something to repeat blindly.
  Future<void> deleteAccount(DeletionRequest request) async {
    _session.requireUid();
    return guard(() => _remote.deleteAccount(request), context: 'deleteAccount');
  }
}
