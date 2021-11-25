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
  final Stream streamMonthly;
  final Stream streamDaily;

  ListReading(this.bloc, this.reading,
      {this.isWater = false, this.isElectric = false})
      : this.streamMonthly = isWater
            ? bloc.rmw$
            : isElectric
                ? bloc.rme$
                : null,
        this.streamDaily = isWater
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
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          title: Text("${reading.meterLocation} : Reading"),
          backgroundColor: Colors.white,
          bottom: TabBar(
            indicatorColor: colorTheme2,
            tabs: [
              Tab(child: Text("Monthly")),
              Tab(child: Text("Daily")),
            ],
          ),
        ),
        body: TabBarView(
          children: [
            StreamBuilder<List<Reading>>(
                stream: streamMonthly,
                builder: (_, s) {
                  if (s.hasData == false)
                    return Center(child: CircularProgressIndicator());
                  return RefreshIndicator(
                    onRefresh: () => isWater
                        ? bloc.fetch(api.ReadingMW)
                        : bloc.fetch(api.ReadingME),
                    child: ListView.separated(
                      padding: EdgeInsets.symmetric(vertical: 12),
                      itemBuilder: (_, i) => TileMonthly(
                        bloc,
                        s.data[i] ?? null,
                        isWater: isWater,
                        isElectric: isElectric,
                      ),
                      itemCount: s.data?.length ?? 0,
                      separatorBuilder: (_, __) =>
                          Divider(color: colorTheme3.withOpacity(0.7)),
                    ),
                  );
                }),
            StreamBuilder<List<Reading>>(
                stream: streamDaily,
                builder: (_, s) {
                  return RefreshIndicator(
                    onRefresh: () => isWater
                        ? bloc.fetch(api.ReadingDW)
                        : bloc.fetch(api.ReadingDE),
                    child: ListView.separated(
                      padding: EdgeInsets.symmetric(vertical: 12),
                      itemBuilder: (_, i) =>
                          TileDaily(s.data[i] ?? null, isWater: isWater),
                      itemCount: s.data?.length ?? 0,
                      separatorBuilder: (_, __) =>
                          Divider(color: colorTheme3.withOpacity(0.7)),
                    ),
                  );
                }),
          ],
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

  TileMonthly(this.bloc, this.value,
      {this.isElectric = false, this.isWater = false});

  @override
  Widget build(BuildContext context) {
    return ListTile(
      title: Text(
        "Amount : RM " + value.utilityTotalRm,
        style: TextStyle(fontWeight: FontWeight.bold),
      ),
      subtitle: Padding(
        padding: const EdgeInsets.symmetric(vertical: 8.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text("Total(kWh) : " + value.utilityReading),
            SizedBox(height: 6),
            Text("Max Demand : " + value.utilityMaxDemand),
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
      // onTap: () {
      //   bloc.sDay = value;
      //   Navigator.push(
      //       context,
      //       MaterialPageRoute(
      //           builder: (_) => page.ListReading(
      //                 bloc,
      //                 value,
      //                 isWater: isWater,
      //                 isElectric: isElectric,
      //               )));
      // },
      onTap: () => Navigator.of(context).push(
        MaterialPageRoute(
          builder: (_) => ViewImage(url: value.utilityImage),
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
        "Consumption : " + value.utilityReading,
        style: TextStyle(fontWeight: FontWeight.bold),
      ),
      subtitle: Padding(
        padding: const EdgeInsets.symmetric(vertical: 8.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text("Timestamp : " + value.time),
            SizedBox(height: 6),
            Text("By : " + value.utilityRecordedBy),
            if (isWater) SizedBox(height: 6),
            if (isWater)
              Text("Submission Shift : " + (value.utilityShift ?? "")),
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
          builder: (_) => ViewImage(url: value.utilityImage),
        ),
      ),
    );
  }
}

class ViewImage extends StatelessWidget {
  final String url;

  const ViewImage({Key key, this.url}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(child: PhotoView(imageProvider: NetworkImage(url)));
  }
}
