import 'package:flutter/material.dart';
import 'package:gfm_gems/model/complaint.dart';
import 'package:gfm_gems/utils/network.dart';
import 'package:rxdart/subjects.dart';

import 'bloc.dart';

class BlocMaterial extends Bloc {
  final String id;
  BlocMaterial(this.id);

  // VARIABLES
  final BehaviorSubject<int> _threshold = BehaviorSubject<int>.seeded(7);
  final BehaviorSubject<int> _minOrder = BehaviorSubject<int>.seeded(4);
  final BehaviorSubject<int> _maxOrder = BehaviorSubject<int>.seeded(20);
  final BehaviorSubject<ComplaintMaterial> _info = BehaviorSubject();

  // MEHTODS : GET
  get threshold => _threshold.stream;
  get minOrder => _minOrder.stream;
  get maxOrder => _maxOrder.stream;
  get info$ => _info.stream;

  // MEHTHOS : SINK
  set threshold(int value) => _threshold.sink.add(value);
  set minOrder(int value) => _minOrder.sink.add(value);
  set maxOrder(int value) => _maxOrder.sink.add(value);
  set info(ComplaintMaterial value) => _info.sink.add(value);
  // DISPOSE
  @override
  void dispose() {
    _threshold.close();
    _minOrder.close();
    _maxOrder.close();
    _info.close();
  }

  // METHODS : LISTENER

  // METHODS
  void addThreshold() => threshold = (_threshold.value + 1);
  void minusThreshold() => threshold = (_threshold.value - 1);
  void addMin() => minOrder = (_minOrder.value + 1);
  void minusMin() => minOrder = (_minOrder.value - 1);
  void addMax() => maxOrder = (_maxOrder.value + 1);
  void minusMax() => maxOrder = (_maxOrder.value - 1);

  Future<void> getInfo(BuildContext context) async {
    final Provider _provider =
        Provider(fetchURL: "/part/part_mobile_details/", taskID: id);
    _provider.context = context;

    final result = await _provider.getJson();
    final value = ComplaintMaterial.fromJson(result);

    info = value;
    threshold = int.parse(value.partThreshold ?? "0");
    minOrder = int.parse(value.partMinOrder ?? "0");
    maxOrder = int.parse(value.partMaxOrder ?? "0");
  }
}
