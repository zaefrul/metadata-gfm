import 'package:flutter/material.dart';
import 'package:gfm_gems/controller/Storekeeper/utils/widget/dialog.dart';

import 'ElectricBill.dart';
import 'WaterBill.dart';

class UtilsBill {
  final Function onRefresh;

  UtilsBill(this.onRefresh);

  void selectType(BuildContext context) {
    showDialog(
      context: context,
      builder: (_) => CustomDialog(
        buttonText: "Electric",
        buttonText2: "Water",
        description: 'Please select your type of utilities',
        title: "Add Utilities",
        secondButton: true,
        okayTapped: () => showElectric(context, isDaily: true),
        secondTapped: () => showWater(context, isDaily: true),
        image: Image.asset("assets/icon_trans.png", height: 40),
      ),
    );
  }

  void selectFrequency(BuildContext context,
      {bool isWater = false, bool isElectric = false}) {
    Navigator.pop(context);
    showDialog(
      context: context,
      builder: (_) => CustomDialog(
        buttonText: "Daily",
        buttonText2: "Monthly",
        description: 'Please select your type of frequency',
        title: "Select Frequency",
        secondButton: true,
        okayTapped: () {
          Navigator.pop(context);
          if (isWater) showWater(context, isDaily: true);
          if (isElectric) showElectric(context, isDaily: true);
        },
        secondTapped: () {
          Navigator.pop(context);
          if (isWater) showWater(context, isMonthly: true);
          if (isElectric) showElectric(context, isMonthly: true);
        },
        image: Image.asset(
          "assets/icon_trans.png",
          height: 40,
        ),
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

  void showElectric(BuildContext context,
      {bool isMonthly = false, bool isDaily = false}) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) =>
            ElectricBillScreen(isMontly: isMonthly, isDaily: isDaily),
      ),
    ).whenComplete(onRefresh);
  }
}
