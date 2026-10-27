// End-to-end flows against the Firebase Emulator Suite.
//
// 1. cd firebase && echo "ENFORCE_APP_CHECK=false" > functions/.env.local
//    firebase emulators:start --project demo-busiserve
// 2. Configure the dev flavor with flutterfire (see README).
// 3. flutter test integration_test \
//      --dart-define-from-file=env/dev.json --dart-define=USE_FIREBASE_EMULATOR=true
import 'package:busiserve_app/bootstrap.dart';
import 'package:busiserve_app/core/config/app_env.dart';
import 'package:busiserve_app/core/config/firebase/firebase_options_dev.dart';
import 'package:busiserve_app/core/config/flavor_config.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  final config = FlavorConfig(
    flavor: AppFlavor.dev,
    appTitle: 'Busiserve Test',
    firebaseOptions: () => DefaultFirebaseOptions.currentPlatform,
  );

  Future<void> start(WidgetTester tester) async {
    await bootstrap(config);
    await tester.pumpAndSettle(const Duration(seconds: 3));
    if (find.text('Skip').evaluate().isNotEmpty) {
      await tester.tap(find.text('Skip'));
      await tester.pumpAndSettle();
    }
  }

  testWidgets('guest submits an enquiry', (tester) async {
    expect(AppEnv.useFirebaseEmulator, isTrue, reason: 'Run against the emulator only.');
    await start(tester);
    await tester.tap(find.text('Get a free consultation'));
    await tester.pumpAndSettle();

    await tester.enterText(find.widgetWithText(TextFormField, 'Full name'), 'Integration Tester');
    await tester.enterText(find.widgetWithText(TextFormField, 'Work email'), 'tester@example.com');
    await tester.tap(find.text('Subject'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('General Inquiry').last);
    await tester.pumpAndSettle();
    await tester.enterText(find.widgetWithText(TextFormField, 'Message'), 'Integration test enquiry message.');
    await tester.ensureVisible(find.text('Send message'));
    await tester.tap(find.text('Send message'));
    await tester.pumpAndSettle(const Duration(seconds: 5));

    expect(find.text('Message sent'), findsOneWidget);
  });

  testWidgets('register, sign out and sign in again', (tester) async {
    expect(AppEnv.useFirebaseEmulator, isTrue);
    await start(tester);
    final email = 'user${DateTime.now().millisecondsSinceEpoch}@example.com';

    await tester.tap(find.text('Account'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Create account').first);
    await tester.pumpAndSettle();
    await tester.enterText(find.widgetWithText(TextFormField, 'Full name'), 'Test User');
    await tester.enterText(find.widgetWithText(TextFormField, 'Email'), email);
    await tester.enterText(find.widgetWithText(TextFormField, 'Password'), 'secure1234');
    await tester.enterText(find.widgetWithText(TextFormField, 'Confirm password'), 'secure1234');
    await tester.tap(find.byType(Checkbox));
    await tester.ensureVisible(find.text('Create account').last);
    await tester.tap(find.text('Create account').last);
    await tester.pumpAndSettle(const Duration(seconds: 5));
    expect(find.text('Your work'), findsOneWidget);

    await tester.scrollUntilVisible(find.text('Sign out'), 300);
    await tester.tap(find.text('Sign out'));
    await tester.pumpAndSettle(const Duration(seconds: 3));
    await tester.tap(find.text('Sign in').first);
    await tester.pumpAndSettle();
    await tester.enterText(find.widgetWithText(TextFormField, 'Email'), email);
    await tester.enterText(find.widgetWithText(TextFormField, 'Password'), 'secure1234');
    await tester.tap(find.text('Sign in').last);
    await tester.pumpAndSettle(const Duration(seconds: 5));
    expect(find.text('Your work'), findsOneWidget);
  });
}
