import 'dart:async';

import 'package:flutter/material.dart';
import 'package:GEMS/controller/Utilities/Bloc/bloc.dart';
import 'package:GEMS/controller/Utilities/unsent_readings.dart';
import 'package:GEMS/data/local/offline_database.dart';
import 'package:GEMS/data/repository/utility_repository.dart';
import 'package:GEMS/model/energy.dart';
import 'package:GEMS/model/meter.dart';
import 'package:GEMS/utils/pending_sync_controller.dart';
import 'package:GEMS/view/drawer.dart';
import 'package:GEMS/view/gems_chrome.dart';
import 'package:GEMS/widgets/common/pending_sync_banner.dart';
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
  final UtilityRepository _utility = UtilityRepository.instance;
  late final StreamSubscription<String> _errors;

  @override
  void initState() {
    super.initState();
    bloc.fetch(api.MetersW);
    bloc.fetchEnergy();
    UtilitySyncScheduler.instance.kick();
    _errors = bloc.err$.listen((event) => Toast.show(event, duration: 4));
  }

  @override
  void dispose() {
    _errors.cancel();
    bloc.dispose();
    super.dispose();
  }

  Future<void> _retrySync() async {
    final report = await _utility.syncPending();
    if (report.needsLogin) {
      Toast.show(
        'Please log in again to sync ${report.remaining} readings.',
        duration: 4,
      );
      return;
    }
    if (report.stoppedOffline && report.sent == 0) {
      throw Exception('offline');
    }
    bloc.fetchEnergy();
    bloc.fetch(api.MetersW);
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
              bloc.fetchEnergy();
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
        body: Column(
          children: [
            StreamBuilder<bool>(
              stream: bloc.fromCache$,
              builder: (context, snapshot) {
                if (snapshot.data != true) return const SizedBox.shrink();
                return Padding(
                  padding: const EdgeInsets.fromLTRB(12, 12, 12, 0),
                  child: Text(
                    'Offline: showing last synced meters.',
                    style: GemsChrome.body(size: 13, color: GemsChrome.textSoft),
                  ),
                );
              },
            ),
            GestureDetector(
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const UnsentReadingsScreen()),
                );
              },
              child: PendingSyncIndicator(
                controller: PendingSyncController(
                  pendingCount$: _utility.unsentCount$,
                  retry: _retrySync,
                ),
              ),
            ),
            Expanded(
              child: TabBarView(
                children: [
                  ListReading(bloc, bloc.mw$, isWater: true),
                  EnergyMeterList(bloc: bloc),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _BuildAddButton extends StatelessWidget {
  final VoidCallback onRefresh;

  const _BuildAddButton({required this.onRefresh});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(4.0),
      child: IconButton(
        icon: const Icon(Icons.add, size: 32),
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
        if (meters.isEmpty) {
          return const Center(child: Text('No meters yet'));
        }
        return RefreshIndicator(
          onRefresh: () async => bloc.fetch(api.MetersW),
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

class EnergyMeterList extends StatelessWidget {
  const EnergyMeterList({super.key, required this.bloc});

  final Bloc bloc;

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<List<EnergyMeter>>(
      stream: bloc.energyMeters$,
      builder: (context, metersSnap) {
        final meters = metersSnap.data ?? const <EnergyMeter>[];
        return StreamBuilder<EnergyMonth?>(
          stream: bloc.energyMonth$,
          builder: (context, monthSnap) {
            if (meters.isEmpty) {
              return const Center(child: Text('No electricity meters yet'));
            }
            final month = monthSnap.data;
            return RefreshIndicator(
              onRefresh: () => bloc.fetchEnergy(),
              color: GemsChrome.primary,
              child: ListView.separated(
                padding: const EdgeInsets.fromLTRB(12, 12, 12, 24),
                itemCount: meters.length,
                separatorBuilder: (_, __) => const SizedBox(height: 10),
                itemBuilder: (_, i) => _EnergyMeterTile(
                  meter: meters[i],
                  month: month,
                ),
              ),
            );
          },
        );
      },
    );
  }
}

class _EnergyMeterTile extends StatelessWidget {
  const _EnergyMeterTile({required this.meter, required this.month});

  final EnergyMeter meter;
  final EnergyMonth? month;

  @override
  Widget build(BuildContext context) {
    final latest = month?.latestFor(meter.meterId);
    final total = month?.totalFor(meter.meterId);
    return StreamBuilder<List<UtilityPendingReading>>(
      stream: UtilityRepository.instance.unsent$,
      builder: (context, snapshot) {
        final waiting = (snapshot.data ?? const <UtilityPendingReading>[])
            .where((row) => row.kind == 'energy_reading' && _meterId(row) == meter.meterId)
            .length;
        return GemsAccentCard(
          accent: GemsChrome.primary,
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => page.EnergyMeterDaily(meter: meter),
              ),
            );
          },
          child: Padding(
            padding: const EdgeInsets.all(12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  meter.meterName,
                  style: GemsChrome.body(size: 15, weight: FontWeight.w600),
                ),
                if (meter.meterDesc.isNotEmpty) ...[
                  const SizedBox(height: 4),
                  Text(
                    meter.meterDesc,
                    style: GemsChrome.body(size: 13, color: GemsChrome.textSoft),
                  ),
                ],
                const SizedBox(height: 8),
                Text(
                  latest == null
                      ? 'Latest reading: —'
                      : 'Latest reading: ${latest.cell.cumulativeKwh} kWh on ${latest.date}',
                  style: GemsChrome.body(size: 13, color: GemsChrome.textSoft),
                ),
                const SizedBox(height: 4),
                Text(
                  total == null
                      ? 'This month: —'
                      : 'This month: $total kWh',
                  style: GemsChrome.body(size: 13, color: GemsChrome.textSoft),
                ),
                if (waiting > 0) ...[
                  const SizedBox(height: 4),
                  Text(
                    'Waiting to send: $waiting',
                    style: GemsChrome.body(size: 13, weight: FontWeight.w600, color: GemsChrome.primary),
                  ),
                ],
              ],
            ),
          ),
        );
      },
    );
  }

  String _meterId(UtilityPendingReading row) {
    final summary = row.payloadJson;
    final marker = '"meterId":"';
    final start = summary.indexOf(marker);
    if (start < 0) return '';
    final from = start + marker.length;
    final end = summary.indexOf('"', from);
    if (end < 0) return '';
    return summary.substring(from, end);
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
    final readingType = isWater ? 'm³' : 'kWh';
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
              'Daily total ($readingType): ${value.dailyTotal ?? "N/A"}',
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
