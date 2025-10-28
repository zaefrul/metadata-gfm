import 'dart:io';

import 'package:flutter/material.dart';
import 'package:GEMS/main.dart';
import 'package:GEMS/utils/network.dart';
import 'package:GEMS/utils/reference.dart';
import 'package:GEMS/data/repository/ppm_repository.dart';
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
  late PPMRepository _repository;
  bool builded = false;
  final int index;
  bool viewer = true;
  bool _isOnline = true;
  bool _isCheckingConnectivity = false;
  bool _isLoading = false; // Track loading state
  Set<String> _offlineTaskIds = {}; // Cache offline task IDs

  _TaskViewState(this.index) {
    _repository = PPMRepository();
  }

  @override
  void initState() {
    super.initState();
    // Call _refresh after widget is mounted
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _refresh();
    });
  }

  /// Check if device has internet connectivity
  Future<bool> _checkConnectivity() async {
    try {
      final result = await InternetAddress.lookup('google.com');
      return result.isNotEmpty && result[0].rawAddress.isNotEmpty;
    } on SocketException catch (_) {
      return false;
    }
  }

  Future<List<Widget>> fetchGenerate(List<Task> listTask) async {
    // Check connectivity first
    if (!_isCheckingConnectivity) {
      _isCheckingConnectivity = true;
      _isOnline = await _checkConnectivity();
      _isCheckingConnectivity = false;
    }

    List<Widget> values = List<Widget>.empty(growable: true);
    
    // Build a set of offline-enabled task IDs
    _offlineTaskIds.clear();
    for (var task in listTask) {
      final isOfflineEnabled = await _repository.isOfflineModeEnabled(task.ppmTaskId);
      if (isOfflineEnabled) {
        _offlineTaskIds.add(task.ppmTaskId);
      }
    }
    
    // Filter tasks based on connectivity
    List<Task> filteredTasks = listTask;
    if (!_isOnline) {
      // When offline, only show tasks with offline mode enabled
      filteredTasks = listTask.where((task) => _offlineTaskIds.contains(task.ppmTaskId)).toList();
      
      // Add offline indicator
      if (filteredTasks.isEmpty) {
        values.add(_buildOfflineEmptyState());
      } else {
        values.add(_buildOfflineHeader(filteredTasks.length));
      }
    }

    values.addAll(List.generate(filteredTasks.length, (item) => tile(filteredTasks[item])));
    values.insert(0, filter);

    return values;
  }

  Widget _buildOfflineHeader(int taskCount) {
    return Container(
      padding: EdgeInsets.all(16),
      margin: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.orange[100],
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.orange),
      ),
      child: Row(
        children: [
          Icon(Icons.offline_bolt, color: Colors.orange[800]),
          SizedBox(width: 12),
          Expanded(
            child: Text(
              'Offline Mode - Showing $taskCount task${taskCount > 1 ? 's' : ''} available offline',
              style: TextStyle(
                color: Colors.orange[800],
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildOfflineEmptyState() {
    return Container(
      padding: EdgeInsets.all(24),
      margin: EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.grey[100],
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.grey[300]!),
      ),
      child: Column(
        children: [
          Icon(Icons.cloud_off, size: 48, color: Colors.grey[400]),
          SizedBox(height: 16),
          Text(
            'No Offline Tasks Available',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.grey[700],
            ),
          ),
          SizedBox(height: 8),
          Text(
            'You are currently offline. No tasks have been enabled for offline mode.\n\nTo access tasks offline, enable offline mode for them when connected to the internet.',
            textAlign: TextAlign.center,
            style: TextStyle(color: Colors.grey[600]),
          ),
        ],
      ),
    );
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
    debugPrint("Fetching PPM tasks from: $url");

    // Set loading state only if mounted
    if (mounted) {
      setState(() {
        _isLoading = true;
      });
    }

    _provider = Provider(fetchURL: url);

    _provider.fetch().then((value) async {
      _listTask = value.taskList?.toList() ?? [];
      tiles = await fetchGenerate(_listTask);
      children = tiles;
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }).catchError((err) async {
      debugPrint("Error fetching tasks: $err");
      tiles = await fetchGenerate([]);
      children = tiles;
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
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
    super.build(context); // Call super for AutomaticKeepAliveClientMixin
    _provider.context = context;

    builded = true;
    return Stack(
      children: [
        children.isNotEmpty
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
              ),
        // Loading overlay when searching
        if (_isLoading)
          Container(
            color: Colors.black.withOpacity(0.3),
            child: const Center(
              child: Card(
                child: Padding(
                  padding: EdgeInsets.all(20.0),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      CircularProgressIndicator(),
                      SizedBox(height: 16),
                      Text(
                        'Searching tasks...',
                        style: TextStyle(fontSize: 16),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
      ],
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
    final hasOfflineMode = _offlineTaskIds.contains(task.ppmTaskId);
    
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
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              task.transactionNo,
                              style: GoogleFonts.poppins(
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                                color: Colors.black87,
                              ),
                            ),
                          ),
                          if (hasOfflineMode) ...[
                            const SizedBox(width: 8),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                              decoration: BoxDecoration(
                                color: Colors.green,
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Icon(Icons.offline_bolt, size: 12, color: Colors.white),
                                  const SizedBox(width: 4),
                                  Text(
                                    'Offline',
                                    style: GoogleFonts.poppins(
                                      fontSize: 10,
                                      fontWeight: FontWeight.w600,
                                      color: Colors.white,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ],
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
