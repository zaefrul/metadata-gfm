import 'package:flutter/material.dart';
import 'package:gfm_gems/model/workorder.dart';
import 'package:gfm_gems/utils/network.dart';
import 'complaintList.dart';

class ComplaintView extends StatefulWidget {
  final int index;
  final String url;
  final Widget headers;

  ComplaintView(this.url, this.headers, this.index);

  @override
  _ComplaintViewState createState() => _ComplaintViewState();
}

class _ComplaintViewState extends State<ComplaintView> {
  String dropdownValue = "All Status";
  String dropdownType = "All Type";
  List<WorkOrderTask> _listTask = List<WorkOrderTask>();
  List<WorkOrderTask> _filterTask = List<WorkOrderTask>();

  @override
  void initState() {
    super.initState();
    _fetch();
  }

  Future<List<WorkOrderTask>> _fetch() async {
    try {
      String filter = "&woType=" +
          (dropdownType == "Work Order"
              ? "WO"
              : dropdownType == "Work Request"
                  ? "WR"
                  : "");
      Provider provider = Provider(fetchURL: widget.url + filter);
      provider.context = context;

      var value = await provider.fetch();

      _listTask = value.workorderTask.toList();

      if (dropdownValue != "All Status")
        _filterTask = _listTask
            .toList()
            .where((test) => test.woTaskStatus == dropdownValue)
            .toList();
      else
        _filterTask = _listTask;

      return Future.value(_filterTask);
    } catch (err) {
      return Future.error(err);
    }
  }

  Widget get _filter => DropdownButton<String>(
        underline: new Container(),
        value: dropdownValue,
        onChanged: (String newValue) {
          setState(() {
            dropdownValue = newValue;
            if (newValue != "All Status")
              _filterTask = _listTask
                  .where((test) => test.woTaskStatus == newValue)
                  .toList();
            else
              _filterTask = _listTask;
          });
        },
        items: <String>[
          'All Status',
          'Assign',
          "WR Check",
          "WR Verified",
          'In Progress',
          'Verify',
          'Re-Open',
          'Completed',
        ].map<DropdownMenuItem<String>>((String value) {
          return DropdownMenuItem<String>(
            value: value,
            child: Text(value),
          );
        }).toList(),
      );

  Widget get _filterType => DropdownButton<String>(
        underline: new Container(),
        value: dropdownType,
        onChanged: (String newValue) {
          setState(() {
            dropdownType = newValue;
            _fetch();
          });
        },
        items: <String>[
          'All Type',
          'Work Request',
          'Work Order',
        ].map<DropdownMenuItem<String>>((String value) {
          return DropdownMenuItem<String>(
            value: value,
            child: Text(value),
          );
        }).toList(),
      );

  Widget get _header => new Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: widget.headers == null
            ? <Widget>[
                _filter,
                _filterType,
              ]
            : <Widget>[_filter, _filterType, widget.headers],
      );

  @override
  Widget build(BuildContext context) {
    var loading = new Container(
      child: Center(
        child: CircularProgressIndicator(),
      ),
      color: Colors.black.withOpacity(0.3),
    );
    Widget body(List<WorkOrderTask> value) => new Container(
          child: new Column(
            children: <Widget>[
              new SizedBox(
                height: 12,
              ),
              new Padding(
                padding: EdgeInsets.symmetric(horizontal: 16.0),
                child: _header,
              ),
              new Divider(),
              new Expanded(
                child: new ComplaintList(
                  list: value,
                  viewer: widget.index == 0,
                  refresh: _fetch,
                ),
              )
            ],
          ),
        );

    return FutureBuilder(
      future: _fetch(),
      builder: (context, AsyncSnapshot<List<WorkOrderTask>> snapshot) {
        if (snapshot.error != null) return body(List<WorkOrderTask>());
        if (snapshot.data == null) return loading;

        return body(snapshot.data);
      },
    );
  }
}
