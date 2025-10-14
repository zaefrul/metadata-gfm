import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:GEMS/data/local/offline_database.dart';
import 'package:GEMS/model/execution.dart';
import 'package:GEMS/model/serializers.dart';
import 'package:GEMS/model/workorder.dart';
import 'package:GEMS/utils/network.dart';
import 'package:flutter/foundation.dart';

import '../../main.dart';

enum WorkOrderActionResult { success, queued }

class WorkOrderDetailRepository {
  WorkOrderDetailRepository({
    OfflineDatabase? database,
    DateTime Function()? clock,
  })  : _database = database ?? OfflineDatabase.instance,
        _clock = clock ?? DateTime.now;

  final OfflineDatabase _database;
  final DateTime Function() _clock;

  Future<void> setOfflineMode({
    required String workOrderId,
    required bool enabled,
    String? currentStatus,
  }) async {
    if (enabled && currentStatus != null) {
      try {
        await getSections(
          workOrderId: workOrderId,
          currentStatus: currentStatus,
          forceRefresh: true,
        );
      } catch (err) {
        debugPrint('Prefetch sections for offline failed: $err');
      }
      try {
        await getExecution(
          workOrderId: workOrderId,
          forceRefresh: true,
        );
      } catch (err) {
        debugPrint('Prefetch execution for offline failed: $err');
      }
      try {
        await getComplaintDetail(
          workOrderId: workOrderId,
          forceRefresh: true,
        );
      } catch (err) {
        debugPrint('Prefetch complaint detail for offline failed: $err');
      }
      try {
        await getRepairImages(
          workOrderId: workOrderId,
          forceRefresh: true,
        );
      } catch (err) {
        debugPrint('Prefetch repair images for offline failed: $err');
      }
    }
    await _database.setWorkOrderOfflineMode(workOrderId, enabled);
  }

  Future<bool> isOfflineModeEnabled(String workOrderId) {
    return _database.isWorkOrderOfflineMode(workOrderId);
  }

  Future<List<WorkOrderStatus>> getSections({
    required String workOrderId,
    required String currentStatus,
    bool forceRefresh = false,
    void Function(List<WorkOrderStatus>)? onRemoteUpdate,
  }) async {
    final cached = await _database.getSections(workOrderId);
    final forcedOffline = await _database.isWorkOrderOfflineMode(workOrderId);
    if (cached.isNotEmpty && (!forceRefresh || forcedOffline)) {
      final sections = cached.map(_statusFromEntity).toList();
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

    if (forcedOffline && cached.isNotEmpty) {
      return cached.map(_statusFromEntity).toList();
    }

    return _refreshSections(
      workOrderId: workOrderId,
      currentStatus: currentStatus,
    );
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
        unawaited(_refreshComplaintDetail(workOrderId: workOrderId).then((value) {
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

  Future<void> syncPendingActions() async {
    final pending = await _database.getPendingActions();
    if (pending.isEmpty) return;

    for (final action in pending) {
      try {
        final body = json.decode(action.payloadJson) as Map<String, dynamic>;
        await _post(body);
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
    return response.technicianImages?.toList() ?? const <TechnicianImageRepair>[];
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
