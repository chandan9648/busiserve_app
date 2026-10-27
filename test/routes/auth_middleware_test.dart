import 'package:busiserve_app/core/services/auth_session.dart';
import 'package:busiserve_app/routes/app_pages.dart';
import 'package:busiserve_app/routes/app_routes.dart';
import 'package:busiserve_app/routes/middlewares.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';

import '../helpers/fakes.dart';

void main() {
  setUp(() => Get.testMode = true);
  tearDown(Get.reset);

  test('redirects signed-out users to login with the original route', () {
    Get.put<AuthSession>(FakeAuthSession());
    final settings = AuthMiddleware().redirect('/projects/p1');
    expect(settings?.name, Routes.login);
    expect((settings?.arguments as Map)['redirect'], '/projects/p1');
  });

  test('lets signed-in users through', () {
    Get.put<AuthSession>(FakeAuthSession(uid: 'u1'));
    expect(AuthMiddleware().redirect('/projects'), isNull);
  });

  test('every customer-data route is protected in the route table', () {
    for (final page in AppPages.routes) {
      final protected = page.middlewares?.whereType<AuthMiddleware>().isNotEmpty ?? false;
      expect(protected, AppPages.protectedRouteNames.contains(page.name), reason: page.name);
    }
  });

  testWidgets('navigating to a protected page shows sign-in', (tester) async {
    Get.put<AuthSession>(FakeAuthSession());
    await tester.pumpWidget(
      GetMaterialApp(
        initialRoute: '/',
        getPages: [
          GetPage(
            name: '/',
            page: () => Scaffold(
              body: TextButton(onPressed: () => Get.toNamed<void>(Routes.projects), child: const Text('Go')),
            ),
          ),
          GetPage(name: Routes.projects, page: () => const Text('PROJECTS'), middlewares: [AuthMiddleware()]),
          GetPage(name: Routes.login, page: () => const Text('LOGIN')),
        ],
      ),
    );
    await tester.tap(find.text('Go'));
    await tester.pumpAndSettle();
    expect(find.text('LOGIN'), findsOneWidget);
    expect(find.text('PROJECTS'), findsNothing);
  });
}
