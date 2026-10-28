import 'dart:async';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:get/get.dart';

import '../config/flavor_config.dart';
import '../errors/app_exception.dart';

/// Read-only view of who is signed in. Controllers, middleware and
/// repositories depend on this interface so tests can supply a fake.
abstract class AuthSession {
  /// Observable uid; null when signed out.
  RxnString get currentUid;
  bool get isLoggedIn;
  String? get uid;
  String? get email;
  String? get displayName;
  bool get isEmailVerified;

  /// Reloads the user and, once verified, refreshes the ID token so the
  /// security rules see `email_verified`. Returns whether it is verified.
  Future<bool> refreshEmailVerified();

  Future<void> sendEmailVerification();

  /// False when Firebase is not configured for this build.
  bool get isAvailable;

  /// Returns the uid or throws [AuthenticationException].
  String requireUid();
}

/// App-lifetime Firebase Auth listener.
class AuthService extends GetxService implements AuthSession {
  AuthService({FirebaseAuth? auth}) : _auth = auth;

  FirebaseAuth? _auth;
  StreamSubscription<User?>? _subscription;

  @override
  final RxnString currentUid = RxnString();

  @override
  bool get isAvailable => FirebaseStatus.isReady;

  FirebaseAuth get auth {
    if (!isAvailable) throw const ConfigurationException();
    return _auth ??= FirebaseAuth.instance;
  }

  User? get user => isAvailable ? auth.currentUser : null;

  @override
  void onInit() {
    super.onInit();
    if (!isAvailable) return;
    currentUid.value = auth.currentUser?.uid;
    _subscription = auth.userChanges().listen((u) => currentUid.value = u?.uid);
  }

  @override
  void onClose() {
    _subscription?.cancel();
    super.onClose();
  }

  @override
  bool get isLoggedIn => currentUid.value != null;
  @override
  String? get uid => currentUid.value;
  @override
  String? get email => user?.email;
  @override
  String? get displayName => user?.displayName;
  @override
  bool get isEmailVerified => user?.emailVerified ?? false;

  @override
  Future<bool> refreshEmailVerified() async {
    var u = user;
    if (u == null) return false;
    if (!u.emailVerified) {
      await u.reload();
      u = auth.currentUser;
      if (u == null || !u.emailVerified) return false;
    }
    // The cached token may predate verification; rules read the token.
    final claims = (await u.getIdTokenResult()).claims;
    if (claims?['email_verified'] != true) await u.getIdToken(true);
    return true;
  }

  @override
  Future<void> sendEmailVerification() async {
    final u = user;
    if (u == null) throw const AuthenticationException('Sign in to continue.', code: 'unauthenticated');
    await u.sendEmailVerification();
  }

  @override
  String requireUid() {
    final id = uid;
    if (id == null) {
      throw const AuthenticationException('Sign in to continue.', code: 'unauthenticated');
    }
    return id;
  }
}
