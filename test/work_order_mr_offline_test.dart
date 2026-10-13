import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:GEMS/controller/WorkOrder/complaintSection_v2.dart';
import 'package:GEMS/controller/WorkOrder/mrRequest.dart';
import 'package:GEMS/data/local/offline_database.dart';
import 'package:GEMS/data/repository/work_order_detail_repository.dart';
import 'package:GEMS/main.dart';
import 'package:GEMS/model/complaint.dart';
import 'package:GEMS/model/execution.dart';
import 'package:GEMS/model/user.dart';
import 'package:GEMS/model/workorder.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:google_fonts/src/google_fonts_base.dart' as google_fonts_base;
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:path_provider_platform_interface/path_provider_platform_interface.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

class _FakePathProviderPlatform extends PathProviderPlatform {
  _FakePathProviderPlatform(this._supportPath);

  final String _supportPath;

  @override
  Future<String?> getApplicationSupportPath() async => _supportPath;
}

class _ScriptedRepository extends WorkOrderDetailRepository {
  _ScriptedRepository() : super(database: OfflineDatabase.instance);

  bool offline = false;
  int pending = 0;
  List<WorkOrderStatus> sections = const [];
  WorkOrderSnapshotData? snapshot;
  int syncCalls = 0;
  int downloadCalls = 0;
  Object? enableError;

  @override
  Future<bool> isOfflineModeEnabled(String workOrderId) async => offline;

  @override
  Future<int> pendingActionCount({String? workOrderId}) async => pending;

  @override
  Future<void> syncPendingActions() async {
    syncCalls++;
  }

  @override
  Future<WorkOrderSnapshotData?> loadSnapshot(String workOrderId) async =>
      snapshot;

  @override
  Future<List<WorkOrderStatus>> getSections({
    required String workOrderId,
    required String currentStatus,
    bool forceRefresh = false,
    void Function(List<WorkOrderStatus>)? onRemoteUpdate,
  }) async {
    return sections;
  }

  @override
  Future<ExecutionModel?> getExecution({
    required String workOrderId,
    bool forceRefresh = false,
    void Function(ExecutionModel)? onRemoteUpdate,
  }) async {
    return null;
  }

  @override
  Future<void> setOfflineMode({
    required String workOrderId,
    required bool enabled,
    String? currentStatus,
  }) async {
    if (enabled && enableError != null) {
      throw enableError!;
    }
    offline = enabled;
    if (enabled && snapshot == null) {
      snapshot = _snapshotFor(workOrderId);
    }
  }

  @override
  Future<WorkOrderSnapshot> downloadSnapshot({
    required String workOrderId,
    required String currentStatus,
  }) async {
    downloadCalls++;
    snapshot ??= _snapshotFor(workOrderId);
    return snapshot!.snapshot;
  }

  WorkOrderSnapshotData _snapshotFor(String workOrderId) {
    final createdAt = DateTime(2026, 3, 2, 8, 30);
    return WorkOrderSnapshotData(
      snapshot: WorkOrderSnapshot(
        metadata: WorkOrderSnapshotEntity(
          snapshotId: 'snap-$workOrderId',
          workOrderId: workOrderId,
          createdAt: createdAt,
        ),
        sections: const [],
      ),
      sections: sections,
      materials: const [],
      materialGroups: const [],
      repairImages: const [],
      responseImages: const [],
    );
  }
}

RequestTask _task({
  required String requestNo,
  required String statusId,
  String? checkpoint,
}) {
  return RequestTask((builder) {
    builder
      ..woTaskRequestNo = requestNo
      ..statusId = statusId
      ..checkpointDesc = checkpoint
      ..requestBy = 'aiman';
  });
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUpAll(() async {
    await _installFontCache();
    sqfliteFfiInit();
    databaseFactory = databaseFactoryFfi;
    PathProviderPlatform.instance =
        _FakePathProviderPlatform('/tmp/gems_wo_mr_offline_test');

    SharedPreferences.setMockInitialValues({
      kUserPrefs: json.encode({
        'result': {
          'token': 'test-token',
          'userId': 'user-aiman',
          'userName': 'aiman',
          'userFirstName': 'Aiman',
          'userLastName': 'Test',
          'userType': 'Technician',
          'userMykadNo': '000000-00-0000',
          'userEmail': 'aiman@example.com',
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
              'roleId': '27',
              'roleDesc': 'MR Reviewer',
              'roleType': 'Reviewer',
            },
          ],
        },
      }),
    });
  });

  group('MR Approval status labels', () {
    test('Review is status 33 at the MR Reviewer checkpoint', () {
      final review = _task(
        requestNo: 'RV-1',
        statusId: '33',
        checkpoint: 'MR Reviewer',
      );
      final approval = _task(
        requestNo: 'AP-1',
        statusId: '33',
        checkpoint: 'Supervisor',
      );

      expect(MRTaskList.statusLabelFor(review), 'Review');
      expect(MRTaskList.statusLabelFor(approval), 'Request Approval');
    });

    test('every mapped status keeps its own label', () {
      const expected = {
        '32': 'Request Parts',
        '33': 'Request Approval',
        '34': 'Stock Request',
        '38': 'Ready For Collection',
        '36': 'Parts Collected',
        '47': 'Need to Order',
        '48': 'Waiting for Purchase',
      };

      expected.forEach((id, label) {
        final task = _task(requestNo: id, statusId: id);
        expect(MRTaskList.statusLabelFor(task), label, reason: 'status $id');
      });
    });

    test('MR Reviewer checkpoint does not relabel Stock Request', () {
      final task = _task(
        requestNo: 'SR-X',
        statusId: '34',
        checkpoint: 'MR Reviewer',
      );
      expect(MRTaskList.statusLabelFor(task), 'Stock Request');
    });

    test('unknown status id is labeled Unknown', () {
      expect(
        MRTaskList.statusLabelFor(_task(requestNo: 'U', statusId: '99')),
        'Unknown',
      );
    });
  });

  group('MR Approval filter', () {
    late Controller controller;
    late List<String> visibleNumbers;
    late String dropdownLabel;
    StreamSubscription<List<RequestTask>>? _tasksSub;
    StreamSubscription<String>? _dropdownSub;

    setUp(() {
      final tasks = [
        _task(requestNo: 'SR-1', statusId: '34'),
        _task(requestNo: 'SR-2', statusId: '34'),
        _task(
          requestNo: 'RV-1',
          statusId: '33',
          checkpoint: 'MR Reviewer',
        ),
        _task(
          requestNo: 'AP-1',
          statusId: '33',
          checkpoint: 'Supervisor',
        ),
        _task(requestNo: 'PT-1', statusId: '32'),
      ];
      controller = Controller.seeded(tasks);
      visibleNumbers = const [];
      dropdownLabel = 'All Status';
      _tasksSub = controller.filteredTaskStream.listen((tasks) {
        visibleNumbers =
            tasks.map((task) => task.woTaskRequestNo ?? '').toList();
      });
      _dropdownSub =
          controller.dropdownValueStream.listen((label) => dropdownLabel = label);
    });

    tearDown(() async {
      await _tasksSub?.cancel();
      await _dropdownSub?.cancel();
      controller.dispose();
    });

    test('All Status keeps the full list', () async {
      controller.filter('All Status');
      await _flush();
      expect(visibleNumbers, ['SR-1', 'SR-2', 'RV-1', 'AP-1', 'PT-1']);
    });

    test('Stock Request keeps only status 34', () async {
      controller.filter('Stock Request');
      await _flush();
      expect(visibleNumbers, ['SR-1', 'SR-2']);
    });

    test('Review keeps the MR Reviewer card', () async {
      controller.filter('Review');
      await _flush();
      expect(visibleNumbers, ['RV-1']);
    });

    test('Request Approval does not include the Review card', () async {
      controller.filter('Request Approval');
      await _flush();
      expect(visibleNumbers, ['AP-1']);
    });

    test('switching filters does not leave the previous match behind', () async {
      controller.filter('Review');
      await _flush();
      expect(visibleNumbers, ['RV-1']);
      controller.filter('Stock Request');
      await _flush();
      expect(visibleNumbers, ['SR-1', 'SR-2']);
      controller.filter('Request Parts');
      await _flush();
      expect(visibleNumbers, ['PT-1']);
      controller.filter('All Status');
      await _flush();
      expect(visibleNumbers, ['SR-1', 'SR-2', 'RV-1', 'AP-1', 'PT-1']);
    });

    test('a status with no cards shows an empty list', () async {
      controller.filter('Need to Order');
      await _flush();
      expect(visibleNumbers, isEmpty);
      expect(dropdownLabel, 'Need to Order');
    });

    test('a null filter selection is ignored', () async {
      controller.filter('Review');
      await _flush();
      controller.filter(null);
      await _flush();
      expect(visibleNumbers, ['RV-1']);
      expect(dropdownLabel, 'Review');
    });
  });

  group('MR Approval list', () {
    testWidgets('filtering Review leaves the one Review card', (tester) async {
      final controller = Controller.seeded([
        _task(requestNo: 'SR-1', statusId: '34'),
        _task(requestNo: 'SR-2', statusId: '34'),
        _task(
          requestNo: 'RV-1',
          statusId: '33',
          checkpoint: 'MR Reviewer',
        ),
      ]);
      addTearDown(controller.dispose);

      await tester.pumpWidget(
        MaterialApp(home: Scaffold(body: MRTaskList(controller: controller))),
      );
      await tester.pump();

      expect(find.text('SR-1'), findsOneWidget);
      expect(find.text('SR-2'), findsOneWidget);
      expect(find.text('RV-1'), findsOneWidget);
      expect(find.text('Review'), findsOneWidget);
      expect(find.text('Stock Request'), findsWidgets);

      final dropdown = tester.widget<DropdownButton<String>>(
        find.byType(DropdownButton<String>),
      );
      final choices = dropdown.items!.map((item) => item.value).toList();
      expect(choices, contains('Review'));
      expect(choices, contains('Stock Request'));

      controller.filter('Review');
      await tester.pump();

      expect(find.text('RV-1'), findsOneWidget);
      expect(find.text('SR-1'), findsNothing);
      expect(find.text('SR-2'), findsNothing);
    });

    testWidgets('filtering Stock Request hides the Review card', (tester) async {
      final controller = Controller.seeded([
        _task(requestNo: 'SR-1', statusId: '34'),
        _task(requestNo: 'SR-2', statusId: '34'),
        _task(
          requestNo: 'RV-1',
          statusId: '33',
          checkpoint: 'MR Reviewer',
        ),
      ]);
      addTearDown(controller.dispose);

      await tester.pumpWidget(
        MaterialApp(home: Scaffold(body: MRTaskList(controller: controller))),
      );
      await tester.pump();
      controller.filter('Stock Request');
      await tester.pump();

      expect(find.text('SR-1'), findsOneWidget);
      expect(find.text('SR-2'), findsOneWidget);
      expect(find.text('RV-1'), findsNothing);
    });
  });

  group('Work order offline mode', () {
    Future<void> showTask(
      WidgetTester tester, {
      required _ScriptedRepository repository,
      required bool viewer,
      required String status,
    }) async {
      tester.view.physicalSize = const Size(800, 1400);
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      await tester.pumpWidget(
        MaterialApp(
          navigatorKey: navigatorKey,
          home: ComplaintSection(
            key: UniqueKey(),
            id: 'WO-1',
            taskNo: 'WO-1001',
            siteName: 'Site A',
            taskStatus: status,
            viewer: viewer,
            woTaskType: 'CM',
            woTaskCategory: '',
            repository: repository,
          ),
        ),
      );

      await _pumpUntil(tester, () {
        return find.textContaining('General details').evaluate().isNotEmpty ||
            find.text('No sections available yet.').evaluate().isNotEmpty;
      });
      // Let the offline-mode read finish after the first frame.
      await tester.pump(const Duration(milliseconds: 200));
    }

    testWidgets('My Task shows the icon and hides the bar until offline is on',
        (tester) async {
      final repository = _ScriptedRepository()
        ..sections = [_section('General details')];

      await showTask(tester, repository: repository, viewer: false, status: 'In Progress');

      expect(find.byTooltip('Offline mode'), findsOneWidget);
      expect(find.text('Offline mode on'), findsNothing);

      await tester.tap(find.byTooltip('Offline mode'));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 300));

      expect(find.text('Save this task on the device before you lose connection.'),
          findsOneWidget);
      expect(find.text('Sync now'), findsNothing);

      await tester.tap(find.byType(Switch));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 300));

      expect(repository.offline, isTrue);
      expect(find.text('Offline mode on'), findsOneWidget);
      expect(find.text('Updates stay on this device until you sync.'), findsOneWidget);
      expect(find.textContaining('2 Mar 2026'), findsOneWidget);
      expect(find.text('1 section'), findsOneWidget);
      expect(find.text('0 actions waiting to sync'), findsOneWidget);

      final syncCallsBefore = repository.syncCalls;
      await tester.tap(find.text('Sync now'));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 300));
      expect(repository.syncCalls, syncCallsBefore + 1);

      await tester.tap(find.text('Refresh offline copy'));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 300));
      expect(repository.downloadCalls, 1);

      await tester.tap(find.byType(Switch));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 300));

      expect(repository.offline, isFalse);
      expect(find.text('Offline mode on'), findsNothing);
      expect(find.byTooltip('Offline mode'), findsOneWidget);
      await _settleToasts(tester);
    });

    testWidgets('WR Check can use the same offline control', (tester) async {
      final repository = _ScriptedRepository()
        ..sections = [_section('General details')];

      await showTask(tester, repository: repository, viewer: false, status: 'WR Check');

      expect(find.byTooltip('Offline mode'), findsOneWidget);
      expect(find.text('Offline mode on'), findsNothing);
    });

    testWidgets('pending changes show on the bar and the app bar count',
        (tester) async {
      final repository = _ScriptedRepository()
        ..offline = true
        ..pending = 2
        ..sections = [_section('General details')]
        ..snapshot = null;

      await showTask(tester, repository: repository, viewer: false, status: 'In Progress');

      expect(find.text('Offline mode on'), findsOneWidget);
      expect(find.text('2 to sync'), findsOneWidget);
      expect(find.byTooltip('Offline mode on'), findsOneWidget);
      expect(find.text('2'), findsWidgets);

      await tester.tap(find.text('Offline mode on'));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 300));

      expect(find.text('2 actions waiting to sync'), findsOneWidget);
      expect(find.text('Preparing offline copy…'), findsOneWidget);
      await _settleToasts(tester);
    });

    testWidgets('My Complaint stays view only even when offline is already on',
        (tester) async {
      final repository = _ScriptedRepository()
        ..offline = true
        ..pending = 3
        ..sections = [_section('General details')];

      await showTask(tester, repository: repository, viewer: true, status: 'In Progress');

      expect(find.textContaining('General details'), findsOneWidget);
      expect(find.text('Offline mode on'), findsNothing);
      expect(find.byTooltip('Offline mode'), findsNothing);
      expect(find.byTooltip('Offline mode on'), findsNothing);
      expect(find.byType(Switch), findsNothing);
      await _settleToasts(tester);
    });

    testWidgets('Assign hides the offline control while the task is online',
        (tester) async {
      final repository = _ScriptedRepository()
        ..sections = [_section('General details')];
      await showTask(tester, repository: repository, viewer: false, status: 'Assign');
      expect(find.byTooltip('Offline mode'), findsNothing);
      expect(find.text('Offline mode on'), findsNothing);
      await _settleToasts(tester);
    });

    testWidgets('a task already offline still shows the bar on other statuses',
        (tester) async {
      final repository = _ScriptedRepository()
        ..offline = true
        ..sections = [_section('General details')];
      await showTask(tester, repository: repository, viewer: false, status: 'Assign');
      expect(find.text('Offline mode on'), findsOneWidget);
      expect(find.byTooltip('Offline mode on'), findsOneWidget);
      await _settleToasts(tester);
    });

    testWidgets('the offline bar stays visible when the task has no sections',
        (tester) async {
      final repository = _ScriptedRepository()
        ..offline = true
        ..sections = const [];

      await showTask(tester, repository: repository, viewer: false, status: 'In Progress');

      expect(find.text('No sections available yet.'), findsOneWidget);
      expect(find.text('Offline mode on'), findsOneWidget);
    });

    testWidgets('a failed enable leaves the task online', (tester) async {
      final repository = _ScriptedRepository()
        ..sections = [_section('General details')]
        ..enableError = OfflinePreparationException('Could not cache this task.');

      await showTask(tester, repository: repository, viewer: false, status: 'In Progress');
      await tester.tap(find.byTooltip('Offline mode'));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 200));
      await tester.tap(find.byType(Switch));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 300));

      expect(repository.offline, isFalse);
      expect(find.text('Offline mode on'), findsNothing);
      expect(find.text('Could not cache this task.'), findsOneWidget);
      await _settleToasts(tester);
    });
  });
}

WorkOrderStatus _section(String desc) {
  return WorkOrderStatus((builder) {
    builder
      ..sectionName = 'A'
      ..sectionDesc = desc
      ..sectionStatus = 'Pending';
  });
}

Future<void> _installFontCache() async {
  final packageConfig = File('.dart_tool/package_config.json');
  if (!packageConfig.existsSync()) return;
  final config = json.decode(packageConfig.readAsStringSync()) as Map<String, dynamic>;
  final packages = config['packages'] as List<dynamic>;
  final fonts = packages.cast<Map<String, dynamic>>().firstWhere(
        (package) => package['name'] == 'google_fonts',
      );
  final rootUri = packageConfig.parent.uri.resolve(fonts['rootUri'] as String);
  final root = rootUri.toFilePath();
  final bytesByUrl = <String, List<int>>{};

  for (final family in ['Lato', 'Poppins']) {
    final part = File('$root/lib/src/google_fonts_parts/part_${family[0].toLowerCase()}.g.dart');
    final source = part.readAsStringSync();
    final marker = "fontFamily: '$family'";
    final end = source.indexOf(marker);
    final start = source.lastIndexOf('GoogleFontsFile>{', end);
    final block = source.substring(start, end);
    final hashes = RegExp(r"'([0-9a-f]{64})'").allMatches(block).map((m) => m.group(1)!);
    for (final hash in hashes) {
      final url = 'https://fonts.gstatic.com/s/a/$hash.ttf';
      final result = await Process.run(
        'curl',
        ['-fsSL', url],
        stdoutEncoding: null,
      );
      if (result.exitCode == 0) {
        bytesByUrl[url] = (result.stdout as List<int>);
      }
    }
  }

  google_fonts_base.httpClient = MockClient((request) async {
    final bytes = bytesByUrl[request.url.toString()];
    if (bytes == null) {
      return http.Response('missing font', 404);
    }
    return http.Response.bytes(bytes, 200);
  });
}

Future<void> _flush() => Future<void>.delayed(Duration.zero);

Future<void> _settleToasts(WidgetTester tester) async {
  await tester.pump(const Duration(seconds: 2));
}

Future<void> _pumpUntil(WidgetTester tester, bool Function() ready) async {
  for (var i = 0; i < 40; i++) {
    await tester.pump(const Duration(milliseconds: 50));
    if (ready()) return;
  }
  fail('Timed out waiting for the work order screen');
}
