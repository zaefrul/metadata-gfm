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
import 'form.dart';
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
  Attendance
])
final Serializers serializers =
    (_$serializers.toBuilder()..addPlugin(StandardJsonPlugin())).build();
T deserialize<T>(dynamic value) =>
    serializers.deserializeWith<T>(serializers.serializerForType(T), value);
BuiltList<T> deserializeListOf<T>(dynamic value) => BuiltList.from(
    value.map((value) => deserialize<T>(value)).toList(growable: false));
