import 'package:flutter/material.dart';
import 'package:GEMS/model/complaint.dart';
import 'package:GEMS/utils/network.dart';
import 'package:GEMS/utils/reference.dart';
import 'package:rxdart/rxdart.dart';
import 'package:toast/toast.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:dropdown_search/dropdown_search.dart';

class ComplaintAdd extends StatefulWidget {
  final String id;
  final Controller _controller;

  ComplaintAdd(this.id, {super.key}) : _controller = Controller(id);

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
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        title: Text(
          'Add Material / Item',
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
      body: Stack(
        children: [
          SingleChildScrollView(
            padding: EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Add New Item',
                  style: GoogleFonts.poppins(
                    fontSize: 22,
                    fontWeight: FontWeight.w700,
                    color: Colors.black87,
                  ),
                ),
                SizedBox(height: 8),
                Text(
                  'Please select the item details below',
                  style: GoogleFonts.poppins(
                    fontSize: 14,
                    color: Colors.grey[600],
                  ),
                ),
                SizedBox(height: 24),

                // Group Selection
                _buildSection(
                  title: 'Item Group',
                  icon: Icons.category_outlined,
                  child: _buildDropdownSearch<ComplaintDGroup>(
                    stream: widget._controller.list1$,
                    valueStream: widget._controller.first$,
                    onChanged: widget._controller.setfirst,
                    hintText: "Select Group",
                    itemAsString: (item) => item.itemName ?? "",
                  ),
                ),
                SizedBox(height: 20),

                // Type Selection
                StreamBuilder<ComplaintDGroup>(
                  stream: widget._controller.first$,
                  builder: (context, snapshot) {
                    return _buildSection(
                      title: 'Item Type',
                      icon: Icons.type_specimen_outlined,
                      child: _buildDropdownSearch<ComplaintDType>(
                        stream: widget._controller.list2$,
                        valueStream: widget._controller.second$.where((event) => event != null).cast<ComplaintDType>(),
                        onChanged: widget._controller.setsecond,
                        hintText: "Select Type",
                        enabled: snapshot.data != null,
                        itemAsString: (item) => item.itemName ?? "",
                      ),
                    );
                  },
                ),
                SizedBox(height: 20),

                // Part Selection
                StreamBuilder<ComplaintDType>(
                  stream: widget._controller.second$.where((event) => event != null).cast<ComplaintDType>(),
                  builder: (context, snapshot) {
                    return _buildSection(
                      title: 'Item Part',
                      icon: Icons.inventory_outlined,
                      child: _buildDropdownSearch<ComplaintDPart>(
                        stream: widget._controller.list3$,
                        valueStream: widget._controller.third$.where((event) => event != null).cast<ComplaintDPart>(),
                        onChanged: widget._controller.setthird,
                        hintText: "Select Part",
                        enabled: snapshot.data != null,
                        itemAsString: (item) => item.itemName ?? "",
                      ),
                    );
                  },
                ),
                SizedBox(height: 20),

                // Quantity and Remark
                _buildSection(
                  title: 'Item Details',
                  icon: Icons.edit_outlined,
                  child: Column(
                    children: [
                      StreamBuilder<ComplaintDPart>(
                        stream: widget._controller.third$.where((event) => event != null).cast<ComplaintDPart>(),
                        builder: (context, snapshot) {
                          return TextField(
                            enabled: snapshot.data != null,
                            controller: widget._controller.quantity,
                            keyboardType: TextInputType.number,
                            decoration: InputDecoration(
                              labelText: 'Quantity',
                              hintText: '0',
                              floatingLabelBehavior: FloatingLabelBehavior.always,
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                                borderSide: BorderSide(color: Colors.grey[300]!),
                              ),
                              enabledBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                                borderSide: BorderSide(color: Colors.grey[300]!),
                              ),
                              filled: true,
                              fillColor: Colors.white,
                              contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                            ),
                            style: GoogleFonts.poppins(fontSize: 14),
                          );
                        },
                      ),
                      SizedBox(height: 16),
                      StreamBuilder<ComplaintDPart>(
                        stream: widget._controller.third$.where((event) => event != null).cast<ComplaintDPart>(),
                        builder: (context, snapshot) {
                          return TextField(
                            enabled: snapshot.data != null,
                            controller: widget._controller.remark,
                            decoration: InputDecoration(
                              labelText: 'Remark',
                              hintText: '-',
                              floatingLabelBehavior: FloatingLabelBehavior.always,
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                                borderSide: BorderSide(color: Colors.grey[300]!),
                              ),
                              enabledBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                                borderSide: BorderSide(color: Colors.grey[300]!),
                              ),
                              filled: true,
                              fillColor: Colors.white,
                              contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                            ),
                            maxLines: 3,
                            style: GoogleFonts.poppins(fontSize: 14),
                          );
                        },
                      ),
                    ],
                  ),
                ),
                SizedBox(height: 40),

                Padding(
                  padding: EdgeInsets.symmetric(horizontal: 20),
                  child: SizedBox(
                    width: double.infinity,
                    child: FloatingActionButton.extended(
                      onPressed: () => widget._controller
                          .upload(context)
                          .then((value) => Navigator.pop(context))
                          .catchError((e) => Toast.show(e.toString())),
                      backgroundColor: AppColors.primary,
                      elevation: 2,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      label: Padding(
                        padding: EdgeInsets.symmetric(vertical: 16),
                        child: Text(
                          'ADD NEW ITEM',
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
        ],
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

  Widget _buildDropdownSearch<T>({
    required Stream<List<T>> stream,
    required Stream<T> valueStream,
    required Function(T?) onChanged,
    required String hintText,
    required String Function(T) itemAsString,
    bool enabled = true,
  }) {
    return StreamBuilder<List<T>>(
      stream: stream,
      builder: (context, snapshot) {
        final List<T> list = (snapshot.data ?? []).where((element) => element != null).toList();
        return StreamBuilder<T>(
          stream: valueStream,
          builder: (context, selected) {
            return DropdownSearch<T>(
              items: (String filter, LoadProps? loadProps) => list,
              selectedItem: selected.data,
              popupProps: PopupProps.modalBottomSheet(
                showSearchBox: true,
                searchFieldProps: TextFieldProps(
                  decoration: InputDecoration(
                    hintText: 'Search $hintText...',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide(color: Colors.grey[300]!),
                    ),
                    contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                  ),
                ),
                modalBottomSheetProps: ModalBottomSheetProps(
                  backgroundColor: Colors.grey[50],
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
                  ),
                ),
              ),
              itemAsString: itemAsString,
              compareFn: (T a, T b) => a == b,
              decoratorProps: DropDownDecoratorProps(
                decoration: InputDecoration(
                  labelText: hintText,
                  floatingLabelBehavior: FloatingLabelBehavior.always,
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
                  contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                ),
              ),
              onChanged: enabled ? onChanged : null,
              enabled: enabled,
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
      getSecond();
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
