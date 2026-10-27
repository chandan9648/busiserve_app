import '../../../core/errors/app_exception.dart';
import '../../../core/errors/error_handler.dart';
import '../../../core/services/auth_session.dart';
import '../datasources/auth_remote_datasource.dart';

/// Called before sign-out so the device token can be removed while the user
/// can still write their own documents.
typedef BeforeSignOut = Future<void> Function();

class AuthRepository {
  AuthRepository({required AuthRemoteDataSource remote, required AuthSession session, this.beforeSignOut})
      : _remote = remote,
        _session = session;

  final AuthRemoteDataSource _remote;
  final AuthSession _session;
  final BeforeSignOut? beforeSignOut;

  void _ensureAvailable() {
    if (!_session.isAvailable) {
      throw const ConfigurationException(
        'Accounts are not available yet. You can still browse and contact us.',
      );
    }
  }

  Future<void> signIn(String email, String password) async {
    _ensureAvailable();
    return guard(() => _remote.signIn(email, password), context: 'signIn');
  }

  Future<void> register({required String name, required String email, required String password, String? phone}) async {
    _ensureAvailable();
    return guard(
      () => _remote.register(name: name, email: email, password: password, phone: phone),
      context: 'register',
    );
  }

  Future<void> sendPasswordReset(String email) async {
    _ensureAvailable();
    return guard(() => _remote.sendPasswordReset(email), context: 'passwordReset');
  }

  Future<void> reauthenticate(String password) async {
    _ensureAvailable();
    return guard(() => _remote.reauthenticate(password), context: 'reauthenticate');
  }

  Future<void> signOut() async {
    if (!_session.isAvailable) return;
    try {
      await beforeSignOut?.call();
    } catch (_) {
      // Never block sign-out on token cleanup.
    }
    return guard(_remote.signOut, context: 'signOut');
  }
}
