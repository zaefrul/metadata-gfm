import 'package:flutter/material.dart';
import '../utils/reference.dart';
import 'package:auto_size_text/auto_size_text.dart';

Widget bar(
  GlobalKey<ScaffoldState> key, {
  VoidCallback? onTap,
  PopupMenuButton? navigateTo,
  required String text,
  bool search = false,
  TabController? controller,
  bool dimmer = false,
  String tabtitle = "Scheduled Maintenance",
  bool isSupervisor = false,
}) {
  final Color dimmerColor = Colors.black.withOpacity(0.5);

  final List<Widget>? actions = search
      ? [
          GestureDetector(
            child: Icon(
              Icons.search,
              color: colorTheme3,
              size: 30,
            ),
            onTap: onTap,
          ),
          SizedBox(width: 20),
        ]
      : navigateTo != null
          ? [navigateTo]
          : null;

  final Widget titleWidget = AutoSizeText(
    text,
    minFontSize: 12,
    maxLines: 1,
    overflow: TextOverflow.ellipsis,
    style: TextStyle(color: colorTheme3, fontWeight: FontWeight.bold),
  );

  final Widget? tab = controller == null
      ? null
      : TabBar(
          labelColor: colorTheme3,
          indicatorColor: dimmer ? colorTheme2.withOpacity(0.5) : colorTheme2,
          controller: controller,
          tabs: <Widget>[
            Tab(text: tabtitle),
            Tab(text: "My Task"),
            if (text == "Work Order" && isSupervisor) Tab(text: "MR Approval"),
          ],
        );

  return AppBar(
    elevation: dimmer ? 0 : 4,
    backgroundColor: dimmer ? dimmerColor : Colors.white,
    leading: IconButton(
      icon: Opacity(
        opacity: dimmer ? 0.5 : 1,
        child: Image.asset("assets/icon_trans.png", width: 30.0),
      ),
      color: Colors.black,
      onPressed: () => key.currentState?.openDrawer(),
    ),
    title: titleWidget,
    centerTitle: true,
    actions: actions,
    bottom: tab as PreferredSizeWidget?,
  );
}
