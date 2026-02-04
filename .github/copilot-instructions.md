## Copilot instructions (GEMS 2.0)

GEMS is a Flutter mobile app (facilities/work orders/PPM/storekeeper). Prefer **small, surgical changes** that match existing patterns.

### Big picture
- Entry point + routing: `lib/main.dart` uses `MaterialApp(onGenerateRoute: _generateRoute)` with a large `switch` over route names.
- Feature layout: screens/BLoCs live under `lib/controller/<Feature>/...` (WorkOrder, PPM, Storekeeper, ReturnItem, etc.).
- Variants: `lib/config/app_config.dart` reads `APP_VARIANT` (`classic`|`client`) for display name, theme, and feature flags.

### Networking (important conventions)
- All HTTP goes through `lib/utils/network.dart` (`Provider`). It injects `Authorization: Bearer <token>` and `deviceid` headers.
- Base URL is **hardcoded** as `netDomain = "https://gems.metadatasystem.my"` in `lib/utils/network.dart` (do not assume `AppConfig.apiConfig` is used).
- Responses often include `result` as **List/Map** or a **double-encoded JSON String**; `Provider.fetch()` handles all three.

### Offline + repositories
- SQLite cache: `lib/data/local/offline_database.dart` (sqflite), current `_dbVersion = 17`.
- Work order list cache-first: `lib/data/repository/work_order_repository.dart` returns warm cache first, then remote, and falls back to cache on errors.
- Work order detail offline mode + action queue: `lib/data/repository/work_order_detail_repository.dart` downloads a snapshot before enabling offline and replays queued actions via `syncPendingActions()`.
- PPM offline: `lib/data/repository/ppm_repository.dart` queues actions and exposes sync progress via `syncProgress$`; periodic retries are orchestrated by `lib/controller/PPM/pending_sync.dart`.

### State management patterns
- Storekeeper BLoCs typically extend `lib/controller/Storekeeper/utils/bloc/bloc.dart` and wrap async calls with `checker(...)` to drive `loadingState$`/`err$`.
- WorkOrder detail uses RxDart `BehaviorSubject` streams in `lib/controller/WorkOrder/bloc/mainBloc.dart` (seeded defaults; update via `sink.add`).
- There are multiple `Bloc` base classes; for Storekeeper/ReturnItem flows use the Storekeeper one (`lib/controller/Storekeeper/utils/bloc/bloc.dart`), not Attendance’s similarly-named base.

### Models / codegen
- API models are `built_value`. Update `lib/model/serializers.dart` when adding models.
- Regenerate with `flutter pub run build_runner build --delete-conflicting-outputs` and **commit the generated `.g.dart`** files.

### Critical pitfall: biometric + system pickers
- When opening camera/gallery/file pickers, **use** `lib/utils/biometric_lock_manager.dart` wrappers (or call `BiometricLockManager.suppressNextLock()` beforehand) to avoid unwanted biometric prompts on resume. See `BIOMETRIC_UX_FIX.md`.

### Dev workflows
- Run variants: `flutter run --dart-define=APP_VARIANT=classic` (or `client`). Release builds: `./build_variants.sh classic-aab|client-aab|all-android`.
- Offline debugging guide: `OFFLINE_DEBUG_GUIDE.md` (DB is `gems_offline.db`; inspect via Flutter DevTools Database Inspector).
- Offline tests exist for WO cache/reopen scenarios: `test/offline_section_cache_test.dart`, `test/offline_reopen_scenario_test.dart`.

### Storekeeper module
- Route names + theme colors live in `lib/controller/Storekeeper/utils/constant.dart` (`routeTechnician`, `routeInventory`, `colorTheme1/2/3/...`). Prefer reusing these instead of introducing new route strings/colors.
- Status handling is commonly string-id based (e.g. `"33"` = approval) with parallel label/color maps (see `lib/controller/Storekeeper/utils/bloc/bloc_task.dart`, `bloc_inventory.dart`).

### Return Item module
- Screens live in `lib/controller/ReturnItem/*` and are wired in `main.dart` as `/return-item-list`, `/return-item-detail` (expects `ReturnPartGroup`), `/return-confirm-list`, `/return-confirm-detail` (expects `String returnId`).
- State is via `ReturnItemBloc` (extends Storekeeper `Bloc`) with streams: `collectedItems$`, `pendingReturns$`, `pendingCount$`.
- API integration is in `ReturnTicketService`: list endpoints use `Provider.getJson(...)`, but submit/verify use JSON `http.post` with `Authorization` + `deviceid` headers sourced from `Provider`.
- Models are plain Dart (not `built_value`) in `lib/model/return_ticket_models.dart`; parsing is defensive (`toString()`, computed `quantityAvailableToReturn`).

### Useful conventions
- Navigation mixes route constants (Storekeeper) and string literals (e.g. `/return-item-detail`); stay consistent with the surrounding feature.
- `main.dart` overrides `debugPrint` to feed `DebugLogService`; prefer `debugPrint(...)` so logs appear in the in-app debug log screens.
