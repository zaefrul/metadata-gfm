import 'package:flutter/material.dart';
import 'package:GEMS/controller/Utilities/Bloc/bloc.dart';
import 'package:GEMS/model/meter.dart';

class ListReading extends StatelessWidget {
  final Bloc bloc;
  final Reading reading;
  final bool isWater;
  final bool isElectric;
  final Stream<dynamic>? stream;

  ListReading(this.bloc, this.reading,
      {super.key, this.isWater = false, this.isElectric = false})
      : stream = isWater
            ? bloc.rdw$
            : isElectric
                ? bloc.rde$ as Stream<dynamic>
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
