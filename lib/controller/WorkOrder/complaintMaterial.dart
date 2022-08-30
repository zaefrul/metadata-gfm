import 'package:flutter/material.dart';
import 'package:gfm_gems/model/complaint.dart';
import 'package:gfm_gems/utils/network.dart';
import 'package:rxdart/rxdart.dart';
import 'package:toast/toast.dart';

class MaterialEdit extends StatefulWidget {
  final String id;
  final Controller _controller;

  MaterialEdit(this.id) : _controller = Controller(id);

  @override
  _MaterialEditState createState() => _MaterialEditState();
}

class _MaterialEditState extends State<MaterialEdit> {
  @override
  void dispose() {
    widget._controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Material / Item"),
        centerTitle: true,
        backgroundColor: Colors.white,
      ),
      body: Container(
        padding: EdgeInsets.all(12),
        child: ListView(
          children: [
            _buildField("Group",
                enable: false, controller: widget._controller._group),
            _buildField("Type",
                enable: false, controller: widget._controller._type),
            _buildField("Name",
                enable: false, controller: widget._controller._name),
            _buildField("Quantity", controller: widget._controller._quantity),
            _buildField("Remark", controller: widget._controller._remark),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
          child: Icon(Icons.done),
          onPressed: () => widget._controller
              .update(context)
              .then((value) => Navigator.pop(context))),
    );
  }

  Widget _buildField(
    String label, {
    TextEditingController controller,
    bool enable = true,
  }) {
    return TextField(
        enabled: enable,
        controller: controller,
        decoration: InputDecoration(labelText: label));
  }
}

class Controller {
  // VARIABLE
  final String id;
  final Request _request;
  final TextEditingController _group = TextEditingController();
  final TextEditingController _type = TextEditingController();
  final TextEditingController _name = TextEditingController();
  final TextEditingController _quantity = TextEditingController();
  final TextEditingController _remark = TextEditingController();

  final BehaviorSubject<bool> _invalidQuantity =
      BehaviorSubject<bool>.seeded(true);
  final BehaviorSubject<String> _invalidMessage =
      BehaviorSubject<String>.seeded("Please Check All Field");
  final BehaviorSubject<ComplaintD> _item = BehaviorSubject<ComplaintD>();

  // INITIALIZER
  Controller(this.id) : _request = Request(id) {
    getItem();
    _item.listen((event) {
      _group.text = event.assetGroupName;
      _type.text = event.itemTypeDesc;
      _name.text = event.itemDescription;
      _quantity.text = event.woTaskPartsQuantity;
      _remark.text = event.woTaskPartsRemark;
    });
    _quantity.addListener(() {
      final value = int.tryParse(_quantity.text);
      if (value == null) {
        invalid = true;
        invalidMessage = "Quantity cannot 0";
      } else {
        if (value == 0) {
          invalid = true;
          invalidMessage = "Quantity cannot 0";
        } else {
          invalidMessage = null;
          invalid = false;
        }
      }
    });
  }

  // DISPOSE
  void dispose() {
    _remark.dispose();
    _quantity.dispose();
    _invalidQuantity.close();
    _invalidMessage.close();
    _item.close();
    _group.dispose();
    _type.dispose();
    _name.dispose();
  }

  // GET
  get remark => _remark;
  get quantity => _quantity;
  get item$ => _item.stream;
  get invalid$ => _invalidQuantity.stream;

  // SINK
  set item(ComplaintD value) => _item.sink.add(value);
  set invalidMessage(String value) => _invalidMessage.sink.add(value);
  set invalid(bool value) => _invalidQuantity.sink.add(value);

  // METHOD
  void getItem() => _request.response.then((value) => item = value);
  Future<void> update(BuildContext context) {
    FocusScope.of(context).unfocus();
    if (_invalidQuantity.value == true) {
      Toast.show(_invalidMessage.value, duration: 3);
      throw "";
    } else {
      if (_invalidMessage.value != null)
        Toast.show(_invalidMessage.value, duration: 3);
      return _request.post(remark: remark.text, quantity: _quantity.text);
    }
  }
}

class Request {
  final Provider _providerGET;
  final Provider _providerUpdate;

  Request(String id)
      : _providerGET =
            Provider(taskID: id, fetchURL: "/wo_parts/wo_parts_mobile_detail/"),
        _providerUpdate = Provider(taskID: id, fetchURL: "/wo_parts/");

  Future<ComplaintD> get response =>
      _providerGET.getJson().then((value) => ComplaintD.fromJson(value));

  Future<void> post({String remark, String quantity}) =>
      _providerUpdate.put(body: {"quantity": quantity, "remark": remark});
}
