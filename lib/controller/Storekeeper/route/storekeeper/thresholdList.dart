import 'package:flutter/material.dart';
import 'package:GEMS/controller/Storekeeper/utils/constant.dart';
import 'package:GEMS/model/complaint.dart';
import 'package:GEMS/model/serializers.dart';
import 'package:GEMS/utils/network.dart';
import 'package:rxdart/subjects.dart';

class ThresholdListView extends StatefulWidget {
  @override
  _ThresholdListViewState createState() => _ThresholdListViewState();
}

class _ThresholdListViewState extends State<ThresholdListView> {
  late Controller _controller;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    setState(() => _controller = Controller(context));
  }

  @override
  Widget build(BuildContext context) {
    return RefreshIndicator(
      onRefresh: () => _controller.getStore(context),
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _filter,
            Divider(color: Colors.black38, height: 0),
            StreamBuilder<List<Map<String, String>>>(
                stream: _controller._materials,
                builder: (context, snapshot) {
                  if (snapshot.data == null)
                    return Center(child: CircularProgressIndicator());

                  final data = snapshot.data;

                  return ListView(
                    physics: NeverScrollableScrollPhysics(),
                    shrinkWrap: true,
                    padding: EdgeInsets.only(bottom: 20),
                    scrollDirection: Axis.vertical,
                    children: List.generate(
                      data?.length ?? 0,
                      (index) => _Material(index + 1, data?[index] ?? {}),
                    ),
                  );
                }),
          ],
        ),
      ),
    );
  }

  Widget get _filter => StreamBuilder<List<ComplaintDStore>>(
      stream: _controller.stores$,
      builder: (context, snapshotList) {
        if (snapshotList.data == null) return Container();
        return StreamBuilder<ComplaintDStore>(
            stream: _controller.store$,
            builder: (context, snapshot) {
              return Padding(
                padding: EdgeInsets.all(12),
                child: Row(
                  children: [
                    Text(
                      "Store :  ",
                      style: TextStyle(fontSize: 16),
                    ),
                    DropdownButton<ComplaintDStore>(
                      underline: new Container(),
                      value: snapshot.data,
                      hint: Text("Select Store"),
                      onChanged: (ComplaintDStore? newValue) {
                        if (newValue != null) {
                          _controller.store = newValue;
                        }
                      },
                      items: snapshotList.data
                          ?.map<DropdownMenuItem<ComplaintDStore>>(
                              (ComplaintDStore value) {
                        return DropdownMenuItem<ComplaintDStore>(
                          value: value,
                          child: Text(value.itemName ?? 'Unknown'),
                        );
                      }).toList() ?? [],
                    ),
                  ],
                ),
              );
            });
      });
}

class _Material extends StatelessWidget {
  final int index;
  final String assetGroupName;
  final String itemTypeDesc;
  final String itemDescription;
  final String partCount;
  final String partId;
  final String partAvailable;
  final String partThreshold;
  final String partRemark;

  _Material(this.index, Map<String, String> data)
      : this.assetGroupName = data["assetGroupName"] ?? '',
        this.itemTypeDesc = data["itemTypeDesc"] ?? '',
        this.itemDescription = data["itemDescription"] ?? '',
        this.partCount = data["partCount"] ?? '',
        this.partId = data["partId"] ?? '',
        this.partAvailable = data["partAvailable"] ?? '',
        this.partThreshold = data["partThreshold"] ?? '',
        this.partRemark = data["partRemark"] ?? '';

  @override
  Widget build(BuildContext context) {
    return ExpansionTile(
      title: Padding(
        padding: const EdgeInsets.symmetric(vertical: 8.0),
        child: Text(
          index.toString() + '.  $itemDescription',
          overflow: TextOverflow.ellipsis,
        ),
      ),
      subtitle: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        text(value: "$assetGroupName  |  $itemTypeDesc", top: 8.0),
        text(value: "Quantity : $partCount", color: colorTheme4),
      ]),
      children: [
        SizedBox(height: 12),
        Align(
          alignment: Alignment.centerLeft,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 22.0),
            child: Text("Threshold Set: $partThreshold"),
          ),
        ),
        Align(
          alignment: Alignment.centerLeft,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 22.0),
            child: Text(partRemark),
          ),
        ),
        TextButton(
            onPressed: () {
              Navigator.pushNamed(context, routeDetails, arguments: partId);
            },
            child: Text("Open Details")),
      ],
    );
  }

  Widget text({required String value, double top = 3.0, Color color = Colors.black}) {
    return Padding(
      padding: EdgeInsets.only(top: top),
      child: Text(
        value,
        style: TextStyle(color: color ?? colorTheme3),
      ),
    );
  }
}

class Controller {
  final BehaviorSubject<List<ComplaintDStore>> _stores =
      BehaviorSubject.seeded([]);
  final BehaviorSubject<List<Map<String, String>>> _materials =
      BehaviorSubject.seeded([]);
  final BehaviorSubject<ComplaintDStore> _store = BehaviorSubject();

  Controller(BuildContext context) {
    getStore(context);
    _store.listen((event) {
      if (event.itemId != null) {
        getMaterails(context, event.itemId!);
      }
    });
  }

  void dispose() {
    _stores.close();
    _materials.close();
  }

  set store(ComplaintDStore value) => _store.sink.add(value);
  set stores(List<ComplaintDStore> values) => _stores.sink.add(values);
  set materials(List<Map<String, String>> values) => _materials.sink.add(values);
  get stores$ => _stores.stream;
  get materials$ => _materials.stream;
  get store$ => _store.stream;

  Future<void> getStore(BuildContext context) async {
    final Provider _provider =
        Provider(fetchURL: "/store/purchase_option_store");
    _provider.context = context;

    final result = await _provider.getJson(url: "/store/purchase_option_store");
    final values = deserializeListOf<ComplaintDStore>(result).toList();

    stores = values;
    store = values.first;
  }

  void getMaterails(BuildContext context, String id) async {
    final Provider _provider =
        Provider(fetchURL: "/part/list_mobile_threshold/", taskID: id);
    _provider.context = context;

    final result = await _provider.getJson(url: "/part/list_mobile_threshold/") as List<dynamic>;
    final List<Map<String, String>> values = result
        .map((value) => Map<String, String>.from(value))
        .toList();
    materials = values;
  }
}
