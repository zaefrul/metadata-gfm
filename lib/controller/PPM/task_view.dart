import 'package:flutter/material.dart';
import 'package:GEMS/main.dart';
import 'package:GEMS/utils/network.dart';
import 'package:GEMS/utils/reference.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../model/task.dart';
import 'Form/form_view.dart';

class TaskView extends StatefulWidget {
  final _TaskViewState view;

  TaskView({super.key, int index = 0}) : view = _TaskViewState(index);

  update(String text) => view.fetch(text);
  updateQR(String text) => view.fetchQR(text);
  updateQRAll(String text) => view.fetchQRAll(text);
  updateAll(String text) => view.fetchAll(text);

  @override
  _TaskViewState createState() => view;
}

class _TaskViewState extends State<TaskView>
    with AutomaticKeepAliveClientMixin<TaskView> {
  String dropdownValue = "All";
  List<Widget> children = List<Widget>.empty(growable: true);
  List<Task> _listTask = List<Task>.empty(growable: true);
  List<Widget> tiles = List<Widget>.empty(growable: true);
  late Provider _provider;
  bool builded = false;
  final int index;
  bool viewer = true;

  _TaskViewState(this.index) {
    _refresh();
  }

  List<Widget> fetchGenerate(List<Task> listTask) {
    List<Widget> values = List<Widget>.empty(growable: true);
    values = List.generate(listTask.length, (item) => tile(listTask[item]));

    values.insert(0, filter);

    return values;
  }

  fetch(String text) {
    String url = "/api/m_ppm.php?type=pending_task";
    url += "_search&assetNo=$text";

    _fetch(url);
  }

  fetchQR(String text) {
    String url = "/api/m_ppm.php?type=pending_task";
    url += "_scan_asset&assetNo=$text";

    _fetch(url);
  }

  fetchQRAll(String text) {
    String url = "/api/m_ppm.php?type=all_task";
    url += "_scan_asset&assetNo=$text";

    _fetch(url);
  }

  fetchAll(String text) {
    String url = "/api/m_ppm.php?type=all_task";
    url += "_search&searchTxt=$text";

    _fetch(url);
  }

  void _fetch(String url) {
    _provider = Provider(fetchURL: url);

    _provider.fetch().then((value) {
      _listTask = value.taskList?.toList() ?? [];
      tiles = fetchGenerate(_listTask);
      children = tiles;
      if (builded) setState(() {});
    }).catchError((err) {
      tiles = fetchGenerate([]);
      children = tiles;
      if (builded) setState(() {});
    });
  }

  Future<void> _refresh() {
    if (index == 0) {
      fetchAll("");
    } else if (index == 1) {
      fetch("");
      viewer = false;
    }

    return Future.value();
  }

  @override
  bool get wantKeepAlive => true;

  @override
  Widget build(BuildContext context) {
    _provider.context = context;

    builded = true;
    return children.isNotEmpty
        ? RefreshIndicator(
            onRefresh: _refresh,
            child: ListView.builder(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              itemCount: children.length,
              itemBuilder: (context, index) => children[index],
              // separatorBuilder: (context, index) {
              //   return Divider();
              // },
            ))
        : Container(
            child: Center(
              child: CircularProgressIndicator(),
            ),
          );
  }

  Widget getTitle(String text, {bold = false}) => Container(
        alignment: Alignment.centerLeft,
        child: Text(text,
            style: TextStyle(
                fontWeight: bold ? FontWeight.bold : FontWeight.normal)),
      );

  Widget status(String value) {
    var text = value;
    var color = colorTheme1;
    if (text == "In Progress") {
      color = colorTheme5;
    } else if (text == "Closed")
      color = colorTheme4;
    else if (text == "Check") {
      color = colorTheme2;
    } else if (text == "Verify") {
      color = colorTheme3;
    }
    return Container(
        alignment: Alignment.center,
        height: 30.0,
        width: 100.0,
        decoration: BoxDecoration(
            color: color, borderRadius: BorderRadius.circular(20.0)),
        child: Text(text,
            style: TextStyle(
              color: Colors.white,
            )));
  }

  Color _statusCardColor(String status) {
    switch (status) {
      case "In Progress":
        return AppColors.primaryLight;
      case "Closed":
        return AppColors.successLight;
      case "Check":
        return AppColors.warningLight;
      case "Verify":
        return AppColors.infoLight;
      case "Open":
      default:
        return AppColors.secondaryLight;
    }
  }

  Color _statusColor(String status) {
    switch (status) {
      case "In Progress":
        return AppColors.primaryDark;
      case "Closed":
        return AppColors.infoDark;
      case "Check":
        return AppColors.warningDark;
      case "Verify":
        return AppColors.info;
      case "Open":
      default:
        return AppColors.secondary;
    }
  }

  ListTile tile(Task task) {
    return ListTile(
      contentPadding: EdgeInsets.zero,
      title: Card(
        elevation: 2,
        margin: const EdgeInsets.only(bottom: 12),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        color: _statusCardColor(task.statusDesc),
        child: InkWell(
          onTap: () {
            Widget page = FormView(
              id: task.ppmTaskId,
              siteName: task.siteName,
              taskNo: task.transactionNo,
              taskStatus: task.statusDesc,
              refresh: () => fetch(""),
              viewer: viewer,
            );
            Navigator.of(context)
                .push(MaterialPageRoute(builder: (context) => page))
                .then((_) {
              if (index == 1) fetch("");
            }).whenComplete(_refresh);
          },
          borderRadius: BorderRadius.circular(12),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                // Left column
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        task.transactionNo,
                        style: GoogleFonts.poppins(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: Colors.black87,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        task.assetTypeName,
                        style: GoogleFonts.poppins(
                          fontSize: 14,
                          color: Colors.black54,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        task.assetNo,
                        style: GoogleFonts.poppins(
                          fontSize: 12,
                          color: Colors.black54,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        task.technician,
                        style: GoogleFonts.poppins(
                          fontSize: 12,
                          color: Colors.black54,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          Icon(Icons.access_time, size: 14, color: Colors.black38),
                          const SizedBox(width: 4),
                          Text(
                            task.taskDateDue,
                            style: GoogleFonts.poppins(
                              fontSize: 12,
                              color: Colors.black54,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),

                // Right: status chip
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: _statusColor(task.statusDesc),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    task.statusDesc,
                    style: GoogleFonts.poppins(
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                      color: Colors.white,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  DropdownButton get filter => DropdownButton<String>(
        underline: Container(),
        value: dropdownValue,
        onChanged: (String? newValue) {
          setState(() {
            dropdownValue = newValue!;
            if (newValue != "All") {
              var tempList = _listTask
                  .where((test) => test.statusDesc == newValue)
                  .toList();
              children = List<Widget>.empty(growable: true);
              children.addAll(ListTile.divideTiles(
                      context: navigatorKey.currentContext!,
                      tiles: List.generate(
                          tempList.length, (index) => tile(tempList[index])))
                  .toList());
              children.insert(0, filter);
            } else {
              children = tiles;
            }
          });
        },
        items: <String>[
          'All',
          'Open',
          'In Progress',
          'Check',
          'Verify',
          'Re-Open',
          'Completed'
        ].map<DropdownMenuItem<String>>((String value) {
          return DropdownMenuItem<String>(
            value: value,
            child: Text(value),
          );
        }).toList(),
      );
}
