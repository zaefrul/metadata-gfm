import 'package:flutter/material.dart';
import 'package:gfm_gems/model/complaint.dart';
import 'package:gfm_gems/utils/network.dart';
import 'package:rxdart/rxdart.dart';
import 'package:toast/toast.dart';
import 'package:custom_searchable_dropdown/custom_searchable_dropdown.dart';

class ComplaintAdd extends StatefulWidget {
  final String id;
  final Controller _controller;

  ComplaintAdd(this.id, {super.key})
      : _controller = Controller(id);

  @override
  _ComplaintAddState createState() => _ComplaintAddState();
}

class _ComplaintAddState extends State<ComplaintAdd> {
  @override
  void dispose() {
    widget._controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    ToastContext().init(context);
    return Scaffold(
      appBar: AppBar(
        title: Text("Add Material / Item"),
        centerTitle: true,
        backgroundColor: Colors.white,
      ),
      body: Container(
        padding: EdgeInsets.all(12),
        child: ListView(
          children: [
            _dropdown<ComplaintDGroup>(
              widget._controller.list1$,
              widget._controller.setfirst,
              value: widget._controller.first$,
              enable: true,
            ),
            StreamBuilder<ComplaintDGroup>(
              stream: widget._controller.first$,
              builder: (context, AsyncSnapshot<ComplaintDGroup> snapshot) {
                return _dropdown<ComplaintDType>(
                  widget._controller.list2$,
                  widget._controller.setsecond,
                  value: widget._controller.second$.where((event) => event != null).cast<ComplaintDType>(),
                  enable: snapshot.data != null,
                );
              },
            ),
            StreamBuilder<ComplaintDType>(
              stream: widget._controller.second$.where((event) => event != null).cast<ComplaintDType>(),
              builder: (context, AsyncSnapshot<ComplaintDType> snapshot) {
                return _dropdown<ComplaintDPart>(
                  widget._controller.list3$,
                  widget._controller.setthird,
                  value: widget._controller.third$.where((event) => event != null).cast<ComplaintDPart>(),
                  enable: snapshot.data != null,
                );
              },
            ),
            StreamBuilder<ComplaintDPart>(
              stream: widget._controller.third$.where((event) => event != null).cast<ComplaintDPart>(),
              builder: (context, snapshot) => TextField(
                enabled: snapshot.data != null,
                controller: widget._controller.quantity,
                keyboardType: TextInputType.number,
                decoration: InputDecoration(
                  labelText: "Quantity",
                  hintText: "0",
                ),
              ),
            ),
            StreamBuilder<ComplaintDPart>(
              stream: widget._controller.third$.where((event) => event != null).cast<ComplaintDPart>(),
              builder: (context, snapshot) => TextField(
                enabled: snapshot.data != null,
                controller: widget._controller.remark,
                decoration: InputDecoration(
                  labelText: "Remark",
                  hintText: "-",
                ),
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        heroTag: "ADD NEW PARTS",
        child: Icon(Icons.done),
        onPressed: () => widget._controller
            .upload(context)
            .then((value) => Navigator.pop(context))
            .catchError((e) => Toast.show(e.toString())),
      ),
    );
  }

  /// _dropdown now takes a stream of List<T>, a [ValueSetter<T>] as sink, a required stream for the current value,
  /// and a flag to enable selection.
  Widget _dropdown<T>(
    Stream<List<T>> stream,
    ValueSetter<T> sink, {
    required Stream<T> value,
    bool enable = false,
  }) {
    return StreamBuilder<List<T>>(
      stream: stream,
      builder: (context, snapshot) {
        // Create a list and filter out null values if any.
        final List<T> list = (snapshot.data ?? []).where((element) => element != null).toList();
        return StreamBuilder<T>(
          stream: value,
          builder: (context, AsyncSnapshot<T> selected) {
            T? selectedItem = selected.data;
            String _hint = "";
            if (T.toString() == "ComplaintDGroup") {
              _hint = "Select Group";
            } else if (T.toString() == "ComplaintDType") {
              _hint = "Select Type";
            } else if (T.toString() == "ComplaintDPart") {
              _hint = "Select Part";
            }
            return CustomSearchableDropDown(
              items: list,
              label: _hint,
              decoration: BoxDecoration(
                border: Border(
                  bottom: BorderSide(color: Colors.black, width: 0.4),
                ),
              ),
              prefixIcon: Padding(
                padding: const EdgeInsets.all(0.0),
                child: Icon(Icons.search),
              ),
              // Convert each item to its display string, safely handling nulls.
              dropDownMenuItems: list.map((e) => (e as dynamic)?.itemName ?? "").toList(),
              onChanged: (item) {
                if (enable && item != null) {
                  sink(item as T);
                }
              },
            );
          },
        );
      },
    );
  }
}

class Controller {
  final String id;
  final Request _request;
  final TextEditingController quantity = TextEditingController();
  final TextEditingController remark = TextEditingController();

  final BehaviorSubject<bool> _invalidQuantity =
      BehaviorSubject<bool>.seeded(true);
  final BehaviorSubject<String> _invalidMessage =
      BehaviorSubject<String>.seeded("Please Check All Field");
  final BehaviorSubject<ComplaintDGroup> _valueFirst =
      BehaviorSubject<ComplaintDGroup>();
  final BehaviorSubject<ComplaintDType?> _valueSecond = BehaviorSubject<ComplaintDType?>();
  final BehaviorSubject<ComplaintDPart?> _valueThird = BehaviorSubject<ComplaintDPart?>();

  final BehaviorSubject<int> _valueFourth = BehaviorSubject<int>();
  final BehaviorSubject<List<ComplaintDGroup>> _listFirst =
      BehaviorSubject<List<ComplaintDGroup>>.seeded([]);
  final BehaviorSubject<List<ComplaintDType>> _listSecond =
      BehaviorSubject<List<ComplaintDType>>.seeded([]);
  final BehaviorSubject<List<ComplaintDPart>> _listThird =
      BehaviorSubject<List<ComplaintDPart>>.seeded([]);

  Controller(this.id) : _request = Request(id) {
    _valueFirst.listen((value) {
      setsecond(null);
      setthird(null);
      setfourth(0);
      invalid = true;
      remark.text = "";
      quantity.text = "";
      if (value != null) {
        getSecond();
      }
    });

    _valueSecond.listen((value) {
      setthird(null);
      setfourth(0);
      invalid = true;
      remark.text = "";
      quantity.text = "";
      if (value != null) {
        getThird();
      }
    });

    _valueThird.listen((value) {
      remark.text = "";
      invalid = true;
      if (value != null) {
        quantity.text = value.itemQuantity ?? '';
      } else {
        quantity.text = "";
      }
    });

    quantity.addListener(() {
      final val = int.tryParse(quantity.text);
      if (val == null) {
        invalid = true;
        fourth = 0;
        invalidMessage = "Quantity must be less than ${_valueThird.value?.itemQuantity ?? 0}";
      } else {
        if (val == 0) {
          invalid = true;
          fourth = 0;
          invalidMessage = "Quantity cannot be 0";
        } else {
          invalidMessage = "";
          invalid = false;
          fourth = val;
        }
      }
    });

    _request.listFirst.then((value) => listFirst = value);
  }

  void dispose() {
    _valueFirst.close();
    _valueSecond.close();
    _valueThird.close();
    _valueFourth.close();
    _listFirst.close();
    _listSecond.close();
    _listThird.close();
    quantity.dispose();
    remark.dispose();
    _invalidQuantity.close();
    _invalidMessage.close();
  }

  Stream<List<ComplaintDGroup>> get list1$ => _listFirst.stream;
  Stream<List<ComplaintDType>> get list2$ => _listSecond.stream;
  Stream<List<ComplaintDPart>> get list3$ => _listThird.stream;
  Stream<ComplaintDGroup> get first$ => _valueFirst.stream;
  Stream<ComplaintDType?> get second$ => _valueSecond.stream;
  Stream<ComplaintDPart?> get third$ => _valueThird.stream;
  Stream<int> get fourth$ => _valueFourth.stream;

  ComplaintDGroup get first => _valueFirst.value;
  ComplaintDType? get second => _valueSecond.value;
  ComplaintDPart? get third => _valueThird.value;
  int get fourth => _valueFourth.value;
  TextEditingController get remarkController => remark;
  TextEditingController get quantityController => quantity;
  Stream<bool> get invalid$ => _invalidQuantity.stream;

  setfirst(ComplaintDGroup? value) => _valueFirst.sink.add(value!);
  setsecond(ComplaintDType? value) => _valueSecond.sink.add(value);
  setthird(ComplaintDPart? value) => _valueThird.sink.add(value);
  setfourth(int value) => _valueFourth.sink.add(value);
  set listFirst(List<ComplaintDGroup> values) => _listFirst.sink.add(values);
  set listSecond(List<ComplaintDType> values) => _listSecond.sink.add(values);
  set listThird(List<ComplaintDPart> values) => _listThird.sink.add(values);
  set fourth(int value) => _valueFourth.sink.add(value);
  set invalidMessage(String value) => _invalidMessage.sink.add(value);
  set invalid(bool value) => _invalidQuantity.sink.add(value);

  void getSecond() =>
      _request.listSecond(_valueFirst.value.itemId ?? "").then((value) => listSecond = value);
  void getThird() =>
      _request.listThird(_valueSecond.value!.itemId!).then((value) => listThird = value);

  Future<void> upload(BuildContext context) {
    FocusScope.of(context).unfocus();
    if (_invalidQuantity.value) {
      Toast.show(_invalidMessage.value, duration: 3);
      throw "";
    } else {
      if (_invalidMessage.value.isNotEmpty) {
        Toast.show(_invalidMessage.value, duration: 3);
      }
      return _request.post(
        _valueThird.value!.itemId!,
        remark: remark.text,
        quantity: quantity.text,
      );
    }
  }
}

class Request {
  final Provider _providerFirst;
  final Provider _providerSecond;
  final Provider _providerThird;
  final Provider _providerUpload;
  final String _id;

  Request(String id)
      : _providerFirst = Provider(fetchURL: "/part/option_asset_group"),
        _providerSecond = Provider(fetchURL: "/part/option_item_type/"),
        _providerThird = Provider(fetchURL: "/part/option_item/"),
        _providerUpload = Provider(taskID: id, fetchURL: ''),
        _id = id;

  Future<List<ComplaintDGroup>> get listFirst => _providerFirst
      .fetchComplaint(group: true)
      .then((value) => value.map((e) => e as ComplaintDGroup).toList());
  Future<List<ComplaintDType>> listSecond(String id) => _providerSecond
          .fetchComplaint(additionalParam: id, type: true)
          .then((value) => value.map((e) => e as ComplaintDType).toList());
  Future<List<ComplaintDPart>> listThird(String id) => _providerThird
          .fetchComplaint(additionalParam: id, part: true)
          .then((value) => value.map((e) => e as ComplaintDPart).toList());
  Future<void> post(String itemId,
          {required String remark, required String quantity}) =>
      _providerUpload.post(url: "/wo_parts", body: {
        "woTaskId": _id,
        "quantity": quantity,
        "itemId": itemId,
        "remark": remark,
      });
}
