import 'package:flutter/widgets.dart';
import 'package:get/get.dart';

import '../../../core/services/prefs_service.dart';
import '../../../routes/app_routes.dart';
import '../models/onboarding_page.dart';

class OnboardingController extends GetxController {
  OnboardingController(this._prefs);
  final PrefsService _prefs;

  final pageController = PageController();
  final page = 0.obs;
  final pages = OnboardingPage.all;

  bool get isLast => page.value == pages.length - 1;

  void onPageChanged(int i) => page.value = i;

  void next() {
    if (isLast) {
      finish();
    } else {
      pageController.nextPage(duration: const Duration(milliseconds: 320), curve: Curves.easeOutCubic);
    }
  }

  Future<void> finish() async {
    await _prefs.setOnboardingDone();
    await Get.offAllNamed<void>(Routes.main);
  }

  @override
  void onClose() {
    pageController.dispose();
    super.onClose();
  }
}
