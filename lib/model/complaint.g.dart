// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'complaint.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

Serializer<ComplaintD> _$complaintDSerializer = _$ComplaintDSerializer();
Serializer<ComplaintDStore> _$complaintDStoreSerializer =
    _$ComplaintDStoreSerializer();
Serializer<ComplaintDGroupStore> _$complaintDGroupStoreSerializer =
    _$ComplaintDGroupStoreSerializer();
Serializer<ComplaintDGroup> _$complaintDGroupSerializer =
    _$ComplaintDGroupSerializer();
Serializer<ComplaintDType> _$complaintDTypeSerializer =
    _$ComplaintDTypeSerializer();
Serializer<ComplaintDStoreType> _$complaintDStoreTypeSerializer =
    _$ComplaintDStoreTypeSerializer();
Serializer<ComplaintDPart> _$complaintDPartSerializer =
    _$ComplaintDPartSerializer();
Serializer<MaterialStorePart> _$materialStorePartSerializer =
    _$MaterialStorePartSerializer();
Serializer<ComplaintDImage> _$complaintDImageSerializer =
    _$ComplaintDImageSerializer();
Serializer<RequestTask> _$requestTaskSerializer = _$RequestTaskSerializer();
Serializer<ComplaintMaterial> _$complaintMaterialSerializer =
    _$ComplaintMaterialSerializer();
Serializer<ComplaintMaterialGrouped> _$complaintMaterialGroupedSerializer =
    _$ComplaintMaterialGroupedSerializer();
Serializer<ComplaintMaterialImage> _$complaintMaterialImageSerializer =
    _$ComplaintMaterialImageSerializer();

class _$ComplaintDSerializer implements StructuredSerializer<ComplaintD> {
  @override
  final Iterable<Type> types = const [ComplaintD, _$ComplaintD];
  @override
  final String wireName = 'ComplaintD';

  @override
  Iterable<Object?> serialize(Serializers serializers, ComplaintD object,
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
    value = object.woTaskRequestId;
    if (value != null) {
      result
        ..add('woTaskRequestId')
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
    value = object.woTaskPartsStatus;
    if (value != null) {
      result
        ..add('woTaskPartsStatus')
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
    value = object.itemTypeDesc;
    if (value != null) {
      result
        ..add('itemTypeDesc')
        ..add(serializers.serialize(value,
            specifiedType: const FullType(String)));
    }
    value = object.assetGroupName;
    if (value != null) {
      result
        ..add('assetGroupName')
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
  ComplaintD deserialize(Serializers serializers, Iterable<Object?> serialized,
      {FullType specifiedType = FullType.unspecified}) {
    final result = ComplaintDBuilder();

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
        case 'woTaskRequestId':
          result.woTaskRequestId = serializers.deserialize(value,
              specifiedType: const FullType(String)) as String?;
          break;
        case 'partId':
          result.partId = serializers.deserialize(value,
              specifiedType: const FullType(String)) as String?;
          break;
        case 'woTaskPartsQuantity':
          result.woTaskPartsQuantity = serializers.deserialize(value,
              specifiedType: const FullType(String)) as String?;
          break;
        case 'woTaskPartsRemark':
          result.woTaskPartsRemark = serializers.deserialize(value,
              specifiedType: const FullType(String)) as String?;
          break;
        case 'woTaskPartsStatus':
          result.woTaskPartsStatus = serializers.deserialize(value,
              specifiedType: const FullType(String)) as String?;
          break;
        case 'itemDescription':
          result.itemDescription = serializers.deserialize(value,
              specifiedType: const FullType(String)) as String?;
          break;
        case 'itemTypeDesc':
          result.itemTypeDesc = serializers.deserialize(value,
              specifiedType: const FullType(String)) as String?;
          break;
        case 'assetGroupName':
          result.assetGroupName = serializers.deserialize(value,
              specifiedType: const FullType(String)) as String?;
          break;
        case 'statusDesc':
          result.statusDesc = serializers.deserialize(value,
              specifiedType: const FullType(String)) as String?;
          break;
        case 'images':
          result.images.replace(serializers.deserialize(value,
                  specifiedType: const FullType(
                      BuiltList, const [const FullType(ComplaintDImage)]))!
              as BuiltList<Object?>);
          break;
      }
    }

    return result.build();
  }
}

class _$ComplaintDStoreSerializer
    implements StructuredSerializer<ComplaintDStore> {
  @override
  final Iterable<Type> types = const [ComplaintDStore, _$ComplaintDStore];
  @override
  final String wireName = 'ComplaintDStore';

  @override
  Iterable<Object?> serialize(Serializers serializers, ComplaintDStore object,
      {FullType specifiedType = FullType.unspecified}) {
    final result = <Object?>[];
    Object? value;
    value = object.itemId;
    if (value != null) {
      result
        ..add('storeId')
        ..add(serializers.serialize(value,
            specifiedType: const FullType(String)));
    }
    value = object.itemName;
    if (value != null) {
      result
        ..add('storeName')
        ..add(serializers.serialize(value,
            specifiedType: const FullType(String)));
    }
    return result;
  }

  @override
  ComplaintDStore deserialize(
      Serializers serializers, Iterable<Object?> serialized,
      {FullType specifiedType = FullType.unspecified}) {
    final result = ComplaintDStoreBuilder();

    final iterator = serialized.iterator;
    while (iterator.moveNext()) {
      final key = iterator.current! as String;
      iterator.moveNext();
      final Object? value = iterator.current;
      switch (key) {
        case 'storeId':
          result.itemId = serializers.deserialize(value,
              specifiedType: const FullType(String)) as String?;
          break;
        case 'storeName':
          result.itemName = serializers.deserialize(value,
              specifiedType: const FullType(String)) as String?;
          break;
      }
    }

    return result.build();
  }
}

class _$ComplaintDGroupStoreSerializer
    implements StructuredSerializer<ComplaintDGroupStore> {
  @override
  final Iterable<Type> types = const [
    ComplaintDGroupStore,
    _$ComplaintDGroupStore
  ];
  @override
  final String wireName = 'ComplaintDGroupStore';

  @override
  Iterable<Object?> serialize(
      Serializers serializers, ComplaintDGroupStore object,
      {FullType specifiedType = FullType.unspecified}) {
    final result = <Object?>[];
    Object? value;
    value = object.itemId;
    if (value != null) {
      result
        ..add('assetGroupId')
        ..add(serializers.serialize(value,
            specifiedType: const FullType(String)));
    }
    value = object.itemName;
    if (value != null) {
      result
        ..add('assetGroupName')
        ..add(serializers.serialize(value,
            specifiedType: const FullType(String)));
    }
    value = object.itemTypes;
    if (value != null) {
      result
        ..add('itemTypes')
        ..add(serializers.serialize(value,
            specifiedType: const FullType(
                BuiltList, const [const FullType(ComplaintDType)])));
    }
    return result;
  }

  @override
  ComplaintDGroupStore deserialize(
      Serializers serializers, Iterable<Object?> serialized,
      {FullType specifiedType = FullType.unspecified}) {
    final result = ComplaintDGroupStoreBuilder();

    final iterator = serialized.iterator;
    while (iterator.moveNext()) {
      final key = iterator.current! as String;
      iterator.moveNext();
      final Object? value = iterator.current;
      switch (key) {
        case 'assetGroupId':
          result.itemId = serializers.deserialize(value,
              specifiedType: const FullType(String)) as String?;
          break;
        case 'assetGroupName':
          result.itemName = serializers.deserialize(value,
              specifiedType: const FullType(String)) as String?;
          break;
        case 'itemTypes':
          result.itemTypes.replace(serializers.deserialize(value,
                  specifiedType: const FullType(
                      BuiltList, const [const FullType(ComplaintDType)]))!
              as BuiltList<Object?>);
          break;
      }
    }

    return result.build();
  }
}

class _$ComplaintDGroupSerializer
    implements StructuredSerializer<ComplaintDGroup> {
  @override
  final Iterable<Type> types = const [ComplaintDGroup, _$ComplaintDGroup];
  @override
  final String wireName = 'ComplaintDGroup';

  @override
  Iterable<Object?> serialize(Serializers serializers, ComplaintDGroup object,
      {FullType specifiedType = FullType.unspecified}) {
    final result = <Object?>[];
    Object? value;
    value = object.itemId;
    if (value != null) {
      result
        ..add('asset_group_id')
        ..add(serializers.serialize(value,
            specifiedType: const FullType(String)));
    }
    value = object.itemName;
    if (value != null) {
      result
        ..add('asset_group_name')
        ..add(serializers.serialize(value,
            specifiedType: const FullType(String)));
    }
    value = object.itemDesc;
    if (value != null) {
      result
        ..add('assetGroupDesc')
        ..add(serializers.serialize(value,
            specifiedType: const FullType(String)));
    }
    value = object.itemStatus;
    if (value != null) {
      result
        ..add('assetGroupStatus')
        ..add(serializers.serialize(value,
            specifiedType: const FullType(String)));
    }
    return result;
  }

  @override
  ComplaintDGroup deserialize(
      Serializers serializers, Iterable<Object?> serialized,
      {FullType specifiedType = FullType.unspecified}) {
    final result = ComplaintDGroupBuilder();

    final iterator = serialized.iterator;
    while (iterator.moveNext()) {
      final key = iterator.current! as String;
      iterator.moveNext();
      final Object? value = iterator.current;
      switch (key) {
        case 'asset_group_id':
          result.itemId = serializers.deserialize(value,
              specifiedType: const FullType(String)) as String?;
          break;
        case 'asset_group_name':
          result.itemName = serializers.deserialize(value,
              specifiedType: const FullType(String)) as String?;
          break;
        case 'assetGroupDesc':
          result.itemDesc = serializers.deserialize(value,
              specifiedType: const FullType(String)) as String?;
          break;
        case 'assetGroupStatus':
          result.itemStatus = serializers.deserialize(value,
              specifiedType: const FullType(String)) as String?;
          break;
      }
    }

    return result.build();
  }
}

class _$ComplaintDTypeSerializer
    implements StructuredSerializer<ComplaintDType> {
  @override
  final Iterable<Type> types = const [ComplaintDType, _$ComplaintDType];
  @override
  final String wireName = 'ComplaintDType';

  @override
  Iterable<Object?> serialize(Serializers serializers, ComplaintDType object,
      {FullType specifiedType = FullType.unspecified}) {
    final result = <Object?>[];
    Object? value;
    value = object.itemId;
    if (value != null) {
      result
        ..add('item_type_id')
        ..add(serializers.serialize(value,
            specifiedType: const FullType(String)));
    }
    value = object.itemGroupId;
    if (value != null) {
      result
        ..add('assetGroupId')
        ..add(serializers.serialize(value,
            specifiedType: const FullType(String)));
    }
    value = object.itemName;
    if (value != null) {
      result
        ..add('item_type_desc')
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
    value = object.itemStatus;
    if (value != null) {
      result
        ..add('itemTypeStatus')
        ..add(serializers.serialize(value,
            specifiedType: const FullType(String)));
    }
    value = object.parts;
    if (value != null) {
      result
        ..add('parts')
        ..add(serializers.serialize(value,
            specifiedType: const FullType(
                BuiltList, const [const FullType(ComplaintMaterial)])));
    }
    return result;
  }

  @override
  ComplaintDType deserialize(
      Serializers serializers, Iterable<Object?> serialized,
      {FullType specifiedType = FullType.unspecified}) {
    final result = ComplaintDTypeBuilder();

    final iterator = serialized.iterator;
    while (iterator.moveNext()) {
      final key = iterator.current! as String;
      iterator.moveNext();
      final Object? value = iterator.current;
      switch (key) {
        case 'item_type_id':
          result.itemId = serializers.deserialize(value,
              specifiedType: const FullType(String)) as String?;
          break;
        case 'assetGroupId':
          result.itemGroupId = serializers.deserialize(value,
              specifiedType: const FullType(String)) as String?;
          break;
        case 'item_type_desc':
          result.itemName = serializers.deserialize(value,
              specifiedType: const FullType(String)) as String?;
          break;
        case 'itemTypeDesc':
          result.itemTypeDesc = serializers.deserialize(value,
              specifiedType: const FullType(String)) as String?;
          break;
        case 'itemTypeStatus':
          result.itemStatus = serializers.deserialize(value,
              specifiedType: const FullType(String)) as String?;
          break;
        case 'parts':
          result.parts.replace(serializers.deserialize(value,
                  specifiedType: const FullType(
                      BuiltList, const [const FullType(ComplaintMaterial)]))!
              as BuiltList<Object?>);
          break;
      }
    }

    return result.build();
  }
}

class _$ComplaintDStoreTypeSerializer
    implements StructuredSerializer<ComplaintDStoreType> {
  @override
  final Iterable<Type> types = const [
    ComplaintDStoreType,
    _$ComplaintDStoreType
  ];
  @override
  final String wireName = 'ComplaintDStoreType';

  @override
  Iterable<Object?> serialize(
      Serializers serializers, ComplaintDStoreType object,
      {FullType specifiedType = FullType.unspecified}) {
    final result = <Object?>[];
    Object? value;
    value = object.itemId;
    if (value != null) {
      result
        ..add('itemTypeId')
        ..add(serializers.serialize(value,
            specifiedType: const FullType(String)));
    }
    value = object.itemName;
    if (value != null) {
      result
        ..add('itemTypeDesc')
        ..add(serializers.serialize(value,
            specifiedType: const FullType(String)));
    }
    value = object.parts;
    if (value != null) {
      result
        ..add('parts')
        ..add(serializers.serialize(value,
            specifiedType: const FullType(
                BuiltList, const [const FullType(ComplaintMaterial)])));
    }
    return result;
  }

  @override
  ComplaintDStoreType deserialize(
      Serializers serializers, Iterable<Object?> serialized,
      {FullType specifiedType = FullType.unspecified}) {
    final result = ComplaintDStoreTypeBuilder();

    final iterator = serialized.iterator;
    while (iterator.moveNext()) {
      final key = iterator.current! as String;
      iterator.moveNext();
      final Object? value = iterator.current;
      switch (key) {
        case 'itemTypeId':
          result.itemId = serializers.deserialize(value,
              specifiedType: const FullType(String)) as String?;
          break;
        case 'itemTypeDesc':
          result.itemName = serializers.deserialize(value,
              specifiedType: const FullType(String)) as String?;
          break;
        case 'parts':
          result.parts.replace(serializers.deserialize(value,
                  specifiedType: const FullType(
                      BuiltList, const [const FullType(ComplaintMaterial)]))!
              as BuiltList<Object?>);
          break;
      }
    }

    return result.build();
  }
}

class _$ComplaintDPartSerializer
    implements StructuredSerializer<ComplaintDPart> {
  @override
  final Iterable<Type> types = const [ComplaintDPart, _$ComplaintDPart];
  @override
  final String wireName = 'ComplaintDPart';

  @override
  Iterable<Object?> serialize(Serializers serializers, ComplaintDPart object,
      {FullType specifiedType = FullType.unspecified}) {
    final result = <Object?>[];
    Object? value;
    value = object.itemId;
    if (value != null) {
      result
        ..add('item_id')
        ..add(serializers.serialize(value,
            specifiedType: const FullType(String)));
    }
    value = object.itemName;
    if (value != null) {
      result
        ..add('item_description')
        ..add(serializers.serialize(value,
            specifiedType: const FullType(String)));
    }
    value = object.itemQuantity;
    if (value != null) {
      result
        ..add('partCounts')
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
    value = object.partLocked;
    if (value != null) {
      result
        ..add('partLocked')
        ..add(serializers.serialize(value,
            specifiedType: const FullType(String)));
    }
    value = object.partMaxOrder;
    if (value != null) {
      result
        ..add('partMaxOrder')
        ..add(serializers.serialize(value,
            specifiedType: const FullType(String)));
    }
    value = object.partMinOrder;
    if (value != null) {
      result
        ..add('partMinOrder')
        ..add(serializers.serialize(value,
            specifiedType: const FullType(String)));
    }
    value = object.partRemark;
    if (value != null) {
      result
        ..add('partRemark')
        ..add(serializers.serialize(value,
            specifiedType: const FullType(String)));
    }
    return result;
  }

  @override
  ComplaintDPart deserialize(
      Serializers serializers, Iterable<Object?> serialized,
      {FullType specifiedType = FullType.unspecified}) {
    final result = ComplaintDPartBuilder();

    final iterator = serialized.iterator;
    while (iterator.moveNext()) {
      final key = iterator.current! as String;
      iterator.moveNext();
      final Object? value = iterator.current;
      switch (key) {
        case 'item_id':
          result.itemId = serializers.deserialize(value,
              specifiedType: const FullType(String)) as String?;
          break;
        case 'item_description':
          result.itemName = serializers.deserialize(value,
              specifiedType: const FullType(String)) as String?;
          break;
        case 'partCounts':
          result.itemQuantity = serializers.deserialize(value,
              specifiedType: const FullType(String)) as String?;
          break;
        case 'itemTypeDesc':
          result.itemTypeDesc = serializers.deserialize(value,
              specifiedType: const FullType(String)) as String?;
          break;
        case 'partLocked':
          result.partLocked = serializers.deserialize(value,
              specifiedType: const FullType(String)) as String?;
          break;
        case 'partMaxOrder':
          result.partMaxOrder = serializers.deserialize(value,
              specifiedType: const FullType(String)) as String?;
          break;
        case 'partMinOrder':
          result.partMinOrder = serializers.deserialize(value,
              specifiedType: const FullType(String)) as String?;
          break;
        case 'partRemark':
          result.partRemark = serializers.deserialize(value,
              specifiedType: const FullType(String)) as String?;
          break;
      }
    }

    return result.build();
  }
}

class _$MaterialStorePartSerializer
    implements StructuredSerializer<MaterialStorePart> {
  @override
  final Iterable<Type> types = const [MaterialStorePart, _$MaterialStorePart];
  @override
  final String wireName = 'MaterialStorePart';

  @override
  Iterable<Object?> serialize(Serializers serializers, MaterialStorePart object,
      {FullType specifiedType = FullType.unspecified}) {
    final result = <Object?>[];
    Object? value;
    value = object.itemDescription;
    if (value != null) {
      result
        ..add('itemDescription')
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
    value = object.partMaxOrder;
    if (value != null) {
      result
        ..add('partMaxOrder')
        ..add(serializers.serialize(value,
            specifiedType: const FullType(String)));
    }
    value = object.partMinOrder;
    if (value != null) {
      result
        ..add('partMinOrder')
        ..add(serializers.serialize(value,
            specifiedType: const FullType(String)));
    }
    value = object.partRemark;
    if (value != null) {
      result
        ..add('partRemark')
        ..add(serializers.serialize(value,
            specifiedType: const FullType(String)));
    }
    return result;
  }

  @override
  MaterialStorePart deserialize(
      Serializers serializers, Iterable<Object?> serialized,
      {FullType specifiedType = FullType.unspecified}) {
    final result = MaterialStorePartBuilder();

    final iterator = serialized.iterator;
    while (iterator.moveNext()) {
      final key = iterator.current! as String;
      iterator.moveNext();
      final Object? value = iterator.current;
      switch (key) {
        case 'itemDescription':
          result.itemDescription = serializers.deserialize(value,
              specifiedType: const FullType(String)) as String?;
          break;
        case 'partAvailable':
          result.partAvailable = serializers.deserialize(value,
              specifiedType: const FullType(String)) as String?;
          break;
        case 'partCount':
          result.partCount = serializers.deserialize(value,
              specifiedType: const FullType(String)) as String?;
          break;
        case 'partId':
          result.partId = serializers.deserialize(value,
              specifiedType: const FullType(String)) as String?;
          break;
        case 'partLocked':
          result.partLocked = serializers.deserialize(value,
              specifiedType: const FullType(String)) as String?;
          break;
        case 'partMaxOrder':
          result.partMaxOrder = serializers.deserialize(value,
              specifiedType: const FullType(String)) as String?;
          break;
        case 'partMinOrder':
          result.partMinOrder = serializers.deserialize(value,
              specifiedType: const FullType(String)) as String?;
          break;
        case 'partRemark':
          result.partRemark = serializers.deserialize(value,
              specifiedType: const FullType(String)) as String?;
          break;
      }
    }

    return result.build();
  }
}

class _$ComplaintDImageSerializer
    implements StructuredSerializer<ComplaintDImage> {
  @override
  final Iterable<Type> types = const [ComplaintDImage, _$ComplaintDImage];
  @override
  final String wireName = 'ComplaintDImage';

  @override
  Iterable<Object?> serialize(Serializers serializers, ComplaintDImage object,
      {FullType specifiedType = FullType.unspecified}) {
    final result = <Object?>[];
    Object? value;
    value = object.file;
    if (value != null) {
      result
        ..add('file')
        ..add(serializers.serialize(value,
            specifiedType: const FullType(String)));
    }
    value = object.title;
    if (value != null) {
      result
        ..add('title')
        ..add(serializers.serialize(value,
            specifiedType: const FullType(String)));
    }
    value = object.width;
    if (value != null) {
      result
        ..add('width')
        ..add(serializers.serialize(value,
            specifiedType: const FullType(String)));
    }
    value = object.height;
    if (value != null) {
      result
        ..add('height')
        ..add(serializers.serialize(value,
            specifiedType: const FullType(String)));
    }
    return result;
  }

  @override
  ComplaintDImage deserialize(
      Serializers serializers, Iterable<Object?> serialized,
      {FullType specifiedType = FullType.unspecified}) {
    final result = ComplaintDImageBuilder();

    final iterator = serialized.iterator;
    while (iterator.moveNext()) {
      final key = iterator.current! as String;
      iterator.moveNext();
      final Object? value = iterator.current;
      switch (key) {
        case 'file':
          result.file = serializers.deserialize(value,
              specifiedType: const FullType(String)) as String?;
          break;
        case 'title':
          result.title = serializers.deserialize(value,
              specifiedType: const FullType(String)) as String?;
          break;
        case 'width':
          result.width = serializers.deserialize(value,
              specifiedType: const FullType(String)) as String?;
          break;
        case 'height':
          result.height = serializers.deserialize(value,
              specifiedType: const FullType(String)) as String?;
          break;
      }
    }

    return result.build();
  }
}

class _$RequestTaskSerializer implements StructuredSerializer<RequestTask> {
  @override
  final Iterable<Type> types = const [RequestTask, _$RequestTask];
  @override
  final String wireName = 'RequestTask';

  @override
  Iterable<Object?> serialize(Serializers serializers, RequestTask object,
      {FullType specifiedType = FullType.unspecified}) {
    final result = <Object?>[];
    Object? value;
    value = object.requestBy;
    if (value != null) {
      result
        ..add('requestBy')
        ..add(serializers.serialize(value,
            specifiedType: const FullType(String)));
    }
    value = object.requestTime;
    if (value != null) {
      result
        ..add('requestTime')
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
    value = object.statusId;
    if (value != null) {
      result
        ..add('statusId')
        ..add(serializers.serialize(value,
            specifiedType: const FullType(String)));
    }
    value = object.checkpointId;
    if (value != null) {
      result
        ..add('checkpointId')
        ..add(serializers.serialize(value,
            specifiedType: const FullType(String)));
    }
    value = object.checkpointDesc;
    if (value != null) {
      result
        ..add('checkpointDesc')
        ..add(serializers.serialize(value,
            specifiedType: const FullType(String)));
    }
    value = object.taskFrom;
    if (value != null) {
      result
        ..add('taskFrom')
        ..add(serializers.serialize(value,
            specifiedType: const FullType(String)));
    }
    value = object.taskReceivedTime;
    if (value != null) {
      result
        ..add('taskReceivedTime')
        ..add(serializers.serialize(value,
            specifiedType: const FullType(String)));
    }
    value = object.woSeverityDesc;
    if (value != null) {
      result
        ..add('woSeverityDesc')
        ..add(serializers.serialize(value,
            specifiedType: const FullType(String)));
    }
    value = object.woTaskNo;
    if (value != null) {
      result
        ..add('woTaskNo')
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
    value = object.woTaskRequestNo;
    if (value != null) {
      result
        ..add('woTaskRequestNo')
        ..add(serializers.serialize(value,
            specifiedType: const FullType(String)));
    }
    value = object.woTypeDesc;
    if (value != null) {
      result
        ..add('woTypeDesc')
        ..add(serializers.serialize(value,
            specifiedType: const FullType(String)));
    }
    value = object.collectTime;
    if (value != null) {
      result
        ..add('collectTime')
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
    value = object.woTaskId;
    if (value != null) {
      result
        ..add('woTaskId')
        ..add(serializers.serialize(value,
            specifiedType: const FullType(String)));
    }
    return result;
  }

  @override
  RequestTask deserialize(Serializers serializers, Iterable<Object?> serialized,
      {FullType specifiedType = FullType.unspecified}) {
    final result = RequestTaskBuilder();

    final iterator = serialized.iterator;
    while (iterator.moveNext()) {
      final key = iterator.current! as String;
      iterator.moveNext();
      final Object? value = iterator.current;
      switch (key) {
        case 'requestBy':
          result.requestBy = serializers.deserialize(value,
              specifiedType: const FullType(String)) as String?;
          break;
        case 'requestTime':
          result.requestTime = serializers.deserialize(value,
              specifiedType: const FullType(String)) as String?;
          break;
        case 'statusDesc':
          result.statusDesc = serializers.deserialize(value,
              specifiedType: const FullType(String)) as String?;
          break;
        case 'statusId':
          result.statusId = serializers.deserialize(value,
              specifiedType: const FullType(String)) as String?;
          break;
        case 'checkpointId':
          result.checkpointId = serializers.deserialize(value,
              specifiedType: const FullType(String)) as String?;
          break;
        case 'checkpointDesc':
          result.checkpointDesc = serializers.deserialize(value,
              specifiedType: const FullType(String)) as String?;
          break;
        case 'taskFrom':
          result.taskFrom = serializers.deserialize(value,
              specifiedType: const FullType(String)) as String?;
          break;
        case 'taskReceivedTime':
          result.taskReceivedTime = serializers.deserialize(value,
              specifiedType: const FullType(String)) as String?;
          break;
        case 'woSeverityDesc':
          result.woSeverityDesc = serializers.deserialize(value,
              specifiedType: const FullType(String)) as String?;
          break;
        case 'woTaskNo':
          result.woTaskNo = serializers.deserialize(value,
              specifiedType: const FullType(String)) as String?;
          break;
        case 'woTaskRequestId':
          result.woTaskRequestId = serializers.deserialize(value,
              specifiedType: const FullType(String)) as String?;
          break;
        case 'woTaskRequestNo':
          result.woTaskRequestNo = serializers.deserialize(value,
              specifiedType: const FullType(String)) as String?;
          break;
        case 'woTypeDesc':
          result.woTypeDesc = serializers.deserialize(value,
              specifiedType: const FullType(String)) as String?;
          break;
        case 'collectTime':
          result.collectTime = serializers.deserialize(value,
              specifiedType: const FullType(String)) as String?;
          break;
        case 'siteName':
          result.siteName = serializers.deserialize(value,
              specifiedType: const FullType(String)) as String?;
          break;
        case 'woTaskId':
          result.woTaskId = serializers.deserialize(value,
              specifiedType: const FullType(String)) as String?;
          break;
      }
    }

    return result.build();
  }
}

class _$ComplaintMaterialSerializer
    implements StructuredSerializer<ComplaintMaterial> {
  @override
  final Iterable<Type> types = const [ComplaintMaterial, _$ComplaintMaterial];
  @override
  final String wireName = 'ComplaintMaterial';

  @override
  Iterable<Object?> serialize(Serializers serializers, ComplaintMaterial object,
      {FullType specifiedType = FullType.unspecified}) {
    final result = <Object?>[];
    Object? value;
    value = object.assetGroupId;
    if (value != null) {
      result
        ..add('assetGroupId')
        ..add(serializers.serialize(value,
            specifiedType: const FullType(String)));
    }
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
    value = object.itemTypeId;
    if (value != null) {
      result
        ..add('itemTypeId')
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
    value = object.partMaxOrder;
    if (value != null) {
      result
        ..add('partMaxOrder')
        ..add(serializers.serialize(value,
            specifiedType: const FullType(String)));
    }
    value = object.partMinOrder;
    if (value != null) {
      result
        ..add('partMinOrder')
        ..add(serializers.serialize(value,
            specifiedType: const FullType(String)));
    }
    value = object.partRemark;
    if (value != null) {
      result
        ..add('partRemark')
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
    value = object.itemGrouped;
    if (value != null) {
      result
        ..add('itemGrouped')
        ..add(serializers.serialize(value,
            specifiedType: const FullType(
                BuiltList, const [const FullType(ComplaintMaterialGrouped)])));
    }
    value = object.images;
    if (value != null) {
      result
        ..add('images')
        ..add(serializers.serialize(value,
            specifiedType: const FullType(
                BuiltList, const [const FullType(ComplaintMaterialImage)])));
    }
    return result;
  }

  @override
  ComplaintMaterial deserialize(
      Serializers serializers, Iterable<Object?> serialized,
      {FullType specifiedType = FullType.unspecified}) {
    final result = ComplaintMaterialBuilder();

    final iterator = serialized.iterator;
    while (iterator.moveNext()) {
      final key = iterator.current! as String;
      iterator.moveNext();
      final Object? value = iterator.current;
      switch (key) {
        case 'assetGroupId':
          result.assetGroupId = serializers.deserialize(value,
              specifiedType: const FullType(String)) as String?;
          break;
        case 'assetGroupName':
          result.assetGroupName = serializers.deserialize(value,
              specifiedType: const FullType(String)) as String?;
          break;
        case 'itemDescription':
          result.itemDescription = serializers.deserialize(value,
              specifiedType: const FullType(String)) as String?;
          break;
        case 'itemId':
          result.itemId = serializers.deserialize(value,
              specifiedType: const FullType(String)) as String?;
          break;
        case 'itemTypeDesc':
          result.itemTypeDesc = serializers.deserialize(value,
              specifiedType: const FullType(String)) as String?;
          break;
        case 'itemTypeId':
          result.itemTypeId = serializers.deserialize(value,
              specifiedType: const FullType(String)) as String?;
          break;
        case 'partAvailable':
          result.partAvailable = serializers.deserialize(value,
              specifiedType: const FullType(String)) as String?;
          break;
        case 'partCount':
          result.partCount = serializers.deserialize(value,
              specifiedType: const FullType(String)) as String?;
          break;
        case 'partId':
          result.partId = serializers.deserialize(value,
              specifiedType: const FullType(String)) as String?;
          break;
        case 'partLocked':
          result.partLocked = serializers.deserialize(value,
              specifiedType: const FullType(String)) as String?;
          break;
        case 'partMaxOrder':
          result.partMaxOrder = serializers.deserialize(value,
              specifiedType: const FullType(String)) as String?;
          break;
        case 'partMinOrder':
          result.partMinOrder = serializers.deserialize(value,
              specifiedType: const FullType(String)) as String?;
          break;
        case 'partRemark':
          result.partRemark = serializers.deserialize(value,
              specifiedType: const FullType(String)) as String?;
          break;
        case 'partThreshold':
          result.partThreshold = serializers.deserialize(value,
              specifiedType: const FullType(String)) as String?;
          break;
        case 'itemGrouped':
          result.itemGrouped.replace(serializers.deserialize(value,
              specifiedType: const FullType(BuiltList, const [
                const FullType(ComplaintMaterialGrouped)
              ]))! as BuiltList<Object?>);
          break;
        case 'images':
          result.images.replace(serializers.deserialize(value,
              specifiedType: const FullType(BuiltList, const [
                const FullType(ComplaintMaterialImage)
              ]))! as BuiltList<Object?>);
          break;
      }
    }

    return result.build();
  }
}

class _$ComplaintMaterialGroupedSerializer
    implements StructuredSerializer<ComplaintMaterialGrouped> {
  @override
  final Iterable<Type> types = const [
    ComplaintMaterialGrouped,
    _$ComplaintMaterialGrouped
  ];
  @override
  final String wireName = 'ComplaintMaterialGrouped';

  @override
  Iterable<Object?> serialize(
      Serializers serializers, ComplaintMaterialGrouped object,
      {FullType specifiedType = FullType.unspecified}) {
    final result = <Object?>[
      'dateCheckIn',
      serializers.serialize(object.dateCheckIn,
          specifiedType: const FullType(String)),
      'doNo',
      serializers.serialize(object.doNo, specifiedType: const FullType(String)),
      'partSubCost',
      serializers.serialize(object.partSubCost,
          specifiedType: const FullType(String)),
      'partSubLocation',
      serializers.serialize(object.partSubLocation,
          specifiedType: const FullType(String)),
      'partSubValidity',
      serializers.serialize(object.partSubValidity,
          specifiedType: const FullType(String)),
      'partSubWarranty',
      serializers.serialize(object.partSubWarranty,
          specifiedType: const FullType(String)),
      'supplierName',
      serializers.serialize(object.supplierName,
          specifiedType: const FullType(String)),
      'total',
      serializers.serialize(object.total,
          specifiedType: const FullType(String)),
    ];

    return result;
  }

  @override
  ComplaintMaterialGrouped deserialize(
      Serializers serializers, Iterable<Object?> serialized,
      {FullType specifiedType = FullType.unspecified}) {
    final result = ComplaintMaterialGroupedBuilder();

    final iterator = serialized.iterator;
    while (iterator.moveNext()) {
      final key = iterator.current! as String;
      iterator.moveNext();
      final Object? value = iterator.current;
      switch (key) {
        case 'dateCheckIn':
          result.dateCheckIn = serializers.deserialize(value,
              specifiedType: const FullType(String))! as String;
          break;
        case 'doNo':
          result.doNo = serializers.deserialize(value,
              specifiedType: const FullType(String))! as String;
          break;
        case 'partSubCost':
          result.partSubCost = serializers.deserialize(value,
              specifiedType: const FullType(String))! as String;
          break;
        case 'partSubLocation':
          result.partSubLocation = serializers.deserialize(value,
              specifiedType: const FullType(String))! as String;
          break;
        case 'partSubValidity':
          result.partSubValidity = serializers.deserialize(value,
              specifiedType: const FullType(String))! as String;
          break;
        case 'partSubWarranty':
          result.partSubWarranty = serializers.deserialize(value,
              specifiedType: const FullType(String))! as String;
          break;
        case 'supplierName':
          result.supplierName = serializers.deserialize(value,
              specifiedType: const FullType(String))! as String;
          break;
        case 'total':
          result.total = serializers.deserialize(value,
              specifiedType: const FullType(String))! as String;
          break;
      }
    }

    return result.build();
  }
}

class _$ComplaintMaterialImageSerializer
    implements StructuredSerializer<ComplaintMaterialImage> {
  @override
  final Iterable<Type> types = const [
    ComplaintMaterialImage,
    _$ComplaintMaterialImage
  ];
  @override
  final String wireName = 'ComplaintMaterialImage';

  @override
  Iterable<Object?> serialize(
      Serializers serializers, ComplaintMaterialImage object,
      {FullType specifiedType = FullType.unspecified}) {
    final result = <Object?>[];
    Object? value;
    value = object.file;
    if (value != null) {
      result
        ..add('file')
        ..add(serializers.serialize(value,
            specifiedType: const FullType(String)));
    }
    value = object.height;
    if (value != null) {
      result
        ..add('height')
        ..add(serializers.serialize(value,
            specifiedType: const FullType(String)));
    }
    value = object.width;
    if (value != null) {
      result
        ..add('width')
        ..add(serializers.serialize(value,
            specifiedType: const FullType(String)));
    }
    value = object.title;
    if (value != null) {
      result
        ..add('title')
        ..add(serializers.serialize(value,
            specifiedType: const FullType(String)));
    }
    return result;
  }

  @override
  ComplaintMaterialImage deserialize(
      Serializers serializers, Iterable<Object?> serialized,
      {FullType specifiedType = FullType.unspecified}) {
    final result = ComplaintMaterialImageBuilder();

    final iterator = serialized.iterator;
    while (iterator.moveNext()) {
      final key = iterator.current! as String;
      iterator.moveNext();
      final Object? value = iterator.current;
      switch (key) {
        case 'file':
          result.file = serializers.deserialize(value,
              specifiedType: const FullType(String)) as String?;
          break;
        case 'height':
          result.height = serializers.deserialize(value,
              specifiedType: const FullType(String)) as String?;
          break;
        case 'width':
          result.width = serializers.deserialize(value,
              specifiedType: const FullType(String)) as String?;
          break;
        case 'title':
          result.title = serializers.deserialize(value,
              specifiedType: const FullType(String)) as String?;
          break;
      }
    }

    return result.build();
  }
}

class _$ComplaintD extends ComplaintD {
  @override
  final String? woTaskPartsId;
  @override
  final String? woTaskRequestId;
  @override
  final String? partId;
  @override
  final String? woTaskPartsQuantity;
  @override
  final String? woTaskPartsRemark;
  @override
  final String? woTaskPartsStatus;
  @override
  final String? itemDescription;
  @override
  final String? itemTypeDesc;
  @override
  final String? assetGroupName;
  @override
  final String? statusDesc;
  @override
  final BuiltList<ComplaintDImage>? images;

  factory _$ComplaintD([void Function(ComplaintDBuilder)? updates]) =>
      (ComplaintDBuilder()..update(updates))._build();

  _$ComplaintD._(
      {this.woTaskPartsId,
      this.woTaskRequestId,
      this.partId,
      this.woTaskPartsQuantity,
      this.woTaskPartsRemark,
      this.woTaskPartsStatus,
      this.itemDescription,
      this.itemTypeDesc,
      this.assetGroupName,
      this.statusDesc,
      this.images})
      : super._();
  @override
  ComplaintD rebuild(void Function(ComplaintDBuilder) updates) =>
      (toBuilder()..update(updates)).build();

  @override
  ComplaintDBuilder toBuilder() => ComplaintDBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is ComplaintD &&
        woTaskPartsId == other.woTaskPartsId &&
        woTaskRequestId == other.woTaskRequestId &&
        partId == other.partId &&
        woTaskPartsQuantity == other.woTaskPartsQuantity &&
        woTaskPartsRemark == other.woTaskPartsRemark &&
        woTaskPartsStatus == other.woTaskPartsStatus &&
        itemDescription == other.itemDescription &&
        itemTypeDesc == other.itemTypeDesc &&
        assetGroupName == other.assetGroupName &&
        statusDesc == other.statusDesc &&
        images == other.images;
  }

  @override
  int get hashCode {
    var _$hash = 0;
    _$hash = $jc(_$hash, woTaskPartsId.hashCode);
    _$hash = $jc(_$hash, woTaskRequestId.hashCode);
    _$hash = $jc(_$hash, partId.hashCode);
    _$hash = $jc(_$hash, woTaskPartsQuantity.hashCode);
    _$hash = $jc(_$hash, woTaskPartsRemark.hashCode);
    _$hash = $jc(_$hash, woTaskPartsStatus.hashCode);
    _$hash = $jc(_$hash, itemDescription.hashCode);
    _$hash = $jc(_$hash, itemTypeDesc.hashCode);
    _$hash = $jc(_$hash, assetGroupName.hashCode);
    _$hash = $jc(_$hash, statusDesc.hashCode);
    _$hash = $jc(_$hash, images.hashCode);
    _$hash = $jf(_$hash);
    return _$hash;
  }

  @override
  String toString() {
    return (newBuiltValueToStringHelper(r'ComplaintD')
          ..add('woTaskPartsId', woTaskPartsId)
          ..add('woTaskRequestId', woTaskRequestId)
          ..add('partId', partId)
          ..add('woTaskPartsQuantity', woTaskPartsQuantity)
          ..add('woTaskPartsRemark', woTaskPartsRemark)
          ..add('woTaskPartsStatus', woTaskPartsStatus)
          ..add('itemDescription', itemDescription)
          ..add('itemTypeDesc', itemTypeDesc)
          ..add('assetGroupName', assetGroupName)
          ..add('statusDesc', statusDesc)
          ..add('images', images))
        .toString();
  }
}

class ComplaintDBuilder implements Builder<ComplaintD, ComplaintDBuilder> {
  _$ComplaintD? _$v;

  String? _woTaskPartsId;
  String? get woTaskPartsId => _$this._woTaskPartsId;
  set woTaskPartsId(String? woTaskPartsId) =>
      _$this._woTaskPartsId = woTaskPartsId;

  String? _woTaskRequestId;
  String? get woTaskRequestId => _$this._woTaskRequestId;
  set woTaskRequestId(String? woTaskRequestId) =>
      _$this._woTaskRequestId = woTaskRequestId;

  String? _partId;
  String? get partId => _$this._partId;
  set partId(String? partId) => _$this._partId = partId;

  String? _woTaskPartsQuantity;
  String? get woTaskPartsQuantity => _$this._woTaskPartsQuantity;
  set woTaskPartsQuantity(String? woTaskPartsQuantity) =>
      _$this._woTaskPartsQuantity = woTaskPartsQuantity;

  String? _woTaskPartsRemark;
  String? get woTaskPartsRemark => _$this._woTaskPartsRemark;
  set woTaskPartsRemark(String? woTaskPartsRemark) =>
      _$this._woTaskPartsRemark = woTaskPartsRemark;

  String? _woTaskPartsStatus;
  String? get woTaskPartsStatus => _$this._woTaskPartsStatus;
  set woTaskPartsStatus(String? woTaskPartsStatus) =>
      _$this._woTaskPartsStatus = woTaskPartsStatus;

  String? _itemDescription;
  String? get itemDescription => _$this._itemDescription;
  set itemDescription(String? itemDescription) =>
      _$this._itemDescription = itemDescription;

  String? _itemTypeDesc;
  String? get itemTypeDesc => _$this._itemTypeDesc;
  set itemTypeDesc(String? itemTypeDesc) => _$this._itemTypeDesc = itemTypeDesc;

  String? _assetGroupName;
  String? get assetGroupName => _$this._assetGroupName;
  set assetGroupName(String? assetGroupName) =>
      _$this._assetGroupName = assetGroupName;

  String? _statusDesc;
  String? get statusDesc => _$this._statusDesc;
  set statusDesc(String? statusDesc) => _$this._statusDesc = statusDesc;

  ListBuilder<ComplaintDImage>? _images;
  ListBuilder<ComplaintDImage> get images =>
      _$this._images ??= ListBuilder<ComplaintDImage>();
  set images(ListBuilder<ComplaintDImage>? images) => _$this._images = images;

  ComplaintDBuilder();

  ComplaintDBuilder get _$this {
    final $v = _$v;
    if ($v != null) {
      _woTaskPartsId = $v.woTaskPartsId;
      _woTaskRequestId = $v.woTaskRequestId;
      _partId = $v.partId;
      _woTaskPartsQuantity = $v.woTaskPartsQuantity;
      _woTaskPartsRemark = $v.woTaskPartsRemark;
      _woTaskPartsStatus = $v.woTaskPartsStatus;
      _itemDescription = $v.itemDescription;
      _itemTypeDesc = $v.itemTypeDesc;
      _assetGroupName = $v.assetGroupName;
      _statusDesc = $v.statusDesc;
      _images = $v.images?.toBuilder();
      _$v = null;
    }
    return this;
  }

  @override
  void replace(ComplaintD other) {
    _$v = other as _$ComplaintD;
  }

  @override
  void update(void Function(ComplaintDBuilder)? updates) {
    if (updates != null) updates(this);
  }

  @override
  ComplaintD build() => _build();

  _$ComplaintD _build() {
    _$ComplaintD _$result;
    try {
      _$result = _$v ??
          _$ComplaintD._(
            woTaskPartsId: woTaskPartsId,
            woTaskRequestId: woTaskRequestId,
            partId: partId,
            woTaskPartsQuantity: woTaskPartsQuantity,
            woTaskPartsRemark: woTaskPartsRemark,
            woTaskPartsStatus: woTaskPartsStatus,
            itemDescription: itemDescription,
            itemTypeDesc: itemTypeDesc,
            assetGroupName: assetGroupName,
            statusDesc: statusDesc,
            images: _images?.build(),
          );
    } catch (_) {
      late String _$failedField;
      try {
        _$failedField = 'images';
        _images?.build();
      } catch (e) {
        throw BuiltValueNestedFieldError(
            r'ComplaintD', _$failedField, e.toString());
      }
      rethrow;
    }
    replace(_$result);
    return _$result;
  }
}

class _$ComplaintDStore extends ComplaintDStore {
  @override
  final String? itemId;
  @override
  final String? itemName;

  factory _$ComplaintDStore([void Function(ComplaintDStoreBuilder)? updates]) =>
      (ComplaintDStoreBuilder()..update(updates))._build();

  _$ComplaintDStore._({this.itemId, this.itemName}) : super._();
  @override
  ComplaintDStore rebuild(void Function(ComplaintDStoreBuilder) updates) =>
      (toBuilder()..update(updates)).build();

  @override
  ComplaintDStoreBuilder toBuilder() => ComplaintDStoreBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is ComplaintDStore &&
        itemId == other.itemId &&
        itemName == other.itemName;
  }

  @override
  int get hashCode {
    var _$hash = 0;
    _$hash = $jc(_$hash, itemId.hashCode);
    _$hash = $jc(_$hash, itemName.hashCode);
    _$hash = $jf(_$hash);
    return _$hash;
  }

  @override
  String toString() {
    return (newBuiltValueToStringHelper(r'ComplaintDStore')
          ..add('itemId', itemId)
          ..add('itemName', itemName))
        .toString();
  }
}

class ComplaintDStoreBuilder
    implements Builder<ComplaintDStore, ComplaintDStoreBuilder> {
  _$ComplaintDStore? _$v;

  String? _itemId;
  String? get itemId => _$this._itemId;
  set itemId(String? itemId) => _$this._itemId = itemId;

  String? _itemName;
  String? get itemName => _$this._itemName;
  set itemName(String? itemName) => _$this._itemName = itemName;

  ComplaintDStoreBuilder();

  ComplaintDStoreBuilder get _$this {
    final $v = _$v;
    if ($v != null) {
      _itemId = $v.itemId;
      _itemName = $v.itemName;
      _$v = null;
    }
    return this;
  }

  @override
  void replace(ComplaintDStore other) {
    _$v = other as _$ComplaintDStore;
  }

  @override
  void update(void Function(ComplaintDStoreBuilder)? updates) {
    if (updates != null) updates(this);
  }

  @override
  ComplaintDStore build() => _build();

  _$ComplaintDStore _build() {
    final _$result = _$v ??
        _$ComplaintDStore._(
          itemId: itemId,
          itemName: itemName,
        );
    replace(_$result);
    return _$result;
  }
}

class _$ComplaintDGroupStore extends ComplaintDGroupStore {
  @override
  final String? itemId;
  @override
  final String? itemName;
  @override
  final BuiltList<ComplaintDType>? itemTypes;

  factory _$ComplaintDGroupStore(
          [void Function(ComplaintDGroupStoreBuilder)? updates]) =>
      (ComplaintDGroupStoreBuilder()..update(updates))._build();

  _$ComplaintDGroupStore._({this.itemId, this.itemName, this.itemTypes})
      : super._();
  @override
  ComplaintDGroupStore rebuild(
          void Function(ComplaintDGroupStoreBuilder) updates) =>
      (toBuilder()..update(updates)).build();

  @override
  ComplaintDGroupStoreBuilder toBuilder() =>
      ComplaintDGroupStoreBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is ComplaintDGroupStore &&
        itemId == other.itemId &&
        itemName == other.itemName &&
        itemTypes == other.itemTypes;
  }

  @override
  int get hashCode {
    var _$hash = 0;
    _$hash = $jc(_$hash, itemId.hashCode);
    _$hash = $jc(_$hash, itemName.hashCode);
    _$hash = $jc(_$hash, itemTypes.hashCode);
    _$hash = $jf(_$hash);
    return _$hash;
  }

  @override
  String toString() {
    return (newBuiltValueToStringHelper(r'ComplaintDGroupStore')
          ..add('itemId', itemId)
          ..add('itemName', itemName)
          ..add('itemTypes', itemTypes))
        .toString();
  }
}

class ComplaintDGroupStoreBuilder
    implements Builder<ComplaintDGroupStore, ComplaintDGroupStoreBuilder> {
  _$ComplaintDGroupStore? _$v;

  String? _itemId;
  String? get itemId => _$this._itemId;
  set itemId(String? itemId) => _$this._itemId = itemId;

  String? _itemName;
  String? get itemName => _$this._itemName;
  set itemName(String? itemName) => _$this._itemName = itemName;

  ListBuilder<ComplaintDType>? _itemTypes;
  ListBuilder<ComplaintDType> get itemTypes =>
      _$this._itemTypes ??= ListBuilder<ComplaintDType>();
  set itemTypes(ListBuilder<ComplaintDType>? itemTypes) =>
      _$this._itemTypes = itemTypes;

  ComplaintDGroupStoreBuilder();

  ComplaintDGroupStoreBuilder get _$this {
    final $v = _$v;
    if ($v != null) {
      _itemId = $v.itemId;
      _itemName = $v.itemName;
      _itemTypes = $v.itemTypes?.toBuilder();
      _$v = null;
    }
    return this;
  }

  @override
  void replace(ComplaintDGroupStore other) {
    _$v = other as _$ComplaintDGroupStore;
  }

  @override
  void update(void Function(ComplaintDGroupStoreBuilder)? updates) {
    if (updates != null) updates(this);
  }

  @override
  ComplaintDGroupStore build() => _build();

  _$ComplaintDGroupStore _build() {
    _$ComplaintDGroupStore _$result;
    try {
      _$result = _$v ??
          _$ComplaintDGroupStore._(
            itemId: itemId,
            itemName: itemName,
            itemTypes: _itemTypes?.build(),
          );
    } catch (_) {
      late String _$failedField;
      try {
        _$failedField = 'itemTypes';
        _itemTypes?.build();
      } catch (e) {
        throw BuiltValueNestedFieldError(
            r'ComplaintDGroupStore', _$failedField, e.toString());
      }
      rethrow;
    }
    replace(_$result);
    return _$result;
  }
}

class _$ComplaintDGroup extends ComplaintDGroup {
  @override
  final String? itemId;
  @override
  final String? itemName;
  @override
  final String? itemDesc;
  @override
  final String? itemStatus;

  factory _$ComplaintDGroup([void Function(ComplaintDGroupBuilder)? updates]) =>
      (ComplaintDGroupBuilder()..update(updates))._build();

  _$ComplaintDGroup._(
      {this.itemId, this.itemName, this.itemDesc, this.itemStatus})
      : super._();
  @override
  ComplaintDGroup rebuild(void Function(ComplaintDGroupBuilder) updates) =>
      (toBuilder()..update(updates)).build();

  @override
  ComplaintDGroupBuilder toBuilder() => ComplaintDGroupBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is ComplaintDGroup &&
        itemId == other.itemId &&
        itemName == other.itemName &&
        itemDesc == other.itemDesc &&
        itemStatus == other.itemStatus;
  }

  @override
  int get hashCode {
    var _$hash = 0;
    _$hash = $jc(_$hash, itemId.hashCode);
    _$hash = $jc(_$hash, itemName.hashCode);
    _$hash = $jc(_$hash, itemDesc.hashCode);
    _$hash = $jc(_$hash, itemStatus.hashCode);
    _$hash = $jf(_$hash);
    return _$hash;
  }

  @override
  String toString() {
    return (newBuiltValueToStringHelper(r'ComplaintDGroup')
          ..add('itemId', itemId)
          ..add('itemName', itemName)
          ..add('itemDesc', itemDesc)
          ..add('itemStatus', itemStatus))
        .toString();
  }
}

class ComplaintDGroupBuilder
    implements Builder<ComplaintDGroup, ComplaintDGroupBuilder> {
  _$ComplaintDGroup? _$v;

  String? _itemId;
  String? get itemId => _$this._itemId;
  set itemId(String? itemId) => _$this._itemId = itemId;

  String? _itemName;
  String? get itemName => _$this._itemName;
  set itemName(String? itemName) => _$this._itemName = itemName;

  String? _itemDesc;
  String? get itemDesc => _$this._itemDesc;
  set itemDesc(String? itemDesc) => _$this._itemDesc = itemDesc;

  String? _itemStatus;
  String? get itemStatus => _$this._itemStatus;
  set itemStatus(String? itemStatus) => _$this._itemStatus = itemStatus;

  ComplaintDGroupBuilder();

  ComplaintDGroupBuilder get _$this {
    final $v = _$v;
    if ($v != null) {
      _itemId = $v.itemId;
      _itemName = $v.itemName;
      _itemDesc = $v.itemDesc;
      _itemStatus = $v.itemStatus;
      _$v = null;
    }
    return this;
  }

  @override
  void replace(ComplaintDGroup other) {
    _$v = other as _$ComplaintDGroup;
  }

  @override
  void update(void Function(ComplaintDGroupBuilder)? updates) {
    if (updates != null) updates(this);
  }

  @override
  ComplaintDGroup build() => _build();

  _$ComplaintDGroup _build() {
    final _$result = _$v ??
        _$ComplaintDGroup._(
          itemId: itemId,
          itemName: itemName,
          itemDesc: itemDesc,
          itemStatus: itemStatus,
        );
    replace(_$result);
    return _$result;
  }
}

class _$ComplaintDType extends ComplaintDType {
  @override
  final String? itemId;
  @override
  final String? itemGroupId;
  @override
  final String? itemName;
  @override
  final String? itemTypeDesc;
  @override
  final String? itemStatus;
  @override
  final BuiltList<ComplaintMaterial>? parts;

  factory _$ComplaintDType([void Function(ComplaintDTypeBuilder)? updates]) =>
      (ComplaintDTypeBuilder()..update(updates))._build();

  _$ComplaintDType._(
      {this.itemId,
      this.itemGroupId,
      this.itemName,
      this.itemTypeDesc,
      this.itemStatus,
      this.parts})
      : super._();
  @override
  ComplaintDType rebuild(void Function(ComplaintDTypeBuilder) updates) =>
      (toBuilder()..update(updates)).build();

  @override
  ComplaintDTypeBuilder toBuilder() => ComplaintDTypeBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is ComplaintDType &&
        itemId == other.itemId &&
        itemGroupId == other.itemGroupId &&
        itemName == other.itemName &&
        itemTypeDesc == other.itemTypeDesc &&
        itemStatus == other.itemStatus &&
        parts == other.parts;
  }

  @override
  int get hashCode {
    var _$hash = 0;
    _$hash = $jc(_$hash, itemId.hashCode);
    _$hash = $jc(_$hash, itemGroupId.hashCode);
    _$hash = $jc(_$hash, itemName.hashCode);
    _$hash = $jc(_$hash, itemTypeDesc.hashCode);
    _$hash = $jc(_$hash, itemStatus.hashCode);
    _$hash = $jc(_$hash, parts.hashCode);
    _$hash = $jf(_$hash);
    return _$hash;
  }

  @override
  String toString() {
    return (newBuiltValueToStringHelper(r'ComplaintDType')
          ..add('itemId', itemId)
          ..add('itemGroupId', itemGroupId)
          ..add('itemName', itemName)
          ..add('itemTypeDesc', itemTypeDesc)
          ..add('itemStatus', itemStatus)
          ..add('parts', parts))
        .toString();
  }
}

class ComplaintDTypeBuilder
    implements Builder<ComplaintDType, ComplaintDTypeBuilder> {
  _$ComplaintDType? _$v;

  String? _itemId;
  String? get itemId => _$this._itemId;
  set itemId(String? itemId) => _$this._itemId = itemId;

  String? _itemGroupId;
  String? get itemGroupId => _$this._itemGroupId;
  set itemGroupId(String? itemGroupId) => _$this._itemGroupId = itemGroupId;

  String? _itemName;
  String? get itemName => _$this._itemName;
  set itemName(String? itemName) => _$this._itemName = itemName;

  String? _itemTypeDesc;
  String? get itemTypeDesc => _$this._itemTypeDesc;
  set itemTypeDesc(String? itemTypeDesc) => _$this._itemTypeDesc = itemTypeDesc;

  String? _itemStatus;
  String? get itemStatus => _$this._itemStatus;
  set itemStatus(String? itemStatus) => _$this._itemStatus = itemStatus;

  ListBuilder<ComplaintMaterial>? _parts;
  ListBuilder<ComplaintMaterial> get parts =>
      _$this._parts ??= ListBuilder<ComplaintMaterial>();
  set parts(ListBuilder<ComplaintMaterial>? parts) => _$this._parts = parts;

  ComplaintDTypeBuilder();

  ComplaintDTypeBuilder get _$this {
    final $v = _$v;
    if ($v != null) {
      _itemId = $v.itemId;
      _itemGroupId = $v.itemGroupId;
      _itemName = $v.itemName;
      _itemTypeDesc = $v.itemTypeDesc;
      _itemStatus = $v.itemStatus;
      _parts = $v.parts?.toBuilder();
      _$v = null;
    }
    return this;
  }

  @override
  void replace(ComplaintDType other) {
    _$v = other as _$ComplaintDType;
  }

  @override
  void update(void Function(ComplaintDTypeBuilder)? updates) {
    if (updates != null) updates(this);
  }

  @override
  ComplaintDType build() => _build();

  _$ComplaintDType _build() {
    _$ComplaintDType _$result;
    try {
      _$result = _$v ??
          _$ComplaintDType._(
            itemId: itemId,
            itemGroupId: itemGroupId,
            itemName: itemName,
            itemTypeDesc: itemTypeDesc,
            itemStatus: itemStatus,
            parts: _parts?.build(),
          );
    } catch (_) {
      late String _$failedField;
      try {
        _$failedField = 'parts';
        _parts?.build();
      } catch (e) {
        throw BuiltValueNestedFieldError(
            r'ComplaintDType', _$failedField, e.toString());
      }
      rethrow;
    }
    replace(_$result);
    return _$result;
  }
}

class _$ComplaintDStoreType extends ComplaintDStoreType {
  @override
  final String? itemId;
  @override
  final String? itemName;
  @override
  final BuiltList<ComplaintMaterial>? parts;

  factory _$ComplaintDStoreType(
          [void Function(ComplaintDStoreTypeBuilder)? updates]) =>
      (ComplaintDStoreTypeBuilder()..update(updates))._build();

  _$ComplaintDStoreType._({this.itemId, this.itemName, this.parts}) : super._();
  @override
  ComplaintDStoreType rebuild(
          void Function(ComplaintDStoreTypeBuilder) updates) =>
      (toBuilder()..update(updates)).build();

  @override
  ComplaintDStoreTypeBuilder toBuilder() =>
      ComplaintDStoreTypeBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is ComplaintDStoreType &&
        itemId == other.itemId &&
        itemName == other.itemName &&
        parts == other.parts;
  }

  @override
  int get hashCode {
    var _$hash = 0;
    _$hash = $jc(_$hash, itemId.hashCode);
    _$hash = $jc(_$hash, itemName.hashCode);
    _$hash = $jc(_$hash, parts.hashCode);
    _$hash = $jf(_$hash);
    return _$hash;
  }

  @override
  String toString() {
    return (newBuiltValueToStringHelper(r'ComplaintDStoreType')
          ..add('itemId', itemId)
          ..add('itemName', itemName)
          ..add('parts', parts))
        .toString();
  }
}

class ComplaintDStoreTypeBuilder
    implements Builder<ComplaintDStoreType, ComplaintDStoreTypeBuilder> {
  _$ComplaintDStoreType? _$v;

  String? _itemId;
  String? get itemId => _$this._itemId;
  set itemId(String? itemId) => _$this._itemId = itemId;

  String? _itemName;
  String? get itemName => _$this._itemName;
  set itemName(String? itemName) => _$this._itemName = itemName;

  ListBuilder<ComplaintMaterial>? _parts;
  ListBuilder<ComplaintMaterial> get parts =>
      _$this._parts ??= ListBuilder<ComplaintMaterial>();
  set parts(ListBuilder<ComplaintMaterial>? parts) => _$this._parts = parts;

  ComplaintDStoreTypeBuilder();

  ComplaintDStoreTypeBuilder get _$this {
    final $v = _$v;
    if ($v != null) {
      _itemId = $v.itemId;
      _itemName = $v.itemName;
      _parts = $v.parts?.toBuilder();
      _$v = null;
    }
    return this;
  }

  @override
  void replace(ComplaintDStoreType other) {
    _$v = other as _$ComplaintDStoreType;
  }

  @override
  void update(void Function(ComplaintDStoreTypeBuilder)? updates) {
    if (updates != null) updates(this);
  }

  @override
  ComplaintDStoreType build() => _build();

  _$ComplaintDStoreType _build() {
    _$ComplaintDStoreType _$result;
    try {
      _$result = _$v ??
          _$ComplaintDStoreType._(
            itemId: itemId,
            itemName: itemName,
            parts: _parts?.build(),
          );
    } catch (_) {
      late String _$failedField;
      try {
        _$failedField = 'parts';
        _parts?.build();
      } catch (e) {
        throw BuiltValueNestedFieldError(
            r'ComplaintDStoreType', _$failedField, e.toString());
      }
      rethrow;
    }
    replace(_$result);
    return _$result;
  }
}

class _$ComplaintDPart extends ComplaintDPart {
  @override
  final String? itemId;
  @override
  final String? itemName;
  @override
  final String? itemQuantity;
  @override
  final String? itemTypeDesc;
  @override
  final String? partLocked;
  @override
  final String? partMaxOrder;
  @override
  final String? partMinOrder;
  @override
  final String? partRemark;

  factory _$ComplaintDPart([void Function(ComplaintDPartBuilder)? updates]) =>
      (ComplaintDPartBuilder()..update(updates))._build();

  _$ComplaintDPart._(
      {this.itemId,
      this.itemName,
      this.itemQuantity,
      this.itemTypeDesc,
      this.partLocked,
      this.partMaxOrder,
      this.partMinOrder,
      this.partRemark})
      : super._();
  @override
  ComplaintDPart rebuild(void Function(ComplaintDPartBuilder) updates) =>
      (toBuilder()..update(updates)).build();

  @override
  ComplaintDPartBuilder toBuilder() => ComplaintDPartBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is ComplaintDPart &&
        itemId == other.itemId &&
        itemName == other.itemName &&
        itemQuantity == other.itemQuantity &&
        itemTypeDesc == other.itemTypeDesc &&
        partLocked == other.partLocked &&
        partMaxOrder == other.partMaxOrder &&
        partMinOrder == other.partMinOrder &&
        partRemark == other.partRemark;
  }

  @override
  int get hashCode {
    var _$hash = 0;
    _$hash = $jc(_$hash, itemId.hashCode);
    _$hash = $jc(_$hash, itemName.hashCode);
    _$hash = $jc(_$hash, itemQuantity.hashCode);
    _$hash = $jc(_$hash, itemTypeDesc.hashCode);
    _$hash = $jc(_$hash, partLocked.hashCode);
    _$hash = $jc(_$hash, partMaxOrder.hashCode);
    _$hash = $jc(_$hash, partMinOrder.hashCode);
    _$hash = $jc(_$hash, partRemark.hashCode);
    _$hash = $jf(_$hash);
    return _$hash;
  }

  @override
  String toString() {
    return (newBuiltValueToStringHelper(r'ComplaintDPart')
          ..add('itemId', itemId)
          ..add('itemName', itemName)
          ..add('itemQuantity', itemQuantity)
          ..add('itemTypeDesc', itemTypeDesc)
          ..add('partLocked', partLocked)
          ..add('partMaxOrder', partMaxOrder)
          ..add('partMinOrder', partMinOrder)
          ..add('partRemark', partRemark))
        .toString();
  }
}

class ComplaintDPartBuilder
    implements Builder<ComplaintDPart, ComplaintDPartBuilder> {
  _$ComplaintDPart? _$v;

  String? _itemId;
  String? get itemId => _$this._itemId;
  set itemId(String? itemId) => _$this._itemId = itemId;

  String? _itemName;
  String? get itemName => _$this._itemName;
  set itemName(String? itemName) => _$this._itemName = itemName;

  String? _itemQuantity;
  String? get itemQuantity => _$this._itemQuantity;
  set itemQuantity(String? itemQuantity) => _$this._itemQuantity = itemQuantity;

  String? _itemTypeDesc;
  String? get itemTypeDesc => _$this._itemTypeDesc;
  set itemTypeDesc(String? itemTypeDesc) => _$this._itemTypeDesc = itemTypeDesc;

  String? _partLocked;
  String? get partLocked => _$this._partLocked;
  set partLocked(String? partLocked) => _$this._partLocked = partLocked;

  String? _partMaxOrder;
  String? get partMaxOrder => _$this._partMaxOrder;
  set partMaxOrder(String? partMaxOrder) => _$this._partMaxOrder = partMaxOrder;

  String? _partMinOrder;
  String? get partMinOrder => _$this._partMinOrder;
  set partMinOrder(String? partMinOrder) => _$this._partMinOrder = partMinOrder;

  String? _partRemark;
  String? get partRemark => _$this._partRemark;
  set partRemark(String? partRemark) => _$this._partRemark = partRemark;

  ComplaintDPartBuilder();

  ComplaintDPartBuilder get _$this {
    final $v = _$v;
    if ($v != null) {
      _itemId = $v.itemId;
      _itemName = $v.itemName;
      _itemQuantity = $v.itemQuantity;
      _itemTypeDesc = $v.itemTypeDesc;
      _partLocked = $v.partLocked;
      _partMaxOrder = $v.partMaxOrder;
      _partMinOrder = $v.partMinOrder;
      _partRemark = $v.partRemark;
      _$v = null;
    }
    return this;
  }

  @override
  void replace(ComplaintDPart other) {
    _$v = other as _$ComplaintDPart;
  }

  @override
  void update(void Function(ComplaintDPartBuilder)? updates) {
    if (updates != null) updates(this);
  }

  @override
  ComplaintDPart build() => _build();

  _$ComplaintDPart _build() {
    final _$result = _$v ??
        _$ComplaintDPart._(
          itemId: itemId,
          itemName: itemName,
          itemQuantity: itemQuantity,
          itemTypeDesc: itemTypeDesc,
          partLocked: partLocked,
          partMaxOrder: partMaxOrder,
          partMinOrder: partMinOrder,
          partRemark: partRemark,
        );
    replace(_$result);
    return _$result;
  }
}

class _$MaterialStorePart extends MaterialStorePart {
  @override
  final String? itemDescription;
  @override
  final String? partAvailable;
  @override
  final String? partCount;
  @override
  final String? partId;
  @override
  final String? partLocked;
  @override
  final String? partMaxOrder;
  @override
  final String? partMinOrder;
  @override
  final String? partRemark;

  factory _$MaterialStorePart(
          [void Function(MaterialStorePartBuilder)? updates]) =>
      (MaterialStorePartBuilder()..update(updates))._build();

  _$MaterialStorePart._(
      {this.itemDescription,
      this.partAvailable,
      this.partCount,
      this.partId,
      this.partLocked,
      this.partMaxOrder,
      this.partMinOrder,
      this.partRemark})
      : super._();
  @override
  MaterialStorePart rebuild(void Function(MaterialStorePartBuilder) updates) =>
      (toBuilder()..update(updates)).build();

  @override
  MaterialStorePartBuilder toBuilder() =>
      MaterialStorePartBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is MaterialStorePart &&
        itemDescription == other.itemDescription &&
        partAvailable == other.partAvailable &&
        partCount == other.partCount &&
        partId == other.partId &&
        partLocked == other.partLocked &&
        partMaxOrder == other.partMaxOrder &&
        partMinOrder == other.partMinOrder &&
        partRemark == other.partRemark;
  }

  @override
  int get hashCode {
    var _$hash = 0;
    _$hash = $jc(_$hash, itemDescription.hashCode);
    _$hash = $jc(_$hash, partAvailable.hashCode);
    _$hash = $jc(_$hash, partCount.hashCode);
    _$hash = $jc(_$hash, partId.hashCode);
    _$hash = $jc(_$hash, partLocked.hashCode);
    _$hash = $jc(_$hash, partMaxOrder.hashCode);
    _$hash = $jc(_$hash, partMinOrder.hashCode);
    _$hash = $jc(_$hash, partRemark.hashCode);
    _$hash = $jf(_$hash);
    return _$hash;
  }

  @override
  String toString() {
    return (newBuiltValueToStringHelper(r'MaterialStorePart')
          ..add('itemDescription', itemDescription)
          ..add('partAvailable', partAvailable)
          ..add('partCount', partCount)
          ..add('partId', partId)
          ..add('partLocked', partLocked)
          ..add('partMaxOrder', partMaxOrder)
          ..add('partMinOrder', partMinOrder)
          ..add('partRemark', partRemark))
        .toString();
  }
}

class MaterialStorePartBuilder
    implements Builder<MaterialStorePart, MaterialStorePartBuilder> {
  _$MaterialStorePart? _$v;

  String? _itemDescription;
  String? get itemDescription => _$this._itemDescription;
  set itemDescription(String? itemDescription) =>
      _$this._itemDescription = itemDescription;

  String? _partAvailable;
  String? get partAvailable => _$this._partAvailable;
  set partAvailable(String? partAvailable) =>
      _$this._partAvailable = partAvailable;

  String? _partCount;
  String? get partCount => _$this._partCount;
  set partCount(String? partCount) => _$this._partCount = partCount;

  String? _partId;
  String? get partId => _$this._partId;
  set partId(String? partId) => _$this._partId = partId;

  String? _partLocked;
  String? get partLocked => _$this._partLocked;
  set partLocked(String? partLocked) => _$this._partLocked = partLocked;

  String? _partMaxOrder;
  String? get partMaxOrder => _$this._partMaxOrder;
  set partMaxOrder(String? partMaxOrder) => _$this._partMaxOrder = partMaxOrder;

  String? _partMinOrder;
  String? get partMinOrder => _$this._partMinOrder;
  set partMinOrder(String? partMinOrder) => _$this._partMinOrder = partMinOrder;

  String? _partRemark;
  String? get partRemark => _$this._partRemark;
  set partRemark(String? partRemark) => _$this._partRemark = partRemark;

  MaterialStorePartBuilder();

  MaterialStorePartBuilder get _$this {
    final $v = _$v;
    if ($v != null) {
      _itemDescription = $v.itemDescription;
      _partAvailable = $v.partAvailable;
      _partCount = $v.partCount;
      _partId = $v.partId;
      _partLocked = $v.partLocked;
      _partMaxOrder = $v.partMaxOrder;
      _partMinOrder = $v.partMinOrder;
      _partRemark = $v.partRemark;
      _$v = null;
    }
    return this;
  }

  @override
  void replace(MaterialStorePart other) {
    _$v = other as _$MaterialStorePart;
  }

  @override
  void update(void Function(MaterialStorePartBuilder)? updates) {
    if (updates != null) updates(this);
  }

  @override
  MaterialStorePart build() => _build();

  _$MaterialStorePart _build() {
    final _$result = _$v ??
        _$MaterialStorePart._(
          itemDescription: itemDescription,
          partAvailable: partAvailable,
          partCount: partCount,
          partId: partId,
          partLocked: partLocked,
          partMaxOrder: partMaxOrder,
          partMinOrder: partMinOrder,
          partRemark: partRemark,
        );
    replace(_$result);
    return _$result;
  }
}

class _$ComplaintDImage extends ComplaintDImage {
  @override
  final String? file;
  @override
  final String? title;
  @override
  final String? width;
  @override
  final String? height;

  factory _$ComplaintDImage([void Function(ComplaintDImageBuilder)? updates]) =>
      (ComplaintDImageBuilder()..update(updates))._build();

  _$ComplaintDImage._({this.file, this.title, this.width, this.height})
      : super._();
  @override
  ComplaintDImage rebuild(void Function(ComplaintDImageBuilder) updates) =>
      (toBuilder()..update(updates)).build();

  @override
  ComplaintDImageBuilder toBuilder() => ComplaintDImageBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is ComplaintDImage &&
        file == other.file &&
        title == other.title &&
        width == other.width &&
        height == other.height;
  }

  @override
  int get hashCode {
    var _$hash = 0;
    _$hash = $jc(_$hash, file.hashCode);
    _$hash = $jc(_$hash, title.hashCode);
    _$hash = $jc(_$hash, width.hashCode);
    _$hash = $jc(_$hash, height.hashCode);
    _$hash = $jf(_$hash);
    return _$hash;
  }

  @override
  String toString() {
    return (newBuiltValueToStringHelper(r'ComplaintDImage')
          ..add('file', file)
          ..add('title', title)
          ..add('width', width)
          ..add('height', height))
        .toString();
  }
}

class ComplaintDImageBuilder
    implements Builder<ComplaintDImage, ComplaintDImageBuilder> {
  _$ComplaintDImage? _$v;

  String? _file;
  String? get file => _$this._file;
  set file(String? file) => _$this._file = file;

  String? _title;
  String? get title => _$this._title;
  set title(String? title) => _$this._title = title;

  String? _width;
  String? get width => _$this._width;
  set width(String? width) => _$this._width = width;

  String? _height;
  String? get height => _$this._height;
  set height(String? height) => _$this._height = height;

  ComplaintDImageBuilder();

  ComplaintDImageBuilder get _$this {
    final $v = _$v;
    if ($v != null) {
      _file = $v.file;
      _title = $v.title;
      _width = $v.width;
      _height = $v.height;
      _$v = null;
    }
    return this;
  }

  @override
  void replace(ComplaintDImage other) {
    _$v = other as _$ComplaintDImage;
  }

  @override
  void update(void Function(ComplaintDImageBuilder)? updates) {
    if (updates != null) updates(this);
  }

  @override
  ComplaintDImage build() => _build();

  _$ComplaintDImage _build() {
    final _$result = _$v ??
        _$ComplaintDImage._(
          file: file,
          title: title,
          width: width,
          height: height,
        );
    replace(_$result);
    return _$result;
  }
}

class _$RequestTask extends RequestTask {
  @override
  final String? requestBy;
  @override
  final String? requestTime;
  @override
  final String? statusDesc;
  @override
  final String? statusId;
  @override
  final String? checkpointId;
  @override
  final String? checkpointDesc;
  @override
  final String? taskFrom;
  @override
  final String? taskReceivedTime;
  @override
  final String? woSeverityDesc;
  @override
  final String? woTaskNo;
  @override
  final String? woTaskRequestId;
  @override
  final String? woTaskRequestNo;
  @override
  final String? woTypeDesc;
  @override
  final String? collectTime;
  @override
  final String? siteName;
  @override
  final String? woTaskId;

  factory _$RequestTask([void Function(RequestTaskBuilder)? updates]) =>
      (RequestTaskBuilder()..update(updates))._build();

  _$RequestTask._(
      {this.requestBy,
      this.requestTime,
      this.statusDesc,
      this.statusId,
      this.checkpointId,
      this.checkpointDesc,
      this.taskFrom,
      this.taskReceivedTime,
      this.woSeverityDesc,
      this.woTaskNo,
      this.woTaskRequestId,
      this.woTaskRequestNo,
      this.woTypeDesc,
      this.collectTime,
      this.siteName,
      this.woTaskId})
      : super._();
  @override
  RequestTask rebuild(void Function(RequestTaskBuilder) updates) =>
      (toBuilder()..update(updates)).build();

  @override
  RequestTaskBuilder toBuilder() => RequestTaskBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is RequestTask &&
        requestBy == other.requestBy &&
        requestTime == other.requestTime &&
        statusDesc == other.statusDesc &&
        statusId == other.statusId &&
        checkpointId == other.checkpointId &&
        checkpointDesc == other.checkpointDesc &&
        taskFrom == other.taskFrom &&
        taskReceivedTime == other.taskReceivedTime &&
        woSeverityDesc == other.woSeverityDesc &&
        woTaskNo == other.woTaskNo &&
        woTaskRequestId == other.woTaskRequestId &&
        woTaskRequestNo == other.woTaskRequestNo &&
        woTypeDesc == other.woTypeDesc &&
        collectTime == other.collectTime &&
        siteName == other.siteName &&
        woTaskId == other.woTaskId;
  }

  @override
  int get hashCode {
    var _$hash = 0;
    _$hash = $jc(_$hash, requestBy.hashCode);
    _$hash = $jc(_$hash, requestTime.hashCode);
    _$hash = $jc(_$hash, statusDesc.hashCode);
    _$hash = $jc(_$hash, statusId.hashCode);
    _$hash = $jc(_$hash, checkpointId.hashCode);
    _$hash = $jc(_$hash, checkpointDesc.hashCode);
    _$hash = $jc(_$hash, taskFrom.hashCode);
    _$hash = $jc(_$hash, taskReceivedTime.hashCode);
    _$hash = $jc(_$hash, woSeverityDesc.hashCode);
    _$hash = $jc(_$hash, woTaskNo.hashCode);
    _$hash = $jc(_$hash, woTaskRequestId.hashCode);
    _$hash = $jc(_$hash, woTaskRequestNo.hashCode);
    _$hash = $jc(_$hash, woTypeDesc.hashCode);
    _$hash = $jc(_$hash, collectTime.hashCode);
    _$hash = $jc(_$hash, siteName.hashCode);
    _$hash = $jc(_$hash, woTaskId.hashCode);
    _$hash = $jf(_$hash);
    return _$hash;
  }

  @override
  String toString() {
    return (newBuiltValueToStringHelper(r'RequestTask')
          ..add('requestBy', requestBy)
          ..add('requestTime', requestTime)
          ..add('statusDesc', statusDesc)
          ..add('statusId', statusId)
          ..add('checkpointId', checkpointId)
          ..add('checkpointDesc', checkpointDesc)
          ..add('taskFrom', taskFrom)
          ..add('taskReceivedTime', taskReceivedTime)
          ..add('woSeverityDesc', woSeverityDesc)
          ..add('woTaskNo', woTaskNo)
          ..add('woTaskRequestId', woTaskRequestId)
          ..add('woTaskRequestNo', woTaskRequestNo)
          ..add('woTypeDesc', woTypeDesc)
          ..add('collectTime', collectTime)
          ..add('siteName', siteName)
          ..add('woTaskId', woTaskId))
        .toString();
  }
}

class RequestTaskBuilder implements Builder<RequestTask, RequestTaskBuilder> {
  _$RequestTask? _$v;

  String? _requestBy;
  String? get requestBy => _$this._requestBy;
  set requestBy(String? requestBy) => _$this._requestBy = requestBy;

  String? _requestTime;
  String? get requestTime => _$this._requestTime;
  set requestTime(String? requestTime) => _$this._requestTime = requestTime;

  String? _statusDesc;
  String? get statusDesc => _$this._statusDesc;
  set statusDesc(String? statusDesc) => _$this._statusDesc = statusDesc;

  String? _statusId;
  String? get statusId => _$this._statusId;
  set statusId(String? statusId) => _$this._statusId = statusId;

  String? _checkpointId;
  String? get checkpointId => _$this._checkpointId;
  set checkpointId(String? checkpointId) => _$this._checkpointId = checkpointId;

  String? _checkpointDesc;
  String? get checkpointDesc => _$this._checkpointDesc;
  set checkpointDesc(String? checkpointDesc) =>
      _$this._checkpointDesc = checkpointDesc;

  String? _taskFrom;
  String? get taskFrom => _$this._taskFrom;
  set taskFrom(String? taskFrom) => _$this._taskFrom = taskFrom;

  String? _taskReceivedTime;
  String? get taskReceivedTime => _$this._taskReceivedTime;
  set taskReceivedTime(String? taskReceivedTime) =>
      _$this._taskReceivedTime = taskReceivedTime;

  String? _woSeverityDesc;
  String? get woSeverityDesc => _$this._woSeverityDesc;
  set woSeverityDesc(String? woSeverityDesc) =>
      _$this._woSeverityDesc = woSeverityDesc;

  String? _woTaskNo;
  String? get woTaskNo => _$this._woTaskNo;
  set woTaskNo(String? woTaskNo) => _$this._woTaskNo = woTaskNo;

  String? _woTaskRequestId;
  String? get woTaskRequestId => _$this._woTaskRequestId;
  set woTaskRequestId(String? woTaskRequestId) =>
      _$this._woTaskRequestId = woTaskRequestId;

  String? _woTaskRequestNo;
  String? get woTaskRequestNo => _$this._woTaskRequestNo;
  set woTaskRequestNo(String? woTaskRequestNo) =>
      _$this._woTaskRequestNo = woTaskRequestNo;

  String? _woTypeDesc;
  String? get woTypeDesc => _$this._woTypeDesc;
  set woTypeDesc(String? woTypeDesc) => _$this._woTypeDesc = woTypeDesc;

  String? _collectTime;
  String? get collectTime => _$this._collectTime;
  set collectTime(String? collectTime) => _$this._collectTime = collectTime;

  String? _siteName;
  String? get siteName => _$this._siteName;
  set siteName(String? siteName) => _$this._siteName = siteName;

  String? _woTaskId;
  String? get woTaskId => _$this._woTaskId;
  set woTaskId(String? woTaskId) => _$this._woTaskId = woTaskId;

  RequestTaskBuilder();

  RequestTaskBuilder get _$this {
    final $v = _$v;
    if ($v != null) {
      _requestBy = $v.requestBy;
      _requestTime = $v.requestTime;
      _statusDesc = $v.statusDesc;
      _statusId = $v.statusId;
      _checkpointId = $v.checkpointId;
      _checkpointDesc = $v.checkpointDesc;
      _taskFrom = $v.taskFrom;
      _taskReceivedTime = $v.taskReceivedTime;
      _woSeverityDesc = $v.woSeverityDesc;
      _woTaskNo = $v.woTaskNo;
      _woTaskRequestId = $v.woTaskRequestId;
      _woTaskRequestNo = $v.woTaskRequestNo;
      _woTypeDesc = $v.woTypeDesc;
      _collectTime = $v.collectTime;
      _siteName = $v.siteName;
      _woTaskId = $v.woTaskId;
      _$v = null;
    }
    return this;
  }

  @override
  void replace(RequestTask other) {
    _$v = other as _$RequestTask;
  }

  @override
  void update(void Function(RequestTaskBuilder)? updates) {
    if (updates != null) updates(this);
  }

  @override
  RequestTask build() => _build();

  _$RequestTask _build() {
    final _$result = _$v ??
        _$RequestTask._(
          requestBy: requestBy,
          requestTime: requestTime,
          statusDesc: statusDesc,
          statusId: statusId,
          checkpointId: checkpointId,
          checkpointDesc: checkpointDesc,
          taskFrom: taskFrom,
          taskReceivedTime: taskReceivedTime,
          woSeverityDesc: woSeverityDesc,
          woTaskNo: woTaskNo,
          woTaskRequestId: woTaskRequestId,
          woTaskRequestNo: woTaskRequestNo,
          woTypeDesc: woTypeDesc,
          collectTime: collectTime,
          siteName: siteName,
          woTaskId: woTaskId,
        );
    replace(_$result);
    return _$result;
  }
}

class _$ComplaintMaterial extends ComplaintMaterial {
  @override
  final String? assetGroupId;
  @override
  final String? assetGroupName;
  @override
  final String? itemDescription;
  @override
  final String? itemId;
  @override
  final String? itemTypeDesc;
  @override
  final String? itemTypeId;
  @override
  final String? partAvailable;
  @override
  final String? partCount;
  @override
  final String? partId;
  @override
  final String? partLocked;
  @override
  final String? partMaxOrder;
  @override
  final String? partMinOrder;
  @override
  final String? partRemark;
  @override
  final String? partThreshold;
  @override
  final BuiltList<ComplaintMaterialGrouped>? itemGrouped;
  @override
  final BuiltList<ComplaintMaterialImage>? images;

  factory _$ComplaintMaterial(
          [void Function(ComplaintMaterialBuilder)? updates]) =>
      (ComplaintMaterialBuilder()..update(updates))._build();

  _$ComplaintMaterial._(
      {this.assetGroupId,
      this.assetGroupName,
      this.itemDescription,
      this.itemId,
      this.itemTypeDesc,
      this.itemTypeId,
      this.partAvailable,
      this.partCount,
      this.partId,
      this.partLocked,
      this.partMaxOrder,
      this.partMinOrder,
      this.partRemark,
      this.partThreshold,
      this.itemGrouped,
      this.images})
      : super._();
  @override
  ComplaintMaterial rebuild(void Function(ComplaintMaterialBuilder) updates) =>
      (toBuilder()..update(updates)).build();

  @override
  ComplaintMaterialBuilder toBuilder() =>
      ComplaintMaterialBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is ComplaintMaterial &&
        assetGroupId == other.assetGroupId &&
        assetGroupName == other.assetGroupName &&
        itemDescription == other.itemDescription &&
        itemId == other.itemId &&
        itemTypeDesc == other.itemTypeDesc &&
        itemTypeId == other.itemTypeId &&
        partAvailable == other.partAvailable &&
        partCount == other.partCount &&
        partId == other.partId &&
        partLocked == other.partLocked &&
        partMaxOrder == other.partMaxOrder &&
        partMinOrder == other.partMinOrder &&
        partRemark == other.partRemark &&
        partThreshold == other.partThreshold &&
        itemGrouped == other.itemGrouped &&
        images == other.images;
  }

  @override
  int get hashCode {
    var _$hash = 0;
    _$hash = $jc(_$hash, assetGroupId.hashCode);
    _$hash = $jc(_$hash, assetGroupName.hashCode);
    _$hash = $jc(_$hash, itemDescription.hashCode);
    _$hash = $jc(_$hash, itemId.hashCode);
    _$hash = $jc(_$hash, itemTypeDesc.hashCode);
    _$hash = $jc(_$hash, itemTypeId.hashCode);
    _$hash = $jc(_$hash, partAvailable.hashCode);
    _$hash = $jc(_$hash, partCount.hashCode);
    _$hash = $jc(_$hash, partId.hashCode);
    _$hash = $jc(_$hash, partLocked.hashCode);
    _$hash = $jc(_$hash, partMaxOrder.hashCode);
    _$hash = $jc(_$hash, partMinOrder.hashCode);
    _$hash = $jc(_$hash, partRemark.hashCode);
    _$hash = $jc(_$hash, partThreshold.hashCode);
    _$hash = $jc(_$hash, itemGrouped.hashCode);
    _$hash = $jc(_$hash, images.hashCode);
    _$hash = $jf(_$hash);
    return _$hash;
  }

  @override
  String toString() {
    return (newBuiltValueToStringHelper(r'ComplaintMaterial')
          ..add('assetGroupId', assetGroupId)
          ..add('assetGroupName', assetGroupName)
          ..add('itemDescription', itemDescription)
          ..add('itemId', itemId)
          ..add('itemTypeDesc', itemTypeDesc)
          ..add('itemTypeId', itemTypeId)
          ..add('partAvailable', partAvailable)
          ..add('partCount', partCount)
          ..add('partId', partId)
          ..add('partLocked', partLocked)
          ..add('partMaxOrder', partMaxOrder)
          ..add('partMinOrder', partMinOrder)
          ..add('partRemark', partRemark)
          ..add('partThreshold', partThreshold)
          ..add('itemGrouped', itemGrouped)
          ..add('images', images))
        .toString();
  }
}

class ComplaintMaterialBuilder
    implements Builder<ComplaintMaterial, ComplaintMaterialBuilder> {
  _$ComplaintMaterial? _$v;

  String? _assetGroupId;
  String? get assetGroupId => _$this._assetGroupId;
  set assetGroupId(String? assetGroupId) => _$this._assetGroupId = assetGroupId;

  String? _assetGroupName;
  String? get assetGroupName => _$this._assetGroupName;
  set assetGroupName(String? assetGroupName) =>
      _$this._assetGroupName = assetGroupName;

  String? _itemDescription;
  String? get itemDescription => _$this._itemDescription;
  set itemDescription(String? itemDescription) =>
      _$this._itemDescription = itemDescription;

  String? _itemId;
  String? get itemId => _$this._itemId;
  set itemId(String? itemId) => _$this._itemId = itemId;

  String? _itemTypeDesc;
  String? get itemTypeDesc => _$this._itemTypeDesc;
  set itemTypeDesc(String? itemTypeDesc) => _$this._itemTypeDesc = itemTypeDesc;

  String? _itemTypeId;
  String? get itemTypeId => _$this._itemTypeId;
  set itemTypeId(String? itemTypeId) => _$this._itemTypeId = itemTypeId;

  String? _partAvailable;
  String? get partAvailable => _$this._partAvailable;
  set partAvailable(String? partAvailable) =>
      _$this._partAvailable = partAvailable;

  String? _partCount;
  String? get partCount => _$this._partCount;
  set partCount(String? partCount) => _$this._partCount = partCount;

  String? _partId;
  String? get partId => _$this._partId;
  set partId(String? partId) => _$this._partId = partId;

  String? _partLocked;
  String? get partLocked => _$this._partLocked;
  set partLocked(String? partLocked) => _$this._partLocked = partLocked;

  String? _partMaxOrder;
  String? get partMaxOrder => _$this._partMaxOrder;
  set partMaxOrder(String? partMaxOrder) => _$this._partMaxOrder = partMaxOrder;

  String? _partMinOrder;
  String? get partMinOrder => _$this._partMinOrder;
  set partMinOrder(String? partMinOrder) => _$this._partMinOrder = partMinOrder;

  String? _partRemark;
  String? get partRemark => _$this._partRemark;
  set partRemark(String? partRemark) => _$this._partRemark = partRemark;

  String? _partThreshold;
  String? get partThreshold => _$this._partThreshold;
  set partThreshold(String? partThreshold) =>
      _$this._partThreshold = partThreshold;

  ListBuilder<ComplaintMaterialGrouped>? _itemGrouped;
  ListBuilder<ComplaintMaterialGrouped> get itemGrouped =>
      _$this._itemGrouped ??= ListBuilder<ComplaintMaterialGrouped>();
  set itemGrouped(ListBuilder<ComplaintMaterialGrouped>? itemGrouped) =>
      _$this._itemGrouped = itemGrouped;

  ListBuilder<ComplaintMaterialImage>? _images;
  ListBuilder<ComplaintMaterialImage> get images =>
      _$this._images ??= ListBuilder<ComplaintMaterialImage>();
  set images(ListBuilder<ComplaintMaterialImage>? images) =>
      _$this._images = images;

  ComplaintMaterialBuilder();

  ComplaintMaterialBuilder get _$this {
    final $v = _$v;
    if ($v != null) {
      _assetGroupId = $v.assetGroupId;
      _assetGroupName = $v.assetGroupName;
      _itemDescription = $v.itemDescription;
      _itemId = $v.itemId;
      _itemTypeDesc = $v.itemTypeDesc;
      _itemTypeId = $v.itemTypeId;
      _partAvailable = $v.partAvailable;
      _partCount = $v.partCount;
      _partId = $v.partId;
      _partLocked = $v.partLocked;
      _partMaxOrder = $v.partMaxOrder;
      _partMinOrder = $v.partMinOrder;
      _partRemark = $v.partRemark;
      _partThreshold = $v.partThreshold;
      _itemGrouped = $v.itemGrouped?.toBuilder();
      _images = $v.images?.toBuilder();
      _$v = null;
    }
    return this;
  }

  @override
  void replace(ComplaintMaterial other) {
    _$v = other as _$ComplaintMaterial;
  }

  @override
  void update(void Function(ComplaintMaterialBuilder)? updates) {
    if (updates != null) updates(this);
  }

  @override
  ComplaintMaterial build() => _build();

  _$ComplaintMaterial _build() {
    _$ComplaintMaterial _$result;
    try {
      _$result = _$v ??
          _$ComplaintMaterial._(
            assetGroupId: assetGroupId,
            assetGroupName: assetGroupName,
            itemDescription: itemDescription,
            itemId: itemId,
            itemTypeDesc: itemTypeDesc,
            itemTypeId: itemTypeId,
            partAvailable: partAvailable,
            partCount: partCount,
            partId: partId,
            partLocked: partLocked,
            partMaxOrder: partMaxOrder,
            partMinOrder: partMinOrder,
            partRemark: partRemark,
            partThreshold: partThreshold,
            itemGrouped: _itemGrouped?.build(),
            images: _images?.build(),
          );
    } catch (_) {
      late String _$failedField;
      try {
        _$failedField = 'itemGrouped';
        _itemGrouped?.build();
        _$failedField = 'images';
        _images?.build();
      } catch (e) {
        throw BuiltValueNestedFieldError(
            r'ComplaintMaterial', _$failedField, e.toString());
      }
      rethrow;
    }
    replace(_$result);
    return _$result;
  }
}

class _$ComplaintMaterialGrouped extends ComplaintMaterialGrouped {
  @override
  final String dateCheckIn;
  @override
  final String doNo;
  @override
  final String partSubCost;
  @override
  final String partSubLocation;
  @override
  final String partSubValidity;
  @override
  final String partSubWarranty;
  @override
  final String supplierName;
  @override
  final String total;

  factory _$ComplaintMaterialGrouped(
          [void Function(ComplaintMaterialGroupedBuilder)? updates]) =>
      (ComplaintMaterialGroupedBuilder()..update(updates))._build();

  _$ComplaintMaterialGrouped._(
      {required this.dateCheckIn,
      required this.doNo,
      required this.partSubCost,
      required this.partSubLocation,
      required this.partSubValidity,
      required this.partSubWarranty,
      required this.supplierName,
      required this.total})
      : super._();
  @override
  ComplaintMaterialGrouped rebuild(
          void Function(ComplaintMaterialGroupedBuilder) updates) =>
      (toBuilder()..update(updates)).build();

  @override
  ComplaintMaterialGroupedBuilder toBuilder() =>
      ComplaintMaterialGroupedBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is ComplaintMaterialGrouped &&
        dateCheckIn == other.dateCheckIn &&
        doNo == other.doNo &&
        partSubCost == other.partSubCost &&
        partSubLocation == other.partSubLocation &&
        partSubValidity == other.partSubValidity &&
        partSubWarranty == other.partSubWarranty &&
        supplierName == other.supplierName &&
        total == other.total;
  }

  @override
  int get hashCode {
    var _$hash = 0;
    _$hash = $jc(_$hash, dateCheckIn.hashCode);
    _$hash = $jc(_$hash, doNo.hashCode);
    _$hash = $jc(_$hash, partSubCost.hashCode);
    _$hash = $jc(_$hash, partSubLocation.hashCode);
    _$hash = $jc(_$hash, partSubValidity.hashCode);
    _$hash = $jc(_$hash, partSubWarranty.hashCode);
    _$hash = $jc(_$hash, supplierName.hashCode);
    _$hash = $jc(_$hash, total.hashCode);
    _$hash = $jf(_$hash);
    return _$hash;
  }

  @override
  String toString() {
    return (newBuiltValueToStringHelper(r'ComplaintMaterialGrouped')
          ..add('dateCheckIn', dateCheckIn)
          ..add('doNo', doNo)
          ..add('partSubCost', partSubCost)
          ..add('partSubLocation', partSubLocation)
          ..add('partSubValidity', partSubValidity)
          ..add('partSubWarranty', partSubWarranty)
          ..add('supplierName', supplierName)
          ..add('total', total))
        .toString();
  }
}

class ComplaintMaterialGroupedBuilder
    implements
        Builder<ComplaintMaterialGrouped, ComplaintMaterialGroupedBuilder> {
  _$ComplaintMaterialGrouped? _$v;

  String? _dateCheckIn;
  String? get dateCheckIn => _$this._dateCheckIn;
  set dateCheckIn(String? dateCheckIn) => _$this._dateCheckIn = dateCheckIn;

  String? _doNo;
  String? get doNo => _$this._doNo;
  set doNo(String? doNo) => _$this._doNo = doNo;

  String? _partSubCost;
  String? get partSubCost => _$this._partSubCost;
  set partSubCost(String? partSubCost) => _$this._partSubCost = partSubCost;

  String? _partSubLocation;
  String? get partSubLocation => _$this._partSubLocation;
  set partSubLocation(String? partSubLocation) =>
      _$this._partSubLocation = partSubLocation;

  String? _partSubValidity;
  String? get partSubValidity => _$this._partSubValidity;
  set partSubValidity(String? partSubValidity) =>
      _$this._partSubValidity = partSubValidity;

  String? _partSubWarranty;
  String? get partSubWarranty => _$this._partSubWarranty;
  set partSubWarranty(String? partSubWarranty) =>
      _$this._partSubWarranty = partSubWarranty;

  String? _supplierName;
  String? get supplierName => _$this._supplierName;
  set supplierName(String? supplierName) => _$this._supplierName = supplierName;

  String? _total;
  String? get total => _$this._total;
  set total(String? total) => _$this._total = total;

  ComplaintMaterialGroupedBuilder();

  ComplaintMaterialGroupedBuilder get _$this {
    final $v = _$v;
    if ($v != null) {
      _dateCheckIn = $v.dateCheckIn;
      _doNo = $v.doNo;
      _partSubCost = $v.partSubCost;
      _partSubLocation = $v.partSubLocation;
      _partSubValidity = $v.partSubValidity;
      _partSubWarranty = $v.partSubWarranty;
      _supplierName = $v.supplierName;
      _total = $v.total;
      _$v = null;
    }
    return this;
  }

  @override
  void replace(ComplaintMaterialGrouped other) {
    _$v = other as _$ComplaintMaterialGrouped;
  }

  @override
  void update(void Function(ComplaintMaterialGroupedBuilder)? updates) {
    if (updates != null) updates(this);
  }

  @override
  ComplaintMaterialGrouped build() => _build();

  _$ComplaintMaterialGrouped _build() {
    final _$result = _$v ??
        _$ComplaintMaterialGrouped._(
          dateCheckIn: BuiltValueNullFieldError.checkNotNull(
              dateCheckIn, r'ComplaintMaterialGrouped', 'dateCheckIn'),
          doNo: BuiltValueNullFieldError.checkNotNull(
              doNo, r'ComplaintMaterialGrouped', 'doNo'),
          partSubCost: BuiltValueNullFieldError.checkNotNull(
              partSubCost, r'ComplaintMaterialGrouped', 'partSubCost'),
          partSubLocation: BuiltValueNullFieldError.checkNotNull(
              partSubLocation, r'ComplaintMaterialGrouped', 'partSubLocation'),
          partSubValidity: BuiltValueNullFieldError.checkNotNull(
              partSubValidity, r'ComplaintMaterialGrouped', 'partSubValidity'),
          partSubWarranty: BuiltValueNullFieldError.checkNotNull(
              partSubWarranty, r'ComplaintMaterialGrouped', 'partSubWarranty'),
          supplierName: BuiltValueNullFieldError.checkNotNull(
              supplierName, r'ComplaintMaterialGrouped', 'supplierName'),
          total: BuiltValueNullFieldError.checkNotNull(
              total, r'ComplaintMaterialGrouped', 'total'),
        );
    replace(_$result);
    return _$result;
  }
}

class _$ComplaintMaterialImage extends ComplaintMaterialImage {
  @override
  final String? file;
  @override
  final String? height;
  @override
  final String? width;
  @override
  final String? title;

  factory _$ComplaintMaterialImage(
          [void Function(ComplaintMaterialImageBuilder)? updates]) =>
      (ComplaintMaterialImageBuilder()..update(updates))._build();

  _$ComplaintMaterialImage._({this.file, this.height, this.width, this.title})
      : super._();
  @override
  ComplaintMaterialImage rebuild(
          void Function(ComplaintMaterialImageBuilder) updates) =>
      (toBuilder()..update(updates)).build();

  @override
  ComplaintMaterialImageBuilder toBuilder() =>
      ComplaintMaterialImageBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is ComplaintMaterialImage &&
        file == other.file &&
        height == other.height &&
        width == other.width &&
        title == other.title;
  }

  @override
  int get hashCode {
    var _$hash = 0;
    _$hash = $jc(_$hash, file.hashCode);
    _$hash = $jc(_$hash, height.hashCode);
    _$hash = $jc(_$hash, width.hashCode);
    _$hash = $jc(_$hash, title.hashCode);
    _$hash = $jf(_$hash);
    return _$hash;
  }

  @override
  String toString() {
    return (newBuiltValueToStringHelper(r'ComplaintMaterialImage')
          ..add('file', file)
          ..add('height', height)
          ..add('width', width)
          ..add('title', title))
        .toString();
  }
}

class ComplaintMaterialImageBuilder
    implements Builder<ComplaintMaterialImage, ComplaintMaterialImageBuilder> {
  _$ComplaintMaterialImage? _$v;

  String? _file;
  String? get file => _$this._file;
  set file(String? file) => _$this._file = file;

  String? _height;
  String? get height => _$this._height;
  set height(String? height) => _$this._height = height;

  String? _width;
  String? get width => _$this._width;
  set width(String? width) => _$this._width = width;

  String? _title;
  String? get title => _$this._title;
  set title(String? title) => _$this._title = title;

  ComplaintMaterialImageBuilder();

  ComplaintMaterialImageBuilder get _$this {
    final $v = _$v;
    if ($v != null) {
      _file = $v.file;
      _height = $v.height;
      _width = $v.width;
      _title = $v.title;
      _$v = null;
    }
    return this;
  }

  @override
  void replace(ComplaintMaterialImage other) {
    _$v = other as _$ComplaintMaterialImage;
  }

  @override
  void update(void Function(ComplaintMaterialImageBuilder)? updates) {
    if (updates != null) updates(this);
  }

  @override
  ComplaintMaterialImage build() => _build();

  _$ComplaintMaterialImage _build() {
    final _$result = _$v ??
        _$ComplaintMaterialImage._(
          file: file,
          height: height,
          width: width,
          title: title,
        );
    replace(_$result);
    return _$result;
  }
}

// ignore_for_file: deprecated_member_use_from_same_package,type=lint
