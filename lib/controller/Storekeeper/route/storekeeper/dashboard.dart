import 'package:flutter/material.dart';
import 'package:gfm_gems/utils/network.dart';
import 'package:rxdart/subjects.dart';

class MyDashboard extends StatelessWidget {
  final BehaviorSubject _data = BehaviorSubject();

  MyDashboard() {
    refresh();
  }
  @override
  Widget build(BuildContext context) {
    return StreamBuilder<dynamic>(
        stream: _data.stream,
        builder: (context, snapshot) {
          if (snapshot.data == null)
            return Center(child: CircularProgressIndicator());

          final data = snapshot.data;
          final totalItem = data["totalItem"];
          final totalLow = data["totalLow"];
          final totalPartAvailable = data["totalPartAvailable"];
          final totalPartLocked = data["totalPartLocked"];
          final totalPartQuantity = data["totalPartQuantity"];
          final totalStore = data["totalStore"];
          final totalValue = data["totalValue"];

          return RefreshIndicator(
            onRefresh: () => refresh(context: context),
            child: ListView(
              padding:
                  const EdgeInsets.symmetric(horizontal: 12.0, vertical: 12.0),
              children: <Widget>[
                Card(
                    elevation: 6,
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 16.0, vertical: 12.0),
                      child: Table(
                        columnWidths: {
                          0: FractionColumnWidth(.5),
                        },
                        children: <TableRow>[
                          row("TOTAL ITEM : ", totalItem),
                          row("TOTAL QUANTITY : ", totalPartQuantity),
                          row("TOTAL STORE : ", totalStore),
                        ],
                      ),
                    )),
                SizedBox(height: 12),
                // Card(
                //     elevation: 6,
                //     child: Padding(
                //       padding:
                //           const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
                //       child: Table(
                //         columnWidths: {
                //           0: FractionColumnWidth(.5),
                //         },
                //         children: <TableRow>[
                //           row("STORE A : ", "1000"),
                //           row("STORE B : ", "300"),
                //           row("STORE C : ", "76"),
                //         ],
                //       ),
                //     )),
                // SizedBox(height: 12),
                Card(
                    elevation: 6,
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 16.0, vertical: 12.0),
                      child: Table(
                        columnWidths: {
                          0: FractionColumnWidth(.5),
                        },
                        children: <TableRow>[
                          row("TOTAL VALUE : ", "RM $totalValue"),
                          // row("VALUE IN STORE : ", "RM 100,000.00"),
                          // row("USED VALUE : ", "RM 150,000.00"),
                        ],
                      ),
                    )),
                SizedBox(height: 12),
                Card(
                    elevation: 6,
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 16.0, vertical: 12.0),
                      child: Table(
                        columnWidths: {
                          0: FractionColumnWidth(.5),
                        },
                        children: <TableRow>[
                          row("LOW STOCK : ", "$totalLow Item(s)"),
                          row("LOCKED STOCK : ", "$totalPartLocked Item(s)"),
                          row("AVAILABLE : ", "$totalPartAvailable Item(s)"),
                        ],
                      ),
                    )),
              ],
            ),
          );
        });
  }

  Future<void> refresh({BuildContext context}) {
    final Provider _provider = Provider(fetchURL: "/part/mobile_dashboard");
    if (context != null) _provider.context = context;
    return _provider.getJson().then((value) => _data.sink.add(value));
  }

  TableRow row(String title, String value) {
    return TableRow(children: [
      TableCell(
          child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 8.0),
        child: Text(
          title,
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
      )),
      TableCell(
          child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 8.0),
        child: Text(value),
      )),
    ]);
  }
}
