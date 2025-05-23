import 'package:flutter/material.dart';
import 'package:GEMS/utils/network.dart';
import 'package:rxdart/rxdart.dart';
import '../../../../main.dart';

class MyDashboard extends StatelessWidget {
  // Explicitly type the BehaviorSubject to hold dynamic data.
  final BehaviorSubject<dynamic> _data = BehaviorSubject<dynamic>();

  MyDashboard() {
    refresh();
  }
  
  @override
  Widget build(BuildContext context) {
    return StreamBuilder<dynamic>(
      stream: _data.stream,
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return const Center(child: CircularProgressIndicator());
        }

        final data = snapshot.data;
        final totalItem = data["totalItem"];
        final totalLow = data["totalLow"];
        final totalPartAvailable = data["totalPartAvailable"];
        final totalPartLocked = data["totalPartLocked"];
        final totalPartQuantity = data["totalPartQuantity"];
        final totalStore = data["totalStore"];
        final totalValue = data["totalValue"];

        return RefreshIndicator(
          onRefresh: () => refresh(context: navigatorKey.currentContext!),
          child: ListView(
            padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 12.0),
            children: <Widget>[
              Card(
                elevation: 6,
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
                  child: Table(
                    columnWidths: const {0: FractionColumnWidth(0.5)},
                    children: <TableRow>[
                      row("TOTAL ITEM : ", totalItem.toString()),
                      row("TOTAL QUANTITY : ", totalPartQuantity.toString()),
                      row("TOTAL STORE : ", totalStore.toString()),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 12),
              Card(
                elevation: 6,
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
                  child: Table(
                    columnWidths: const {0: FractionColumnWidth(0.5)},
                    children: <TableRow>[
                      row("TOTAL VALUE : ", "RM " + totalValue.toString()),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 12),
              Card(
                elevation: 6,
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
                  child: Table(
                    columnWidths: const {0: FractionColumnWidth(0.5)},
                    children: <TableRow>[
                      row("LOW STOCK : ", "$totalLow Item(s)"),
                      row("LOCKED STOCK : ", "$totalPartLocked Item(s)"),
                      row("AVAILABLE : ", "$totalPartAvailable Item(s)"),
                    ],
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Future<void> refresh({BuildContext? context}) {
    final Provider provider = Provider(fetchURL: "/part/mobile_dashboard");
    provider.context = context!;
    return provider.getJson(url: "/part/mobile_dashboard").then((value) {
      _data.sink.add(value);
    });
  }

  TableRow row(String title, String value) {
    return TableRow(
      children: [
        TableCell(
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 8.0),
            child: Text(
              title,
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
          ),
        ),
        TableCell(
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 8.0),
            child: Text(value),
          ),
        ),
      ],
    );
  }
}
