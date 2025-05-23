library form;

import 'dart:convert';

import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';
import 'package:GEMS/model/serializers.dart';

part 'form.g.dart';

abstract class Form implements Built<Form, FormBuilder> {
  String get ppmTaskSectionId;
  String get ppmTaskSectionName;
  String get ppmTaskId;
  String get ppmTaskSectionStatus;
  String get checkParts;
  String get checkAdditionalReport;

  Form._();

  factory Form([void Function(FormBuilder) updates]) = _$Form;

  String toJson() {
    return json.encode(serializers.serializeWith(Form.serializer, this));
  }

  static Form fromJson(String jsonString) {
    return serializers.deserializeWith(Form.serializer, json.decode(jsonString))!;
  }

  static Serializer<Form> get serializer => _$formSerializer;
}

abstract class FormAItem implements Built<FormAItem, FormAItemBuilder> {
  String get ppmTaskId;
  String get ppmTaskScheduleDate;
  String get assetId;
  String get assetGroupName;
  String get assetCategoryName;
  String get assetTypeName;
  String get assetBrandName;
  String get assetModelName;
  String get assetNo;
  String get assetName;
  String get locationCodeId;
  String get assetCapacity;
  String get ppmTaskTimeStart;
  String get ppmTaskTimeServiced;

  FormAItem._();

  factory FormAItem([void Function(FormAItemBuilder) updates]) = _$FormAItem;

  String toJson() {
    return json.encode(serializers.serializeWith(FormAItem.serializer, this));
  }

  static FormAItem fromJson(String jsonString) {
    return serializers.deserializeWith(FormAItem.serializer, json.decode(jsonString))!;
  }

  static Serializer<FormAItem> get serializer => _$formAItemSerializer;
}

abstract class FormBItem implements Built<FormBItem, FormBItemBuilder> {
  String get ppmTaskId;
  String get ppmTaskGuideline;

  FormBItem._();

  factory FormBItem([void Function(FormBItemBuilder) updates]) = _$FormBItem;

  String toJson() {
    return json.encode(serializers.serializeWith(FormBItem.serializer, this));
  }

  static FormBItem fromJson(String jsonString) {
    return serializers.deserializeWith(FormBItem.serializer, json.decode(jsonString))!;
  }

  static Serializer<FormBItem> get serializer => _$formBItemSerializer;
}

abstract class FormCItem implements Built<FormCItem, FormCItemBuilder> {
  String get ppmTaskQualId;
  String get ppmTaskId;
  String get ppmTaskQualNumb;
  String get ppmTaskQualDesc;
  String get frequencyId;
  String get frequencyName;
  String get ppmTaskQualResult;
  String get ppmTaskQualRemark;

  FormCItem._();

  factory FormCItem([void Function(FormCItemBuilder) updates]) = _$FormCItem;

  String toJson() {
    return json.encode(serializers.serializeWith(FormCItem.serializer, this));
  }

  static FormCItem fromJson(String jsonString) {
    return serializers.deserializeWith(FormCItem.serializer, json.decode(jsonString))!;
  }

  static Serializer<FormCItem> get serializer => _$formCItemSerializer;

  // Updated to return nullable string since some cases return null
  String? get dropDownValue {
    switch (ppmTaskQualResult) {
      case "Pass":
        return "Passed";
      case "Fail":
        return "Failed";
      case "Passed":
        return "Passed";
      case "Failed":
        return "Failed";
      case "N/A":
        return null;
      default:
        return null;
    }
  }
}

abstract class FormDItem implements Built<FormDItem, FormDItemBuilder> {
  String get ppmTaskQuanId;
  String get ppmTaskId;
  String get ppmTaskQuanNumb;
  String get ppmTaskQuanDesc;
  String get frequencyId;
  String get frequencyName;
  String get ppmTaskQuanUnit;
  String get ppmTaskQuanSetValues;
  String get ppmTaskQuanMeasuredValues;
  String get ppmTaskQuanLimit;
  String get ppmTaskQuanResult;
  String get ppmTaskQuanRemark;

  FormDItem._();

  factory FormDItem([void Function(FormDItemBuilder) updates]) = _$FormDItem;

  String toJson() {
    return json.encode(serializers.serializeWith(FormDItem.serializer, this));
  }

  static FormDItem fromJson(String jsonString) {
    return serializers.deserializeWith(FormDItem.serializer, json.decode(jsonString))!;
  }

  static Serializer<FormDItem> get serializer => _$formDItemSerializer;
}

abstract class FormEItem implements Built<FormEItem, FormEItemBuilder> {
  String get ppmTaskPartsId;
  String get ppmTaskId;
  String get ppmTaskPartsDesc;

  FormEItem._();

  factory FormEItem([void Function(FormEItemBuilder) updates]) = _$FormEItem;

  String toJson() {
    return json.encode(serializers.serializeWith(FormEItem.serializer, this));
  }

  static FormEItem fromJson(String jsonString) {
    return serializers.deserializeWith(FormEItem.serializer, json.decode(jsonString))!;
  }

  static Serializer<FormEItem> get serializer => _$formEItemSerializer;
}

abstract class FormFItem implements Built<FormFItem, FormFItemBuilder> {
  String get ppmTaskUploadId;
  String get ppmTaskUploadType;
  String get ppmTaskId;
  String get uploadId;
  String get uploadName;
  String get documentDesc;
  String get documentFilename;
  String get documentSrc;

  FormFItem._();

  factory FormFItem([void Function(FormFItemBuilder) updates]) = _$FormFItem;

  String toJson() {
    return json.encode(serializers.serializeWith(FormFItem.serializer, this));
  }

  static FormFItem fromJson(String jsonString) {
    return serializers.deserializeWith(FormFItem.serializer, json.decode(jsonString))!;
  }

  static Serializer<FormFItem> get serializer => _$formFItemSerializer;
}

abstract class FormGItem implements Built<FormGItem, FormGItemBuilder> {
  String get ppmTaskId;
  String get ppmTaskRemark;

  FormGItem._();

  factory FormGItem([void Function(FormGItemBuilder) updates]) = _$FormGItem;

  String toJson() {
    return json.encode(serializers.serializeWith(FormGItem.serializer, this));
  }

  static FormGItem fromJson(String jsonString) {
    return serializers.deserializeWith(FormGItem.serializer, json.decode(jsonString))!;
  }

  static Serializer<FormGItem> get serializer => _$formGItemSerializer;
}

abstract class FormHItem implements Built<FormHItem, FormHItemBuilder> {
  String get ppmTaskUploadId;
  String get ppmTaskUploadType;
  String get ppmTaskUploadLongitude;
  String get ppmTaskUploadLatitude;
  String get ppmTaskUploadTimestamp;
  String get ppmTaskUploadDesc;
  String get ppmTaskId;
  String? get uploadId;
  String get uploadName;
  String get documentDesc;
  String get documentFilename;
  String get documentSrc;

  FormHItem._();

  factory FormHItem([void Function(FormHItemBuilder) updates]) = _$FormHItem;

  String toJson() {
    return json.encode(serializers.serializeWith(FormHItem.serializer, this));
  }

  static FormHItem fromJson(String jsonString) {
    return serializers.deserializeWith(FormHItem.serializer, json.decode(jsonString))!;
  }

  static Serializer<FormHItem> get serializer => _$formHItemSerializer;
}
