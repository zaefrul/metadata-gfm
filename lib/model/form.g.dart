// GENERATED CODE - DO NOT MODIFY BY HAND

part of form;

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

Serializer<Form> _$formSerializer = new _$FormSerializer();
Serializer<FormAItem> _$formAItemSerializer = new _$FormAItemSerializer();
Serializer<FormBItem> _$formBItemSerializer = new _$FormBItemSerializer();
Serializer<FormCItem> _$formCItemSerializer = new _$FormCItemSerializer();
Serializer<FormDItem> _$formDItemSerializer = new _$FormDItemSerializer();
Serializer<FormEItem> _$formEItemSerializer = new _$FormEItemSerializer();
Serializer<FormFItem> _$formFItemSerializer = new _$FormFItemSerializer();
Serializer<FormGItem> _$formGItemSerializer = new _$FormGItemSerializer();
Serializer<FormHItem> _$formHItemSerializer = new _$FormHItemSerializer();

class _$FormSerializer implements StructuredSerializer<Form> {
  @override
  final Iterable<Type> types = const [Form, _$Form];
  @override
  final String wireName = 'Form';

  @override
  Iterable<Object> serialize(Serializers serializers, Form object,
      {FullType specifiedType = FullType.unspecified}) {
    final result = <Object>[
      'ppmTaskSectionId',
      serializers.serialize(object.ppmTaskSectionId,
          specifiedType: const FullType(String)),
      'ppmTaskSectionName',
      serializers.serialize(object.ppmTaskSectionName,
          specifiedType: const FullType(String)),
      'ppmTaskId',
      serializers.serialize(object.ppmTaskId,
          specifiedType: const FullType(String)),
      'ppmTaskSectionStatus',
      serializers.serialize(object.ppmTaskSectionStatus,
          specifiedType: const FullType(String)),
      'checkParts',
      serializers.serialize(object.checkParts,
          specifiedType: const FullType(String)),
      'checkAdditionalReport',
      serializers.serialize(object.checkAdditionalReport,
          specifiedType: const FullType(String)),
    ];

    return result;
  }

  @override
  Form deserialize(Serializers serializers, Iterable<Object> serialized,
      {FullType specifiedType = FullType.unspecified}) {
    final result = new FormBuilder();

    final iterator = serialized.iterator;
    while (iterator.moveNext()) {
      final key = iterator.current as String;
      iterator.moveNext();
      final dynamic value = iterator.current;
      switch (key) {
        case 'ppmTaskSectionId':
          result.ppmTaskSectionId = serializers.deserialize(value,
              specifiedType: const FullType(String)) as String;
          break;
        case 'ppmTaskSectionName':
          result.ppmTaskSectionName = serializers.deserialize(value,
              specifiedType: const FullType(String)) as String;
          break;
        case 'ppmTaskId':
          result.ppmTaskId = serializers.deserialize(value,
              specifiedType: const FullType(String)) as String;
          break;
        case 'ppmTaskSectionStatus':
          result.ppmTaskSectionStatus = serializers.deserialize(value,
              specifiedType: const FullType(String)) as String;
          break;
        case 'checkParts':
          result.checkParts = serializers.deserialize(value,
              specifiedType: const FullType(String)) as String;
          break;
        case 'checkAdditionalReport':
          result.checkAdditionalReport = serializers.deserialize(value,
              specifiedType: const FullType(String)) as String;
          break;
      }
    }

    return result.build();
  }
}

class _$FormAItemSerializer implements StructuredSerializer<FormAItem> {
  @override
  final Iterable<Type> types = const [FormAItem, _$FormAItem];
  @override
  final String wireName = 'FormAItem';

  @override
  Iterable<Object> serialize(Serializers serializers, FormAItem object,
      {FullType specifiedType = FullType.unspecified}) {
    final result = <Object>[
      'ppmTaskId',
      serializers.serialize(object.ppmTaskId,
          specifiedType: const FullType(String)),
      'ppmTaskScheduleDate',
      serializers.serialize(object.ppmTaskScheduleDate,
          specifiedType: const FullType(String)),
      'assetId',
      serializers.serialize(object.assetId,
          specifiedType: const FullType(String)),
      'assetGroupName',
      serializers.serialize(object.assetGroupName,
          specifiedType: const FullType(String)),
      'assetCategoryName',
      serializers.serialize(object.assetCategoryName,
          specifiedType: const FullType(String)),
      'assetTypeName',
      serializers.serialize(object.assetTypeName,
          specifiedType: const FullType(String)),
      'assetBrandName',
      serializers.serialize(object.assetBrandName,
          specifiedType: const FullType(String)),
      'assetModelName',
      serializers.serialize(object.assetModelName,
          specifiedType: const FullType(String)),
      'assetNo',
      serializers.serialize(object.assetNo,
          specifiedType: const FullType(String)),
      'assetName',
      serializers.serialize(object.assetName,
          specifiedType: const FullType(String)),
      'locationCodeId',
      serializers.serialize(object.locationCodeId,
          specifiedType: const FullType(String)),
      'assetCapacity',
      serializers.serialize(object.assetCapacity,
          specifiedType: const FullType(String)),
      'ppmTaskTimeStart',
      serializers.serialize(object.ppmTaskTimeStart,
          specifiedType: const FullType(String)),
      'ppmTaskTimeServiced',
      serializers.serialize(object.ppmTaskTimeServiced,
          specifiedType: const FullType(String)),
    ];

    return result;
  }

  @override
  FormAItem deserialize(Serializers serializers, Iterable<Object> serialized,
      {FullType specifiedType = FullType.unspecified}) {
    final result = new FormAItemBuilder();

    final iterator = serialized.iterator;
    while (iterator.moveNext()) {
      final key = iterator.current as String;
      iterator.moveNext();
      final dynamic value = iterator.current;
      switch (key) {
        case 'ppmTaskId':
          result.ppmTaskId = serializers.deserialize(value,
              specifiedType: const FullType(String)) as String;
          break;
        case 'ppmTaskScheduleDate':
          result.ppmTaskScheduleDate = serializers.deserialize(value,
              specifiedType: const FullType(String)) as String;
          break;
        case 'assetId':
          result.assetId = serializers.deserialize(value,
              specifiedType: const FullType(String)) as String;
          break;
        case 'assetGroupName':
          result.assetGroupName = serializers.deserialize(value,
              specifiedType: const FullType(String)) as String;
          break;
        case 'assetCategoryName':
          result.assetCategoryName = serializers.deserialize(value,
              specifiedType: const FullType(String)) as String;
          break;
        case 'assetTypeName':
          result.assetTypeName = serializers.deserialize(value,
              specifiedType: const FullType(String)) as String;
          break;
        case 'assetBrandName':
          result.assetBrandName = serializers.deserialize(value,
              specifiedType: const FullType(String)) as String;
          break;
        case 'assetModelName':
          result.assetModelName = serializers.deserialize(value,
              specifiedType: const FullType(String)) as String;
          break;
        case 'assetNo':
          result.assetNo = serializers.deserialize(value,
              specifiedType: const FullType(String)) as String;
          break;
        case 'assetName':
          result.assetName = serializers.deserialize(value,
              specifiedType: const FullType(String)) as String;
          break;
        case 'locationCodeId':
          result.locationCodeId = serializers.deserialize(value,
              specifiedType: const FullType(String)) as String;
          break;
        case 'assetCapacity':
          result.assetCapacity = serializers.deserialize(value,
              specifiedType: const FullType(String)) as String;
          break;
        case 'ppmTaskTimeStart':
          result.ppmTaskTimeStart = serializers.deserialize(value,
              specifiedType: const FullType(String)) as String;
          break;
        case 'ppmTaskTimeServiced':
          result.ppmTaskTimeServiced = serializers.deserialize(value,
              specifiedType: const FullType(String)) as String;
          break;
      }
    }

    return result.build();
  }
}

class _$FormBItemSerializer implements StructuredSerializer<FormBItem> {
  @override
  final Iterable<Type> types = const [FormBItem, _$FormBItem];
  @override
  final String wireName = 'FormBItem';

  @override
  Iterable<Object> serialize(Serializers serializers, FormBItem object,
      {FullType specifiedType = FullType.unspecified}) {
    final result = <Object>[
      'ppmTaskId',
      serializers.serialize(object.ppmTaskId,
          specifiedType: const FullType(String)),
      'ppmTaskGuideline',
      serializers.serialize(object.ppmTaskGuideline,
          specifiedType: const FullType(String)),
    ];

    return result;
  }

  @override
  FormBItem deserialize(Serializers serializers, Iterable<Object> serialized,
      {FullType specifiedType = FullType.unspecified}) {
    final result = new FormBItemBuilder();

    final iterator = serialized.iterator;
    while (iterator.moveNext()) {
      final key = iterator.current as String;
      iterator.moveNext();
      final dynamic value = iterator.current;
      switch (key) {
        case 'ppmTaskId':
          result.ppmTaskId = serializers.deserialize(value,
              specifiedType: const FullType(String)) as String;
          break;
        case 'ppmTaskGuideline':
          result.ppmTaskGuideline = serializers.deserialize(value,
              specifiedType: const FullType(String)) as String;
          break;
      }
    }

    return result.build();
  }
}

class _$FormCItemSerializer implements StructuredSerializer<FormCItem> {
  @override
  final Iterable<Type> types = const [FormCItem, _$FormCItem];
  @override
  final String wireName = 'FormCItem';

  @override
  Iterable<Object> serialize(Serializers serializers, FormCItem object,
      {FullType specifiedType = FullType.unspecified}) {
    final result = <Object>[
      'ppmTaskQualId',
      serializers.serialize(object.ppmTaskQualId,
          specifiedType: const FullType(String)),
      'ppmTaskId',
      serializers.serialize(object.ppmTaskId,
          specifiedType: const FullType(String)),
      'ppmTaskQualNumb',
      serializers.serialize(object.ppmTaskQualNumb,
          specifiedType: const FullType(String)),
      'ppmTaskQualDesc',
      serializers.serialize(object.ppmTaskQualDesc,
          specifiedType: const FullType(String)),
      'frequencyId',
      serializers.serialize(object.frequencyId,
          specifiedType: const FullType(String)),
      'frequencyName',
      serializers.serialize(object.frequencyName,
          specifiedType: const FullType(String)),
      'ppmTaskQualResult',
      serializers.serialize(object.ppmTaskQualResult,
          specifiedType: const FullType(String)),
      'ppmTaskQualRemark',
      serializers.serialize(object.ppmTaskQualRemark,
          specifiedType: const FullType(String)),
    ];

    return result;
  }

  @override
  FormCItem deserialize(Serializers serializers, Iterable<Object> serialized,
      {FullType specifiedType = FullType.unspecified}) {
    final result = new FormCItemBuilder();

    final iterator = serialized.iterator;
    while (iterator.moveNext()) {
      final key = iterator.current as String;
      iterator.moveNext();
      final dynamic value = iterator.current;
      switch (key) {
        case 'ppmTaskQualId':
          result.ppmTaskQualId = serializers.deserialize(value,
              specifiedType: const FullType(String)) as String;
          break;
        case 'ppmTaskId':
          result.ppmTaskId = serializers.deserialize(value,
              specifiedType: const FullType(String)) as String;
          break;
        case 'ppmTaskQualNumb':
          result.ppmTaskQualNumb = serializers.deserialize(value,
              specifiedType: const FullType(String)) as String;
          break;
        case 'ppmTaskQualDesc':
          result.ppmTaskQualDesc = serializers.deserialize(value,
              specifiedType: const FullType(String)) as String;
          break;
        case 'frequencyId':
          result.frequencyId = serializers.deserialize(value,
              specifiedType: const FullType(String)) as String;
          break;
        case 'frequencyName':
          result.frequencyName = serializers.deserialize(value,
              specifiedType: const FullType(String)) as String;
          break;
        case 'ppmTaskQualResult':
          result.ppmTaskQualResult = serializers.deserialize(value,
              specifiedType: const FullType(String)) as String;
          break;
        case 'ppmTaskQualRemark':
          result.ppmTaskQualRemark = serializers.deserialize(value,
              specifiedType: const FullType(String)) as String;
          break;
      }
    }

    return result.build();
  }
}

class _$FormDItemSerializer implements StructuredSerializer<FormDItem> {
  @override
  final Iterable<Type> types = const [FormDItem, _$FormDItem];
  @override
  final String wireName = 'FormDItem';

  @override
  Iterable<Object> serialize(Serializers serializers, FormDItem object,
      {FullType specifiedType = FullType.unspecified}) {
    final result = <Object>[
      'ppmTaskQuanId',
      serializers.serialize(object.ppmTaskQuanId,
          specifiedType: const FullType(String)),
      'ppmTaskId',
      serializers.serialize(object.ppmTaskId,
          specifiedType: const FullType(String)),
      'ppmTaskQuanNumb',
      serializers.serialize(object.ppmTaskQuanNumb,
          specifiedType: const FullType(String)),
      'ppmTaskQuanDesc',
      serializers.serialize(object.ppmTaskQuanDesc,
          specifiedType: const FullType(String)),
      'frequencyId',
      serializers.serialize(object.frequencyId,
          specifiedType: const FullType(String)),
      'frequencyName',
      serializers.serialize(object.frequencyName,
          specifiedType: const FullType(String)),
      'ppmTaskQuanUnit',
      serializers.serialize(object.ppmTaskQuanUnit,
          specifiedType: const FullType(String)),
      'ppmTaskQuanSetValues',
      serializers.serialize(object.ppmTaskQuanSetValues,
          specifiedType: const FullType(String)),
      'ppmTaskQuanMeasuredValues',
      serializers.serialize(object.ppmTaskQuanMeasuredValues,
          specifiedType: const FullType(String)),
      'ppmTaskQuanLimit',
      serializers.serialize(object.ppmTaskQuanLimit,
          specifiedType: const FullType(String)),
      'ppmTaskQuanResult',
      serializers.serialize(object.ppmTaskQuanResult,
          specifiedType: const FullType(String)),
      'ppmTaskQuanRemark',
      serializers.serialize(object.ppmTaskQuanRemark,
          specifiedType: const FullType(String)),
    ];

    return result;
  }

  @override
  FormDItem deserialize(Serializers serializers, Iterable<Object> serialized,
      {FullType specifiedType = FullType.unspecified}) {
    final result = new FormDItemBuilder();

    final iterator = serialized.iterator;
    while (iterator.moveNext()) {
      final key = iterator.current as String;
      iterator.moveNext();
      final dynamic value = iterator.current;
      switch (key) {
        case 'ppmTaskQuanId':
          result.ppmTaskQuanId = serializers.deserialize(value,
              specifiedType: const FullType(String)) as String;
          break;
        case 'ppmTaskId':
          result.ppmTaskId = serializers.deserialize(value,
              specifiedType: const FullType(String)) as String;
          break;
        case 'ppmTaskQuanNumb':
          result.ppmTaskQuanNumb = serializers.deserialize(value,
              specifiedType: const FullType(String)) as String;
          break;
        case 'ppmTaskQuanDesc':
          result.ppmTaskQuanDesc = serializers.deserialize(value,
              specifiedType: const FullType(String)) as String;
          break;
        case 'frequencyId':
          result.frequencyId = serializers.deserialize(value,
              specifiedType: const FullType(String)) as String;
          break;
        case 'frequencyName':
          result.frequencyName = serializers.deserialize(value,
              specifiedType: const FullType(String)) as String;
          break;
        case 'ppmTaskQuanUnit':
          result.ppmTaskQuanUnit = serializers.deserialize(value,
              specifiedType: const FullType(String)) as String;
          break;
        case 'ppmTaskQuanSetValues':
          result.ppmTaskQuanSetValues = serializers.deserialize(value,
              specifiedType: const FullType(String)) as String;
          break;
        case 'ppmTaskQuanMeasuredValues':
          result.ppmTaskQuanMeasuredValues = serializers.deserialize(value,
              specifiedType: const FullType(String)) as String;
          break;
        case 'ppmTaskQuanLimit':
          result.ppmTaskQuanLimit = serializers.deserialize(value,
              specifiedType: const FullType(String)) as String;
          break;
        case 'ppmTaskQuanResult':
          result.ppmTaskQuanResult = serializers.deserialize(value,
              specifiedType: const FullType(String)) as String;
          break;
        case 'ppmTaskQuanRemark':
          result.ppmTaskQuanRemark = serializers.deserialize(value,
              specifiedType: const FullType(String)) as String;
          break;
      }
    }

    return result.build();
  }
}

class _$FormEItemSerializer implements StructuredSerializer<FormEItem> {
  @override
  final Iterable<Type> types = const [FormEItem, _$FormEItem];
  @override
  final String wireName = 'FormEItem';

  @override
  Iterable<Object> serialize(Serializers serializers, FormEItem object,
      {FullType specifiedType = FullType.unspecified}) {
    final result = <Object>[
      'ppmTaskPartsId',
      serializers.serialize(object.ppmTaskPartsId,
          specifiedType: const FullType(String)),
      'ppmTaskId',
      serializers.serialize(object.ppmTaskId,
          specifiedType: const FullType(String)),
      'ppmTaskPartsDesc',
      serializers.serialize(object.ppmTaskPartsDesc,
          specifiedType: const FullType(String)),
    ];

    return result;
  }

  @override
  FormEItem deserialize(Serializers serializers, Iterable<Object> serialized,
      {FullType specifiedType = FullType.unspecified}) {
    final result = new FormEItemBuilder();

    final iterator = serialized.iterator;
    while (iterator.moveNext()) {
      final key = iterator.current as String;
      iterator.moveNext();
      final dynamic value = iterator.current;
      switch (key) {
        case 'ppmTaskPartsId':
          result.ppmTaskPartsId = serializers.deserialize(value,
              specifiedType: const FullType(String)) as String;
          break;
        case 'ppmTaskId':
          result.ppmTaskId = serializers.deserialize(value,
              specifiedType: const FullType(String)) as String;
          break;
        case 'ppmTaskPartsDesc':
          result.ppmTaskPartsDesc = serializers.deserialize(value,
              specifiedType: const FullType(String)) as String;
          break;
      }
    }

    return result.build();
  }
}

class _$FormFItemSerializer implements StructuredSerializer<FormFItem> {
  @override
  final Iterable<Type> types = const [FormFItem, _$FormFItem];
  @override
  final String wireName = 'FormFItem';

  @override
  Iterable<Object> serialize(Serializers serializers, FormFItem object,
      {FullType specifiedType = FullType.unspecified}) {
    final result = <Object>[
      'ppmTaskUploadId',
      serializers.serialize(object.ppmTaskUploadId,
          specifiedType: const FullType(String)),
      'ppmTaskUploadType',
      serializers.serialize(object.ppmTaskUploadType,
          specifiedType: const FullType(String)),
      'ppmTaskId',
      serializers.serialize(object.ppmTaskId,
          specifiedType: const FullType(String)),
      'uploadId',
      serializers.serialize(object.uploadId,
          specifiedType: const FullType(String)),
      'uploadName',
      serializers.serialize(object.uploadName,
          specifiedType: const FullType(String)),
      'documentDesc',
      serializers.serialize(object.documentDesc,
          specifiedType: const FullType(String)),
      'documentFilename',
      serializers.serialize(object.documentFilename,
          specifiedType: const FullType(String)),
      'documentSrc',
      serializers.serialize(object.documentSrc,
          specifiedType: const FullType(String)),
    ];

    return result;
  }

  @override
  FormFItem deserialize(Serializers serializers, Iterable<Object> serialized,
      {FullType specifiedType = FullType.unspecified}) {
    final result = new FormFItemBuilder();

    final iterator = serialized.iterator;
    while (iterator.moveNext()) {
      final key = iterator.current as String;
      iterator.moveNext();
      final dynamic value = iterator.current;
      switch (key) {
        case 'ppmTaskUploadId':
          result.ppmTaskUploadId = serializers.deserialize(value,
              specifiedType: const FullType(String)) as String;
          break;
        case 'ppmTaskUploadType':
          result.ppmTaskUploadType = serializers.deserialize(value,
              specifiedType: const FullType(String)) as String;
          break;
        case 'ppmTaskId':
          result.ppmTaskId = serializers.deserialize(value,
              specifiedType: const FullType(String)) as String;
          break;
        case 'uploadId':
          result.uploadId = serializers.deserialize(value,
              specifiedType: const FullType(String)) as String;
          break;
        case 'uploadName':
          result.uploadName = serializers.deserialize(value,
              specifiedType: const FullType(String)) as String;
          break;
        case 'documentDesc':
          result.documentDesc = serializers.deserialize(value,
              specifiedType: const FullType(String)) as String;
          break;
        case 'documentFilename':
          result.documentFilename = serializers.deserialize(value,
              specifiedType: const FullType(String)) as String;
          break;
        case 'documentSrc':
          result.documentSrc = serializers.deserialize(value,
              specifiedType: const FullType(String)) as String;
          break;
      }
    }

    return result.build();
  }
}

class _$FormGItemSerializer implements StructuredSerializer<FormGItem> {
  @override
  final Iterable<Type> types = const [FormGItem, _$FormGItem];
  @override
  final String wireName = 'FormGItem';

  @override
  Iterable<Object> serialize(Serializers serializers, FormGItem object,
      {FullType specifiedType = FullType.unspecified}) {
    final result = <Object>[
      'ppmTaskId',
      serializers.serialize(object.ppmTaskId,
          specifiedType: const FullType(String)),
      'ppmTaskRemark',
      serializers.serialize(object.ppmTaskRemark,
          specifiedType: const FullType(String)),
    ];

    return result;
  }

  @override
  FormGItem deserialize(Serializers serializers, Iterable<Object> serialized,
      {FullType specifiedType = FullType.unspecified}) {
    final result = new FormGItemBuilder();

    final iterator = serialized.iterator;
    while (iterator.moveNext()) {
      final key = iterator.current as String;
      iterator.moveNext();
      final dynamic value = iterator.current;
      switch (key) {
        case 'ppmTaskId':
          result.ppmTaskId = serializers.deserialize(value,
              specifiedType: const FullType(String)) as String;
          break;
        case 'ppmTaskRemark':
          result.ppmTaskRemark = serializers.deserialize(value,
              specifiedType: const FullType(String)) as String;
          break;
      }
    }

    return result.build();
  }
}

class _$FormHItemSerializer implements StructuredSerializer<FormHItem> {
  @override
  final Iterable<Type> types = const [FormHItem, _$FormHItem];
  @override
  final String wireName = 'FormHItem';

  @override
  Iterable<Object> serialize(Serializers serializers, FormHItem object,
      {FullType specifiedType = FullType.unspecified}) {
    final result = <Object>[
      'ppmTaskUploadId',
      serializers.serialize(object.ppmTaskUploadId,
          specifiedType: const FullType(String)),
      'ppmTaskUploadType',
      serializers.serialize(object.ppmTaskUploadType,
          specifiedType: const FullType(String)),
      'ppmTaskUploadLongitude',
      serializers.serialize(object.ppmTaskUploadLongitude,
          specifiedType: const FullType(String)),
      'ppmTaskUploadLatitude',
      serializers.serialize(object.ppmTaskUploadLatitude,
          specifiedType: const FullType(String)),
      'ppmTaskUploadTimestamp',
      serializers.serialize(object.ppmTaskUploadTimestamp,
          specifiedType: const FullType(String)),
      'ppmTaskUploadDesc',
      serializers.serialize(object.ppmTaskUploadDesc,
          specifiedType: const FullType(String)),
      'ppmTaskId',
      serializers.serialize(object.ppmTaskId,
          specifiedType: const FullType(String)),
      'uploadName',
      serializers.serialize(object.uploadName,
          specifiedType: const FullType(String)),
      'documentDesc',
      serializers.serialize(object.documentDesc,
          specifiedType: const FullType(String)),
      'documentFilename',
      serializers.serialize(object.documentFilename,
          specifiedType: const FullType(String)),
      'documentSrc',
      serializers.serialize(object.documentSrc,
          specifiedType: const FullType(String)),
    ];
    if (object.uploadId != null) {
      result
        ..add('uploadId')
        ..add(serializers.serialize(object.uploadId,
            specifiedType: const FullType(String)));
    }
    return result;
  }

  @override
  FormHItem deserialize(Serializers serializers, Iterable<Object> serialized,
      {FullType specifiedType = FullType.unspecified}) {
    final result = new FormHItemBuilder();

    final iterator = serialized.iterator;
    while (iterator.moveNext()) {
      final key = iterator.current as String;
      iterator.moveNext();
      final dynamic value = iterator.current;
      switch (key) {
        case 'ppmTaskUploadId':
          result.ppmTaskUploadId = serializers.deserialize(value,
              specifiedType: const FullType(String)) as String;
          break;
        case 'ppmTaskUploadType':
          result.ppmTaskUploadType = serializers.deserialize(value,
              specifiedType: const FullType(String)) as String;
          break;
        case 'ppmTaskUploadLongitude':
          result.ppmTaskUploadLongitude = serializers.deserialize(value,
              specifiedType: const FullType(String)) as String;
          break;
        case 'ppmTaskUploadLatitude':
          result.ppmTaskUploadLatitude = serializers.deserialize(value,
              specifiedType: const FullType(String)) as String;
          break;
        case 'ppmTaskUploadTimestamp':
          result.ppmTaskUploadTimestamp = serializers.deserialize(value,
              specifiedType: const FullType(String)) as String;
          break;
        case 'ppmTaskUploadDesc':
          result.ppmTaskUploadDesc = serializers.deserialize(value,
              specifiedType: const FullType(String)) as String;
          break;
        case 'ppmTaskId':
          result.ppmTaskId = serializers.deserialize(value,
              specifiedType: const FullType(String)) as String;
          break;
        case 'uploadId':
          result.uploadId = serializers.deserialize(value,
              specifiedType: const FullType(String)) as String;
          break;
        case 'uploadName':
          result.uploadName = serializers.deserialize(value,
              specifiedType: const FullType(String)) as String;
          break;
        case 'documentDesc':
          result.documentDesc = serializers.deserialize(value,
              specifiedType: const FullType(String)) as String;
          break;
        case 'documentFilename':
          result.documentFilename = serializers.deserialize(value,
              specifiedType: const FullType(String)) as String;
          break;
        case 'documentSrc':
          result.documentSrc = serializers.deserialize(value,
              specifiedType: const FullType(String)) as String;
          break;
      }
    }

    return result.build();
  }
}

class _$Form extends Form {
  @override
  final String ppmTaskSectionId;
  @override
  final String ppmTaskSectionName;
  @override
  final String ppmTaskId;
  @override
  final String ppmTaskSectionStatus;
  @override
  final String checkParts;
  @override
  final String checkAdditionalReport;

  factory _$Form([void Function(FormBuilder) updates]) =>
      (new FormBuilder()..update(updates)).build();

  _$Form._(
      {this.ppmTaskSectionId,
      this.ppmTaskSectionName,
      this.ppmTaskId,
      this.ppmTaskSectionStatus,
      this.checkParts,
      this.checkAdditionalReport})
      : super._() {
    if (ppmTaskSectionId == null) {
      throw new BuiltValueNullFieldError('Form', 'ppmTaskSectionId');
    }
    if (ppmTaskSectionName == null) {
      throw new BuiltValueNullFieldError('Form', 'ppmTaskSectionName');
    }
    if (ppmTaskId == null) {
      throw new BuiltValueNullFieldError('Form', 'ppmTaskId');
    }
    if (ppmTaskSectionStatus == null) {
      throw new BuiltValueNullFieldError('Form', 'ppmTaskSectionStatus');
    }
    if (checkParts == null) {
      throw new BuiltValueNullFieldError('Form', 'checkParts');
    }
    if (checkAdditionalReport == null) {
      throw new BuiltValueNullFieldError('Form', 'checkAdditionalReport');
    }
  }

  @override
  Form rebuild(void Function(FormBuilder) updates) =>
      (toBuilder()..update(updates)).build();

  @override
  FormBuilder toBuilder() => new FormBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is Form &&
        ppmTaskSectionId == other.ppmTaskSectionId &&
        ppmTaskSectionName == other.ppmTaskSectionName &&
        ppmTaskId == other.ppmTaskId &&
        ppmTaskSectionStatus == other.ppmTaskSectionStatus &&
        checkParts == other.checkParts &&
        checkAdditionalReport == other.checkAdditionalReport;
  }

  @override
  int get hashCode {
    return $jf($jc(
        $jc(
            $jc(
                $jc(
                    $jc($jc(0, ppmTaskSectionId.hashCode),
                        ppmTaskSectionName.hashCode),
                    ppmTaskId.hashCode),
                ppmTaskSectionStatus.hashCode),
            checkParts.hashCode),
        checkAdditionalReport.hashCode));
  }

  @override
  String toString() {
    return (newBuiltValueToStringHelper('Form')
          ..add('ppmTaskSectionId', ppmTaskSectionId)
          ..add('ppmTaskSectionName', ppmTaskSectionName)
          ..add('ppmTaskId', ppmTaskId)
          ..add('ppmTaskSectionStatus', ppmTaskSectionStatus)
          ..add('checkParts', checkParts)
          ..add('checkAdditionalReport', checkAdditionalReport))
        .toString();
  }
}

class FormBuilder implements Builder<Form, FormBuilder> {
  _$Form _$v;

  String _ppmTaskSectionId;
  String get ppmTaskSectionId => _$this._ppmTaskSectionId;
  set ppmTaskSectionId(String ppmTaskSectionId) =>
      _$this._ppmTaskSectionId = ppmTaskSectionId;

  String _ppmTaskSectionName;
  String get ppmTaskSectionName => _$this._ppmTaskSectionName;
  set ppmTaskSectionName(String ppmTaskSectionName) =>
      _$this._ppmTaskSectionName = ppmTaskSectionName;

  String _ppmTaskId;
  String get ppmTaskId => _$this._ppmTaskId;
  set ppmTaskId(String ppmTaskId) => _$this._ppmTaskId = ppmTaskId;

  String _ppmTaskSectionStatus;
  String get ppmTaskSectionStatus => _$this._ppmTaskSectionStatus;
  set ppmTaskSectionStatus(String ppmTaskSectionStatus) =>
      _$this._ppmTaskSectionStatus = ppmTaskSectionStatus;

  String _checkParts;
  String get checkParts => _$this._checkParts;
  set checkParts(String checkParts) => _$this._checkParts = checkParts;

  String _checkAdditionalReport;
  String get checkAdditionalReport => _$this._checkAdditionalReport;
  set checkAdditionalReport(String checkAdditionalReport) =>
      _$this._checkAdditionalReport = checkAdditionalReport;

  FormBuilder();

  FormBuilder get _$this {
    if (_$v != null) {
      _ppmTaskSectionId = _$v.ppmTaskSectionId;
      _ppmTaskSectionName = _$v.ppmTaskSectionName;
      _ppmTaskId = _$v.ppmTaskId;
      _ppmTaskSectionStatus = _$v.ppmTaskSectionStatus;
      _checkParts = _$v.checkParts;
      _checkAdditionalReport = _$v.checkAdditionalReport;
      _$v = null;
    }
    return this;
  }

  @override
  void replace(Form other) {
    if (other == null) {
      throw new ArgumentError.notNull('other');
    }
    _$v = other as _$Form;
  }

  @override
  void update(void Function(FormBuilder) updates) {
    if (updates != null) updates(this);
  }

  @override
  _$Form build() {
    final _$result = _$v ??
        new _$Form._(
            ppmTaskSectionId: ppmTaskSectionId,
            ppmTaskSectionName: ppmTaskSectionName,
            ppmTaskId: ppmTaskId,
            ppmTaskSectionStatus: ppmTaskSectionStatus,
            checkParts: checkParts,
            checkAdditionalReport: checkAdditionalReport);
    replace(_$result);
    return _$result;
  }
}

class _$FormAItem extends FormAItem {
  @override
  final String ppmTaskId;
  @override
  final String ppmTaskScheduleDate;
  @override
  final String assetId;
  @override
  final String assetGroupName;
  @override
  final String assetCategoryName;
  @override
  final String assetTypeName;
  @override
  final String assetBrandName;
  @override
  final String assetModelName;
  @override
  final String assetNo;
  @override
  final String assetName;
  @override
  final String locationCodeId;
  @override
  final String assetCapacity;
  @override
  final String ppmTaskTimeStart;
  @override
  final String ppmTaskTimeServiced;

  factory _$FormAItem([void Function(FormAItemBuilder) updates]) =>
      (new FormAItemBuilder()..update(updates)).build();

  _$FormAItem._(
      {this.ppmTaskId,
      this.ppmTaskScheduleDate,
      this.assetId,
      this.assetGroupName,
      this.assetCategoryName,
      this.assetTypeName,
      this.assetBrandName,
      this.assetModelName,
      this.assetNo,
      this.assetName,
      this.locationCodeId,
      this.assetCapacity,
      this.ppmTaskTimeStart,
      this.ppmTaskTimeServiced})
      : super._() {
    if (ppmTaskId == null) {
      throw new BuiltValueNullFieldError('FormAItem', 'ppmTaskId');
    }
    if (ppmTaskScheduleDate == null) {
      throw new BuiltValueNullFieldError('FormAItem', 'ppmTaskScheduleDate');
    }
    if (assetId == null) {
      throw new BuiltValueNullFieldError('FormAItem', 'assetId');
    }
    if (assetGroupName == null) {
      throw new BuiltValueNullFieldError('FormAItem', 'assetGroupName');
    }
    if (assetCategoryName == null) {
      throw new BuiltValueNullFieldError('FormAItem', 'assetCategoryName');
    }
    if (assetTypeName == null) {
      throw new BuiltValueNullFieldError('FormAItem', 'assetTypeName');
    }
    if (assetBrandName == null) {
      throw new BuiltValueNullFieldError('FormAItem', 'assetBrandName');
    }
    if (assetModelName == null) {
      throw new BuiltValueNullFieldError('FormAItem', 'assetModelName');
    }
    if (assetNo == null) {
      throw new BuiltValueNullFieldError('FormAItem', 'assetNo');
    }
    if (assetName == null) {
      throw new BuiltValueNullFieldError('FormAItem', 'assetName');
    }
    if (locationCodeId == null) {
      throw new BuiltValueNullFieldError('FormAItem', 'locationCodeId');
    }
    if (assetCapacity == null) {
      throw new BuiltValueNullFieldError('FormAItem', 'assetCapacity');
    }
    if (ppmTaskTimeStart == null) {
      throw new BuiltValueNullFieldError('FormAItem', 'ppmTaskTimeStart');
    }
    if (ppmTaskTimeServiced == null) {
      throw new BuiltValueNullFieldError('FormAItem', 'ppmTaskTimeServiced');
    }
  }

  @override
  FormAItem rebuild(void Function(FormAItemBuilder) updates) =>
      (toBuilder()..update(updates)).build();

  @override
  FormAItemBuilder toBuilder() => new FormAItemBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is FormAItem &&
        ppmTaskId == other.ppmTaskId &&
        ppmTaskScheduleDate == other.ppmTaskScheduleDate &&
        assetId == other.assetId &&
        assetGroupName == other.assetGroupName &&
        assetCategoryName == other.assetCategoryName &&
        assetTypeName == other.assetTypeName &&
        assetBrandName == other.assetBrandName &&
        assetModelName == other.assetModelName &&
        assetNo == other.assetNo &&
        assetName == other.assetName &&
        locationCodeId == other.locationCodeId &&
        assetCapacity == other.assetCapacity &&
        ppmTaskTimeStart == other.ppmTaskTimeStart &&
        ppmTaskTimeServiced == other.ppmTaskTimeServiced;
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
                                                        $jc(0,
                                                            ppmTaskId.hashCode),
                                                        ppmTaskScheduleDate
                                                            .hashCode),
                                                    assetId.hashCode),
                                                assetGroupName.hashCode),
                                            assetCategoryName.hashCode),
                                        assetTypeName.hashCode),
                                    assetBrandName.hashCode),
                                assetModelName.hashCode),
                            assetNo.hashCode),
                        assetName.hashCode),
                    locationCodeId.hashCode),
                assetCapacity.hashCode),
            ppmTaskTimeStart.hashCode),
        ppmTaskTimeServiced.hashCode));
  }

  @override
  String toString() {
    return (newBuiltValueToStringHelper('FormAItem')
          ..add('ppmTaskId', ppmTaskId)
          ..add('ppmTaskScheduleDate', ppmTaskScheduleDate)
          ..add('assetId', assetId)
          ..add('assetGroupName', assetGroupName)
          ..add('assetCategoryName', assetCategoryName)
          ..add('assetTypeName', assetTypeName)
          ..add('assetBrandName', assetBrandName)
          ..add('assetModelName', assetModelName)
          ..add('assetNo', assetNo)
          ..add('assetName', assetName)
          ..add('locationCodeId', locationCodeId)
          ..add('assetCapacity', assetCapacity)
          ..add('ppmTaskTimeStart', ppmTaskTimeStart)
          ..add('ppmTaskTimeServiced', ppmTaskTimeServiced))
        .toString();
  }
}

class FormAItemBuilder implements Builder<FormAItem, FormAItemBuilder> {
  _$FormAItem _$v;

  String _ppmTaskId;
  String get ppmTaskId => _$this._ppmTaskId;
  set ppmTaskId(String ppmTaskId) => _$this._ppmTaskId = ppmTaskId;

  String _ppmTaskScheduleDate;
  String get ppmTaskScheduleDate => _$this._ppmTaskScheduleDate;
  set ppmTaskScheduleDate(String ppmTaskScheduleDate) =>
      _$this._ppmTaskScheduleDate = ppmTaskScheduleDate;

  String _assetId;
  String get assetId => _$this._assetId;
  set assetId(String assetId) => _$this._assetId = assetId;

  String _assetGroupName;
  String get assetGroupName => _$this._assetGroupName;
  set assetGroupName(String assetGroupName) =>
      _$this._assetGroupName = assetGroupName;

  String _assetCategoryName;
  String get assetCategoryName => _$this._assetCategoryName;
  set assetCategoryName(String assetCategoryName) =>
      _$this._assetCategoryName = assetCategoryName;

  String _assetTypeName;
  String get assetTypeName => _$this._assetTypeName;
  set assetTypeName(String assetTypeName) =>
      _$this._assetTypeName = assetTypeName;

  String _assetBrandName;
  String get assetBrandName => _$this._assetBrandName;
  set assetBrandName(String assetBrandName) =>
      _$this._assetBrandName = assetBrandName;

  String _assetModelName;
  String get assetModelName => _$this._assetModelName;
  set assetModelName(String assetModelName) =>
      _$this._assetModelName = assetModelName;

  String _assetNo;
  String get assetNo => _$this._assetNo;
  set assetNo(String assetNo) => _$this._assetNo = assetNo;

  String _assetName;
  String get assetName => _$this._assetName;
  set assetName(String assetName) => _$this._assetName = assetName;

  String _locationCodeId;
  String get locationCodeId => _$this._locationCodeId;
  set locationCodeId(String locationCodeId) =>
      _$this._locationCodeId = locationCodeId;

  String _assetCapacity;
  String get assetCapacity => _$this._assetCapacity;
  set assetCapacity(String assetCapacity) =>
      _$this._assetCapacity = assetCapacity;

  String _ppmTaskTimeStart;
  String get ppmTaskTimeStart => _$this._ppmTaskTimeStart;
  set ppmTaskTimeStart(String ppmTaskTimeStart) =>
      _$this._ppmTaskTimeStart = ppmTaskTimeStart;

  String _ppmTaskTimeServiced;
  String get ppmTaskTimeServiced => _$this._ppmTaskTimeServiced;
  set ppmTaskTimeServiced(String ppmTaskTimeServiced) =>
      _$this._ppmTaskTimeServiced = ppmTaskTimeServiced;

  FormAItemBuilder();

  FormAItemBuilder get _$this {
    if (_$v != null) {
      _ppmTaskId = _$v.ppmTaskId;
      _ppmTaskScheduleDate = _$v.ppmTaskScheduleDate;
      _assetId = _$v.assetId;
      _assetGroupName = _$v.assetGroupName;
      _assetCategoryName = _$v.assetCategoryName;
      _assetTypeName = _$v.assetTypeName;
      _assetBrandName = _$v.assetBrandName;
      _assetModelName = _$v.assetModelName;
      _assetNo = _$v.assetNo;
      _assetName = _$v.assetName;
      _locationCodeId = _$v.locationCodeId;
      _assetCapacity = _$v.assetCapacity;
      _ppmTaskTimeStart = _$v.ppmTaskTimeStart;
      _ppmTaskTimeServiced = _$v.ppmTaskTimeServiced;
      _$v = null;
    }
    return this;
  }

  @override
  void replace(FormAItem other) {
    if (other == null) {
      throw new ArgumentError.notNull('other');
    }
    _$v = other as _$FormAItem;
  }

  @override
  void update(void Function(FormAItemBuilder) updates) {
    if (updates != null) updates(this);
  }

  @override
  _$FormAItem build() {
    final _$result = _$v ??
        new _$FormAItem._(
            ppmTaskId: ppmTaskId,
            ppmTaskScheduleDate: ppmTaskScheduleDate,
            assetId: assetId,
            assetGroupName: assetGroupName,
            assetCategoryName: assetCategoryName,
            assetTypeName: assetTypeName,
            assetBrandName: assetBrandName,
            assetModelName: assetModelName,
            assetNo: assetNo,
            assetName: assetName,
            locationCodeId: locationCodeId,
            assetCapacity: assetCapacity,
            ppmTaskTimeStart: ppmTaskTimeStart,
            ppmTaskTimeServiced: ppmTaskTimeServiced);
    replace(_$result);
    return _$result;
  }
}

class _$FormBItem extends FormBItem {
  @override
  final String ppmTaskId;
  @override
  final String ppmTaskGuideline;

  factory _$FormBItem([void Function(FormBItemBuilder) updates]) =>
      (new FormBItemBuilder()..update(updates)).build();

  _$FormBItem._({this.ppmTaskId, this.ppmTaskGuideline}) : super._() {
    if (ppmTaskId == null) {
      throw new BuiltValueNullFieldError('FormBItem', 'ppmTaskId');
    }
    if (ppmTaskGuideline == null) {
      throw new BuiltValueNullFieldError('FormBItem', 'ppmTaskGuideline');
    }
  }

  @override
  FormBItem rebuild(void Function(FormBItemBuilder) updates) =>
      (toBuilder()..update(updates)).build();

  @override
  FormBItemBuilder toBuilder() => new FormBItemBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is FormBItem &&
        ppmTaskId == other.ppmTaskId &&
        ppmTaskGuideline == other.ppmTaskGuideline;
  }

  @override
  int get hashCode {
    return $jf($jc($jc(0, ppmTaskId.hashCode), ppmTaskGuideline.hashCode));
  }

  @override
  String toString() {
    return (newBuiltValueToStringHelper('FormBItem')
          ..add('ppmTaskId', ppmTaskId)
          ..add('ppmTaskGuideline', ppmTaskGuideline))
        .toString();
  }
}

class FormBItemBuilder implements Builder<FormBItem, FormBItemBuilder> {
  _$FormBItem _$v;

  String _ppmTaskId;
  String get ppmTaskId => _$this._ppmTaskId;
  set ppmTaskId(String ppmTaskId) => _$this._ppmTaskId = ppmTaskId;

  String _ppmTaskGuideline;
  String get ppmTaskGuideline => _$this._ppmTaskGuideline;
  set ppmTaskGuideline(String ppmTaskGuideline) =>
      _$this._ppmTaskGuideline = ppmTaskGuideline;

  FormBItemBuilder();

  FormBItemBuilder get _$this {
    if (_$v != null) {
      _ppmTaskId = _$v.ppmTaskId;
      _ppmTaskGuideline = _$v.ppmTaskGuideline;
      _$v = null;
    }
    return this;
  }

  @override
  void replace(FormBItem other) {
    if (other == null) {
      throw new ArgumentError.notNull('other');
    }
    _$v = other as _$FormBItem;
  }

  @override
  void update(void Function(FormBItemBuilder) updates) {
    if (updates != null) updates(this);
  }

  @override
  _$FormBItem build() {
    final _$result = _$v ??
        new _$FormBItem._(
            ppmTaskId: ppmTaskId, ppmTaskGuideline: ppmTaskGuideline);
    replace(_$result);
    return _$result;
  }
}

class _$FormCItem extends FormCItem {
  @override
  final String ppmTaskQualId;
  @override
  final String ppmTaskId;
  @override
  final String ppmTaskQualNumb;
  @override
  final String ppmTaskQualDesc;
  @override
  final String frequencyId;
  @override
  final String frequencyName;
  @override
  final String ppmTaskQualResult;
  @override
  final String ppmTaskQualRemark;

  factory _$FormCItem([void Function(FormCItemBuilder) updates]) =>
      (new FormCItemBuilder()..update(updates)).build();

  _$FormCItem._(
      {this.ppmTaskQualId,
      this.ppmTaskId,
      this.ppmTaskQualNumb,
      this.ppmTaskQualDesc,
      this.frequencyId,
      this.frequencyName,
      this.ppmTaskQualResult,
      this.ppmTaskQualRemark})
      : super._() {
    if (ppmTaskQualId == null) {
      throw new BuiltValueNullFieldError('FormCItem', 'ppmTaskQualId');
    }
    if (ppmTaskId == null) {
      throw new BuiltValueNullFieldError('FormCItem', 'ppmTaskId');
    }
    if (ppmTaskQualNumb == null) {
      throw new BuiltValueNullFieldError('FormCItem', 'ppmTaskQualNumb');
    }
    if (ppmTaskQualDesc == null) {
      throw new BuiltValueNullFieldError('FormCItem', 'ppmTaskQualDesc');
    }
    if (frequencyId == null) {
      throw new BuiltValueNullFieldError('FormCItem', 'frequencyId');
    }
    if (frequencyName == null) {
      throw new BuiltValueNullFieldError('FormCItem', 'frequencyName');
    }
    if (ppmTaskQualResult == null) {
      throw new BuiltValueNullFieldError('FormCItem', 'ppmTaskQualResult');
    }
    if (ppmTaskQualRemark == null) {
      throw new BuiltValueNullFieldError('FormCItem', 'ppmTaskQualRemark');
    }
  }

  @override
  FormCItem rebuild(void Function(FormCItemBuilder) updates) =>
      (toBuilder()..update(updates)).build();

  @override
  FormCItemBuilder toBuilder() => new FormCItemBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is FormCItem &&
        ppmTaskQualId == other.ppmTaskQualId &&
        ppmTaskId == other.ppmTaskId &&
        ppmTaskQualNumb == other.ppmTaskQualNumb &&
        ppmTaskQualDesc == other.ppmTaskQualDesc &&
        frequencyId == other.frequencyId &&
        frequencyName == other.frequencyName &&
        ppmTaskQualResult == other.ppmTaskQualResult &&
        ppmTaskQualRemark == other.ppmTaskQualRemark;
  }

  @override
  int get hashCode {
    return $jf($jc(
        $jc(
            $jc(
                $jc(
                    $jc(
                        $jc(
                            $jc($jc(0, ppmTaskQualId.hashCode),
                                ppmTaskId.hashCode),
                            ppmTaskQualNumb.hashCode),
                        ppmTaskQualDesc.hashCode),
                    frequencyId.hashCode),
                frequencyName.hashCode),
            ppmTaskQualResult.hashCode),
        ppmTaskQualRemark.hashCode));
  }

  @override
  String toString() {
    return (newBuiltValueToStringHelper('FormCItem')
          ..add('ppmTaskQualId', ppmTaskQualId)
          ..add('ppmTaskId', ppmTaskId)
          ..add('ppmTaskQualNumb', ppmTaskQualNumb)
          ..add('ppmTaskQualDesc', ppmTaskQualDesc)
          ..add('frequencyId', frequencyId)
          ..add('frequencyName', frequencyName)
          ..add('ppmTaskQualResult', ppmTaskQualResult)
          ..add('ppmTaskQualRemark', ppmTaskQualRemark))
        .toString();
  }
}

class FormCItemBuilder implements Builder<FormCItem, FormCItemBuilder> {
  _$FormCItem _$v;

  String _ppmTaskQualId;
  String get ppmTaskQualId => _$this._ppmTaskQualId;
  set ppmTaskQualId(String ppmTaskQualId) =>
      _$this._ppmTaskQualId = ppmTaskQualId;

  String _ppmTaskId;
  String get ppmTaskId => _$this._ppmTaskId;
  set ppmTaskId(String ppmTaskId) => _$this._ppmTaskId = ppmTaskId;

  String _ppmTaskQualNumb;
  String get ppmTaskQualNumb => _$this._ppmTaskQualNumb;
  set ppmTaskQualNumb(String ppmTaskQualNumb) =>
      _$this._ppmTaskQualNumb = ppmTaskQualNumb;

  String _ppmTaskQualDesc;
  String get ppmTaskQualDesc => _$this._ppmTaskQualDesc;
  set ppmTaskQualDesc(String ppmTaskQualDesc) =>
      _$this._ppmTaskQualDesc = ppmTaskQualDesc;

  String _frequencyId;
  String get frequencyId => _$this._frequencyId;
  set frequencyId(String frequencyId) => _$this._frequencyId = frequencyId;

  String _frequencyName;
  String get frequencyName => _$this._frequencyName;
  set frequencyName(String frequencyName) =>
      _$this._frequencyName = frequencyName;

  String _ppmTaskQualResult;
  String get ppmTaskQualResult => _$this._ppmTaskQualResult;
  set ppmTaskQualResult(String ppmTaskQualResult) =>
      _$this._ppmTaskQualResult = ppmTaskQualResult;

  String _ppmTaskQualRemark;
  String get ppmTaskQualRemark => _$this._ppmTaskQualRemark;
  set ppmTaskQualRemark(String ppmTaskQualRemark) =>
      _$this._ppmTaskQualRemark = ppmTaskQualRemark;

  FormCItemBuilder();

  FormCItemBuilder get _$this {
    if (_$v != null) {
      _ppmTaskQualId = _$v.ppmTaskQualId;
      _ppmTaskId = _$v.ppmTaskId;
      _ppmTaskQualNumb = _$v.ppmTaskQualNumb;
      _ppmTaskQualDesc = _$v.ppmTaskQualDesc;
      _frequencyId = _$v.frequencyId;
      _frequencyName = _$v.frequencyName;
      _ppmTaskQualResult = _$v.ppmTaskQualResult;
      _ppmTaskQualRemark = _$v.ppmTaskQualRemark;
      _$v = null;
    }
    return this;
  }

  @override
  void replace(FormCItem other) {
    if (other == null) {
      throw new ArgumentError.notNull('other');
    }
    _$v = other as _$FormCItem;
  }

  @override
  void update(void Function(FormCItemBuilder) updates) {
    if (updates != null) updates(this);
  }

  @override
  _$FormCItem build() {
    final _$result = _$v ??
        new _$FormCItem._(
            ppmTaskQualId: ppmTaskQualId,
            ppmTaskId: ppmTaskId,
            ppmTaskQualNumb: ppmTaskQualNumb,
            ppmTaskQualDesc: ppmTaskQualDesc,
            frequencyId: frequencyId,
            frequencyName: frequencyName,
            ppmTaskQualResult: ppmTaskQualResult,
            ppmTaskQualRemark: ppmTaskQualRemark);
    replace(_$result);
    return _$result;
  }
}

class _$FormDItem extends FormDItem {
  @override
  final String ppmTaskQuanId;
  @override
  final String ppmTaskId;
  @override
  final String ppmTaskQuanNumb;
  @override
  final String ppmTaskQuanDesc;
  @override
  final String frequencyId;
  @override
  final String frequencyName;
  @override
  final String ppmTaskQuanUnit;
  @override
  final String ppmTaskQuanSetValues;
  @override
  final String ppmTaskQuanMeasuredValues;
  @override
  final String ppmTaskQuanLimit;
  @override
  final String ppmTaskQuanResult;
  @override
  final String ppmTaskQuanRemark;

  factory _$FormDItem([void Function(FormDItemBuilder) updates]) =>
      (new FormDItemBuilder()..update(updates)).build();

  _$FormDItem._(
      {this.ppmTaskQuanId,
      this.ppmTaskId,
      this.ppmTaskQuanNumb,
      this.ppmTaskQuanDesc,
      this.frequencyId,
      this.frequencyName,
      this.ppmTaskQuanUnit,
      this.ppmTaskQuanSetValues,
      this.ppmTaskQuanMeasuredValues,
      this.ppmTaskQuanLimit,
      this.ppmTaskQuanResult,
      this.ppmTaskQuanRemark})
      : super._() {
    if (ppmTaskQuanId == null) {
      throw new BuiltValueNullFieldError('FormDItem', 'ppmTaskQuanId');
    }
    if (ppmTaskId == null) {
      throw new BuiltValueNullFieldError('FormDItem', 'ppmTaskId');
    }
    if (ppmTaskQuanNumb == null) {
      throw new BuiltValueNullFieldError('FormDItem', 'ppmTaskQuanNumb');
    }
    if (ppmTaskQuanDesc == null) {
      throw new BuiltValueNullFieldError('FormDItem', 'ppmTaskQuanDesc');
    }
    if (frequencyId == null) {
      throw new BuiltValueNullFieldError('FormDItem', 'frequencyId');
    }
    if (frequencyName == null) {
      throw new BuiltValueNullFieldError('FormDItem', 'frequencyName');
    }
    if (ppmTaskQuanUnit == null) {
      throw new BuiltValueNullFieldError('FormDItem', 'ppmTaskQuanUnit');
    }
    if (ppmTaskQuanSetValues == null) {
      throw new BuiltValueNullFieldError('FormDItem', 'ppmTaskQuanSetValues');
    }
    if (ppmTaskQuanMeasuredValues == null) {
      throw new BuiltValueNullFieldError(
          'FormDItem', 'ppmTaskQuanMeasuredValues');
    }
    if (ppmTaskQuanLimit == null) {
      throw new BuiltValueNullFieldError('FormDItem', 'ppmTaskQuanLimit');
    }
    if (ppmTaskQuanResult == null) {
      throw new BuiltValueNullFieldError('FormDItem', 'ppmTaskQuanResult');
    }
    if (ppmTaskQuanRemark == null) {
      throw new BuiltValueNullFieldError('FormDItem', 'ppmTaskQuanRemark');
    }
  }

  @override
  FormDItem rebuild(void Function(FormDItemBuilder) updates) =>
      (toBuilder()..update(updates)).build();

  @override
  FormDItemBuilder toBuilder() => new FormDItemBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is FormDItem &&
        ppmTaskQuanId == other.ppmTaskQuanId &&
        ppmTaskId == other.ppmTaskId &&
        ppmTaskQuanNumb == other.ppmTaskQuanNumb &&
        ppmTaskQuanDesc == other.ppmTaskQuanDesc &&
        frequencyId == other.frequencyId &&
        frequencyName == other.frequencyName &&
        ppmTaskQuanUnit == other.ppmTaskQuanUnit &&
        ppmTaskQuanSetValues == other.ppmTaskQuanSetValues &&
        ppmTaskQuanMeasuredValues == other.ppmTaskQuanMeasuredValues &&
        ppmTaskQuanLimit == other.ppmTaskQuanLimit &&
        ppmTaskQuanResult == other.ppmTaskQuanResult &&
        ppmTaskQuanRemark == other.ppmTaskQuanRemark;
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
                                            $jc($jc(0, ppmTaskQuanId.hashCode),
                                                ppmTaskId.hashCode),
                                            ppmTaskQuanNumb.hashCode),
                                        ppmTaskQuanDesc.hashCode),
                                    frequencyId.hashCode),
                                frequencyName.hashCode),
                            ppmTaskQuanUnit.hashCode),
                        ppmTaskQuanSetValues.hashCode),
                    ppmTaskQuanMeasuredValues.hashCode),
                ppmTaskQuanLimit.hashCode),
            ppmTaskQuanResult.hashCode),
        ppmTaskQuanRemark.hashCode));
  }

  @override
  String toString() {
    return (newBuiltValueToStringHelper('FormDItem')
          ..add('ppmTaskQuanId', ppmTaskQuanId)
          ..add('ppmTaskId', ppmTaskId)
          ..add('ppmTaskQuanNumb', ppmTaskQuanNumb)
          ..add('ppmTaskQuanDesc', ppmTaskQuanDesc)
          ..add('frequencyId', frequencyId)
          ..add('frequencyName', frequencyName)
          ..add('ppmTaskQuanUnit', ppmTaskQuanUnit)
          ..add('ppmTaskQuanSetValues', ppmTaskQuanSetValues)
          ..add('ppmTaskQuanMeasuredValues', ppmTaskQuanMeasuredValues)
          ..add('ppmTaskQuanLimit', ppmTaskQuanLimit)
          ..add('ppmTaskQuanResult', ppmTaskQuanResult)
          ..add('ppmTaskQuanRemark', ppmTaskQuanRemark))
        .toString();
  }
}

class FormDItemBuilder implements Builder<FormDItem, FormDItemBuilder> {
  _$FormDItem _$v;

  String _ppmTaskQuanId;
  String get ppmTaskQuanId => _$this._ppmTaskQuanId;
  set ppmTaskQuanId(String ppmTaskQuanId) =>
      _$this._ppmTaskQuanId = ppmTaskQuanId;

  String _ppmTaskId;
  String get ppmTaskId => _$this._ppmTaskId;
  set ppmTaskId(String ppmTaskId) => _$this._ppmTaskId = ppmTaskId;

  String _ppmTaskQuanNumb;
  String get ppmTaskQuanNumb => _$this._ppmTaskQuanNumb;
  set ppmTaskQuanNumb(String ppmTaskQuanNumb) =>
      _$this._ppmTaskQuanNumb = ppmTaskQuanNumb;

  String _ppmTaskQuanDesc;
  String get ppmTaskQuanDesc => _$this._ppmTaskQuanDesc;
  set ppmTaskQuanDesc(String ppmTaskQuanDesc) =>
      _$this._ppmTaskQuanDesc = ppmTaskQuanDesc;

  String _frequencyId;
  String get frequencyId => _$this._frequencyId;
  set frequencyId(String frequencyId) => _$this._frequencyId = frequencyId;

  String _frequencyName;
  String get frequencyName => _$this._frequencyName;
  set frequencyName(String frequencyName) =>
      _$this._frequencyName = frequencyName;

  String _ppmTaskQuanUnit;
  String get ppmTaskQuanUnit => _$this._ppmTaskQuanUnit;
  set ppmTaskQuanUnit(String ppmTaskQuanUnit) =>
      _$this._ppmTaskQuanUnit = ppmTaskQuanUnit;

  String _ppmTaskQuanSetValues;
  String get ppmTaskQuanSetValues => _$this._ppmTaskQuanSetValues;
  set ppmTaskQuanSetValues(String ppmTaskQuanSetValues) =>
      _$this._ppmTaskQuanSetValues = ppmTaskQuanSetValues;

  String _ppmTaskQuanMeasuredValues;
  String get ppmTaskQuanMeasuredValues => _$this._ppmTaskQuanMeasuredValues;
  set ppmTaskQuanMeasuredValues(String ppmTaskQuanMeasuredValues) =>
      _$this._ppmTaskQuanMeasuredValues = ppmTaskQuanMeasuredValues;

  String _ppmTaskQuanLimit;
  String get ppmTaskQuanLimit => _$this._ppmTaskQuanLimit;
  set ppmTaskQuanLimit(String ppmTaskQuanLimit) =>
      _$this._ppmTaskQuanLimit = ppmTaskQuanLimit;

  String _ppmTaskQuanResult;
  String get ppmTaskQuanResult => _$this._ppmTaskQuanResult;
  set ppmTaskQuanResult(String ppmTaskQuanResult) =>
      _$this._ppmTaskQuanResult = ppmTaskQuanResult;

  String _ppmTaskQuanRemark;
  String get ppmTaskQuanRemark => _$this._ppmTaskQuanRemark;
  set ppmTaskQuanRemark(String ppmTaskQuanRemark) =>
      _$this._ppmTaskQuanRemark = ppmTaskQuanRemark;

  FormDItemBuilder();

  FormDItemBuilder get _$this {
    if (_$v != null) {
      _ppmTaskQuanId = _$v.ppmTaskQuanId;
      _ppmTaskId = _$v.ppmTaskId;
      _ppmTaskQuanNumb = _$v.ppmTaskQuanNumb;
      _ppmTaskQuanDesc = _$v.ppmTaskQuanDesc;
      _frequencyId = _$v.frequencyId;
      _frequencyName = _$v.frequencyName;
      _ppmTaskQuanUnit = _$v.ppmTaskQuanUnit;
      _ppmTaskQuanSetValues = _$v.ppmTaskQuanSetValues;
      _ppmTaskQuanMeasuredValues = _$v.ppmTaskQuanMeasuredValues;
      _ppmTaskQuanLimit = _$v.ppmTaskQuanLimit;
      _ppmTaskQuanResult = _$v.ppmTaskQuanResult;
      _ppmTaskQuanRemark = _$v.ppmTaskQuanRemark;
      _$v = null;
    }
    return this;
  }

  @override
  void replace(FormDItem other) {
    if (other == null) {
      throw new ArgumentError.notNull('other');
    }
    _$v = other as _$FormDItem;
  }

  @override
  void update(void Function(FormDItemBuilder) updates) {
    if (updates != null) updates(this);
  }

  @override
  _$FormDItem build() {
    final _$result = _$v ??
        new _$FormDItem._(
            ppmTaskQuanId: ppmTaskQuanId,
            ppmTaskId: ppmTaskId,
            ppmTaskQuanNumb: ppmTaskQuanNumb,
            ppmTaskQuanDesc: ppmTaskQuanDesc,
            frequencyId: frequencyId,
            frequencyName: frequencyName,
            ppmTaskQuanUnit: ppmTaskQuanUnit,
            ppmTaskQuanSetValues: ppmTaskQuanSetValues,
            ppmTaskQuanMeasuredValues: ppmTaskQuanMeasuredValues,
            ppmTaskQuanLimit: ppmTaskQuanLimit,
            ppmTaskQuanResult: ppmTaskQuanResult,
            ppmTaskQuanRemark: ppmTaskQuanRemark);
    replace(_$result);
    return _$result;
  }
}

class _$FormEItem extends FormEItem {
  @override
  final String ppmTaskPartsId;
  @override
  final String ppmTaskId;
  @override
  final String ppmTaskPartsDesc;

  factory _$FormEItem([void Function(FormEItemBuilder) updates]) =>
      (new FormEItemBuilder()..update(updates)).build();

  _$FormEItem._({this.ppmTaskPartsId, this.ppmTaskId, this.ppmTaskPartsDesc})
      : super._() {
    if (ppmTaskPartsId == null) {
      throw new BuiltValueNullFieldError('FormEItem', 'ppmTaskPartsId');
    }
    if (ppmTaskId == null) {
      throw new BuiltValueNullFieldError('FormEItem', 'ppmTaskId');
    }
    if (ppmTaskPartsDesc == null) {
      throw new BuiltValueNullFieldError('FormEItem', 'ppmTaskPartsDesc');
    }
  }

  @override
  FormEItem rebuild(void Function(FormEItemBuilder) updates) =>
      (toBuilder()..update(updates)).build();

  @override
  FormEItemBuilder toBuilder() => new FormEItemBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is FormEItem &&
        ppmTaskPartsId == other.ppmTaskPartsId &&
        ppmTaskId == other.ppmTaskId &&
        ppmTaskPartsDesc == other.ppmTaskPartsDesc;
  }

  @override
  int get hashCode {
    return $jf($jc($jc($jc(0, ppmTaskPartsId.hashCode), ppmTaskId.hashCode),
        ppmTaskPartsDesc.hashCode));
  }

  @override
  String toString() {
    return (newBuiltValueToStringHelper('FormEItem')
          ..add('ppmTaskPartsId', ppmTaskPartsId)
          ..add('ppmTaskId', ppmTaskId)
          ..add('ppmTaskPartsDesc', ppmTaskPartsDesc))
        .toString();
  }
}

class FormEItemBuilder implements Builder<FormEItem, FormEItemBuilder> {
  _$FormEItem _$v;

  String _ppmTaskPartsId;
  String get ppmTaskPartsId => _$this._ppmTaskPartsId;
  set ppmTaskPartsId(String ppmTaskPartsId) =>
      _$this._ppmTaskPartsId = ppmTaskPartsId;

  String _ppmTaskId;
  String get ppmTaskId => _$this._ppmTaskId;
  set ppmTaskId(String ppmTaskId) => _$this._ppmTaskId = ppmTaskId;

  String _ppmTaskPartsDesc;
  String get ppmTaskPartsDesc => _$this._ppmTaskPartsDesc;
  set ppmTaskPartsDesc(String ppmTaskPartsDesc) =>
      _$this._ppmTaskPartsDesc = ppmTaskPartsDesc;

  FormEItemBuilder();

  FormEItemBuilder get _$this {
    if (_$v != null) {
      _ppmTaskPartsId = _$v.ppmTaskPartsId;
      _ppmTaskId = _$v.ppmTaskId;
      _ppmTaskPartsDesc = _$v.ppmTaskPartsDesc;
      _$v = null;
    }
    return this;
  }

  @override
  void replace(FormEItem other) {
    if (other == null) {
      throw new ArgumentError.notNull('other');
    }
    _$v = other as _$FormEItem;
  }

  @override
  void update(void Function(FormEItemBuilder) updates) {
    if (updates != null) updates(this);
  }

  @override
  _$FormEItem build() {
    final _$result = _$v ??
        new _$FormEItem._(
            ppmTaskPartsId: ppmTaskPartsId,
            ppmTaskId: ppmTaskId,
            ppmTaskPartsDesc: ppmTaskPartsDesc);
    replace(_$result);
    return _$result;
  }
}

class _$FormFItem extends FormFItem {
  @override
  final String ppmTaskUploadId;
  @override
  final String ppmTaskUploadType;
  @override
  final String ppmTaskId;
  @override
  final String uploadId;
  @override
  final String uploadName;
  @override
  final String documentDesc;
  @override
  final String documentFilename;
  @override
  final String documentSrc;

  factory _$FormFItem([void Function(FormFItemBuilder) updates]) =>
      (new FormFItemBuilder()..update(updates)).build();

  _$FormFItem._(
      {this.ppmTaskUploadId,
      this.ppmTaskUploadType,
      this.ppmTaskId,
      this.uploadId,
      this.uploadName,
      this.documentDesc,
      this.documentFilename,
      this.documentSrc})
      : super._() {
    if (ppmTaskUploadId == null) {
      throw new BuiltValueNullFieldError('FormFItem', 'ppmTaskUploadId');
    }
    if (ppmTaskUploadType == null) {
      throw new BuiltValueNullFieldError('FormFItem', 'ppmTaskUploadType');
    }
    if (ppmTaskId == null) {
      throw new BuiltValueNullFieldError('FormFItem', 'ppmTaskId');
    }
    if (uploadId == null) {
      throw new BuiltValueNullFieldError('FormFItem', 'uploadId');
    }
    if (uploadName == null) {
      throw new BuiltValueNullFieldError('FormFItem', 'uploadName');
    }
    if (documentDesc == null) {
      throw new BuiltValueNullFieldError('FormFItem', 'documentDesc');
    }
    if (documentFilename == null) {
      throw new BuiltValueNullFieldError('FormFItem', 'documentFilename');
    }
    if (documentSrc == null) {
      throw new BuiltValueNullFieldError('FormFItem', 'documentSrc');
    }
  }

  @override
  FormFItem rebuild(void Function(FormFItemBuilder) updates) =>
      (toBuilder()..update(updates)).build();

  @override
  FormFItemBuilder toBuilder() => new FormFItemBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is FormFItem &&
        ppmTaskUploadId == other.ppmTaskUploadId &&
        ppmTaskUploadType == other.ppmTaskUploadType &&
        ppmTaskId == other.ppmTaskId &&
        uploadId == other.uploadId &&
        uploadName == other.uploadName &&
        documentDesc == other.documentDesc &&
        documentFilename == other.documentFilename &&
        documentSrc == other.documentSrc;
  }

  @override
  int get hashCode {
    return $jf($jc(
        $jc(
            $jc(
                $jc(
                    $jc(
                        $jc(
                            $jc($jc(0, ppmTaskUploadId.hashCode),
                                ppmTaskUploadType.hashCode),
                            ppmTaskId.hashCode),
                        uploadId.hashCode),
                    uploadName.hashCode),
                documentDesc.hashCode),
            documentFilename.hashCode),
        documentSrc.hashCode));
  }

  @override
  String toString() {
    return (newBuiltValueToStringHelper('FormFItem')
          ..add('ppmTaskUploadId', ppmTaskUploadId)
          ..add('ppmTaskUploadType', ppmTaskUploadType)
          ..add('ppmTaskId', ppmTaskId)
          ..add('uploadId', uploadId)
          ..add('uploadName', uploadName)
          ..add('documentDesc', documentDesc)
          ..add('documentFilename', documentFilename)
          ..add('documentSrc', documentSrc))
        .toString();
  }
}

class FormFItemBuilder implements Builder<FormFItem, FormFItemBuilder> {
  _$FormFItem _$v;

  String _ppmTaskUploadId;
  String get ppmTaskUploadId => _$this._ppmTaskUploadId;
  set ppmTaskUploadId(String ppmTaskUploadId) =>
      _$this._ppmTaskUploadId = ppmTaskUploadId;

  String _ppmTaskUploadType;
  String get ppmTaskUploadType => _$this._ppmTaskUploadType;
  set ppmTaskUploadType(String ppmTaskUploadType) =>
      _$this._ppmTaskUploadType = ppmTaskUploadType;

  String _ppmTaskId;
  String get ppmTaskId => _$this._ppmTaskId;
  set ppmTaskId(String ppmTaskId) => _$this._ppmTaskId = ppmTaskId;

  String _uploadId;
  String get uploadId => _$this._uploadId;
  set uploadId(String uploadId) => _$this._uploadId = uploadId;

  String _uploadName;
  String get uploadName => _$this._uploadName;
  set uploadName(String uploadName) => _$this._uploadName = uploadName;

  String _documentDesc;
  String get documentDesc => _$this._documentDesc;
  set documentDesc(String documentDesc) => _$this._documentDesc = documentDesc;

  String _documentFilename;
  String get documentFilename => _$this._documentFilename;
  set documentFilename(String documentFilename) =>
      _$this._documentFilename = documentFilename;

  String _documentSrc;
  String get documentSrc => _$this._documentSrc;
  set documentSrc(String documentSrc) => _$this._documentSrc = documentSrc;

  FormFItemBuilder();

  FormFItemBuilder get _$this {
    if (_$v != null) {
      _ppmTaskUploadId = _$v.ppmTaskUploadId;
      _ppmTaskUploadType = _$v.ppmTaskUploadType;
      _ppmTaskId = _$v.ppmTaskId;
      _uploadId = _$v.uploadId;
      _uploadName = _$v.uploadName;
      _documentDesc = _$v.documentDesc;
      _documentFilename = _$v.documentFilename;
      _documentSrc = _$v.documentSrc;
      _$v = null;
    }
    return this;
  }

  @override
  void replace(FormFItem other) {
    if (other == null) {
      throw new ArgumentError.notNull('other');
    }
    _$v = other as _$FormFItem;
  }

  @override
  void update(void Function(FormFItemBuilder) updates) {
    if (updates != null) updates(this);
  }

  @override
  _$FormFItem build() {
    final _$result = _$v ??
        new _$FormFItem._(
            ppmTaskUploadId: ppmTaskUploadId,
            ppmTaskUploadType: ppmTaskUploadType,
            ppmTaskId: ppmTaskId,
            uploadId: uploadId,
            uploadName: uploadName,
            documentDesc: documentDesc,
            documentFilename: documentFilename,
            documentSrc: documentSrc);
    replace(_$result);
    return _$result;
  }
}

class _$FormGItem extends FormGItem {
  @override
  final String ppmTaskId;
  @override
  final String ppmTaskRemark;

  factory _$FormGItem([void Function(FormGItemBuilder) updates]) =>
      (new FormGItemBuilder()..update(updates)).build();

  _$FormGItem._({this.ppmTaskId, this.ppmTaskRemark}) : super._() {
    if (ppmTaskId == null) {
      throw new BuiltValueNullFieldError('FormGItem', 'ppmTaskId');
    }
    if (ppmTaskRemark == null) {
      throw new BuiltValueNullFieldError('FormGItem', 'ppmTaskRemark');
    }
  }

  @override
  FormGItem rebuild(void Function(FormGItemBuilder) updates) =>
      (toBuilder()..update(updates)).build();

  @override
  FormGItemBuilder toBuilder() => new FormGItemBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is FormGItem &&
        ppmTaskId == other.ppmTaskId &&
        ppmTaskRemark == other.ppmTaskRemark;
  }

  @override
  int get hashCode {
    return $jf($jc($jc(0, ppmTaskId.hashCode), ppmTaskRemark.hashCode));
  }

  @override
  String toString() {
    return (newBuiltValueToStringHelper('FormGItem')
          ..add('ppmTaskId', ppmTaskId)
          ..add('ppmTaskRemark', ppmTaskRemark))
        .toString();
  }
}

class FormGItemBuilder implements Builder<FormGItem, FormGItemBuilder> {
  _$FormGItem _$v;

  String _ppmTaskId;
  String get ppmTaskId => _$this._ppmTaskId;
  set ppmTaskId(String ppmTaskId) => _$this._ppmTaskId = ppmTaskId;

  String _ppmTaskRemark;
  String get ppmTaskRemark => _$this._ppmTaskRemark;
  set ppmTaskRemark(String ppmTaskRemark) =>
      _$this._ppmTaskRemark = ppmTaskRemark;

  FormGItemBuilder();

  FormGItemBuilder get _$this {
    if (_$v != null) {
      _ppmTaskId = _$v.ppmTaskId;
      _ppmTaskRemark = _$v.ppmTaskRemark;
      _$v = null;
    }
    return this;
  }

  @override
  void replace(FormGItem other) {
    if (other == null) {
      throw new ArgumentError.notNull('other');
    }
    _$v = other as _$FormGItem;
  }

  @override
  void update(void Function(FormGItemBuilder) updates) {
    if (updates != null) updates(this);
  }

  @override
  _$FormGItem build() {
    final _$result = _$v ??
        new _$FormGItem._(ppmTaskId: ppmTaskId, ppmTaskRemark: ppmTaskRemark);
    replace(_$result);
    return _$result;
  }
}

class _$FormHItem extends FormHItem {
  @override
  final String ppmTaskUploadId;
  @override
  final String ppmTaskUploadType;
  @override
  final String ppmTaskUploadLongitude;
  @override
  final String ppmTaskUploadLatitude;
  @override
  final String ppmTaskUploadTimestamp;
  @override
  final String ppmTaskUploadDesc;
  @override
  final String ppmTaskId;
  @override
  final String uploadId;
  @override
  final String uploadName;
  @override
  final String documentDesc;
  @override
  final String documentFilename;
  @override
  final String documentSrc;

  factory _$FormHItem([void Function(FormHItemBuilder) updates]) =>
      (new FormHItemBuilder()..update(updates)).build();

  _$FormHItem._(
      {this.ppmTaskUploadId,
      this.ppmTaskUploadType,
      this.ppmTaskUploadLongitude,
      this.ppmTaskUploadLatitude,
      this.ppmTaskUploadTimestamp,
      this.ppmTaskUploadDesc,
      this.ppmTaskId,
      this.uploadId,
      this.uploadName,
      this.documentDesc,
      this.documentFilename,
      this.documentSrc})
      : super._() {
    if (ppmTaskUploadId == null) {
      throw new BuiltValueNullFieldError('FormHItem', 'ppmTaskUploadId');
    }
    if (ppmTaskUploadType == null) {
      throw new BuiltValueNullFieldError('FormHItem', 'ppmTaskUploadType');
    }
    if (ppmTaskUploadLongitude == null) {
      throw new BuiltValueNullFieldError('FormHItem', 'ppmTaskUploadLongitude');
    }
    if (ppmTaskUploadLatitude == null) {
      throw new BuiltValueNullFieldError('FormHItem', 'ppmTaskUploadLatitude');
    }
    if (ppmTaskUploadTimestamp == null) {
      throw new BuiltValueNullFieldError('FormHItem', 'ppmTaskUploadTimestamp');
    }
    if (ppmTaskUploadDesc == null) {
      throw new BuiltValueNullFieldError('FormHItem', 'ppmTaskUploadDesc');
    }
    if (ppmTaskId == null) {
      throw new BuiltValueNullFieldError('FormHItem', 'ppmTaskId');
    }
    if (uploadName == null) {
      throw new BuiltValueNullFieldError('FormHItem', 'uploadName');
    }
    if (documentDesc == null) {
      throw new BuiltValueNullFieldError('FormHItem', 'documentDesc');
    }
    if (documentFilename == null) {
      throw new BuiltValueNullFieldError('FormHItem', 'documentFilename');
    }
    if (documentSrc == null) {
      throw new BuiltValueNullFieldError('FormHItem', 'documentSrc');
    }
  }

  @override
  FormHItem rebuild(void Function(FormHItemBuilder) updates) =>
      (toBuilder()..update(updates)).build();

  @override
  FormHItemBuilder toBuilder() => new FormHItemBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is FormHItem &&
        ppmTaskUploadId == other.ppmTaskUploadId &&
        ppmTaskUploadType == other.ppmTaskUploadType &&
        ppmTaskUploadLongitude == other.ppmTaskUploadLongitude &&
        ppmTaskUploadLatitude == other.ppmTaskUploadLatitude &&
        ppmTaskUploadTimestamp == other.ppmTaskUploadTimestamp &&
        ppmTaskUploadDesc == other.ppmTaskUploadDesc &&
        ppmTaskId == other.ppmTaskId &&
        uploadId == other.uploadId &&
        uploadName == other.uploadName &&
        documentDesc == other.documentDesc &&
        documentFilename == other.documentFilename &&
        documentSrc == other.documentSrc;
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
                                                $jc(0,
                                                    ppmTaskUploadId.hashCode),
                                                ppmTaskUploadType.hashCode),
                                            ppmTaskUploadLongitude.hashCode),
                                        ppmTaskUploadLatitude.hashCode),
                                    ppmTaskUploadTimestamp.hashCode),
                                ppmTaskUploadDesc.hashCode),
                            ppmTaskId.hashCode),
                        uploadId.hashCode),
                    uploadName.hashCode),
                documentDesc.hashCode),
            documentFilename.hashCode),
        documentSrc.hashCode));
  }

  @override
  String toString() {
    return (newBuiltValueToStringHelper('FormHItem')
          ..add('ppmTaskUploadId', ppmTaskUploadId)
          ..add('ppmTaskUploadType', ppmTaskUploadType)
          ..add('ppmTaskUploadLongitude', ppmTaskUploadLongitude)
          ..add('ppmTaskUploadLatitude', ppmTaskUploadLatitude)
          ..add('ppmTaskUploadTimestamp', ppmTaskUploadTimestamp)
          ..add('ppmTaskUploadDesc', ppmTaskUploadDesc)
          ..add('ppmTaskId', ppmTaskId)
          ..add('uploadId', uploadId)
          ..add('uploadName', uploadName)
          ..add('documentDesc', documentDesc)
          ..add('documentFilename', documentFilename)
          ..add('documentSrc', documentSrc))
        .toString();
  }
}

class FormHItemBuilder implements Builder<FormHItem, FormHItemBuilder> {
  _$FormHItem _$v;

  String _ppmTaskUploadId;
  String get ppmTaskUploadId => _$this._ppmTaskUploadId;
  set ppmTaskUploadId(String ppmTaskUploadId) =>
      _$this._ppmTaskUploadId = ppmTaskUploadId;

  String _ppmTaskUploadType;
  String get ppmTaskUploadType => _$this._ppmTaskUploadType;
  set ppmTaskUploadType(String ppmTaskUploadType) =>
      _$this._ppmTaskUploadType = ppmTaskUploadType;

  String _ppmTaskUploadLongitude;
  String get ppmTaskUploadLongitude => _$this._ppmTaskUploadLongitude;
  set ppmTaskUploadLongitude(String ppmTaskUploadLongitude) =>
      _$this._ppmTaskUploadLongitude = ppmTaskUploadLongitude;

  String _ppmTaskUploadLatitude;
  String get ppmTaskUploadLatitude => _$this._ppmTaskUploadLatitude;
  set ppmTaskUploadLatitude(String ppmTaskUploadLatitude) =>
      _$this._ppmTaskUploadLatitude = ppmTaskUploadLatitude;

  String _ppmTaskUploadTimestamp;
  String get ppmTaskUploadTimestamp => _$this._ppmTaskUploadTimestamp;
  set ppmTaskUploadTimestamp(String ppmTaskUploadTimestamp) =>
      _$this._ppmTaskUploadTimestamp = ppmTaskUploadTimestamp;

  String _ppmTaskUploadDesc;
  String get ppmTaskUploadDesc => _$this._ppmTaskUploadDesc;
  set ppmTaskUploadDesc(String ppmTaskUploadDesc) =>
      _$this._ppmTaskUploadDesc = ppmTaskUploadDesc;

  String _ppmTaskId;
  String get ppmTaskId => _$this._ppmTaskId;
  set ppmTaskId(String ppmTaskId) => _$this._ppmTaskId = ppmTaskId;

  String _uploadId;
  String get uploadId => _$this._uploadId;
  set uploadId(String uploadId) => _$this._uploadId = uploadId;

  String _uploadName;
  String get uploadName => _$this._uploadName;
  set uploadName(String uploadName) => _$this._uploadName = uploadName;

  String _documentDesc;
  String get documentDesc => _$this._documentDesc;
  set documentDesc(String documentDesc) => _$this._documentDesc = documentDesc;

  String _documentFilename;
  String get documentFilename => _$this._documentFilename;
  set documentFilename(String documentFilename) =>
      _$this._documentFilename = documentFilename;

  String _documentSrc;
  String get documentSrc => _$this._documentSrc;
  set documentSrc(String documentSrc) => _$this._documentSrc = documentSrc;

  FormHItemBuilder();

  FormHItemBuilder get _$this {
    if (_$v != null) {
      _ppmTaskUploadId = _$v.ppmTaskUploadId;
      _ppmTaskUploadType = _$v.ppmTaskUploadType;
      _ppmTaskUploadLongitude = _$v.ppmTaskUploadLongitude;
      _ppmTaskUploadLatitude = _$v.ppmTaskUploadLatitude;
      _ppmTaskUploadTimestamp = _$v.ppmTaskUploadTimestamp;
      _ppmTaskUploadDesc = _$v.ppmTaskUploadDesc;
      _ppmTaskId = _$v.ppmTaskId;
      _uploadId = _$v.uploadId;
      _uploadName = _$v.uploadName;
      _documentDesc = _$v.documentDesc;
      _documentFilename = _$v.documentFilename;
      _documentSrc = _$v.documentSrc;
      _$v = null;
    }
    return this;
  }

  @override
  void replace(FormHItem other) {
    if (other == null) {
      throw new ArgumentError.notNull('other');
    }
    _$v = other as _$FormHItem;
  }

  @override
  void update(void Function(FormHItemBuilder) updates) {
    if (updates != null) updates(this);
  }

  @override
  _$FormHItem build() {
    final _$result = _$v ??
        new _$FormHItem._(
            ppmTaskUploadId: ppmTaskUploadId,
            ppmTaskUploadType: ppmTaskUploadType,
            ppmTaskUploadLongitude: ppmTaskUploadLongitude,
            ppmTaskUploadLatitude: ppmTaskUploadLatitude,
            ppmTaskUploadTimestamp: ppmTaskUploadTimestamp,
            ppmTaskUploadDesc: ppmTaskUploadDesc,
            ppmTaskId: ppmTaskId,
            uploadId: uploadId,
            uploadName: uploadName,
            documentDesc: documentDesc,
            documentFilename: documentFilename,
            documentSrc: documentSrc);
    replace(_$result);
    return _$result;
  }
}

// ignore_for_file: always_put_control_body_on_new_line,always_specify_types,annotate_overrides,avoid_annotating_with_dynamic,avoid_as,avoid_catches_without_on_clauses,avoid_returning_this,lines_longer_than_80_chars,omit_local_variable_types,prefer_expression_function_bodies,sort_constructors_first,test_types_in_equals,unnecessary_const,unnecessary_new
