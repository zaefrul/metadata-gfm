import 'dart:convert';

import 'package:flutter/material.dart';

/// Represents a single part instance (part_sub) that is eligible for return.
class ReturnPartInstance {
  final String woTaskNo;
  final String woTaskRequestNo;
  final String woTaskRequestId;
  final String woTaskPartsId;
  final String partId;
  final String itemDescription;
  final String partSubId;
  final String partSubNo;
  final String? checkOutTime;
  final String? partSubStatus;
  final int quantityCollected;
  final int quantityAlreadyReturned;
  final int quantityAvailableToReturn;

  const ReturnPartInstance({
    required this.woTaskNo,
    required this.woTaskRequestNo,
    required this.woTaskRequestId,
    required this.woTaskPartsId,
    required this.partId,
    required this.itemDescription,
    required this.partSubId,
    required this.partSubNo,
    this.checkOutTime,
    this.partSubStatus,
    this.quantityCollected = 1,
    this.quantityAlreadyReturned = 0,
    this.quantityAvailableToReturn = 1,
  });

  factory ReturnPartInstance.fromSummary(ReturnQuantitySummary summary) {
    return ReturnPartInstance(
      woTaskNo: summary.woTaskNo,
      woTaskRequestNo: summary.woTaskRequestNo,
      woTaskRequestId: summary.woTaskRequestId,
      woTaskPartsId: summary.woTaskPartsId,
      partId: summary.partId,
      itemDescription: summary.itemDescription,
      partSubId: '',
      partSubNo: '',
      partSubStatus: '36',
      quantityCollected: summary.quantityCollected,
      quantityAlreadyReturned: summary.quantityAlreadyReturned,
      quantityAvailableToReturn: summary.quantityAvailableToReturn,
    );
  }

  factory ReturnPartInstance.fromJson(Map<String, dynamic> json) {
    String _string(dynamic value) => value?.toString() ?? '';
    int _int(dynamic value) {
      if (value == null) return 0;
      if (value is num) return value.toInt();
      return int.tryParse(value.toString()) ?? 0;
    }

    final partSubId = _string(json['partSubId']);
    final collected =
        _int(json['quantityCollected'] ?? json['woTaskPartsQuantity'] ?? 1);
    final alreadyReturned =
        _int(json['quantityAlreadyReturned'] ?? json['quantityReturned']);
    final available = _int(json['quantityAvailableToReturn'] ??
        json['quantityPending'] ??
        json['quantityBalance']);
    final status = json['partSubStatus']?.toString();

    int resolvedAvailable = available;
    if (resolvedAvailable <= 0) {
      if (partSubId.isNotEmpty) {
        resolvedAvailable = status == '36' ? 1 : 0;
      } else {
        final computed = collected - alreadyReturned;
        if (computed > 0) {
          resolvedAvailable = computed;
        } else {
          resolvedAvailable = 0;
        }
      }
    }

    // console json
    debugPrint(jsonEncode(json));

    return ReturnPartInstance(
      woTaskNo: _string(json['woTaskNo'] ?? json['workOrderNo']),
      woTaskRequestNo: _string(json['woTaskRequestNo']),
      woTaskRequestId: _string(json['woTaskRequestId']),
      woTaskPartsId: _string(json['woTaskPartsId']),
      partId: _string(json['partId']),
      itemDescription: _string(json['itemDescription']),
      partSubId: partSubId,
      partSubNo: _string(json['partSubNo']),
      checkOutTime: json['checkOutTime']?.toString(),
      partSubStatus: status,
      quantityCollected: collected > 0 ? collected : 1,
      quantityAlreadyReturned: alreadyReturned,
      quantityAvailableToReturn:
          resolvedAvailable > 0 ? resolvedAvailable : 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'woTaskNo': woTaskNo,
      'woTaskRequestNo': woTaskRequestNo,
      'woTaskRequestId': woTaskRequestId,
      'woTaskPartsId': woTaskPartsId,
      'partId': partId,
      'itemDescription': itemDescription,
      'partSubId': partSubId,
      'partSubNo': partSubNo,
      'checkOutTime': checkOutTime,
      'partSubStatus': partSubStatus,
      'quantityCollected': quantityCollected,
      'quantityAlreadyReturned': quantityAlreadyReturned,
      'quantityAvailableToReturn': quantityAvailableToReturn,
    };
  }

  bool get isCollected => partSubStatus == '36';
  bool get isSerialized => partSubId.isNotEmpty;
  bool get supportsQuantityInput => !isSerialized;
}

class ReturnQuantitySummary {
  final String woTaskNo;
  final String woTaskRequestNo;
  final String woTaskRequestId;
  final String woTaskPartsId;
  final String partId;
  final String itemDescription;
  final int quantityCollected;
  final int partsInPossession;
  final int quantityAvailableToReturn;
  final int quantityAlreadyReturned;

  const ReturnQuantitySummary({
    required this.woTaskNo,
    required this.woTaskRequestNo,
    required this.woTaskRequestId,
    required this.woTaskPartsId,
    required this.partId,
    required this.itemDescription,
    required this.quantityCollected,
    required this.partsInPossession,
    required this.quantityAvailableToReturn,
    required this.quantityAlreadyReturned,
  });

  factory ReturnQuantitySummary.fromJson(Map<String, dynamic> json) {
    String _string(dynamic value) => value?.toString() ?? '';
    int _int(dynamic value) {
      if (value == null) return 0;
      if (value is num) return value.toInt();
      return int.tryParse(value.toString()) ?? 0;
    }

    return ReturnQuantitySummary(
      woTaskNo: _string(json['woTaskNo'] ?? json['workOrderNo']),
      woTaskRequestNo: _string(json['woTaskRequestNo']),
      woTaskRequestId: _string(json['woTaskRequestId']),
      woTaskPartsId: _string(json['woTaskPartsId']),
      partId: _string(json['partId']),
      itemDescription: _string(
          json['itemDescription'] ?? json['partName'] ?? json['partDescription']),
      quantityCollected: _int(json['quantityCollected']),
      partsInPossession: _int(json['partsInPossession']),
      quantityAvailableToReturn: _int(json['quantityAvailableToReturn']),
      quantityAlreadyReturned: _int(json['quantityAlreadyReturned']),
    );
  }
}

class ReturnPartGroup {
  final String partId;
  final String itemDescription;
  final List<ReturnPartInstance> instances;

  const ReturnPartGroup({
  required this.partId,
  required this.itemDescription,
  required this.instances,
  });

  int get totalCollected => instances.fold(0, (sum, item) => sum + item.quantityCollected);
  int get totalReturned =>
    instances.fold(0, (sum, item) => sum + item.quantityAlreadyReturned);
  int get totalAvailable =>
    instances.fold(0, (sum, item) => sum + item.quantityAvailableToReturn);

  bool get hasSerialized => instances.any((item) => item.isSerialized);
  bool get hasBulk => instances.any((item) => !item.isSerialized);

  List<ReturnPartInstance> get serializedInstances => instances
    .where((item) => item.isSerialized && item.quantityAvailableToReturn > 0)
    .toList(growable: false);

  List<ReturnPartInstance> get bulkBuckets => instances
    .where((item) => !item.isSerialized && item.quantityAvailableToReturn > 0)
    .toList(growable: false);
}

/// Payload item used when submitting a return request.
class ReturnPartsRequestItem {
  final List<String>? partSubIds;
  final String? woTaskPartsId;
  final int? quantity;
  final String returnReason;
  final String? returnRemarks;

  const ReturnPartsRequestItem({
    this.partSubIds,
    this.woTaskPartsId,
    this.quantity,
    required this.returnReason,
    this.returnRemarks,
  }) : assert(partSubIds != null || (woTaskPartsId != null && quantity != null),
            'Either partSubIds or (woTaskPartsId & quantity) must be provided');

  Map<String, dynamic> toJson() {
    return {
      if (partSubIds != null) 'partSubIds': partSubIds,
      if (woTaskPartsId != null) 'woTaskPartsId': woTaskPartsId,
      if (quantity != null) 'quantity': quantity,
      'returnReason': returnReason,
      if (returnRemarks != null && returnRemarks!.isNotEmpty) 'returnRemarks': returnRemarks,
    };
  }
}

/// Server response after submitting returns.
class ReturnSubmissionResult {
  final int totalReturned;
  final List<String> returnTicketIds;
  final List<ReturnSubmissionItem> items;

  const ReturnSubmissionResult({
    required this.totalReturned,
    required this.returnTicketIds,
    required this.items,
  });

  factory ReturnSubmissionResult.fromJson(Map<String, dynamic> json) {
    final List<dynamic> ticketArray = json['returnTicketIds'] as List<dynamic>? ?? [];
    final List<dynamic> itemArray = json['items'] as List<dynamic>? ?? [];

    return ReturnSubmissionResult(
      totalReturned: int.tryParse(json['totalReturned']?.toString() ?? '') ?? 0,
      returnTicketIds: ticketArray.map((e) => e.toString()).toList(growable: false),
      items: itemArray
          .map((e) => ReturnSubmissionItem.fromJson(e as Map<String, dynamic>))
          .toList(growable: false),
    );
  }
}

class ReturnSubmissionItem {
  final String returnTicketId;
  final String returnReason;
  final String? returnRemarks;
  final String woTaskRequestId;
  final String woTaskPartsId;
  final String partId;
  final int quantityReturned;
  final List<String> partSubIds;
  final String woTaskNo;
  final String woTaskRequestNo;

  const ReturnSubmissionItem({
    required this.returnTicketId,
    required this.returnReason,
    this.returnRemarks,
    required this.woTaskRequestId,
    required this.woTaskPartsId,
    required this.partId,
    required this.quantityReturned,
    required this.partSubIds,
    required this.woTaskNo,
    required this.woTaskRequestNo,
  });

  factory ReturnSubmissionItem.fromJson(Map<String, dynamic> json) {
    final List<dynamic> ids = json['partSubIds'] as List<dynamic>? ?? [];
    final ticketId = json['returnTicketId'] ?? json['returnId'];
    return ReturnSubmissionItem(
      returnTicketId: ticketId?.toString() ?? '',
      returnReason: json['returnReason']?.toString() ?? '',
      returnRemarks: json['returnRemarks']?.toString(),
      woTaskRequestId: json['woTaskRequestId']?.toString() ?? '',
      woTaskPartsId: json['woTaskPartsId']?.toString() ?? '',
      partId: json['partId']?.toString() ?? '',
      quantityReturned: int.tryParse(json['quantityReturned']?.toString() ?? '') ?? 0,
      partSubIds: ids.map((e) => e.toString()).toList(growable: false),
      woTaskNo: json['woTaskNo']?.toString() ?? '',
      woTaskRequestNo: json['woTaskRequestNo']?.toString() ?? '',
    );
  }
}

/// Summary entry returned by /list_return_verification.
class ReturnTicketSummary {
  final String returnTicketId;
  final String woTaskNo;
  final String woTaskRequestNo;
  final String technicianName;
  final String siteName;
  final String? siteId;
  final DateTime? submittedAt;
  final int itemCount;
  final List<String> partSubIds;
  final List<ReturnTicketItem> items;

  const ReturnTicketSummary({
    required this.returnTicketId,
    required this.woTaskNo,
    required this.woTaskRequestNo,
    required this.technicianName,
    required this.siteName,
    required this.siteId,
    required this.submittedAt,
    required this.itemCount,
    required this.partSubIds,
    required this.items,
  });

  factory ReturnTicketSummary.fromJson(Map<String, dynamic> json) {
    DateTime? parseDate(String? value) {
      if (value == null || value.isEmpty) return null;
      return DateTime.tryParse(value);
    }

    final List<dynamic> ids = json['partSubIds'] as List<dynamic>? ?? [];
    final List<dynamic> detail = json['items'] as List<dynamic>? ?? [];
    final ticketId = json['returnTicketId'] ?? json['returnId'];
    String _string(dynamic value) => value?.toString() ?? '';

    return ReturnTicketSummary(
      returnTicketId: ticketId?.toString() ?? '',
      woTaskNo: _string(json['woTaskNo'] ?? json['workOrderNo']),
      woTaskRequestNo: _string(json['woTaskRequestNo']),
      technicianName: _string(json['technicianName'] ?? json['technician']),
      siteName: _string(json['siteName']),
      siteId: json['siteId']?.toString(),
      submittedAt: parseDate(json['submittedAt']?.toString()),
      itemCount: int.tryParse(json['itemCount']?.toString() ?? '') ?? detail.length,
      partSubIds: ids.map((e) => e.toString()).toList(growable: false),
      items: detail
          .map((e) => ReturnTicketItem.fromJson(e as Map<String, dynamic>))
          .toList(growable: false),
    );
  }
}

class ReturnTicketItem {
  final String partSubId;
  final String? partSubNo;
  final String itemDescription;
  final String woTaskNo;
  final String woTaskRequestNo;
  final String woTaskRequestId;
  final String woTaskPartsId;
  final String partId;
  final String? status;
  final String? remark;
  final int quantityReturned;

  const ReturnTicketItem({
    required this.partSubId,
    this.partSubNo,
    required this.itemDescription,
    required this.woTaskNo,
    required this.woTaskRequestNo,
    required this.woTaskRequestId,
    required this.woTaskPartsId,
    required this.partId,
    required this.status,
    required this.remark,
    required this.quantityReturned,
  });

  factory ReturnTicketItem.fromJson(Map<String, dynamic> json) {
    int _int(dynamic value) {
      if (value == null) return 0;
      if (value is num) return value.toInt();
      return int.tryParse(value.toString()) ?? 0;
    }

    final partSubId = json['partSubId']?.toString() ?? '';
    final rawQty = _int(json['quantityReturned']);
    final resolvedQty = rawQty > 0
        ? rawQty
        : partSubId.isNotEmpty
            ? 1
            : 0;

    return ReturnTicketItem(
      partSubId: partSubId,
      partSubNo: json['partSubNo']?.toString(),
      itemDescription: json['itemDescription']?.toString() ?? '',
      woTaskNo: json['woTaskNo']?.toString() ?? '',
      woTaskRequestNo: json['woTaskRequestNo']?.toString() ?? '',
      woTaskRequestId: json['woTaskRequestId']?.toString() ?? '',
      woTaskPartsId: json['woTaskPartsId']?.toString() ?? '',
      partId: json['partId']?.toString() ?? '',
      status: json['status']?.toString(),
      remark: json['remark']?.toString(),
      quantityReturned: resolvedQty,
    );
  }

  bool get isPending => status == null || status == '37';
  bool get isApproved => status == '46';
  bool get isRejected => status == '38';
}

class ReturnVerifyResult {
  final String returnTicketId;
  final String action;
  final int approvedCount;
  final int rejectedCount;
  final int pendingCount;
  final List<ReturnVerifyItem> items;

  const ReturnVerifyResult({
    required this.returnTicketId,
    required this.action,
    required this.approvedCount,
    required this.rejectedCount,
    required this.pendingCount,
    required this.items,
  });

  factory ReturnVerifyResult.fromJson(Map<String, dynamic> json) {
    final List<dynamic> detail = json['items'] as List<dynamic>? ?? [];
    final ticketId = json['returnTicketId'] ?? json['returnId'];

    return ReturnVerifyResult(
      returnTicketId: ticketId?.toString() ?? '',
      action: json['action']?.toString() ?? '',
      approvedCount: int.tryParse(json['approvedCount']?.toString() ?? '') ?? 0,
      rejectedCount: int.tryParse(json['rejectedCount']?.toString() ?? '') ?? 0,
      pendingCount: int.tryParse(json['pendingCount']?.toString() ?? '') ?? 0,
      items: detail
          .map((e) => ReturnVerifyItem.fromJson(e as Map<String, dynamic>))
          .toList(growable: false),
    );
  }
}

class ReturnVerifyItem {
  final String partSubId;
  final String status;
  final String? remark;

  const ReturnVerifyItem({
    required this.partSubId,
    required this.status,
    this.remark,
  });

  factory ReturnVerifyItem.fromJson(Map<String, dynamic> json) {
    return ReturnVerifyItem(
      partSubId: json['partSubId']?.toString() ?? '',
      status: json['status']?.toString() ?? '',
      remark: json['remark']?.toString(),
    );
  }
}

/// Simple helper to pretty print payloads while debugging.
String prettyPrintJson(Object? value) {
  const encoder = JsonEncoder.withIndent('  ');
  return encoder.convert(value);
}
