import 'package:flutter/material.dart';
import 'package:gfm_gems/controller/Storekeeper/utils/constant.dart';
import 'package:gfm_gems/utils/network.dart';
import 'package:rxdart/subjects.dart';

class CheckInList extends StatelessWidget {
  final BehaviorSubject<List> _data = BehaviorSubject<List>.seeded([]);

  CheckInList() {
    refresh();
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<dynamic>(
        stream: _data.stream,
        builder: (context, snapshot) {
          if (snapshot.data == null)
            return Center(child: CircularProgressIndicator());

          final data = snapshot.data as List;

          return RefreshIndicator(
            onRefresh: () => refresh(context: context),
            child: ListView.separated(
              shrinkWrap: true,
              primary: true,
              padding: EdgeInsets.only(top: 12, bottom: 50),
              itemBuilder: (ctx, index) => _Tile(data[index]),
              itemCount: data.length,
              separatorBuilder: (ctx, index) => Divider(),
            ),
          );
        });
  }

  Future<void> refresh({BuildContext context}) {
    final Provider _provider = Provider(fetchURL: "/do/list_mobile_check_in");
    if (context != null) _provider.context = context;

    return _provider.getJson().then((value) {
      // final List values = value as List;
      // values.sort((a, b) => b["doDate"].compareTo(a["doDate"]));
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

  _Tile(Map value)
      : this.doDate = value["doDate"],
        this.doId = value["doId"],
        this.doNo = value["doNo"],
        this.doTimestamp = value["doTimestamp"],
        this.supplierName = value["supplierName"],
        this.totalCost = value["totalCost"],
        this.userFirstName = value["userFirstName"];

  @override
  Widget build(BuildContext context) {
    return ListTile(
        title: Text(doNo, style: TextStyle(fontWeight: FontWeight.bold)),
        onTap: () =>
            Navigator.pushNamed(context, routeCheckInInfo, arguments: doId),
        subtitle:
            Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          text(value: userFirstName, top: 8.0),
          text(value: doDate),
          text(value: supplierName),
        ]),
        trailing: state(totalCost));
  }

  Widget text({@required String value, double top = 3.0}) {
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
          style: TextStyle(color: Colors.white, fontSize: 16),
        ),
      ),
    );
  }
}
