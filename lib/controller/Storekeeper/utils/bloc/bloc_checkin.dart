import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_image_compress/flutter_image_compress.dart';
import 'package:gfm_gems/model/complaint.dart';
import 'package:gfm_gems/model/serializers.dart';
import 'package:gfm_gems/utils/network.dart';
import 'package:image_picker/image_picker.dart';
import 'package:image_size_getter/file_input.dart';
import 'package:image_size_getter/image_size_getter.dart';
import 'package:intl/intl.dart';
import 'package:rxdart/subjects.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:toast/toast.dart';

import 'bloc.dart';

final String _kMaterials = "MATERIALS";
final String _kDoNo = "DONO";
final String _kDo = "DO";
final String _kStore = "STORE";
final String _kSupplier = "SUPPLIER";

class BlocCheckin extends Bloc {
  final _store = BehaviorSubject<ComplaintDStore>();
  final _materials = BehaviorSubject<List<Item>>.seeded([]);
  final _do = BehaviorSubject<List<File>>.seeded([]);
  final _doNo = TextEditingController();
  final _supplierName = TextEditingController();

  BlocCheckin() {
    getMaterials().whenComplete(
      () => _materials.listen((value) => saveMaterials()),
    );
    getDoNo().whenComplete(
      () => _doNo.addListener(() => saveDoNo()),
    );
    getSupplierName().whenComplete(
      () => _supplierName.addListener(() => saveSupplierName()),
    );
    getDo().whenComplete(
      () => _do.listen((value) => saveDo()),
    );
    getStore().whenComplete(
      () => _store.listen((value) => saveStore()),
    );
  }

  set materials(List<Item> values) => _materials.sink.add(values);
  get materials$ => _materials.stream;
  set dos(List<File> values) => _do.sink.add(values);
  get do$ => _do.stream;
  set material(Item value) {
    final list = _materials.value;
    list.add(value);
    _materials.sink.add(list);
  }

  set file(File value) {
    final list = _do.value;
    list.add(value);
    _do.sink.add(list);
  }

  set store(ComplaintDStore value) => _store.sink.add(value);
  get store$ => _store.stream;
  get doNoCtrl => _doNo;
  get supplierCtrl => _supplierName;

  @override
  void dispose() {
    _do.close();
    _store.close();
    _materials.close();
    _doNo.dispose();
    _supplierName.dispose();
    super.dispose();
  }

  void saveMaterials() async {
    print("save");
    final list = _materials.value;
    final pref = await SharedPreferences.getInstance();
    final listString = list.map((e) => json.encode(e)).toList();
    print(listString);
    pref.setStringList(_kMaterials, listString);
  }

  void saveDoNo() async {
    final value = _doNo.text;
    final pref = await SharedPreferences.getInstance();
    pref.setString(_kDoNo, value);
  }

  void saveSupplierName() async {
    final value = _supplierName.text;
    final pref = await SharedPreferences.getInstance();
    pref.setString(_kSupplier, value);
  }

  void saveDo() async {
    final values = _do.value.map((e) => e.path).toList();
    final pref = await SharedPreferences.getInstance();
    pref.setStringList(_kDo, values);
  }

  void saveStore() async {
    final value = _store.value.toJson();
    final pref = await SharedPreferences.getInstance();
    pref.setString(_kStore, json.encode(value));
  }

  Future<void> getMaterials() async {
    final pref = await SharedPreferences.getInstance();
    final list = pref.getStringList(_kMaterials);
    final listM = list.map((e) => Item.fromString(json.decode(e))).toList();
    _materials.sink.add(listM);
    return;
  }

  Future<void> getDoNo() async {
    final pref = await SharedPreferences.getInstance();
    final value = pref.getString(_kDoNo);
    _doNo.text = value;
    return;
  }

  Future<void> getSupplierName() async {
    final pref = await SharedPreferences.getInstance();
    final value = pref.getString(_kSupplier);
    _supplierName.text = value;
    return;
  }

  Future<void> getDo() async {
    final pref = await SharedPreferences.getInstance();
    final values = pref.getStringList(_kDo);
    dos = values.map((e) => File(e)).toList();
    return;
  }

  Future<void> getStore() async {
    final pref = await SharedPreferences.getInstance();
    final value = pref.getString(_kStore);
    final translate = json.decode(value);
    final item = deserialize<ComplaintDStore>(translate);
    store = item;
    return;
  }

  Future<List<ComplaintDStore>> fetchStore(BuildContext context) async {
    final Provider _provider =
        Provider(fetchURL: "/store/purchase_option_store");
    _provider.context = context;

    final result = await checker(_provider.getJson());
    final list = deserializeListOf<ComplaintDStore>(result).toList();

    if (_store.value == null) _store.sink.add(list.first);
    return list;
  }

  Future<void> submit(BuildContext context) async {
    final valuesM = _materials.value;
    final valuesD = _do.value;
    final fieldStore = _store.value;
    final fieldDoNo = _doNo.text;
    final fieldSupplier = _supplierName.text;

    if (valuesM.length == 0) throw "Please select material";
    if (valuesD.length == 0) throw "Please upload DO ";
    if (fieldStore == null) throw "Please select Store";
    if (fieldDoNo.length == 0) throw "Please insert Do Number";
    if (fieldSupplier.length == 0) throw "Please insert Supplier Name";
    final Provider _provider = Provider();
    _provider.context = context;

    final body = await param;
    return checker(
            _provider.postUtilities(url: "/do/check_in_direct", body: body))
        .then((_) async {
      final pref = await SharedPreferences.getInstance();
      pref.remove(_kMaterials);
      pref.remove(_kDoNo);
      pref.remove(_kDo);
      pref.remove(_kStore);
      pref.remove(_kSupplier);
    });
  }

  Future<Map> get param async {
    final value = {
      "storeId": _store.value.itemId,
      "doNo": _doNo.text,
      "doDate": DateFormat('yyyy-MM-dd').format(DateTime.now()),
      "supplierName": _supplierName.text,
    };
    final valuesM = _materials.value;
    for (var i = 0; i < valuesM.length; i++) {
      final item = valuesM[i];
      final map = item.toJson();
      map.forEach((k, v) => value["doItems[$i][$k]"] = v);
    }
    final valuesD = _do.value;
    for (var i = 0; i < valuesD.length; i++) {
      final File item = valuesD[i];
      final getter = ImageSizeGetter.getSize(FileInput(item));
      final height = getter.height;
      final width = getter.width;
      final type = 'data:image/jpg:base64';
      final filename = "DO";
      final bytes = await compressFile(item);
      final size = bytes.length.toString();
      String name =
          DateFormat('kk:mm:ss EEE d MMM').format(DateTime.now()) + ".jpg";
      final data = base64Encode(bytes);

      value['doUploads[$i][name]'] = filename;
      value['doUploads[$i][filename]'] = name;
      value['doUploads[$i][type]'] = type;
      value['doUploads[$i][size]'] = size;
      value['doUploads[$i][data]'] = data;
      value['doUploads[$i][height]'] = height.toString();
      value['doUploads[$i][width]'] = width.toString();
    }

    return value;
  }

  Future<List<int>> compressFile(File file) async {
    var result = await FlutterImageCompress.compressWithFile(file.absolute.path,
        quality: Platform.isIOS ? 20 : 60, minWidth: 480, minHeight: 640);
    print(file.lengthSync());
    print(result.length);
    return result;
  }

  void createUploadItem(BuildContext context) async {
    final value = await ImagePicker().pickImage(source: ImageSource.camera);

    if (value != null) {
      file = File(value.path);
    } else
      Toast.show("Only one picture is required");
  }

  void removeMaterial(Item value) {
    final list = _materials.value;
    list.removeWhere((element) => element == value);
    materials = list;
  }
}

class Item {
  final String itemGroupName;
  final String itemTypeName;
  final String itemName;
  final String itemId;
  final String itemQuantity;
  final String itemPrice;
  final String partSubLocation;
  final String doItemWarranty;
  final String doItemValidity;

  Item(
    this.itemGroupName,
    this.itemTypeName,
    this.itemName,
    this.itemId,
    this.itemQuantity,
    this.itemPrice,
    this.partSubLocation,
    this.doItemWarranty,
    this.doItemValidity,
  );

  Item.fromString(dynamic value)
      : this.itemGroupName = value["itemGroupName"],
        this.itemTypeName = value["itemTypeName"],
        this.itemName = value["itemName"],
        this.itemId = value["partId"],
        this.itemQuantity = value["doItemTotal"],
        this.itemPrice = value["doItemCost"],
        this.partSubLocation = value["partSubLocation"],
        this.doItemWarranty = value["doItemWarranty"],
        this.doItemValidity = value["doItemValidity"];

  Map toJson() => {
        "itemGroupName": itemGroupName,
        "itemTypeName": itemTypeName,
        "itemName": itemName,
        "partId": itemId,
        "doItemTotal": itemQuantity,
        "doItemCost": itemPrice,
        "partSubLocation": partSubLocation,
        "doItemWarranty": doItemWarranty,
        "doItemValidity": doItemValidity,
      };

  @override
  String toString() {
    return toJson().toString();
  }
}
