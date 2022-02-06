// GENERATED CODE - DO NOT MODIFY BY HAND

part of responseValue;

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
  final String result;
  @override
  final BuiltList<Task> taskList;
  @override
  final BuiltList<WorkOrderTask> workorderTask;
  @override
  final WorkOrderDetail woDetail;
  @override
  final BuiltList<MonitorTask> monitorTaskList;
  @override
  final MonitorDetail monitorDetail;
  @override
  final BuiltList<Dot> dotList;
  @override
  final BuiltList<WorkOrderStatus> wostatusList;
  @override
  final BuiltList<Form> statusList;
  @override
  final FormAItem sectionAList;
  @override
  final FormBItem sectionBList;
  @override
  final BuiltList<FormCItem> sectionCList;
  @override
  final BuiltList<FormDItem> sectionDList;
  @override
  final BuiltList<FormEItem> sectionEList;
  @override
  final BuiltList<FormFItem> sectionFList;
  @override
  final FormGItem sectionGList;
  @override
  final BuiltList<FormHItem> sectionHList;
  @override
  final TechnicianDetails technicianDetails;
  @override
  final TechnicianTask technicianTask;
  @override
  final BuiltList<TechnicianImageRepair> technicianImages;
  @override
  final TechnicianAssign technicianAssign;

  factory _$ResponseValue([void Function(ResponseValueBuilder) updates]) =>
      (new ResponseValueBuilder()..update(updates)).build();

  _$ResponseValue._(
      {this.success,
      this.error,
      this.errmsg,
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
      : super._() {
    BuiltValueNullFieldError.checkNotNull(success, 'ResponseValue', 'success');
    BuiltValueNullFieldError.checkNotNull(error, 'ResponseValue', 'error');
    BuiltValueNullFieldError.checkNotNull(errmsg, 'ResponseValue', 'errmsg');
  }

  @override
  ResponseValue rebuild(void Function(ResponseValueBuilder) updates) =>
      (toBuilder()..update(updates)).build();

  @override
  ResponseValueBuilder toBuilder() => new ResponseValueBuilder()..replace(this);

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
                                                        $jc(
                                                            $jc(
                                                                $jc(
                                                                    $jc(
                                                                        $jc(
                                                                            $jc($jc($jc($jc($jc($jc(0, success.hashCode), error.hashCode), errmsg.hashCode), result.hashCode), taskList.hashCode),
                                                                                workorderTask.hashCode),
                                                                            woDetail.hashCode),
                                                                        monitorTaskList.hashCode),
                                                                    monitorDetail.hashCode),
                                                                dotList.hashCode),
                                                            wostatusList.hashCode),
                                                        statusList.hashCode),
                                                    sectionAList.hashCode),
                                                sectionBList.hashCode),
                                            sectionCList.hashCode),
                                        sectionDList.hashCode),
                                    sectionEList.hashCode),
                                sectionFList.hashCode),
                            sectionGList.hashCode),
                        sectionHList.hashCode),
                    technicianDetails.hashCode),
                technicianTask.hashCode),
            technicianImages.hashCode),
        technicianAssign.hashCode));
  }

  @override
  String toString() {
    return (newBuiltValueToStringHelper('ResponseValue')
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
  _$ResponseValue _$v;

  bool _success;
  bool get success => _$this._success;
  set success(bool success) => _$this._success = success;

  String _error;
  String get error => _$this._error;
  set error(String error) => _$this._error = error;

  String _errmsg;
  String get errmsg => _$this._errmsg;
  set errmsg(String errmsg) => _$this._errmsg = errmsg;

  String _result;
  String get result => _$this._result;
  set result(String result) => _$this._result = result;

  ListBuilder<Task> _taskList;
  ListBuilder<Task> get taskList =>
      _$this._taskList ??= new ListBuilder<Task>();
  set taskList(ListBuilder<Task> taskList) => _$this._taskList = taskList;

  ListBuilder<WorkOrderTask> _workorderTask;
  ListBuilder<WorkOrderTask> get workorderTask =>
      _$this._workorderTask ??= new ListBuilder<WorkOrderTask>();
  set workorderTask(ListBuilder<WorkOrderTask> workorderTask) =>
      _$this._workorderTask = workorderTask;

  WorkOrderDetailBuilder _woDetail;
  WorkOrderDetailBuilder get woDetail =>
      _$this._woDetail ??= new WorkOrderDetailBuilder();
  set woDetail(WorkOrderDetailBuilder woDetail) => _$this._woDetail = woDetail;

  ListBuilder<MonitorTask> _monitorTaskList;
  ListBuilder<MonitorTask> get monitorTaskList =>
      _$this._monitorTaskList ??= new ListBuilder<MonitorTask>();
  set monitorTaskList(ListBuilder<MonitorTask> monitorTaskList) =>
      _$this._monitorTaskList = monitorTaskList;

  MonitorDetailBuilder _monitorDetail;
  MonitorDetailBuilder get monitorDetail =>
      _$this._monitorDetail ??= new MonitorDetailBuilder();
  set monitorDetail(MonitorDetailBuilder monitorDetail) =>
      _$this._monitorDetail = monitorDetail;

  ListBuilder<Dot> _dotList;
  ListBuilder<Dot> get dotList => _$this._dotList ??= new ListBuilder<Dot>();
  set dotList(ListBuilder<Dot> dotList) => _$this._dotList = dotList;

  ListBuilder<WorkOrderStatus> _wostatusList;
  ListBuilder<WorkOrderStatus> get wostatusList =>
      _$this._wostatusList ??= new ListBuilder<WorkOrderStatus>();
  set wostatusList(ListBuilder<WorkOrderStatus> wostatusList) =>
      _$this._wostatusList = wostatusList;

  ListBuilder<Form> _statusList;
  ListBuilder<Form> get statusList =>
      _$this._statusList ??= new ListBuilder<Form>();
  set statusList(ListBuilder<Form> statusList) =>
      _$this._statusList = statusList;

  FormAItemBuilder _sectionAList;
  FormAItemBuilder get sectionAList =>
      _$this._sectionAList ??= new FormAItemBuilder();
  set sectionAList(FormAItemBuilder sectionAList) =>
      _$this._sectionAList = sectionAList;

  FormBItemBuilder _sectionBList;
  FormBItemBuilder get sectionBList =>
      _$this._sectionBList ??= new FormBItemBuilder();
  set sectionBList(FormBItemBuilder sectionBList) =>
      _$this._sectionBList = sectionBList;

  ListBuilder<FormCItem> _sectionCList;
  ListBuilder<FormCItem> get sectionCList =>
      _$this._sectionCList ??= new ListBuilder<FormCItem>();
  set sectionCList(ListBuilder<FormCItem> sectionCList) =>
      _$this._sectionCList = sectionCList;

  ListBuilder<FormDItem> _sectionDList;
  ListBuilder<FormDItem> get sectionDList =>
      _$this._sectionDList ??= new ListBuilder<FormDItem>();
  set sectionDList(ListBuilder<FormDItem> sectionDList) =>
      _$this._sectionDList = sectionDList;

  ListBuilder<FormEItem> _sectionEList;
  ListBuilder<FormEItem> get sectionEList =>
      _$this._sectionEList ??= new ListBuilder<FormEItem>();
  set sectionEList(ListBuilder<FormEItem> sectionEList) =>
      _$this._sectionEList = sectionEList;

  ListBuilder<FormFItem> _sectionFList;
  ListBuilder<FormFItem> get sectionFList =>
      _$this._sectionFList ??= new ListBuilder<FormFItem>();
  set sectionFList(ListBuilder<FormFItem> sectionFList) =>
      _$this._sectionFList = sectionFList;

  FormGItemBuilder _sectionGList;
  FormGItemBuilder get sectionGList =>
      _$this._sectionGList ??= new FormGItemBuilder();
  set sectionGList(FormGItemBuilder sectionGList) =>
      _$this._sectionGList = sectionGList;

  ListBuilder<FormHItem> _sectionHList;
  ListBuilder<FormHItem> get sectionHList =>
      _$this._sectionHList ??= new ListBuilder<FormHItem>();
  set sectionHList(ListBuilder<FormHItem> sectionHList) =>
      _$this._sectionHList = sectionHList;

  TechnicianDetailsBuilder _technicianDetails;
  TechnicianDetailsBuilder get technicianDetails =>
      _$this._technicianDetails ??= new TechnicianDetailsBuilder();
  set technicianDetails(TechnicianDetailsBuilder technicianDetails) =>
      _$this._technicianDetails = technicianDetails;

  TechnicianTaskBuilder _technicianTask;
  TechnicianTaskBuilder get technicianTask =>
      _$this._technicianTask ??= new TechnicianTaskBuilder();
  set technicianTask(TechnicianTaskBuilder technicianTask) =>
      _$this._technicianTask = technicianTask;

  ListBuilder<TechnicianImageRepair> _technicianImages;
  ListBuilder<TechnicianImageRepair> get technicianImages =>
      _$this._technicianImages ??= new ListBuilder<TechnicianImageRepair>();
  set technicianImages(ListBuilder<TechnicianImageRepair> technicianImages) =>
      _$this._technicianImages = technicianImages;

  TechnicianAssignBuilder _technicianAssign;
  TechnicianAssignBuilder get technicianAssign =>
      _$this._technicianAssign ??= new TechnicianAssignBuilder();
  set technicianAssign(TechnicianAssignBuilder technicianAssign) =>
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
    ArgumentError.checkNotNull(other, 'other');
    _$v = other as _$ResponseValue;
  }

  @override
  void update(void Function(ResponseValueBuilder) updates) {
    if (updates != null) updates(this);
  }

  @override
  _$ResponseValue build() {
    _$ResponseValue _$result;
    try {
      _$result = _$v ??
          new _$ResponseValue._(
              success: BuiltValueNullFieldError.checkNotNull(
                  success, 'ResponseValue', 'success'),
              error: BuiltValueNullFieldError.checkNotNull(
                  error, 'ResponseValue', 'error'),
              errmsg: BuiltValueNullFieldError.checkNotNull(
                  errmsg, 'ResponseValue', 'errmsg'),
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
              technicianAssign: _technicianAssign?.build());
    } catch (_) {
      String _$failedField;
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
        throw new BuiltValueNestedFieldError(
            'ResponseValue', _$failedField, e.toString());
      }
      rethrow;
    }
    replace(_$result);
    return _$result;
  }
}

// ignore_for_file: always_put_control_body_on_new_line,always_specify_types,annotate_overrides,avoid_annotating_with_dynamic,avoid_as,avoid_catches_without_on_clauses,avoid_returning_this,deprecated_member_use_from_same_package,lines_longer_than_80_chars,omit_local_variable_types,prefer_expression_function_bodies,sort_constructors_first,test_types_in_equals,unnecessary_const,unnecessary_new
