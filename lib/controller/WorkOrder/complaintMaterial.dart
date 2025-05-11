import 'package:flutter/material.dart';
import 'package:gfm_gems/model/complaint.dart';
import 'package:gfm_gems/utils/network.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:rxdart/rxdart.dart';
import 'package:toast/toast.dart';
import 'package:gfm_gems/utils/reference.dart';

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
    debugPrint("Controller: ${widget._controller.group.text}");
    debugPrint("Controller: ${widget._controller.group.value}");
    ToastContext().init(context);
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        title: Text(
          'Material / Item',
          style: GoogleFonts.poppins(
            fontWeight: FontWeight.w600,
            fontSize: 18,
          ),
        ),
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
        iconTheme: IconThemeData(color: Colors.black87),
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Item Information Section
            _buildSection(
              title: 'Item Information',
              icon: Icons.inventory_outlined,
              child: Column(
                children: [
                  _buildReadOnlyField('Group', false, 1, widget._controller.group),
                  SizedBox(height: 16),
                  _buildReadOnlyField('Type', false, 3, widget._controller.type),
                  SizedBox(height: 16),
                  _buildReadOnlyField('Name', false, 1, widget._controller.name),
                ],
              ),
            ),
            
            SizedBox(height: 20),
            
            // Edit Details Section
            _buildSection(
              title: 'Edit Details',
              icon: Icons.edit_outlined,
              child: Column(
                children: [
                  _buildEditableField(
                    'Quantity',
                    widget._controller.quantity,
                    keyboardType: TextInputType.number,
                  ),
                  SizedBox(height: 16),
                  _buildEditableField(
                    'Remark',
                    widget._controller.remark,
                    maxLines: 3,
                  ),
                ],
              ),
            ),
            
            SizedBox(height: 40),
            
            // Save Button
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 20),
              child: SizedBox(
                width: double.infinity,
                child: FloatingActionButton.extended(
                  onPressed: () => widget._controller
                      .update(context)
                      .then((_) => Navigator.pop(context))
                      .catchError((e) {}),
                  backgroundColor: AppColors.primary,
                  elevation: 2,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  label: Padding(
                    padding: EdgeInsets.symmetric(vertical: 16),
                    child: Text(
                      'SAVE CHANGES',
                      style: GoogleFonts.poppins(
                        fontSize: 15,
                        fontWeight: FontWeight.w600,
                        letterSpacing: 0.5,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
              ),
            ),
            
            SizedBox(height: 40),
          ],
        ),
      ),
    );
  }

  Widget _buildSection({
    required String title,
    required Widget child,
    required IconData icon,
  }) {
    return Container(
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, size: 20, color: AppColors.primary),
              SizedBox(width: 8),
              Text(
                title,
                style: GoogleFonts.poppins(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
          SizedBox(height: 16),
          child,
        ],
      ),
    );
  }

  Widget _buildReadOnlyField(String label, bool enable, int? maxline, TextEditingController controller) {
    debugPrint("ReadOnly: $controller");
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: GoogleFonts.poppins(
            fontSize: 14,
            color: Colors.grey[600],
          ),
        ),
        SizedBox(height: 4),
        TextField(
          controller: controller,
          maxLines: maxline,
          enabled: enable,
          decoration: InputDecoration(
            contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: Colors.grey[300]!),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: Colors.grey[300]!),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: AppColors.primary),
            ),
            filled: true,
            fillColor: Colors.white,
          ),
          style: GoogleFonts.poppins(
            fontSize: 14,
            color: Colors.black87,
          ),
        ),
      ],
    );
  }

  Widget _buildEditableField(
    String label,
    TextEditingController controller, {
    int maxLines = 1,
    TextInputType keyboardType = TextInputType.text,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: GoogleFonts.poppins(
            fontSize: 14,
            color: Colors.grey[600],
          ),
        ),
        SizedBox(height: 4),
        TextField(
          controller: controller,
          maxLines: maxLines,
          keyboardType: keyboardType,
          decoration: InputDecoration(
            contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: Colors.grey[300]!),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: Colors.grey[300]!),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: AppColors.primary),
            ),
            filled: true,
            fillColor: Colors.white,
          ),
          style: GoogleFonts.poppins(
            fontSize: 14,
            color: Colors.black87,
          ),
        ),
      ],
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
