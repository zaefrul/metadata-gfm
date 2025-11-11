# Copilot Instructions for GEMS

> **Project Context**: GEMS 2.0 is a facilities management Flutter mobile app for work order tracking, PPM scheduling, inventory management, and attendance. The Flutter app (`metadata-gfm`) communicates with a PHP backend (`Backend/gems2`) hosted at `https://gems.metadatasystem.my`.

---

## 🏗️ Architecture Overview

### App Structure & Entry Point
- **`lib/main.dart`**: Bootstraps Firebase (Core + Messaging), registers all feature routes, handles push notifications via `flutter_local_notifications`, and manages biometric authentication on app resume.
- **Feature organization**: Code lives under `lib/controller/<Feature>/` (WorkOrder, Storekeeper, PPM, Utilities, Attendance, etc.) with screens and feature-specific BLoCs co-located.
- **Routing**: Most routes registered in `main.dart` via switch/case; Storekeeper routes defined as constants in `lib/controller/Storekeeper/utils/constant.dart` (e.g., `routeTechnician`, `routeDashboard`).

### Multi-Variant Build System
- **Configuration**: `lib/config/app_config.dart` reads `APP_VARIANT` dart-define at compile time; supports `classic` (default teal theme, basic features) and `client` (blue theme, premium features enabled).
- **Feature flags**: Check `AppConfig.features['advancedReporting']`, `AppConfig.features['bulkOperations']`, etc. to gate premium functionality.
- **Theme colors**: Access via `AppConfig.themeConfig['primaryColor']`, `themeConfig['watermarkText']`, etc.
- **Bundle ID**: Both variants use `com.GFM.GEMS` to comply with Apple requirements; app display names differ ("GEMS 2.0" vs "GEMS 2.0 Client").
- **Building variants**: Use `./build_variants.sh classic-aab|client-aab|all-android` for release builds. For dev: `flutter run --dart-define=APP_VARIANT=classic`.

---

## 🌐 Networking & Data Layer

### HTTP Provider Pattern
- **Base class**: `lib/utils/network.dart` → `Provider` class handles all API calls.
- **Authentication**: Auto-injects `Authorization: Bearer <token>` and `deviceid: <device_id>` headers on every request.
- **Device ID**: Fetched via `device_info_plus` (Android: `build.id`, iOS: `identifierForVendor`).
- **Base URL**: `netDomain = "https://gems.metadatasystem.my"` (hardcoded; `AppConfig.apiConfig` exists but isn't wired yet).
- **Endpoints**: Mix of legacy (`/api/m_wo.php?type=...`) and v2 RESTful (`/wo_v2/section_assign/:id`, `/wo_parts/wo_parts_list/:id`).

### API Response Handling
- **Deserialization**: Responses use `built_value` models in `lib/model/**` with committed `.g.dart` files.
- **Session expiry**: Provider checks for `"Signature verification failed"`, `"Device ID invalid"`, `"Expired token"` in response; calls `alert(...)` from `lib/view/dialog.dart` to prompt relogin.
- **Error pattern**: `ResponseValue.success` boolean + `errmsg` field for failure details.
- **Regenerating serializers**: `flutter pub run build_runner build --delete-conflicting-outputs` after model changes.

### Offline-First Repository Layer (In Progress)
- **Database**: `lib/data/local/offline_database.dart` (sqflite) stores work orders, sections, execution data, pending actions, materials, snapshots. Current schema version: 10.
- **Repositories**: 
  - `lib/data/repository/work_order_repository.dart` — list-level operations (My Tasks, Self Finding), caching, offline mode flags.
  - `lib/data/repository/work_order_detail_repository.dart` — sections, execution, complaint details, images; queues mutations for later sync.
- **Offline mode flow**: Enable offline → fetch + cache sections → close app → reopen in airplane mode → load from cache. All mutations queued in `work_order_pending_actions` table.
- **Status**: Phase 1 (local storage + repository layer) complete; Phase 2 (selective download) and Phase 3 (sync engine) pending.

---

## 🧱 State Management Patterns

### House BLoC Pattern (Storekeeper Example)
- **Base class**: `lib/controller/Storekeeper/utils/bloc/bloc.dart` defines:
  - `_errMsg` and `_loadingState` streams (auto-managed via `checker(...)`).
  - `checker(Future)` method wraps async work, sets loading=true, catches errors to `errMsg` stream, then sets loading=false.
- **Feature BLoC example**: `bloc_task.dart` → `MaterialTask` extends `Bloc`, exposes `materials$` and `detail$` streams, wraps API calls with `checker(...)`.
- **UI consumption**: `StreamBuilder(stream: _bloc.materials$, ...)` listens to data; show spinner on `_bloc.loadingState$`, display toast on `_bloc.err$`.

### WorkOrder BLoC Pattern
- **`lib/controller/WorkOrder/bloc/mainBloc.dart`**: Uses multiple `BehaviorSubject` streams seeded with default values:
  - `_sections` (List<WorkOrderStatus>) seeded with `[]`.
  - `_execution`, `_offlineMode`, `_pendingActions`, `_snapshot`.
- **Initialization**: Loads cached data immediately, then optionally refreshes from network (unless `forcedOffline=true`).
- **Stream updates**: Always use `sink.add(newValue)` to publish state changes.

---

## 🎨 UI & Design Conventions

### Color Palette Sources
- **Global**: `lib/utils/reference.dart` → `AppColors`, `getButtonBgColorByStatus(...)` (work order status colors).
- **Storekeeper**: `lib/controller/Storekeeper/utils/constant.dart` → `colorTheme1` (teal), `colorTheme2` (blue), `colorTheme3` (dark blue), etc.
- **Variant-aware**: Use `Color(AppConfig.themeConfig['primaryColor'])` for branding-sensitive UI elements.

### Typography & Components
- **Fonts**: Google Fonts (`GoogleFonts.poppins(...)`) for modern text; Avenir (`fonts/Avenir-Roman.otf`) as fallback.
- **Dialogs**: Reuse `CustomDialog` from `controller/Storekeeper/utils/widget/dialog.dart` (handles max length, toast messaging, double confirmation).
- **Toasts**: Use `toast` package; initialize with `ToastContext().init(context)` in `initState` or `didChangeDependencies`.

### Image Handling
- **Local assets**: Glob pattern `assets/` in `pubspec.yaml`; add files to `assets/` folder.
- **Network images**: Use `photo_view` package for zoom/pan (already imported).
- **Compression**: Apply `flutter_image_compress` before uploading images to reduce payload size.
- **System Pickers**: **ALWAYS use `BiometricLockManager` wrapper** when opening camera/gallery/file pickers to prevent unwanted biometric prompts:
  ```dart
  // ✅ CORRECT: Use wrapper to suppress biometric lock
  import 'package:GEMS/utils/biometric_lock_manager.dart';
  
  final picked = await BiometricLockManager.pickImage(
    source: ImageSource.camera,
    imageQuality: 85,
  );
  
  // ❌ WRONG: Direct ImagePicker call triggers biometric prompt
  final picked = await ImagePicker().pickImage(source: ImageSource.camera);
  ```
- **Why?** Opening native pickers causes app pause → resume, triggering biometric re-auth. Users find this confusing since they "never left the app". See `BIOMETRIC_UX_FIX.md` for full details.

---

## 🧪 Development Workflow

### Local Development
```bash
# Install dependencies
flutter pub get

# Run classic variant
flutter run --dart-define=APP_VARIANT=classic

# Run client variant (premium features)
flutter run --dart-define=APP_VARIANT=client

# Analyze code
flutter analyze

# Run tests (sparse coverage; add tests as needed)
flutter test
```

### Building for Release
```bash
# Build classic Android bundle for Play Store
./build_variants.sh classic-aab

# Build client Android bundle
./build_variants.sh client-aab

# Build both Android variants
./build_variants.sh all-android

# Build iOS (opens Xcode workspace)
./build_variants.sh classic-ios

# Clean artifacts
./build_variants.sh clean
```

### Debugging Offline Features
- **Logs**: Added comprehensive `debugPrint(...)` statements in repositories and BLoCs; watch console for cache hits, offline mode state, section counts.
- **Test scenarios**: See `test/offline_reopen_scenario_test.dart` for end-to-end offline simulation.
- **Database inspection**: Use Flutter DevTools → Database Inspector to query `gems_offline.db` tables.

---

## 🔧 Common Tasks & Patterns

### Adding a New Feature
1. **Create controller folder**: `lib/controller/<Feature>/` for screens and BLoCs.
2. **Define route constant**: Add to `main.dart`'s route switch or Storekeeper constants if inventory-related.
3. **Create BLoC**: Extend `Bloc` base class, expose streams, wrap API calls with `checker(...)`.
4. **UI screen**: Use `StreamBuilder` for reactive state, initialize toast context, handle loading/error states.
5. **Register route**: Add case in `main.dart`'s `onGenerateRoute`.

### Making API Calls
```dart
// GET request
Provider provider = Provider(fetchURL: "/wo_v2/section_assign/", taskID: woTaskId);
await provider.init(); // Sets token + deviceID
ResponseValue response = await provider.fetch();

// POST request
Provider provider = Provider(fetchURL: "/api/m_wo.php");
await provider.post(url: "/api/m_wo.php", body: {"action": "submit", "data": jsonData});
```

### Adding a New Model
1. **Create model**: `lib/model/my_model.dart` with `built_value` annotations.
2. **Register serializer**: Add to `lib/model/serializers.dart`.
3. **Generate code**: `flutter pub run build_runner build --delete-conflicting-outputs`.
4. **Commit `.g.dart`**: Always commit generated files to repo.

### Updating App Icon/Name
- **Icon**: Replace `assets/app_icon.jpg` (1024x1024), run `flutter pub run flutter_launcher_icons`.
- **App name**: Edit `android/app/src/main/AndroidManifest.xml` (Android) and `ios/Runner/Info.plist` (iOS).
- **Variant display name**: Update `AppConfig.appDisplayName` in `lib/config/app_config.dart`.

---

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


## 🗂️ Offline Implementation Status

### ✅ Completed Features

**Phase 1 – Foundation & Core Flows (100% Complete)**
- ✅ Sqflite database with 15 tables (schema v10): headers, sections, execution, materials, images, snapshots, pending actions
- ✅ Repository layer with cache-first pattern for all major data types
- ✅ Offline mode toggle UI in `complaintSection_v2.dart` with eligibility check (In Progress/WR Check only)
- ✅ Snapshot system: downloads full WO state (sections, execution, materials, images, dropdowns) for offline reference
- ✅ BehaviorSubject streams in `MainBloc` for reactive UI updates (`offlineMode$`, `pendingActions$`, `snapshot$`)

**Phase 2 – Mutation Queue (100% Complete)**
- ✅ Generic pending action queue with automatic network/offline detection
- ✅ **Technician Assignment**: `submitAssign`, `saveRepairWork`, `saveAssetNumber`
- ✅ **Assistant Management**: `addAssistant`, `removeAssistant`, `submitAssistantList` (with optimistic queue cancellation)
- ✅ **Materials Management**: `addMaterial`, `updateMaterial`, `deleteMaterial`, `submitMaterialRequest`, `resetMaterialRequest`
- ✅ **Image Uploads**: `uploadRepairImage`, `uploadResponseImage`, `deleteResponseImage`, `saveRepairImageDescriptions`
- ✅ **Verification Actions**: `submitVerified`, `reject`, `rejectOutOfScope`, `reOpenWorkOrder`
- ✅ Pending action display in UI showing count and "Queued" feedback messages

**Phase 3 – Sync Engine (90% Complete)**
- ✅ `syncPendingActions()` replays queued actions on network restore
- ✅ Automatic sync attempt before every mutation when online
- ✅ Socket/timeout exception handling to prevent sync failures from breaking UX
- ✅ Manual sync trigger via `MainBloc.retryPendingSync()`
- ⚠️ **Missing**: Conflict detection (no version metadata or ETag checks yet)
- ⚠️ **Missing**: Retry backoff strategy (currently stops on first failure)

**Phase 4 – Data Caching (95% Complete)**
- ✅ Sections with cache-first + background refresh pattern
- ✅ Execution model caching
- ✅ Complaint details caching
- ✅ Materials (groups, types, parts) with scoped caching
- ✅ Repair/response images cached in DB
- ✅ Technician assignment + dropdown options cached in snapshots
- ⚠️ **Missing**: Image binary caching (currently only metadata; actual files not stored offline)

### 🚧 Pending / Incomplete Features

**User Experience Gaps**
- ❌ **No visual indicator for queued vs synced state per action**: Users can't see which specific changes are pending
- ❌ **No conflict resolution UI**: If backend rejects a queued action, no user-facing flow to handle it
- ❌ **No "available offline" filter in My Tasks list**: Hard to find which WOs are cached (list shows `isOffline` flag but no UI filter)
- ❌ **No storage management screen**: Can't see cache size, clear old WOs, or manage offline quota

**Sync Engine Limitations**
- ❌ **No exponential backoff**: After first sync failure, it stops trying (should retry with increasing delays)
- ❌ **No partial sync progress**: All-or-nothing approach; if one action fails mid-sync, remaining actions stay queued
- ❌ **No conflict detection**: Backend could reject queued changes due to concurrent edits; no version metadata to detect this
- ❌ **No sync progress indicator**: User doesn't know how many actions are being replayed during sync

**Snapshot System Gaps**
- ❌ **No delta sync**: Always downloads full snapshot; should fetch only changed data since last download
- ❌ **No snapshot expiry**: Old snapshots never auto-delete; could accumulate stale data
- ❌ **No snapshot version comparison**: Can't detect if remote WO has changed since snapshot was taken

**Image Handling**
- ❌ **Image files not cached offline**: `uploadResponseImage`/`uploadRepairImage` queue the metadata/base64, but viewing existing images requires network
- ❌ **No image compression during queue**: Large images could bloat pending actions table
- ❌ **No thumbnail generation**: Full-size images downloaded even for list previews

**Security & Data Management**
- ❌ **No automatic cache clear on logout**: Offline data persists after logout (potential data leak)
- ✅ **Biometric UX improved**: System pickers (camera/file) no longer trigger biometric prompt (see `BIOMETRIC_UX_FIX.md`)
- ⚠️ **Partial biometric wipe on failure**: Failed biometric auth doesn't trigger cache wipe (separate concern)
- ❌ **No encryption at rest**: SQLite database stores sensitive WO data unencrypted

**Testing & Monitoring**
- ✅ Basic offline scenario tests exist (`test/offline_reopen_scenario_test.dart`)
- ❌ **No sync replay tests**: Queue mechanism not covered by automated tests
- ❌ **No conflict scenario tests**: How does system behave when backend rejects queued changes?
- ❌ **No performance tests**: Large pending action queues (100+ items) not tested
- ❌ **No analytics/telemetry**: Can't track offline adoption, sync success rates, or common failure modes

### 📊 Completion Summary

| Category | Completion | Notes |
|----------|------------|-------|
| **Local Storage** | 100% | All tables, indexes, CRUD operations complete |
| **Repository Layer** | 100% | Cache-first pattern for all data types |
| **Offline Toggle UI** | 100% | Enable/disable, eligibility checks, feedback messages |
| **Snapshot System** | 85% | Downloads full state; missing delta sync, expiry |
| **Mutation Queue** | 100% | All WO actions (assign, materials, images, verify) queueable |
| **Sync Engine** | 75% | Basic replay works; missing backoff, conflicts, progress |
| **Image Caching** | 40% | Metadata cached; binary files not cached |
| **UX Polish** | 50% | Basic flows work; missing filters, conflict UI, storage mgmt |
| **Security** | 30% | No encryption, no auto-wipe |
| **Testing** | 40% | Basic tests exist; sync/conflict scenarios untested |
| **Overall** | **75%** | Core offline mode functional; production-ready needs polish |

### 🎯 Recommended Next Steps (Priority Order)

1. **Critical**: Implement cache wipe on logout/biometric failure (security issue)
2. **High**: Add exponential backoff to sync engine (prevents battery drain from retry storms)
3. **High**: Add "Available Offline" filter to My Tasks list (discoverability)
4. **High**: Implement partial sync (don't stop entire sync on single action failure)
5. **Medium**: Add per-action sync status UI (show which changes are queued)
6. **Medium**: Implement snapshot expiry (prevent stale data accumulation)
7. **Medium**: Add conflict detection via version metadata/ETags
8. **Medium**: Cache image binaries for true offline viewing
9. **Low**: Build storage management screen
10. **Low**: Add comprehensive sync/conflict tests

### 🔍 Known Issues

- **Snapshot download can fail silently**: If network drops mid-download, offline mode flag is set but cache is incomplete
- **No indication when sync is running**: User can trigger multiple syncs simultaneously
- **Pending action count doesn't update in real-time**: Requires manual refresh after sync
- **Material dropdown caching is scope-limited**: If user navigates to new WO while offline, dropdowns won't be available

---

## 🚫 Constraints & Guidelines

### Do NOT Create Test/Debug Files Unless Necessary
- Avoid creating throwaway test files or troubleshooting scripts.
- If a test file is created for diagnostics, delete it immediately after gathering needed info.
- **Think before implementing**: Consider existing patterns, reusable components, and minimal viable changes.

### Preserve Existing Patterns
- **BLoC lifecycle**: Always dispose streams in `dispose()` method.
- **Toast initialization**: Never skip `ToastContext().init(context)` before showing toasts.
- **Navigation**: Use named routes (`Navigator.pushNamed`) for Storekeeper flows; `MaterialPageRoute` is acceptable for simple navigations.
- **Device ID header**: Do not remove or modify `deviceid` header; backend relies on it for session validation.

### Backend Integration Notes
- **Endpoint versioning**: Mix of legacy (`/api/m_wo.php`) and v2 (`/wo_v2/*`) endpoints; do not assume consistency.
- **Response formats**: Some endpoints return `{"result": [...]}`, others return `{"result": "JSON_STRING"}` (double-encoded); `Provider.fetch()` handles both.
- **Session tokens**: Stored in `User` object via `User.getPrefUser`; refreshed on login, cleared on logout/session expiry.

---

## 📚 Key Files & Directories Reference

| Path | Purpose |
|------|---------|
| `lib/main.dart` | App entry, Firebase init, route registry, biometric auth, lifecycle handling |
| `lib/config/app_config.dart` | Variant configuration (classic/client), feature flags, theme |
| `lib/utils/network.dart` | HTTP provider, auth headers, session expiry detection |
| `lib/utils/biometric_lock_manager.dart` | **NEW**: Suppress biometric prompts for system pickers |
| `lib/data/local/offline_database.dart` | Sqflite schemas, CRUD operations, offline cache |
| `lib/data/repository/*.dart` | Repository pattern for WorkOrder lists & details |
| `lib/controller/WorkOrder/bloc/mainBloc.dart` | WorkOrder detail state management |
| `lib/controller/Storekeeper/utils/bloc/bloc.dart` | Base BLoC with loading/error streams |
| `lib/controller/Storekeeper/utils/constant.dart` | Storekeeper route names, color palette |
| `lib/model/*.dart` | Built_value models, serializers |
| `build_variants.sh` | Build script for classic/client variants |
| `README.md` | Build, deploy, maintenance guide |
| `VARIANTS_GUIDE.md` | Detailed variant system documentation |
| `OFFLINE_DEBUG_GUIDE.md` | Debugging offline features |
| `BIOMETRIC_UX_FIX.md` | **NEW**: Biometric UX improvements, migration guide |
| `OFFLINE_IMAGE_SYNC_BUG.md` | **NEW**: Image sync bug investigation & fix |

---

## 🔍 Quick Navigation Tips

- **Find API endpoint usage**: Search for `/wo_v2/`, `/api/m_wo.php`, `/wo_parts/` across codebase.
- **Locate BLoC pattern examples**: Check `lib/controller/Storekeeper/utils/bloc/bloc_task.dart` (MaterialTask).
- **Understand routing**: Start at `main.dart`'s `onGenerateRoute`, then check feature-specific constants.
- **Debug offline issues**: Enable verbose logging, check `OfflineDatabase` queries, verify `forcedOffline` flag state.
- **Feature flag usage**: Search `AppConfig.features` to see gated functionality.

---

## 📦 Return Item Module (Production Ready)

> **Status**: ✅ Implementation Complete | Ready for QA Testing  
> **Created**: 9 November 2025 | **Completed**: 10 November 2025  
> **API Docs**: See `MATERIAL_ITEM_API.md` | **Testing Guide**: See `RETURN_ITEM_TESTING_GUIDE.md`

### Business Requirements
- **Technicians** can return items previously collected from storekeeper
- **Partial returns supported**: Can return items in batches (e.g., return 2 now, 3 later from 5 collected)
- **Two-step workflow**: Technician initiates return → Storekeeper confirms receipt
- **Status tracking**: Collected (36) → Return Pending → Completed (status 47 in ast_part_sub)
- **Inventory impact**: Items added back to stock after storekeeper confirmation (updates `part_locked`)
- **WO-agnostic**: Returns not tied to specific Work Orders; shows all collected items across all WOs
- **Instance tracking**: Uses `ast_part_sub` table with FIFO logic for granular part tracking

### API Endpoints (Production)
**Base URL**: `https://gems.metadatasystem.my/api/m_inventory.php`
1. **Technician**: 
   - `GET /return_eligible_items/:userId` - List items available to return
   - `POST /request_return` - Submit return request (supports partial quantities)
   - `GET /return_history?userId=&status=&dateFrom=&dateTo=` - View return history
   - `GET /return_statistics?userId=` - Get return metrics
2. **Storekeeper**: 
   - `GET /storekeeper_pending_returns` - List pending returns
   - `GET /return_detail/:returnId` - Get return details
   - `PUT /confirm_return/:returnId` - Confirm receipt & update inventory (transaction-safe)

### Mobile Implementation (Complete)
**Models & Data Layer**:
- ✅ `lib/model/return_item.dart` → 3 built_value models (CollectedItem, ReturnRequest, PendingReturn)
- ✅ `lib/model/serializers.dart` → Models registered for JSON deserialization
- ✅ `lib/model/return_item.g.dart` → Generated serializers (16 outputs)

**State Management**:
- ✅ `lib/controller/ReturnItem/bloc/bloc_return.dart` → BLoC with 6 API methods, 3 streams
- ✅ Methods: loadCollectedItems, submitReturn, loadPendingReturns, getReturnDetail, confirmReturn, getStatistics
- ✅ Streams: collectedItems$, pendingReturns$, pendingCount$ (for badge)

**UI Screens (4 screens, ~2,600 lines)**:
- ✅ `return_item_list.dart` (345 lines) - Technician: List collected items with quantity chips, pending badges, pull-to-refresh
- ✅ `return_item_detail.dart` (465 lines) - Technician: Form with validation, reason dropdown, optional remarks/deadline
- ✅ `return_confirm_list.dart` (456 lines) - Storekeeper: Pending returns with priority indicators, technician info, time ago chips
- ✅ `return_confirm_detail.dart` (656 lines) - Storekeeper: Full details, confirm button with dialog, timeline

**Navigation & Integration**:
- ✅ `lib/main.dart` → 4 routes registered (/return-item-list, /return-item-detail, /return-confirm-list, /return-confirm-detail)
- ✅ `lib/view/drawer.dart` → Technician menu item "Return Items" added
- ✅ `lib/controller/Storekeeper/route/storekeeper/homepage.dart` → Badge icon in AppBar with live count

### Key Features Implemented
- ✅ **Partial returns**: Full support - can return items in batches with quantity validation
- ✅ **Return reasons**: 4 predefined options (unused_excess, wrong_part, damaged, other) with color coding
- ✅ **Validation**: Client-side checks (empty, zero, exceeds available) with toast feedback
- ✅ **Inventory update**: Transaction-safe after storekeeper confirmation
- ✅ **Real-time badge**: Storekeeper sees live pending count via stream
- ✅ **Confirmation dialogs**: Both technician submit and storekeeper confirm require confirmation
- ✅ **Loading states**: Spinners during API calls, disabled buttons, pull-to-refresh
- ✅ **Empty states**: "No Collected Items" (technician), "All Caught Up!" (storekeeper)
- ✅ **Error handling**: Toast messages for all error scenarios
- ✅ **UI/UX polish**: Priority indicators, color-coded reasons, time ago chips, responsive design
- ✅ **Access control**: All technicians (role 8) and storekeepers (role 16) have access
- ✅ **Return deadline**: Optional informational field (not enforced)
- ✅ **Instance tracking**: Uses `ast_part_sub` table with FIFO logic

### Implementation Timeline (Estimated 6-8 days)
- **Phase 1**: Backend APIs + DB table (2-3 days)
- **Phase 2**: Mobile models + BLoC (1 day)
- **Phase 3**: Technician screens (2 days)
- **Phase 4**: Storekeeper screens (1.5 days)
- **Phase 5**: Polish + testing (1 day)
- **Phase 6**: Optional enhancements (post-MVP)

### Key Patterns to Follow
- **BLoC Pattern**: Extend `Bloc` base class, use `checker(...)` wrapper for async calls
- **Models**: Use `built_value` with serializers, register in `lib/model/serializers.dart`
- **UI Components**: Reuse existing card styles, color palette (`AppColors`), Google Fonts (Poppins)
- **Error Handling**: Toast messages for user feedback, loading indicators during operations
- **API Integration**: Use `Provider` class for all HTTP calls, handle session expiry

### Related Modules
- **WorkOrder Material Flow**: `lib/controller/WorkOrder/complaintSectionD_material.dart` (technician requests materials)
- **Storekeeper Task Flow**: `lib/controller/Storekeeper/utils/bloc/bloc_task.dart` (approve, reserve, checkout)
- **Inventory Tracking**: Backend confirms quantity deduction handled by `/wo_request/check_out_request/` endpoint

### Implementation Notes
- Start implementation only after clarifying open questions above
- Backend team must create `material_returns` table and endpoints first
- Mobile development can proceed with mock data once API contracts defined
- Test full round-trip: technician return request → storekeeper confirm → verify inventory updated

---

**Version**: 1.2 (Updated 9 November 2025)  
**Maintainer**: GEMS Development Team

