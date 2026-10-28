import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'bindings/initial_binding.dart';
import 'core/config/flavor_config.dart';
import 'core/services/prefs_service.dart';
import 'core/theme/app_theme.dart';
import 'core/widgets/offline_gate.dart';
import 'routes/app_pages.dart';
import 'routes/app_routes.dart';

class BusiserveApp extends StatelessWidget {
  const BusiserveApp({super.key, required this.config});
  final FlavorConfig config;

  @override
  Widget build(BuildContext context) {
    final app = GetMaterialApp(
      title: config.appTitle,
      debugShowCheckedModeBanner: false,
      initialBinding: InitialBinding(),
      initialRoute: Routes.splash,
      getPages: AppPages.routes,
      theme: AppTheme.light,
      darkTheme: AppTheme.dark,
      themeMode: PrefsService().themeMode,
      defaultTransition: Transition.native,
      // Keep text scaling accessible but prevent layouts from breaking at extremes.
      builder: (context, child) {
        final media = MediaQuery.of(context);
        return MediaQuery(
          data: media.copyWith(
            textScaler: media.textScaler.clamp(maxScaleFactor: 1.3),
          ),
          child: OfflineGate(child: child ?? const SizedBox.shrink()),
        );
      },
    );
    return app;
  }
}
