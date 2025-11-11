import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'return_item.g.dart';

/// Model for items eligible to be returned (technician view)
abstract class CollectedItem implements Built<CollectedItem, CollectedItemBuilder> {
  @BuiltValueField(wireName: 'woTaskPartsId')
  String? get woTaskPartsId;
  
  @BuiltValueField(wireName: 'partId')
  String? get partId;
  
  @BuiltValueField(wireName: 'partName')
  String? get partName;
  
  @BuiltValueField(wireName: 'partCode')
  String? get partCode;
  
  @BuiltValueField(wireName: 'quantityCollected')
  int? get quantityCollected;
  
  @BuiltValueField(wireName: 'technicianId')
  String? get technicianId;
  
  @BuiltValueField(wireName: 'collectedDate')
  String? get collectedDate;
  
  @BuiltValueField(wireName: 'workOrderNo')
  String? get workOrderNo;
  
  @BuiltValueField(wireName: 'partsInPossession')
  int? get partsInPossession;
  
  @BuiltValueField(wireName: 'quantityAlreadyReturned')
  int? get quantityAlreadyReturned;
  
  @BuiltValueField(wireName: 'quantityAvailableToReturn')
  int? get quantityAvailableToReturn;
  
  @BuiltValueField(wireName: 'hasPendingReturn')
  bool? get hasPendingReturn;
  
  @BuiltValueField(wireName: 'pendingReturnId')
  String? get pendingReturnId;
  
  @BuiltValueField(wireName: 'pendingReturnQuantity')
  int? get pendingReturnQuantity;
  
  CollectedItem._();
  factory CollectedItem([void Function(CollectedItemBuilder) updates]) = _$CollectedItem;
  
  static Serializer<CollectedItem> get serializer => _$collectedItemSerializer;
}

/// Model for submitting a return request (payload)
abstract class ReturnRequest implements Built<ReturnRequest, ReturnRequestBuilder> {
  @BuiltValueField(wireName: 'woTaskPartsId')
  String? get woTaskPartsId;
  
  @BuiltValueField(wireName: 'quantityReturned')
  int? get quantityReturned;
  
  @BuiltValueField(wireName: 'returnReason')
  String? get returnReason;
  
  @BuiltValueField(wireName: 'returnRemarks')
  String? get returnRemarks;
  
  @BuiltValueField(wireName: 'returnDeadlineDate')
  String? get returnDeadlineDate;
  
  ReturnRequest._();
  factory ReturnRequest([void Function(ReturnRequestBuilder) updates]) = _$ReturnRequest;
  
  static Serializer<ReturnRequest> get serializer => _$returnRequestSerializer;
}

/// Model for pending returns (storekeeper view)
abstract class PendingReturn implements Built<PendingReturn, PendingReturnBuilder> {
  @BuiltValueField(wireName: 'returnId')
  String? get returnId;
  
  @BuiltValueField(wireName: 'woTaskPartsId')
  String? get woTaskPartsId;
  
  @BuiltValueField(wireName: 'partId')
  String? get partId;
  
  @BuiltValueField(wireName: 'technicianUserId')
  String? get technicianUserId;
  
  @BuiltValueField(wireName: 'quantityReturned')
  int? get quantityReturned;
  
  @BuiltValueField(wireName: 'returnStatus')
  String? get returnStatus;
  
  @BuiltValueField(wireName: 'returnReason')
  String? get returnReason;
  
  @BuiltValueField(wireName: 'returnRemarks')
  String? get returnRemarks;
  
  @BuiltValueField(wireName: 'returnRequestDate')
  String? get returnRequestDate;
  
  @BuiltValueField(wireName: 'returnDeadlineDate')
  String? get returnDeadlineDate;
  
  @BuiltValueField(wireName: 'returnConfirmedDate')
  String? get returnConfirmedDate;
  
  @BuiltValueField(wireName: 'storekeeperUserId')
  String? get storekeeperUserId;
  
  @BuiltValueField(wireName: 'partName')
  String? get partName;
  
  @BuiltValueField(wireName: 'partCode')
  String? get partCode;
  
  @BuiltValueField(wireName: 'partUnit')
  String? get partUnit;
  
  @BuiltValueField(wireName: 'technicianName')
  String? get technicianName;
  
  @BuiltValueField(wireName: 'workOrderNo')
  String? get workOrderNo;
  
  @BuiltValueField(wireName: 'siteName')
  String? get siteName;
  
  PendingReturn._();
  factory PendingReturn([void Function(PendingReturnBuilder) updates]) = _$PendingReturn;
  
  static Serializer<PendingReturn> get serializer => _$pendingReturnSerializer;
}
