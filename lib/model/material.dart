import 'package:built_collection/built_collection.dart';
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

import 'complaint.dart';

part 'material.g.dart';

abstract class Material implements Built<Material, MaterialBuilder> {
  String? get assetGroupName;
  String? get itemDescription;
  String? get itemId;
  String? get itemTypeDesc;
  String? get partAvailable;
  String? get partCount;
  String? get partId;
  String? get partLocked;
  String? get partThreshold;
  String? get statusDesc;
  String? get statusStorekeeper;
  String? get woTaskPartsId;
  String? get woTaskPartsQuantity;
  String? get woTaskPartsRemark;
  String? get woTaskPartStatus;
  String? get woTaskRequestId;
  BuiltList<ComplaintDImage>? get images;

  Material._();
  factory Material([void Function(MaterialBuilder) updates]) = _$Material;

  static Serializer<Material> get serializer => _$materialSerializer;
}
