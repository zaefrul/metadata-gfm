import 'package:flutter/material.dart';
import 'package:GEMS/controller/Storekeeper/utils/constant.dart';
import 'package:GEMS/model/complaint.dart';
import 'package:GEMS/view/gems_chrome.dart';
import 'package:GEMS/utils/network.dart';
import 'package:rxdart/subjects.dart';
import '../../../../main.dart';

class CheckOutList extends StatelessWidget {
  final BehaviorSubject<List<Map<String, dynamic>>> _data =
    BehaviorSubject<List<Map<String, dynamic>>>.seeded([]);

  CheckOutList({super.key}) {
    refresh();
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<List<Map<String, dynamic>>>(
      stream: _data.stream,
      builder: (context, snapshot) {
        if (!snapshot.hasData || snapshot.data == null) {
          return Center(child: CircularProgressIndicator());
        }

        final data = snapshot.data!;

        return RefreshIndicator(
          onRefresh: () => refresh(context: navigatorKey.currentContext!),
          child: ListView.separated(
            padding: const EdgeInsets.fromLTRB(12, 12, 12, 80),
            itemBuilder: (ctx, index) => _Tile(data[index]),
            itemCount: data.length,
            separatorBuilder: (ctx, index) => const SizedBox(height: 10),
          ),
        );
      },
    );
  }

  Future<void> refresh({BuildContext? context}) async {
    final Provider provider =
        Provider(fetchURL: "/wo_request/list_mobile_check_out");
    if (context != null) {
      provider.context = context;
    }
    final value = await provider.getJson(url: "/wo_request/list_mobile_check_out");
    if (value is List) {
      _data.sink.add(value.cast<Map<String, dynamic>>());
    }
  }
}

class _Tile extends StatelessWidget {
  final Map<String, dynamic> value;

  const _Tile(this.value);

  @override
  Widget build(BuildContext context) {
    final checkoutBy = value["checkOutBy"] ?? "Unknown";
    final checkoutTime = value["checkOutTime"] ?? "Unknown";
    final total = value["total"] ?? 0;
    final woTaskNo = value["woTaskNo"] ?? "N/A";
    final woTaskRequestId = value["woTaskRequestId"];
    final woTaskRequestNo = value["woTaskRequestNo"] ?? "N/A";

    return GemsAccentCard(
      accent: GemsChrome.primary,
      onTap: () => Navigator.pushNamed(
        context,
        routeMaterialRequestView,
        arguments: RequestTask.fromJson(value),
      ),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(12, 12, 12, 12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    woTaskRequestNo,
                    style: GemsChrome.body(size: 15, weight: FontWeight.w600),
                  ),
                ),
                const SizedBox(width: 8),
                state(woTaskNo),
              ],
            ),
            const SizedBox(height: 6),
            text(checkoutBy),
            text(checkoutTime),
            text('Total Item : $total'),
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

  Widget state(String no) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        color: GemsChrome.primarySoft,
      ),
      child: Text(
        no,
        style: GemsChrome.body(
          size: 12,
          weight: FontWeight.w600,
          color: GemsChrome.primary,
        ),
      ),
    );
  }
}