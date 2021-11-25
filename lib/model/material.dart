import 'package:built_collection/built_collection.dart';
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

import 'complaint.dart';

part 'material.g.dart';

abstract class Material implements Built<Material, MaterialBuilder> {
  @nullable
  String get assetGroupName;
  @nullable
  String get itemDescription;
  @nullable
  String get itemId;
  @nullable
  String get itemTypeDesc;
  @nullable
  String get partAvailable;
  @nullable
  String get partCount;
  @nullable
  String get partId;
  @nullable
  String get partLocked;
  @nullable
  String get partThreshold;
  @nullable
  String get statusDesc;
  @nullable
  String get statusStorekeeper;
  @nullable
  String get woTaskPartsId;
  @nullable
  String get woTaskPartsQuantity;
  @nullable
  String get woTaskPartsRemark;
  @nullable
  String get woTaskPartStatus;
  @nullable
  String get woTaskRequestId;
  @nullable
  BuiltList<ComplaintDImage> get images;

  Material._();
  factory Material([void Function(MaterialBuilder) updates]) = _$Material;

  static Serializer<Material> get serializer => _$materialSerializer;
}
