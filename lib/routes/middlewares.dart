import 'package:flutter/widgets.dart';
import 'package:get/get.dart';

import '../core/services/auth_session.dart';
import 'app_routes.dart';

/// Sends signed-out users to sign in, then back to where they were going.
class AuthMiddleware extends GetMiddleware {
  AuthMiddleware({super.priority = 1});

  @override
  RouteSettings? redirect(String? route) {
    final session = Get.find<AuthSession>();
    if (session.isLoggedIn) return null;
    return RouteSettings(name: Routes.login, arguments: {'redirect': route});
  }
}
