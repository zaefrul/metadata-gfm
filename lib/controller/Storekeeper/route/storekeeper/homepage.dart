import 'package:flutter/material.dart';
import 'package:GEMS/controller/Storekeeper/route/storekeeper/list_checkin.dart';
import 'package:GEMS/controller/Storekeeper/route/storekeeper/list_stock.dart';
import 'package:GEMS/controller/Storekeeper/route/storekeeper/list_task.dart';
import 'package:GEMS/controller/Storekeeper/route/storekeeper/thresholdList.dart';
import 'package:GEMS/controller/Storekeeper/utils/bloc/bloc_inventory.dart';
import 'package:GEMS/controller/Storekeeper/utils/constant.dart';
import 'package:GEMS/controller/Storekeeper/utils/widget/FAB.dart';
import 'package:GEMS/controller/ReturnItem/bloc/bloc_return.dart';
import 'package:GEMS/view/drawer.dart';

import 'dashboard.dart';
import 'list_checkout.dart';

class Homepage extends StatefulWidget {
  const Homepage({super.key});
  @override
  _HomepageState createState() => _HomepageState();
}

class _HomepageState extends State<Homepage> with TickerProviderStateMixin {
  late final BlocInventory bloc;
  late final TabController _controller;
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  @override
  void initState() {
    super.initState();
    bloc = BlocInventory(context); // Pass the required argument
    _controller = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _controller.dispose();
    bloc.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return bloc == null
        ? Scaffold(
            appBar: AppBar(
              backgroundColor: Colors.white,
              title: const Text("Inventory"),
              centerTitle: true,
            ),
            body: Container(child: const Center(child: CircularProgressIndicator())),
          )
        : Scaffold(
            key: _scaffoldKey,
            appBar: PreferredSize(
              preferredSize: const Size.fromHeight(60),
              child: _AppBar(bloc, _scaffoldKey),
            ),
            drawer: BuildDrawer(() => Navigator.pop(context)),
            body: _Body(bloc),
            floatingActionButton: _controller.index == 0 ? _FloatingButton(bloc) : null,
          );
  }
}

class _AppBar extends StatelessWidget implements PreferredSizeWidget {
  final BlocInventory _bloc;
  final GlobalKey<ScaffoldState> _key;

  const _AppBar(this._bloc, this._key, {super.key});

  @override
  Widget build(BuildContext context) {
    return AppBar(
      title: StreamBuilder<String>(
        stream: _bloc.view$.cast<String>(),
        builder: (ctx, snapshot) =>
            Tab(text: "Inventory - ${snapshot.data?.toString() ?? ""}"),
      ),
      backgroundColor: Colors.white,
      centerTitle: true,
      leading: leading(_key),
      actions: [
        _ReturnsBadge(),
        const SizedBox(width: 8),
      ],
    );
  }

  Widget leading(GlobalKey<ScaffoldState> key) {
    return IconButton(
      icon: Image.asset("assets/icon_trans.png", height: 30, width: 30),
      padding: const EdgeInsets.all(14),
      onPressed: () => key.currentState?.openDrawer(),
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(60);
}

class _Body extends StatelessWidget {
  final BlocInventory _bloc;

  const _Body(this._bloc, {super.key});

  @override
  Widget build(BuildContext context) {
    return firstTab;
  }

  Widget get secondTab {
    return SingleChildScrollView(
      child: Column(
        children: <Widget>[
          _Header(_bloc),
          Container(
            width: double.infinity,
            color: colorTheme3,
            height: 0.5,
          ),
          TaskList(_bloc),
        ],
      ),
    );
  }

  Widget get firstTab {
    return StreamBuilder<String>(
        stream: _bloc.view$.cast<String>(),
        builder: (ctx, snapshot) {
          switch (snapshot.data) {
            case "My Stock":
              return MyStock(_bloc);
            case "My Check In":
              return CheckInList();
            case "My Check Out":
              return CheckOutList();
            case "My Dashboard":
              return MyDashboard();
            case "Threshold":
              return ThresholdListView();
            case "My Task":
              return secondTab;
            default:
              return Center(child: Text(snapshot.data ?? "My Stock"));
          }
        });
  }
}

class _Header extends StatelessWidget {
  final BlocInventory bloc;
  const _Header(this.bloc, {super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 70,
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: <Widget>[
          _DropdownFilter(bloc),
        ],
      ),
    );
  }
}

class _DropdownFilter extends StatelessWidget {
  final BlocInventory bloc;

  const _DropdownFilter(this.bloc, {super.key});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<String>(
      stream: bloc.selected$.cast<String>(),
      builder: (ctx, snapshot) => DropdownButton<String>(
        underline: Container(),
        value: snapshot.data,
        items: statuses
            .map((f) => DropdownMenuItem(value: f, child: Text(f)))
            .toList(),
        onChanged: (value) {
          if (value != null) {
            bloc.setSelected(value);
          }
        },
      ),
    );
  }
}

class _FloatingButton extends StatelessWidget {
  final BlocInventory bloc;

  const _FloatingButton(this.bloc, {super.key});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<String>(
      stream: bloc.view$.cast<String>(),
      builder: (ctx, snapshot) => Row(
        mainAxisAlignment: MainAxisAlignment.end,
        children: <Widget>[
          if (snapshot.data == "My Check In")
            FloatingActionButton(
              heroTag: "Submit",
              child: const Icon(Icons.add),
              onPressed: () =>
                  Navigator.pushNamed(context, routeMaterialCheckinRequest),
            ),
          if (snapshot.data == "My Check In") const SizedBox(width: 12),
          FloatingActionButton(
            heroTag: "FAB",
            backgroundColor: colorTheme1,
            onPressed: () {
              Navigator.push(
                context,
                PageRouteBuilder(
                  opaque: false,
                  pageBuilder: (ctx, _, __) => AwesomeFAB(),
                ),
              ).then((value) {
                if (value != null) {
                  // Handle Return Item navigation
                  if (value == "Return Item") {
                    Navigator.pushNamed(context, '/return-confirm-list');
                  } else {
                    bloc.setView(value);
                  }
                }
              });
            },
            child: const Icon(Icons.menu),
          ),
        ],
      ),
    );
  }
}

class _ReturnsBadge extends StatefulWidget {
  const _ReturnsBadge({super.key});

  @override
  _ReturnsBadgeState createState() => _ReturnsBadgeState();
}

class _ReturnsBadgeState extends State<_ReturnsBadge> {
  final ReturnItemBloc _bloc = ReturnItemBloc();

  @override
  void initState() {
    super.initState();
    _bloc.loadPendingReturns();
  }

  @override
  void dispose() {
    _bloc.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<int>(
      stream: _bloc.pendingCount$,
      builder: (context, snapshot) {
        int count = snapshot.data ?? 0;

        return IconButton(
          icon: Stack(
            children: [
              const Icon(
                Icons.assignment_return,
                color: colorTheme1,
                size: 28,
              ),
              if (count > 0)
                Positioned(
                  right: 0,
                  top: 0,
                  child: Container(
                    padding: const EdgeInsets.all(4),
                    decoration: BoxDecoration(
                      color: Colors.red,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    constraints: const BoxConstraints(
                      minWidth: 18,
                      minHeight: 18,
                    ),
                    child: Text(
                      count > 99 ? '99+' : count.toString(),
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                ),
            ],
          ),
          onPressed: () {
            Navigator.pushNamed(context, '/return-confirm-list');
          },
          tooltip: 'Pending Returns',
        );
      },
    );
  }
}
