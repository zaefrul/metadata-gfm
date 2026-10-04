import 'package:flutter/material.dart';
import 'package:GEMS/view/gems_chrome.dart';
import 'package:GEMS/controller/Utilities/Bloc/bloc.dart';
import 'package:GEMS/data/repository/utility_repository.dart';
import 'package:GEMS/model/energy.dart';
import 'package:GEMS/model/meter.dart';
import 'package:intl/intl.dart';
import 'package:photo_view/photo_view.dart';

class ListReading extends StatelessWidget {
  final Bloc bloc;
  final Meter reading;
  final bool isWater;
  final bool isElectric;
  final Stream<List<Reading>>? streamMonthly;
  final Stream<List<Reading>>? streamDaily;

  ListReading(
    this.bloc,
    this.reading, {super.key, 
    this.isWater = false,
    this.isElectric = false,
  })  : streamMonthly = isWater ? bloc.rmw$ : null,
        streamDaily = isWater ? bloc.rdw$ : null {
    if (isWater) {
      bloc.fetch(api.ReadingMW);
      bloc.fetch(api.ReadingDW);
    }
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 1,
      child: Scaffold(
        backgroundColor: GemsChrome.page,
        appBar: gemsAppBar(
          title: Text("${reading.meterLocation} : Daily Reading"),
          // Uncomment below to enable a tab bar if needed.
          // bottom: TabBar(
          //   indicatorColor: colorTheme2,
          //   tabs: [
          //     Tab(
          //         child: Text(
          //       "Daily",
          //       style: TextStyle(color: Colors.black),
          //     )),
          //   ],
          // ),
        ),
        body: StreamBuilder<List<Reading>>(
          stream: streamDaily,
          builder: (context, s) {
            if (!s.hasData) {
              return const Center(child: CircularProgressIndicator(color: GemsChrome.primary));
            }
            final List<Reading> data = s.data!;
            return RefreshIndicator(
              onRefresh: () async {
                if (isWater) {
                  bloc.fetch(api.ReadingDW);
                }
              },
              color: GemsChrome.primary,
              child: ListView.separated(
                padding: const EdgeInsets.fromLTRB(12, 12, 12, 24),
                itemCount: data.length,
                itemBuilder: (context, i) => TileDaily(data[i], isWater: isWater),
                separatorBuilder: (context, index) => const SizedBox(height: 10),
              ),
            );
          },
        ),
      ),
    );
  }
}

class TileMonthly extends StatelessWidget {
  final Reading value;
  final Bloc bloc;
  final bool isWater;
  final bool isElectric;

  const TileMonthly(
    this.bloc,
    this.value, {super.key, 
    this.isElectric = false,
    this.isWater = false,
  });

  @override
  Widget build(BuildContext context) {
    return GemsAccentCard(
      accent: GemsChrome.primary,
      onTap: () => Navigator.of(context).push(
        MaterialPageRoute(
          builder: (_) => ViewImage(url: value.utilityImage ?? ''),
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    'Amount: RM ${value.utilityTotalRm ?? "0.00"}',
                    style: GemsChrome.body(size: 15, weight: FontWeight.w600),
                  ),
                ),
                _dateChip('${value.month} ${value.year}'),
              ],
            ),
            const SizedBox(height: 6),
            Text(
              'Total (kWh): ${value.utilityReading ?? "N/A"}',
              style: GemsChrome.body(size: 13, color: GemsChrome.textSoft),
            ),
            const SizedBox(height: 4),
            Text(
              'Max demand: ${value.utilityMaxDemand ?? "N/A"}',
              style: GemsChrome.body(size: 13, color: GemsChrome.textSoft),
            ),
          ],
        ),
      ),
    );
  }
}

class TileDaily extends StatelessWidget {
  final Reading value;
  final bool isWater;
  const TileDaily(this.value, {super.key, this.isWater = false});

  @override
  Widget build(BuildContext context) {
    return GemsAccentCard(
      accent: GemsChrome.primary,
      onTap: () => Navigator.of(context).push(
        MaterialPageRoute(
          builder: (_) => ViewImage(url: value.utilityImage ?? ''),
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    'Consumption: ${value.utilityReading ?? "N/A"}',
                    style: GemsChrome.body(size: 15, weight: FontWeight.w600),
                  ),
                ),
                _dateChip('${value.day} ${value.month} ${value.year}'),
              ],
            ),
            const SizedBox(height: 6),
            Text(
              'Timestamp: ${value.time}',
              style: GemsChrome.body(size: 13, color: GemsChrome.textSoft),
            ),
            const SizedBox(height: 4),
            Text(
              'By: ${value.utilityRecordedBy ?? "Unknown"}',
              style: GemsChrome.body(size: 13, color: GemsChrome.textSoft),
            ),
            if (isWater) ...[
              const SizedBox(height: 4),
              Text(
                'Submission shift: ${value.utilityShift ?? ""}',
                style: GemsChrome.body(size: 13, color: GemsChrome.textSoft),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

Widget _dateChip(String label) {
  return Container(
    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
    decoration: BoxDecoration(
      color: GemsChrome.primarySoft,
      borderRadius: BorderRadius.circular(20),
    ),
    child: Text(
      label,
      style: GemsChrome.body(size: 12, weight: FontWeight.w600, color: GemsChrome.primary),
    ),
  );
}

class EnergyMeterDaily extends StatefulWidget {
  const EnergyMeterDaily({super.key, required this.meter});

  final EnergyMeter meter;

  @override
  State<EnergyMeterDaily> createState() => _EnergyMeterDailyState();
}

class _EnergyMeterDailyState extends State<EnergyMeterDaily> {
  final _utility = UtilityRepository.instance;
  late DateTime _month;
  EnergyMonth? _grid;
  String? _error;
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    final now = DateTime.now();
    _month = DateTime(now.year, now.month);
    _load();
  }

  Future<void> _load() async {
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      final grid = await _utility.loadEnergyMonth(_month.year, _month.month);
      if (!mounted) return;
      setState(() {
        _grid = grid;
        _loading = false;
      });
    } catch (err) {
      if (!mounted) return;
      setState(() {
        _error = err.toString();
        _loading = false;
      });
    }
  }

  void _shift(int delta) {
    setState(() {
      _month = DateTime(_month.year, _month.month + delta);
    });
    _load();
  }

  @override
  Widget build(BuildContext context) {
    final label = DateFormat.yMMMM().format(_month);
    final days = _grid?.rows.where((row) {
          final cell = row.cellFor(widget.meter.meterId);
          return cell != null && cell.hasReading;
        }).toList() ??
        const <EnergyDay>[];
    return Scaffold(
      backgroundColor: GemsChrome.page,
      appBar: gemsAppBar(title: Text(widget.meter.meterName)),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(8, 8, 8, 0),
            child: Row(
              children: [
                IconButton(
                  onPressed: () => _shift(-1),
                  icon: const Icon(Icons.chevron_left),
                ),
                Expanded(
                  child: Text(
                    label,
                    textAlign: TextAlign.center,
                    style: GemsChrome.body(size: 16, weight: FontWeight.w600),
                  ),
                ),
                IconButton(
                  onPressed: () => _shift(1),
                  icon: const Icon(Icons.chevron_right),
                ),
              ],
            ),
          ),
          Expanded(
            child: _loading
                ? const Center(child: CircularProgressIndicator(color: GemsChrome.primary))
                : _error != null
                    ? Center(
                        child: Padding(
                          padding: const EdgeInsets.all(24),
                          child: Text(
                            'History needs a connection.\n$_error',
                            textAlign: TextAlign.center,
                            style: GemsChrome.body(color: GemsChrome.textSoft),
                          ),
                        ),
                      )
                    : RefreshIndicator(
                        onRefresh: _load,
                        color: GemsChrome.primary,
                        child: days.isEmpty
                            ? ListView(
                                children: [
                                  Padding(
                                    padding: const EdgeInsets.all(24),
                                    child: Text(
                                      'No readings this month.',
                                      textAlign: TextAlign.center,
                                      style: GemsChrome.body(color: GemsChrome.textSoft),
                                    ),
                                  ),
                                ],
                              )
                            : ListView.separated(
                                padding: const EdgeInsets.fromLTRB(12, 12, 12, 24),
                                itemCount: days.length,
                                separatorBuilder: (_, __) => const SizedBox(height: 10),
                                itemBuilder: (_, i) {
                                  final row = days[i];
                                  final cell = row.cellFor(widget.meter.meterId)!;
                                  return GemsAccentCard(
                                    accent: GemsChrome.primary,
                                    onTap: () {},
                                    child: Padding(
                                      padding: const EdgeInsets.all(12),
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            row.date,
                                            style: GemsChrome.body(size: 15, weight: FontWeight.w600),
                                          ),
                                          const SizedBox(height: 6),
                                          Text(
                                            'Cumulative: ${cell.cumulativeKwh ?? "—"} kWh',
                                            style: GemsChrome.body(size: 13, color: GemsChrome.textSoft),
                                          ),
                                          const SizedBox(height: 4),
                                          Text(
                                            'Consumption: ${cell.consumptionKwh ?? "—"} kWh',
                                            style: GemsChrome.body(size: 13, color: GemsChrome.textSoft),
                                          ),
                                          const SizedBox(height: 4),
                                          Text(
                                            'Max demand: ${cell.maxDemandKw ?? "—"}',
                                            style: GemsChrome.body(size: 13, color: GemsChrome.textSoft),
                                          ),
                                          if (cell.remark.isNotEmpty) ...[
                                            const SizedBox(height: 4),
                                            Text(
                                              cell.remark,
                                              style: GemsChrome.body(size: 13, color: GemsChrome.textSoft),
                                            ),
                                          ],
                                        ],
                                      ),
                                    ),
                                  );
                                },
                              ),
                      ),
          ),
        ],
      ),
    );
  }
}

class ViewImage extends StatelessWidget {
  final String url;

  const ViewImage({super.key, required this.url});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: gemsAppBar(title: const Text('View Image')),
      body: Container(child: PhotoView(imageProvider: NetworkImage(url))),
    );
  }
}
