import 'package:get/get.dart';
import 'package:url_launcher/url_launcher.dart';

import '../constants/company_info.dart';
import 'app_logger.dart';

/// Opens phone, email, map and web links with a visible fallback message.
class Launcher {
  Launcher._();

  static Future<void> call() => _open(Uri(scheme: 'tel', path: CompanyInfo.phoneDial));

  static Future<void> email({String? subject}) => _open(
        Uri(
          scheme: 'mailto',
          path: CompanyInfo.email,
          query: subject == null ? null : 'subject=${Uri.encodeComponent(subject)}',
        ),
      );

  static Future<void> web(String url) => _open(Uri.parse(url));

  static Future<void> _open(Uri uri) async {
    try {
      final ok = await launchUrl(uri, mode: LaunchMode.externalApplication);
      if (!ok) _fail();
    } catch (e, st) {
      AppLogger.error('launch failed for scheme ${uri.scheme}', error: e, stackTrace: st);
      _fail();
    }
  }

  static void _fail() {
    Get.snackbar(
      'Could not open link',
      'Contact us at ${CompanyInfo.email} or ${CompanyInfo.phoneDisplay}.',
      snackPosition: SnackPosition.BOTTOM,
    );
  }
}
