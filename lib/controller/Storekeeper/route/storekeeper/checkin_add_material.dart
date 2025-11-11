import 'dart:async';

import 'package:flutter/material.dart';
import 'package:GEMS/controller/Storekeeper/utils/bloc/bloc.dart';
import 'package:GEMS/controller/Storekeeper/utils/bloc/bloc_checkin.dart';
import 'package:GEMS/model/complaint.dart';
import 'package:GEMS/model/user.dart';
import 'package:GEMS/utils/network.dart';
import 'package:intl/intl.dart';
import 'package:rxdart/rxdart.dart';
import 'package:toast/toast.dart';
import 'package:GEMS/view/dialog.dart';
import '../../../../main.dart';

class CheckinAdd extends StatefulWidget {
  final Controller _controller;

  CheckinAdd({super.key}) : _controller = Controller();

  @override
  _CheckinAddState createState() => _CheckinAddState();
}

class _CheckinAddState extends State<CheckinAdd> {
  @override
  void didChangeDependencies() {
    // Listen to loading state and error streams
    widget._controller.loadingState$.listen((event) {
      if (event == true) {
        showDialog(
          context: navigatorKey.currentContext!,
          barrierDismissible: false,
          builder: (_) => const Center(
            child: CircularProgressIndicator(),
          ),
        );
      } else {
        Navigator.pop(context);
      }
    });
    widget._controller.err$.listen((event) {
      if (event == "Your session already expired, please relogin.") {
        showDialog(
          context: navigatorKey.currentContext!,
          builder: (BuildContext context) => CustomDialog(
            title: "Expired Session",
            description: event,
            buttonText: "Okay",
            image: Image.asset(
              "assets/icon_trans.png",
              height: 40,
            ),
          ),
        ).whenComplete(() async {
          final userPref = await User.getPrefUser;
          final user = User.fromMap(userPref);
          user.removeUser();
          Navigator.pop(context);
          Navigator.pushReplacementNamed(context, "/");
        });
      }
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
    ToastContext().init(context);
    return Scaffold(
      appBar: AppBar(
        title: const Text("Add Material / Item"),
        centerTitle: true,
        backgroundColor: Colors.white,
      ),
      body: Container(
        padding: const EdgeInsets.all(12),
        child: ListView(
          children: [
            _dropdown<ComplaintDStore>(
              widget._controller.list4$,
              widget._controller.setFourth,
              value: widget._controller.fourth$.cast<ComplaintDStore>(),
              enable: true,
            ),
            StreamBuilder<ComplaintDStore>(
              stream: widget._controller.fourth$.cast<ComplaintDStore>(),
              builder: (context, AsyncSnapshot<ComplaintDStore> snapshot) {
                return _dropdown<ComplaintDGroupStore>(
                  widget._controller.list1$,
                  widget._controller.setfirst,
                  value: widget._controller.first$.cast<ComplaintDGroupStore>(),
                  enable: snapshot.hasData && snapshot.data != null,
                );
              },
            ),
            StreamBuilder<ComplaintDGroupStore>(
              stream: widget._controller.first$.cast<ComplaintDGroupStore>(),
              builder: (context, AsyncSnapshot<ComplaintDGroupStore> snapshot) {
                return _dropdown<ComplaintDStoreType>(
                  widget._controller.list2$,
                  widget._controller.setsecond,
                  value: widget._controller.second$.cast<ComplaintDStoreType>(),
                  enable: snapshot.hasData && snapshot.data != null,
                );
              },
            ),
            StreamBuilder<ComplaintDStoreType>(
              stream: widget._controller.second$.cast<ComplaintDStoreType>(),
              builder: (context, AsyncSnapshot<ComplaintDStoreType> snapshot) {
                return _dropdown<MaterialStorePart>(
                  widget._controller.list3$,
                  widget._controller.setthird,
                  value: widget._controller.third$.cast<MaterialStorePart>(),
                  enable: snapshot.hasData && snapshot.data != null,
                );
              },
            ),
            StreamBuilder<MaterialStorePart>(
              stream: widget._controller.third$.cast<MaterialStorePart>(),
              builder: (context, snapshot) {
                final isEnabled = snapshot.hasData && snapshot.data != null;
                return AbsorbPointer(
                  absorbing: !isEnabled,
                  child: Opacity(
                    opacity: isEnabled ? 1.0 : 0.5,
                    child: TextField(
                      controller: widget._controller.quantity,
                      keyboardType: TextInputType.number,
                      decoration: const InputDecoration(
                        labelText: "Quantity", 
                        hintText: "0",
                      ),
                    ),
                  ),
                );
              },
            ),
            StreamBuilder<MaterialStorePart>(
              stream: widget._controller.third$.cast<MaterialStorePart>(),
              builder: (context, snapshot) {
                final isEnabled = snapshot.hasData && snapshot.data != null;
                return AbsorbPointer(
                  absorbing: !isEnabled,
                  child: Opacity(
                    opacity: isEnabled ? 1.0 : 0.5,
                    child: TextField(
                      controller: widget._controller.remark,
                      keyboardType: const TextInputType.numberWithOptions(decimal: true),
                      decoration: const InputDecoration(
                        labelText: "Price Per Unit (RM)", 
                        hintText: "10.00",
                      ),
                    ),
                  ),
                );
              },
            ),
            StreamBuilder<MaterialStorePart>(
              stream: widget._controller.third$.cast<MaterialStorePart>(),
              builder: (context, snapshot) {
                final isEnabled = snapshot.hasData && snapshot.data != null;
                return AbsorbPointer(
                  absorbing: !isEnabled,
                  child: Opacity(
                    opacity: isEnabled ? 1.0 : 0.5,
                    child: TextField(
                      controller: widget._controller.subLocation,
                      decoration: const InputDecoration(labelText: "Sub Location"),
                    ),
                  ),
                );
              },
            ),
            StreamBuilder<MaterialStorePart>(
              stream: widget._controller.third$.cast<MaterialStorePart>(),
              builder: (context, snapshot) {
                final isEnabled = snapshot.hasData && snapshot.data != null;
                return AbsorbPointer(
                  absorbing: !isEnabled,
                  child: Opacity(
                    opacity: isEnabled ? 1.0 : 0.5,
                    child: TextField(
                      controller: widget._controller.warranty,
                      keyboardType: TextInputType.number,
                      decoration: const InputDecoration(
                        labelText: "Warranty", 
                        hintText: "1",
                      ),
                    ),
                  ),
                );
              },
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        child: const Icon(Icons.done),
        onPressed: () {
          // Validate all required fields are selected
          if (widget._controller.selectedFourth == null) {
            Toast.show("Please select a store", duration: 3);
            return;
          }
          if (widget._controller.first == null) {
            Toast.show("Please select a group", duration: 3);
            return;
          }
          if (widget._controller.second == null) {
            Toast.show("Please select a type", duration: 3);
            return;
          }
          if (widget._controller.third == null) {
            Toast.show("Please select a part", duration: 3);
            return;
          }
          if (widget._controller.quantity.text.isEmpty || 
              int.tryParse(widget._controller.quantity.text) == null ||
              int.parse(widget._controller.quantity.text) <= 0) {
            Toast.show("Please enter a valid quantity", duration: 3);
            return;
          }
          if (widget._controller.remark.text.isEmpty) {
            Toast.show("Please enter a price per unit", duration: 3);
            return;
          }
          if (widget._controller.warranty.text.isEmpty) {
            Toast.show("Please enter warranty period", duration: 3);
            return;
          }
          
          final item = widget._controller.value(context);
          if (item != null) {
            print("CheckinAdd: Returning item: ${item.toString()}");
            Navigator.pop(context, item);
          } else {
            Toast.show("Failed to create item", duration: 3);
          }
        },
      ),
    );
  }

  Widget _dropdown<T>(
    Stream<List<T>> stream,
    Function sink, {
    Stream<T>? value,
    bool enable = false,
  }) {
    return StreamBuilder<List<T>>(
      stream: stream,
      builder: (context, snapshot) => StreamBuilder<T>(
        stream: value,
        builder: (context, AsyncSnapshot<T> selected) {
          final List<DropdownMenuItem<T>> items = [];
          String hint = "";
          String hintDisable = "";
          if (T.toString() == "ComplaintDStore") {
            hint = "Select Store";
            final list = <ComplaintDStore>[];
            if (snapshot.hasData && snapshot.data != null) {
              list.addAll(snapshot.data!.map((e) => e as ComplaintDStore));
            }
            items.addAll(list
                .map((item) => DropdownMenuItem<T>(
                      value: item as T,
                      child: Text(item.itemName ?? 'Unknown'),
                    ))
                .toList());
          } else if (T.toString() == "ComplaintDGroupStore") {
            hint = "Select Group";
            hintDisable = "Select Group";
            final list = <ComplaintDGroupStore>[];
            if (snapshot.hasData && snapshot.data != null) {
              list.addAll(snapshot.data!.map((e) => e as ComplaintDGroupStore));
            }
            items.addAll(list
                .map((item) => DropdownMenuItem<T>(
                      value: item as T,
                      child: Text(item.itemName ?? 'Unknown'),
                    ))
                .toList());
          } else if (T.toString() == "ComplaintDStoreType") {
            hint = "Select Type";
            hintDisable = "Select Type";
            final list = <ComplaintDStoreType>[];
            if (snapshot.hasData && snapshot.data != null) {
              list.addAll(snapshot.data!.map((e) => e as ComplaintDStoreType));
            }
            items.addAll(list
                .map((item) => DropdownMenuItem<T>(
                      value: item as T,
                      child: Text(item.itemName ?? 'Unknown'),
                    ))
                .toList());
          } else if (T.toString() == "MaterialStorePart") {
            hint = "Select Part";
            hintDisable = "Select Part";
            final list = <MaterialStorePart>[];
            if (snapshot.hasData && snapshot.data != null) {
              list.addAll(snapshot.data!.map((e) => e as MaterialStorePart));
            }
            items.addAll(list
                .map((item) => DropdownMenuItem<T>(
                      value: item as T,
                      child: Text(item.itemDescription ?? 'No Description'),
                    ))
                .toList());
          }

          return DropdownButton<T>(
            hint: Text(hint),
            disabledHint: Text(hintDisable),
            isExpanded: true,
            items: items,
            value: selected.data,
            onChanged: enable ? (item) => sink(item) : null,
          );
        },
      ),
    );
  }
}

class Controller extends Bloc {
  // VARIABLES
  final Request _request;
  final TextEditingController _remark = TextEditingController();
  final TextEditingController _quantity = TextEditingController();
  final TextEditingController _subLocation = TextEditingController();
  final TextEditingController _warranty = TextEditingController();

  final BehaviorSubject<bool> _invalidQuantity =
      BehaviorSubject<bool>.seeded(true);
  final BehaviorSubject<String?> _invalidMessage =
      BehaviorSubject<String?>.seeded("Please Check All Fields");
  final BehaviorSubject<ComplaintDGroupStore?> _valueFirst =
      BehaviorSubject<ComplaintDGroupStore?>();
  final BehaviorSubject<ComplaintDStoreType?> _valueSecond =
      BehaviorSubject<ComplaintDStoreType?>();
  final BehaviorSubject<MaterialStorePart?> _valueThird =
      BehaviorSubject<MaterialStorePart?>();
  final BehaviorSubject<ComplaintDStore?> _valueFourth =
      BehaviorSubject<ComplaintDStore?>();
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
      getFirst();
    });
    _valueFirst.listen((value) {
      setsecond(null);
      setthird(null);
      fourth = "";
      invalid = true;
      remark.text = "";
      quantity.text = "";
      getSecond();
    });

    _valueSecond.listen((value) {
      setthird(null);
      fourth = "";
      invalid = true;
      remark.text = "";
      quantity.text = "";
      getThird();
    });

    _valueThird.listen((value) {
      remark.text = "";
      invalid = true;
      quantity.text = value?.partCount ?? "";
    });

    _quantity.addListener(() {
      final value = int.tryParse(_quantity.text);
      if (value == null) {
        invalid = true;
        fourth = "";
        invalidMessage =
            "Quantity must be less than ${_valueThird.value?.partCount ?? "0"}";
      } else {
        if (value == 0) {
          invalid = true;
          fourth = "";
          invalidMessage = "Quantity cannot be 0";
        } else {
          invalidMessage = null;
          invalid = false;
        }
      }
    });

    _request.listFourth().then((value) => listFourth = value);
  }

  // DISPOSE
  @override
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

  // GETTERS
  Stream<List<ComplaintDGroupStore>> get list1$ => _listFirst.stream;
  Stream<List<ComplaintDStoreType>> get list2$ => _listSecond.stream;
  Stream<List<MaterialStorePart>> get list3$ => _listThird.stream;
  Stream<List<ComplaintDStore>> get list4$ => _listFourth.stream;
  Stream<ComplaintDGroupStore?> get first$ => _valueFirst.stream;
  Stream<ComplaintDStoreType?> get second$ => _valueSecond.stream;
  Stream<MaterialStorePart?> get third$ => _valueThird.stream;
  Stream<ComplaintDStore?> get fourth$ => _valueFourth.stream;
  ComplaintDGroupStore? get first => _valueFirst.valueOrNull;
  ComplaintDStoreType? get second => _valueSecond.valueOrNull;
  MaterialStorePart? get third => _valueThird.valueOrNull;
  ComplaintDStore? get selectedFourth => _valueFourth.valueOrNull;
  TextEditingController get remark => _remark;
  TextEditingController get quantity => _quantity;
  TextEditingController get subLocation => _subLocation;
  TextEditingController get warranty => _warranty;
  Stream<bool> get invalid$ => _invalidQuantity.stream;

  String get validity {
    final now = DateTime.now();
    final year = now.year + int.parse(warranty.text);
    final newDate = DateTime(year, now.month, now.day);
    final f = DateFormat("yyyy-MM-dd");
    return f.format(newDate);
  }

  // SETTERS
  void setfirst(ComplaintDGroupStore? value) => _valueFirst.sink.add(value);
  void setsecond(ComplaintDStoreType? value) => _valueSecond.sink.add(value);
  void setthird(MaterialStorePart? value) => _valueThird.sink.add(value);
  void setFourth(ComplaintDStore? value) => _valueFourth.sink.add(value);
  set listFirst(List<ComplaintDGroupStore> values) =>
      _listFirst.sink.add(values);
  set listSecond(List<ComplaintDStoreType> values) =>
      _listSecond.sink.add(values);
  set listThird(List<MaterialStorePart> values) => _listThird.sink.add(values);
  set listFourth(List<ComplaintDStore> values) => _listFourth.sink.add(values);
  set fourth(String value) => _quantity.text = value;
  set invalidMessage(String? value) => _invalidMessage.sink.add(value);
  set invalid(bool value) => _invalidQuantity.sink.add(value);

  // METHODS
  Item? value(BuildContext context) {
    final part = third;
    if (part == null) return null;
    
    return Item(
      first?.itemName ?? "Unknown Group",
      second?.itemName ?? "Unknown Type", 
      part.itemDescription ?? "No Description",
      part.partId ?? "",
      quantity.text,
      remark.text,
      subLocation.text,
      warranty.text,
      validity,
    );
  }

  void getFirst() => _request
      .listFirst(_valueFourth.valueOrNull?.itemId ?? "")
      .then((value) => listFirst = value);
  void getSecond() => _request
      .listSecond(
          _valueFirst.valueOrNull?.itemId ?? "",
          _valueFourth.valueOrNull?.itemId ?? "")
      .then((value) => listSecond = value);
  void getThird() => _request
      .listThird(
          _valueSecond.valueOrNull?.itemId ?? "",
          _valueFourth.valueOrNull?.itemId ?? "")
      .then((value) => listThird = value);
  void getFourth() =>
      _request.listFourth().then((value) => listFourth = value);

  Future<void> upload(BuildContext context) async {
    FocusScope.of(context).unfocus();
    if (_invalidQuantity.value == true) {
      Toast.show(_invalidMessage.valueOrNull ?? "Invalid input", duration: 3);
      throw Exception("Invalid input");
    } else {
      Toast.show("Uploading...", duration: 3);
      await _request.post(
        _valueThird.valueOrNull?.partId ?? "",
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
  final Provider _providerFourth;
  final Provider _providerUpload;

  Request()
      : _providerFirst =
            Provider(fetchURL: "/part/purchase_option_asset_group/"),
        _providerSecond =
            Provider(fetchURL: "/part/purchase_option_item_type/"),
        _providerThird = Provider(fetchURL: "/part/purchase_option_part/"),
        _providerFourth = Provider(fetchURL: "/store/purchase_option_store"),
        _providerUpload = Provider(fetchURL: "/wo_parts");

  Future<List<ComplaintDGroupStore>> listFirst(String id) => _providerFirst
      .fetchComplaint(additionalParam: id, groupStore: true)
      .then((value) => value.map((e) => e as ComplaintDGroupStore).toList());
  Future<List<ComplaintDStoreType>> listSecond(String id, String storeId) =>
      _providerSecond
          .fetchComplaint(additionalParam: "$storeId/$id", storeType: true)
          .then((value) => value.map((e) => e as ComplaintDStoreType).toList());
  Future<List<MaterialStorePart>> listThird(String id, String storeId) =>
      _providerThird
          .fetchComplaint(additionalParam: "$storeId/$id", storePart: true)
          .then((value) => value.map((e) => e as MaterialStorePart).toList());
  Future<List<ComplaintDStore>> listFourth() => _providerFourth
      .fetchComplaint(store: true)
      .then((value) => value.map((e) => e as ComplaintDStore).toList());
  Future<void> post(String itemId, {required String remark, required String quantity}) =>
      _providerUpload.post(url: "/wo_parts", body: {
        "quantity": quantity,
        "itemId": itemId,
        "remark": remark,
      });
}
