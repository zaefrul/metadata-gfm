// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'material.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

Serializer<Material> _$materialSerializer = new _$MaterialSerializer();

class _$MaterialSerializer implements StructuredSerializer<Material> {
  @override
  final Iterable<Type> types = const [Material, _$Material];
  @override
  final String wireName = 'Material';

  @override
  Iterable<Object> serialize(Serializers serializers, Material object,
      {FullType specifiedType = FullType.unspecified}) {
    final result = <Object>[];
    Object value;
    value = object.assetGroupName;
    if (value != null) {
      result
        ..add('assetGroupName')
        ..add(serializers.serialize(value,
            specifiedType: const FullType(String)));
    }
    value = object.itemDescription;
    if (value != null) {
      result
        ..add('itemDescription')
        ..add(serializers.serialize(value,
            specifiedType: const FullType(String)));
    }
    value = object.itemId;
    if (value != null) {
      result
        ..add('itemId')
        ..add(serializers.serialize(value,
            specifiedType: const FullType(String)));
    }
    value = object.itemTypeDesc;
    if (value != null) {
      result
        ..add('itemTypeDesc')
        ..add(serializers.serialize(value,
            specifiedType: const FullType(String)));
    }
    value = object.partAvailable;
    if (value != null) {
      result
        ..add('partAvailable')
        ..add(serializers.serialize(value,
            specifiedType: const FullType(String)));
    }
    value = object.partCount;
    if (value != null) {
      result
        ..add('partCount')
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
    value = object.partLocked;
    if (value != null) {
      result
        ..add('partLocked')
        ..add(serializers.serialize(value,
            specifiedType: const FullType(String)));
    }
    value = object.partThreshold;
    if (value != null) {
      result
        ..add('partThreshold')
        ..add(serializers.serialize(value,
            specifiedType: const FullType(String)));
    }
    value = object.statusDesc;
    if (value != null) {
      result
        ..add('statusDesc')
        ..add(serializers.serialize(value,
            specifiedType: const FullType(String)));
    }
    value = object.statusStorekeeper;
    if (value != null) {
      result
        ..add('statusStorekeeper')
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
    value = object.woTaskPartsQuantity;
    if (value != null) {
      result
        ..add('woTaskPartsQuantity')
        ..add(serializers.serialize(value,
            specifiedType: const FullType(String)));
    }
    value = object.woTaskPartsRemark;
    if (value != null) {
      result
        ..add('woTaskPartsRemark')
        ..add(serializers.serialize(value,
            specifiedType: const FullType(String)));
    }
    value = object.woTaskPartStatus;
    if (value != null) {
      result
        ..add('woTaskPartStatus')
        ..add(serializers.serialize(value,
            specifiedType: const FullType(String)));
    }
    value = object.woTaskRequestId;
    if (value != null) {
      result
        ..add('woTaskRequestId')
        ..add(serializers.serialize(value,
            specifiedType: const FullType(String)));
    }
    value = object.images;
    if (value != null) {
      result
        ..add('images')
        ..add(serializers.serialize(value,
            specifiedType: const FullType(
                BuiltList, const [const FullType(ComplaintDImage)])));
    }
    return result;
  }

  @override
  Material deserialize(Serializers serializers, Iterable<Object> serialized,
      {FullType specifiedType = FullType.unspecified}) {
    final result = new MaterialBuilder();

    final iterator = serialized.iterator;
    while (iterator.moveNext()) {
      final key = iterator.current as String;
      iterator.moveNext();
      final Object value = iterator.current;
      switch (key) {
        case 'assetGroupName':
          result.assetGroupName = serializers.deserialize(value,
              specifiedType: const FullType(String)) as String;
          break;
        case 'itemDescription':
          result.itemDescription = serializers.deserialize(value,
              specifiedType: const FullType(String)) as String;
          break;
        case 'itemId':
          result.itemId = serializers.deserialize(value,
              specifiedType: const FullType(String)) as String;
          break;
        case 'itemTypeDesc':
          result.itemTypeDesc = serializers.deserialize(value,
              specifiedType: const FullType(String)) as String;
          break;
        case 'partAvailable':
          result.partAvailable = serializers.deserialize(value,
              specifiedType: const FullType(String)) as String;
          break;
        case 'partCount':
          result.partCount = serializers.deserialize(value,
              specifiedType: const FullType(String)) as String;
          break;
        case 'partId':
          result.partId = serializers.deserialize(value,
              specifiedType: const FullType(String)) as String;
          break;
        case 'partLocked':
          result.partLocked = serializers.deserialize(value,
              specifiedType: const FullType(String)) as String;
          break;
        case 'partThreshold':
          result.partThreshold = serializers.deserialize(value,
              specifiedType: const FullType(String)) as String;
          break;
        case 'statusDesc':
          result.statusDesc = serializers.deserialize(value,
              specifiedType: const FullType(String)) as String;
          break;
        case 'statusStorekeeper':
          result.statusStorekeeper = serializers.deserialize(value,
              specifiedType: const FullType(String)) as String;
          break;
        case 'woTaskPartsId':
          result.woTaskPartsId = serializers.deserialize(value,
              specifiedType: const FullType(String)) as String;
          break;
        case 'woTaskPartsQuantity':
          result.woTaskPartsQuantity = serializers.deserialize(value,
              specifiedType: const FullType(String)) as String;
          break;
        case 'woTaskPartsRemark':
          result.woTaskPartsRemark = serializers.deserialize(value,
              specifiedType: const FullType(String)) as String;
          break;
        case 'woTaskPartStatus':
          result.woTaskPartStatus = serializers.deserialize(value,
              specifiedType: const FullType(String)) as String;
          break;
        case 'woTaskRequestId':
          result.woTaskRequestId = serializers.deserialize(value,
              specifiedType: const FullType(String)) as String;
          break;
        case 'images':
          result.images.replace(serializers.deserialize(value,
                  specifiedType: const FullType(
                      BuiltList, const [const FullType(ComplaintDImage)]))
              as BuiltList<Object>);
          break;
      }
    }

    return result.build();
  }
}

class _$Material extends Material {
  @override
  final String assetGroupName;
  @override
  final String itemDescription;
  @override
  final String itemId;
  @override
  final String itemTypeDesc;
  @override
  final String partAvailable;
  @override
  final String partCount;
  @override
  final String partId;
  @override
  final String partLocked;
  @override
  final String partThreshold;
  @override
  final String statusDesc;
  @override
  final String statusStorekeeper;
  @override
  final String woTaskPartsId;
  @override
  final String woTaskPartsQuantity;
  @override
  final String woTaskPartsRemark;
  @override
  final String woTaskPartStatus;
  @override
  final String woTaskRequestId;
  @override
  final BuiltList<ComplaintDImage> images;

  factory _$Material([void Function(MaterialBuilder) updates]) =>
      (new MaterialBuilder()..update(updates)).build();

  _$Material._(
      {this.assetGroupName,
      this.itemDescription,
      this.itemId,
      this.itemTypeDesc,
      this.partAvailable,
      this.partCount,
      this.partId,
      this.partLocked,
      this.partThreshold,
      this.statusDesc,
      this.statusStorekeeper,
      this.woTaskPartsId,
      this.woTaskPartsQuantity,
      this.woTaskPartsRemark,
      this.woTaskPartStatus,
      this.woTaskRequestId,
      this.images})
      : super._();

  @override
  Material rebuild(void Function(MaterialBuilder) updates) =>
      (toBuilder()..update(updates)).build();

  @override
  MaterialBuilder toBuilder() => new MaterialBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is Material &&
        assetGroupName == other.assetGroupName &&
        itemDescription == other.itemDescription &&
        itemId == other.itemId &&
        itemTypeDesc == other.itemTypeDesc &&
        partAvailable == other.partAvailable &&
        partCount == other.partCount &&
        partId == other.partId &&
        partLocked == other.partLocked &&
        partThreshold == other.partThreshold &&
        statusDesc == other.statusDesc &&
        statusStorekeeper == other.statusStorekeeper &&
        woTaskPartsId == other.woTaskPartsId &&
        woTaskPartsQuantity == other.woTaskPartsQuantity &&
        woTaskPartsRemark == other.woTaskPartsRemark &&
        woTaskPartStatus == other.woTaskPartStatus &&
        woTaskRequestId == other.woTaskRequestId &&
        images == other.images;
  }

  @override
  int get hashCode {
    return $jf($jc(
        $jc(
            $jc(
                $jc(
                    $jc(
                        $jc(
                            $jc(
                                $jc(
                                    $jc(
                                        $jc(
                                            $jc(
                                                $jc(
                                                    $jc(
                                                        $jc(
                                                            $jc(
                                                                $jc(
                                                                    $jc(
                                                                        0,
                                                                        assetGroupName
                                                                            .hashCode),
                                                                    itemDescription
                                                                        .hashCode),
                                                                itemId
                                                                    .hashCode),
                                                            itemTypeDesc
                                                                .hashCode),
                                                        partAvailable.hashCode),
                                                    partCount.hashCode),
                                                partId.hashCode),
                                            partLocked.hashCode),
                                        partThreshold.hashCode),
                                    statusDesc.hashCode),
                                statusStorekeeper.hashCode),
                            woTaskPartsId.hashCode),
                        woTaskPartsQuantity.hashCode),
                    woTaskPartsRemark.hashCode),
                woTaskPartStatus.hashCode),
            woTaskRequestId.hashCode),
        images.hashCode));
  }

  @override
  String toString() {
    return (newBuiltValueToStringHelper('Material')
          ..add('assetGroupName', assetGroupName)
          ..add('itemDescription', itemDescription)
          ..add('itemId', itemId)
          ..add('itemTypeDesc', itemTypeDesc)
          ..add('partAvailable', partAvailable)
          ..add('partCount', partCount)
          ..add('partId', partId)
          ..add('partLocked', partLocked)
          ..add('partThreshold', partThreshold)
          ..add('statusDesc', statusDesc)
          ..add('statusStorekeeper', statusStorekeeper)
          ..add('woTaskPartsId', woTaskPartsId)
          ..add('woTaskPartsQuantity', woTaskPartsQuantity)
          ..add('woTaskPartsRemark', woTaskPartsRemark)
          ..add('woTaskPartStatus', woTaskPartStatus)
          ..add('woTaskRequestId', woTaskRequestId)
          ..add('images', images))
        .toString();
  }
}

class MaterialBuilder implements Builder<Material, MaterialBuilder> {
  _$Material _$v;

  String _assetGroupName;
  String get assetGroupName => _$this._assetGroupName;
  set assetGroupName(String assetGroupName) =>
      _$this._assetGroupName = assetGroupName;

  String _itemDescription;
  String get itemDescription => _$this._itemDescription;
  set itemDescription(String itemDescription) =>
      _$this._itemDescription = itemDescription;

  String _itemId;
  String get itemId => _$this._itemId;
  set itemId(String itemId) => _$this._itemId = itemId;

  String _itemTypeDesc;
  String get itemTypeDesc => _$this._itemTypeDesc;
  set itemTypeDesc(String itemTypeDesc) => _$this._itemTypeDesc = itemTypeDesc;

  String _partAvailable;
  String get partAvailable => _$this._partAvailable;
  set partAvailable(String partAvailable) =>
      _$this._partAvailable = partAvailable;

  String _partCount;
  String get partCount => _$this._partCount;
  set partCount(String partCount) => _$this._partCount = partCount;

  String _partId;
  String get partId => _$this._partId;
  set partId(String partId) => _$this._partId = partId;

  String _partLocked;
  String get partLocked => _$this._partLocked;
  set partLocked(String partLocked) => _$this._partLocked = partLocked;

  String _partThreshold;
  String get partThreshold => _$this._partThreshold;
  set partThreshold(String partThreshold) =>
      _$this._partThreshold = partThreshold;

  String _statusDesc;
  String get statusDesc => _$this._statusDesc;
  set statusDesc(String statusDesc) => _$this._statusDesc = statusDesc;

  String _statusStorekeeper;
  String get statusStorekeeper => _$this._statusStorekeeper;
  set statusStorekeeper(String statusStorekeeper) =>
      _$this._statusStorekeeper = statusStorekeeper;

  String _woTaskPartsId;
  String get woTaskPartsId => _$this._woTaskPartsId;
  set woTaskPartsId(String woTaskPartsId) =>
      _$this._woTaskPartsId = woTaskPartsId;

  String _woTaskPartsQuantity;
  String get woTaskPartsQuantity => _$this._woTaskPartsQuantity;
  set woTaskPartsQuantity(String woTaskPartsQuantity) =>
      _$this._woTaskPartsQuantity = woTaskPartsQuantity;

  String _woTaskPartsRemark;
  String get woTaskPartsRemark => _$this._woTaskPartsRemark;
  set woTaskPartsRemark(String woTaskPartsRemark) =>
      _$this._woTaskPartsRemark = woTaskPartsRemark;

  String _woTaskPartStatus;
  String get woTaskPartStatus => _$this._woTaskPartStatus;
  set woTaskPartStatus(String woTaskPartStatus) =>
      _$this._woTaskPartStatus = woTaskPartStatus;

  String _woTaskRequestId;
  String get woTaskRequestId => _$this._woTaskRequestId;
  set woTaskRequestId(String woTaskRequestId) =>
      _$this._woTaskRequestId = woTaskRequestId;

  ListBuilder<ComplaintDImage> _images;
  ListBuilder<ComplaintDImage> get images =>
      _$this._images ??= new ListBuilder<ComplaintDImage>();
  set images(ListBuilder<ComplaintDImage> images) => _$this._images = images;

  MaterialBuilder();

  MaterialBuilder get _$this {
    final $v = _$v;
    if ($v != null) {
      _assetGroupName = $v.assetGroupName;
      _itemDescription = $v.itemDescription;
      _itemId = $v.itemId;
      _itemTypeDesc = $v.itemTypeDesc;
      _partAvailable = $v.partAvailable;
      _partCount = $v.partCount;
      _partId = $v.partId;
      _partLocked = $v.partLocked;
      _partThreshold = $v.partThreshold;
      _statusDesc = $v.statusDesc;
      _statusStorekeeper = $v.statusStorekeeper;
      _woTaskPartsId = $v.woTaskPartsId;
      _woTaskPartsQuantity = $v.woTaskPartsQuantity;
      _woTaskPartsRemark = $v.woTaskPartsRemark;
      _woTaskPartStatus = $v.woTaskPartStatus;
      _woTaskRequestId = $v.woTaskRequestId;
      _images = $v.images?.toBuilder();
      _$v = null;
    }
    return this;
  }

  @override
  void replace(Material other) {
    ArgumentError.checkNotNull(other, 'other');
    _$v = other as _$Material;
  }

  @override
  void update(void Function(MaterialBuilder) updates) {
    if (updates != null) updates(this);
  }

  @override
  _$Material build() {
    _$Material _$result;
    try {
      _$result = _$v ??
          new _$Material._(
              assetGroupName: assetGroupName,
              itemDescription: itemDescription,
              itemId: itemId,
              itemTypeDesc: itemTypeDesc,
              partAvailable: partAvailable,
              partCount: partCount,
              partId: partId,
              partLocked: partLocked,
              partThreshold: partThreshold,
              statusDesc: statusDesc,
              statusStorekeeper: statusStorekeeper,
              woTaskPartsId: woTaskPartsId,
              woTaskPartsQuantity: woTaskPartsQuantity,
              woTaskPartsRemark: woTaskPartsRemark,
              woTaskPartStatus: woTaskPartStatus,
              woTaskRequestId: woTaskRequestId,
              images: _images?.build());
    } catch (_) {
      String _$failedField;
      try {
        _$failedField = 'images';
        _images?.build();
      } catch (e) {
        throw new BuiltValueNestedFieldError(
            'Material', _$failedField, e.toString());
      }
      rethrow;
    }
    replace(_$result);
    return _$result;
  }
}

// ignore_for_file: always_put_control_body_on_new_line,always_specify_types,annotate_overrides,avoid_annotating_with_dynamic,avoid_as,avoid_catches_without_on_clauses,avoid_returning_this,deprecated_member_use_from_same_package,lines_longer_than_80_chars,omit_local_variable_types,prefer_expression_function_bodies,sort_constructors_first,test_types_in_equals,unnecessary_const,unnecessary_new
