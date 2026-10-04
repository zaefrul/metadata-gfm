import 'package:flutter/material.dart';
import 'package:GEMS/view/gems_chrome.dart';
import 'ElectricBill.dart';
import 'WaterBill.dart';
import '../../main.dart';

class UtilsBill {
  final VoidCallback onRefresh;

  UtilsBill(this.onRefresh);

  void selectType(BuildContext context) {
    showDialog(
      context: navigatorKey.currentContext!,
      builder: (dialogContext) => AlertDialog(
        title: Text('Add Utilities', style: GemsChrome.heading(size: 18)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              'Please select your type of utilities',
              style: GemsChrome.body(),
            ),
            const SizedBox(height: 16),
            FilledButton.icon(
              style: FilledButton.styleFrom(backgroundColor: GemsChrome.primary),
              onPressed: () {
                Navigator.pop(dialogContext);
                showElectric(context);
              },
              icon: const Icon(Icons.bolt, color: Colors.white),
              label: Text(
                'Electric',
                style: GemsChrome.body(weight: FontWeight.w600, color: Colors.white),
              ),
            ),
            const SizedBox(height: 8),
            FilledButton.icon(
              style: FilledButton.styleFrom(backgroundColor: GemsChrome.primary),
              onPressed: () {
                Navigator.pop(dialogContext);
                showWater(context, isDaily: true);
              },
              icon: const Icon(Icons.water_drop, color: Colors.white),
              label: Text(
                'Water',
                style: GemsChrome.body(weight: FontWeight.w600, color: Colors.white),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: Text('Cancel', style: GemsChrome.body(color: GemsChrome.textSoft)),
          ),
        ],
      ),
    );
  }

  void selectFrequency(BuildContext context, {bool isWater = false}) {
    showDialog(
      context: navigatorKey.currentContext!,
      builder: (dialogContext) => AlertDialog(
        title: Text('Select Frequency', style: GemsChrome.heading(size: 18)),
        content: Text(
          'Please select your type of frequency',
          style: GemsChrome.body(),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: Text('Cancel', style: GemsChrome.body(color: GemsChrome.textSoft)),
          ),
          FilledButton(
            style: FilledButton.styleFrom(backgroundColor: GemsChrome.primary),
            onPressed: () {
              Navigator.pop(dialogContext);
              if (isWater) showWater(context, isDaily: true);
            },
            child: Text(
              'Daily',
              style: GemsChrome.body(weight: FontWeight.w600, color: Colors.white),
            ),
          ),
          FilledButton(
            style: FilledButton.styleFrom(backgroundColor: GemsChrome.primary),
            onPressed: () {
              Navigator.pop(dialogContext);
              if (isWater) showWater(context, isMonthly: true);
            },
            child: Text(
              'Monthly',
              style: GemsChrome.body(weight: FontWeight.w600, color: Colors.white),
            ),
          ),
        ],
      ),
    );
  }

  void showWater(BuildContext context,
      {bool isMonthly = false, bool isDaily = false}) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => WaterBillScreen(isMontly: isMonthly, isDaily: isDaily),
      ),
    ).whenComplete(onRefresh);
  }

  void showElectric(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => const ElectricBillScreen(),
      ),
    ).whenComplete(onRefresh);
  }
}
