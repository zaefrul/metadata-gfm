import 'package:flutter/material.dart';
import 'package:GEMS/controller/Storekeeper/utils/constant.dart';
import 'package:GEMS/model/complaint.dart';
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
            padding: EdgeInsets.only(top: 12, bottom: 50),
            itemBuilder: (ctx, index) => _Tile(data[index]),
            itemCount: data.length,
            separatorBuilder: (ctx, index) => Divider(),
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

    return ListTile(
      title: Text(
        woTaskRequestNo,
        style: TextStyle(fontWeight: FontWeight.bold),
      ),
      onTap: () => Navigator.pushNamed(
        context,
        routeMaterialRequestView,
        arguments: RequestTask.fromJson(value),
      ),
      subtitle: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          text(value: checkoutBy, top: 8.0),
          text(value: checkoutTime),
          text(value: "Total Item : $total"),
        ],
      ),
      trailing: state(woTaskNo),
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

  Widget state(String no) {
    return Container(
      height: 40,
      width: 160,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        color: colorTheme3,
      ),
      child: Center(
        child: Text(
          no,
          style: TextStyle(color: Colors.white, fontSize: 14),
        ),
      ),
    );
  }
}