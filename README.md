# Busiserve — official mobile app

Flutter + GetX app for **Busiserve Infotech Solution** (https://www.busiserve.in), with a Firebase backend
(Auth, Firestore, App Check, Crashlytics) on the free Spark plan — no Cloud Functions.

Public visitors can browse services, case studies and contact details. Sending an enquiry needs an
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

## 2. Firebase setup

The production web flavor is configured to use the `busiserve-app` Firebase project.
Run it with `flutter run -d chrome -t lib/main_prod.dart --dart-define-from-file=env/prod.json`. Dev and staging remain
unconfigured. For Android and iOS production builds, run FlutterFire configuration with the
matching native app IDs and add the platform-specific options before building. Until then,
Firebase-dependent features are unavailable on those platforms; public screens remain browsable.

In the Firebase Console, enable Email/Password sign-in, create Firestore (region `asia-south1`),
and register App Check (reCAPTCHA v3 for web, Play Integrity / App Attest for native).

### Spark plan: no Cloud Functions

This project runs on the **free Spark plan**, so nothing in `firebase/functions/` is deployed.
Everything those functions used to do now happens in the client with the Firestore security
rules as the only enforcement point:

| Was | Now |
|---|---|
| `createEnquiry` validated and wrote the enquiry | The signed-in customer writes `enquiries/{idempotencyKey}` directly; `firestore.rules` validates every field |
| `deleteAccount` deleted the user and anonymised their records | The app clears the profile subcollections, deletes `users/{uid}`, then calls `User.delete()` |
| `setUserRole` set a `role` custom claim | `users/{uid}.role` is a Firestore field; only an admin may write it |
| `onQuotationCreated` / `onProjectUpdated` / `onTicketMessageCreated` sent notifications | Staff create `users/{uid}/notifications/{id}` by hand |

What this costs you, stated plainly:

- **Anonymous enquiries are gone.** Submitting now requires an account, because an
  unauthenticated write path would be an open door for bots.
- **No rate limiting.** The old 5-per-hour-per-email cap needed a server-side counter.
  App Check and the sign-in requirement are the remaining defences.
- **No push notifications at all.** Sending FCM needs a server key. The in-app
  notification list still works, but someone has to write the entries.
- **Deleted accounts leave records behind.** Enquiries, quotations, projects and tickets
  keep pointing at a uid that no longer exists; anonymising them needs the Admin SDK.
  Clear them from the console when you delete an account.
- **Firestore Storage is not set up.** The app does not use it, and new projects need
  Blaze for a default bucket anyway.

Deploy rules and indexes:

```bash
cd firebase
cp .firebaserc.example .firebaserc          # edit project ids
firebase use prod
firebase deploy --only firestore:rules,firestore:indexes
```

Grant the first admin from the Firebase Console — there is no script, because
`scripts/grant-admin.ts` needs the Admin SDK:

1. Sign up in the app with the owner's email so `users/{uid}` exists.
2. Firestore → `users` → that document → add field `role` (string) = `admin`.

That admin can then set `role` on other users, which the rules allow and nothing else does.
If you later enable Blaze, deploy `firebase/functions/` and move `role` back to custom
claims — the functions are left in the repository unchanged for exactly that.

---

## 3. Run

```bash
flutter run --flavor dev     -t lib/main_dev.dart     --dart-define-from-file=env/dev.json
flutter run --flavor staging -t lib/main_staging.dart --dart-define-from-file=env/staging.json
```

For production, copy `env/prod.example.json` to `env/prod.json` (git-ignored) and fill
the `FIREBASE_*` values from Firebase Console → Project settings → Your apps. These are
public client configuration values and are still included in the built app; keep service
account keys and other privileged credentials out of the app and use CI secrets/server-side
storage for those.

`FIREBASE_APPCHECK_RECAPTCHA_SITE_KEY` comes from Firebase Console → App Check → Apps →
your web app → reCAPTCHA v3. With no Cloud Functions in front of the data, App Check on
Firestore is what stops a scripted client from hammering the enquiry collection, so enable
enforcement on Firestore and fill this key in. Leave it blank only while enforcement is off.

All three env files carry the same key set. A prod build with a blank `FIREBASE_*` value
now fails at startup naming the missing entry instead of degrading to public-only mode.

For dev on web, put the same `FIREBASE_*` keys in `env/dev.local.json` (git-ignored) and pass it
as a second file:

```bash
flutter run -d chrome -t lib/main_dev.dart --dart-define-from-file=env/dev.json --dart-define-from-file=env/dev.local.json
```

### Local emulators

```bash
cd firebase && firebase emulators:start   # auth + firestore only; no functions on Spark
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
# firebase/functions/ is not deployed on Spark; build it only if you enable Blaze.
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
| Enquiry validation (reference only; not deployed on Spark) | `firebase/functions/src/test/validation.test.ts` |

Not yet covered: Firestore security-rules unit tests (`@firebase/rules-unit-testing`). Add these
before production. With no Cloud Functions, the rules are the *only* security boundary.

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
- **Auth boundary.** `AuthMiddleware` hides screens; the Firestore and Storage rules enforce
  access. Staff/admin come from `users/{uid}.role`, writable by an admin only.

---

## 6. Data model (Firestore)

| Path | Written by | Read by |
|---|---|---|
| `services/{slug}`, `caseStudies/{slug}` (`published`, `order`, …) | staff | everyone (published only) |
| `users/{uid}` (`name`, `email`, `phone`, `company`) | owner (limited fields) | owner, staff |
| `users/{uid}/devices/{fcmToken}` | owner | owner |
| `users/{uid}/notifications/{id}` | staff | owner (may only set `read`) |
| `enquiries/{idempotencyKey}` | owner (validated by rules), staff | owner, staff |
| `quotations/{id}` (`customerId`, `items[]`, `total`, `status`, `validUntil`) | staff | owner, staff |
| `projects/{id}` + `milestones/{id}` | staff | owner, staff |
| `tickets/{id}` + `messages/{id}` | owner (validated), staff | owner, staff |
| `projects/{id}/files/*` (Storage) | staff | owner, staff |

**Content.** Without Firestore content the app shows the services and case studies bundled in
`*_local_datasource.dart`, copied from busiserve.in. To edit content without an app release, add
`published: true` documents to `services` / `caseStudies`; fields `description`, `highlights`,
`challenge`, `solution`, `results`, `technologies` are optional and render when present.

**Duplicate protection.** The enquiry form generates one UUID per form session and keeps it across
failed attempts and uses it as the document id. The rules allow create but not update, so a retried
submit collides with the first write and the app reports the original enquiry. Support tickets use the same pattern with a pre-generated document id.

---

## 7. Release

1. Fill `env/prod.json` (including the App Check site key); deploy rules and indexes to prod;
   grant the first admin by setting `users/{uid}.role` in the console.
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
