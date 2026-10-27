# Busiserve — official mobile app

Flutter + GetX app for **Busiserve Infotech Solution** (https://www.busiserve.in), with a Firebase backend
(Auth, Firestore, Cloud Functions, FCM, Storage, App Check, Crashlytics).

Public visitors can browse services, case studies and contact details and send an enquiry without an
account. Signed-in customers can also track enquiries and quotations, follow project milestones, receive
notifications, raise support requests and delete their account.

> **Build status — read this first.** This code was written without access to a Flutter SDK or the
> network, so `dart format`, `flutter analyze`, `flutter test` and `npm run build` have **not** been run
> yet. Run the commands in [Verify](#verify) before anything else and fix whatever they report. Package
> versions are a mutually compatible set from 2025; `flutter pub outdated` will show newer ones.

---

## 1. First-time setup

Requirements: Flutter 3.27+ (Dart 3.6+), Xcode 15+, Android Studio, Node 20, Firebase CLI,
FlutterFire CLI (`dart pub global activate flutterfire_cli`).

The repository contains `lib/`, `test/`, `assets/` and `firebase/`, but not the generated platform
folders. Create them once (this does not touch `lib/`):

```bash
flutter create . --org in.busiserve --project-name busiserve_app --platforms android,ios
flutter pub get
dart run flutter_launcher_icons
dart run flutter_native_splash:create
```

### Android flavors

In `android/app/build.gradle(.kts)` set `applicationId "in.busiserve.app"`, `minSdk 23`, and add:

```groovy
flavorDimensions "env"
productFlavors {
    dev     { dimension "env"; applicationIdSuffix ".dev";     resValue "string", "app_name", "Busiserve Dev" }
    staging { dimension "env"; applicationIdSuffix ".staging"; resValue "string", "app_name", "Busiserve Staging" }
    prod    { dimension "env";                                  resValue "string", "app_name", "Busiserve" }
}
```

Use `@string/app_name` as the label in `AndroidManifest.xml`, and add inside `<manifest>` so phone,
email and web links open on Android 11+:

```xml
<queries>
  <intent><action android:name="android.intent.action.DIAL" /><data android:scheme="tel" /></intent>
  <intent><action android:name="android.intent.action.SENDTO" /><data android:scheme="mailto" /></intent>
  <intent><action android:name="android.intent.action.VIEW" /><data android:scheme="https" /></intent>
</queries>
```

### iOS flavors

In Xcode create schemes `dev`, `staging`, `prod` with matching build configurations
(`Debug-dev`, `Release-dev`, ...). Set bundle ids `in.busiserve.app.dev`, `in.busiserve.app.staging`,
`in.busiserve.app`. Enable **Push Notifications** and **Background Modes → Remote notifications**, and
upload an APNs key in Firebase Console → Project settings → Cloud Messaging.

---

## 2. Firebase setup (once per environment)

Create three projects, for example `busiserve-dev`, `busiserve-staging`, `busiserve-prod`. In each:
enable Email/Password sign-in, create Firestore (region `asia-south1`), enable Storage, register
App Check (Play Integrity / App Attest), and upgrade to Blaze (required for Functions).

Generate the options file for each flavor. These replace the placeholders in
`lib/core/config/firebase/`:

```bash
flutterfire configure --project=busiserve-dev \
  --out=lib/core/config/firebase/firebase_options_dev.dart \
  --ios-bundle-id=in.busiserve.app.dev --android-package-name=in.busiserve.app.dev
# repeat for staging (".staging") and prod (no suffix)
```

Until this is done the app still starts: public screens work and account features show
"not available yet". That is intentional, not a bug.

Deploy rules, indexes and functions:

```bash
cd firebase
cp .firebaserc.example .firebaserc          # edit project ids
cd functions && npm install && npm run build && npm test && cd ..
firebase use dev
firebase deploy --only firestore:rules,firestore:indexes,storage,functions
```

Grant the first admin from a trusted machine (never from the app):

```bash
cd firebase/functions
export GOOGLE_APPLICATION_CREDENTIALS=/secure/path/service-account.json
npx ts-node scripts/grant-admin.ts owner@example.com
```

Admins can then promote staff with the `setUserRole` callable.

---

## 3. Run

```bash
flutter run --flavor dev     -t lib/main_dev.dart     --dart-define-from-file=env/dev.json
flutter run --flavor staging -t lib/main_staging.dart --dart-define-from-file=env/staging.json
```

For production, copy `env/prod.example.json` to `env/prod.json` (git-ignored).

### Local emulators

```bash
cd firebase && echo "ENFORCE_APP_CHECK=false" > functions/.env.local
firebase emulators:start
# another terminal
flutter run --flavor dev -t lib/main_dev.dart --dart-define-from-file=env/dev.json \
  --dart-define=USE_FIREBASE_EMULATOR=true
```

---

## 4. Verify

```bash
dart format .
flutter analyze
flutter test
cd firebase/functions && npm run build && npm test
# with emulators running:
flutter test integration_test --flavor dev \
  --dart-define-from-file=env/dev.json --dart-define=USE_FIREBASE_EMULATOR=true
```

What the tests cover:

| Area | File |
|---|---|
| Validators (email, Indian/international phone, name, password, lengths) | `test/core/validators_test.dart` |
| Firebase, Functions and Dio error mapping; no raw server text leaks | `test/core/error_mapping_test.dart` |
| Currency/date formatting, log redaction, idempotency keys, notification route allow-list | `test/core/formatters_and_misc_test.dart` |
| JSON/Firestore parsing for every model; catalogue matches website | `test/modules/models_test.dart` |
| Repository fallback and caching; controller state transitions | `test/modules/service_repository_and_controller_test.dart` |
| Enquiry repository config and error handling | `test/modules/enquiry_repository_test.dart` |
| Loading / empty / success / error widgets | `test/widgets/state_view_test.dart` |
| Enquiry form validation, double-submit prevention, safe retry with same key | `test/widgets/enquiry_form_test.dart` |
| Auth middleware and that every customer-data route is protected | `test/routes/auth_middleware_test.dart` |
| Guest enquiry and register/sign-out/sign-in against emulators | `integration_test/app_flow_test.dart` |
| Server-side enquiry validation | `firebase/functions/src/test/validation.test.ts` |

Not yet covered: Firestore security-rules unit tests (`@firebase/rules-unit-testing`). Add these
before production; the rules are the real security boundary.

---

## 5. Architecture

```
lib/
  main_dev|staging|prod.dart  flavor entry points -> bootstrap.dart
  app.dart                    GetMaterialApp, themes
  bindings/initial_binding.dart  app-lifetime services (GetxService)
  routes/                     Routes, AppPages (GetPage table), AuthMiddleware
  core/
    config/      AppEnv (dart-define), FlavorConfig, firebase options per flavor
    constants/   CompanyInfo (verified website data), limits, assets
    errors/      AppException hierarchy, Failure, ErrorHandler, Firebase/Dio mappers, guard()
    network/     DioClient (only registered when API_BASE_URL is set)
    services/    AuthService (AuthSession), Prefs, SecureStorage, PushNotificationService
    state/       sealed ViewState<T>: Initial, Loading, Success, Empty, Error
    theme/       colours sampled from the logo, spacing, BrandTokens, ThemeData (light + dark)
    utils/       validators, parsing, formatters, logger (redacting), launcher, idempotency
    widgets/     AppButton, AppTextField, StateView, hexagon motif, cards, notices
  modules/<feature>/
    bindings/ controllers/ models/ datasources/ repositories/ views/ widgets/
```

Features: `splash`, `onboarding`, `home` (shell + home tab), `services`, `portfolio`, `enquiry`, `auth`,
`profile`, `quotations`, `projects`, `notifications`, `support`, `privacy`.

Conventions:

- **Feature-first.** A feature owns its models, data sources, repository, controllers and views. If
  another feature needs a model it imports it from the owner (e.g. `quotations` uses
  `enquiry/models/enquiry_model.dart`); models are never duplicated.
- **Layers.** View → Controller (GetxController, Rx state) → Repository (business rules, error mapping
  via `guard`) → DataSource (Firebase/HTTP only). Views never call Firebase.
- **Errors.** Data sources throw whatever the SDK throws; repositories convert to `AppException`;
  controllers turn that into `ErrorState(Failure)`. Only `Failure.message` reaches the UI. Retry is
  offered only for transient failures.
- **DI.** App-wide services in `InitialBinding`; feature dependencies in feature bindings with
  `lazyPut`. Nothing is `Get.put` from a `build` method. Controllers dispose text controllers, focus
  nodes, workers and stream subscriptions in `onClose`.
- **Auth boundary.** `AuthMiddleware` hides screens; Firestore/Storage rules and Cloud Functions
  enforce access. Staff/admin come from Auth custom claims only.

---

## 6. Data model (Firestore)

| Path | Written by | Read by |
|---|---|---|
| `services/{slug}`, `caseStudies/{slug}` (`published`, `order`, …) | staff | everyone (published only) |
| `users/{uid}` (`name`, `email`, `phone`, `company`) | owner (limited fields) | owner, staff |
| `users/{uid}/devices/{fcmToken}` | owner | owner |
| `users/{uid}/notifications/{id}` | functions | owner (may only set `read`) |
| `enquiries/{idempotencyKey}` | `createEnquiry` function | owner, staff |
| `quotations/{id}` (`customerId`, `items[]`, `total`, `status`, `validUntil`) | staff | owner, staff |
| `projects/{id}` + `milestones/{id}` | staff | owner, staff |
| `tickets/{id}` + `messages/{id}` | owner (validated), staff | owner, staff |
| `projects/{id}/files/*` (Storage) | staff | owner, staff |

**Content.** Without Firestore content the app shows the services and case studies bundled in
`*_local_datasource.dart`, copied from busiserve.in. To edit content without an app release, add
`published: true` documents to `services` / `caseStudies`; fields `description`, `highlights`,
`challenge`, `solution`, `results`, `technologies` are optional and render when present.

**Duplicate protection.** The enquiry form generates one UUID per form session and keeps it across
failed attempts; `createEnquiry` uses it as the document id inside a transaction, so a retried request
returns the original enquiry. Support tickets use the same pattern with a pre-generated document id.

---

## 7. Release

1. Replace placeholder Firebase options for `prod`; deploy rules, indexes and functions to prod.
2. Android: create an upload keystore, `key.properties` (git-ignored), signing config; add the release
   SHA-256 to Firebase and Play Integrity.
   `flutter build appbundle --flavor prod -t lib/main_prod.dart --dart-define-from-file=env/prod.json --obfuscate --split-debug-info=build/symbols`
3. iOS: set signing team, push capability, App Attest.
   `flutter build ipa --flavor prod -t lib/main_prod.dart --dart-define-from-file=env/prod.json --obfuscate --split-debug-info=build/symbols`
4. Upload Crashlytics symbols (`firebase crashlytics:symbols:upload`).
5. Store listings: Play Data Safety and App Store privacy labels (name, email, phone, messages;
   crash data only with consent). Account deletion is available in-app (Account → Privacy and data);
   Google Play also needs a web URL for deletion requests.

---

## 8. Open items before production

- **Content approval.** Confirm the three case studies and their figures may appear in the app.
- **Backend of record.** busiserve.in links to a company CRM. If enquiries, quotations and projects
  should live there, replace the Firestore data sources for those features with REST data sources
  using `DioClient` once API contracts exist. No endpoints have been invented.
- **Staff tooling.** Staff currently manage quotations, projects, milestones and ticket replies in the
  Firebase console; an admin panel (or CRM sync) is the natural next step.
- **Guest enquiry linking.** Enquiries sent before creating an account are not linked to it.
  Linking by email should happen server-side only after email verification.
- **Ticket attachments** are not implemented yet (Storage rules for project files are in place).
- **Fonts.** `google_fonts` fetches Sora and Manrope at runtime; bundle the font files under
  `assets/fonts/` for offline first launch.
