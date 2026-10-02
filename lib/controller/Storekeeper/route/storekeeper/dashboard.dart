import 'package:flutter/material.dart';
import 'package:GEMS/utils/network.dart';
import 'package:GEMS/view/gems_chrome.dart';
import 'package:rxdart/rxdart.dart';
import '../../../../main.dart';

class MyDashboard extends StatelessWidget {
  // Explicitly type the BehaviorSubject to hold dynamic data.
  final BehaviorSubject<dynamic> _data = BehaviorSubject<dynamic>();

  MyDashboard({super.key}) {
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
              _card(<TableRow>[
                row("TOTAL ITEM : ", totalItem.toString()),
                row("TOTAL QUANTITY : ", totalPartQuantity.toString()),
                row("TOTAL STORE : ", totalStore.toString()),
              ]),
              const SizedBox(height: 12),
              _card(<TableRow>[
                row("TOTAL VALUE : ", "RM $totalValue"),
              ]),
              const SizedBox(height: 12),
              _card(<TableRow>[
                row("LOW STOCK : ", "$totalLow Item(s)"),
                row("LOCKED STOCK : ", "$totalPartLocked Item(s)"),
                row("AVAILABLE : ", "$totalPartAvailable Item(s)"),
              ]),
            ],
          ),
        );
      },
    );
  }

  Future<void> refresh({BuildContext? context}) {
    final Provider provider = Provider(fetchURL: "/part/mobile_dashboard");
    if (context != null) {
      provider.context = context;
    }
    return provider.getJson(url: "/part/mobile_dashboard").then((value) {
      _data.sink.add(value);
    }).catchError((error) {
      debugPrint("Dashboard refresh error: $error");
      // Add empty data to prevent infinite loading
      _data.sink.add({
        "totalItem": 0,
        "totalLow": 0,
        "totalPartAvailable": 0,
        "totalPartLocked": 0,
        "totalPartQuantity": 0,
        "totalStore": 0,
        "totalValue": "0.00",
      });
    });
  }

  Widget _card(List<TableRow> rows) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(GemsChrome.radius),
      child: DecoratedBox(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(GemsChrome.radius),
          border: Border.all(color: GemsChrome.border),
        ),
        child: Column(
          children: [
            const ColoredBox(
              color: GemsChrome.teal,
              child: SizedBox(height: 3, width: double.infinity),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              child: Table(
                columnWidths: const {0: FractionColumnWidth(0.5)},
                children: rows,
              ),
            ),
          ],
        ),
      ),
    );
  }

  TableRow row(String title, String value) {
    return TableRow(
      children: [
        TableCell(
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 8.0),
            child: Text(
              title,
              style: GemsChrome.body(weight: FontWeight.w600, color: GemsChrome.textSoft),
            ),
          ),
        ),
        TableCell(
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 8.0),
            child: Text(value, style: GemsChrome.body(weight: FontWeight.w600)),
          ),
        ),
      ],
    );
  }
}
