import 'package:flutter/material.dart';
import 'package:GEMS/controller/Storekeeper/utils/constant.dart';
import 'package:GEMS/controller/Utilities/Bloc/bloc.dart';
import 'package:GEMS/model/meter.dart';
import 'package:GEMS/view/drawer.dart';
import 'package:toast/toast.dart';
import 'util.dart';
import 'MonthlyReading.dart' as page;

class UtilitiesHome extends StatefulWidget {
  const UtilitiesHome({Key? key}) : super(key: key);

  @override
  _UtilitiesHomeState createState() => _UtilitiesHomeState();
}

class _UtilitiesHomeState extends State<UtilitiesHome> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  final Bloc bloc = Bloc();

  _UtilitiesHomeState() {
    bloc.fetch(api.MetersE);
    bloc.fetch(api.MetersW);
  }

  @override
  void dispose() {
    bloc.dispose();
    super.dispose();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    bloc.err$.listen((event) => Toast.show(event, duration: 4));
  }

  @override
  Widget build(BuildContext context) {
    ToastContext().init(context);
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        key: _scaffoldKey,
        appBar: AppBar(
          title: Text(
            "Utilities",
            style: TextStyle(color: colorTheme3),
          ),
          backgroundColor: Colors.white,
          centerTitle: true,
          actions: [
            _BuildAddButton(onRefresh: () {
              bloc.fetch(api.ReadingE);
              bloc.fetch(api.ReadingW);
            })
          ],
          leading: IconButton(
            icon: Image.asset("assets/icon_trans.png", width: 30.0),
            color: Colors.black,
            onPressed: () {
              _scaffoldKey.currentState!.openDrawer();
            },
          ),
          bottom: TabBar(
            indicatorColor: colorTheme2,
            tabs: [
              Tab(icon: Image.asset("assets/drop.png", width: 24.0)),
              Tab(icon: Image.asset("assets/flash.png", width: 24.0)),
            ],
          ),
        ),
        drawer: BuildDrawer(() => Navigator.pop(context)),
        body: TabBarView(
          children: [
            ListReading(bloc, bloc.mw$, isWater: true),
            ListReading(bloc, bloc.me$, isElectric: true),
          ],
        ),
      ),
    );
  }
}

class _BuildAddButton extends StatelessWidget {
  final VoidCallback onRefresh;

  const _BuildAddButton({Key? key, required this.onRefresh}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(4.0),
      child: IconButton(
        icon: Icon(Icons.add, size: 32),
        onPressed: () => UtilsBill(onRefresh).selectType(context),
      ),
    );
  }
}

class ListReading extends StatelessWidget {
  final Stream<List<Meter>> stream;
  final Bloc bloc;
  final bool isWater;
  final bool isElectric;

  const ListReading(
    this.bloc,
    this.stream, {
    this.isElectric = false,
    this.isWater = false,
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<List<Meter>>(
      stream: stream,
      builder: (_, snapshot) {
        if (!snapshot.hasData) {
          return Center(child: CircularProgressIndicator());
        }
        final meters = snapshot.data!;
        return RefreshIndicator(
          onRefresh: () async =>
              isWater ? bloc.fetch(api.MetersW) : bloc.fetch(api.MetersE),
          child: ListView.separated(
            padding: EdgeInsets.symmetric(vertical: 12),
            itemBuilder: (_, i) => TileMeter(
              bloc,
              meters[i],
              isWater: isWater,
              isElectric: isElectric,
            ),
            itemCount: meters.length,
            separatorBuilder: (_, __) =>
                Divider(color: colorTheme3.withOpacity(0.7)),
          ),
        );
      },
    );
  }
}

class TileMeter extends StatelessWidget {
  final Meter value;
  final Bloc bloc;
  final bool isWater;
  final bool isElectric;

  const TileMeter(
    this.bloc,
    this.value, {
    this.isElectric = false,
    this.isWater = false,
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    String readingType = "";
    if (isWater) {
      readingType = "35m³";
    } else if (isElectric) {
      readingType = "kWh";
    }
    return ListTile(
      title: Text(
        value.meterName,
        style: TextStyle(fontWeight: FontWeight.bold),
      ),
      subtitle: Padding(
        padding: const EdgeInsets.symmetric(vertical: 8.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text("Monthly Total(RM) : " + (value.monthlyTotalRm ?? "N/A")),
            Padding(
              padding: EdgeInsets.symmetric(vertical: 4),
              child: Text("Daily Total($readingType) : " + (value.dailyLatestReading ?? "N/A")),
            ),
            Text("Reading($readingType) : " + (value.dailyLatestReading ?? "N/A")),
          ],
        ),
      ),
      trailing: Container(
        height: 40,
        width: 120,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(5),
          color: colorTheme2,
        ),
        child: Text(
          value.meterLocation,
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
      ),
      onTap: () {
        bloc.sMeter = value;
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => page.ListReading(
              bloc,
              value,
              isWater: isWater,
              isElectric: isElectric,
            ),
          ),
        );
      },
    );
  }
}
