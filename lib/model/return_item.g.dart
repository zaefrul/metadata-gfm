// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'return_item.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

Serializer<CollectedItem> _$collectedItemSerializer =
    _$CollectedItemSerializer();
Serializer<ReturnRequest> _$returnRequestSerializer =
    _$ReturnRequestSerializer();
Serializer<PendingReturn> _$pendingReturnSerializer =
    _$PendingReturnSerializer();

class _$CollectedItemSerializer implements StructuredSerializer<CollectedItem> {
  @override
  final Iterable<Type> types = const [CollectedItem, _$CollectedItem];
  @override
  final String wireName = 'CollectedItem';

  @override
  Iterable<Object?> serialize(Serializers serializers, CollectedItem object,
      {FullType specifiedType = FullType.unspecified}) {
    final result = <Object?>[];
    Object? value;
    value = object.woTaskPartsId;
    if (value != null) {
      result
        ..add('woTaskPartsId')
        ..add(serializers.serialize(value,
            specifiedType: const FullType(String)));
    }
    value = object.partId;
    if (value != null) {
      result
        ..add('partId')
        ..add(serializers.serialize(value,
            specifiedType: const FullType(String)));
    }
    value = object.partName;
    if (value != null) {
      result
        ..add('partName')
        ..add(serializers.serialize(value,
            specifiedType: const FullType(String)));
    }
    value = object.partCode;
    if (value != null) {
      result
        ..add('partCode')
        ..add(serializers.serialize(value,
            specifiedType: const FullType(String)));
    }
    value = object.quantityCollected;
    if (value != null) {
      result
        ..add('quantityCollected')
        ..add(serializers.serialize(value, specifiedType: const FullType(int)));
    }
    value = object.technicianId;
    if (value != null) {
      result
        ..add('technicianId')
        ..add(serializers.serialize(value,
            specifiedType: const FullType(String)));
    }
    value = object.collectedDate;
    if (value != null) {
      result
        ..add('collectedDate')
        ..add(serializers.serialize(value,
            specifiedType: const FullType(String)));
    }
    value = object.workOrderNo;
    if (value != null) {
      result
        ..add('workOrderNo')
        ..add(serializers.serialize(value,
            specifiedType: const FullType(String)));
    }
    value = object.partsInPossession;
    if (value != null) {
      result
        ..add('partsInPossession')
        ..add(serializers.serialize(value, specifiedType: const FullType(int)));
    }
    value = object.quantityAlreadyReturned;
    if (value != null) {
      result
        ..add('quantityAlreadyReturned')
        ..add(serializers.serialize(value, specifiedType: const FullType(int)));
    }
    value = object.quantityAvailableToReturn;
    if (value != null) {
      result
        ..add('quantityAvailableToReturn')
        ..add(serializers.serialize(value, specifiedType: const FullType(int)));
    }
    value = object.hasPendingReturn;
    if (value != null) {
      result
        ..add('hasPendingReturn')
        ..add(
            serializers.serialize(value, specifiedType: const FullType(bool)));
    }
    value = object.pendingReturnId;
    if (value != null) {
      result
        ..add('pendingReturnId')
        ..add(serializers.serialize(value,
            specifiedType: const FullType(String)));
    }
    value = object.pendingReturnQuantity;
    if (value != null) {
      result
        ..add('pendingReturnQuantity')
        ..add(serializers.serialize(value, specifiedType: const FullType(int)));
    }
    return result;
  }

  @override
  CollectedItem deserialize(
      Serializers serializers, Iterable<Object?> serialized,
      {FullType specifiedType = FullType.unspecified}) {
    final result = CollectedItemBuilder();

    final iterator = serialized.iterator;
    while (iterator.moveNext()) {
      final key = iterator.current! as String;
      iterator.moveNext();
      final Object? value = iterator.current;
      switch (key) {
        case 'woTaskPartsId':
          result.woTaskPartsId = serializers.deserialize(value,
              specifiedType: const FullType(String)) as String?;
          break;
        case 'partId':
          result.partId = serializers.deserialize(value,
              specifiedType: const FullType(String)) as String?;
          break;
        case 'partName':
          result.partName = serializers.deserialize(value,
              specifiedType: const FullType(String)) as String?;
          break;
        case 'partCode':
          result.partCode = serializers.deserialize(value,
              specifiedType: const FullType(String)) as String?;
          break;
        case 'quantityCollected':
          result.quantityCollected = serializers.deserialize(value,
              specifiedType: const FullType(int)) as int?;
          break;
        case 'technicianId':
          result.technicianId = serializers.deserialize(value,
              specifiedType: const FullType(String)) as String?;
          break;
        case 'collectedDate':
          result.collectedDate = serializers.deserialize(value,
              specifiedType: const FullType(String)) as String?;
          break;
        case 'workOrderNo':
          result.workOrderNo = serializers.deserialize(value,
              specifiedType: const FullType(String)) as String?;
          break;
        case 'partsInPossession':
          result.partsInPossession = serializers.deserialize(value,
              specifiedType: const FullType(int)) as int?;
          break;
        case 'quantityAlreadyReturned':
          result.quantityAlreadyReturned = serializers.deserialize(value,
              specifiedType: const FullType(int)) as int?;
          break;
        case 'quantityAvailableToReturn':
          result.quantityAvailableToReturn = serializers.deserialize(value,
              specifiedType: const FullType(int)) as int?;
          break;
        case 'hasPendingReturn':
          result.hasPendingReturn = serializers.deserialize(value,
              specifiedType: const FullType(bool)) as bool?;
          break;
        case 'pendingReturnId':
          result.pendingReturnId = serializers.deserialize(value,
              specifiedType: const FullType(String)) as String?;
          break;
        case 'pendingReturnQuantity':
          result.pendingReturnQuantity = serializers.deserialize(value,
              specifiedType: const FullType(int)) as int?;
          break;
      }
    }

    return result.build();
  }
}

class _$ReturnRequestSerializer implements StructuredSerializer<ReturnRequest> {
  @override
  final Iterable<Type> types = const [ReturnRequest, _$ReturnRequest];
  @override
  final String wireName = 'ReturnRequest';

  @override
  Iterable<Object?> serialize(Serializers serializers, ReturnRequest object,
      {FullType specifiedType = FullType.unspecified}) {
    final result = <Object?>[];
    Object? value;
    value = object.woTaskPartsId;
    if (value != null) {
      result
        ..add('woTaskPartsId')
        ..add(serializers.serialize(value,
            specifiedType: const FullType(String)));
    }
    value = object.quantityReturned;
    if (value != null) {
      result
        ..add('quantityReturned')
        ..add(serializers.serialize(value, specifiedType: const FullType(int)));
    }
    value = object.returnReason;
    if (value != null) {
      result
        ..add('returnReason')
        ..add(serializers.serialize(value,
            specifiedType: const FullType(String)));
    }
    value = object.returnRemarks;
    if (value != null) {
      result
        ..add('returnRemarks')
        ..add(serializers.serialize(value,
            specifiedType: const FullType(String)));
    }
    value = object.returnDeadlineDate;
    if (value != null) {
      result
        ..add('returnDeadlineDate')
        ..add(serializers.serialize(value,
            specifiedType: const FullType(String)));
    }
    return result;
  }

  @override
  ReturnRequest deserialize(
      Serializers serializers, Iterable<Object?> serialized,
      {FullType specifiedType = FullType.unspecified}) {
    final result = ReturnRequestBuilder();

    final iterator = serialized.iterator;
    while (iterator.moveNext()) {
      final key = iterator.current! as String;
      iterator.moveNext();
      final Object? value = iterator.current;
      switch (key) {
        case 'woTaskPartsId':
          result.woTaskPartsId = serializers.deserialize(value,
              specifiedType: const FullType(String)) as String?;
          break;
        case 'quantityReturned':
          result.quantityReturned = serializers.deserialize(value,
              specifiedType: const FullType(int)) as int?;
          break;
        case 'returnReason':
          result.returnReason = serializers.deserialize(value,
              specifiedType: const FullType(String)) as String?;
          break;
        case 'returnRemarks':
          result.returnRemarks = serializers.deserialize(value,
              specifiedType: const FullType(String)) as String?;
          break;
        case 'returnDeadlineDate':
          result.returnDeadlineDate = serializers.deserialize(value,
              specifiedType: const FullType(String)) as String?;
          break;
      }
    }

    return result.build();
  }
}

class _$PendingReturnSerializer implements StructuredSerializer<PendingReturn> {
  @override
  final Iterable<Type> types = const [PendingReturn, _$PendingReturn];
  @override
  final String wireName = 'PendingReturn';

  @override
  Iterable<Object?> serialize(Serializers serializers, PendingReturn object,
      {FullType specifiedType = FullType.unspecified}) {
    final result = <Object?>[];
    Object? value;
    value = object.returnId;
    if (value != null) {
      result
        ..add('returnId')
        ..add(serializers.serialize(value,
            specifiedType: const FullType(String)));
    }
    value = object.woTaskPartsId;
    if (value != null) {
      result
        ..add('woTaskPartsId')
        ..add(serializers.serialize(value,
            specifiedType: const FullType(String)));
    }
    value = object.partId;
    if (value != null) {
      result
        ..add('partId')
        ..add(serializers.serialize(value,
            specifiedType: const FullType(String)));
    }
    value = object.technicianUserId;
    if (value != null) {
      result
        ..add('technicianUserId')
        ..add(serializers.serialize(value,
            specifiedType: const FullType(String)));
    }
    value = object.quantityReturned;
    if (value != null) {
      result
        ..add('quantityReturned')
        ..add(serializers.serialize(value, specifiedType: const FullType(int)));
    }
    value = object.returnStatus;
    if (value != null) {
      result
        ..add('returnStatus')
        ..add(serializers.serialize(value,
            specifiedType: const FullType(String)));
    }
    value = object.returnReason;
    if (value != null) {
      result
        ..add('returnReason')
        ..add(serializers.serialize(value,
            specifiedType: const FullType(String)));
    }
    value = object.returnRemarks;
    if (value != null) {
      result
        ..add('returnRemarks')
        ..add(serializers.serialize(value,
            specifiedType: const FullType(String)));
    }
    value = object.returnRequestDate;
    if (value != null) {
      result
        ..add('returnRequestDate')
        ..add(serializers.serialize(value,
            specifiedType: const FullType(String)));
    }
    value = object.returnDeadlineDate;
    if (value != null) {
      result
        ..add('returnDeadlineDate')
        ..add(serializers.serialize(value,
            specifiedType: const FullType(String)));
    }
    value = object.returnConfirmedDate;
    if (value != null) {
      result
        ..add('returnConfirmedDate')
        ..add(serializers.serialize(value,
            specifiedType: const FullType(String)));
    }
    value = object.storekeeperUserId;
    if (value != null) {
      result
        ..add('storekeeperUserId')
        ..add(serializers.serialize(value,
            specifiedType: const FullType(String)));
    }
    value = object.partName;
    if (value != null) {
      result
        ..add('partName')
        ..add(serializers.serialize(value,
            specifiedType: const FullType(String)));
    }
    value = object.partCode;
    if (value != null) {
      result
        ..add('partCode')
        ..add(serializers.serialize(value,
            specifiedType: const FullType(String)));
    }
    value = object.partUnit;
    if (value != null) {
      result
        ..add('partUnit')
        ..add(serializers.serialize(value,
            specifiedType: const FullType(String)));
    }
    value = object.technicianName;
    if (value != null) {
      result
        ..add('technicianName')
        ..add(serializers.serialize(value,
            specifiedType: const FullType(String)));
    }
    value = object.workOrderNo;
    if (value != null) {
      result
        ..add('workOrderNo')
        ..add(serializers.serialize(value,
            specifiedType: const FullType(String)));
    }
    value = object.siteName;
    if (value != null) {
      result
        ..add('siteName')
        ..add(serializers.serialize(value,
            specifiedType: const FullType(String)));
    }
    return result;
  }

  @override
  PendingReturn deserialize(
      Serializers serializers, Iterable<Object?> serialized,
      {FullType specifiedType = FullType.unspecified}) {
    final result = PendingReturnBuilder();

    final iterator = serialized.iterator;
    while (iterator.moveNext()) {
      final key = iterator.current! as String;
      iterator.moveNext();
      final Object? value = iterator.current;
      switch (key) {
        case 'returnId':
          result.returnId = serializers.deserialize(value,
              specifiedType: const FullType(String)) as String?;
          break;
        case 'woTaskPartsId':
          result.woTaskPartsId = serializers.deserialize(value,
              specifiedType: const FullType(String)) as String?;
          break;
        case 'partId':
          result.partId = serializers.deserialize(value,
              specifiedType: const FullType(String)) as String?;
          break;
        case 'technicianUserId':
          result.technicianUserId = serializers.deserialize(value,
              specifiedType: const FullType(String)) as String?;
          break;
        case 'quantityReturned':
          result.quantityReturned = serializers.deserialize(value,
              specifiedType: const FullType(int)) as int?;
          break;
        case 'returnStatus':
          result.returnStatus = serializers.deserialize(value,
              specifiedType: const FullType(String)) as String?;
          break;
        case 'returnReason':
          result.returnReason = serializers.deserialize(value,
              specifiedType: const FullType(String)) as String?;
          break;
        case 'returnRemarks':
          result.returnRemarks = serializers.deserialize(value,
              specifiedType: const FullType(String)) as String?;
          break;
        case 'returnRequestDate':
          result.returnRequestDate = serializers.deserialize(value,
              specifiedType: const FullType(String)) as String?;
          break;
        case 'returnDeadlineDate':
          result.returnDeadlineDate = serializers.deserialize(value,
              specifiedType: const FullType(String)) as String?;
          break;
        case 'returnConfirmedDate':
          result.returnConfirmedDate = serializers.deserialize(value,
              specifiedType: const FullType(String)) as String?;
          break;
        case 'storekeeperUserId':
          result.storekeeperUserId = serializers.deserialize(value,
              specifiedType: const FullType(String)) as String?;
          break;
        case 'partName':
          result.partName = serializers.deserialize(value,
              specifiedType: const FullType(String)) as String?;
          break;
        case 'partCode':
          result.partCode = serializers.deserialize(value,
              specifiedType: const FullType(String)) as String?;
          break;
        case 'partUnit':
          result.partUnit = serializers.deserialize(value,
              specifiedType: const FullType(String)) as String?;
          break;
        case 'technicianName':
          result.technicianName = serializers.deserialize(value,
              specifiedType: const FullType(String)) as String?;
          break;
        case 'workOrderNo':
          result.workOrderNo = serializers.deserialize(value,
              specifiedType: const FullType(String)) as String?;
          break;
        case 'siteName':
          result.siteName = serializers.deserialize(value,
              specifiedType: const FullType(String)) as String?;
          break;
      }
    }

    return result.build();
  }
}

class _$CollectedItem extends CollectedItem {
  @override
  final String? woTaskPartsId;
  @override
  final String? partId;
  @override
  final String? partName;
  @override
  final String? partCode;
  @override
  final int? quantityCollected;
  @override
  final String? technicianId;
  @override
  final String? collectedDate;
  @override
  final String? workOrderNo;
  @override
  final int? partsInPossession;
  @override
  final int? quantityAlreadyReturned;
  @override
  final int? quantityAvailableToReturn;
  @override
  final bool? hasPendingReturn;
  @override
  final String? pendingReturnId;
  @override
  final int? pendingReturnQuantity;

  factory _$CollectedItem([void Function(CollectedItemBuilder)? updates]) =>
      (CollectedItemBuilder()..update(updates))._build();

  _$CollectedItem._(
      {this.woTaskPartsId,
      this.partId,
      this.partName,
      this.partCode,
      this.quantityCollected,
      this.technicianId,
      this.collectedDate,
      this.workOrderNo,
      this.partsInPossession,
      this.quantityAlreadyReturned,
      this.quantityAvailableToReturn,
      this.hasPendingReturn,
      this.pendingReturnId,
      this.pendingReturnQuantity})
      : super._();
  @override
  CollectedItem rebuild(void Function(CollectedItemBuilder) updates) =>
      (toBuilder()..update(updates)).build();

  @override
  CollectedItemBuilder toBuilder() => CollectedItemBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is CollectedItem &&
        woTaskPartsId == other.woTaskPartsId &&
        partId == other.partId &&
        partName == other.partName &&
        partCode == other.partCode &&
        quantityCollected == other.quantityCollected &&
        technicianId == other.technicianId &&
        collectedDate == other.collectedDate &&
        workOrderNo == other.workOrderNo &&
        partsInPossession == other.partsInPossession &&
        quantityAlreadyReturned == other.quantityAlreadyReturned &&
        quantityAvailableToReturn == other.quantityAvailableToReturn &&
        hasPendingReturn == other.hasPendingReturn &&
        pendingReturnId == other.pendingReturnId &&
        pendingReturnQuantity == other.pendingReturnQuantity;
  }

  @override
  int get hashCode {
    var _$hash = 0;
    _$hash = $jc(_$hash, woTaskPartsId.hashCode);
    _$hash = $jc(_$hash, partId.hashCode);
    _$hash = $jc(_$hash, partName.hashCode);
    _$hash = $jc(_$hash, partCode.hashCode);
    _$hash = $jc(_$hash, quantityCollected.hashCode);
    _$hash = $jc(_$hash, technicianId.hashCode);
    _$hash = $jc(_$hash, collectedDate.hashCode);
    _$hash = $jc(_$hash, workOrderNo.hashCode);
    _$hash = $jc(_$hash, partsInPossession.hashCode);
    _$hash = $jc(_$hash, quantityAlreadyReturned.hashCode);
    _$hash = $jc(_$hash, quantityAvailableToReturn.hashCode);
    _$hash = $jc(_$hash, hasPendingReturn.hashCode);
    _$hash = $jc(_$hash, pendingReturnId.hashCode);
    _$hash = $jc(_$hash, pendingReturnQuantity.hashCode);
    _$hash = $jf(_$hash);
    return _$hash;
  }

  @override
  String toString() {
    return (newBuiltValueToStringHelper(r'CollectedItem')
          ..add('woTaskPartsId', woTaskPartsId)
          ..add('partId', partId)
          ..add('partName', partName)
          ..add('partCode', partCode)
          ..add('quantityCollected', quantityCollected)
          ..add('technicianId', technicianId)
          ..add('collectedDate', collectedDate)
          ..add('workOrderNo', workOrderNo)
          ..add('partsInPossession', partsInPossession)
          ..add('quantityAlreadyReturned', quantityAlreadyReturned)
          ..add('quantityAvailableToReturn', quantityAvailableToReturn)
          ..add('hasPendingReturn', hasPendingReturn)
          ..add('pendingReturnId', pendingReturnId)
          ..add('pendingReturnQuantity', pendingReturnQuantity))
        .toString();
  }
}

class CollectedItemBuilder
    implements Builder<CollectedItem, CollectedItemBuilder> {
  _$CollectedItem? _$v;

  String? _woTaskPartsId;
  String? get woTaskPartsId => _$this._woTaskPartsId;
  set woTaskPartsId(String? woTaskPartsId) =>
      _$this._woTaskPartsId = woTaskPartsId;

  String? _partId;
  String? get partId => _$this._partId;
  set partId(String? partId) => _$this._partId = partId;

  String? _partName;
  String? get partName => _$this._partName;
  set partName(String? partName) => _$this._partName = partName;

  String? _partCode;
  String? get partCode => _$this._partCode;
  set partCode(String? partCode) => _$this._partCode = partCode;

  int? _quantityCollected;
  int? get quantityCollected => _$this._quantityCollected;
  set quantityCollected(int? quantityCollected) =>
      _$this._quantityCollected = quantityCollected;

  String? _technicianId;
  String? get technicianId => _$this._technicianId;
  set technicianId(String? technicianId) => _$this._technicianId = technicianId;

  String? _collectedDate;
  String? get collectedDate => _$this._collectedDate;
  set collectedDate(String? collectedDate) =>
      _$this._collectedDate = collectedDate;

  String? _workOrderNo;
  String? get workOrderNo => _$this._workOrderNo;
  set workOrderNo(String? workOrderNo) => _$this._workOrderNo = workOrderNo;

  int? _partsInPossession;
  int? get partsInPossession => _$this._partsInPossession;
  set partsInPossession(int? partsInPossession) =>
      _$this._partsInPossession = partsInPossession;

  int? _quantityAlreadyReturned;
  int? get quantityAlreadyReturned => _$this._quantityAlreadyReturned;
  set quantityAlreadyReturned(int? quantityAlreadyReturned) =>
      _$this._quantityAlreadyReturned = quantityAlreadyReturned;

  int? _quantityAvailableToReturn;
  int? get quantityAvailableToReturn => _$this._quantityAvailableToReturn;
  set quantityAvailableToReturn(int? quantityAvailableToReturn) =>
      _$this._quantityAvailableToReturn = quantityAvailableToReturn;

  bool? _hasPendingReturn;
  bool? get hasPendingReturn => _$this._hasPendingReturn;
  set hasPendingReturn(bool? hasPendingReturn) =>
      _$this._hasPendingReturn = hasPendingReturn;

  String? _pendingReturnId;
  String? get pendingReturnId => _$this._pendingReturnId;
  set pendingReturnId(String? pendingReturnId) =>
      _$this._pendingReturnId = pendingReturnId;

  int? _pendingReturnQuantity;
  int? get pendingReturnQuantity => _$this._pendingReturnQuantity;
  set pendingReturnQuantity(int? pendingReturnQuantity) =>
      _$this._pendingReturnQuantity = pendingReturnQuantity;

  CollectedItemBuilder();

  CollectedItemBuilder get _$this {
    final $v = _$v;
    if ($v != null) {
      _woTaskPartsId = $v.woTaskPartsId;
      _partId = $v.partId;
      _partName = $v.partName;
      _partCode = $v.partCode;
      _quantityCollected = $v.quantityCollected;
      _technicianId = $v.technicianId;
      _collectedDate = $v.collectedDate;
      _workOrderNo = $v.workOrderNo;
      _partsInPossession = $v.partsInPossession;
      _quantityAlreadyReturned = $v.quantityAlreadyReturned;
      _quantityAvailableToReturn = $v.quantityAvailableToReturn;
      _hasPendingReturn = $v.hasPendingReturn;
      _pendingReturnId = $v.pendingReturnId;
      _pendingReturnQuantity = $v.pendingReturnQuantity;
      _$v = null;
    }
    return this;
  }

  @override
  void replace(CollectedItem other) {
    _$v = other as _$CollectedItem;
  }

  @override
  void update(void Function(CollectedItemBuilder)? updates) {
    if (updates != null) updates(this);
  }

  @override
  CollectedItem build() => _build();

  _$CollectedItem _build() {
    final _$result = _$v ??
        _$CollectedItem._(
          woTaskPartsId: woTaskPartsId,
          partId: partId,
          partName: partName,
          partCode: partCode,
          quantityCollected: quantityCollected,
          technicianId: technicianId,
          collectedDate: collectedDate,
          workOrderNo: workOrderNo,
          partsInPossession: partsInPossession,
          quantityAlreadyReturned: quantityAlreadyReturned,
          quantityAvailableToReturn: quantityAvailableToReturn,
          hasPendingReturn: hasPendingReturn,
          pendingReturnId: pendingReturnId,
          pendingReturnQuantity: pendingReturnQuantity,
        );
    replace(_$result);
    return _$result;
  }
}

class _$ReturnRequest extends ReturnRequest {
  @override
  final String? woTaskPartsId;
  @override
  final int? quantityReturned;
  @override
  final String? returnReason;
  @override
  final String? returnRemarks;
  @override
  final String? returnDeadlineDate;

  factory _$ReturnRequest([void Function(ReturnRequestBuilder)? updates]) =>
      (ReturnRequestBuilder()..update(updates))._build();

  _$ReturnRequest._(
      {this.woTaskPartsId,
      this.quantityReturned,
      this.returnReason,
      this.returnRemarks,
      this.returnDeadlineDate})
      : super._();
  @override
  ReturnRequest rebuild(void Function(ReturnRequestBuilder) updates) =>
      (toBuilder()..update(updates)).build();

  @override
  ReturnRequestBuilder toBuilder() => ReturnRequestBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is ReturnRequest &&
        woTaskPartsId == other.woTaskPartsId &&
        quantityReturned == other.quantityReturned &&
        returnReason == other.returnReason &&
        returnRemarks == other.returnRemarks &&
        returnDeadlineDate == other.returnDeadlineDate;
  }

  @override
  int get hashCode {
    var _$hash = 0;
    _$hash = $jc(_$hash, woTaskPartsId.hashCode);
    _$hash = $jc(_$hash, quantityReturned.hashCode);
    _$hash = $jc(_$hash, returnReason.hashCode);
    _$hash = $jc(_$hash, returnRemarks.hashCode);
    _$hash = $jc(_$hash, returnDeadlineDate.hashCode);
    _$hash = $jf(_$hash);
    return _$hash;
  }

  @override
  String toString() {
    return (newBuiltValueToStringHelper(r'ReturnRequest')
          ..add('woTaskPartsId', woTaskPartsId)
          ..add('quantityReturned', quantityReturned)
          ..add('returnReason', returnReason)
          ..add('returnRemarks', returnRemarks)
          ..add('returnDeadlineDate', returnDeadlineDate))
        .toString();
  }
}

class ReturnRequestBuilder
    implements Builder<ReturnRequest, ReturnRequestBuilder> {
  _$ReturnRequest? _$v;

  String? _woTaskPartsId;
  String? get woTaskPartsId => _$this._woTaskPartsId;
  set woTaskPartsId(String? woTaskPartsId) =>
      _$this._woTaskPartsId = woTaskPartsId;

  int? _quantityReturned;
  int? get quantityReturned => _$this._quantityReturned;
  set quantityReturned(int? quantityReturned) =>
      _$this._quantityReturned = quantityReturned;

  String? _returnReason;
  String? get returnReason => _$this._returnReason;
  set returnReason(String? returnReason) => _$this._returnReason = returnReason;

  String? _returnRemarks;
  String? get returnRemarks => _$this._returnRemarks;
  set returnRemarks(String? returnRemarks) =>
      _$this._returnRemarks = returnRemarks;

  String? _returnDeadlineDate;
  String? get returnDeadlineDate => _$this._returnDeadlineDate;
  set returnDeadlineDate(String? returnDeadlineDate) =>
      _$this._returnDeadlineDate = returnDeadlineDate;

  ReturnRequestBuilder();

  ReturnRequestBuilder get _$this {
    final $v = _$v;
    if ($v != null) {
      _woTaskPartsId = $v.woTaskPartsId;
      _quantityReturned = $v.quantityReturned;
      _returnReason = $v.returnReason;
      _returnRemarks = $v.returnRemarks;
      _returnDeadlineDate = $v.returnDeadlineDate;
      _$v = null;
    }
    return this;
  }

  @override
  void replace(ReturnRequest other) {
    _$v = other as _$ReturnRequest;
  }

  @override
  void update(void Function(ReturnRequestBuilder)? updates) {
    if (updates != null) updates(this);
  }

  @override
  ReturnRequest build() => _build();

  _$ReturnRequest _build() {
    final _$result = _$v ??
        _$ReturnRequest._(
          woTaskPartsId: woTaskPartsId,
          quantityReturned: quantityReturned,
          returnReason: returnReason,
          returnRemarks: returnRemarks,
          returnDeadlineDate: returnDeadlineDate,
        );
    replace(_$result);
    return _$result;
  }
}

class _$PendingReturn extends PendingReturn {
  @override
  final String? returnId;
  @override
  final String? woTaskPartsId;
  @override
  final String? partId;
  @override
  final String? technicianUserId;
  @override
  final int? quantityReturned;
  @override
  final String? returnStatus;
  @override
  final String? returnReason;
  @override
  final String? returnRemarks;
  @override
  final String? returnRequestDate;
  @override
  final String? returnDeadlineDate;
  @override
  final String? returnConfirmedDate;
  @override
  final String? storekeeperUserId;
  @override
  final String? partName;
  @override
  final String? partCode;
  @override
  final String? partUnit;
  @override
  final String? technicianName;
  @override
  final String? workOrderNo;
  @override
  final String? siteName;

  factory _$PendingReturn([void Function(PendingReturnBuilder)? updates]) =>
      (PendingReturnBuilder()..update(updates))._build();

  _$PendingReturn._(
      {this.returnId,
      this.woTaskPartsId,
      this.partId,
      this.technicianUserId,
      this.quantityReturned,
      this.returnStatus,
      this.returnReason,
      this.returnRemarks,
      this.returnRequestDate,
      this.returnDeadlineDate,
      this.returnConfirmedDate,
      this.storekeeperUserId,
      this.partName,
      this.partCode,
      this.partUnit,
      this.technicianName,
      this.workOrderNo,
      this.siteName})
      : super._();
  @override
  PendingReturn rebuild(void Function(PendingReturnBuilder) updates) =>
      (toBuilder()..update(updates)).build();

  @override
  PendingReturnBuilder toBuilder() => PendingReturnBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is PendingReturn &&
        returnId == other.returnId &&
        woTaskPartsId == other.woTaskPartsId &&
        partId == other.partId &&
        technicianUserId == other.technicianUserId &&
        quantityReturned == other.quantityReturned &&
        returnStatus == other.returnStatus &&
        returnReason == other.returnReason &&
        returnRemarks == other.returnRemarks &&
        returnRequestDate == other.returnRequestDate &&
        returnDeadlineDate == other.returnDeadlineDate &&
        returnConfirmedDate == other.returnConfirmedDate &&
        storekeeperUserId == other.storekeeperUserId &&
        partName == other.partName &&
        partCode == other.partCode &&
        partUnit == other.partUnit &&
        technicianName == other.technicianName &&
        workOrderNo == other.workOrderNo &&
        siteName == other.siteName;
  }

  @override
  int get hashCode {
    var _$hash = 0;
    _$hash = $jc(_$hash, returnId.hashCode);
    _$hash = $jc(_$hash, woTaskPartsId.hashCode);
    _$hash = $jc(_$hash, partId.hashCode);
    _$hash = $jc(_$hash, technicianUserId.hashCode);
    _$hash = $jc(_$hash, quantityReturned.hashCode);
    _$hash = $jc(_$hash, returnStatus.hashCode);
    _$hash = $jc(_$hash, returnReason.hashCode);
    _$hash = $jc(_$hash, returnRemarks.hashCode);
    _$hash = $jc(_$hash, returnRequestDate.hashCode);
    _$hash = $jc(_$hash, returnDeadlineDate.hashCode);
    _$hash = $jc(_$hash, returnConfirmedDate.hashCode);
    _$hash = $jc(_$hash, storekeeperUserId.hashCode);
    _$hash = $jc(_$hash, partName.hashCode);
    _$hash = $jc(_$hash, partCode.hashCode);
    _$hash = $jc(_$hash, partUnit.hashCode);
    _$hash = $jc(_$hash, technicianName.hashCode);
    _$hash = $jc(_$hash, workOrderNo.hashCode);
    _$hash = $jc(_$hash, siteName.hashCode);
    _$hash = $jf(_$hash);
    return _$hash;
  }

  @override
  String toString() {
    return (newBuiltValueToStringHelper(r'PendingReturn')
          ..add('returnId', returnId)
          ..add('woTaskPartsId', woTaskPartsId)
          ..add('partId', partId)
          ..add('technicianUserId', technicianUserId)
          ..add('quantityReturned', quantityReturned)
          ..add('returnStatus', returnStatus)
          ..add('returnReason', returnReason)
          ..add('returnRemarks', returnRemarks)
          ..add('returnRequestDate', returnRequestDate)
          ..add('returnDeadlineDate', returnDeadlineDate)
          ..add('returnConfirmedDate', returnConfirmedDate)
          ..add('storekeeperUserId', storekeeperUserId)
          ..add('partName', partName)
          ..add('partCode', partCode)
          ..add('partUnit', partUnit)
          ..add('technicianName', technicianName)
          ..add('workOrderNo', workOrderNo)
          ..add('siteName', siteName))
        .toString();
  }
}

class PendingReturnBuilder
    implements Builder<PendingReturn, PendingReturnBuilder> {
  _$PendingReturn? _$v;

  String? _returnId;
  String? get returnId => _$this._returnId;
  set returnId(String? returnId) => _$this._returnId = returnId;

  String? _woTaskPartsId;
  String? get woTaskPartsId => _$this._woTaskPartsId;
  set woTaskPartsId(String? woTaskPartsId) =>
      _$this._woTaskPartsId = woTaskPartsId;

  String? _partId;
  String? get partId => _$this._partId;
  set partId(String? partId) => _$this._partId = partId;

  String? _technicianUserId;
  String? get technicianUserId => _$this._technicianUserId;
  set technicianUserId(String? technicianUserId) =>
      _$this._technicianUserId = technicianUserId;

  int? _quantityReturned;
  int? get quantityReturned => _$this._quantityReturned;
  set quantityReturned(int? quantityReturned) =>
      _$this._quantityReturned = quantityReturned;

  String? _returnStatus;
  String? get returnStatus => _$this._returnStatus;
  set returnStatus(String? returnStatus) => _$this._returnStatus = returnStatus;

  String? _returnReason;
  String? get returnReason => _$this._returnReason;
  set returnReason(String? returnReason) => _$this._returnReason = returnReason;

  String? _returnRemarks;
  String? get returnRemarks => _$this._returnRemarks;
  set returnRemarks(String? returnRemarks) =>
      _$this._returnRemarks = returnRemarks;

  String? _returnRequestDate;
  String? get returnRequestDate => _$this._returnRequestDate;
  set returnRequestDate(String? returnRequestDate) =>
      _$this._returnRequestDate = returnRequestDate;

  String? _returnDeadlineDate;
  String? get returnDeadlineDate => _$this._returnDeadlineDate;
  set returnDeadlineDate(String? returnDeadlineDate) =>
      _$this._returnDeadlineDate = returnDeadlineDate;

  String? _returnConfirmedDate;
  String? get returnConfirmedDate => _$this._returnConfirmedDate;
  set returnConfirmedDate(String? returnConfirmedDate) =>
      _$this._returnConfirmedDate = returnConfirmedDate;

  String? _storekeeperUserId;
  String? get storekeeperUserId => _$this._storekeeperUserId;
  set storekeeperUserId(String? storekeeperUserId) =>
      _$this._storekeeperUserId = storekeeperUserId;

  String? _partName;
  String? get partName => _$this._partName;
  set partName(String? partName) => _$this._partName = partName;

  String? _partCode;
  String? get partCode => _$this._partCode;
  set partCode(String? partCode) => _$this._partCode = partCode;

  String? _partUnit;
  String? get partUnit => _$this._partUnit;
  set partUnit(String? partUnit) => _$this._partUnit = partUnit;

  String? _technicianName;
  String? get technicianName => _$this._technicianName;
  set technicianName(String? technicianName) =>
      _$this._technicianName = technicianName;

  String? _workOrderNo;
  String? get workOrderNo => _$this._workOrderNo;
  set workOrderNo(String? workOrderNo) => _$this._workOrderNo = workOrderNo;

  String? _siteName;
  String? get siteName => _$this._siteName;
  set siteName(String? siteName) => _$this._siteName = siteName;

  PendingReturnBuilder();

  PendingReturnBuilder get _$this {
    final $v = _$v;
    if ($v != null) {
      _returnId = $v.returnId;
      _woTaskPartsId = $v.woTaskPartsId;
      _partId = $v.partId;
      _technicianUserId = $v.technicianUserId;
      _quantityReturned = $v.quantityReturned;
      _returnStatus = $v.returnStatus;
      _returnReason = $v.returnReason;
      _returnRemarks = $v.returnRemarks;
      _returnRequestDate = $v.returnRequestDate;
      _returnDeadlineDate = $v.returnDeadlineDate;
      _returnConfirmedDate = $v.returnConfirmedDate;
      _storekeeperUserId = $v.storekeeperUserId;
      _partName = $v.partName;
      _partCode = $v.partCode;
      _partUnit = $v.partUnit;
      _technicianName = $v.technicianName;
      _workOrderNo = $v.workOrderNo;
      _siteName = $v.siteName;
      _$v = null;
    }
    return this;
  }

  @override
  void replace(PendingReturn other) {
    _$v = other as _$PendingReturn;
  }

  @override
  void update(void Function(PendingReturnBuilder)? updates) {
    if (updates != null) updates(this);
  }

  @override
  PendingReturn build() => _build();

  _$PendingReturn _build() {
    final _$result = _$v ??
        _$PendingReturn._(
          returnId: returnId,
          woTaskPartsId: woTaskPartsId,
          partId: partId,
          technicianUserId: technicianUserId,
          quantityReturned: quantityReturned,
          returnStatus: returnStatus,
          returnReason: returnReason,
          returnRemarks: returnRemarks,
          returnRequestDate: returnRequestDate,
          returnDeadlineDate: returnDeadlineDate,
          returnConfirmedDate: returnConfirmedDate,
          storekeeperUserId: storekeeperUserId,
          partName: partName,
          partCode: partCode,
          partUnit: partUnit,
          technicianName: technicianName,
          workOrderNo: workOrderNo,
          siteName: siteName,
        );
    replace(_$result);
    return _$result;
  }
}

// ignore_for_file: deprecated_member_use_from_same_package,type=lint
