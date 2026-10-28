# Busiserve — official mobile app

Flutter + GetX app for **Busiserve Infotech Solution** (https://www.busiserve.in), with a Firebase backend
(Auth, Firestore, App Check, Crashlytics) on the free Spark plan — no Cloud Functions.

Public visitors can browse services, case studies and contact details. Sending an enquiry needs an
account. Signed-in customers can also track enquiries and quotations, follow project milestones, receive
notifications, raise support requests and delete their account.

> **Where things stand.** The app currently runs on **web** (Chrome) against the `busiserve-app`
> Firebase project. Android needs the one-time steps in [Android setup](#33-android-setup-one-time)
> before it builds, and the iOS folder has not been generated yet. Before you start changing code,
> run the checks in [Verify](#4-verify).

---

## 1. Set up your system

Follow these steps in order on a new machine. Commands are the same on Windows (PowerShell or
Git Bash), macOS and Linux unless a step says otherwise.

### 1.1 Install the tools

| Tool | Version | Needed for | Check with |
|---|---|---|---|
| [Git](https://git-scm.com/downloads) | any recent | cloning the repo | `git --version` |
| [Flutter SDK](https://docs.flutter.dev/get-started/install) | 3.27 or newer (includes Dart 3.6+) | everything | `flutter --version` |
| [Google Chrome](https://www.google.com/chrome/) | any recent | running the web build | — |
| [Android Studio](https://developer.android.com/studio) | latest, with Android SDK, command-line tools and an emulator | Android builds | `flutter doctor` |
| JDK 17 | bundled with Android Studio | Android builds | `java -version` |
| [Node.js](https://nodejs.org/) | 20 LTS | Firebase CLI | `node -v` |
| [Firebase CLI](https://firebase.google.com/docs/cli) | latest | deploying rules, emulators | `firebase --version` |
| FlutterFire CLI | latest | generating native Firebase config | `flutterfire --version` |
| Xcode 15+ and CocoaPods | macOS only | iOS builds | `xcodebuild -version` |

Install the two CLIs after Node and Flutter are in place:

```bash
npm install -g firebase-tools
dart pub global activate flutterfire_cli
```

On Windows, add `%LOCALAPPDATA%\Pub\Cache\bin` to your `PATH` so the `flutterfire` command is
found. On macOS/Linux, add `$HOME/.pub-cache/bin`. Then accept the Android licences and check the
toolchain:

```bash
flutter doctor --android-licenses
flutter doctor
```

`flutter doctor` should show green ticks for Flutter and Chrome, plus the Android toolchain if you
build for Android. Fix anything it reports before going further.

### 1.2 Get the code and dependencies

```bash
git clone <repository-url> busiserve_app
cd busiserve_app
flutter pub get
```

Optional, only after changing the icon or splash images in `assets/`:

```bash
dart run flutter_launcher_icons
dart run flutter_native_splash:create
```

### 1.3 Create your local environment files

Build settings come from JSON files in `env/`, passed with `--dart-define-from-file`. Two of them
are git-ignored, so every developer creates them locally:

| File | Committed? | Purpose |
|---|---|---|
| `env/dev.json` | yes | dev flavor settings, Firebase values left blank |
| `env/staging.json` | yes | staging flavor settings, Firebase values left blank |
| `env/prod.example.json` | yes | template for `env/prod.json` |
| `env/prod.json` | **no** | production Firebase web config |
| `env/dev.local.json` | **no** | Firebase web config for running dev on web |

Create `env/prod.json` from the template:

```bash
# macOS / Linux / Git Bash
cp env/prod.example.json env/prod.json
# Windows PowerShell
Copy-Item env/prod.example.json env/prod.json
```

Fill in every `FIREBASE_*` value from **Firebase Console → Project settings → General → Your apps →
Web app → SDK setup and configuration**. These are public client identifiers, not secrets. Keep
service-account keys and other privileged credentials out of these files and out of the repo.

`env/dev.local.json` holds only the Firebase keys:

```json
{
  "FIREBASE_API_KEY": "AIza...",
  "FIREBASE_AUTH_DOMAIN": "busiserve-app.firebaseapp.com",
  "FIREBASE_PROJECT_ID": "busiserve-app",
  "FIREBASE_STORAGE_BUCKET": "busiserve-app.firebasestorage.app",
  "FIREBASE_MESSAGING_SENDER_ID": "...",
  "FIREBASE_APP_ID": "1:...:web:..."
}
```

`FIREBASE_APPCHECK_RECAPTCHA_SITE_KEY` comes from **Firebase Console → App Check → Apps → your web
app → reCAPTCHA v3**. You can leave it blank while App Check enforcement is off. Once enforcement
is on, it's required. With no Cloud Functions in front of the data, App Check on Firestore is what
stops scripted clients from flooding the enquiry collection.

A prod build with a blank `FIREBASE_*` value fails at startup and names the missing entry. Dev and
staging builds without Firebase values still start, but in public-only mode: you can browse
services and case studies, but you can't sign in or send enquiries.

---

## 2. Firebase setup

You only need this section if you're setting up a new Firebase project or deploying rules. If
you're joining an existing project, ask the owner for the web config values in step 1.3 and go
to [Run the app](#3-run-the-app).

### 2.1 Console setup (once per project)

1. Create the project (production uses `busiserve-app`) on the free **Spark** plan.
2. **Authentication → Sign-in method:** enable Email/Password.
3. **Firestore Database:** create it in region `asia-south1`.
4. **Project settings → Your apps:** add a Web app, plus Android/iOS apps when you build for them.
5. **App Check:** register reCAPTCHA v3 for web, and Play Integrity / App Attest for native.

### 2.2 Deploy Firestore rules and indexes

```bash
firebase login
cd firebase
cp .firebaserc.example .firebaserc          # edit the project ids if yours differ
firebase use prod
firebase deploy --only firestore:rules,firestore:indexes
cd ..
```

### 2.3 Make yourself an admin

There's no script for this, because `scripts/grant-admin.ts` needs the Admin SDK, which Spark
doesn't allow.

1. Run the app and sign up with the owner's email so that `users/{uid}` exists.
2. In **Firestore**, open `users` → that document, then add the field `role` (string) = `admin`.

That admin can then set `role` on other users. The rules allow this for admins and no one else.

### 2.4 Spark plan: no Cloud Functions

This project runs on the **free Spark plan**, so nothing in `firebase/functions/` is deployed.
Everything those functions used to do now happens in the client, and the Firestore security
rules are the only enforcement point:

| Was | Now |
|---|---|
| `createEnquiry` validated and wrote the enquiry | The signed-in customer writes `enquiries/{idempotencyKey}` directly; `firestore.rules` validates every field |
| `deleteAccount` deleted the user and anonymised their records | The app clears the profile subcollections, deletes `users/{uid}`, then calls `User.delete()` |
| `setUserRole` set a `role` custom claim | `users/{uid}.role` is a Firestore field; only an admin may write it |
| `onQuotationCreated` / `onProjectUpdated` / `onTicketMessageCreated` sent notifications | Staff create `users/{uid}/notifications/{id}` by hand |

Trade-offs of running without Cloud Functions:

- **Anonymous enquiries are gone.** Submitting now requires an account, because an
  unauthenticated write path would be an open door for bots.
- **No rate limiting.** The old 5-per-hour-per-email cap needed a server-side counter.
  App Check and the sign-in requirement are the remaining defences.
- **No push notifications at all.** Sending FCM needs a server key. The in-app
  notification list still works, but someone has to write the entries.
- **Deleted accounts leave records behind.** Enquiries, quotations, projects and tickets
  keep pointing at a uid that no longer exists; anonymising them needs the Admin SDK.
  Clear them from the console when you delete an account.
- **Firebase Storage is not set up.** The app does not use it, and new projects need
  Blaze for a default bucket anyway.

If you later move to the Blaze plan, deploy `firebase/functions/` and move `role` back to custom
claims. The functions are kept in the repository for that purpose.

---

## 3. Run the app

### 3.1 Web (works today)

```bash
# Production Firebase project
flutter run -d chrome -t lib/main_prod.dart --dart-define-from-file=env/prod.json

# Dev flavor against the same Firebase project
flutter run -d chrome -t lib/main_dev.dart \
  --dart-define-from-file=env/dev.json --dart-define-from-file=env/dev.local.json
```

In PowerShell, put each command on one line or replace the trailing `\` with a backtick.

Plain `flutter run -d chrome` runs `lib/main.dart`, which is the dev flavor without Firebase
config, so the app starts in public-only mode.

### 3.2 Local Firebase emulators

Use these to test sign-in and Firestore without touching real data:

```bash
cd firebase && firebase emulators:start   # auth + firestore; Emulator UI at http://localhost:4000
# in a second terminal, from the project root:
flutter run -d chrome -t lib/main_dev.dart \
  --dart-define-from-file=env/dev.json --dart-define-from-file=env/dev.local.json \
  --dart-define=USE_FIREBASE_EMULATOR=true
```

### 3.3 Android setup (one-time)

The `android/` folder is the default `flutter create` output and isn't ready to build yet. Do
these steps once, in this order.

**1. Declare the Google Services Gradle plugin.** `android/app/build.gradle.kts` applies
`com.google.gms.google-services`, but `android/settings.gradle.kts` never declares it. Add it to
the `plugins { }` block in `android/settings.gradle.kts`:

```kotlin
id("com.google.gms.google-services") version "4.4.2" apply false
```

**2. Set the package name and flavors.** In `android/app/build.gradle.kts`, change `namespace`
and `applicationId` from `com.example.busiserve_app` to `in.busiserve.app`, set `minSdk = 23`,
and add inside `android { }`:

```kotlin
flavorDimensions += "env"
productFlavors {
    create("dev") {
        dimension = "env"
        applicationIdSuffix = ".dev"
        resValue("string", "app_name", "Busiserve Dev")
    }
    create("staging") {
        dimension = "env"
        applicationIdSuffix = ".staging"
        resValue("string", "app_name", "Busiserve Staging")
    }
    create("prod") {
        dimension = "env"
        resValue("string", "app_name", "Busiserve")
    }
}
```

Move `MainActivity.kt` to the matching package folder (`kotlin/in/busiserve/app/`) and update its
`package` line.

**3. Update `AndroidManifest.xml`.** In `android/app/src/main/AndroidManifest.xml`, set
`android:label="@string/app_name"`, and add these to the existing `<queries>` block so phone,
email and web links open on Android 11+:

```xml
<intent><action android:name="android.intent.action.DIAL" /><data android:scheme="tel" /></intent>
<intent><action android:name="android.intent.action.SENDTO" /><data android:scheme="mailto" /></intent>
<intent><action android:name="android.intent.action.VIEW" /><data android:scheme="https" /></intent>
```

**4. Connect Firebase.** Register the Android app and download `google-services.json`. The file is
git-ignored, so every developer runs this:

```bash
flutterfire configure --project=busiserve-app --platforms=android --android-package-name=in.busiserve.app
```

The command also writes `lib/firebase_options.dart`. The app doesn't read that file. Instead,
copy its `android` `FirebaseOptions` into `lib/core/config/firebase/firebase_options_prod.dart`
(which currently throws on every non-web platform) and return it when
`defaultTargetPlatform == TargetPlatform.android`. Then delete `lib/firebase_options.dart`. Repeat
with the `.dev` / `.staging` package names when those Firebase projects exist.

**5. Add the debug SHA-256** to the Android app in Firebase Console so that App Check and Auth
work on debug builds:

```bash
cd android && ./gradlew signingReport      # Windows: .\gradlew signingReport
```

### 3.4 iOS setup (one-time, macOS only)

```bash
flutter create . --org in.busiserve --project-name busiserve_app --platforms ios
cd ios && pod install && cd ..
flutterfire configure --project=busiserve-app --platforms=ios --ios-bundle-id=in.busiserve.app
```

Then, in Xcode:

- Create schemes `dev`, `staging` and `prod` with matching build configurations (`Debug-dev`,
  `Release-dev`, ...) and bundle IDs `in.busiserve.app.dev`, `in.busiserve.app.staging` and
  `in.busiserve.app`.
- Enable **Push Notifications** and **Background Modes → Remote notifications**.
- Upload an APNs key in **Firebase Console → Project settings → Cloud Messaging**.

As with Android, copy the `ios` options into the flavor's `firebase_options_*.dart` file.

### 3.5 Run on a phone or emulator

After 3.3 or 3.4:

```bash
flutter devices                                   # list emulators and connected phones
flutter run --flavor dev  -t lib/main_dev.dart  --dart-define-from-file=env/dev.json
flutter run --flavor prod -t lib/main_prod.dart --dart-define-from-file=env/prod.json
```

### 3.6 Troubleshooting

| Symptom | Fix |
|---|---|
| `env/prod.json is incomplete: FIREBASE_...` | Fill the named key in `env/prod.json` (step 1.3). |
| App runs but sign-in and enquiries are disabled | Firebase didn't initialise. Either you ran dev/staging without `env/dev.local.json`, or you ran on Android/iOS before the native setup. |
| `flutterfire: command not found` | Add the pub-cache `bin` folder to `PATH` (step 1.1). |
| `Plugin [id: 'com.google.gms.google-services'] was not found` | Android step 1. |
| `File google-services.json is missing` | Android step 4. |
| Gradle can't find the `dev` / `prod` flavor | Android step 2. |
| `flutter.sdk not set in local.properties` | Run `flutter pub get` once from the project root; it writes `android/local.properties`. |
| Stale build errors after switching branches | `flutter clean`, then `flutter pub get`. |

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
