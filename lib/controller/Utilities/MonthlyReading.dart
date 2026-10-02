import 'package:flutter/material.dart';
import 'package:GEMS/view/gems_chrome.dart';
import 'package:GEMS/controller/Utilities/Bloc/bloc.dart';
import 'package:GEMS/model/meter.dart';
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
  })  : streamMonthly = isWater
            ? bloc.rmw$
            : isElectric
                ? bloc.rme$
                : null,
        streamDaily = isWater
            ? bloc.rdw$
            : isElectric
                ? bloc.rde$
                : null {
    if (isWater) {
      bloc.fetch(api.ReadingMW);
      bloc.fetch(api.ReadingDW);
    } else if (isElectric) {
      bloc.fetch(api.ReadingME);
      bloc.fetch(api.ReadingDE);
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
                } else {
                  bloc.fetch(api.ReadingDE);
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
