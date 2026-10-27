import 'dart:async';

import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../core/errors/app_exception.dart';
import '../../../core/errors/failure.dart';
import '../../../core/services/auth_session.dart';
import '../../../core/services/prefs_service.dart';
import '../../../core/state/view_state.dart';
import '../../../routes/app_routes.dart';
import '../../auth/models/user_model.dart';
import '../../auth/repositories/auth_repository.dart';
import '../repositories/profile_repository.dart';

/// Backs the Account tab: signed-out call to action, or profile + menu.
class ProfileController extends GetxController {
  ProfileController({
    required ProfileRepository profileRepository,
    required AuthRepository authRepository,
    required this.session,
    required PrefsService prefs,
  })  : _profileRepository = profileRepository,
        _authRepository = authRepository,
        _prefs = prefs;

  final ProfileRepository _profileRepository;
  final AuthRepository _authRepository;
  final PrefsService _prefs;
  final AuthSession session;

  final profile = Rx<ViewState<UserModel>>(const InitialState());
  final themeMode = ThemeMode.system.obs;
  final isSigningOut = false.obs;

  StreamSubscription<UserModel>? _sub;
  Worker? _authWorker;

  @override
  void onInit() {
    super.onInit();
    themeMode.value = _prefs.themeMode;
    _authWorker = ever<String?>(session.currentUid, (_) => _listen());
    _listen();
  }

  void _listen() {
    _sub?.cancel();
    _sub = null;
    if (!session.isLoggedIn) {
      profile.value = const InitialState();
      return;
    }
    profile.value = const LoadingState();
    try {
      _sub = _profileRepository.watchMine().listen(
            (u) => profile.value = SuccessState(u),
            onError: (Object e) {
              if (e is AppException) profile.value = ErrorState(Failure.fromException(e));
            },
          );
    } on AppException catch (e) {
      profile.value = ErrorState(Failure.fromException(e));
    }
  }

  void retry() => _listen();

  void setThemeMode(ThemeMode mode) {
    themeMode.value = mode;
    _prefs.setThemeMode(mode);
    Get.changeThemeMode(mode);
  }

  void goToLogin() => Get.toNamed<void>(Routes.login);
  void goToRegister() => Get.toNamed<void>(Routes.register);
  void open(String route) => Get.toNamed<void>(route);

  Future<void> signOut() async {
    if (isSigningOut.value) return;
    isSigningOut.value = true;
    try {
      await _authRepository.signOut();
    } on AppException catch (e) {
      Get.snackbar('Could not sign out', e.message);
    } finally {
      isSigningOut.value = false;
    }
  }

  @override
  void onClose() {
    _sub?.cancel();
    _authWorker?.dispose();
    super.onClose();
  }
}
