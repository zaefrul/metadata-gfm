import 'package:flutter/material.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:gfm_gems/controller/Storekeeper/utils/constant.dart';
import 'package:gfm_gems/model/complaint.dart';
import 'package:gfm_gems/utils/network.dart';
import 'package:rxdart/rxdart.dart';
import 'package:toast/toast.dart';
import 'complaintAdd.dart';

class ComplaintSectionDMaterial extends StatefulWidget {
  final String id;
  final bool enableSubmit;
  final bool enableReset;
  final bool viewer;
  final String comment;

  const ComplaintSectionDMaterial(
    this.id, {
    Key? key,
    this.enableSubmit = false,
    this.viewer = false,
    this.enableReset = false,
    this.comment = "",
  }) : super(key: key);

  @override
  _ComplaintSectionDMaterialState createState() =>
      _ComplaintSectionDMaterialState(id);
}

class _ComplaintSectionDMaterialState extends State<ComplaintSectionDMaterial> {
  final Controller _controller;

  _ComplaintSectionDMaterialState(String id)
      : _controller = Controller(id);

  @override
  Widget build(BuildContext context) {
    ToastContext().init(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text("E. Spare Parts/ Material User"),
        centerTitle: true,
        backgroundColor: Colors.white,
        actions: [
          if (widget.enableReset)
            TextButton(
              onPressed: () {
                _controller.reset().then((_) {
                  Navigator.pop(context);
                }).catchError((e) => print(e));
              },
              child: const Text("Re-Apply"),
            )
        ],
      ),
      body: Container(
        padding: const EdgeInsets.only(top: 16.0),
        child: StreamBuilder<List<ComplaintD>>(
          stream: _controller.items$,
          builder: (context, snapshot) {
            return RefreshIndicator(
              onRefresh: () => _controller.refresh(),
              child: ListView(
                children: [
                  if (widget.comment.isNotEmpty)
                    Padding(
                      padding: const EdgeInsets.all(12),
                      child: Text(widget.comment),
                    ),
                  ListView.separated(
                    primary: true,
                    shrinkWrap: true,
                    itemBuilder: (_, index) {
                      return Tile(snapshot.data![index], _controller,
                          widget.enableSubmit);
                    },
                    separatorBuilder: (_, __) => const Divider(),
                    itemCount: snapshot.data == null ? 0 : snapshot.data!.length,
                  ),
                ],
              ),
            );
          },
        ),
      ),
      floatingActionButton: !widget.viewer && widget.enableSubmit
          ? Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                _addButton,
                const SizedBox(width: 12),
                _submitButton,
              ],
            )
          : null,
    );
  }

  Widget get _addButton => FloatingActionButton(
        backgroundColor: colorTheme2,
        child: const Icon(Icons.add),
        onPressed: () => _controller.add(context, widget.id),
      );

  Widget get _submitButton => FloatingActionButton.extended(
        heroTag: "submit",
        backgroundColor: colorTheme2,
        label: const Text("Submit"),
        onPressed: () => _controller.submit(context),
      );
}

class Tile extends StatelessWidget {
  final ComplaintD item;
  final Controller controller;
  final bool enableEdit;

  const Tile(this.item, this.controller, this.enableEdit, {Key? key})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Slidable(
      // Uncomment and adjust the following properties if needed:
      // actionPane: SlidableDrawerActionPane(),
      // actionExtentRatio: 0.25,
      child: ListTile(
        title: Text(
          item.itemDescription ?? 'No description available',
          overflow: TextOverflow.ellipsis,
          maxLines: 1,
        ),
        subtitle: Padding(
          padding: const EdgeInsets.symmetric(vertical: 8.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text("Quantity : " + (item.woTaskPartsQuantity ?? "N/A")),
              Text("Group : " + (item.assetGroupName ?? "N/A")),
              Text(
                "Type : " + (item.itemTypeDesc ?? "N/A"),
                overflow: TextOverflow.ellipsis,
                maxLines: 1,
              ),
            ],
          ),
        ),
        trailing: Container(
          padding: const EdgeInsets.all(8),
          child: Text(item.statusDesc ?? 'N/A'),
        ),
        onTap: enableEdit
            ? () => Navigator.pushNamed(
                  context,
                  routeMaterial,
                  arguments: item.woTaskPartsId,
                ).whenComplete(() => controller.refresh())
            : null,
      ),
      // Optionally uncomment actions or secondaryActions below:
      // actions: [
      //   IconSlideAction(
      //     caption: 'Delete',
      //     color: Colors.red,
      //     icon: Icons.delete,
      //     onTap: () => controller.delete(item.woTaskPartsId),
      //   )
      // ],
      // secondaryActions: [
      //   IconSlideAction(
      //     caption: 'Delete',
      //     color: Colors.red,
      //     icon: Icons.delete,
      //     onTap: () => controller.delete(item.woTaskPartsId),
      //   )
      // ],
    );
  }
}

class Controller {
  final String id;
  final Request _request;

  Controller(this.id) : _request = Request(id) {
    refresh();
  }

  // Variables
  final BehaviorSubject<List<ComplaintD>> _items =
      BehaviorSubject<List<ComplaintD>>.seeded([]);

  // STREAM
  Stream<List<ComplaintD>> get items$ => _items.stream;

  // SINK
  set items(List<ComplaintD> values) => _items.sink.add(values);

  // DISPOSE
  void dispose() {
    _items.close();
  }

  // METHOD

  void add(BuildContext context, String id) => Navigator.of(context)
      .push(MaterialPageRoute(builder: (_) => ComplaintAdd(id)))
      .whenComplete(() => refresh());

  void delete(String itemId) =>
      _request.delete(itemId).whenComplete(() => refresh());

  Future<void> refresh() => _request.response.then((value) {
        items = value;
      });

  Future<void> reset() =>
      _request.reset().whenComplete(() => refresh());

  void submit(BuildContext context) => _request
          .submit()
          .then((value) => Toast.show("Your Request has submitted"))
          .then((value) {
        Navigator.pop(context);
        Navigator.pop(context);
      }).catchError((onError) => Toast.show(onError.toString()));
}

class Request {
  final Provider _providerGET;
  final Provider _providerSUBMIT;
  final Provider _providerDELETE;
  final Provider _providerRESET;
  final String _id;

  Request(String id)
      : _providerGET = Provider(
            taskID: id,
            fetchURL: "/wo_parts/wo_parts_mobile_list/"),
        _providerDELETE = Provider(fetchURL: "/wo_parts/" + id),
        _providerSUBMIT = Provider(fetchURL: "/wo_request/" + id),
        _providerRESET = Provider(fetchURL: "/wo_request/reset/" + id),
        _id = id;

  Future<List<ComplaintD>> get response => _providerGET
      .fetchComplaint()
      .then((value) => value.map((e) => e as ComplaintD).toList());

  Future delete(String id) =>
      _providerDELETE.delete(url: "/wo_parts/" + id);

  Future submit() => _providerSUBMIT.post(url: "/wo_request/" + _id);

  Future reset() => _providerRESET.post(url: "/wo_request/reset/" + _id);
}
