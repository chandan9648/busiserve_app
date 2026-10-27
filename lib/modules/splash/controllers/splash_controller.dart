import 'dart:async';

import 'package:get/get.dart';

import '../../../core/services/prefs_service.dart';
import '../../../routes/app_routes.dart';

class SplashController extends GetxController {
  SplashController(this._prefs, {this.delay = const Duration(milliseconds: 1400)});
  final PrefsService _prefs;
  final Duration delay;
  Timer? _timer;

  @override
  void onReady() {
    super.onReady();
    _timer = Timer(delay, _next);
  }

  void _next() {
    Get.offAllNamed<void>(_prefs.onboardingDone ? Routes.main : Routes.onboarding);
  }

  @override
  void onClose() {
    _timer?.cancel();
    super.onClose();
  }
}
