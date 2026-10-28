# Busiserve — official mobile app

Flutter + GetX app for **Busiserve Infotech Solution** (https://www.busiserve.in), with a Firebase backend
(Auth, Firestore, App Check, Crashlytics) on the free Spark plan — no Cloud Functions.

Public visitors can browse services, case studies and contact details. Sending an enquiry needs an
account. Signed-in customers can also track enquiries and quotations, follow project milestones, receive
notifications, raise support requests and delete their account.

> **Where things stand.** The app runs on **web** (Chrome) and **Android** against the
> `busiserve-app` Firebase project. Android has no build flavors yet, so every Android build uses
> package `in.busiserve_app`. The `ios/` folder exists (bundle ID `in.busiserveApp`), but iOS is not
> connected to Firebase yet, so it starts in public-only mode. Before you start changing code, run
> the checks in [Verify](#4-verify).

## Quick start (Android phone)

For a machine that already has Flutter and Android Studio installed. Every step is explained in
detail further down.

```bash
git clone <repository-url> busiserve_app
cd busiserve_app
flutter pub get
# put the Firebase Android config in place (ask the project owner, or see 3.3):
#   android/app/google-services.json
flutter devices                    # phone connected with USB debugging on
flutter run -d <device-id>
```

The phone needs a working internet connection. Without one, the app shows a "No internet" screen
and comes back by itself when the connection returns (see [3.6](#36-offline-screen)).

---

## 1. Set up your system

Follow these steps in order on a new machine. Commands are the same on Windows (PowerShell or
Git Bash), macOS and Linux unless a step says otherwise.

### 1.1 Install the tools

| Tool | Version | Needed for | Check with |
|---|---|---|---|
| [Git](https://git-scm.com/downloads) | any recent | cloning the repo | `git --version` |
| [Flutter SDK](https://docs.flutter.dev/get-started/install) | 3.27 or newer (includes Dart 3.6+); last tested on 3.47.8 stable | everything | `flutter --version` |
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

The generated app icons and splash screens for Android, iOS and web are already committed. Run
these only after replacing `assets/icons/app_icon.png` (app icon) or `assets/images/logo_mark.png`
(splash). Their settings are in `pubspec.yaml` under `flutter_launcher_icons` and
`flutter_native_splash`.

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
| `android/app/google-services.json` | **no** | Firebase config for Android (see [Android setup](#33-android-setup-one-time)) |

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

The `FIREBASE_*` values are used only on **web**. On Android, Firebase reads
`google-services.json` instead.

A prod web build with a blank `FIREBASE_*` value fails at startup and names the missing entry. Dev
and staging web builds without Firebase values still start, but in public-only mode: you can
browse services and case studies, but you can't sign in or send enquiries.

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
- **Rate limiting lives in the rules, per account only.** See [2.5](#25-abuse-protection).
  There is no per-IP limit, which would need a server.
- **No push notifications at all.** Sending FCM needs a server key. The in-app
  notification list still works, but someone has to write the entries.
- **Deleted accounts leave records behind.** Enquiries, quotations, projects and tickets
  keep pointing at a uid that no longer exists; anonymising them needs the Admin SDK.
  Clear them from the console when you delete an account.
- **Firebase Storage is not set up.** The app does not use it, and new projects need
  Blaze for a default bucket anyway.

If you later move to the Blaze plan, deploy `firebase/functions/` and move `role` back to custom
claims. The functions are kept in the repository for that purpose.

### 2.5 Abuse protection

Three layers stop bots and spam from flooding staff with enquiries and tickets:

1. **Verified email.** The rules accept enquiries, new tickets and customer messages only when
   the ID token has `email_verified == true`. The app shows a notice with **Resend link** and
   **I've verified** buttons on the enquiry form, the new-ticket form and the Account tab.
2. **Per-account rate limits**, enforced by `firestore.rules`:

   | Write | Cooldown | Max per 24 hours |
   |---|---|---|
   | Enquiry | 2 minutes | 5 |
   | Support ticket | 2 minutes | 5 |
   | Ticket message | 3 seconds | 200 |

   Each limited create must be committed in the same batch as an update to
   `users/{uid}/limits/{enquiry|ticket|message}` (`last`, `windowStart`, `count`, `lastId`). The
   rules check the cooldown and the count, require `lastId` to equal the new document's id (so one
   update can't pay for several writes), and never allow the limit document to be deleted. The
   app does this in `lib/core/services/rate_limits.dart` and shows a friendly message before the
   write when a limit is reached. **If you change a number, change it in both `firestore.rules`
   (`limitCooldown` / `limitPerDay`) and `RateLimit` in `rate_limits.dart`.**
3. **App Check.** Turn on enforcement for Cloud Firestore in **Firebase Console → App Check →
   APIs**, so only the genuine app can write at all. Check the App Check metrics page first: once
   enforcement is on, unverified requests (old app versions, debug builds without a registered
   debug token) are rejected.

Firebase Auth also limits how fast new accounts can be created from one IP address.

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

**1. Get `google-services.json`.** The Android app is already registered in the `busiserve-app`
Firebase project with package name **`in.busiserve_app`**, which matches `applicationId` in
`android/app/build.gradle.kts`. Download its config from **Firebase Console → Project settings →
General → Your apps → Android app (`in.busiserve_app`) → google-services.json** and save it as:

```
android/app/google-services.json
```

The file is git-ignored, so every developer downloads it once. Without it, the build stops with
`File google-services.json is missing`. Check that it's in place:

```bash
ls android/app        # should list build.gradle.kts, google-services.json, src
```

You don't need any Dart changes. On Android, `firebase_options_dev.dart` and
`firebase_options_prod.dart` return `null`, so Firebase reads its settings from this file. The
`env/*.json` Firebase keys aren't used on Android.

If you ever change `applicationId`, register the new package name in Firebase and download
`google-services.json` again. Otherwise the build fails with `No matching client found for
package name`.

**2. Run on a phone.** Turn on **Developer options → USB debugging** on the phone, connect it by
USB and accept the prompt on the phone. Then:

```bash
flutter devices                    # copy the phone's id, e.g. 10BF9L1J6Y003J4
flutter run -d <device-id>
```

The first build takes several minutes, because Gradle downloads the Android SDK platforms and the
NDK. Later builds are much faster. See [3.5](#35-run-on-a-phone-or-emulator) for picking a flavor.

**3. Optional: add flavors.** These are needed only for `--flavor dev|staging|prod` builds. In
`android/app/build.gradle.kts`, set `minSdk = 23` and add inside `android { }`:

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

Register `in.busiserve_app.dev` and `in.busiserve_app.staging` in Firebase too. Then download
`google-services.json` again so that it covers all three package names.

**4. Update `AndroidManifest.xml`.** `android/app/src/main/AndroidManifest.xml` already has the
`INTERNET` permission, which release builds need for Firebase and the offline check. Add these to
the existing `<queries>` block so phone, email and web links open on Android 11+. The launcher
label is still `busiserve_app`: change it to `android:label="Busiserve"` now, or to
`android:label="@string/app_name"` after step 3.

```xml
<intent><action android:name="android.intent.action.DIAL" /><data android:scheme="tel" /></intent>
<intent><action android:name="android.intent.action.SENDTO" /><data android:scheme="mailto" /></intent>
<intent><action android:name="android.intent.action.VIEW" /><data android:scheme="https" /></intent>
```

**5. Add the debug SHA-256** to the Android app in Firebase Console. Email/password sign-in works
without it, but App Check and Google sign-in need it:

```bash
cd android && ./gradlew signingReport      # Windows: .\gradlew signingReport
```

### 3.4 iOS setup (one-time, macOS only)

The `ios/` folder is already in the repo (bundle ID `in.busiserveApp`, iOS 15.0 minimum, icons
and launch screen generated). Don't run `flutter create` for iOS again. iOS bundle IDs can't
contain underscores, so iOS uses `in.busiserveApp` while Android uses `in.busiserve_app`.

```bash
flutter pub get
flutter build ios --no-codesign      # first run creates ios/Podfile and runs pod install
flutterfire configure --project=busiserve-app --platforms=ios --ios-bundle-id=in.busiserveApp
```

`flutterfire configure` registers the iOS app in Firebase and writes
`ios/Runner/GoogleService-Info.plist` (git-ignored, so every developer downloads or generates it).

Then, in Xcode (`open ios/Runner.xcworkspace`):

- Set your signing team under **Runner → Signing & Capabilities**.
- Only if you want flavors: create schemes `dev`, `staging` and `prod` with matching build
  configurations (`Debug-dev`, `Release-dev`, ...) and bundle IDs `in.busiserveApp.dev`,
  `in.busiserveApp.staging` and `in.busiserveApp`.
- Enable **Push Notifications** and **Background Modes → Remote notifications**.
- Upload an APNs key in **Firebase Console → Project settings → Cloud Messaging**.

Then copy the `ios` options from the generated `lib/firebase_options.dart` into the flavor's
`firebase_options_*.dart` file and return them when `defaultTargetPlatform == TargetPlatform.iOS`.
Delete `lib/firebase_options.dart` afterwards. The flavor files currently throw on iOS, so until
then the app starts in public-only mode.

### 3.5 Run on a phone or emulator

Without flavors (the current setup), `-t` picks the entry point. Both entry points connect to
`busiserve-app` through `google-services.json`:

```bash
flutter run -d <device-id>                                   # lib/main.dart = dev, "Busiserve Dev"
flutter run -d <device-id> -t lib/main_prod.dart --dart-define-from-file=env/prod.json
flutter build apk --release -t lib/main_prod.dart --dart-define-from-file=env/prod.json
```

After you've added flavors (Android step 3), add `--flavor dev|staging|prod` to these commands.

### 3.6 Offline screen

On Android and iOS, `OfflineGate` (`lib/core/widgets/offline_gate.dart`, wired in `app.dart`) covers
the current screen with a "No internet" animation (`assets/animations/network_error.json`) when the
device has no working internet. It does not trust Wi-Fi/mobile status alone. It checks that a real
host is reachable, re-checks every 5 seconds and whenever connectivity changes, and returns the user
to the same screen once the internet is back. The check is skipped on web.

To test it, turn on airplane mode while the app is open, then turn it off again.

### 3.7 Small screens and large fonts

The layouts are built to work on small phones (down to about 320 dp wide) and with large system
font sizes:

- Text scaling follows the phone's font setting, but `app.dart` caps it at **1.3x** so cards and
  grids keep their shape. Raise `maxScaleFactor` there only if you also check every screen.
- The home "What we build" grid shows 2 columns below 360 dp width, 3 on phones and 4 on tablets.
  Tile height is calculated from the font size, not a fixed aspect ratio.
- Long titles end in "..." instead of overflowing.

Before releasing UI changes, check on a small emulator (for example a 4" / 320 dp device) with
**Settings → Display → Font size** at the largest setting. A red-and-yellow "BOTTOM OVERFLOWED BY
… PIXELS" stripe in a debug build means a widget has a fixed height that's too small for its text.

### 3.8 Troubleshooting

| Symptom | Fix |
|---|---|
| `env/prod.json is incomplete: FIREBASE_...` | Fill the named key in `env/prod.json` (step 1.3). |
| "Accounts are not available yet" on sign-up | Firebase didn't initialise. On web, you ran without `env/dev.local.json` / `env/prod.json`. Restart the app with the full command from 3.1; hot reload isn't enough. Look for `Firebase not initialised` in the terminal for the exact cause. |
| `flutterfire: command not found` | Add the pub-cache `bin` folder to `PATH` (step 1.1). |
| `File google-services.json is missing` | Android step 1. The file must be at `android/app/google-services.json`, not inside `src/`, and not named `google-services (1).json`. |
| `No matching client found for package name` | `applicationId` doesn't match a package in `google-services.json`. Re-download it after registering the package. |
| Gradle can't find the `dev` / `prod` flavor | Flavors aren't set up yet. Run without `--flavor`, or do Android step 3. |
| Warnings about `java.lang.System::load` or `cloud_functions` / Kotlin Gradle Plugin | Harmless warnings. They don't cause the build to fail. |
| `flutter.sdk not set in local.properties` | Run `flutter pub get` once from the project root; it writes `android/local.properties`. |
| Stale build errors after switching branches | `flutter clean`, then `flutter pub get`. |
| "No internet" screen stays although the phone is online | The reachability check is failing (captive Wi-Fi login, firewall, VPN). Open a website in the phone browser first. A release build also needs `INTERNET` in `AndroidManifest.xml`. |
| "BOTTOM OVERFLOWED BY … PIXELS" stripe | A widget has a fixed height that's too small for its text at the current font size. See [3.7](#37-small-screens-and-large-fonts). |
| `pod install` / `Podfile` not found (iOS) | Run `flutter build ios --no-codesign` once; it generates `ios/Podfile`. |
| "Verify your email first" although the link was clicked | Tap **I've verified**; it reloads the account and refreshes the sign-in token, which the rules read. |
| "You've reached today's limit…" / "Please wait a moment…" | A rate limit from [2.5](#25-abuse-protection). In testing, delete `users/{uid}/limits/*` from the console or emulator UI. |
| `npm test` in `firebase/test`: "Could not start Firestore Emulator, port taken" | An emulator is already on port 8080, often one left over from an earlier run on Windows. Either run `npm run test:running` to test against it, or stop it: `netstat -ano \| findstr :8080`, then `taskkill /PID <pid> /F`. |
| `permission-denied` on enquiry/ticket after editing the rules | The batch must also update `users/{uid}/limits/{kind}`; run the rules tests (section 4). |

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

# Firestore security rules (needs Node 20+ and Java 11+; starts its own emulator)
cd firebase/test && npm install && npm test
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
| Security rules: email verification, rate limits (cooldown, daily cap, new window, one write per limit update), limit docs can't be deleted or lowered, ticket `relatedId` size | `firebase/test/firestore.rules.test.js` |

The rules tests cover the abuse-protection rules only. Field validation and owner/staff access
are not tested yet. Extend `firestore.rules.test.js` whenever you change the rules: with no Cloud
Functions, they are the *only* security boundary.

---

## 5. Architecture

```
lib/
  main_dev|staging|prod.dart  flavor entry points -> bootstrap.dart
  app.dart                    GetMaterialApp, themes, text-scale cap, OfflineGate
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
    widgets/     AppButton, AppTextField, StateView, OfflineGate, hexagon motif, cards, notices
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
2. Android: create an upload keystore and `android/key.properties` (both git-ignored). The signing
   config in `android/app/build.gradle.kts` already reads it; without it, release builds fall back
   to the debug key and Gradle prints a warning. Never distribute a debug-signed APK. Add the release
   SHA-256 to Firebase and Play Integrity.

   ```properties
   storePassword=...
   keyPassword=...
   keyAlias=upload
   storeFile=C:/path/to/upload-keystore.jks
   ```
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
