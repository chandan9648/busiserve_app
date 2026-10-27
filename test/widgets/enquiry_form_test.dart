import 'package:busiserve_app/core/errors/app_exception.dart';
import 'package:busiserve_app/core/services/auth_session.dart';
import 'package:busiserve_app/modules/enquiry/controllers/enquiry_controller.dart';
import 'package:busiserve_app/modules/enquiry/repositories/enquiry_repository.dart';
import 'package:busiserve_app/modules/enquiry/views/enquiry_form_view.dart';
import 'package:busiserve_app/routes/app_routes.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';

import '../helpers/fakes.dart';

void main() {
  late FakeEnquiryRemote remote;

  Future<void> pumpForm(WidgetTester tester, {FakeEnquiryRemote? fake}) async {
    tester.view.physicalSize = const Size(1080, 4000);
    tester.view.devicePixelRatio = 2;
    addTearDown(tester.view.reset);

    Get.testMode = true;
    remote = fake ?? FakeEnquiryRemote();
    final session = FakeAuthSession();
    Get.put<AuthSession>(session);
    Get.put(EnquiryController(EnquiryRepository(remote: remote, session: session), session,
        arguments: const {'subjectId': 'app-development'}));

    await tester.pumpWidget(
      GetMaterialApp(
        initialRoute: Routes.enquiry,
        getPages: [
          GetPage(name: Routes.enquiry, page: () => const EnquiryFormView()),
          GetPage(name: Routes.enquirySuccess, page: () => const Scaffold(body: Text('SUCCESS'))),
        ],
      ),
    );
    await tester.pumpAndSettle();
  }

  Future<void> fillValid(WidgetTester tester) async {
    await tester.enterText(find.widgetWithText(TextFormField, 'Full name'), 'Asha Verma');
    await tester.enterText(find.widgetWithText(TextFormField, 'Work email'), 'asha@example.com');
    await tester.enterText(find.widgetWithText(TextFormField, 'Message'), 'We need a clinic booking app.');
  }

  tearDown(Get.reset);

  testWidgets('shows inline errors and does not submit an invalid form', (tester) async {
    await pumpForm(tester);
    await tester.tap(find.text('Send message'));
    await tester.pump();
    expect(find.text('Name is required.'), findsOneWidget);
    expect(find.text('Email is required.'), findsOneWidget);
    expect(find.text('Message is required.'), findsOneWidget);
    expect(remote.requests, isEmpty);
  });

  testWidgets('pre-selects the subject passed from a service', (tester) async {
    await pumpForm(tester);
    expect(find.text('Mobile App Development'), findsWidgets);
  });

  testWidgets('double tap submits once and navigates to success', (tester) async {
    await pumpForm(tester, fake: FakeEnquiryRemote(delay: const Duration(milliseconds: 300)));
    await fillValid(tester);
    await tester.tap(find.text('Send message'));
    await tester.pump(const Duration(milliseconds: 10));
    // Second tap while the request is in flight: the button is disabled.
    await tester.tap(find.text('Send message'), warnIfMissed: false);
    await tester.pumpAndSettle();
    expect(remote.requests.length, 1);
    expect(find.text('SUCCESS'), findsOneWidget);
  });

  testWidgets('retry after a failure reuses the same idempotency key and keeps input', (tester) async {
    await pumpForm(tester, fake: FakeEnquiryRemote(failuresBeforeSuccess: 1, failure: const NetworkException()));
    await fillValid(tester);
    await tester.tap(find.text('Send message'));
    await tester.pumpAndSettle();
    expect(find.textContaining('No internet connection'), findsOneWidget);
    expect(find.text('Asha Verma'), findsOneWidget);

    await tester.tap(find.text('Send message'));
    await tester.pumpAndSettle();
    expect(remote.requests.length, 2);
    expect(remote.requests[0].idempotencyKey, remote.requests[1].idempotencyKey);
    expect(find.text('SUCCESS'), findsOneWidget);
  });
}
