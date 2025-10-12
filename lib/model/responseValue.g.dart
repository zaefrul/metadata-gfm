// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'responseValue.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

class _$ResponseValue extends ResponseValue {
  @override
  final bool success;
  @override
  final String error;
  @override
  final String errmsg;
  @override
  final String? result;
  @override
  final BuiltList<Task>? taskList;
  @override
  final BuiltList<WorkOrderTask>? workorderTask;
  @override
  final WorkOrderDetail? woDetail;
  @override
  final BuiltList<MonitorTask>? monitorTaskList;
  @override
  final MonitorDetail? monitorDetail;
  @override
  final BuiltList<Dot>? dotList;
  @override
  final BuiltList<WorkOrderStatus>? wostatusList;
  @override
  final BuiltList<Form>? statusList;
  @override
  final FormAItem? sectionAList;
  @override
  final FormBItem? sectionBList;
  @override
  final BuiltList<FormCItem>? sectionCList;
  @override
  final BuiltList<FormDItem>? sectionDList;
  @override
  final BuiltList<FormEItem>? sectionEList;
  @override
  final BuiltList<FormFItem>? sectionFList;
  @override
  final FormGItem? sectionGList;
  @override
  final BuiltList<FormHItem>? sectionHList;
  @override
  final TechnicianDetails? technicianDetails;
  @override
  final TechnicianTask? technicianTask;
  @override
  final BuiltList<TechnicianImageRepair>? technicianImages;
  @override
  final TechnicianAssign? technicianAssign;

  factory _$ResponseValue([void Function(ResponseValueBuilder)? updates]) =>
      (ResponseValueBuilder()..update(updates))._build();

  _$ResponseValue._(
      {required this.success,
      required this.error,
      required this.errmsg,
      this.result,
      this.taskList,
      this.workorderTask,
      this.woDetail,
      this.monitorTaskList,
      this.monitorDetail,
      this.dotList,
      this.wostatusList,
      this.statusList,
      this.sectionAList,
      this.sectionBList,
      this.sectionCList,
      this.sectionDList,
      this.sectionEList,
      this.sectionFList,
      this.sectionGList,
      this.sectionHList,
      this.technicianDetails,
      this.technicianTask,
      this.technicianImages,
      this.technicianAssign})
      : super._();
  @override
  ResponseValue rebuild(void Function(ResponseValueBuilder) updates) =>
      (toBuilder()..update(updates)).build();

  @override
  ResponseValueBuilder toBuilder() => ResponseValueBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is ResponseValue &&
        success == other.success &&
        error == other.error &&
        errmsg == other.errmsg &&
        result == other.result &&
        taskList == other.taskList &&
        workorderTask == other.workorderTask &&
        woDetail == other.woDetail &&
        monitorTaskList == other.monitorTaskList &&
        monitorDetail == other.monitorDetail &&
        dotList == other.dotList &&
        wostatusList == other.wostatusList &&
        statusList == other.statusList &&
        sectionAList == other.sectionAList &&
        sectionBList == other.sectionBList &&
        sectionCList == other.sectionCList &&
        sectionDList == other.sectionDList &&
        sectionEList == other.sectionEList &&
        sectionFList == other.sectionFList &&
        sectionGList == other.sectionGList &&
        sectionHList == other.sectionHList &&
        technicianDetails == other.technicianDetails &&
        technicianTask == other.technicianTask &&
        technicianImages == other.technicianImages &&
        technicianAssign == other.technicianAssign;
  }

  @override
  int get hashCode {
    var _$hash = 0;
    _$hash = $jc(_$hash, success.hashCode);
    _$hash = $jc(_$hash, error.hashCode);
    _$hash = $jc(_$hash, errmsg.hashCode);
    _$hash = $jc(_$hash, result.hashCode);
    _$hash = $jc(_$hash, taskList.hashCode);
    _$hash = $jc(_$hash, workorderTask.hashCode);
    _$hash = $jc(_$hash, woDetail.hashCode);
    _$hash = $jc(_$hash, monitorTaskList.hashCode);
    _$hash = $jc(_$hash, monitorDetail.hashCode);
    _$hash = $jc(_$hash, dotList.hashCode);
    _$hash = $jc(_$hash, wostatusList.hashCode);
    _$hash = $jc(_$hash, statusList.hashCode);
    _$hash = $jc(_$hash, sectionAList.hashCode);
    _$hash = $jc(_$hash, sectionBList.hashCode);
    _$hash = $jc(_$hash, sectionCList.hashCode);
    _$hash = $jc(_$hash, sectionDList.hashCode);
    _$hash = $jc(_$hash, sectionEList.hashCode);
    _$hash = $jc(_$hash, sectionFList.hashCode);
    _$hash = $jc(_$hash, sectionGList.hashCode);
    _$hash = $jc(_$hash, sectionHList.hashCode);
    _$hash = $jc(_$hash, technicianDetails.hashCode);
    _$hash = $jc(_$hash, technicianTask.hashCode);
    _$hash = $jc(_$hash, technicianImages.hashCode);
    _$hash = $jc(_$hash, technicianAssign.hashCode);
    _$hash = $jf(_$hash);
    return _$hash;
  }

  @override
  String toString() {
    return (newBuiltValueToStringHelper(r'ResponseValue')
          ..add('success', success)
          ..add('error', error)
          ..add('errmsg', errmsg)
          ..add('result', result)
          ..add('taskList', taskList)
          ..add('workorderTask', workorderTask)
          ..add('woDetail', woDetail)
          ..add('monitorTaskList', monitorTaskList)
          ..add('monitorDetail', monitorDetail)
          ..add('dotList', dotList)
          ..add('wostatusList', wostatusList)
          ..add('statusList', statusList)
          ..add('sectionAList', sectionAList)
          ..add('sectionBList', sectionBList)
          ..add('sectionCList', sectionCList)
          ..add('sectionDList', sectionDList)
          ..add('sectionEList', sectionEList)
          ..add('sectionFList', sectionFList)
          ..add('sectionGList', sectionGList)
          ..add('sectionHList', sectionHList)
          ..add('technicianDetails', technicianDetails)
          ..add('technicianTask', technicianTask)
          ..add('technicianImages', technicianImages)
          ..add('technicianAssign', technicianAssign))
        .toString();
  }
}

class ResponseValueBuilder
    implements Builder<ResponseValue, ResponseValueBuilder> {
  _$ResponseValue? _$v;

  bool? _success;
  bool? get success => _$this._success;
  set success(bool? success) => _$this._success = success;

  String? _error;
  String? get error => _$this._error;
  set error(String? error) => _$this._error = error;

  String? _errmsg;
  String? get errmsg => _$this._errmsg;
  set errmsg(String? errmsg) => _$this._errmsg = errmsg;

  String? _result;
  String? get result => _$this._result;
  set result(String? result) => _$this._result = result;

  ListBuilder<Task>? _taskList;
  ListBuilder<Task> get taskList => _$this._taskList ??= ListBuilder<Task>();
  set taskList(ListBuilder<Task>? taskList) => _$this._taskList = taskList;

  ListBuilder<WorkOrderTask>? _workorderTask;
  ListBuilder<WorkOrderTask> get workorderTask =>
      _$this._workorderTask ??= ListBuilder<WorkOrderTask>();
  set workorderTask(ListBuilder<WorkOrderTask>? workorderTask) =>
      _$this._workorderTask = workorderTask;

  WorkOrderDetailBuilder? _woDetail;
  WorkOrderDetailBuilder get woDetail =>
      _$this._woDetail ??= WorkOrderDetailBuilder();
  set woDetail(WorkOrderDetailBuilder? woDetail) => _$this._woDetail = woDetail;

  ListBuilder<MonitorTask>? _monitorTaskList;
  ListBuilder<MonitorTask> get monitorTaskList =>
      _$this._monitorTaskList ??= ListBuilder<MonitorTask>();
  set monitorTaskList(ListBuilder<MonitorTask>? monitorTaskList) =>
      _$this._monitorTaskList = monitorTaskList;

  MonitorDetailBuilder? _monitorDetail;
  MonitorDetailBuilder get monitorDetail =>
      _$this._monitorDetail ??= MonitorDetailBuilder();
  set monitorDetail(MonitorDetailBuilder? monitorDetail) =>
      _$this._monitorDetail = monitorDetail;

  ListBuilder<Dot>? _dotList;
  ListBuilder<Dot> get dotList => _$this._dotList ??= ListBuilder<Dot>();
  set dotList(ListBuilder<Dot>? dotList) => _$this._dotList = dotList;

  ListBuilder<WorkOrderStatus>? _wostatusList;
  ListBuilder<WorkOrderStatus> get wostatusList =>
      _$this._wostatusList ??= ListBuilder<WorkOrderStatus>();
  set wostatusList(ListBuilder<WorkOrderStatus>? wostatusList) =>
      _$this._wostatusList = wostatusList;

  ListBuilder<Form>? _statusList;
  ListBuilder<Form> get statusList =>
      _$this._statusList ??= ListBuilder<Form>();
  set statusList(ListBuilder<Form>? statusList) =>
      _$this._statusList = statusList;

  FormAItemBuilder? _sectionAList;
  FormAItemBuilder get sectionAList =>
      _$this._sectionAList ??= FormAItemBuilder();
  set sectionAList(FormAItemBuilder? sectionAList) =>
      _$this._sectionAList = sectionAList;

  FormBItemBuilder? _sectionBList;
  FormBItemBuilder get sectionBList =>
      _$this._sectionBList ??= FormBItemBuilder();
  set sectionBList(FormBItemBuilder? sectionBList) =>
      _$this._sectionBList = sectionBList;

  ListBuilder<FormCItem>? _sectionCList;
  ListBuilder<FormCItem> get sectionCList =>
      _$this._sectionCList ??= ListBuilder<FormCItem>();
  set sectionCList(ListBuilder<FormCItem>? sectionCList) =>
      _$this._sectionCList = sectionCList;

  ListBuilder<FormDItem>? _sectionDList;
  ListBuilder<FormDItem> get sectionDList =>
      _$this._sectionDList ??= ListBuilder<FormDItem>();
  set sectionDList(ListBuilder<FormDItem>? sectionDList) =>
      _$this._sectionDList = sectionDList;

  ListBuilder<FormEItem>? _sectionEList;
  ListBuilder<FormEItem> get sectionEList =>
      _$this._sectionEList ??= ListBuilder<FormEItem>();
  set sectionEList(ListBuilder<FormEItem>? sectionEList) =>
      _$this._sectionEList = sectionEList;

  ListBuilder<FormFItem>? _sectionFList;
  ListBuilder<FormFItem> get sectionFList =>
      _$this._sectionFList ??= ListBuilder<FormFItem>();
  set sectionFList(ListBuilder<FormFItem>? sectionFList) =>
      _$this._sectionFList = sectionFList;

  FormGItemBuilder? _sectionGList;
  FormGItemBuilder get sectionGList =>
      _$this._sectionGList ??= FormGItemBuilder();
  set sectionGList(FormGItemBuilder? sectionGList) =>
      _$this._sectionGList = sectionGList;

  ListBuilder<FormHItem>? _sectionHList;
  ListBuilder<FormHItem> get sectionHList =>
      _$this._sectionHList ??= ListBuilder<FormHItem>();
  set sectionHList(ListBuilder<FormHItem>? sectionHList) =>
      _$this._sectionHList = sectionHList;

  TechnicianDetailsBuilder? _technicianDetails;
  TechnicianDetailsBuilder get technicianDetails =>
      _$this._technicianDetails ??= TechnicianDetailsBuilder();
  set technicianDetails(TechnicianDetailsBuilder? technicianDetails) =>
      _$this._technicianDetails = technicianDetails;

  TechnicianTaskBuilder? _technicianTask;
  TechnicianTaskBuilder get technicianTask =>
      _$this._technicianTask ??= TechnicianTaskBuilder();
  set technicianTask(TechnicianTaskBuilder? technicianTask) =>
      _$this._technicianTask = technicianTask;

  ListBuilder<TechnicianImageRepair>? _technicianImages;
  ListBuilder<TechnicianImageRepair> get technicianImages =>
      _$this._technicianImages ??= ListBuilder<TechnicianImageRepair>();
  set technicianImages(ListBuilder<TechnicianImageRepair>? technicianImages) =>
      _$this._technicianImages = technicianImages;

  TechnicianAssignBuilder? _technicianAssign;
  TechnicianAssignBuilder get technicianAssign =>
      _$this._technicianAssign ??= TechnicianAssignBuilder();
  set technicianAssign(TechnicianAssignBuilder? technicianAssign) =>
      _$this._technicianAssign = technicianAssign;

  ResponseValueBuilder();

  ResponseValueBuilder get _$this {
    final $v = _$v;
    if ($v != null) {
      _success = $v.success;
      _error = $v.error;
      _errmsg = $v.errmsg;
      _result = $v.result;
      _taskList = $v.taskList?.toBuilder();
      _workorderTask = $v.workorderTask?.toBuilder();
      _woDetail = $v.woDetail?.toBuilder();
      _monitorTaskList = $v.monitorTaskList?.toBuilder();
      _monitorDetail = $v.monitorDetail?.toBuilder();
      _dotList = $v.dotList?.toBuilder();
      _wostatusList = $v.wostatusList?.toBuilder();
      _statusList = $v.statusList?.toBuilder();
      _sectionAList = $v.sectionAList?.toBuilder();
      _sectionBList = $v.sectionBList?.toBuilder();
      _sectionCList = $v.sectionCList?.toBuilder();
      _sectionDList = $v.sectionDList?.toBuilder();
      _sectionEList = $v.sectionEList?.toBuilder();
      _sectionFList = $v.sectionFList?.toBuilder();
      _sectionGList = $v.sectionGList?.toBuilder();
      _sectionHList = $v.sectionHList?.toBuilder();
      _technicianDetails = $v.technicianDetails?.toBuilder();
      _technicianTask = $v.technicianTask?.toBuilder();
      _technicianImages = $v.technicianImages?.toBuilder();
      _technicianAssign = $v.technicianAssign?.toBuilder();
      _$v = null;
    }
    return this;
  }

  @override
  void replace(ResponseValue other) {
    _$v = other as _$ResponseValue;
  }

  @override
  void update(void Function(ResponseValueBuilder)? updates) {
    if (updates != null) updates(this);
  }

  @override
  ResponseValue build() => _build();

  _$ResponseValue _build() {
    _$ResponseValue _$result;
    try {
      _$result = _$v ??
          _$ResponseValue._(
            success: BuiltValueNullFieldError.checkNotNull(
                success, r'ResponseValue', 'success'),
            error: BuiltValueNullFieldError.checkNotNull(
                error, r'ResponseValue', 'error'),
            errmsg: BuiltValueNullFieldError.checkNotNull(
                errmsg, r'ResponseValue', 'errmsg'),
            result: result,
            taskList: _taskList?.build(),
            workorderTask: _workorderTask?.build(),
            woDetail: _woDetail?.build(),
            monitorTaskList: _monitorTaskList?.build(),
            monitorDetail: _monitorDetail?.build(),
            dotList: _dotList?.build(),
            wostatusList: _wostatusList?.build(),
            statusList: _statusList?.build(),
            sectionAList: _sectionAList?.build(),
            sectionBList: _sectionBList?.build(),
            sectionCList: _sectionCList?.build(),
            sectionDList: _sectionDList?.build(),
            sectionEList: _sectionEList?.build(),
            sectionFList: _sectionFList?.build(),
            sectionGList: _sectionGList?.build(),
            sectionHList: _sectionHList?.build(),
            technicianDetails: _technicianDetails?.build(),
            technicianTask: _technicianTask?.build(),
            technicianImages: _technicianImages?.build(),
            technicianAssign: _technicianAssign?.build(),
          );
    } catch (_) {
      late String _$failedField;
      try {
        _$failedField = 'taskList';
        _taskList?.build();
        _$failedField = 'workorderTask';
        _workorderTask?.build();
        _$failedField = 'woDetail';
        _woDetail?.build();
        _$failedField = 'monitorTaskList';
        _monitorTaskList?.build();
        _$failedField = 'monitorDetail';
        _monitorDetail?.build();
        _$failedField = 'dotList';
        _dotList?.build();
        _$failedField = 'wostatusList';
        _wostatusList?.build();
        _$failedField = 'statusList';
        _statusList?.build();
        _$failedField = 'sectionAList';
        _sectionAList?.build();
        _$failedField = 'sectionBList';
        _sectionBList?.build();
        _$failedField = 'sectionCList';
        _sectionCList?.build();
        _$failedField = 'sectionDList';
        _sectionDList?.build();
        _$failedField = 'sectionEList';
        _sectionEList?.build();
        _$failedField = 'sectionFList';
        _sectionFList?.build();
        _$failedField = 'sectionGList';
        _sectionGList?.build();
        _$failedField = 'sectionHList';
        _sectionHList?.build();
        _$failedField = 'technicianDetails';
        _technicianDetails?.build();
        _$failedField = 'technicianTask';
        _technicianTask?.build();
        _$failedField = 'technicianImages';
        _technicianImages?.build();
        _$failedField = 'technicianAssign';
        _technicianAssign?.build();
      } catch (e) {
        throw BuiltValueNestedFieldError(
            r'ResponseValue', _$failedField, e.toString());
      }
      rethrow;
    }
    replace(_$result);
    return _$result;
  }
}

// ignore_for_file: deprecated_member_use_from_same_package,type=lint
