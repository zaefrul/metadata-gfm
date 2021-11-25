import 'package:flutter/material.dart';
import 'package:gfm_gems/controller/Storekeeper/utils/constant.dart';
import 'package:gfm_gems/controller/Utilities/Bloc/bloc.dart';
import 'package:gfm_gems/model/meter.dart';
import 'package:photo_view/photo_view.dart';

class ListReading extends StatelessWidget {
  final Bloc bloc;
  final Reading reading;
  final bool isWater;
  final bool isElectric;
  final Stream stream;

  ListReading(this.bloc, this.reading,
      {this.isWater = false, this.isElectric = false})
      : this.stream = isWater
            ? bloc.rdw$
            : isElectric
                ? bloc.rde$
                : null {
    if (isWater) {
      bloc.fetch(api.ReadingDW);
    } else if (isElectric) {
      bloc.fetch(api.ReadingDE);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("${reading.month} : Reading"),
        backgroundColor: Colors.white,
      ),
      // body:
    );
  }
}
