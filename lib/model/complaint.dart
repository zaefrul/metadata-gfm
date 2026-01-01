import 'package:built_collection/built_collection.dart';
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';
import 'serializers.dart';

part 'complaint.g.dart';

abstract class ComplaintD implements Built<ComplaintD, ComplaintDBuilder> {
  String? get woTaskPartsId;
  String? get woTaskRequestId;
  String? get partId;
  String? get woTaskPartsQuantity;
  String? get woTaskPartsRemark;
  String? get woTaskPartsStatus;
  String? get itemDescription;
  String? get itemTypeDesc;
  String? get assetGroupName;
  String? get statusDesc;
  BuiltList<ComplaintDImage>? get images;

  ComplaintD._();
  factory ComplaintD([void Function(ComplaintDBuilder) updates]) = _$ComplaintD;

  static ComplaintD? fromJson(Map<String, dynamic> json) {
    return serializers.deserializeWith(ComplaintD.serializer, json);
  }

  static Serializer<ComplaintD> get serializer => _$complaintDSerializer;
}

abstract class ComplaintDStore
    implements Built<ComplaintDStore, ComplaintDStoreBuilder> {
  @BuiltValueField(wireName: 'storeId')
  String? get itemId;

  @BuiltValueField(wireName: 'storeName')
  String? get itemName;

  ComplaintDStore._();
  factory ComplaintDStore([void Function(ComplaintDStoreBuilder) updates]) =
      _$ComplaintDStore;

  Map<String, dynamic> toJson() {
    return serializers.serializeWith(ComplaintDStore.serializer, this)
        as Map<String, dynamic>;
  }

  static Serializer<ComplaintDStore> get serializer =>
      _$complaintDStoreSerializer;
}

abstract class ComplaintDGroupStore
    implements Built<ComplaintDGroupStore, ComplaintDGroupStoreBuilder> {
  @BuiltValueField(wireName: 'assetGroupId')
  String? get itemId;

  @BuiltValueField(wireName: 'assetGroupName')
  String? get itemName;

  BuiltList<ComplaintDType>? get itemTypes;

  ComplaintDGroupStore._();
  factory ComplaintDGroupStore(
          [void Function(ComplaintDGroupStoreBuilder) updates]) =
      _$ComplaintDGroupStore;

  static Serializer<ComplaintDGroupStore> get serializer =>
      _$complaintDGroupStoreSerializer;
}

abstract class ComplaintDGroup
    implements Built<ComplaintDGroup, ComplaintDGroupBuilder> {
  @BuiltValueField(wireName: 'asset_group_id')
  String? get itemId;
  @BuiltValueField(wireName: 'asset_group_name')
  String? get itemName;
  @BuiltValueField(wireName: 'assetGroupDesc')
  String? get itemDesc;
  @BuiltValueField(wireName: 'assetGroupStatus')
  String? get itemStatus;

  ComplaintDGroup._();
  factory ComplaintDGroup([void Function(ComplaintDGroupBuilder) updates]) =
      _$ComplaintDGroup;

  static Serializer<ComplaintDGroup> get serializer =>
      _$complaintDGroupSerializer;
}

abstract class ComplaintDType
    implements Built<ComplaintDType, ComplaintDTypeBuilder> {
  @BuiltValueField(wireName: 'item_type_id')
  String? get itemId;
  @BuiltValueField(wireName: 'assetGroupId')
  String? get itemGroupId;
  @BuiltValueField(wireName: 'item_type_desc')
  String? get itemName;
  String? get itemTypeDesc;
  @BuiltValueField(wireName: 'itemTypeStatus')
  String? get itemStatus;

  BuiltList<ComplaintMaterial>? get parts;

  ComplaintDType._();
  factory ComplaintDType([void Function(ComplaintDTypeBuilder) updates]) =
      _$ComplaintDType;

  static Serializer<ComplaintDType> get serializer =>
      _$complaintDTypeSerializer;
}

abstract class ComplaintDStoreType
    implements Built<ComplaintDStoreType, ComplaintDStoreTypeBuilder> {
  @BuiltValueField(wireName: 'itemTypeId')
  String? get itemId;
  @BuiltValueField(wireName: 'itemTypeDesc')
  String? get itemName;

  BuiltList<ComplaintMaterial>? get parts;

  ComplaintDStoreType._();
  factory ComplaintDStoreType(
          [void Function(ComplaintDStoreTypeBuilder) updates]) =
      _$ComplaintDStoreType;

  static Serializer<ComplaintDStoreType> get serializer =>
      _$complaintDStoreTypeSerializer;
}

abstract class ComplaintDPart
    implements Built<ComplaintDPart, ComplaintDPartBuilder> {
  @BuiltValueField(wireName: 'item_id')
  String? get itemId;
  @BuiltValueField(wireName: 'item_description')
  String? get itemName;
  @BuiltValueField(wireName: 'partCounts')
  String? get itemQuantity;
  @BuiltValueField(wireName: 'itemTypeDesc')
  String? get itemTypeDesc;
  String? get partLocked;
  String? get partMaxOrder;
  String? get partMinOrder;
  String? get partRemark;

  ComplaintDPart._();
  factory ComplaintDPart([void Function(ComplaintDPartBuilder) updates]) =
      _$ComplaintDPart;

  static Serializer<ComplaintDPart> get serializer =>
      _$complaintDPartSerializer;
}

abstract class MaterialStorePart
    implements Built<MaterialStorePart, MaterialStorePartBuilder> {
  MaterialStorePart._();
  factory MaterialStorePart([void Function(MaterialStorePartBuilder) updates]) =
      _$MaterialStorePart;

  String? get itemDescription;
  String? get partAvailable;
  String? get partCount;
  String? get partId;
  String? get partLocked;
  String? get partMaxOrder;
  String? get partMinOrder;
  String? get partRemark;

  Map<String, dynamic> toJson() {
    return serializers.serializeWith(MaterialStorePart.serializer, this)
        as Map<String, dynamic>;
  }

  static MaterialStorePart fromJson(Map<String, dynamic> json) {
    return serializers.deserializeWith(MaterialStorePart.serializer, json)!;
  }

  static Serializer<MaterialStorePart> get serializer =>
      _$materialStorePartSerializer;
}

abstract class ComplaintDImage
    implements Built<ComplaintDImage, ComplaintDImageBuilder> {
  String? get file;
  String? get title;
  String? get width;
  String? get height;

  ComplaintDImage._();
  factory ComplaintDImage([void Function(ComplaintDImageBuilder) updates]) =
      _$ComplaintDImage;

  Map<String, dynamic> toJson() {
    return serializers.serializeWith(ComplaintDImage.serializer, this)
        as Map<String, dynamic>;
  }

  static ComplaintDImage fromJson(Map<String, dynamic> json) {
    return serializers.deserializeWith(ComplaintDImage.serializer, json)!;
  }

  static Serializer<ComplaintDImage> get serializer =>
      _$complaintDImageSerializer;
}

abstract class RequestTask implements Built<RequestTask, RequestTaskBuilder> {
  String? get requestBy;
  String? get requestTime;
  String? get statusDesc;
  String? get statusId;
  String? get checkpointId;
  String? get checkpointDesc;
  String? get taskFrom;
  String? get taskReceivedTime;
  String? get woSeverityDesc;
  String? get woTaskNo;
  String? get woTaskRequestId;
  String? get woTaskRequestNo;
  String? get woTypeDesc;
  String? get collectTime;
  String? get siteName;
  String? get woTaskId;

  RequestTask._();
  factory RequestTask([void Function(RequestTaskBuilder) updates]) =
      _$RequestTask;

  Map<String, dynamic> toJson() {
    return serializers.serializeWith(RequestTask.serializer, this)
        as Map<String, dynamic>;
  }

  static RequestTask fromJson(Map<String, dynamic> json) {
    final normalized = Map<String, dynamic>.from(json);

    void ensureField(String target, List<String> fallbacks) {
      if (normalized[target] != null) return;
      for (final fb in fallbacks) {
        final value = normalized[fb] ?? json[fb];
        if (value != null) {
          normalized[target] = value;
          return;
        }
      }
    }

    ensureField('woTaskId', const ['wo_task_id', 'woTaskID']);
    ensureField('woTaskRequestId', const ['wo_task_request_id']);
    ensureField('woTaskRequestNo', const ['wo_task_request_no']);
    ensureField('woTaskNo', const ['wo_task_no']);
    ensureField('woSeverityDesc', const ['wo_severity_desc']);
    ensureField('collectTime', const ['collect_time']);
    ensureField('siteName', const ['site_name']);
    ensureField('checkpointId', const ['checkpoint_id']);
    ensureField('checkpointDesc', const ['checkpoint_desc']);

    return serializers.deserializeWith(RequestTask.serializer, normalized)!;
  }

  static Serializer<RequestTask> get serializer => _$requestTaskSerializer;
}

abstract class ComplaintMaterial
    implements Built<ComplaintMaterial, ComplaintMaterialBuilder> {
  String? get assetGroupId;
  String? get assetGroupName;
  String? get itemDescription;
  String? get itemId;
  String? get itemTypeDesc;
  String? get itemTypeId;
  String? get partAvailable;
  String? get partCount;
  String? get partId;
  String? get partLocked;
  String? get partMaxOrder;
  String? get partMinOrder;
  String? get partRemark;
  String? get partThreshold;
  BuiltList<ComplaintMaterialGrouped>? get itemGrouped;
  BuiltList<ComplaintMaterialImage>? get images;

  ComplaintMaterial._();
  factory ComplaintMaterial([void Function(ComplaintMaterialBuilder) updates]) =
      _$ComplaintMaterial;

  static ComplaintMaterial fromJson(Map<String, dynamic> json) {
    return serializers.deserializeWith(ComplaintMaterial.serializer, json)!;
  }

  static Serializer<ComplaintMaterial> get serializer =>
      _$complaintMaterialSerializer;
}

abstract class ComplaintMaterialGrouped
    implements
        Built<ComplaintMaterialGrouped, ComplaintMaterialGroupedBuilder> {
  String get dateCheckIn;
  String get doNo;
  String get partSubCost;
  String get partSubLocation;
  String get partSubValidity;
  String get partSubWarranty;
  String get supplierName;
  String get total;

  ComplaintMaterialGrouped._();
  factory ComplaintMaterialGrouped(
          [void Function(ComplaintMaterialGroupedBuilder) updates]) =
      _$ComplaintMaterialGrouped;

  static ComplaintMaterialGrouped fromJson(Map<String, dynamic> json) {
    return serializers.deserializeWith(
        ComplaintMaterialGrouped.serializer, json)!;
  }

  static Serializer<ComplaintMaterialGrouped> get serializer =>
      _$complaintMaterialGroupedSerializer;
}

abstract class ComplaintMaterialImage
    implements Built<ComplaintMaterialImage, ComplaintMaterialImageBuilder> {
  String? get file;
  String? get height;
  String? get width;
  String? get title;

  ComplaintMaterialImage._();
  factory ComplaintMaterialImage(
          [void Function(ComplaintMaterialImageBuilder) updates]) =
      _$ComplaintMaterialImage;

  Map<String, dynamic> toJson() {
    return serializers.serializeWith(ComplaintMaterialImage.serializer, this)
        as Map<String, dynamic>;
  }

  static ComplaintMaterialImage fromJson(Map<String, dynamic> json) {
    return serializers.deserializeWith(
        ComplaintMaterialImage.serializer, json)!;
  }

  static Serializer<ComplaintMaterialImage> get serializer =>
      _$complaintMaterialImageSerializer;
}
