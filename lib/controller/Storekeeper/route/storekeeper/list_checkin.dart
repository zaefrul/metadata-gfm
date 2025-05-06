import 'package:flutter/material.dart';
import 'package:gfm_gems/controller/Storekeeper/utils/constant.dart';
import 'package:gfm_gems/utils/network.dart';
import 'package:rxdart/rxdart.dart';
import '../../../../main.dart';

class CheckInList extends StatelessWidget {
  // Explicitly specify that the subject holds a List<dynamic>.
  final BehaviorSubject<List<dynamic>> _data = BehaviorSubject<List<dynamic>>.seeded([]);

  CheckInList() {
    refresh();
  }

  @override
  Widget build(BuildContext context) {
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
    final Provider _provider = Provider(fetchURL: "/do/list_mobile_check_in");
    _provider.context = context!;
    return _provider.getJson(url: "/do/list_mobile_check_in").then((value) {
      _data.sink.add(value);
    });
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
          "RM " + price,
          style: const TextStyle(color: Colors.white, fontSize: 16),
        ),
      ),
    );
  }
}
