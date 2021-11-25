import 'package:flutter/material.dart';
import 'package:gfm_gems/controller/Storekeeper/utils/constant.dart';
import 'package:gfm_gems/model/complaint.dart';
import 'package:gfm_gems/utils/network.dart';
import 'package:rxdart/subjects.dart';

class CheckOutList extends StatelessWidget {
  final BehaviorSubject<List> _data = BehaviorSubject<List>.seeded([]);

  CheckOutList() {
    refresh();
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<Object>(
      stream: _data.stream,
      builder: (context, snapshot) {
        if (snapshot.data == null)
          return Center(child: CircularProgressIndicator());

        final data = snapshot.data as List;

        return RefreshIndicator(
          onRefresh: () => refresh(context: context),
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

  Future<void> refresh({BuildContext context}) {
    final Provider _provider =
        Provider(fetchURL: "/wo_request/list_mobile_check_out");
    if (context != null) _provider.context = context;
    return _provider.getJson().then((value) {
      // final List values = value as List;
      // values.sort((a, b) => b["checkOutTime"].compareTo(a["checkOutTime"]));
      _data.sink.add(value);
    });
  }
}

class _Tile extends StatelessWidget {
  final Map value;

  _Tile(this.value);

  @override
  Widget build(BuildContext context) {
    final checkoutBy = value["checkOutBy"];
    final checkoutTime = value["checkOutTime"];
    final total = value["total"];
    final woTaskNo = value["woTaskNo"];
    final woTaskRequestId = value["woTaskRequestId"];
    final woTaskRequestNo = value["woTaskRequestNo"];

    return ListTile(
        title: Text(woTaskRequestNo,
            style: TextStyle(fontWeight: FontWeight.bold)),
        onTap: () => Navigator.pushNamed(context, routeMaterialRequestView,
            arguments: RequestTask.fromJson(value)),
        subtitle:
            Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          text(value: checkoutBy, top: 8.0),
          text(value: checkoutTime),
          text(value: "Total Item : $total"),
        ]),
        trailing: state(woTaskNo));
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
