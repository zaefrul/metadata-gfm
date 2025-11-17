import 'dart:typed_data';

/// Entity for pending PPM actions stored in SQLite
class PPMPendingActionEntity {
  final int? id;
  final String ppmTaskId;
  final String action; // 'upload_maintenance_image', 'upload_additional_report', 'save_form_c', etc.
  final String payloadJson;
  final DateTime createdAt;
  final String actionId; // UUID for batch sync tracking

  PPMPendingActionEntity({
    this.id,
    required this.ppmTaskId,
    required this.action,
    required this.payloadJson,
    required this.createdAt,
    required this.actionId,
  });

  Map<String, dynamic> toMap() {
    return {
      if (id != null) 'id': id,
      'ppm_task_id': ppmTaskId,
      'action': action,
      'payload_json': payloadJson,
      'created_at': createdAt.toIso8601String(),
      'action_id': actionId,
    };
  }

  static PPMPendingActionEntity fromMap(Map<String, dynamic> map) {
    return PPMPendingActionEntity(
      id: map['id'] as int?,
      ppmTaskId: map['ppm_task_id'] as String,
      action: map['action'] as String,
      payloadJson: map['payload_json'] as String,
      createdAt: DateTime.parse(map['created_at'] as String),
      actionId: map['action_id'] as String? ?? '', // Default for old records
    );
  }
}

/// Represents a pending maintenance image waiting to be synced
class PendingMaintenanceImage {
  final String uploadType; // 'Before', 'During', 'After'
  final Uint8List bytes;
  final DateTime createdAt;
  final String? latitude;
  final String? longitude;
  final String? displayName;

  PendingMaintenanceImage({
    required this.uploadType,
    required this.bytes,
    required this.createdAt,
    this.latitude,
    this.longitude,
    this.displayName,
  });
}

/// Represents a pending additional report (Form F) waiting to be synced
class PendingAdditionalReport {
  final String name;
  final Uint8List bytes;
  final DateTime createdAt;

  PendingAdditionalReport({
    required this.name,
    required this.bytes,
    required this.createdAt,
  });
}

/// Entity for PPM task metadata stored in SQLite (for caching)
class PPMTaskEntity {
  final String ppmTaskId;
  final String taskNo;
  final String siteName;
  final String status;
  final DateTime? lastSync;
  final String? dataJson; // Cached JSON response

  PPMTaskEntity({
    required this.ppmTaskId,
    required this.taskNo,
    required this.siteName,
    required this.status,
    this.lastSync,
    this.dataJson,
  });

  Map<String, dynamic> toMap() {
    return {
      'ppm_task_id': ppmTaskId,
      'task_no': taskNo,
      'site_name': siteName,
      'status': status,
      'last_sync': lastSync?.toIso8601String(),
      'data_json': dataJson,
    };
  }

  static PPMTaskEntity fromMap(Map<String, dynamic> map) {
    return PPMTaskEntity(
      ppmTaskId: map['ppm_task_id'] as String,
      taskNo: map['task_no'] as String,
      siteName: map['site_name'] as String,
      status: map['status'] as String,
      lastSync: map['last_sync'] != null 
          ? DateTime.parse(map['last_sync'] as String) 
          : null,
      dataJson: map['data_json'] as String?,
    );
  }
}

/// Entity for Form H maintenance images stored in SQLite
class PPMMaintenanceImageEntity {
  final String ppmTaskUploadId;
  final String ppmTaskId;
  final String uploadType; // 'Before', 'During', 'After'
  final String? latitude;
  final String? longitude;
  final String? timestamp;
  final String? description;
  final String? uploadId;
  final String? uploadName;
  final String? documentDesc;
  final String? documentFilename;
  final String? documentSrc;

  PPMMaintenanceImageEntity({
    required this.ppmTaskUploadId,
    required this.ppmTaskId,
    required this.uploadType,
    this.latitude,
    this.longitude,
    this.timestamp,
    this.description,
    this.uploadId,
    this.uploadName,
    this.documentDesc,
    this.documentFilename,
    this.documentSrc,
  });

  Map<String, dynamic> toMap() {
    return {
      'ppm_task_upload_id': ppmTaskUploadId,
      'ppm_task_id': ppmTaskId,
      'upload_type': uploadType,
      'latitude': latitude,
      'longitude': longitude,
      'timestamp': timestamp,
      'description': description,
      'upload_id': uploadId,
      'upload_name': uploadName,
      'document_desc': documentDesc,
      'document_filename': documentFilename,
      'document_src': documentSrc,
    };
  }

  static PPMMaintenanceImageEntity fromMap(Map<String, dynamic> map) {
    return PPMMaintenanceImageEntity(
      ppmTaskUploadId: map['ppm_task_upload_id'] as String,
      ppmTaskId: map['ppm_task_id'] as String,
      uploadType: map['upload_type'] as String,
      latitude: map['latitude'] as String?,
      longitude: map['longitude'] as String?,
      timestamp: map['timestamp'] as String?,
      description: map['description'] as String?,
      uploadId: map['upload_id'] as String?,
      uploadName: map['upload_name'] as String?,
      documentDesc: map['document_desc'] as String?,
      documentFilename: map['document_filename'] as String?,
      documentSrc: map['document_src'] as String?,
    );
  }
}
