import 'package:flutter/material.dart';
import 'package:gfm_gems/controller/Storekeeper/utils/constant.dart';
import 'package:gfm_gems/controller/Utilities/Bloc/bloc.dart';
import 'package:gfm_gems/model/meter.dart';
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
    this.reading, {
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
        appBar: AppBar(
          title: Text("${reading.meterLocation} : Daily Reading"),
          backgroundColor: Colors.white,
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
              return Center(child: CircularProgressIndicator());
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
              child: ListView.separated(
                padding: EdgeInsets.symmetric(vertical: 12),
                itemCount: data.length,
                itemBuilder: (context, i) => TileDaily(data[i], isWater: isWater),
                separatorBuilder: (context, index) =>
                    Divider(color: colorTheme3.withOpacity(0.7)),
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

  TileMonthly(
    this.bloc,
    this.value, {
    this.isElectric = false,
    this.isWater = false,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      title: Text(
        "Amount : RM " + (value.utilityTotalRm ?? "0.00"),
        style: TextStyle(fontWeight: FontWeight.bold),
      ),
      subtitle: Padding(
        padding: const EdgeInsets.symmetric(vertical: 8.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text("Total(kWh) : " + (value.utilityReading ?? "N/A")),
            SizedBox(height: 6),
            Text("Max Demand : " + (value.utilityMaxDemand ?? "N/A")),
          ],
        ),
      ),
      trailing: Container(
        height: 40,
        width: 100,
        alignment: Alignment.center,
        decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(5), color: colorTheme2),
        child: Text(
          value.month + " " + value.year,
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
      ),
      onTap: () => Navigator.of(context).push(
        MaterialPageRoute(
          builder: (_) => ViewImage(url: value.utilityImage ?? ''),
        ),
      ),
    );
  }
}

class TileDaily extends StatelessWidget {
  final Reading value;
  final bool isWater;
  TileDaily(this.value, {this.isWater = false});

  @override
  Widget build(BuildContext context) {
    return ListTile(
      title: Text(
        "Consumption : " + (value.utilityReading ?? "N/A"),
        style: TextStyle(fontWeight: FontWeight.bold),
      ),
      subtitle: Padding(
        padding: const EdgeInsets.symmetric(vertical: 8.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text("Timestamp : " + value.time),
            SizedBox(height: 6),
            Text("By : " + (value.utilityRecordedBy ?? "Unknown")),
            if (isWater) SizedBox(height: 6),
            if (isWater) Text("Submission Shift : " + (value.utilityShift ?? "")),
          ],
        ),
      ),
      trailing: Container(
        height: 40,
        width: 100,
        alignment: Alignment.center,
        decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(5), color: colorTheme2),
        child: Text(
          value.day + " " + value.month + " " + value.year,
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
      ),
      onTap: () => Navigator.of(context).push(
        MaterialPageRoute(
          builder: (_) => ViewImage(url: value.utilityImage ?? ''),
        ),
      ),
    );
  }
}

class ViewImage extends StatelessWidget {
  final String url;

  const ViewImage({Key? key, required this.url}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("View Image")),
      body: Container(child: PhotoView(imageProvider: NetworkImage(url))),
    );
  }
}
