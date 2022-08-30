import 'package:flutter/material.dart';
import 'package:gfm_gems/model/complaint.dart';
import 'package:gfm_gems/utils/network.dart';
import 'package:rxdart/rxdart.dart';
import 'package:toast/toast.dart';
import 'package:custom_searchable_dropdown/custom_searchable_dropdown.dart';

class ComplaintAdd extends StatefulWidget {
  final String id;
  final Controller _controller;

  ComplaintAdd(this.id) : _controller = Controller(id);

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
                builder: (context, snapshot) {
                  return _dropdown<ComplaintDType>(
                      widget._controller.list2$, widget._controller.setsecond,
                      value: widget._controller.second$,
                      enable: snapshot.data != null);
                }),
            StreamBuilder<ComplaintDType>(
                stream: widget._controller.second$,
                builder: (context, snapshot) {
                  return _dropdown<ComplaintDPart>(
                      widget._controller.list3$, widget._controller.setthird,
                      value: widget._controller.third$,
                      enable: snapshot.data != null);
                }),
            StreamBuilder<ComplaintDPart>(
              stream: widget._controller.third$,
              builder: (context, snapshot) => TextField(
                  enabled: snapshot.data != null,
                  controller: widget._controller.quantity,
                  keyboardType: TextInputType.number,
                  decoration:
                      InputDecoration(labelText: "Quantity", hintText: "0")),
            ),
            StreamBuilder<ComplaintDPart>(
              stream: widget._controller.third$,
              builder: (context, snapshot) => TextField(
                  enabled: snapshot.data != null,
                  controller: widget._controller.remark,
                  decoration:
                      InputDecoration(labelText: "Remark", hintText: "-")),
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
              .catchError((e) => Toast.show(e))),
    );
  }

  Widget _dropdown<T>(Stream<List<T>> stream, sink,
      {Stream<T> value, bool enable = false}) {
    final Widget listView = StreamBuilder<List<T>>(
        stream: stream,
        builder: (context, snapshot) => StreamBuilder<T>(
            stream: value,
            builder: (context, selected) {
              final List<DropdownMenuItem<T>> _items = [];

              final list = [];
              String _hint = "";
              String _hintDisable = "";
              if (T.toString() == "ComplaintDGroup") {
                _hint = "Select Group";
                if (snapshot.data != null)
                  list.addAll(snapshot.data.map((e) => e as ComplaintDGroup));
                if (list.length > 1)
                  _items.addAll(list
                      .map(
                        (item) => DropdownMenuItem<T>(
                          child: Text(item.itemName),
                          value: item as T,
                        ),
                      )
                      .toList());
              } else if (T.toString() == "ComplaintDType") {
                _hint = "Select Type";
                _hintDisable = "Select Type";

                if (snapshot.data != null)
                  list.addAll(snapshot.data.map((e) => e as ComplaintDType));
                _items.addAll(list
                    .map(
                      (item) => DropdownMenuItem<T>(
                        child: Text(item.itemName),
                        value: item as T,
                      ),
                    )
                    .toList());
              } else if (T.toString() == "ComplaintDPart") {
                _hint = "Select Part";
                _hintDisable = "Select Part";

                if (snapshot.data != null)
                  list.addAll(snapshot.data.map((e) => e as ComplaintDPart));
                _items.addAll(list
                    .map(
                      (item) => DropdownMenuItem<T>(
                        child: Text(item.itemName),
                        value: item as T,
                      ),
                    )
                    .toList());
              }

              return CustomSearchableDropDown(
                items: list,
                label: _hint,
                decoration: BoxDecoration(
                    border: Border(
                  bottom: BorderSide(
                    color: Colors.black,
                    width: 0.4,
                  ),
                )),
                prefixIcon: Padding(
                  padding: const EdgeInsets.all(0.0),
                  child: Icon(Icons.search),
                ),
                dropDownMenuItems: list.map((e) => e.itemName).toList(),
                onChanged: (item) => enable == false ? null : sink(item),
              );

              // return DropdownButton<T>(
              //   hint: Text(_hint),
              //   disabledHint: Text(_hintDisable),
              //   isExpanded: true,
              //   items: _items,
              //   value: selected.data,
              //   onChanged: (item) => enable == false ? null : sink(item),
              // );
            }));

    return listView;
  }
}

class Controller {
  // VARIABLE
  final String id;
  final Request _request;
  final TextEditingController _remark = TextEditingController();
  final TextEditingController _quantity = TextEditingController();

  final BehaviorSubject<bool> _invalidQuantity =
      BehaviorSubject<bool>.seeded(true);
  final BehaviorSubject<String> _invalidMessage =
      BehaviorSubject<String>.seeded("Please Check All Field");
  final BehaviorSubject<ComplaintDGroup> _valueFirst =
      BehaviorSubject<ComplaintDGroup>();
  final BehaviorSubject<ComplaintDType> _valueSecond =
      BehaviorSubject<ComplaintDType>();
  final BehaviorSubject<ComplaintDPart> _valueThird =
      BehaviorSubject<ComplaintDPart>();
  final BehaviorSubject<int> _valueFourth = BehaviorSubject<int>();
  final BehaviorSubject<List<ComplaintDGroup>> _listFirst =
      BehaviorSubject<List<ComplaintDGroup>>.seeded([]);
  final BehaviorSubject<List<ComplaintDType>> _listSecond =
      BehaviorSubject<List<ComplaintDType>>.seeded([]);
  final BehaviorSubject<List<ComplaintDPart>> _listThird =
      BehaviorSubject<List<ComplaintDPart>>.seeded([]);
  // final BehaviorSubject<List<ComplaintD>> _listFourth =
  //     BehaviorSubject<List<ComplaintD>>.seeded([]);

  // INITIALIZER
  Controller(this.id) : _request = Request(id) {
    _valueFirst.listen((value) {
      setsecond(null);
      setthird(null);
      setfourth(null);
      invalid = true;
      remark.text = "";
      quantity.text = "";
      if (value != null) getSecond();
    });

    _valueSecond.listen((value) {
      setthird(null);
      setfourth(null);
      invalid = true;
      remark.text = "";
      quantity.text = "";
      if (value != null) getThird();
    });

    _valueThird.listen((value) {
      // setfourth(null);
      remark.text = "";
      invalid = true;
      if (value != null) quantity.text = value.itemQuantity;
      if (value == null) quantity.text = "";
    });

    _quantity.addListener(() {
      final value = int.tryParse(_quantity.text);
      if (value == null) {
        invalid = true;
        fourth = 0;
        invalidMessage =
            "Quantity must be less than " + _valueThird.value.itemQuantity;
      } else {
        if (value == 0) {
          invalid = true;
          fourth = 0;
          invalidMessage = "Quantity cannot 0";
        } else {
          invalidMessage = null;
          invalid = false;
          fourth = value;
        }
      }
    });

    _request.listFirst.then((value) => listFirst = value);
  }

  // DISPOSE
  void dispose() {
    _valueFirst.close();
    _valueSecond.close();
    _valueThird.close();
    _valueFourth.close();
    _listFirst.close();
    _listSecond.close();
    _listThird.close();
    _remark.dispose();
    _quantity.dispose();
    _invalidQuantity.close();
    _invalidMessage.close();
    // _listFourth.close();
  }

  // GET
  get list1$ => _listFirst.stream;
  get list2$ => _listSecond.stream;
  get list3$ => _listThird.stream;
  // get list4$ => _listFourth.stream;
  get first$ => _valueFirst.stream;
  get second$ => _valueSecond.stream;
  get third$ => _valueThird.stream;
  get fourth$ => _valueFourth.stream;
  get first => _valueFirst.value;
  get second => _valueSecond.value;
  get third => _valueThird.value;
  get fourth => _valueFourth.value;
  get remark => _remark;
  get quantity => _quantity;
  get invalid$ => _invalidQuantity.stream;

  // SINK
  setfirst(ComplaintDGroup value) => _valueFirst.sink.add(value);
  setsecond(ComplaintDType value) => _valueSecond.sink.add(value);
  setthird(ComplaintDPart value) => _valueThird.sink.add(value);
  setfourth(int value) => _valueFourth.sink.add(value);
  set listFirst(List<ComplaintDGroup> values) => _listFirst.sink.add(values);
  set listSecond(List<ComplaintDType> values) => _listSecond.sink.add(values);
  set listThird(List<ComplaintDPart> values) => _listThird.sink.add(values);
  set fourth(int value) => _valueFourth.sink.add(value);
  set invalidMessage(String value) => _invalidMessage.sink.add(value);
  set invalid(bool value) => _invalidQuantity.sink.add(value);
  // set listFourth(List<ComplaintD> values) => _listFourth.sink.add(values);

  // METHOD
  void getFirst() => _request.listFirst.then((value) => listFirst = value);
  void getSecond() => _request
      .listSecond(_valueFirst.value.itemId)
      .then((value) => listSecond = value);
  void getThird() => _request
      .listThird(_valueSecond.value.itemId)
      .then((value) => listThird = value);
  // void getFourth() => _request
  //     .listFourth(_valueThird.value.itemId)
  //     .then((value) => listFirst = value);
  Future<void> upload(BuildContext context) {
    FocusScope.of(context).unfocus();
    if (_invalidQuantity.value == true) {
      Toast.show(_invalidMessage.value, duration: 3);
      throw "";
    } else {
      if (_invalidMessage.value != null)
        Toast.show(_invalidMessage.value, duration: 3);
      return _request.post(
        _valueThird.value.itemId,
        remark: remark.text,
        quantity: _quantity.text,
      );
    }
  }
}

class Request {
  final Provider _providerFirst;
  final Provider _providerSecond;
  final Provider _providerThird;
  // final Provider _providerFourth;
  final Provider _providerUpload;
  final String _id;

  Request(String id)
      : _providerFirst = Provider(fetchURL: "/part/option_asset_group"),
        _providerSecond = Provider(fetchURL: "/part/option_item_type/"),
        _providerThird = Provider(fetchURL: "/part/option_item/"),
        // _providerFourth = Provider(fetchURL: ""),
        _providerUpload = Provider(taskID: id),
        this._id = id;

  Future<List<ComplaintDGroup>> get listFirst => _providerFirst
      .fetchComplaint(group: true)
      .then((value) => value.map((e) => e as ComplaintDGroup).toList());
  Future<List<ComplaintDType>> listSecond(String id) => _providerSecond
      .fetchComplaint(additionalParam: id, type: true)
      .then((value) => value.map((e) => e as ComplaintDType).toList());
  Future<List<ComplaintDPart>> listThird(String id) => _providerThird
      .fetchComplaint(additionalParam: id, part: true)
      .then((value) => value.map((e) => e as ComplaintDPart).toList());
  // Future<List<ComplaintD>> listFourth(String id) => _providerFourth
  //     .fetchComplaint(additionalParam: id)
  //     .then((value) => value.items.toList());
  Future<void> post(String itemId, {String remark, String quantity}) =>
      _providerUpload.post(url: "/wo_parts", body: {
        "woTaskId": _id,
        "quantity": quantity,
        "itemId": itemId,
        "remark": remark,
      });
}
