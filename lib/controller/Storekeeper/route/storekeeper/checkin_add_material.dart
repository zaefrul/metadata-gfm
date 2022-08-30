import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:gfm_gems/controller/Storekeeper/utils/bloc/bloc.dart';
import 'package:gfm_gems/model/complaint.dart';
import 'package:gfm_gems/model/user.dart';
import 'package:gfm_gems/utils/network.dart';
import 'package:intl/intl.dart';
import 'package:rxdart/rxdart.dart';
import 'package:toast/toast.dart';
import 'package:gfm_gems/view/dialog.dart';
import 'package:gfm_gems/controller/Storekeeper/utils/bloc/bloc_checkin.dart';

class CheckinAdd extends StatefulWidget {
  final Controller _controller;

  CheckinAdd() : _controller = Controller();

  @override
  _CheckinAddState createState() => _CheckinAddState();
}

class _CheckinAddState extends State<CheckinAdd> {
  @override
  void didChangeDependencies() {
    widget._controller.loadingState$.listen((event) {
      if (event == null) return;
      if (event == true)
        showDialog(
          context: context,
          builder: (_) => Center(
            child: CircularProgressIndicator(),
          ),
        );
      else if (event == false) Navigator.pop(context);
    });
    widget._controller.err$.listen((event) {
      if (event == "Your session already expired, please relogin.")
        showDialog(
            context: context,
            builder: (BuildContext context) => CustomDialog(
                  title: "Expired Session",
                  description: event,
                  buttonText: "Okay",
                  image: Image.asset(
                    "assets/icon_trans.png",
                    height: 40,
                  ),
                )).whenComplete(() async {
          var userPref = await User.getPrefUser;
          var user = User.fromMap(userPref);
          user.removeUser();
          Navigator.pop(context);
          Navigator.pushReplacementNamed(
            context,
            "/",
          );
        });
      Toast.show(event);
    });
    super.didChangeDependencies();
  }

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
            _dropdown<ComplaintDStore>(
              widget._controller.list4$,
              widget._controller.setFourth,
              value: widget._controller.fourth$,
              enable: true,
            ),
            StreamBuilder<ComplaintDStore>(
                stream: widget._controller.fourth$,
                builder: (context, snapshot) {
                  return _dropdown<ComplaintDGroupStore>(
                      widget._controller.list1$, widget._controller.setfirst,
                      value: widget._controller.first$,
                      enable: snapshot.data != null);
                }),
            StreamBuilder<ComplaintDGroupStore>(
                stream: widget._controller.first$,
                builder: (context, snapshot) {
                  return _dropdown<ComplaintDStoreType>(
                      widget._controller.list2$, widget._controller.setsecond,
                      value: widget._controller.second$,
                      enable: snapshot.data != null);
                }),
            StreamBuilder<ComplaintDStoreType>(
                stream: widget._controller.second$,
                builder: (context, snapshot) {
                  return _dropdown<MaterialStorePart>(
                      widget._controller.list3$, widget._controller.setthird,
                      value: widget._controller.third$,
                      enable: snapshot.data != null);
                }),
            StreamBuilder<MaterialStorePart>(
              stream: widget._controller.third$,
              builder: (context, snapshot) => TextField(
                  enabled: snapshot.data != null,
                  controller: widget._controller.quantity,
                  keyboardType: TextInputType.number,
                  decoration:
                      InputDecoration(labelText: "Quantity", hintText: "0")),
            ),
            StreamBuilder<MaterialStorePart>(
              stream: widget._controller.third$,
              builder: (context, snapshot) => TextField(
                  enabled: snapshot.data != null,
                  controller: widget._controller.remark,
                  keyboardType: TextInputType.numberWithOptions(decimal: true),
                  decoration: InputDecoration(
                      labelText: "Price Per Unit (RM)", hintText: "10.00")),
            ),
            StreamBuilder<MaterialStorePart>(
              stream: widget._controller.third$,
              builder: (context, snapshot) => TextField(
                  enabled: snapshot.data != null,
                  controller: widget._controller.subLocation,
                  decoration: InputDecoration(labelText: "Sub Location")),
            ),
            StreamBuilder<MaterialStorePart>(
              stream: widget._controller.third$,
              builder: (context, snapshot) => TextField(
                  enabled: snapshot.data != null,
                  controller: widget._controller.warranty,
                  keyboardType: TextInputType.number,
                  decoration:
                      InputDecoration(labelText: "Warranty", hintText: "1")),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
          child: Icon(Icons.done),
          onPressed: () {
            final item = widget._controller.value(context);
            if (item != null)
              Navigator.pop(context, item);
            else
              Navigator.pop(context);
          }),
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
              String _hint = "";
              String _hintDisable = "";
              if (T.toString() == "ComplaintDStore") {
                _hint = "Select Store";
                final list = [];
                if (snapshot.data != null)
                  list.addAll(snapshot.data.map((e) => e as ComplaintDStore));
                _items.addAll(list
                    .map(
                      (item) => DropdownMenuItem<T>(
                        child: Text(item.itemName),
                        value: item as T,
                      ),
                    )
                    .toList());
              } else if (T.toString() == "ComplaintDGroup") {
                _hint = "Select Group";
                _hintDisable = "Select Group";
                final list = [];
                if (snapshot.data != null)
                  list.addAll(snapshot.data.map((e) => e as ComplaintDGroup));
                _items.addAll(list
                    .map(
                      (item) => DropdownMenuItem<T>(
                        child: Text(item.itemName),
                        value: item as T,
                      ),
                    )
                    .toList());
              } else if (T.toString() == "ComplaintDGroupStore") {
                _hint = "Select Group";
                _hintDisable = "Select Group";
                final list = [];
                if (snapshot.data != null)
                  list.addAll(
                      snapshot.data.map((e) => e as ComplaintDGroupStore));
                _items.addAll(list
                    .map(
                      (item) => DropdownMenuItem<T>(
                        child: Text(item.itemName),
                        value: item as T,
                      ),
                    )
                    .toList());
              } else if (T.toString() == "ComplaintDStoreType") {
                _hint = "Select Type";
                _hintDisable = "Select Type";

                final list = [];
                if (snapshot.data != null)
                  list.addAll(
                      snapshot.data.map((e) => e as ComplaintDStoreType));
                _items.addAll(list
                    .map(
                      (item) => DropdownMenuItem<T>(
                        child: Text(item.itemName),
                        value: item as T,
                      ),
                    )
                    .toList());
              } else if (T.toString() == "MaterialStorePart") {
                _hint = "Select Part";
                _hintDisable = "Select Part";
                final list = [];
                if (snapshot.data != null)
                  list.addAll(snapshot.data.map((e) => e as MaterialStorePart));
                _items.addAll(list
                    .map(
                      (item) => DropdownMenuItem<T>(
                        child: Text(item.itemDescription),
                        value: item as T,
                      ),
                    )
                    .toList());
              }

              return DropdownButton<T>(
                hint: Text(_hint),
                disabledHint: Text(_hintDisable),
                isExpanded: true,
                items: _items,
                value: selected.data,
                onChanged: (item) => enable == false ? null : sink(item),
              );
            }));

    return listView;
  }
}

class Controller extends Bloc {
  // VARIABLE
  final Request _request;
  final TextEditingController _remark = TextEditingController();
  final TextEditingController _quantity = TextEditingController();
  final TextEditingController _subLocation = TextEditingController();
  final TextEditingController _warranty = TextEditingController();

  final BehaviorSubject<bool> _invalidQuantity =
      BehaviorSubject<bool>.seeded(true);
  final BehaviorSubject<String> _invalidMessage =
      BehaviorSubject<String>.seeded("Please Check All Field");
  final BehaviorSubject<ComplaintDGroupStore> _valueFirst =
      BehaviorSubject<ComplaintDGroupStore>();
  final BehaviorSubject<ComplaintDStoreType> _valueSecond =
      BehaviorSubject<ComplaintDStoreType>();
  final BehaviorSubject<MaterialStorePart> _valueThird =
      BehaviorSubject<MaterialStorePart>();
  final BehaviorSubject<ComplaintDStore> _valueFourth =
      BehaviorSubject<ComplaintDStore>();
  final BehaviorSubject<List<ComplaintDGroupStore>> _listFirst =
      BehaviorSubject<List<ComplaintDGroupStore>>.seeded([]);
  final BehaviorSubject<List<ComplaintDStoreType>> _listSecond =
      BehaviorSubject<List<ComplaintDStoreType>>.seeded([]);
  final BehaviorSubject<List<MaterialStorePart>> _listThird =
      BehaviorSubject<List<MaterialStorePart>>.seeded([]);
  final BehaviorSubject<List<ComplaintDStore>> _listFourth =
      BehaviorSubject<List<ComplaintDStore>>.seeded([]);

  // INITIALIZER
  Controller() : _request = Request() {
    _valueFourth.listen((event) {
      setfirst(null);
      setsecond(null);
      setthird(null);
      fourth = "";
      invalid = true;
      remark.text = "";
      quantity.text = "";
      if (value != null) getFirst();
    });
    _valueFirst.listen((value) {
      setsecond(null);
      setthird(null);
      fourth = "";
      invalid = true;
      remark.text = "";
      quantity.text = "";
      if (value != null) getSecond();
    });

    _valueSecond.listen((value) {
      setthird(null);
      fourth = "";
      invalid = true;
      remark.text = "";
      quantity.text = "";
      if (value != null) getThird();
    });

    _valueThird.listen((value) {
      remark.text = "";
      invalid = true;
      if (value != null) quantity.text = value.partCount;
      if (value == null) quantity.text = "";
    });

    _quantity.addListener(() {
      final value = int.tryParse(_quantity.text);
      if (value == null) {
        invalid = true;
        fourth = "";
        invalidMessage =
            "Quantity must be less than " + _valueThird.value.partCount;
      } else {
        if (value == 0) {
          invalid = true;
          fourth = "";
          invalidMessage = "Quantity cannot 0";
        } else {
          invalidMessage = null;
          invalid = false;
        }
      }
    });

    _request.listFourth().then((value) => listFourth = value);
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
    _listFourth.close();
    _subLocation.dispose();
    _warranty.dispose();
    super.dispose();
  }

  // GET
  get list1$ => _listFirst.stream;
  get list2$ => _listSecond.stream;
  get list3$ => _listThird.stream;
  get list4$ => _listFourth.stream;
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
  get subLocation => _subLocation;
  get warranty => _warranty;
  get invalid$ => _invalidQuantity.stream;
  get validity {
    final now = DateTime.now().add(Duration());
    final year = now.year + int.parse(warranty.text);
    final newDate = new DateTime(year, now.month, now.day);
    final f = DateFormat("yyyy-MM-dd");
    final result = f.format(newDate);

    return result;
  }

  // SINK
  setfirst(ComplaintDGroupStore value) => _valueFirst.sink.add(value);
  setsecond(ComplaintDStoreType value) => _valueSecond.sink.add(value);
  setthird(MaterialStorePart value) => _valueThird.sink.add(value);
  setFourth(ComplaintDStore value) => _valueFourth.sink.add(value);
  set listFirst(List<ComplaintDGroupStore> values) =>
      _listFirst.sink.add(values);
  set listSecond(List<ComplaintDStoreType> values) =>
      _listSecond.sink.add(values);
  set listThird(List<MaterialStorePart> values) => _listThird.sink.add(values);
  set listFourth(List<ComplaintDStore> values) => _listFourth.sink.add(values);
  set fourth(String value) => _quantity.text = value;
  set invalidMessage(String value) => _invalidMessage.sink.add(value);
  set invalid(bool value) => _invalidQuantity.sink.add(value);

  // METHOD
  void getFirst() => checker(_request.listFirst(_valueFourth.value.itemId))
      .then((value) => listFirst = value);
  void getSecond() => checker(_request.listSecond(
          _valueFirst.value.itemId, _valueFourth.value.itemId))
      .then((value) => listSecond = value);
  void getThird() => checker(_request.listThird(
          _valueSecond.value.itemId, _valueFourth.value.itemId))
      .then((value) => listThird = value);
  void getFourth() =>
      checker(_request.listFourth()).then((value) => listFourth = value);
  Future<void> upload(BuildContext context) {
    FocusScope.of(context).unfocus();
    if (_invalidQuantity.value == true) {
      Toast.show(_invalidMessage.value, duration: 3);
      throw "";
    } else {
      if (_invalidMessage.value != null)
        Toast.show(_invalidMessage.value, duration: 3);
      return _request.post(
        _valueThird.value.partId,
        remark: remark.text,
        quantity: _quantity.text,
      );
    }
  }

  Item value(BuildContext context) {
    FocusScope.of(context).unfocus();
    bool checkEmpty = false;
    List<TextEditingController> tempCtrl = [
      _remark,
      _quantity,
      _warranty,
    ];

    checkEmpty = tempCtrl.firstWhere((element) => element.text.isEmpty,
            orElse: () => null) !=
        null;
    if (checkEmpty) {
      Toast.show("Please check all fields");
      throw "Please check all fields";
    }

    tempCtrl = [
      _quantity,
      _warranty,
    ];

    for (var i = 0; i < tempCtrl.length; i++) {
      final ctrl = tempCtrl[i];
      try {
        final _ = int.parse(ctrl.text);
      } catch (err) {
        Toast.show("Please check all fields must be numerical and integer");
        throw "Please check all fields must be numerical  and integer";
      }
    }

    tempCtrl = [
      _remark,
    ];

    for (var i = 0; i < tempCtrl.length; i++) {
      final ctrl = tempCtrl[i];
      try {
        final _ = double.parse(ctrl.text);
      } catch (err) {
        Toast.show("Please check all fields must be numerical");
        throw "Please check all fields must be numerical";
      }
    }

    final quantity = int.parse(_quantity.value.text);
    final maxOrder = int.parse(_valueThird.value.partMaxOrder ?? 0);
    final minOrder = int.parse(_valueThird.value.partMinOrder ?? 0);

    if (quantity < minOrder) {
      Toast.show("Min order is : $minOrder");
      throw "Min order is : $minOrder ";
    }
    if (quantity > maxOrder) {
      Toast.show("Max order is : $maxOrder");
      throw "Max order is : $maxOrder ";
    }

    if (_invalidQuantity.value == true) {
      Toast.show(_invalidMessage.value, duration: 3);
      throw "";
    } else {
      if (_invalidMessage.value != null)
        Toast.show(_invalidMessage.value, duration: 3);
      return Item(
        _valueFirst.value.itemName,
        _valueSecond.value.itemName,
        _valueThird.value.itemDescription,
        _valueThird.value.partId,
        int.parse(_quantity.value.text).toString(),
        (double.parse(_remark.value.text)).toStringAsFixed(2),
        subLocation.text,
        int.parse(warranty.text).toString(),
        validity,
      );
    }
  }
}

class Request {
  final Provider _providerFirst;
  final Provider _providerSecond;
  final Provider _providerThird;
  final Provider _providerFourth;
  final Provider _providerUpload;

  Request()
      : _providerFirst =
            Provider(fetchURL: "/part/purchase_option_asset_group/"),
        _providerSecond =
            Provider(fetchURL: "/part/purchase_option_item_type/"),
        _providerThird = Provider(fetchURL: "/part/purchase_option_part/"),
        _providerFourth = Provider(fetchURL: "/store/purchase_option_store"),
        _providerUpload = Provider();

  Future<List<ComplaintDGroupStore>> listFirst(String id) => _providerFirst
      .fetchComplaint(additionalParam: id, groupStore: true)
      .then((value) => value.map((e) => e as ComplaintDGroupStore).toList());
  Future<List<ComplaintDStoreType>> listSecond(String id, String storeId) =>
      _providerSecond
          .fetchComplaint(additionalParam: storeId + "/" + id, storeType: true)
          .then((value) => value.map((e) => e as ComplaintDStoreType).toList());
  Future<List<MaterialStorePart>> listThird(String id, String storeId) =>
      _providerThird
          .fetchComplaint(additionalParam: storeId + "/" + id, storePart: true)
          .then((value) => value.map((e) => e as MaterialStorePart).toList());
  Future<List<ComplaintDStore>> listFourth() => _providerFourth
      .fetchComplaint(store: true)
      .then((value) => value.map((e) => e as ComplaintDStore).toList());
  Future<void> post(String itemId, {String remark, String quantity}) =>
      _providerUpload.post(url: "/wo_parts", body: {
        "quantity": quantity,
        "itemId": itemId,
        "remark": remark,
      });
}
