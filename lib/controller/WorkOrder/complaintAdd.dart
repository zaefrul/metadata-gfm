import 'package:flutter/material.dart';
import 'package:gfm_gems/model/complaint.dart';
import 'package:rxdart/rxdart.dart';
import 'package:toast/toast.dart';
import 'package:custom_searchable_dropdown/custom_searchable_dropdown.dart';

class Controller {
  final String id;
  final BehaviorSubject<List<ComplaintDGroup>> list1$ = BehaviorSubject();
  final BehaviorSubject<List<ComplaintDType>> list2$ = BehaviorSubject();
  final BehaviorSubject<List<ComplaintDPart>> list3$ = BehaviorSubject();
  final BehaviorSubject<ComplaintDGroup?> first$ = BehaviorSubject();
  final BehaviorSubject<ComplaintDType?> second$ = BehaviorSubject();
  final BehaviorSubject<ComplaintDPart?> third$ = BehaviorSubject();
  final TextEditingController quantity = TextEditingController();
  final TextEditingController remark = TextEditingController();

  Controller(this.id);

  void setfirst(ComplaintDGroup group) {
    first$.add(group);
  }

  void setsecond(ComplaintDType type) {
    second$.add(type);
  }

  void setthird(ComplaintDPart part) {
    third$.add(part);
  }

  Future<void> upload(BuildContext context) async {
    // Add upload logic here
  }

  void dispose() {
    list1$.close();
    list2$.close();
    list3$.close();
    first$.close();
    second$.close();
    third$.close();
    quantity.dispose();
    remark.dispose();
  }
}

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
            _dropdown<ComplaintDGroup>(
              widget._controller.list1$,
              widget._controller.setfirst,
              value: widget._controller.first$.cast<ComplaintDGroup>(),
              enable: true,
            ),
            StreamBuilder<ComplaintDGroup>(
                stream: widget._controller.first$.cast<ComplaintDGroup>(),
                builder: (context, AsyncSnapshot<ComplaintDGroup> snapshot) {
                  return _dropdown<ComplaintDType>(
                      widget._controller.list2$, widget._controller.setsecond,
                      value: widget._controller.second$.cast<ComplaintDType>(),
                      enable: snapshot.hasData && snapshot.data != null);
                }),
            StreamBuilder<ComplaintDType>(
                stream: widget._controller.second$.cast<ComplaintDType>(),
                builder: (context, AsyncSnapshot<ComplaintDType> snapshot) {
                  return _dropdown<ComplaintDPart>(
                      widget._controller.list3$, widget._controller.setthird,
                      value: widget._controller.third$.cast<ComplaintDPart>(),
                      enable: snapshot.hasData && snapshot.data != null);
                }),
            StreamBuilder<ComplaintDPart>(
              stream: widget._controller.third$.whereType<ComplaintDPart>(),
              builder: (context, snapshot) => TextField(
                  enabled: snapshot.hasData && snapshot.data != null,
                  controller: widget._controller.quantity,
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(
                      labelText: "Quantity", hintText: "0")),
            ),
            StreamBuilder<ComplaintDPart>(
              stream: widget._controller.third$.whereType<ComplaintDPart>(),
              builder: (context, snapshot) => TextField(
                  enabled: snapshot.hasData && snapshot.data != null,
                  controller: widget._controller.remark,
                  decoration: const InputDecoration(
                      labelText: "Remark", hintText: "-")),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
          heroTag: "ADD NEW PARTS",
          child: const Icon(Icons.done),
          onPressed: () => widget._controller
              .upload(context)
              .then((value) => Navigator.pop(context))
              .catchError((e) => Toast.show(e.toString()))),
    );
  }

  Widget _dropdown<T>(
    Stream<List<T>> stream,
    Function(T) sink, {
    Stream<T>? value,
    bool enable = false,
  }) {
    return StreamBuilder<List<T>>(
        stream: stream,
        builder: (context, snapshot) => StreamBuilder<T>(
            stream: value,
            builder: (context, AsyncSnapshot<T> selected) {
              final List<DropdownMenuItem<T>> _items = [];
              final List<T> list = [];
              String _hint = "";
              String _hintDisable = "";
              if (T.toString() == "ComplaintDGroup") {
                _hint = "Select Group";
                if (snapshot.hasData && snapshot.data != null) {
                  list.addAll(snapshot.data!.map((e) => e));
                }
                _items.addAll(list
                    .map((item) => DropdownMenuItem<T>(
                          child: Text((item as ComplaintDGroup).itemName ?? ""),
                          value: item as T,
                        ))
                    .toList());
              } else if (T.toString() == "ComplaintDType") {
                _hint = "Select Type";
                _hintDisable = "Select Type";
                if (snapshot.hasData && snapshot.data != null) {
                  list.addAll(snapshot.data!.map((e) => e));
                }
                _items.addAll(list
                    .map((item) => DropdownMenuItem<T>(
                          child: Text((item as ComplaintDType).itemName ?? ""),
                          value: item as T,
                        ))
                    .toList());
              } else if (T.toString() == "ComplaintDPart") {
                _hint = "Select Part";
                _hintDisable = "Select Part";
                if (snapshot.hasData && snapshot.data != null) {
                  list.addAll(snapshot.data!.map((e) => e));
                }
                _items.addAll(list
                    .map((item) => DropdownMenuItem<T>(
                          child: Text((item as ComplaintDPart).itemName ?? ""),
                          value: item as T,
                        ))
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
                    )
                  ),
                prefixIcon: const Padding(
                  padding: EdgeInsets.all(0.0),
                  child: Icon(Icons.search),
                ),
                dropDownMenuItems:
                  list.map((e) => (e is ComplaintDGroup)
                            ? e.itemName
                            : (e is ComplaintDType)
                                ? e.itemName
                                : (e is ComplaintDPart)
                                    ? e.itemName
                                    : "")
                        .toList(),
                onChanged: (item) {
                  if (enable && item != null) {
                    sink(item);
                  }
                },
              );
            }));
  }
}
