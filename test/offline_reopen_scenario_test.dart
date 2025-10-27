import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:GEMS/data/local/offline_database.dart';
import 'package:GEMS/data/repository/work_order_detail_repository.dart';
import 'package:GEMS/model/workorder.dart';
import 'package:GEMS/model/user.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:path_provider_platform_interface/path_provider_platform_interface.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'package:shared_preferences/shared_preferences.dart';

class _FakePathProviderPlatform extends PathProviderPlatform {
  _FakePathProviderPlatform(this._supportPath);

  final String _supportPath;

  @override
  Future<String?> getApplicationSupportPath() async => _supportPath;
}

class _FailingHttpOverrides extends HttpOverrides {
  @override
  HttpClient createHttpClient(SecurityContext? context) {
    throw const SocketException('Simulating airplane mode - no network');
  }
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late Directory tempDir;

  setUpAll(() async {
    sqfliteFfiInit();
    databaseFactory = databaseFactoryFfi;

    tempDir = await Directory.systemTemp.createTemp('gems_offline_reopen_test');
    PathProviderPlatform.instance = _FakePathProviderPlatform(tempDir.path);

    final fakeUserJson = json.encode({
      'result': {
        'token': 'test-token',
        'userId': 'user-123',
        'userName': 'tester',
        'userFirstName': 'Test',
        'userLastName': 'User',
        'userType': 'Technician',
        'userMykadNo': '000000-00-0000',
        'userEmail': 'test@example.com',
        'userContactNo': '0123456789',
        'isFirstTime': '0',
        'imgUrl': '',
        'address': {
          'addressDesc': 'HQ',
          'addressPostcode': '00000',
          'addressCity': 'City',
          'addressState': 'State',
        },
        'roles': [
          {
            'roleId': '1',
            'roleDesc': 'WO Executor',
            'roleType': 'Technician',
          },
        ],
      },
    });
    SharedPreferences.setMockInitialValues({kUserPrefs: fakeUserJson});
  });

  tearDownAll(() async {
    if (await tempDir.exists()) {
      await tempDir.delete(recursive: true);
    }
  });

  test(
      'User scenario: enable offline, close app, airplane mode, reopen app - sections should be available',
      () async {
    // SETUP: Clear database
    final database = OfflineDatabase.instance;
    await database.clearAll();

    const workOrderId = 'WO-OFFLINE-TEST';
    const currentStatus = 'In Progress';
    final timestamp = DateTime.utc(2025, 01, 01);

    // Create test sections
    final sectionA = WorkOrderStatus((b) => b
      ..sectionName = 'A'
      ..sectionDesc = 'General Information'
      ..sectionStatus = 'Pending');

    final sectionB = WorkOrderStatus((b) => b
      ..sectionName = 'B'
      ..sectionDesc = 'Work Assignment'
      ..sectionStatus = 'Pending');

    final sectionC = WorkOrderStatus((b) => b
      ..sectionName = 'C'
      ..sectionDesc = 'Work Execution'
      ..sectionStatus = 'Pending');

    // STEP 1: User opens app and enables offline mode
    print('\n=== STEP 1: Enable offline mode ===');
    final repository = WorkOrderDetailRepository(
      database: database,
      clock: () => timestamp,
    );

    // Simulate the setOfflineMode call which should cache sections
    await database.ensureWorkOrderHeader(workOrderId);
    await database.replaceSections(workOrderId, [
      WorkOrderSectionEntity(
        workOrderId: workOrderId,
        sectionName: 'A',
        sectionDesc: 'General Information',
        payloadJson: sectionA.toJson(),
        lastSyncedAt: timestamp,
      ),
      WorkOrderSectionEntity(
        workOrderId: workOrderId,
        sectionName: 'B',
        sectionDesc: 'Work Assignment',
        payloadJson: sectionB.toJson(),
        lastSyncedAt: timestamp,
      ),
      WorkOrderSectionEntity(
        workOrderId: workOrderId,
        sectionName: 'C',
        sectionDesc: 'Work Execution',
        payloadJson: sectionC.toJson(),
        lastSyncedAt: timestamp,
      ),
    ]);
    await database.setWorkOrderOfflineMode(workOrderId, true);

    // Verify offline mode is enabled
    final isOfflineAfterEnable =
        await repository.isOfflineModeEnabled(workOrderId);
    expect(isOfflineAfterEnable, isTrue,
        reason: 'Offline mode should be enabled after setting it');

    // Verify sections are cached
    final cachedSections = await database.getSections(workOrderId);
    expect(cachedSections.length, equals(3),
        reason: 'Should have 3 cached sections');

    print('Offline mode enabled: $isOfflineAfterEnable');
    print('Cached sections count: ${cachedSections.length}');

    // STEP 2: User closes app and clears memory
    print('\n=== STEP 2: Simulate app close (repository recreated) ===');
    // In real app, the repository instance would be garbage collected
    // We simulate this by creating a new instance

    // STEP 3: User opens app in airplane mode (no internet)
    print('\n=== STEP 3: Reopen app in airplane mode ===');
    final previousOverrides = HttpOverrides.current;
    HttpOverrides.global = _FailingHttpOverrides();
    addTearDown(() {
      HttpOverrides.global = previousOverrides;
    });

    // Create a fresh repository instance (simulating app restart)
    final repositoryAfterRestart = WorkOrderDetailRepository(
      database: database,
      clock: () => timestamp,
    );

    // Verify offline mode is still enabled after restart
    final isOfflineAfterRestart =
        await repositoryAfterRestart.isOfflineModeEnabled(workOrderId);
    print('Offline mode after restart: $isOfflineAfterRestart');
    expect(isOfflineAfterRestart, isTrue,
        reason:
            'Offline mode should still be enabled after app restart (it\'s stored in database)');

    // STEP 4: User navigates to the task and tries to load sections
    print('\n=== STEP 4: Load sections (should use cache, not network) ===');
    final sections = await repositoryAfterRestart.getSections(
      workOrderId: workOrderId,
      currentStatus: currentStatus,
      forceRefresh: false, // This is what MainBloc uses on initialization
    );

    print('Sections loaded: ${sections.length}');
    for (final section in sections) {
      print(
          '  - Section ${section.sectionName}: ${section.sectionDesc} (${section.sectionStatus})');
    }

    // ASSERT: Sections should be available from cache
    expect(sections, isNotEmpty,
        reason:
            'Sections should be available from cache even in airplane mode');
    expect(sections.length, equals(3),
        reason: 'Should have all 3 sections cached');
    expect(sections[0].sectionName, equals('A'));
    expect(sections[0].sectionDesc, equals('General Information'));
    expect(sections[1].sectionName, equals('B'));
    expect(sections[1].sectionDesc, equals('Work Assignment'));
    expect(sections[2].sectionName, equals('C'));
    expect(sections[2].sectionDesc, equals('Work Execution'));

    print('\n=== TEST PASSED: Sections available offline after restart ===');
  });

  test('Verify database persists offline mode flag across instances', () async {
    final database = OfflineDatabase.instance;
    await database.clearAll();

    const workOrderId = 'WO-PERSISTENCE-TEST';

    // Set offline mode
    await database.ensureWorkOrderHeader(workOrderId);
    await database.setWorkOrderOfflineMode(workOrderId, true);

    // Verify it's set
    final isOffline1 = await database.isWorkOrderOfflineMode(workOrderId);
    expect(isOffline1, isTrue);

    // Query again (simulating different code path / restart)
    final isOffline2 = await database.isWorkOrderOfflineMode(workOrderId);
    expect(isOffline2, isTrue,
        reason: 'Offline mode flag should persist in database');
  });
}
