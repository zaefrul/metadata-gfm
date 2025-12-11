import 'package:flutter/material.dart';
import 'package:GEMS/controller/Storekeeper/utils/constant.dart';
import 'package:GEMS/utils/network.dart';
import 'package:rxdart/rxdart.dart';
import '../../../../main.dart';

class CheckInList extends StatelessWidget {
  // Explicitly specify that the subject holds a List<dynamic>.
  final BehaviorSubject<List<dynamic>> _data = BehaviorSubject<List<dynamic>>.seeded([]);

  CheckInList({super.key}) {
    // Don't call refresh in constructor - it will be called when widget builds
  }

  @override
  Widget build(BuildContext context) {
    // Call refresh once when the widget first builds
    if (_data.value.isEmpty) {
      refresh(context: context);
    }
    
    return StreamBuilder<List<dynamic>>(
      stream: _data.stream,
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return const Center(child: CircularProgressIndicator());
        }

        final data = snapshot.data!;

        return RefreshIndicator(
          onRefresh: () => refresh(context: navigatorKey.currentContext!),
          child: ListView.separated(
            shrinkWrap: true,
            primary: true,
            padding: const EdgeInsets.only(top: 12, bottom: 50),
            itemBuilder: (ctx, index) => _Tile(data[index]),
            itemCount: data.length,
            separatorBuilder: (ctx, index) => const Divider(),
          ),
        );
      },
    );
  }

  Future<void> refresh({BuildContext? context}) {
    final Provider provider = Provider(fetchURL: "/do/list_mobile_check_in");
    if (context != null) {
      provider.context = context;
    }
    return provider.getJson(url: "/do/list_mobile_check_in").then((value) {
      final List<dynamic> items = _normalizeList(value);
      items.sort(_sortLatestFirst);
      _data.sink.add(items);
    }).catchError((error) {
      debugPrint("Error refreshing check-in list: $error");
      // Keep the current data on error
    });
  }

  List<dynamic> _normalizeList(dynamic value) {
    if (value is List) return List<dynamic>.from(value);
    if (value is Map<String, dynamic> && value['result'] is List) {
      return List<dynamic>.from(value['result'] as List);
    }
    return <dynamic>[];
  }

  int _sortLatestFirst(dynamic a, dynamic b) {
    final DateTime? dateA = _extractTimestamp(a);
    final DateTime? dateB = _extractTimestamp(b);
    if (dateA == null && dateB == null) return 0;
    if (dateA == null) return 1;
    if (dateB == null) return -1;
    return dateB.compareTo(dateA);
  }

  DateTime? _extractTimestamp(dynamic entry) {
    if (entry is! Map<String, dynamic>) return null;
    final DateTime? timestamp = _parseTimestamp(entry['doTimestamp']);
    if (timestamp != null) return timestamp;
    return _parseTimestamp(entry['doDate']);
  }

  DateTime? _parseTimestamp(dynamic raw) {
    if (raw == null) return null;
    final String text = raw.toString();
    if (text.isEmpty) return null;
    final int? numValue = int.tryParse(text);
    if (numValue != null) {
      if (text.length >= 13) {
        return DateTime.fromMillisecondsSinceEpoch(numValue);
      }
      return DateTime.fromMillisecondsSinceEpoch(numValue * 1000);
    }
    return DateTime.tryParse(text);
  }
}

class _Tile extends StatelessWidget {
  final String doDate;
  final String doId;
  final String doNo;
  final String doTimestamp;
  final String supplierName;
  final String totalCost;
  final String userFirstName;

  _Tile(Map<String, dynamic> value)
      : doDate = value["doDate"] ?? "",
        doId = value["doId"] ?? "",
        doNo = value["doNo"] ?? "",
        doTimestamp = value["doTimestamp"] ?? "",
        supplierName = value["supplierName"] ?? "",
        totalCost = value["totalCost"] ?? "",
        userFirstName = value["userFirstName"] ?? "";

  @override
  Widget build(BuildContext context) {
    return ListTile(
      title: Text(
        doNo,
        style: const TextStyle(fontWeight: FontWeight.bold),
      ),
      onTap: () => Navigator.pushNamed(context, routeCheckInInfo, arguments: doId),
      subtitle: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          text(value: userFirstName, top: 8.0),
          text(value: doDate),
          text(value: supplierName),
        ],
      ),
      trailing: state(totalCost),
    );
  }

  Widget text({required String value, double top = 3.0}) {
    return Padding(
      padding: EdgeInsets.only(top: top),
      child: Text(
        value,
        style: TextStyle(color: colorTheme3),
      ),
    );
  }

  Widget state(String price) {
    return Container(
      height: 40,
      width: 130,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        color: colorTheme3,
      ),
      child: Center(
        child: Text(
          "RM $price",
          style: const TextStyle(color: Colors.white, fontSize: 16),
        ),
      ),
    );
  }
}
