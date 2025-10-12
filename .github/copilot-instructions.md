# Copilot instructions for GEMS

## 🧭 Architecture
- GEMS is a Flutter mobile app; `lib/main.dart` wires Firebase init, push notifications, and registers every feature route (WorkOrder, Storekeeper, Utilities, etc.).
- Feature code lives under `lib/controller/<Feature>/…`, mixing screens with their feature-specific logic; reuse this structure when adding flows.
- Variant-specific branding lives in `lib/config/app_config.dart` and is selected by `--dart-define=APP_VARIANT`; UI reads colors/flags via `AppConfig.themeConfig` and `AppConfig.features`.

## 🧩 Data & networking
- All HTTP calls go through `lib/utils/network.dart`; `Provider` adds device + bearer headers from the stored `User` and exposes `fetch`, `post`, `put`, etc.
- API paths are relative to `netDomain` (`https://gems.metadatasystem.my`); `AppConfig.apiConfig` is future-proof but not yet wired into Provider.
- Responses are deserialized with built_value models declared in `lib/model/**`; keep `.g.dart` files committed.
- After editing model classes update serializers with `flutter pub run build_runner build --delete-conflicting-outputs`.

## 🧱 State management patterns
- Storekeeper flows demonstrate the house BLoC: see `lib/controller/Storekeeper/utils/bloc/bloc.dart` and `bloc_task.dart` (`MaterialTask`).
- Each BLoC exposes `BehaviorSubject` streams (`materials$`, `detail$`) consumed by `StreamBuilder`; push updates via `sink.add` setters.
- Wrap async work with `checker(...)` to auto-toggle loading + error streams; UI subscribes via `_bloc.loadingState$` and `_bloc.err$` to show spinners/toasts.

## 🎨 UI conventions
- Colors/constants share two sources: general app colors in `lib/utils/reference.dart` (`AppColors`, `getButtonBgColorByStatus`) and Storekeeper palette in `controller/Storekeeper/utils/constant.dart`.
- Use Google Fonts (`GoogleFonts.poppins`) and chip/card patterns like `_MaterialCard` when presenting material inventory data.
- Toasts rely on the `toast` package—always call `ToastContext().init(context)` in `initState`/`didChangeDependencies` like existing screens.

## 🔌 Integrations & side effects
- Firebase Core/Messaging is initialized in `main.dart`; background handlers log to console, while foreground notifications go through `flutter_local_notifications` via `setupFlutterNotifications()`.
- Device metadata is fetched with `device_info_plus` and attached to requests (`deviceid` header); keep this intact for backend auth.
- Session expiry is surfaced by `Provider.fetch` (strings like "Signature verification failed"); call `alert(...)` from `lib/view/dialog.dart` to prompt relogin.

## 🔧 Build, run, and quality gates
- Install deps with `flutter pub get`; sanity-check changes with `flutter analyze` and `flutter test` (tests are sparse but wired up).
- Use `./build_variants.sh <command>` to package release artifacts (e.g., `./build_variants.sh classic-aab`, `client-aab`, `all-android`).
- For local debugging run `flutter run --dart-define=APP_VARIANT=classic` (or `client`) to mirror production branding/features.

## 🛠️ Feature implementation tips
- When adding inventory flows, compose REST helpers via the existing `Request` wrapper pattern (`bloc_task.dart`) so statuses, button copy, and colors stay consistent.
- Route names for Storekeeper screens live in `controller/Storekeeper/utils/constant.dart`; reuse them when navigating via `Navigator.pushNamed`.
- Dialog interactions (remarks, double confirmation) reuse `CustomDialog` from `controller/Storekeeper/utils/widget/dialog.dart`; it already handles max length + toast messaging.

## 🧩 Assets & configuration
- Assets are globbed via `assets/` in `pubspec.yaml`; keep new images inside that folder to avoid manual registration.
- Fonts (`fonts/Avenir-Roman.otf`) and launcher icon configuration are declared in `pubspec.yaml`; update both Android/iOS via `flutter_launcher_icons` if branding changes.
- `build_variants.sh clean` runs `flutter clean` + `pub get`; use it when switching SDK channels or after large asset updates.
