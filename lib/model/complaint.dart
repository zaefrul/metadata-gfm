import 'package:built_collection/built_collection.dart';
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';
import 'serializers.dart';

part 'complaint.g.dart';

abstract class ComplaintD implements Built<ComplaintD, ComplaintDBuilder> {
  @nullable
  String get woTaskPartsId;
  @nullable
  String get woTaskRequestId;
  @nullable
  String get partId;
  @nullable
  String get woTaskPartsQuantity;
  @nullable
  String get woTaskPartsRemark;
  @nullable
  String get woTaskPartsStatus;
  @nullable
  String get itemDescription;
  @nullable
  String get itemTypeDesc;
  @nullable
  String get assetGroupName;
  @nullable
  String get statusDesc;
  @nullable
  BuiltList<ComplaintDImage> get images;

  ComplaintD._();
  factory ComplaintD([void Function(ComplaintDBuilder) updates]) = _$ComplaintD;

  static ComplaintD fromJson(Map<String, dynamic> json) {
    return serializers.deserializeWith(ComplaintD.serializer, json);
  }

  static Serializer<ComplaintD> get serializer => _$complaintDSerializer;
}

abstract class ComplaintDStore
    implements Built<ComplaintDStore, ComplaintDStoreBuilder> {
  @BuiltValueField(wireName: 'storeId')
  @nullable
  String get itemId;

  @BuiltValueField(wireName: 'storeName')
  @nullable
  String get itemName;

  ComplaintDStore._();
  factory ComplaintDStore([void Function(ComplaintDStoreBuilder) updates]) =
      _$ComplaintDStore;

  Map<String, dynamic> toJson() {
    return serializers.serializeWith(ComplaintDStore.serializer, this);
  }

  static Serializer<ComplaintDStore> get serializer =>
      _$complaintDStoreSerializer;
}

abstract class ComplaintDGroupStore
    implements Built<ComplaintDGroupStore, ComplaintDGroupStoreBuilder> {
  @BuiltValueField(wireName: 'assetGroupId')
  @nullable
  String get itemId;

  @BuiltValueField(wireName: 'assetGroupName')
  @nullable
  String get itemName;

  @nullable
  BuiltList<ComplaintDType> get itemTypes;

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
  @nullable
  String get itemId;
  @BuiltValueField(wireName: 'asset_group_name')
  @nullable
  String get itemName;
  @BuiltValueField(wireName: 'assetGroupDesc')
  @nullable
  String get itemDesc;
  @BuiltValueField(wireName: 'assetGroupStatus')
  @nullable
  String get itemStatus;

  ComplaintDGroup._();
  factory ComplaintDGroup([void Function(ComplaintDGroupBuilder) updates]) =
      _$ComplaintDGroup;

  static Serializer<ComplaintDGroup> get serializer =>
      _$complaintDGroupSerializer;
}

abstract class ComplaintDType
    implements Built<ComplaintDType, ComplaintDTypeBuilder> {
  @BuiltValueField(wireName: 'item_type_id')
  @nullable
  String get itemId;
  @BuiltValueField(wireName: 'assetGroupId')
  @nullable
  String get itemGroupId;
  @BuiltValueField(wireName: 'item_type_desc')
  @nullable
  String get itemName;
  @nullable
  String get itemTypeDesc;
  @BuiltValueField(wireName: 'itemTypeStatus')
  @nullable
  String get itemStatus;

  @nullable
  BuiltList<ComplaintMaterial> get parts;

  ComplaintDType._();
  factory ComplaintDType([void Function(ComplaintDTypeBuilder) updates]) =
      _$ComplaintDType;

  static Serializer<ComplaintDType> get serializer =>
      _$complaintDTypeSerializer;
}

abstract class ComplaintDStoreType
    implements Built<ComplaintDStoreType, ComplaintDStoreTypeBuilder> {
  @BuiltValueField(wireName: 'itemTypeId')
  @nullable
  String get itemId;
  @BuiltValueField(wireName: 'itemTypeDesc')
  @nullable
  String get itemName;

  @nullable
  BuiltList<ComplaintMaterial> get parts;

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
  @nullable
  String get itemId;
  @BuiltValueField(wireName: 'item_description')
  @nullable
  String get itemName;
  @BuiltValueField(wireName: 'partCounts')
  @nullable
  String get itemQuantity;
  @BuiltValueField(wireName: 'itemTypeDesc')
  @nullable
  String get itemTypeDesc;
  @nullable
  String get partLocked;
  @nullable
  String get partMaxOrder;
  @nullable
  String get partMinOrder;
  @nullable
  String get partRemark;

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

  @nullable
  String get itemDescription;
  @nullable
  String get partAvailable;
  @nullable
  String get partCount;
  @nullable
  String get partId;
  @nullable
  String get partLocked;
  @nullable
  String get partMaxOrder;
  @nullable
  String get partMinOrder;
  @nullable
  String get partRemark;

  Map<String, dynamic> toJson() {
    return serializers.serializeWith(MaterialStorePart.serializer, this);
  }

  static MaterialStorePart fromJson(Map<String, dynamic> json) {
    return serializers.deserializeWith(MaterialStorePart.serializer, json);
  }

  static Serializer<MaterialStorePart> get serializer =>
      _$materialStorePartSerializer;
}

abstract class ComplaintDImage
    implements Built<ComplaintDImage, ComplaintDImageBuilder> {
  @nullable
  String get file;
  @nullable
  String get title;
  @nullable
  String get width;
  @nullable
  String get height;

  ComplaintDImage._();
  factory ComplaintDImage([void Function(ComplaintDImageBuilder) updates]) =
      _$ComplaintDImage;

  Map<String, dynamic> toJson() {
    return serializers.serializeWith(ComplaintDImage.serializer, this);
  }

  static ComplaintDImage fromJson(Map<String, dynamic> json) {
    return serializers.deserializeWith(ComplaintDImage.serializer, json);
  }

  static Serializer<ComplaintDImage> get serializer =>
      _$complaintDImageSerializer;
}

abstract class RequestTask implements Built<RequestTask, RequestTaskBuilder> {
  @nullable
  String get requestBy; //a
  @nullable
  String get requestTime; //a
  @nullable
  String get statusDesc; //a
  @nullable
  String get statusId; //a
  @nullable
  String get taskFrom;
  @nullable
  String get taskReceivedTime; // collect time
  @nullable
  String get woSeverityDesc; //a
  @nullable
  String get woTaskNo; //a
  @nullable
  String get woTaskRequestId; //a
  @nullable
  String get woTaskRequestNo; // wo request no
  @nullable
  String get woTypeDesc; //a
  @nullable
  String get collectTime;
  @nullable
  String get siteName;

  RequestTask._();
  factory RequestTask([void Function(RequestTaskBuilder) updates]) =
      _$RequestTask;

  Map<String, dynamic> toJson() {
    return serializers.serializeWith(RequestTask.serializer, this);
  }

  static RequestTask fromJson(Map<String, dynamic> json) {
    return serializers.deserializeWith(RequestTask.serializer, json);
  }

  static Serializer<RequestTask> get serializer => _$requestTaskSerializer;
}

abstract class ComplaintMaterial
    implements Built<ComplaintMaterial, ComplaintMaterialBuilder> {
  @nullable
  String get assetGroupId;
  @nullable
  String get assetGroupName;
  @nullable
  String get itemDescription;
  @nullable
  String get itemId;
  @nullable
  String get itemTypeDesc;
  @nullable
  String get itemTypeId;
  @nullable
  String get partAvailable;
  @nullable
  String get partCount;
  @nullable
  String get partId;
  @nullable
  String get partLocked;
  @nullable
  String get partMaxOrder;
  @nullable
  String get partMinOrder;
  @nullable
  String get partRemark;
  @nullable
  String get partThreshold;
  @nullable
  BuiltList<ComplaintMaterialGrouped> get itemGrouped;
  @nullable
  BuiltList<ComplaintMaterialImage> get images;

  ComplaintMaterial._();
  factory ComplaintMaterial([void Function(ComplaintMaterialBuilder) updates]) =
      _$ComplaintMaterial;

  static ComplaintMaterial fromJson(Map<String, dynamic> json) {
    return serializers.deserializeWith(ComplaintMaterial.serializer, json);
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
        ComplaintMaterialGrouped.serializer, json);
  }

  static Serializer<ComplaintMaterialGrouped> get serializer =>
      _$complaintMaterialGroupedSerializer;
}

abstract class ComplaintMaterialImage
    implements Built<ComplaintMaterialImage, ComplaintMaterialImageBuilder> {
  @nullable
  String get file;
  @nullable
  String get height;
  @nullable
  String get width;
  @nullable
  String get title;

  ComplaintMaterialImage._();
  factory ComplaintMaterialImage(
          [void Function(ComplaintMaterialImageBuilder) updates]) =
      _$ComplaintMaterialImage;

  Map<String, dynamic> toJson() {
    return serializers.serializeWith(ComplaintMaterialImage.serializer, this);
  }

  static ComplaintMaterialImage fromJson(Map<String, dynamic> json) {
    return serializers.deserializeWith(ComplaintMaterialImage.serializer, json);
  }

  static Serializer<ComplaintMaterialImage> get serializer =>
      _$complaintMaterialImageSerializer;
}
