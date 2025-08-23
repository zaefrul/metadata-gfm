import 'package:flutter/material.dart';
import 'package:GEMS/model/workorder.dart';
import 'package:GEMS/utils/network.dart';
import 'complaintList.dart';

class ComplaintView extends StatefulWidget {
  final int index;
  final String url;
  final Widget? headers;

  const ComplaintView(this.url, this.headers, this.index, {super.key});

  @override
  _ComplaintViewState createState() => _ComplaintViewState();
}

class _ComplaintViewState extends State<ComplaintView> {
  String dropdownValue = "All Status";
  String dropdownType = "All Type";
  List<WorkOrderTask> _listTask = [];
  List<WorkOrderTask> _filterTask = [];

  @override
  void initState() {
    super.initState();
    _fetch();
  }

  Future<List<WorkOrderTask>> _fetch() async {
    try {
      String filter = "&woType=${dropdownType == "Work Order"
              ? "WO"
              : dropdownType == "Work Request"
                  ? "WR"
                  : ""}";
      Provider provider = Provider(fetchURL: widget.url + filter);
      provider.context = context;

      var value = await provider.fetch();
      _listTask = List<WorkOrderTask>.from((value.workorderTask ?? []) as Iterable);

      if (dropdownValue != "All Status") {
        _filterTask = _listTask
            .where((test) => test.woTaskStatus == dropdownValue)
            .toList();
      } else {
        _filterTask = _listTask;
      }
      return _filterTask;
    } catch (err) {
      return Future.error(err);
    }
  }

  Widget get _filter => DropdownButton<String>(
        underline: Container(),
        value: dropdownValue,
        onChanged: (String? newValue) {
          setState(() {
            dropdownValue = newValue ?? "All Status";
            if (dropdownValue != "All Status") {
              _filterTask = _listTask
                  .where((test) => test.woTaskStatus == dropdownValue)
                  .toList();
            } else {
              _filterTask = _listTask;
            }
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
          'Out of Scope',
        ].map<DropdownMenuItem<String>>((String value) {
          return DropdownMenuItem<String>(
            value: value,
            child: Text(value),
          );
        }).toList(),
      );

  Widget get _filterType => DropdownButton<String>(
        underline: Container(),
        value: dropdownType,
        onChanged: (String? newValue) {
          setState(() {
            dropdownType = newValue ?? "All Type";
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

  Widget get _header => Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: widget.headers == null
            ? <Widget>[
                _filter,
                _filterType,
              ]
            : <Widget>[
                _filter,
                _filterType,
                widget.headers!,
              ],
      );

  @override
  Widget build(BuildContext context) {
    Widget loadingWidget = Container(
      color: Colors.black.withOpacity(0.3),
      child: const Center(
        child: CircularProgressIndicator(),
      ),
    );

    Widget body(List<WorkOrderTask> value) => Container(
          child: Column(
            children: <Widget>[
              const SizedBox(height: 12),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                child: _header,
              ),
              const Divider(),
              Expanded(
                child: ComplaintList(
                  list: value,
                  viewer: widget.index == 0,
                  refresh: _fetch,
                ),
              ),
            ],
          ),
        );

    return FutureBuilder<List<WorkOrderTask>>(
      future: _fetch(),
      builder: (context, AsyncSnapshot<List<WorkOrderTask>> snapshot) {
        if (snapshot.hasError) return body([]);
        if (!snapshot.hasData) return loadingWidget;

        return body(snapshot.data!);
      },
    );
  }
}
