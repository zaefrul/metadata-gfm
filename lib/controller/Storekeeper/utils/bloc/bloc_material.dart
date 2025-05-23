import 'package:flutter/material.dart';
import 'package:GEMS/model/complaint.dart';
import 'package:rxdart/rxdart.dart';

import 'bloc.dart';

class BlocMaterial extends Bloc {
  String _id;

  BlocMaterial(this._id);

  // VARIABLES
  final BehaviorSubject<int> _threshold = BehaviorSubject<int>.seeded(7);
  final BehaviorSubject<int> _minOrder = BehaviorSubject<int>.seeded(4);
  final BehaviorSubject<int> _maxOrder = BehaviorSubject<int>.seeded(20);
  final BehaviorSubject<ComplaintMaterial> _info = BehaviorSubject<ComplaintMaterial>();

  // METHODS : GET (Streams)
  Stream<int> get threshold$ => _threshold.stream;
  Stream<int> get minOrder$ => _minOrder.stream;
  Stream<int> get maxOrder$ => _maxOrder.stream;
  Stream<ComplaintMaterial> get info$ => _info.stream;

  // METHODS : SINK (setters)
  set threshold(int value) => _threshold.sink.add(value);
  set minOrder(int value) => _minOrder.sink.add(value);
  set maxOrder(int value) => _maxOrder.sink.add(value);
  set info(ComplaintMaterial value) => _info.sink.add(value);

  // Added setId method so that the id can be updated properly.
  void setId(String id) {
    _id = id;
  }

  @override
  void dispose() {
    _threshold.close();
    _minOrder.close();
    _maxOrder.close();
    _info.close();
    super.dispose();
  }

  // METHODS to modify values
  void addThreshold() => threshold = (_threshold.value + 1);
  void minusThreshold() => threshold = (_threshold.value - 1);
  void addMin() => minOrder = (_minOrder.value + 1);
  void minusMin() => minOrder = (_minOrder.value - 1);
  void addMax() => maxOrder = (_maxOrder.value + 1);
  void minusMax() => maxOrder = (_maxOrder.value - 1);

  // Optionally, add a method to use the _id (for example, fetching information).
  Future<void> getInfo(BuildContext context) async {
    // Your actual implementation goes here.
    // For example, using the _id to fetch data and then:
    // info = fetchedComplaintMaterial;
  }
}
