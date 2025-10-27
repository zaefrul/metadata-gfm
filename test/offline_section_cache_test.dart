import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:GEMS/data/local/offline_database.dart';
import 'package:GEMS/data/repository/work_order_detail_repository.dart';
import 'package:GEMS/model/workorder.dart';
import 'package:GEMS/main.dart';
import 'package:GEMS/controller/WorkOrder/bloc/mainBloc.dart';
import 'package:GEMS/model/user.dart';
import 'package:flutter/material.dart';
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
    throw const SocketException('Network access disabled in test');
  }
}

class _FakeBuildContext extends Fake implements BuildContext {}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late Directory tempDir;

  setUpAll(() async {
    sqfliteFfiInit();
    databaseFactory = databaseFactoryFfi;

    tempDir = await Directory.systemTemp.createTemp('gems_offline_test');
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

  test('offline sections are served from cache when offline mode is enabled',
      () async {
    final database = OfflineDatabase.instance;
    await database.clearAll();

    const workOrderId = 'WO-123';
    final timestamp = DateTime.utc(2025, 01, 01);
    final status = WorkOrderStatus((b) => b
      ..sectionName = 'A'
      ..sectionDesc = 'General'
      ..sectionStatus = 'Pending');

    await database.ensureWorkOrderHeader(workOrderId);
    await database.replaceSections(workOrderId, [
      WorkOrderSectionEntity(
        workOrderId: workOrderId,
        sectionName: 'A',
        sectionDesc: 'General',
        payloadJson: status.toJson(),
        lastSyncedAt: timestamp,
      ),
    ]);

    await database.setWorkOrderOfflineMode(workOrderId, true);

    final repository = WorkOrderDetailRepository(
      database: database,
      clock: () => timestamp,
    );

    final sections = await repository.getSections(
      workOrderId: workOrderId,
      currentStatus: 'In Progress',
    );

    expect(sections, isNotEmpty);
    expect(sections.first.sectionName, equals('A'));
    expect(sections.first.sectionDesc, equals('General'));
  });

  test('MainBloc emits cached sections when reopening offline task', () async {
    final database = OfflineDatabase.instance;
    await database.clearAll();

    const workOrderId = 'WO-456';
    final timestamp = DateTime.utc(2025, 01, 01);
    final status = WorkOrderStatus((b) => b
      ..sectionName = 'B'
      ..sectionDesc = 'Safety'
      ..sectionStatus = 'In Progress');

    await database.ensureWorkOrderHeader(workOrderId);
    await database.replaceSections(workOrderId, [
      WorkOrderSectionEntity(
        workOrderId: workOrderId,
        sectionName: 'B',
        sectionDesc: 'Safety',
        payloadJson: status.toJson(),
        lastSyncedAt: timestamp,
      ),
    ]);
    await database.setWorkOrderOfflineMode(workOrderId, true);

    final repository = WorkOrderDetailRepository(
      database: database,
      clock: () => timestamp,
    );
    final preflightSections = await repository.getSections(
      workOrderId: workOrderId,
      currentStatus: 'In Progress',
    );
    expect(preflightSections, isNotEmpty);
    expect(await repository.isOfflineModeEnabled(workOrderId), isTrue);

    final bloc = MainBloc(
      id: workOrderId,
      status: 'In Progress',
      taskNo: 'WO-456',
      context: _FakeBuildContext(),
      woTaskCategory: 'Client Complaint',
      repository: repository,
    );
    addTearDown(bloc.dispose);

    final sections = await bloc.sections$
        .firstWhere((value) => value.isNotEmpty)
        .timeout(const Duration(seconds: 2));

    expect(sections, isNotEmpty);
    expect(sections.first.sectionName, equals('B'));
    expect(sections.first.sectionDesc, equals('Safety'));
  });

  test('getSections falls back to cache when remote refresh fails', () async {
    final database = OfflineDatabase.instance;
    await database.clearAll();

    const workOrderId = 'WO-789';
    final timestamp = DateTime.utc(2025, 01, 01);
    final status = WorkOrderStatus((b) => b
      ..sectionName = 'C'
      ..sectionDesc = 'Logistics'
      ..sectionStatus = 'Pending');

    await database.ensureWorkOrderHeader(workOrderId);
    await database.replaceSections(workOrderId, [
      WorkOrderSectionEntity(
        workOrderId: workOrderId,
        sectionName: 'C',
        sectionDesc: 'Logistics',
        payloadJson: status.toJson(),
        lastSyncedAt: timestamp,
      ),
    ]);

    final previousOverrides = HttpOverrides.current;
    HttpOverrides.global = _FailingHttpOverrides();
    addTearDown(() {
      HttpOverrides.global = previousOverrides;
    });

    final repository = WorkOrderDetailRepository(
      database: database,
      clock: () => timestamp,
    );

    final sections = await repository.getSections(
      workOrderId: workOrderId,
      currentStatus: 'In Progress',
      forceRefresh: true,
    );

    expect(sections, isNotEmpty);
    expect(sections.first.sectionName, equals('C'));
    expect(sections.first.sectionDesc, equals('Logistics'));
  });
}
