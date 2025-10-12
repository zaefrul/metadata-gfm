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

## 📦 WorkOrder offline roadmap
- **Execution model**: We (mobile) implement all client-side changes. When a step calls for backend support, request the specific API update and the backend team will handle it. Existing endpoints are reusable; backend tweaks are optional optimizations.
- **Phase 0 – Discovery & groundwork**
	- *Mobile*: choose local storage tech (Drift/Isar/etc.), add connectivity monitoring + feature flag, spike repository ↔ cache.
	- *Backend*: confirm bulk download/update coverage, plan any new endpoints or metadata (version stamps, batch APIs).
- **Phase 1 – Local cache foundations**
	- *Mobile*: create WorkOrder schemas (headers, tasks, checklists, references), implement repository layered over `Provider`, refactor list screens to serve cached data first.
	- *Backend*: ensure responses include stable identifiers + timestamps; no schema changes required if already present.
- **Phase 2 – Selective download flow**
	- *Mobile*: add download selectors, orchestrate multi-endpoint bundle fetch, persist atomically, load detail UIs from cache, cache attachments on disk.
	- *Backend*: optionally expose bundle/delta endpoints for efficiency; otherwise existing APIs suffice.
- **Phase 3 – Offline interaction & optimistic updates**
	- *Mobile*: build action queue for POST/PUT calls, optimistic UI updates, offline mode indicators, local storage for remarks/photos/signatures.
	- *Backend*: document payload validation rules; confirm idempotency expectations so queued requests replay cleanly.
- **Phase 4 – Sync engine & conflict handling**
	- *Mobile*: implement sync worker with retry/backoff, detect conflicts via version metadata, build conflict resolution UI, surface sync progress/errors.
	- *Backend*: add or expose versioning/`updatedAt`/ETag metadata and return conflict info on stale updates; support “changes since” endpoints if feasible.
- **Phase 5 – Polish & rollout**
	- *Mobile*: storage management screen, secure wipe on logout/biometric failure, automated offline tests, staged rollout via feature flag.
	- *Backend*: monitor load, provide analytics endpoints, prep support playbook for conflict escalations.
- **Communication cadence**: before starting each phase, verify backend readiness (if needed) and capture decisions in PR/notes so future prompts stay aligned.

## 🗂️ Offline rollout progress
- **Phase 1 – Step 1 (Local storage foundation)** — ✅ Completed on 2025-10-12. Created the sqflite-backed `OfflineDatabase`, schema tables, and entity mappers.
- **Phase 1 – Step 2 (Repository layer over cache + network)** — ✅ Completed on 2025-10-12. Added `WorkOrderRepository` to hydrate from the API, persist results via `OfflineDatabase`, and serve cached lists to the existing WorkOrder UI.
- **Phase 1 – Step 3 (Refactor WorkOrder controllers to offline-first flows)** — 🔜 Up next. Switch `ComplaintSection` detail flows to consume repository data and queue mutations for offline replay.
