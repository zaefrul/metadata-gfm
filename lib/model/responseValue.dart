library responseValue;

import 'package:built_collection/built_collection.dart';
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';
import 'package:GEMS/model/dot.dart';
import 'package:GEMS/model/form.dart';
import 'package:GEMS/model/task.dart';
import 'package:GEMS/model/workorder.dart';

import 'monitor.dart';

part 'responseValue.g.dart';

abstract class ResponseValue
    implements Built<ResponseValue, ResponseValueBuilder> {
  bool get success;
  String get error;
  String get errmsg;

  String? get result;
  BuiltList<Task>? get taskList;
  BuiltList<WorkOrderTask>? get workorderTask;
  WorkOrderDetail? get woDetail;
  BuiltList<MonitorTask>? get monitorTaskList;
  MonitorDetail? get monitorDetail;
  BuiltList<Dot>? get dotList;
  BuiltList<WorkOrderStatus>? get wostatusList;
  BuiltList<Form>? get statusList;
  FormAItem? get sectionAList;
  FormBItem? get sectionBList;
  BuiltList<FormCItem>? get sectionCList;
  BuiltList<FormDItem>? get sectionDList;
  BuiltList<FormEItem>? get sectionEList;
  BuiltList<FormFItem>? get sectionFList;
  FormGItem? get sectionGList;
  BuiltList<FormHItem>? get sectionHList;
  TechnicianDetails? get technicianDetails;
  TechnicianTask? get technicianTask;
  BuiltList<TechnicianImageRepair>? get technicianImages;
  TechnicianAssign? get technicianAssign;

  @BuiltValueSerializer(custom: true)
  static Serializer<ResponseValue> get serializer => ResponseSerializer();

  ResponseValue._();
  factory ResponseValue([void Function(ResponseValueBuilder) updates]) =
      _$ResponseValue;

  static void _defaultUpdates(ResponseValueBuilder builder) {}
}

class ResponseSerializer implements StructuredSerializer<ResponseValue> {
  @override
  final Iterable<Type> types = const [ResponseValue, _$ResponseValue];
  @override
  final String wireName = "ResponseValue";

  @override
  Iterable<Object?> serialize(Serializers serializers, ResponseValue object,
      {FullType specifiedType = FullType.unspecified}) {
    final result = <Object?>[];

    result
      ..add('values')
      ..add(serializers.serialize(object.taskList,
          specifiedType:
              const FullType(BuiltList, [FullType(Task)])));
    result
      ..add('values')
      ..add(serializers.serialize(object.result,
          specifiedType:
              const FullType(BuiltList, [FullType(String)])));
    return result;
  }

  @override
  ResponseValue deserialize(Serializers serializers, Iterable<Object?> serialized,
      {FullType specifiedType = FullType.unspecified}) {
    final result = ResponseValueBuilder();

    final iterator = serialized.iterator;
    while (iterator.moveNext()) {
      final key = iterator.current as String;
      iterator.moveNext();
      final dynamic value = iterator.current;
      switch (key) {
        case 'success':
          result.success = serializers.deserialize(value,
              specifiedType: const FullType(bool)) as bool;
          break;
        case 'error':
          result.error = serializers.deserialize(value.toString(),
              specifiedType: const FullType(String)) as String;
          break;
        case 'errmsg':
          result.errmsg = serializers.deserialize(value.toString(),
              specifiedType: const FullType(String)) as String;
          break;
        case 'result':
          if (value is Map<String, dynamic>) {
            if (trySectionA(serializers, value)) {
              result.sectionAList.replace(serializers.deserialize(value,
                      specifiedType: const FullType(FormAItem)) as FormAItem);
            } else if (tryWODetail(serializers, value)) {
              result.woDetail.replace(serializers.deserialize(value,
                      specifiedType: const FullType(WorkOrderDetail)) as WorkOrderDetail);
            } else if (tryMonitorDetail(serializers, value)) {
              result.monitorDetail.replace(serializers.deserialize(value,
                      specifiedType: const FullType(MonitorDetail)) as MonitorDetail);
            } else if (trySectionB(serializers, value)) {
              result.sectionBList.replace(serializers.deserialize(value,
                      specifiedType: const FullType(FormBItem)) as FormBItem);
            } else if (trySectionG(serializers, value)) {
              result.sectionGList.replace(serializers.deserialize(value,
                      specifiedType: const FullType(FormGItem)) as FormGItem);
            } else if (tryTechnicianDetails(serializers, value)) {
              result.technicianDetails.replace(serializers.deserialize(value,
                      specifiedType: const FullType(TechnicianDetails))
                  as TechnicianDetails);
            } else if (tryTechnicianTask(serializers, value)) {
              result.technicianTask.replace(serializers.deserialize(value,
                      specifiedType: const FullType(TechnicianTask))
                  as TechnicianTask);
            } else if (tryTechnicianAssign(serializers, value)) {
              result.technicianAssign.replace(serializers.deserialize(value,
                      specifiedType: const FullType(TechnicianAssign))
                  as TechnicianAssign);
            }
          } else if (value is List<dynamic>) {
            if (tryTask(serializers, value)) {
              result.taskList.replace(serializers.deserialize(value,
                      specifiedType: const FullType(
                          BuiltList, [FullType(Task)])) as BuiltList<Task>);
            } else if (tryMonitorTask(serializers, value)) {
              result.monitorTaskList.replace(serializers.deserialize(value,
                      specifiedType: const FullType(
                          BuiltList, [FullType(MonitorTask)])) as BuiltList<MonitorTask>);
            } else if (tryWorkOrderTask(serializers, value)) {
              result.workorderTask.replace(serializers.deserialize(value,
                      specifiedType: const FullType(
                          BuiltList, [FullType(WorkOrderTask)])) as BuiltList<WorkOrderTask>);
            } else if (tryDot(serializers, value)) {
              result.dotList.replace(serializers.deserialize(value,
                      specifiedType: const FullType(
                          BuiltList, [FullType(Dot)])) as BuiltList<Dot>);
            } else if (tryForm(serializers, value)) {
              result.statusList.replace(serializers.deserialize(value,
                      specifiedType: const FullType(
                          BuiltList, [FullType(Form)])) as BuiltList<Form>);
            } else if (trySectionC(serializers, value)) {
              result.sectionCList.replace(serializers.deserialize(value,
                      specifiedType: const FullType(
                          BuiltList, [FullType(FormCItem)])) as BuiltList<FormCItem>);
            } else if (trySectionD(serializers, value)) {
              result.sectionDList.replace(serializers.deserialize(value,
                      specifiedType: const FullType(
                          BuiltList, [FullType(FormDItem)])) as BuiltList<FormDItem>);
            } else if (trySectionE(serializers, value)) {
              result.sectionEList.replace(serializers.deserialize(value,
                      specifiedType: const FullType(
                          BuiltList, [FullType(FormEItem)])) as BuiltList<FormEItem>);
            } else if (trySectionH(serializers, value)) {
              result.sectionHList.replace(serializers.deserialize(value,
                      specifiedType: const FullType(
                          BuiltList, [FullType(FormHItem)])) as BuiltList<FormHItem>);
            } else if (trySectionF(serializers, value)) {
              result.sectionFList.replace(serializers.deserialize(value,
                      specifiedType: const FullType(
                          BuiltList, [FullType(FormFItem)])) as BuiltList<FormFItem>);
            } else if (tryTechnicianImage(serializers, value)) {
              result.technicianImages.replace(serializers.deserialize(value,
                      specifiedType: const FullType(BuiltList, [
                        FullType(TechnicianImageRepair)
                      ])) as BuiltList<TechnicianImageRepair>);
            } else if (tryWoStatus(serializers, value)) {
              result.wostatusList.replace(serializers.deserialize(value,
                      specifiedType: const FullType(
                          BuiltList, [FullType(WorkOrderStatus)])) as BuiltList<WorkOrderStatus>);
            }
          } else {
            result.result = serializers.deserialize(value.toString(),
                specifiedType: const FullType(String)) as String;
          }
          break;
      }
    }
    return result.build();
  }

  bool tryTask(Serializers serializers, List<dynamic> value) {
    try {
      var singleMap = value[0];
      var _ = serializers.deserialize(singleMap,
          specifiedType: const FullType(Task)) as Task;
      return true;
    } catch (_) {
      return false;
    }
  }

  bool tryMonitorTask(Serializers serializers, List<dynamic> value) {
    try {
      var singleMap = value[0];
      var _ = serializers.deserialize(singleMap,
          specifiedType: const FullType(MonitorTask)) as MonitorTask;
      return true;
    } catch (_) {
      return false;
    }
  }

  bool tryWorkOrderTask(Serializers serializers, List<dynamic> value) {
    try {
      var singleMap = value[0];
      var _ = serializers.deserialize(singleMap,
          specifiedType: const FullType(WorkOrderTask)) as WorkOrderTask;
      return true;
    } catch (_) {
      return false;
    }
  }

  bool tryWODetail(Serializers serializers, Map<String, dynamic> value) {
    try {
      var _ = serializers.deserialize(value,
          specifiedType: const FullType(WorkOrderDetail)) as WorkOrderDetail;
      return true;
    } catch (_) {
      return false;
    }
  }

  bool tryMonitorDetail(Serializers serializers, Map<String, dynamic> value) {
    try {
      var _ = serializers.deserialize(value,
          specifiedType: const FullType(MonitorDetail)) as MonitorDetail;
      return true;
    } catch (_) {
      return false;
    }
  }

  bool tryDot(Serializers serializers, List<dynamic> value) {
    try {
      var singleMap = value[0];
      var _ = serializers.deserialize(singleMap,
          specifiedType: const FullType(Dot)) as Dot;
      return true;
    } catch (_) {
      return false;
    }
  }

  bool tryWoStatus(Serializers serializers, List<dynamic> value) {
    try {
      var singleMap = value[0];
      var _ = serializers.deserialize(singleMap,
          specifiedType: const FullType(WorkOrderStatus)) as WorkOrderStatus;
      return true;
    } catch (_) {
      return false;
    }
  }

  bool tryForm(Serializers serializers, List<dynamic> value) {
    try {
      var singleMap = value[0];
      var _ = serializers.deserialize(singleMap,
          specifiedType: const FullType(Form)) as Form;
      return true;
    } catch (_) {
      return false;
    }
  }

  bool trySectionA(Serializers serializers, Map<String, dynamic> value) {
    try {
      var _ = serializers.deserialize(value,
          specifiedType: const FullType(FormAItem)) as FormAItem;
      return true;
    } catch (_) {
      return false;
    }
  }

  bool trySectionB(Serializers serializers, Map<String, dynamic> value) {
    try {
      var _ = serializers.deserialize(value,
          specifiedType: const FullType(FormBItem)) as FormBItem;
      return true;
    } catch (_) {
      return false;
    }
  }

  bool trySectionC(Serializers serializers, List<dynamic> value) {
    try {
      var singleMap = value[0];
      var _ = serializers.deserialize(singleMap,
          specifiedType: const FullType(FormCItem)) as FormCItem;
      return true;
    } catch (_) {
      return false;
    }
  }

  bool trySectionD(Serializers serializers, List<dynamic> value) {
    try {
      var singleMap = value[0];
      var _ = serializers.deserialize(singleMap,
          specifiedType: const FullType(FormDItem)) as FormDItem;
      return true;
    } catch (_) {
      return false;
    }
  }

  bool trySectionE(Serializers serializers, List<dynamic> value) {
    try {
      var singleMap = value[0];
      var _ = serializers.deserialize(singleMap,
          specifiedType: const FullType(FormEItem)) as FormEItem;
      return true;
    } catch (_) {
      return false;
    }
  }

  bool trySectionF(Serializers serializers, List<dynamic> value) {
    try {
      var singleMap = value[0];
      var _ = serializers.deserialize(singleMap,
          specifiedType: const FullType(FormFItem)) as FormFItem;
      return true;
    } catch (_) {
      return false;
    }
  }

  bool trySectionG(Serializers serializers, Map<String, dynamic> value) {
    try {
      var _ = serializers.deserialize(value,
          specifiedType: const FullType(FormGItem)) as FormGItem;
      return true;
    } catch (_) {
      return false;
    }
  }

  bool tryTechnicianDetails(Serializers serializers, Map<String, dynamic> value) {
    try {
      var _ = serializers.deserialize(value,
              specifiedType: const FullType(TechnicianDetails))
          as TechnicianDetails;
      return true;
    } catch (_) {
      return false;
    }
  }

  bool tryTechnicianTask(Serializers serializers, Map<String, dynamic> value) {
    try {
      var _ = serializers.deserialize(value,
          specifiedType: const FullType(TechnicianTask)) as TechnicianTask;
      return true;
    } catch (_) {
      return false;
    }
  }

  bool tryTechnicianAssign(Serializers serializers, Map<String, dynamic> value) {
    try {
      var _ = serializers.deserialize(value,
          specifiedType: const FullType(TechnicianAssign)) as TechnicianAssign;
      return true;
    } catch (_) {
      return false;
    }
  }

  bool trySectionH(Serializers serializers, List<dynamic> value) {
    try {
      var singleMap = value[0];
      var _ = serializers.deserialize(singleMap,
          specifiedType: const FullType(FormHItem)) as FormHItem;
      return true;
    } catch (_) {
      return false;
    }
  }

  bool tryTechnicianImage(Serializers serializers, List<dynamic> value) {
    try {
      var singleMap = value[0];
      var _ = serializers.deserialize(singleMap,
          specifiedType: const FullType(TechnicianImageRepair)) as TechnicianImageRepair;
      return true;
    } catch (_) {
      return false;
    }
  }
}
