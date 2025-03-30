import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:gfm_gems/controller/Storekeeper/utils/bloc/bloc_checkin.dart';
import 'package:rxdart/subjects.dart';
import 'package:shared_preferences/shared_preferences.dart';

class CheckinMaterial extends StatefulWidget {
  @override
  _CheckinMaterialState createState() => _CheckinMaterialState();
}

class _CheckinMaterialState extends State<CheckinMaterial> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Checkin Material"),
        backgroundColor: Colors.white,
        centerTitle: true,
      ),
      body: ListView(
        padding: EdgeInsets.only(top: 12, left: 16, right: 16, bottom: 50),
        children: [],
      ),
    );
  }
}

class _ListMaterial extends StatelessWidget {
  final Stream<List<Item>> stream;

  _ListMaterial(this.stream);

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<List<Item>>(
        stream: stream,
        builder: (context, snapshot) {
          return Column(
            children: snapshot.data == null
                ? []
                : snapshot.data?.map((e) => Text(e.itemId)).toList() ?? [],
          );
        });
  }
}

class _MaterialTile extends StatelessWidget {
  final Item item;
  _MaterialTile(this.item);

  @override
  Widget build(BuildContext context) {
    return Container();
  }
}

class Controller {
  final BehaviorSubject<List<Item>> _items =
      BehaviorSubject<List<Item>>.seeded([]);

  Controller() {
    SharedPreferences.getInstance().then((value) {
      final List<String> list = value.getStringList("material_checkin") ?? [];
      return list.map((e) => Item.fromString(jsonDecode(e))).toList();
    }).then((value) => setItems(value));
  }

  set item(Item value) {
    final values = _items.value;
    values.add(value);

    setItems(values);
  }

  void setItems(List<Item> values) async {
    final prefs = await SharedPreferences.getInstance();
    final List<String> encode = values.map((e) => jsonEncode(e)).toList();
    prefs.setStringList("material_checkin", encode);

    _items.sink.add(values);
  }

  void dispose() {
    _items.close();
  }
}

class Request {}
