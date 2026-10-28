import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:flutter/foundation.dart';
import 'package:get/get.dart';

import '../../../core/config/flavor_config.dart';
import '../../../core/constants/company_info.dart';
import '../../../core/services/auth_session.dart';
import '../../../core/services/prefs_service.dart';
import '../../../core/services/push_notification_service.dart';
import '../../../core/utils/app_logger.dart';
import '../../../core/utils/launcher.dart';
import '../../../routes/app_routes.dart';

class PrivacyController extends GetxController {
  PrivacyController({required PrefsService prefs, required this.session, PushNotificationService? push})
      : _prefs = prefs,
        _push = push;

  final PrefsService _prefs;
  final PushNotificationService? _push;
  final AuthSession session;

  final crashReporting = false.obs;
  final pushEnabled = true.obs;

  bool get crashReportingSupported => FirebaseStatus.isReady && !kIsWeb;

  @override
  void onInit() {
    super.onInit();
    crashReporting.value = _prefs.crashReportingConsent ?? false;
    pushEnabled.value = _prefs.pushEnabled;
  }

  Future<void> setCrashReporting(bool value) async {
    crashReporting.value = value;
    await _prefs.setCrashReportingConsent(value);
    if (crashReportingSupported) {
      await FirebaseCrashlytics.instance.setCrashlyticsCollectionEnabled(value);
      AppLogger.crashlyticsEnabled = value;
    }
  }

  Future<void> setPushEnabled(bool value) async {
    pushEnabled.value = value;
    await _prefs.setPushEnabled(value);
    final uid = session.uid;
    if (!value) {
      await _push?.unregister();
      return;
    }
    await _push?.subscribeToBroadcasts();
    if (uid != null) await _push?.register(uid);
  }

  void openPrivacyPolicy() => Launcher.web(CompanyInfo.privacyUrl);
  void openTerms() => Launcher.web(CompanyInfo.termsUrl);
  void openRefundPolicy() => Launcher.web(CompanyInfo.refundUrl);
  void openDeleteAccount() => Get.toNamed<void>(Routes.deleteAccount);
}
