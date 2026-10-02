import 'package:flutter/material.dart';
import 'package:GEMS/controller/Storekeeper/utils/constant.dart';
import 'package:GEMS/utils/network.dart';
import 'package:GEMS/view/gems_chrome.dart';
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
            padding: const EdgeInsets.fromLTRB(12, 12, 12, 80),
            itemBuilder: (ctx, index) => _Tile(data[index]),
            itemCount: data.length,
            separatorBuilder: (ctx, index) => const SizedBox(height: 10),
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
    return GemsAccentCard(
      accent: GemsChrome.primary,
      onTap: () => Navigator.pushNamed(context, routeCheckInInfo, arguments: doId),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(12, 12, 12, 12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    doNo,
                    style: GemsChrome.body(size: 15, weight: FontWeight.w600),
                  ),
                ),
                const SizedBox(width: 8),
                state(totalCost),
              ],
            ),
            const SizedBox(height: 6),
            text(userFirstName),
            text(doDate),
            text(supplierName),
          ],
        ),
      ),
    );
  }

  Widget text(String value) {
    return Padding(
      padding: const EdgeInsets.only(top: 2),
      child: Text(value, style: GemsChrome.body(size: 13, color: GemsChrome.textSoft)),
    );
  }

  Widget state(String price) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        color: GemsChrome.primarySoft,
      ),
      child: Text(
        'RM $price',
        style: GemsChrome.body(
          size: 12,
          weight: FontWeight.w600,
          color: GemsChrome.primary,
        ),
      ),
    );
  }
}
