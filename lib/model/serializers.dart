library serializers;

import 'package:built_collection/built_collection.dart';
import 'package:built_value/serializer.dart';
import 'package:built_value/standard_json_plugin.dart';

import 'package:gfm_gems/model/dot.dart';
import 'package:gfm_gems/model/responseValue.dart';
import 'package:gfm_gems/model/task.dart';
import 'package:gfm_gems/model/workorder.dart';

import 'attendance.dart';
import 'complaint.dart';
import 'complaintResponse.dart';
import 'eventAtt.dart';
import 'eventDetail.dart';
import 'form.dart';
import 'gamificationInfo.dart';
import 'material.dart';
import 'meter.dart';
import 'monitor.dart';

part 'serializers.g.dart';

@SerializersFor(const [
  Task,
  WorkOrderTask,
  WorkOrderStatus,
  WorkOrderDetail,
  ComplaintImage,
  ComplaintDImage,
  MonitorTask,
  MonitorDetail,
  MonitorHistory,
  Dot,
  ResponseValue,
  Form,
  FormAItem,
  FormBItem,
  FormCItem,
  FormDItem,
  FormEItem,
  FormFItem,
  FormGItem,
  FormHItem,
  TechnicianDetails,
  TechnicianTask,
  TechnicianImageRepair,
  TechnicianAssign,
  ComplaintResponse,
  ComplaintD,
  ComplaintDGroup,
  ComplaintDType,
  ComplaintDPart,
  RequestTask,
  Material,
  ComplaintDStore,
  ComplaintDGroupStore,
  ComplaintMaterial,
  ComplaintMaterialGrouped,
  ComplaintMaterialImage,
  Meter,
  MaterialStorePart,
  ComplaintDStoreType,
  Reading,
  Attendance,
  GamificationInfo,
  EventAtt,
  EventDetail,
])
final Serializers serializers =
    (_$serializers.toBuilder()..addPlugin(StandardJsonPlugin())).build();
T deserialize<T>(dynamic value) {
  final serializer = serializers.serializerForType(T);
  if (serializer == null) {
    throw ArgumentError('No serializer found for type $T');
  }
  final result = serializers.deserializeWith<T>(serializer as Serializer<T>, value);
  if (result == null) {
    throw ArgumentError('Deserialization returned null for type $T');
  }
  return result;
}
BuiltList<T> deserializeListOf<T>(dynamic value) => BuiltList.from(
    value.map((value) => deserialize<T>(value)).toList(growable: false));
