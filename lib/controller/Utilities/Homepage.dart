import 'package:flutter/material.dart';
import 'package:GEMS/controller/Utilities/Bloc/bloc.dart';
import 'package:GEMS/model/meter.dart';
import 'package:GEMS/view/drawer.dart';
import 'package:GEMS/view/gems_chrome.dart';
import 'package:toast/toast.dart';
import 'util.dart';
import 'MonthlyReading.dart' as page;

class UtilitiesHome extends StatefulWidget {
  const UtilitiesHome({super.key});

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
        backgroundColor: GemsChrome.page,
        appBar: gemsAppBar(
          title: const Text('Utilities'),
          actions: [
            _BuildAddButton(onRefresh: () {
              bloc.fetch(api.ReadingE);
              bloc.fetch(api.ReadingW);
            })
          ],
          bottom: TabBar(
            indicatorColor: GemsChrome.teal,
            indicatorWeight: 3,
            labelColor: GemsChrome.primary,
            unselectedLabelColor: GemsChrome.textSoft,
            dividerColor: GemsChrome.border,
            tabs: const [
              Tab(icon: Icon(Icons.water_drop_outlined)),
              Tab(icon: Icon(Icons.bolt_outlined)),
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

  const _BuildAddButton({super.key, required this.onRefresh});

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
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<List<Meter>>(
      stream: stream,
      builder: (_, snapshot) {
        if (!snapshot.hasData) {
          return const Center(child: CircularProgressIndicator(color: GemsChrome.primary));
        }
        final meters = snapshot.data!;
        return RefreshIndicator(
          onRefresh: () async =>
              isWater ? bloc.fetch(api.MetersW) : bloc.fetch(api.MetersE),
          color: GemsChrome.primary,
          child: ListView.separated(
            padding: const EdgeInsets.fromLTRB(12, 12, 12, 24),
            itemBuilder: (_, i) => TileMeter(
              bloc,
              meters[i],
              isWater: isWater,
              isElectric: isElectric,
            ),
            itemCount: meters.length,
            separatorBuilder: (_, __) => const SizedBox(height: 10),
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
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    String readingType = "";
    if (isWater) {
      readingType = "35m³";
    } else if (isElectric) {
      readingType = "kWh";
    }
    return GemsAccentCard(
      accent: GemsChrome.primary,
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
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    value.meterName,
                    style: GemsChrome.body(size: 15, weight: FontWeight.w600),
                  ),
                ),
                const SizedBox(width: 8),
                Flexible(
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: GemsChrome.primarySoft,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      value.meterLocation,
                      overflow: TextOverflow.ellipsis,
                      style: GemsChrome.body(
                        size: 12,
                        weight: FontWeight.w600,
                        color: GemsChrome.primary,
                      ),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              'Monthly total (RM): ${value.monthlyTotalRm ?? "N/A"}',
              style: GemsChrome.body(size: 13, color: GemsChrome.textSoft),
            ),
            const SizedBox(height: 4),
            Text(
              'Daily total ($readingType): ${value.dailyLatestReading ?? "N/A"}',
              style: GemsChrome.body(size: 13, color: GemsChrome.textSoft),
            ),
            const SizedBox(height: 4),
            Text(
              'Reading ($readingType): ${value.dailyLatestReading ?? "N/A"}',
              style: GemsChrome.body(size: 13, color: GemsChrome.textSoft),
            ),
          ],
        ),
      ),
    );
  }
}
