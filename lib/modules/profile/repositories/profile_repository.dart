import '../../../core/errors/error_handler.dart';
import '../../../core/services/auth_session.dart';
import '../../auth/models/user_model.dart';
import '../datasources/profile_remote_datasource.dart';

class ProfileRepository {
  ProfileRepository({required ProfileRemoteDataSource remote, required AuthSession session})
      : _remote = remote,
        _session = session;

  final ProfileRemoteDataSource _remote;
  final AuthSession _session;

  /// Falls back to Auth data when the profile document does not exist yet.
  Stream<UserModel> watchMine() {
    final uid = _session.requireUid();
    return guardStream(
      _remote.watch(uid).map(
            (p) => p ?? UserModel(uid: uid, name: _session.displayName ?? '', email: _session.email ?? ''),
          ),
      context: 'watch profile',
    );
  }

  Future<void> update({required String name, String? phone, String? company}) async {
    final uid = _session.requireUid();
    return guard(
      () => _remote.update(
        UserModel(uid: uid, name: name, email: _session.email ?? '', phone: phone, company: company),
      ),
      context: 'update profile',
    );
  }
}
