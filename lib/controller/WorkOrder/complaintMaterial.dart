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
    ToastContext().init(context);
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
                enable: false, controller: widget._controller.group),
            _buildField("Type",
                enable: false, controller: widget._controller.type),
            _buildField("Name",
                enable: false, controller: widget._controller.name),
            _buildField("Quantity", controller: widget._controller.quantity),
            _buildField("Remark", controller: widget._controller.remark),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        child: Icon(Icons.done),
        onPressed: () => widget._controller
            .update(context)
            .then((_) => Navigator.pop(context)),
      ),
    );
  }

  Widget _buildField(String label,
      {required TextEditingController controller, bool enable = true}) {
    return TextField(
      enabled: enable,
      controller: controller,
      decoration: InputDecoration(labelText: label),
    );
  }
}

class Controller {
  // VARIABLES
  final String id;
  final Request _request;
  final TextEditingController _group = TextEditingController();
  final TextEditingController _type = TextEditingController();
  final TextEditingController _name = TextEditingController();
  final TextEditingController _quantity = TextEditingController();
  final TextEditingController _remark = TextEditingController();

  final BehaviorSubject<bool> _invalidQuantity =
      BehaviorSubject<bool>.seeded(true);
  final BehaviorSubject<String?> _invalidMessage =
      BehaviorSubject<String?>.seeded("Please Check All Field");
  final BehaviorSubject<ComplaintD> _item =
      BehaviorSubject<ComplaintD>();

  // INITIALIZER
  Controller(this.id) : _request = Request(id) {
    getItem();
    _item.listen((event) {
      _group.text = event.assetGroupName ?? '';
      _type.text = event.itemTypeDesc ?? '';
      _name.text = event.itemDescription ?? '';
      _quantity.text = event.woTaskPartsQuantity ?? '';
      _remark.text = event.woTaskPartsRemark ?? '';
    });
    _quantity.addListener(() {
      final value = int.tryParse(_quantity.text);
      if (value == null || value == 0) {
        invalid = true;
        invalidMessage = "Quantity cannot be 0";
      } else {
        invalidMessage = null;
        invalid = false;
      }
    });
  }

  // DISPOSE
  void dispose() {
    _group.dispose();
    _type.dispose();
    _name.dispose();
    _quantity.dispose();
    _remark.dispose();
    _invalidQuantity.close();
    _invalidMessage.close();
    _item.close();
  }

  // GETTERS
  TextEditingController get group => _group;
  TextEditingController get type => _type;
  TextEditingController get name => _name;
  TextEditingController get quantity => _quantity;
  TextEditingController get remark => _remark;
  Stream<ComplaintD> get item$ => _item.stream;
  Stream<bool> get invalid$ => _invalidQuantity.stream;

  // SETTERS
  set item(ComplaintD value) => _item.sink.add(value);
  set invalidMessage(String? value) => _invalidMessage.sink.add(value);
  set invalid(bool value) => _invalidQuantity.sink.add(value);

  // METHODS
  void getItem() => _request.response.then((value) => item = value);

  Future<void> update(BuildContext context) {
    FocusScope.of(context).unfocus();
    if (_invalidQuantity.value == true) {
      Toast.show(_invalidMessage.value ?? "",
          duration: 3);
      return Future.error("Invalid quantity");
    } else {
      Toast.show(_invalidMessage.value ?? "",
          duration: 3);
      return _request.post(
          remark: _remark.text, quantity: _quantity.text);
    }
  }
}

class Request {
  final Provider _providerGET;
  final Provider _providerUpdate;

  Request(String id)
      : _providerGET = Provider(
          taskID: id,
          fetchURL: "/wo_parts/wo_parts_mobile_detail/",
        ),
        _providerUpdate = Provider(
          taskID: id,
          fetchURL: "/wo_parts/",
        );

  Future<ComplaintD> get response =>
      _providerGET.getJson(url: "/wo_parts/wo_parts_mobile_detail/").then((value) => ComplaintD.fromJson(value) ?? ComplaintD());

  Future<void> post({required String remark, required String quantity}) =>
      _providerUpdate.put(body: {"quantity": quantity, "remark": remark});
}
