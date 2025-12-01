import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:GEMS/data/local/offline_database.dart';
import 'package:GEMS/model/complaint.dart';
import 'package:GEMS/model/execution.dart';
import 'package:GEMS/model/response_image.dart';
import 'package:GEMS/model/serializers.dart';
import 'package:GEMS/model/workorder.dart';
import 'package:GEMS/utils/network.dart';
import 'package:flutter/foundation.dart';

import '../../main.dart';

enum WorkOrderActionResult { success, queued }

class OfflinePreparationException implements Exception {
  OfflinePreparationException(this.message);

  final String message;

  @override
  String toString() => message;
}

class WorkOrderDetailRepository {
  WorkOrderDetailRepository({
    OfflineDatabase? database,
    DateTime Function()? clock,
  })  : _database = database ?? OfflineDatabase.instance,
        _clock = clock ?? DateTime.now;

  final OfflineDatabase _database;
  final DateTime Function() _clock;

  static const _materialGroupCategory = 'material_group';
  static const _materialTypeCategory = 'material_type';
  static const _materialPartCategory = 'material_part';

  Future<void> setOfflineMode({
    required String workOrderId,
    required bool enabled,
    String? currentStatus,
  }) async {
    if (enabled) {
      debugPrint(
          'setOfflineMode: Enabling offline for workOrderId=$workOrderId, currentStatus=$currentStatus');
      final status = currentStatus ?? '';
      try {
        await downloadSnapshot(
          workOrderId: workOrderId,
          currentStatus: status,
        );
        await _database.setWorkOrderOfflineMode(workOrderId, true);
      } on OfflinePreparationException {
        await _database.setWorkOrderOfflineMode(workOrderId, false);
        rethrow;
      } catch (err, st) {
        debugPrint('setOfflineMode: Snapshot download failed: $err\n$st');
        await _database.setWorkOrderOfflineMode(workOrderId, false);
        rethrow;
      }
      return;
    }

    await _database.setWorkOrderOfflineMode(workOrderId, false);
    await _database.deleteSnapshotsForWorkOrder(workOrderId);
  }

  Future<bool> isOfflineModeEnabled(String workOrderId) {
    return _database.isWorkOrderOfflineMode(workOrderId);
  }

  Future<WorkOrderSnapshot> downloadSnapshot({
    required String workOrderId,
    required String currentStatus,
  }) async {
    debugPrint(
        'downloadSnapshot: workOrderId=$workOrderId, currentStatus=$currentStatus');
    final createdAt = _clock().toUtc();

    List<WorkOrderStatus> sections = const [];
    Object? sectionError;
    try {
      sections = await _refreshSections(
        workOrderId: workOrderId,
        currentStatus: currentStatus,
      );
      debugPrint(
          'downloadSnapshot: fetched ${sections.length} sections for $workOrderId');
    } catch (err, st) {
      sectionError = err;
      debugPrint('downloadSnapshot: section prefetch failed: $err\n$st');
    }

    if (sections.isEmpty) {
      debugPrint(
          'downloadSnapshot: no sections captured, sectionError=$sectionError');
      const message =
          'We couldn\'t download the work order steps for offline use. Please reconnect and try again.';
      throw OfflinePreparationException(message);
    }

  ExecutionModel? execution;
  WorkOrderDetail? complaintDetail;
  List<TechnicianImageRepair> repairImages = const <TechnicianImageRepair>[];
  List<ResponseImage> responseImages = const <ResponseImage>[];
  List<ComplaintD> materials = const <ComplaintD>[];
  List<ComplaintDGroup> materialGroups = const <ComplaintDGroup>[];
  TechnicianAssign? assignment;
  List<WorkOrderStatus> groupOptions = const <WorkOrderStatus>[];
  List<WorkOrderStatus> severityOptions = const <WorkOrderStatus>[];
  List<WorkOrderStatus> executorOptions = const <WorkOrderStatus>[];
  TechnicianDetails? technicianDetails;
  String? repairWork;
  List<WorkOrderAssistant> assistantOptions = const <WorkOrderAssistant>[];
  List<WorkOrderAssistant> assistantSelected = const <WorkOrderAssistant>[];
  int? maxAssistants;

    try {
      execution = await _refreshExecution(workOrderId: workOrderId);
    } catch (err, st) {
      debugPrint('downloadSnapshot: execution fetch failed: $err\n$st');
    }

    try {
      complaintDetail = await _refreshComplaintDetail(workOrderId: workOrderId);
    } catch (err, st) {
      debugPrint('downloadSnapshot: complaint detail fetch failed: $err\n$st');
    }

    try {
      repairImages = await _refreshRepairImages(workOrderId: workOrderId);
    } catch (err, st) {
      debugPrint('downloadSnapshot: repair image fetch failed: $err\n$st');
    }

    try {
      responseImages = await _refreshResponseImages(workOrderId: workOrderId);
    } catch (err, st) {
      debugPrint('downloadSnapshot: response image fetch failed: $err\n$st');
    }

    try {
      materials = await _refreshMaterials(workOrderId: workOrderId);
    } catch (err, st) {
      debugPrint('downloadSnapshot: material fetch failed: $err\n$st');
    }

    try {
      materialGroups = await _refreshMaterialGroups(workOrderId: workOrderId);
    } catch (err, st) {
      debugPrint('downloadSnapshot: material group fetch failed: $err\n$st');
    }

    try {
      assignment = await _fetchAssignmentRemote(workOrderId);
    } catch (err, st) {
      debugPrint('downloadSnapshot: assignment fetch failed: $err\n$st');
    }

    try {
      groupOptions = await _fetchGroupListRemote(workOrderId);
    } catch (err, st) {
      debugPrint('downloadSnapshot: group list fetch failed: $err\n$st');
    }

    try {
      severityOptions = await _fetchSeverityListRemote(workOrderId);
    } catch (err, st) {
      debugPrint('downloadSnapshot: severity list fetch failed: $err\n$st');
    }

    final assignmentGroupId = assignment?.groupId;
    final assignmentUserId = assignment?.userId;

    if (assignmentGroupId != null && assignmentGroupId.isNotEmpty) {
      try {
        executorOptions = await _fetchTechnicianListRemote(assignmentGroupId);
      } catch (err, st) {
        debugPrint('downloadSnapshot: executor list fetch failed: $err\n$st');
      }
    }

    if (assignmentGroupId != null && assignmentGroupId.isNotEmpty) {
      final userId = assignmentUserId;
      if (userId != null && userId.isNotEmpty) {
        try {
          technicianDetails =
              await _fetchTechnicianDetailsRemote(assignmentGroupId, userId);
        } catch (err, st) {
          debugPrint('downloadSnapshot: technician details fetch failed: $err\n$st');
        }
      }
    }

    try {
      repairWork = await _fetchRepairWorkRemote(workOrderId);
    } catch (err, st) {
      debugPrint('downloadSnapshot: repair work fetch failed: $err\n$st');
    }

    try {
      assistantOptions = await _fetchAssistantDropdownRemote(workOrderId);
    } catch (err, st) {
      debugPrint(
          'downloadSnapshot: assistant dropdown fetch failed: $err\n$st');
    }

    try {
      assistantSelected = await _fetchAssistantSelectedRemote(workOrderId);
    } catch (err, st) {
      debugPrint(
          'downloadSnapshot: assistant selected fetch failed: $err\n$st');
    }

    maxAssistants = _parseMaxAssistants(assignment?.woTaskMaxAssistant);

    final snapshotId = '${workOrderId}_${createdAt.microsecondsSinceEpoch}';
    final sectionEntities = <WorkOrderSnapshotSectionEntity>[];
    for (var index = 0; index < sections.length; index++) {
      final section = sections[index];
      final sectionId = 'section_${index + 1}';
      final sectionName = (section.sectionName?.isNotEmpty ?? false)
          ? section.sectionName
          : 'Section ${index + 1}';
      sectionEntities.add(
        WorkOrderSnapshotSectionEntity(
          snapshotId: snapshotId,
          sectionId: sectionId,
          sectionName: sectionName,
          position: index,
          payloadJson: section.toJson(),
        ),
      );
    }

  final summary = <String, dynamic>{
      'status': currentStatus,
      'downloadedAt': createdAt.toIso8601String(),
      'execution': execution != null ? _executionToJson(execution) : null,
    'complaintDetail':
      complaintDetail != null ? _encodeComplaintDetail(complaintDetail) : null,
    'materials': materials
      .map(_encodeComplaintD)
      .whereType<Map<String, dynamic>>()
      .toList(growable: false),
    'materialGroups': materialGroups
      .map(_encodeComplaintDGroup)
      .whereType<Map<String, dynamic>>()
      .toList(growable: false),
    'repairImages': repairImages
      .map(_encodeTechnicianImageRepair)
      .whereType<Map<String, dynamic>>()
      .toList(growable: false),
      'responseImages':
          responseImages.map((image) => image.toJson()).toList(),
      'assignment':
          assignment != null ? _encodeTechnicianAssign(assignment) : null,
      'groupOptions': groupOptions
          .map(_encodeWorkOrderStatus)
          .whereType<Map<String, dynamic>>()
          .toList(growable: false),
      'severityOptions': severityOptions
          .map(_encodeWorkOrderStatus)
          .whereType<Map<String, dynamic>>()
          .toList(growable: false),
      'executorOptions': executorOptions
          .map(_encodeWorkOrderStatus)
          .whereType<Map<String, dynamic>>()
          .toList(growable: false),
      'technicianDetails': technicianDetails != null
          ? _encodeTechnicianDetails(technicianDetails)
          : null,
      'repairWork': repairWork,
    'assistantOptions': assistantOptions
      .map(_encodeAssistant)
      .whereType<Map<String, dynamic>>()
      .toList(growable: false),
    'selectedAssistants': assistantSelected
      .map(_encodeAssistant)
      .whereType<Map<String, dynamic>>()
      .toList(growable: false),
    'maxAssistants': maxAssistants,
    };
    summary.removeWhere((key, value) => value == null);

    final snapshotEntity = WorkOrderSnapshotEntity(
      snapshotId: snapshotId,
      workOrderId: workOrderId,
      createdAt: createdAt,
      status: currentStatus,
      summaryJson: json.encode(summary),
    );

    await _database.replaceSnapshot(snapshotEntity, sectionEntities);
    debugPrint('downloadSnapshot: snapshot $snapshotId stored for $workOrderId');
    return WorkOrderSnapshot(metadata: snapshotEntity, sections: sectionEntities);
  }

  Future<WorkOrderSnapshot?> getLatestSnapshot(String workOrderId) {
    return _database.getLatestSnapshot(workOrderId);
  }

  Future<WorkOrderSnapshotData?> loadSnapshot(String workOrderId) async {
    final snapshot = await _database.getLatestSnapshot(workOrderId);
    if (snapshot == null) {
      return null;
    }

    final sections = snapshot.sections
        .map(_decodeSnapshotSection)
        .whereType<WorkOrderStatus>()
        .toList(growable: false);

    final summaryMap = _decodeSnapshotSummary(snapshot.metadata.summaryJson);

    final execution = _decodeExecution(summaryMap['execution']);
    final complaintDetail = _decodeComplaintDetail(summaryMap['complaintDetail']);
    final materials = _decodeComplaintDList(summaryMap['materials']);
    final materialGroups = _decodeComplaintDGroupList(summaryMap['materialGroups']);
    final repairImages = _decodeTechnicianImageRepairList(summaryMap['repairImages']);
    final responseImages = _decodeResponseImageList(summaryMap['responseImages']);
    final assignment = _decodeTechnicianAssign(summaryMap['assignment']);
    final groupOptions = _decodeWorkOrderStatusList(summaryMap['groupOptions']);
    final severityOptions =
        _decodeWorkOrderStatusList(summaryMap['severityOptions']);
    final executorOptions =
        _decodeWorkOrderStatusList(summaryMap['executorOptions']);
    final technicianDetails =
        _decodeTechnicianDetails(summaryMap['technicianDetails']);
    final repairWork = _decodeRepairWork(summaryMap['repairWork']);
  final assistantOptions =
    _decodeAssistantList(summaryMap['assistantOptions']);
  final selectedAssistants =
    _decodeAssistantList(summaryMap['selectedAssistants']);
  final maxAssistants = _decodeMaxAssistants(summaryMap['maxAssistants']) ??
    _parseMaxAssistants(assignment?.woTaskMaxAssistant);

    return WorkOrderSnapshotData(
      snapshot: snapshot,
      sections: sections,
      execution: execution,
      complaintDetail: complaintDetail,
      materials: materials,
      materialGroups: materialGroups,
      repairImages: repairImages,
      responseImages: responseImages,
      assignment: assignment,
      groupOptions: groupOptions,
      severityOptions: severityOptions,
      executorOptions: executorOptions,
      technicianDetails: technicianDetails,
      repairWork: repairWork,
      assistantOptions: assistantOptions,
      selectedAssistants: selectedAssistants,
      maxAssistants: maxAssistants,
    );
  }

  Future<List<WorkOrderStatus>> getSections({
    required String workOrderId,
    required String currentStatus,
    bool forceRefresh = false,
    void Function(List<WorkOrderStatus>)? onRemoteUpdate,
  }) async {
    final cachedEntities = await _database.getSections(workOrderId);
    final forcedOffline = await _database.isWorkOrderOfflineMode(workOrderId);
    final hasCache = cachedEntities.isNotEmpty;

    debugPrint(
        'getSections($workOrderId): hasCache=$hasCache (${cachedEntities.length} items), forcedOffline=$forcedOffline, forceRefresh=$forceRefresh');

    if (hasCache && (!forceRefresh || forcedOffline)) {
      final sections = cachedEntities.map(_statusFromEntity).toList();
      debugPrint('getSections: Returning ${sections.length} cached sections');
      if (!forceRefresh && !forcedOffline) {
        unawaited(_refreshSections(
          workOrderId: workOrderId,
          currentStatus: currentStatus,
        ).then((value) {
          if (onRemoteUpdate != null) {
            onRemoteUpdate(value);
          }
        }));
      }
      return sections;
    }

    if (forcedOffline && hasCache) {
      final sections = cachedEntities.map(_statusFromEntity).toList();
      debugPrint(
          'getSections: Returning ${sections.length} cached sections (forced offline)');
      return sections;
    }

    debugPrint('getSections: Attempting remote refresh...');
    try {
      return await _refreshSections(
        workOrderId: workOrderId,
        currentStatus: currentStatus,
      );
    } catch (err, st) {
      if (hasCache) {
        debugPrint(
            'Remote section refresh failed; using cached sections. Error: $err\n$st');
        return cachedEntities.map(_statusFromEntity).toList();
      }
      rethrow;
    }
  }

  Future<ExecutionModel?> getExecution({
    required String workOrderId,
    bool forceRefresh = false,
    void Function(ExecutionModel)? onRemoteUpdate,
  }) async {
    final cached = await _database.getExecution(workOrderId);
    final forcedOffline = await _database.isWorkOrderOfflineMode(workOrderId);
    if (cached != null && (!forceRefresh || forcedOffline)) {
      final execution = _executionFromEntity(cached);
      if (!forceRefresh && !forcedOffline) {
        unawaited(_refreshExecution(workOrderId: workOrderId).then((value) {
          if (value != null && onRemoteUpdate != null) {
            onRemoteUpdate(value);
          }
        }));
      }
      return execution;
    }

    return _refreshExecution(workOrderId: workOrderId);
  }

  Future<int> pendingActionCount({String? workOrderId}) {
    return _database.getPendingActionCount(workOrderId: workOrderId);
  }

  Future<WorkOrderDetail?> getComplaintDetail({
    required String workOrderId,
    bool forceRefresh = false,
    void Function(WorkOrderDetail)? onRemoteUpdate,
  }) async {
    final cached = await _database.getComplaintDetail(workOrderId);
    final forcedOffline = await _database.isWorkOrderOfflineMode(workOrderId);

    if (cached != null && (!forceRefresh || forcedOffline)) {
      final detail = _detailFromEntity(cached);
      if (!forceRefresh && !forcedOffline && onRemoteUpdate != null) {
        unawaited(
            _refreshComplaintDetail(workOrderId: workOrderId).then((value) {
          if (value != null) {
            onRemoteUpdate(value);
          }
        }));
      }
      return detail;
    }

    if (forcedOffline && cached != null) {
      return _detailFromEntity(cached);
    }

    return _refreshComplaintDetail(workOrderId: workOrderId);
  }

  Future<List<TechnicianImageRepair>> getRepairImages({
    required String workOrderId,
    bool forceRefresh = false,
    void Function(List<TechnicianImageRepair>)? onRemoteUpdate,
  }) async {
    final cached = await _database.getRepairImages(workOrderId);
    final forcedOffline = await _database.isWorkOrderOfflineMode(workOrderId);

    if (cached.isNotEmpty && (!forceRefresh || forcedOffline)) {
      final images = cached.map(_repairImageFromEntity).toList();
      if (!forceRefresh && !forcedOffline && onRemoteUpdate != null) {
        unawaited(_refreshRepairImages(workOrderId: workOrderId).then((value) {
          onRemoteUpdate(value);
        }));
      }
      return images;
    }

    if (forcedOffline && cached.isNotEmpty) {
      return cached.map(_repairImageFromEntity).toList();
    }

    final refreshed = await _refreshRepairImages(workOrderId: workOrderId);
    if (refreshed.isEmpty && cached.isNotEmpty) {
      return cached.map(_repairImageFromEntity).toList();
    }
    return refreshed;
  }

  Future<List<PendingRepairImage>> getPendingRepairImages(
    String workOrderId,
  ) async {
    final pending = await _database.getPendingActions();
    if (pending.isEmpty) return const [];

    final results = <PendingRepairImage>[];
    for (final action in pending) {
      if (action.workOrderId != workOrderId) continue;
      if (action.action != 'upload_repair_image') continue;
      try {
        final payload = json.decode(action.payloadJson) as Map<String, dynamic>;
        final data = payload['fileUpload[data]']?.toString();
        if (data == null || data.isEmpty) continue;
        final bytes = base64Decode(data);
        results.add(
          PendingRepairImage(
            uploadType: payload['uploadType']?.toString() ?? '2',
            bytes: bytes,
            createdAt: action.createdAt,
            latitude: payload['latitude']?.toString(),
            longitude: payload['longitude']?.toString(),
            displayName: payload['fileUpload[name]']?.toString(),
          ),
        );
      } catch (err) {
        debugPrint('Failed to decode pending repair image payload: $err');
      }
    }

    results.sort((a, b) => b.createdAt.compareTo(a.createdAt));
    return results;
  }

  Future<List<ResponseImage>> getResponseImages({
    required String workOrderId,
    bool forceRefresh = false,
    void Function(List<ResponseImage>)? onRemoteUpdate,
  }) async {
    final cached = await _database.getResponseImages(workOrderId);
    final forcedOffline = await _database.isWorkOrderOfflineMode(workOrderId);

    if (cached.isNotEmpty && (!forceRefresh || forcedOffline)) {
      final images =
          cached.map<ResponseImage>(_responseImageFromEntity).toList();
      if (!forceRefresh && !forcedOffline && onRemoteUpdate != null) {
        unawaited(
            _refreshResponseImages(workOrderId: workOrderId).then((value) {
          onRemoteUpdate(value);
        }));
      }
      return images;
    }

    if (forcedOffline && cached.isNotEmpty) {
      return cached.map<ResponseImage>(_responseImageFromEntity).toList();
    }

    final refreshed = await _refreshResponseImages(workOrderId: workOrderId);
    if (refreshed.isEmpty && cached.isNotEmpty) {
      return cached.map<ResponseImage>(_responseImageFromEntity).toList();
    }
    return refreshed;
  }

  Future<List<PendingResponseImage>> getPendingResponseImages(
    String workOrderId,
  ) async {
    final pending = await _database.getPendingActions();
    if (pending.isEmpty) return const [];

    final results = <PendingResponseImage>[];
    for (final action in pending) {
      if (action.workOrderId != workOrderId) continue;
      if (action.action != 'upload_response_image') continue;
      try {
        final payload = json.decode(action.payloadJson) as Map<String, dynamic>;
        final data = payload['fileUpload[data]']?.toString();
        if (data == null || data.isEmpty) continue;
        final bytes = base64Decode(data);
        results.add(
          PendingResponseImage(
            bytes: bytes,
            createdAt: action.createdAt,
            latitude: payload['latitude']?.toString(),
            longitude: payload['longitude']?.toString(),
            displayName: payload['fileUpload[name]']?.toString(),
            description: payload['fileUpload[description]']?.toString(),
          ),
        );
      } catch (err) {
        debugPrint('Failed to decode pending response image payload: $err');
      }
    }

    results.sort((a, b) => b.createdAt.compareTo(a.createdAt));
    return results;
  }

  Future<WorkOrderAssistantData> getAssistantData({
    required String workOrderId,
    bool forceRefresh = false,
  }) async {
    Future<WorkOrderAssistantData> loadFromSnapshot() async {
      final snapshot = await loadSnapshot(workOrderId);
      if (snapshot == null) {
        if (forceRefresh) {
          throw StateError('Assistant data not cached for offline use.');
        }
        return WorkOrderAssistantData.empty;
      }
      return WorkOrderAssistantData(
        options: snapshot.assistantOptions,
        selected: snapshot.selectedAssistants,
        maxAssistants: snapshot.maxAssistants,
      );
    }

    final forcedOffline = await _database.isWorkOrderOfflineMode(workOrderId);
    if (forcedOffline) {
      return loadFromSnapshot();
    }

    try {
      final dropdown = await _fetchAssistantDropdownRemote(workOrderId);
      final selected = await _fetchAssistantSelectedRemote(workOrderId);
      final assignment = await _fetchAssignmentRemote(workOrderId);
      final maxAssistants =
          _parseMaxAssistants(assignment?.woTaskMaxAssistant);
      return WorkOrderAssistantData(
        options: dropdown,
        selected: selected,
        maxAssistants: maxAssistants,
      );
    } on SocketException catch (_) {
      return loadFromSnapshot();
    } on TimeoutException catch (_) {
      return loadFromSnapshot();
    } catch (err, st) {
      debugPrint('Failed to fetch assistant data: $err\n$st');
      if (forceRefresh) {
        rethrow;
      }
      return WorkOrderAssistantData.empty;
    }
  }

  Future<List<ComplaintD>> getMaterials({
    required String workOrderId,
    bool forceRefresh = false,
    void Function(List<ComplaintD>)? onRemoteUpdate,
  }) async {
    final cached = await _database.getMaterials(workOrderId);
    final forcedOffline = await _database.isWorkOrderOfflineMode(workOrderId);

    if (cached.isNotEmpty && (!forceRefresh || forcedOffline)) {
      final materials =
          cached.map<ComplaintD>(_materialFromEntity).toList(growable: false);
      if (!forceRefresh && !forcedOffline && onRemoteUpdate != null) {
        unawaited(
          _refreshMaterials(workOrderId: workOrderId).then((value) {
            onRemoteUpdate(value);
          }),
        );
      }
      return materials;
    }

    if (forcedOffline && cached.isNotEmpty) {
      return cached
          .map<ComplaintD>(_materialFromEntity)
          .toList(growable: false);
    }

    final refreshed = await _refreshMaterials(workOrderId: workOrderId);
    if (refreshed.isEmpty && cached.isNotEmpty) {
      return cached
          .map<ComplaintD>(_materialFromEntity)
          .toList(growable: false);
    }
    return refreshed;
  }

  Future<List<ComplaintDGroup>> getMaterialGroups({
    required String workOrderId,
    bool forceRefresh = false,
    void Function(List<ComplaintDGroup>)? onRemoteUpdate,
  }) async {
    final scope = _groupScope(workOrderId);
    final cachedEntities = await _database.getReferenceData(
      category: _materialGroupCategory,
      code: scope,
    );
    final forcedOffline = await _database.isWorkOrderOfflineMode(workOrderId);
    final cached = _groupsFromReference(cachedEntities);

    if (cached.isNotEmpty && (!forceRefresh || forcedOffline)) {
      if (!forceRefresh && !forcedOffline && onRemoteUpdate != null) {
        unawaited(
          _refreshMaterialGroups(workOrderId: workOrderId).then((value) {
            onRemoteUpdate(value);
          }),
        );
      }
      return cached;
    }

    if (forcedOffline) {
      if (cached.isNotEmpty) {
        return cached;
      }
      throw StateError('No cached material groups available offline.');
    }

    final refreshed = await _refreshMaterialGroups(workOrderId: workOrderId);
    if (refreshed.isEmpty && cached.isNotEmpty) {
      return cached;
    }
    return refreshed;
  }

  Future<List<ComplaintDType>> getMaterialTypes({
    required String workOrderId,
    required String groupId,
    bool forceRefresh = false,
    void Function(List<ComplaintDType>)? onRemoteUpdate,
  }) async {
    final scope = _typeScope(workOrderId, groupId);
    final cachedEntities = await _database.getReferenceData(
      category: _materialTypeCategory,
      code: scope,
    );
    final forcedOffline = await _database.isWorkOrderOfflineMode(workOrderId);
    final cached = _typesFromReference(scope, cachedEntities);

    if (cached.isNotEmpty && (!forceRefresh || forcedOffline)) {
      if (!forceRefresh && !forcedOffline && onRemoteUpdate != null) {
        unawaited(
          _refreshMaterialTypes(
            workOrderId: workOrderId,
            groupId: groupId,
          ).then((value) {
            onRemoteUpdate(value);
          }),
        );
      }
      return cached;
    }

    if (forcedOffline) {
      if (cached.isNotEmpty) {
        return cached;
      }
      throw StateError('No cached material types available offline.');
    }

    final refreshed = await _refreshMaterialTypes(
      workOrderId: workOrderId,
      groupId: groupId,
    );
    if (refreshed.isEmpty && cached.isNotEmpty) {
      return cached;
    }
    return refreshed;
  }

  Future<List<ComplaintDPart>> getMaterialParts({
    required String workOrderId,
    required String typeId,
    bool forceRefresh = false,
    void Function(List<ComplaintDPart>)? onRemoteUpdate,
  }) async {
    final scope = _partScope(workOrderId, typeId);
    final cachedEntities = await _database.getReferenceData(
      category: _materialPartCategory,
      code: scope,
    );
    final forcedOffline = await _database.isWorkOrderOfflineMode(workOrderId);
    final cached = _partsFromReference(scope, cachedEntities);

    if (cached.isNotEmpty && (!forceRefresh || forcedOffline)) {
      if (!forceRefresh && !forcedOffline && onRemoteUpdate != null) {
        unawaited(
          _refreshMaterialParts(
            workOrderId: workOrderId,
            typeId: typeId,
          ).then((value) {
            onRemoteUpdate(value);
          }),
        );
      }
      return cached;
    }

    if (forcedOffline) {
      if (cached.isNotEmpty) {
        return cached;
      }
      throw StateError('No cached material parts available offline.');
    }

    final refreshed = await _refreshMaterialParts(
      workOrderId: workOrderId,
      typeId: typeId,
    );
    if (refreshed.isEmpty && cached.isNotEmpty) {
      return cached;
    }
    return refreshed;
  }

  Future<List<PendingMaterialAction>> getPendingMaterials(
    String workOrderId,
  ) async {
    final pending = await _database.getPendingActions();
    if (pending.isEmpty) return const [];

    final results = <PendingMaterialAction>[];
    for (final action in pending) {
      if (action.workOrderId != workOrderId) continue;
      if (action.action != 'rest') continue;
      try {
        final payload = json.decode(action.payloadJson) as Map<String, dynamic>;
        final typeStr = payload['type']?.toString() ?? '';
        final type = _pendingMaterialTypeFromString(typeStr);
        if (type == PendingMaterialActionType.unknown) {
          continue;
        }

        final display = payload['display'];
        ComplaintD? material;
        if (display is Map<String, dynamic>) {
          try {
            material = serializers.deserializeWith(
              ComplaintD.serializer,
              display,
            );
          } catch (_) {
            // Fallback to manual mapping below
          }
        }

        String? materialId = payload['materialId']?.toString();
        String? description;
        String? quantity;
        String? remark;
        String? assetGroup;
        String? itemType;
        String? previousQuantity;
        if (display is Map<String, dynamic>) {
          materialId ??= display['materialId']?.toString();
          description = display['itemDescription']?.toString();
          quantity = display['woTaskPartsQuantity']?.toString();
          remark = display['woTaskPartsRemark']?.toString();
          assetGroup = display['assetGroupName']?.toString();
          itemType = display['itemTypeDesc']?.toString();
          previousQuantity = display['previousQuantity']?.toString();
          material ??= ComplaintD((b) {
            b
              ..woTaskPartsId = materialId
              ..itemDescription = description
              ..woTaskPartsQuantity = quantity
              ..woTaskPartsRemark = remark
              ..assetGroupName = assetGroup
              ..itemTypeDesc = itemType
              ..statusDesc = display['statusDesc']?.toString();
          });
        }

        results.add(
          PendingMaterialAction(
            type: type,
            createdAt: action.createdAt,
            materialId: materialId,
            material: material,
            quantity: quantity,
            previousQuantity: previousQuantity,
            remark: remark,
            assetGroupName: assetGroup,
            itemTypeDesc: itemType,
          ),
        );
      } catch (err) {
        debugPrint('Failed to decode pending material payload: $err');
      }
    }

    results.sort((a, b) => b.createdAt.compareTo(a.createdAt));
    return results;
  }

  Future<List<TechnicianImageRepair>> _refreshRepairImages({
    required String workOrderId,
  }) async {
    try {
      final images = await _fetchRepairImagesRemote(workOrderId);
      final entities = images
          .map(
            (image) => WorkOrderRepairImageEntity(
              uploadId: image.woTaskUploadId,
              workOrderId: workOrderId,
              payloadJson: image.toJson(),
              uploadType: image.woTaskUploadType,
              documentDesc: image.documentDesc,
              documentSrc: image.documentSrc,
              capturedAt: _parseTimestamp(image.woTaskUploadTimestamp),
              lastSyncedAt: _clock(),
            ),
          )
          .toList();
      await _database.replaceRepairImages(workOrderId, entities);
      return images;
    } catch (err) {
      debugPrint('Failed to refresh repair images: $err');
      return const [];
    }
  }

  Future<List<ResponseImage>> _refreshResponseImages({
    required String workOrderId,
  }) async {
    try {
      final images = await _fetchResponseImagesRemote(workOrderId);
      final entities = images
          .map(
            (image) => WorkOrderResponseImageEntity(
              uploadId: image.woTaskUploadId,
              workOrderId: workOrderId,
              payloadJson: json.encode(image.toJson()),
              documentFilename: image.documentFilename,
              documentDesc: image.documentDesc,
              documentSrc: image.documentSrc,
              lastSyncedAt: _clock(),
            ),
          )
          .toList();
      await _database.replaceResponseImages(workOrderId, entities);
      return images;
    } catch (err) {
      debugPrint('Failed to refresh response images: $err');
      return const [];
    }
  }

  Future<List<ComplaintDGroup>> _refreshMaterialGroups({
    required String workOrderId,
  }) async {
    try {
      final groups = await _fetchMaterialGroupsRemote(workOrderId);
      final scope = _groupScope(workOrderId);
      final references = <ReferenceDataEntity>[];
      for (var index = 0; index < groups.length; index++) {
        references.add(
          _groupToReference(
            workOrderId: workOrderId,
            group: groups[index],
            index: index,
          ),
        );
      }
      await _database.replaceReferenceData(
        category: _materialGroupCategory,
        code: scope,
        items: references,
      );
      return groups;
    } catch (err) {
      debugPrint('Failed to refresh material groups: $err');
      return const [];
    }
  }

  Future<List<ComplaintDType>> _refreshMaterialTypes({
    required String workOrderId,
    required String groupId,
  }) async {
    try {
      final types = await _fetchMaterialTypesRemote(groupId);
      final scope = _typeScope(workOrderId, groupId);
      final references = <ReferenceDataEntity>[];
      for (var index = 0; index < types.length; index++) {
        references.add(
          _typeToReference(
            workOrderId: workOrderId,
            groupId: groupId,
            type: types[index],
            index: index,
          ),
        );
      }
      await _database.replaceReferenceData(
        category: _materialTypeCategory,
        code: scope,
        items: references,
      );
      return types;
    } catch (err) {
      debugPrint('Failed to refresh material types: $err');
      return const [];
    }
  }

  Future<List<ComplaintDPart>> _refreshMaterialParts({
    required String workOrderId,
    required String typeId,
  }) async {
    try {
      final parts = await _fetchMaterialPartsRemote(typeId);
      final scope = _partScope(workOrderId, typeId);
      final references = <ReferenceDataEntity>[];
      for (var index = 0; index < parts.length; index++) {
        references.add(
          _partToReference(
            workOrderId: workOrderId,
            typeId: typeId,
            part: parts[index],
            index: index,
          ),
        );
      }
      await _database.replaceReferenceData(
        category: _materialPartCategory,
        code: scope,
        items: references,
      );
      return parts;
    } catch (err) {
      debugPrint('Failed to refresh material parts: $err');
      return const [];
    }
  }

  Future<List<ComplaintD>> _refreshMaterials({
    required String workOrderId,
  }) async {
    try {
      final materials = await _fetchMaterialsRemote(workOrderId);
      final entities = <WorkOrderMaterialEntity>[];
      for (var index = 0; index < materials.length; index++) {
        final material = materials[index];
        final serialized = serializers.serializeWith(
          ComplaintD.serializer,
          material,
        );
        if (serialized == null) {
          continue;
        }

        final bufferId = material.woTaskPartsId ??
            '${material.partId ?? ''}_${material.itemDescription ?? ''}';
        final id = bufferId.trim().isEmpty
            ? 'material_${workOrderId}_$index'
            : bufferId;

        entities.add(
          WorkOrderMaterialEntity(
            materialId: id,
            workOrderId: workOrderId,
            payloadJson: json.encode(serialized),
            itemOrder: index,
            lastSyncedAt: _clock(),
          ),
        );
      }
      await _database.replaceMaterials(workOrderId, entities);
      return materials;
    } catch (err) {
      debugPrint('Failed to refresh materials: $err');
      return const [];
    }
  }

  Future<void> syncPendingActions() async {
    final pending = await _database.getPendingActions();
    if (pending.isEmpty) return;

    for (final action in pending) {
      try {
        if (action.action == 'rest') {
          final payload =
              json.decode(action.payloadJson) as Map<String, dynamic>;
          await _sendRest(payload);
        } else {
          final body = json.decode(action.payloadJson) as Map<String, dynamic>;
          await _post(body);
        }
        if (action.id != null) {
          await _database.removePendingAction(action.id!);
        }
      } on SocketException catch (_) {
        // Still offline; stop replay attempts until connectivity returns.
        break;
      } on TimeoutException catch (_) {
        break;
      } catch (err) {
        debugPrint('Failed to replay action ${action.id}: $err');
        break;
      }
    }
  }

  Future<WorkOrderActionResult> submitAssign(String workOrderId) async {
    return _sendOrQueue(
      workOrderId: workOrderId,
      body: {
        'action': 'submit_assign',
        'woTaskId': workOrderId,
      },
    );
  }

  Future<WorkOrderActionResult> submitVerified(
    String workOrderId,
    String remarks,
    int isRejected,
  ) async {
    return _sendOrQueue(
      workOrderId: workOrderId,
      body: {
        'action': 'submit_wr_verified',
        'woTaskId': workOrderId,
        'remarks': remarks,
        'isRejected': isRejected.toString(),
      },
    );
  }

  Future<WorkOrderActionResult> reject(
    String status,
    String workOrderId,
    String remark,
  ) async {
    final action = status == 'Assign'
        ? 'reject_complaint'
        : status == 'WR Verified' || status == 'Check'
            ? 'return_by_verifier'
            : 'return_by_technician';
    return _sendOrQueue(
      workOrderId: workOrderId,
      body: {
        'action': action,
        'woTaskId': workOrderId,
        'remark': remark,
      },
    );
  }

  Future<WorkOrderActionResult> rejectOutOfScope(
    String workOrderId,
    String remark,
  ) async {
    return _sendOrQueue(
      workOrderId: workOrderId,
      body: {
        'action': 'reject_complaint',
        'woTaskId': workOrderId,
        'remark': remark,
      },
    );
  }

  Future<WorkOrderActionResult> reOpenWorkOrder(
    String status,
    String workOrderId,
    String remark,
  ) async {
    var action = 'return_verify';
    if (status == 'Check') {
      action = 'return_from_check';
    }
    return _sendOrQueue(
      workOrderId: workOrderId,
      body: {
        'action': action,
        'woTaskId': workOrderId,
        'remark': remark,
      },
    );
  }

  Future<List<WorkOrderStatus>> _refreshSections({
    required String workOrderId,
    required String currentStatus,
  }) async {
    final remote = await _fetchSectionsRemote(currentStatus, workOrderId);
    final entities = <WorkOrderSectionEntity>[];
    for (var i = 0; i < remote.length; i++) {
      final section = remote[i];
      final key = (section.sectionName?.isNotEmpty ?? false)
          ? section.sectionName!
          : 'section_$i';
      entities.add(
        WorkOrderSectionEntity(
          workOrderId: workOrderId,
          sectionName: key,
          sectionDesc: section.sectionDesc,
          payloadJson: section.toJson(),
          lastSyncedAt: _clock(),
        ),
      );
    }
    await _database.replaceSections(workOrderId, entities);
    return remote;
  }

  Future<ExecutionModel?> _refreshExecution({
    required String workOrderId,
  }) async {
    try {
      final execution = await _fetchExecutionRemote(workOrderId);
      if (execution != null) {
        await _database.upsertExecution(
          WorkOrderExecutionEntity(
            workOrderId: workOrderId,
            payloadJson: json.encode(_executionToJson(execution)),
            lastSyncedAt: _clock(),
          ),
        );
      }
      return execution;
    } catch (err) {
      debugPrint('Failed to refresh execution info: $err');
      return null;
    }
  }

  Future<List<WorkOrderStatus>> _fetchSectionsRemote(
    String status,
    String workOrderId,
  ) async {
    final provider = _buildProvider(
      _sectionsPathForStatus(status),
      taskId: workOrderId,
    );
    final response = await provider.fetch();
    final list = response.wostatusList?.toList() ?? const <WorkOrderStatus>[];
    return List<WorkOrderStatus>.from(list);
  }

  Future<ExecutionModel?> _fetchExecutionRemote(String workOrderId) async {
    final provider =
        _buildProvider('/wo_v2/execution_info/', taskId: workOrderId);
    final result = await provider.getJson(url: '/wo_v2/execution_info/');
    if (result is Map<String, dynamic>) {
      return ExecutionModel.fromJson(result);
    }
    return null;
  }

  Future<WorkOrderDetail?> _fetchComplaintDetailRemote(
    String workOrderId,
  ) async {
    final provider = _buildProvider(
      '/api/m_wo.php?type=complaint_details&woTaskId=',
      taskId: workOrderId,
    );
    final response = await provider.fetch();
    return response.woDetail;
  }

  Future<List<TechnicianImageRepair>> _fetchRepairImagesRemote(
    String workOrderId,
  ) async {
    final provider = _buildProvider(
      '/api/m_wo.php?type=wo_repair_images&woTaskId=',
      taskId: workOrderId,
    );
    final response = await provider.fetch();
    return response.technicianImages?.toList() ??
        const <TechnicianImageRepair>[];
  }

  Future<List<ComplaintDGroup>> _fetchMaterialGroupsRemote(
    String workOrderId,
  ) async {
    final provider = _buildProvider('/part/option_asset_group');
    final result = await provider.fetchComplaint(group: true);
    return result.whereType<ComplaintDGroup>().toList(growable: false);
  }

  Future<List<ComplaintDType>> _fetchMaterialTypesRemote(String groupId) async {
    if (groupId.isEmpty) {
      return const [];
    }
    final provider = _buildProvider('/part/option_item_type/');
    final result = await provider.fetchComplaint(
      additionalParam: groupId,
      type: true,
    );
    return result.whereType<ComplaintDType>().toList(growable: false);
  }

  Future<List<ComplaintDPart>> _fetchMaterialPartsRemote(String typeId) async {
    if (typeId.isEmpty) {
      return const [];
    }
    final provider = _buildProvider('/part/option_item/');
    final result = await provider.fetchComplaint(
      additionalParam: typeId,
      part: true,
    );
    return result.whereType<ComplaintDPart>().toList(growable: false);
  }

  Future<List<ComplaintD>> _fetchMaterialsRemote(String workOrderId) async {
    final provider = _buildProvider(
      '/wo_parts/wo_parts_mobile_list/',
      taskId: workOrderId,
    );
    final result = await provider.fetchComplaint();
    return result.whereType<ComplaintD>().toList();
  }

  Future<List<WorkOrderStatus>> _fetchGroupListRemote(
    String workOrderId,
  ) async {
    if (workOrderId.isEmpty) {
      return const [];
    }
    final provider = _buildProvider(
      '/api/m_wo.php?type=wo_group_list&woTaskId=',
      taskId: workOrderId,
    );
    final response = await provider.fetch();
    return response.wostatusList?.toList() ?? const <WorkOrderStatus>[];
  }

  Future<List<WorkOrderStatus>> _fetchSeverityListRemote(
    String workOrderId,
  ) async {
    if (workOrderId.isEmpty) {
      return const [];
    }
    final provider = _buildProvider(
      '/api/m_wo.php?type=wo_severity_list&woTaskId=',
      taskId: workOrderId,
    );
    final response = await provider.fetch();
    return response.wostatusList?.toList() ?? const <WorkOrderStatus>[];
  }

  Future<List<WorkOrderStatus>> _fetchTechnicianListRemote(String groupId) async {
    if (groupId.isEmpty) {
      return const [];
    }
    final provider = _buildProvider(
      '/api/m_wo.php?type=wo_technician_list&groupId=',
      taskId: groupId,
    );
    final response = await provider.fetch();
    return response.wostatusList?.toList() ?? const <WorkOrderStatus>[];
  }

  Future<TechnicianAssign?> _fetchAssignmentRemote(String workOrderId) async {
    if (workOrderId.isEmpty) {
      return null;
    }
    final provider =
        _buildProvider('/wo_v2/assign_and_severity/', taskId: workOrderId);
    final response = await provider.fetch();
    return response.technicianAssign;
  }

  Future<TechnicianDetails?> _fetchTechnicianDetailsRemote(
    String groupId,
    String userId,
  ) async {
    if (groupId.isEmpty || userId.isEmpty) {
      return null;
    }
    final provider = _buildProvider(
      '/api/m_wo.php?type=technician_details&groupId=$groupId&userId=',
      taskId: userId,
    );
    final response = await provider.fetch();
    return response.technicianDetails;
  }

  Future<String?> _fetchRepairWorkRemote(String workOrderId) async {
    if (workOrderId.isEmpty) {
      return null;
    }
    final provider = _buildProvider(
      '/api/m_wo.php?type=wo_repair_work&woTaskId=',
      taskId: workOrderId,
    );
    final response = await provider.fetch();
    return response.result;
  }

  Future<List<WorkOrderAssistant>> _fetchAssistantDropdownRemote(
    String workOrderId,
  ) async {
    if (workOrderId.isEmpty) {
      return const <WorkOrderAssistant>[];
    }
    final provider =
        _buildProvider('/wo_task_assist/dropdown_list/', taskId: workOrderId);
    final raw = await provider.getJson(url: '/wo_task_assist/dropdown_list/');
    return _assistantListFromJson(raw);
  }

  Future<List<WorkOrderAssistant>> _fetchAssistantSelectedRemote(
    String workOrderId,
  ) async {
    if (workOrderId.isEmpty) {
      return const <WorkOrderAssistant>[];
    }
    final provider =
        _buildProvider('/wo_task_assist/assistant_list/', taskId: workOrderId);
    final raw = await provider.getJson(url: '/wo_task_assist/assistant_list/');
    return _assistantListFromJson(raw);
  }

  Future<List<ResponseImage>> _fetchResponseImagesRemote(
    String workOrderId,
  ) async {
    final url = '/api/m_wo.php?type=wo_response_images&woTaskId=$workOrderId';
    final provider = _buildProvider(url, taskId: workOrderId);
    final raw = await provider.getJson(url: url);
    final list = _normalizeResponseImagePayload(raw);
    return list.map(ResponseImage.fromJson).toList();
  }

  List<Map<String, dynamic>> _normalizeResponseImagePayload(dynamic raw) {
    if (raw is List) {
      return raw
          .whereType<Map>()
          .map((e) => Map<String, dynamic>.from(e))
          .toList();
    }
    if (raw is String) {
      try {
        final decoded = json.decode(raw);
        return _normalizeResponseImagePayload(decoded);
      } catch (err) {
        debugPrint('Failed to decode response image payload string: $err');
        return const [];
      }
    }
    if (raw is Map) {
      final result = raw['result'];
      if (result is List) {
        return result
            .whereType<Map>()
            .map((e) => Map<String, dynamic>.from(e))
            .toList();
      }
    }
    return const [];
  }

  WorkOrderStatus _statusFromEntity(WorkOrderSectionEntity entity) {
    final decoded = json.decode(entity.payloadJson);
    var status = serializers.deserializeWith(
      WorkOrderStatus.serializer,
      decoded,
    )!;
    status = status.rebuild((builder) {
      if (builder.sectionDesc == null && entity.sectionDesc != null) {
        builder.sectionDesc = entity.sectionDesc;
      }
      if (builder.sectionName == null && entity.sectionName.isNotEmpty) {
        builder.sectionName = entity.sectionName;
      }
    });
    return status;
  }


  List<WorkOrderStatus> _decodeWorkOrderStatusList(dynamic value) {
    if (value is! List) {
      return const <WorkOrderStatus>[];
    }
    final result = <WorkOrderStatus>[];
    for (final entry in value) {
      final map = _asJsonMap(entry);
      if (map == null) {
        continue;
      }
      try {
        final WorkOrderStatus? status = serializers.deserializeWith(
          WorkOrderStatus.serializer,
          map,
        );
        if (status != null) {
          result.add(status);
        }
      } catch (err) {
        debugPrint('Failed to decode work order status: $err');
      }
    }
    return result;
  }

  TechnicianAssign? _decodeTechnicianAssign(dynamic value) {
    final map = _asJsonMap(value);
    if (map == null) {
      return null;
    }
    try {
      final TechnicianAssign? assign =
          serializers.deserializeWith(TechnicianAssign.serializer, map);
      return assign;
    } catch (err) {
      debugPrint('Failed to decode technician assignment: $err');
      return null;
    }
  }

  TechnicianDetails? _decodeTechnicianDetails(dynamic value) {
    final map = _asJsonMap(value);
    if (map == null) {
      return null;
    }
    try {
      final TechnicianDetails? details =
          serializers.deserializeWith(TechnicianDetails.serializer, map);
      return details;
    } catch (err) {
      debugPrint('Failed to decode technician details: $err');
      return null;
    }
  }

  List<WorkOrderAssistant> _decodeAssistantList(dynamic value) {
    if (value is! List) {
      return const <WorkOrderAssistant>[];
    }
    final results = <WorkOrderAssistant>[];
    for (final entry in value) {
      final map = _asJsonMap(entry);
      if (map == null) {
        continue;
      }
      final assistant = WorkOrderAssistant.maybeFromMap(map);
      if (assistant != null) {
        results.add(assistant);
      }
    }
    return results;
  }

  List<WorkOrderAssistant> _assistantListFromJson(dynamic raw) {
    if (raw is! List) {
      return const <WorkOrderAssistant>[];
    }
    final results = <WorkOrderAssistant>[];
    for (final entry in raw) {
      final map = _asJsonMap(entry);
      if (map == null) {
        continue;
      }
      final assistant = WorkOrderAssistant.maybeFromMap(map);
      if (assistant != null) {
        results.add(assistant);
      }
    }
    return results;
  }

  String? _decodeRepairWork(dynamic value) {
    if (value == null) {
      return null;
    }
    if (value is String) {
      return value;
    }
    return null;
  }

  Map<String, dynamic>? _asJsonMap(dynamic value) {
    if (value is Map<String, dynamic>) {
      return value;
    }
    if (value is Map) {
      return value.map((key, entry) => MapEntry(key.toString(), entry));
    }
    if (value is String) {
      try {
        final decoded = json.decode(value);
        return _asJsonMap(decoded);
      } catch (err) {
        debugPrint('Failed to parse JSON string map: $err');
        return null;
      }
    }
    return null;
  }

  int? _parseMaxAssistants(Object? source) {
    if (source == null) {
      return null;
    }
    if (source is int) {
      return source;
    }
    if (source is num) {
      return source.toInt();
    }
    if (source is String) {
      final trimmed = source.trim();
      if (trimmed.isEmpty) {
        return null;
      }
      return int.tryParse(trimmed);
    }
    return null;
  }

  int? _decodeMaxAssistants(dynamic value) => _parseMaxAssistants(value);
  ExecutionModel _executionFromEntity(WorkOrderExecutionEntity entity) {
    final map = json.decode(entity.payloadJson) as Map<String, dynamic>;
    return ExecutionModel.fromJson(map);
  }

  WorkOrderDetail _detailFromEntity(
    WorkOrderComplaintDetailEntity entity,
  ) {
    return WorkOrderDetail.fromJson(entity.payloadJson);
  }

  TechnicianImageRepair _repairImageFromEntity(
    WorkOrderRepairImageEntity entity,
  ) {
    return TechnicianImageRepair.fromJson(entity.payloadJson);
  }

  ResponseImage _responseImageFromEntity(
    WorkOrderResponseImageEntity entity,
  ) {
    final map = json.decode(entity.payloadJson) as Map<String, dynamic>;
    return ResponseImage.fromJson(map);
  }

  ComplaintD _materialFromEntity(WorkOrderMaterialEntity entity) {
    try {
      final map = json.decode(entity.payloadJson) as Map<String, dynamic>;
      final material = ComplaintD.fromJson(map);
      if (material != null) {
        return material;
      }
    } catch (err) {
      debugPrint('Failed to decode material entity: $err');
    }
    return ComplaintD();
  }

  ReferenceDataEntity _groupToReference({
    required String workOrderId,
    required ComplaintDGroup group,
    required int index,
  }) {
    final scope = _groupScope(workOrderId);
    final serialized = serializers.serializeWith(
      ComplaintDGroup.serializer,
      group,
    );
    final payload = serialized != null
        ? json.encode(serialized)
        : json.encode({
            'asset_group_id': group.itemId,
            'asset_group_name': group.itemName,
            'assetGroupDesc': group.itemDesc,
            'assetGroupStatus': group.itemStatus,
          });
    return ReferenceDataEntity(
      referenceId: _buildReferenceId(_materialGroupCategory, scope, index),
      category: _materialGroupCategory,
      code: scope,
      label: group.itemName ?? group.itemDesc ?? 'Group ${index + 1}',
      updatedAt: _clock(),
      extraJson: payload,
    );
  }

  ReferenceDataEntity _typeToReference({
    required String workOrderId,
    required String groupId,
    required ComplaintDType type,
    required int index,
  }) {
    final scope = _typeScope(workOrderId, groupId);
    final serialized = serializers.serializeWith(
      ComplaintDType.serializer,
      type,
    );
    final payload = serialized != null
        ? json.encode(serialized)
        : json.encode({
            'item_type_id': type.itemId,
            'assetGroupId': groupId,
            'item_type_desc': type.itemName,
            'itemTypeDesc': type.itemTypeDesc,
            'itemTypeStatus': type.itemStatus,
          });
    return ReferenceDataEntity(
      referenceId: _buildReferenceId(_materialTypeCategory, scope, index),
      category: _materialTypeCategory,
      code: scope,
      label: type.itemName ?? type.itemTypeDesc ?? 'Type ${index + 1}',
      updatedAt: _clock(),
      extraJson: payload,
    );
  }

  ReferenceDataEntity _partToReference({
    required String workOrderId,
    required String typeId,
    required ComplaintDPart part,
    required int index,
  }) {
    final scope = _partScope(workOrderId, typeId);
    final serialized = serializers.serializeWith(
      ComplaintDPart.serializer,
      part,
    );
    final payload = serialized != null
        ? json.encode(serialized)
        : json.encode({
            'item_id': part.itemId,
            'item_description': part.itemName,
            'partCounts': part.itemQuantity,
            'itemTypeDesc': part.itemTypeDesc,
            'partLocked': part.partLocked,
            'partMaxOrder': part.partMaxOrder,
            'partMinOrder': part.partMinOrder,
            'partRemark': part.partRemark,
          });
    return ReferenceDataEntity(
      referenceId: _buildReferenceId(_materialPartCategory, scope, index),
      category: _materialPartCategory,
      code: scope,
      label: part.itemName ?? 'Part ${index + 1}',
      updatedAt: _clock(),
      extraJson: payload,
    );
  }

  List<ComplaintDGroup> _groupsFromReference(
    List<ReferenceDataEntity> entities,
  ) {
    final results = <ComplaintDGroup>[];
    for (final entity in entities) {
      final parsed = _groupFromReference(entity);
      if (parsed != null) {
        results.add(parsed);
      }
    }
    return results;
  }

  List<ComplaintDType> _typesFromReference(
    String scope,
    List<ReferenceDataEntity> entities,
  ) {
    final groupId = _scopeChild(scope);
    final results = <ComplaintDType>[];
    for (final entity in entities) {
      final parsed = _typeFromReference(entity, groupId);
      if (parsed != null) {
        results.add(parsed);
      }
    }
    return results;
  }

  List<ComplaintDPart> _partsFromReference(
    String scope,
    List<ReferenceDataEntity> entities,
  ) {
    final typeId = _scopeChild(scope);
    final results = <ComplaintDPart>[];
    for (final entity in entities) {
      final parsed = _partFromReference(entity, typeId);
      if (parsed != null) {
        results.add(parsed);
      }
    }
    return results;
  }

  ComplaintDGroup? _groupFromReference(ReferenceDataEntity entity) {
    final raw = entity.extraJson;
    if (raw == null || raw.isEmpty) {
      return null;
    }
    try {
      final decoded = json.decode(raw);
      final model = serializers.deserializeWith(
        ComplaintDGroup.serializer,
        decoded,
      );
      if (model != null) {
        return model;
      }
    } catch (err) {
      debugPrint('Failed to decode cached material group: $err');
    }
    final label = entity.label;
    if (label == null) {
      return null;
    }
    return ComplaintDGroup((b) {
      b
        ..itemName = label
        ..itemDesc = label;
    });
  }

  ComplaintDType? _typeFromReference(
    ReferenceDataEntity entity,
    String? groupId,
  ) {
    final raw = entity.extraJson;
    if (raw != null && raw.isNotEmpty) {
      try {
        final decoded = json.decode(raw);
        final model = serializers.deserializeWith(
          ComplaintDType.serializer,
          decoded,
        );
        if (model != null) {
          return model;
        }
      } catch (err) {
        debugPrint('Failed to decode cached material type: $err');
      }
    }
    final label = entity.label;
    if (label == null) {
      return null;
    }
    return ComplaintDType((b) {
      b
        ..itemGroupId = groupId
        ..itemName = label
        ..itemTypeDesc = label;
    });
  }

  ComplaintDPart? _partFromReference(
    ReferenceDataEntity entity,
    String? typeId,
  ) {
    final raw = entity.extraJson;
    if (raw != null && raw.isNotEmpty) {
      try {
        final decoded = json.decode(raw);
        final model = serializers.deserializeWith(
          ComplaintDPart.serializer,
          decoded,
        );
        if (model != null) {
          return model;
        }
      } catch (err) {
        debugPrint('Failed to decode cached material part: $err');
      }
    }
    final label = entity.label;
    if (label == null) {
      return null;
    }
    return ComplaintDPart((b) {
      b
        ..itemId = null
        ..itemTypeDesc = label
        ..itemName = label;
    });
  }

  String _groupScope(String workOrderId) => workOrderId;

  String _typeScope(String workOrderId, String groupId) =>
      '$workOrderId|$groupId';

  String _partScope(String workOrderId, String typeId) =>
      '$workOrderId|$typeId';

  String? _scopeChild(String scope) {
    final separator = scope.indexOf('|');
    if (separator == -1 || separator + 1 >= scope.length) {
      return null;
    }
    return scope.substring(separator + 1);
  }

  String _buildReferenceId(String category, String scope, int index) =>
      '$category|$scope|$index';

  Map<String, dynamic> _executionToJson(ExecutionModel model) {
    return {
      'maxExecutionTime': model.max,
      'minExecutionTime': model.min,
      'isTimeExceeded': model.exceed,
      'currentTime': model.current,
      'executeTime': model.execute,
      'assignTime': model.assignTime,
      'responseTimeDue': model.responseTimeDue,
      'completionTimeDue': model.completionTimeDue,
      'responseTimeSla': model.responseTimeSla,
      'completionTimeSla': model.completionTimeSla,
      'completionTimeExceeded': model.completionTimeExceeded,
      'responseTimeExceeded': model.responseTimeExceeded,
    };
  }

  Map<String, dynamic>? _encodeComplaintDetail(WorkOrderDetail detail) {
    try {
      final raw = detail.toJson();
      final decoded = json.decode(raw);
      if (decoded is Map<String, dynamic>) {
        return decoded;
      }
      if (decoded is Map) {
        return Map<String, dynamic>.from(decoded);
      }
    } catch (err) {
      debugPrint('Failed to encode complaint detail: $err');
    }
    return null;
  }

  Map<String, dynamic>? _encodeComplaintD(ComplaintD material) {
    try {
      final serialized =
          serializers.serializeWith(ComplaintD.serializer, material);
      if (serialized is Map<String, dynamic>) {
        return serialized;
      }
      if (serialized is Map) {
        return Map<String, dynamic>.from(serialized);
      }
    } catch (err) {
      debugPrint('Failed to encode complaint material: $err');
    }
    return null;
  }

  Map<String, dynamic>? _encodeComplaintDGroup(ComplaintDGroup group) {
    try {
      final serialized =
          serializers.serializeWith(ComplaintDGroup.serializer, group);
      if (serialized is Map<String, dynamic>) {
        return serialized;
      }
      if (serialized is Map) {
        return Map<String, dynamic>.from(serialized);
      }
    } catch (err) {
      debugPrint('Failed to encode complaint group: $err');
    }
    return null;
  }

  Map<String, dynamic>? _encodeTechnicianImageRepair(
    TechnicianImageRepair image,
  ) {
    try {
      final raw = image.toJson();
      final decoded = json.decode(raw);
      if (decoded is Map<String, dynamic>) {
        return decoded;
      }
      if (decoded is Map) {
        return Map<String, dynamic>.from(decoded);
      }
    } catch (err) {
      debugPrint('Failed to encode technician repair image: $err');
    }
    return null;
  }

  Map<String, dynamic>? _encodeWorkOrderStatus(WorkOrderStatus status) {
    try {
      final serialized =
          serializers.serializeWith(WorkOrderStatus.serializer, status);
      if (serialized is Map<String, dynamic>) {
        return serialized;
      }
      if (serialized is Map) {
        return Map<String, dynamic>.from(serialized);
      }
    } catch (err) {
      debugPrint('Failed to encode work order status: $err');
    }
    return null;
  }

  Map<String, dynamic>? _encodeTechnicianAssign(TechnicianAssign assign) {
    try {
      final serialized =
          serializers.serializeWith(TechnicianAssign.serializer, assign);
      if (serialized is Map<String, dynamic>) {
        return serialized;
      }
      if (serialized is Map) {
        return Map<String, dynamic>.from(serialized);
      }
    } catch (err) {
      debugPrint('Failed to encode technician assignment: $err');
    }
    return null;
  }

  Map<String, dynamic>? _encodeTechnicianDetails(TechnicianDetails details) {
    try {
      final serialized =
          serializers.serializeWith(TechnicianDetails.serializer, details);
      if (serialized is Map<String, dynamic>) {
        return serialized;
      }
      if (serialized is Map) {
        return Map<String, dynamic>.from(serialized);
      }
    } catch (err) {
      debugPrint('Failed to encode technician details: $err');
    }
    return null;
  }

  Map<String, dynamic>? _encodeAssistant(WorkOrderAssistant assistant) {
    if (assistant.userId.isEmpty) {
      return null;
    }
    return {
      'assistantId': assistant.assistantId,
      'userId': assistant.userId,
      'userFullName': assistant.userFullName,
    };
  }

  WorkOrderStatus? _decodeSnapshotSection(
    WorkOrderSnapshotSectionEntity entity,
  ) {
    final payload = entity.payloadJson;
    if (payload == null || payload.isEmpty) {
      return null;
    }
    try {
      return WorkOrderStatus.fromJson(payload);
    } catch (err) {
      debugPrint('Failed to decode snapshot section: $err');
      return null;
    }
  }

  Map<String, dynamic> _decodeSnapshotSummary(String? raw) {
    if (raw == null || raw.isEmpty) {
      return const {};
    }
    try {
      final decoded = json.decode(raw);
      if (decoded is Map<String, dynamic>) {
        return decoded;
      }
      if (decoded is Map) {
        return Map<String, dynamic>.from(decoded);
      }
    } catch (err) {
      debugPrint('Failed to decode snapshot summary: $err');
    }
    return const {};
  }

  ExecutionModel? _decodeExecution(dynamic value) {
    if (value is Map<String, dynamic>) {
      return ExecutionModel.fromJson(value);
    }
    if (value is Map) {
      return ExecutionModel.fromJson(Map<String, dynamic>.from(value));
    }
    return null;
  }

  WorkOrderDetail? _decodeComplaintDetail(dynamic value) {
    if (value is Map) {
      try {
        return WorkOrderDetail.fromJson(json.encode(value));
      } catch (err) {
        debugPrint('Failed to decode complaint detail from snapshot: $err');
      }
    }
    return null;
  }

  List<ComplaintD> _decodeComplaintDList(dynamic value) {
    if (value is! List) {
      return const [];
    }
    final results = <ComplaintD>[];
    for (final entry in value) {
      if (entry is Map) {
        try {
          final map = Map<String, dynamic>.from(entry);
          final material = ComplaintD.fromJson(map);
          if (material != null) {
            results.add(material);
          }
        } catch (err) {
          debugPrint('Failed to decode complaint material snapshot: $err');
        }
      }
    }
    return results;
  }

  List<ComplaintDGroup> _decodeComplaintDGroupList(dynamic value) {
    if (value is! List) {
      return const [];
    }
    final results = <ComplaintDGroup>[];
    for (final entry in value) {
      if (entry is Map) {
        try {
          final map = Map<String, dynamic>.from(entry);
          final group = serializers.deserializeWith(
            ComplaintDGroup.serializer,
            map,
          );
          if (group != null) {
            results.add(group);
          }
        } catch (err) {
          debugPrint('Failed to decode complaint group snapshot: $err');
        }
      }
    }
    return results;
  }

  List<TechnicianImageRepair> _decodeTechnicianImageRepairList(dynamic value) {
    if (value is! List) {
      return const [];
    }
    final results = <TechnicianImageRepair>[];
    for (final entry in value) {
      if (entry is Map) {
        try {
          final map = Map<String, dynamic>.from(entry);
          final model = TechnicianImageRepair.fromJson(json.encode(map));
          results.add(model);
        } catch (err) {
          debugPrint('Failed to decode technician repair image snapshot: $err');
        }
      }
    }
    return results;
  }

  List<ResponseImage> _decodeResponseImageList(dynamic value) {
    if (value is! List) {
      return const [];
    }
    final results = <ResponseImage>[];
    for (final entry in value) {
      if (entry is Map) {
        try {
          final map = Map<String, dynamic>.from(entry);
          results.add(ResponseImage.fromJson(map));
        } catch (err) {
          debugPrint('Failed to decode response image snapshot: $err');
        }
      }
    }
    return results;
  }

  Future<WorkOrderActionResult> _sendOrQueue({
    required String workOrderId,
    required Map<String, dynamic> body,
  }) async {
    final forcedOffline = await _database.isWorkOrderOfflineMode(workOrderId);
    if (!forcedOffline) {
      try {
        await syncPendingActions();
        await _post(body);
        return WorkOrderActionResult.success;
      } on SocketException catch (_) {
        await _queueAction(workOrderId, body);
        return WorkOrderActionResult.queued;
      } on TimeoutException catch (_) {
        await _queueAction(workOrderId, body);
        return WorkOrderActionResult.queued;
      }
    }

    await _queueAction(workOrderId, body);
    return WorkOrderActionResult.queued;
  }

  Future<void> _queueAction(
      String workOrderId, Map<String, dynamic> body) async {
    await _database.enqueuePendingAction(
      WorkOrderPendingActionEntity(
        workOrderId: workOrderId,
        action: body['action']?.toString() ?? 'unknown',
        payloadJson: json.encode(body),
        createdAt: _clock(),
      ),
    );
  }

  Future<void> _queueRestAction(
    String workOrderId,
    Map<String, dynamic> payload,
  ) async {
    await _database.enqueuePendingAction(
      WorkOrderPendingActionEntity(
        workOrderId: workOrderId,
        action: 'rest',
        payloadJson: json.encode(payload),
        createdAt: _clock(),
      ),
    );
  }

  Future<bool> _removeQueuedAssistantAdd({
    required String workOrderId,
    required String userId,
  }) async {
    final pending = await _database.getPendingActions();
    if (pending.isEmpty) {
      return false;
    }

    for (final action in pending) {
      if (action.workOrderId != workOrderId) {
        continue;
      }
      if (action.action != 'rest') {
        continue;
      }
      try {
        final payload = json.decode(action.payloadJson) as Map<String, dynamic>;
        if (payload['type'] != 'assistant_add') {
          continue;
        }
        final body = payload['body'];
        final assistant =
            body is Map<String, dynamic> ? body['assistant']?.toString() : null;
        if (assistant == userId) {
          if (action.id != null) {
            await _database.removePendingAction(action.id!);
          }
          return true;
        }
      } catch (err) {
        debugPrint('Failed to inspect pending assistant add: $err');
      }
    }

    return false;
  }

  Future<WorkOrderActionResult> _sendRestOrQueue({
    required String workOrderId,
    required Map<String, dynamic> payload,
  }) async {
    final forcedOffline = await _database.isWorkOrderOfflineMode(workOrderId);
    debugPrint(
        '[RestOrQueue] woTaskId=$workOrderId forcedOffline=$forcedOffline payloadType=${payload['type']} method=${payload['method']} url=${payload['url']}');
    if (!forcedOffline) {
      try {
        await syncPendingActions();
        await _sendRest(payload);
        debugPrint('[RestOrQueue] sent immediately');
        return WorkOrderActionResult.success;
      } on SocketException catch (_) {
        await _queueRestAction(workOrderId, payload);
        debugPrint('[RestOrQueue] queued due to SocketException');
        return WorkOrderActionResult.queued;
      } on TimeoutException catch (_) {
        await _queueRestAction(workOrderId, payload);
        debugPrint('[RestOrQueue] queued due to TimeoutException');
        return WorkOrderActionResult.queued;
      }
    }

    await _queueRestAction(workOrderId, payload);
    debugPrint('[RestOrQueue] forced offline, queued action');
    return WorkOrderActionResult.queued;
  }

  Future<void> _sendRest(Map<String, dynamic> payload) async {
    final method = payload['method']?.toString().toUpperCase() ?? 'POST';
    final url = payload['url']?.toString();
    if (url == null || url.isEmpty) {
      throw ArgumentError('REST payload missing url');
    }
    final fetchURL = payload['fetchURL']?.toString() ?? url;
    final taskId = payload['taskId'];
    final body = payload['body'];

    final provider = Provider(
      fetchURL: fetchURL,
      taskID: taskId?.toString(),
    );
    final context = navigatorKey.currentContext;
    if (context != null) {
      provider.context = context;
    }

    switch (method) {
      case 'POST':
        await provider.post(url: url, body: body);
        break;
      case 'PUT':
        await provider.put(body: (body as Map<String, dynamic>?) ?? const {});
        break;
      case 'DELETE':
        await provider.delete(url: url);
        break;
      default:
        throw UnsupportedError('Unsupported REST method $method');
    }
  }

  Future<WorkOrderActionResult> saveRepairWork(
    String workOrderId,
    String notes,
  ) async {
    return _sendOrQueue(
      workOrderId: workOrderId,
      body: {
        'action': 'save_wo_repair_work',
        'woTaskId': workOrderId,
        'repairWork': notes,
      },
    );
  }

  Future<WorkOrderActionResult> saveAssetNumber(
    String workOrderId,
    String assetNo,
  ) async {
    return _sendOrQueue(
      workOrderId: workOrderId,
      body: {
        'action': 'save_asset_no',
        'woTaskId': workOrderId,
        'assetNo': assetNo,
      },
    );
  }

  Future<WorkOrderActionResult> addAssistant({
    required String workOrderId,
    required String userId,
    String? userFullName,
  }) {
    final payload = <String, dynamic>{
      'type': 'assistant_add',
      'method': 'POST',
      'url': '/wo_task_assist',
      'body': {
        'woTaskId': workOrderId,
        'assistant': userId,
      },
      'display': {
        'assistantId': null,
        'userId': userId,
        'userFullName': userFullName ?? userId,
      },
    };
    return _sendRestOrQueue(workOrderId: workOrderId, payload: payload);
  }

  Future<WorkOrderActionResult> removeAssistant({
    required String workOrderId,
    String? assistantId,
    required String userId,
  }) async {
    if (assistantId == null || assistantId.isEmpty) {
      final removed = await _removeQueuedAssistantAdd(
        workOrderId: workOrderId,
        userId: userId,
      );
      if (removed) {
        return WorkOrderActionResult.success;
      }
      return WorkOrderActionResult.success;
    }

    final payload = <String, dynamic>{
      'type': 'assistant_delete',
      'method': 'DELETE',
      'url': '/wo_task_assist/$assistantId',
      'assistantId': assistantId,
    };
    return _sendRestOrQueue(workOrderId: workOrderId, payload: payload);
  }

  Future<WorkOrderActionResult> submitAssistantList(String workOrderId) {
    final payload = <String, dynamic>{
      'type': 'assistant_submit',
      'method': 'POST',
      'url': '/wo_v2/save_assistant_list/$workOrderId',
      'body': const <String, dynamic>{},
    };
    return _sendRestOrQueue(workOrderId: workOrderId, payload: payload);
  }

  Future<WorkOrderActionResult> addMaterial({
    required String workOrderId,
    required String itemId,
    required String quantity,
    String? remark,
    String? itemDescription,
    String? assetGroupName,
    String? itemTypeDesc,
  }) {
    final payload = <String, dynamic>{
      'type': 'material_add',
      'method': 'POST',
      'url': '/wo_parts',
      'body': {
        'woTaskId': workOrderId,
        'itemId': itemId,
        'quantity': quantity,
        'remark': remark ?? '',
      },
      'display': {
        'materialId': null,
        'itemDescription': itemDescription,
        'woTaskPartsQuantity': quantity,
        'woTaskPartsRemark': remark ?? '',
        'assetGroupName': assetGroupName,
        'itemTypeDesc': itemTypeDesc,
        'statusDesc': 'Pending',
      },
    };
    debugPrint('[MaterialAddRepo] payload=$payload');
    return _sendRestOrQueue(
      workOrderId: workOrderId,
      payload: payload,
    );
  }

  Future<WorkOrderActionResult> updateMaterial({
    required String workOrderId,
    required String materialId,
    required String quantity,
    String? remark,
    String? itemDescription,
    String? assetGroupName,
    String? itemTypeDesc,
    String? previousQuantity,
  }) {
    final payload = <String, dynamic>{
      'type': 'material_update',
      'method': 'PUT',
      'url': '/wo_parts/$materialId',
      'fetchURL': '/wo_parts/',
      'taskId': materialId,
      'materialId': materialId,
      'body': {
        'quantity': quantity,
        'remark': remark ?? '',
      },
      'display': {
        'materialId': materialId,
        'itemDescription': itemDescription,
        'woTaskPartsQuantity': quantity,
        'woTaskPartsRemark': remark ?? '',
        'assetGroupName': assetGroupName,
        'itemTypeDesc': itemTypeDesc,
        'previousQuantity': previousQuantity,
        'statusDesc': 'Pending update',
      },
    };
    return _sendRestOrQueue(
      workOrderId: workOrderId,
      payload: payload,
    );
  }

  Future<WorkOrderActionResult> deleteMaterial({
    required String workOrderId,
    required String materialId,
    String? itemDescription,
    String? quantity,
    String? assetGroupName,
    String? itemTypeDesc,
  }) {
    final payload = <String, dynamic>{
      'type': 'material_delete',
      'method': 'DELETE',
      'url': '/wo_parts/$materialId',
      'materialId': materialId,
      'display': {
        'materialId': materialId,
        'itemDescription': itemDescription,
        'woTaskPartsQuantity': quantity,
        'assetGroupName': assetGroupName,
        'itemTypeDesc': itemTypeDesc,
        'statusDesc': 'Pending delete',
      },
    };
    return _sendRestOrQueue(
      workOrderId: workOrderId,
      payload: payload,
    );
  }

  Future<WorkOrderActionResult> submitMaterialRequest(
    String workOrderId,
  ) {
    final payload = <String, dynamic>{
      'type': 'material_submit',
      'method': 'POST',
      'url': '/wo_request/$workOrderId',
      'body': const <String, dynamic>{},
    };
    return _sendRestOrQueue(
      workOrderId: workOrderId,
      payload: payload,
    );
  }

  Future<WorkOrderActionResult> resetMaterialRequest(
    String workOrderId,
  ) {
    final payload = <String, dynamic>{
      'type': 'material_reset',
      'method': 'POST',
      'url': '/wo_request/reset/$workOrderId',
      'body': const <String, dynamic>{},
    };
    return _sendRestOrQueue(
      workOrderId: workOrderId,
      payload: payload,
    );
  }

  Future<WorkOrderActionResult> uploadRepairImage({
    required String workOrderId,
    required String uploadType,
    required String latitude,
    required String longitude,
    required String displayName,
    required String filename,
    required int sizeBytes,
    required String base64Data,
  }) {
    return _sendOrQueue(
      workOrderId: workOrderId,
      body: {
        'action': 'upload_repair_image',
        'woTaskId': workOrderId,
        'uploadType': uploadType,
        'longitude': longitude,
        'latitude': latitude,
        'fileUpload[name]': displayName,
        'fileUpload[filename]': filename,
        'fileUpload[size]': sizeBytes.toString(),
        'fileUpload[type]': 'data:image/jpeg;base64',
        'fileUpload[data]': base64Data,
      },
    );
  }

  Future<WorkOrderActionResult> uploadResponseImage({
    required String workOrderId,
    required String uploadType,
    required String latitude,
    required String longitude,
    required String displayName,
    required String filename,
    required int sizeBytes,
    required String base64Data,
    String? description,
  }) {
    final body = <String, dynamic>{
      'action': 'upload_response_image',
      'woTaskId': workOrderId,
      'uploadType': uploadType,
      'longitude': longitude,
      'latitude': latitude,
      'fileUpload[name]': displayName,
      'fileUpload[filename]': filename,
      'fileUpload[size]': sizeBytes.toString(),
      'fileUpload[type]': 'data:image/jpeg;base64',
      'fileUpload[data]': base64Data,
      'fileUpload[description]': description ?? '',
    };
    return _sendOrQueue(
      workOrderId: workOrderId,
      body: body,
    );
  }

  Future<WorkOrderActionResult> deleteResponseImage({
    required String workOrderId,
    required String uploadId,
  }) {
    return _sendOrQueue(
      workOrderId: workOrderId,
      body: {
        'action': 'delete_wo_repair_image',
        'woTaskId': workOrderId,
        'woTaskUploadId': uploadId,
      },
    );
  }

  Future<WorkOrderActionResult> saveRepairImageDescriptions({
    required String workOrderId,
    required Map<String, String> descriptions,
  }) {
    final body = <String, String>{
      'action': 'save_wo_repair_image_desc',
      'woTaskId': workOrderId,
    };
    var index = 0;
    descriptions.forEach((key, value) {
      body['woTaskUpload[$index][woTaskUploadId]'] = key;
      body['woTaskUpload[$index][woTaskUploadDesc]'] = value;
      index++;
    });
    return _sendOrQueue(
      workOrderId: workOrderId,
      body: body,
    );
  }

  Future<void> _post(Map<String, dynamic> body) async {
    final provider = _buildProvider('/api/m_wo.php');
    await provider.post(url: '/api/m_wo.php', body: body);
  }

  Future<WorkOrderDetail?> _refreshComplaintDetail({
    required String workOrderId,
  }) async {
    try {
      final detail = await _fetchComplaintDetailRemote(workOrderId);
      if (detail != null) {
        await _database.upsertComplaintDetail(
          WorkOrderComplaintDetailEntity(
            workOrderId: workOrderId,
            payloadJson: detail.toJson(),
            lastSyncedAt: _clock(),
          ),
        );
      }
      return detail;
    } catch (err) {
      debugPrint('Failed to refresh complaint detail: $err');
      return null;
    }
  }

  Provider _buildProvider(String fetchURL, {String? taskId}) {
    final provider = Provider(fetchURL: fetchURL, taskID: taskId);
    final context = navigatorKey.currentContext;
    if (context != null) {
      provider.context = context;
    }
    return provider;
  }

  String _sectionsPathForStatus(String status) {
    const listAssign = {'Assign', 'Revisit', 'Rejected', 'WR Reassign'};
    const listWr = {'WR Check', 'WR Verified', 'WR Re-Open'};

    String url = '/wo_v2/section_assign/';
    if (listAssign.contains(status)) {
      url = '/api/m_wo.php?type=section_status_assign&woTaskId=';
    } else if (listWr.contains(status)) {
      url = '/api/m_wo.php?type=section_status_wr&woTaskId=';
    }
    return url;
  }

  DateTime? _parseTimestamp(String? value) {
    if (value == null || value.isEmpty) return null;
    try {
      return DateTime.parse(value);
    } catch (_) {
      try {
        return DateTime.parse(value.replaceAll(' ', 'T'));
      } catch (_) {
        return null;
      }
    }
  }
}

@immutable
class PendingRepairImage {
  const PendingRepairImage({
    required this.uploadType,
    required this.bytes,
    required this.createdAt,
    this.latitude,
    this.longitude,
    this.displayName,
  });

  final String uploadType;
  final Uint8List bytes;
  final DateTime createdAt;
  final String? latitude;
  final String? longitude;
  final String? displayName;
}

@immutable
class PendingResponseImage {
  const PendingResponseImage({
    required this.bytes,
    required this.createdAt,
    this.latitude,
    this.longitude,
    this.displayName,
    this.description,
  });

  final Uint8List bytes;
  final DateTime createdAt;
  final String? latitude;
  final String? longitude;
  final String? displayName;
  final String? description;
}

@immutable
class WorkOrderSnapshotData {
  const WorkOrderSnapshotData({
    required this.snapshot,
    required this.sections,
    required this.materials,
    required this.materialGroups,
    required this.repairImages,
    required this.responseImages,
    this.execution,
    this.complaintDetail,
    this.assignment,
    this.groupOptions = const <WorkOrderStatus>[],
    this.severityOptions = const <WorkOrderStatus>[],
    this.executorOptions = const <WorkOrderStatus>[],
    this.technicianDetails,
    this.repairWork,
    this.assistantOptions = const <WorkOrderAssistant>[],
    this.selectedAssistants = const <WorkOrderAssistant>[],
    this.maxAssistants,
  });

  final WorkOrderSnapshot snapshot;
  final List<WorkOrderStatus> sections;
  final ExecutionModel? execution;
  final WorkOrderDetail? complaintDetail;
  final List<ComplaintD> materials;
  final List<ComplaintDGroup> materialGroups;
  final List<TechnicianImageRepair> repairImages;
  final List<ResponseImage> responseImages;
  final TechnicianAssign? assignment;
  final List<WorkOrderStatus> groupOptions;
  final List<WorkOrderStatus> severityOptions;
  final List<WorkOrderStatus> executorOptions;
  final TechnicianDetails? technicianDetails;
  final String? repairWork;
  final List<WorkOrderAssistant> assistantOptions;
  final List<WorkOrderAssistant> selectedAssistants;
  final int? maxAssistants;
}

@immutable
class WorkOrderAssistant {
  const WorkOrderAssistant({
    this.assistantId,
    required this.userId,
    required this.userFullName,
    this.isPending = false,
  });

  final String? assistantId;
  final String userId;
  final String userFullName;
  final bool isPending;

  WorkOrderAssistant copyWith({
    String? assistantId,
    String? userId,
    String? userFullName,
    bool? isPending,
  }) {
    return WorkOrderAssistant(
      assistantId: assistantId ?? this.assistantId,
      userId: userId ?? this.userId,
      userFullName: userFullName ?? this.userFullName,
      isPending: isPending ?? this.isPending,
    );
  }

  static WorkOrderAssistant? maybeFromMap(Map<String, dynamic> map) {
    final userId = map['userId']?.toString() ?? '';
    if (userId.isEmpty) {
      return null;
    }
    final fullNameRaw = map['userFullName'] ?? map['user_name'];
    final userFullName = (fullNameRaw?.toString() ?? '').trim().isEmpty
        ? userId
        : fullNameRaw.toString();
    final assistantIdRaw = map['assistantId'] ?? map['woTaskAssistId'];
    String? assistantId;
    if (assistantIdRaw != null) {
      final normalized = assistantIdRaw.toString().trim();
      if (normalized.isNotEmpty) {
        assistantId = normalized;
      }
    }
    return WorkOrderAssistant(
      assistantId: assistantId,
      userId: userId,
      userFullName: userFullName,
    );
  }

  Map<String, dynamic> toSnapshotMap() {
    return {
      'assistantId': assistantId,
      'userId': userId,
      'userFullName': userFullName,
    };
  }
}

@immutable
class WorkOrderAssistantData {
  const WorkOrderAssistantData({
    required this.options,
    required this.selected,
    this.maxAssistants,
  });

  final List<WorkOrderAssistant> options;
  final List<WorkOrderAssistant> selected;
  final int? maxAssistants;

  static const empty = WorkOrderAssistantData(
    options: <WorkOrderAssistant>[],
    selected: <WorkOrderAssistant>[],
    maxAssistants: null,
  );
}

enum PendingMaterialActionType {
  add,
  update,
  delete,
  submit,
  reset,
  unknown,
}

PendingMaterialActionType _pendingMaterialTypeFromString(String value) {
  switch (value) {
    case 'material_add':
      return PendingMaterialActionType.add;
    case 'material_update':
      return PendingMaterialActionType.update;
    case 'material_delete':
      return PendingMaterialActionType.delete;
    case 'material_submit':
      return PendingMaterialActionType.submit;
    case 'material_reset':
      return PendingMaterialActionType.reset;
    default:
      return PendingMaterialActionType.unknown;
  }
}

@immutable
class PendingMaterialAction {
  const PendingMaterialAction({
    required this.type,
    required this.createdAt,
    this.materialId,
    this.material,
    this.quantity,
    this.previousQuantity,
    this.remark,
    this.assetGroupName,
    this.itemTypeDesc,
  });

  final PendingMaterialActionType type;
  final DateTime createdAt;
  final String? materialId;
  final ComplaintD? material;
  final String? quantity;
  final String? previousQuantity;
  final String? remark;
  final String? assetGroupName;
  final String? itemTypeDesc;

  bool get hidesRemoteItem =>
      type == PendingMaterialActionType.delete && materialId != null;
}
