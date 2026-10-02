import 'package:flutter/material.dart';
import 'package:GEMS/view/gems_chrome.dart';
import 'package:GEMS/controller/Storekeeper/utils/constant.dart';

class StockInList extends StatelessWidget {
  const StockInList({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: GemsChrome.page,
      appBar: gemsAppBar(
          title: const Text('New Check In')),
      body: ListView.separated(
        padding: const EdgeInsets.fromLTRB(12, 12, 12, 50),
        itemBuilder: (ctx, index) => _Tile("RM10,000.00"),
        itemCount: 2,
        separatorBuilder: (ctx, index) => const SizedBox(height: 10),
      ),
    );
  }
}

class _Tile extends StatelessWidget {
  final String price;

  const _Tile(this.price);

  @override
  Widget build(BuildContext context) {
    return GemsAccentCard(
      accent: GemsChrome.primary,
      onTap: () => Navigator.pushNamed(context, routeCheckInInfo, arguments: true),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(12, 12, 12, 12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    'RFQ00045',
                    style: GemsChrome.body(size: 15, weight: FontWeight.w600),
                  ),
                ),
                state,
              ],
            ),
            const SizedBox(height: 6),
            text('Mohd Syafiq'),
            text('2 / 5 / 2020'),
            text('PR000312'),
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

  Widget get state {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        color: GemsChrome.primarySoft,
      ),
      child: Text(
        price,
        style: GemsChrome.body(
          size: 12,
          weight: FontWeight.w600,
          color: GemsChrome.primary,
        ),
      ),
    );
  }
}
