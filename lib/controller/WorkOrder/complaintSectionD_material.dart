import 'package:flutter/material.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:gfm_gems/controller/Storekeeper/utils/constant.dart';
import 'package:gfm_gems/model/complaint.dart';
import 'package:gfm_gems/utils/network.dart';
import 'package:rxdart/rxdart.dart';
import 'package:toast/toast.dart';
import 'package:gfm_gems/utils/reference.dart'; // Assuming this contains AppColors
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
      backgroundColor: AppColors.gray100,
      appBar: AppBar(
        title: Text(
          "Spare Parts / Material User",
          style: TextStyle(
            color: AppColors.textPrimary,
            fontWeight: FontWeight.w600,
          ),
        ),
        centerTitle: true,
        backgroundColor: AppColors.bgAppBar,
        elevation: 0,
        iconTheme: IconThemeData(color: AppColors.primary),
        actions: [
          if (widget.enableReset)
            TextButton(
              onPressed: () {
                _controller.reset().then((_) {
                  Navigator.pop(context);
                }).catchError((e) => print(e));
              },
              child: Text(
                "Re-Apply",
                style: TextStyle(color: AppColors.primary),
              ),
            )
        ],
      ),
      body: Container(
        padding: const EdgeInsets.only(top: 16.0),
        child: StreamBuilder<List<ComplaintD>>(
          stream: _controller.items$,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return Center(child: CircularProgressIndicator());
            }

            if (snapshot.hasError) {
              return Center(child: Text("Error loading data"));
            }

            final items = snapshot.data ?? [];

            if (items.isEmpty) {
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.inventory_2_outlined, size: 48, color: AppColors.gray400),
                    SizedBox(height: 16),
                    Text(
                      "No spare parts added yet",
                      style: TextStyle(
                        color: AppColors.textSecondary,
                        fontSize: 16,
                      ),
                    ),
                    SizedBox(height: 8),
                    Text(
                      "Tap the + button to add items",
                      style: TextStyle(
                        color: AppColors.textHint,
                        fontSize: 14,
                      ),
                    ),
                  ],
                ),
              );
            }

            return RefreshIndicator(
              onRefresh: () => _controller.refresh(),
              child: ListView(
                children: [
                  if (widget.comment.isNotEmpty)
                    Card(
                      margin: EdgeInsets.all(12),
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                        side: BorderSide(
                          color: AppColors.gray200,
                          width: 1,
                        ),
                      ),
                      child: Padding(
                        padding: EdgeInsets.all(16),
                        child: Text(
                          widget.comment,
                          style: TextStyle(color: AppColors.textSecondary),
                        ),
                      ),
                    ),
                  ListView.builder(
                    primary: false,
                    shrinkWrap: true,
                    itemCount: items.length,
                    itemBuilder: (_, index) => Padding(
                      padding: EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                      child: MaterialItemCard(
                        item: items[index],
                        controller: _controller,
                        enableEdit: widget.enableSubmit,
                      ),
                    ),  
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
                FloatingActionButton(
                  heroTag: "add",
                  backgroundColor: AppColors.primary,
                  child: Icon(Icons.add, color: AppColors.onPrimary),
                  onPressed: () => _controller.add(context, widget.id),
                ),
                SizedBox(width: 12),
                FloatingActionButton.extended(
                  heroTag: "submit",
                  backgroundColor: AppColors.primary,
                  icon: Icon(Icons.send, color: AppColors.onPrimary),
                  label: Text(
                    "Submit",
                    style: TextStyle(color: AppColors.onPrimary),
                  ),
                  onPressed: () => _controller.submit(context),
                ),
              ],
            )
          : null,
    );
  }
}

class MaterialItemCard extends StatelessWidget {
  final ComplaintD item;
  final Controller controller;
  final bool enableEdit;

  const MaterialItemCard({
    Key? key,
    required this.item,
    required this.controller,
    required this.enableEdit,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 1,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Slidable(
        endActionPane: ActionPane(
          motion: ScrollMotion(),
          children: [
            SlidableAction(
              onPressed: (_) => controller.delete(item.woTaskPartsId!),
              backgroundColor: AppColors.danger,
              foregroundColor: AppColors.onDanger,
              icon: Icons.delete,
              label: 'Delete',
              borderRadius: BorderRadius.only(
                topRight: Radius.circular(12),
                bottomRight: Radius.circular(12),
              ),
            ),
          ],
        ),
        child: InkWell(
          borderRadius: BorderRadius.circular(12),
          onTap: enableEdit
              ? () => Navigator.pushNamed(
                    context,
                    routeMaterial,
                    arguments: item.woTaskPartsId,
                  ).whenComplete(() => controller.refresh())
              : null,
          child: Padding(
            padding: EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        item.itemDescription ?? 'No description available',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w500,
                          color: AppColors.textPrimary,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    Container(
                      padding: EdgeInsets.symmetric(
                          horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: _getStatusColor(item.statusDesc),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        item.statusDesc ?? 'N/A',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 12,
                        ),
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 12),
                _buildDetailRow(
                  Icons.scale,
                  "Quantity: ${item.woTaskPartsQuantity ?? "N/A"}",
                ),
                _buildDetailRow(
                  Icons.category,
                  "Group: ${item.assetGroupName ?? "N/A"}",
                ),
                _buildDetailRow(
                  Icons.type_specimen,
                  "Type: ${item.itemTypeDesc ?? "N/A"}",
                  maxLines: 2, // Specific override for type
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildDetailRow(IconData icon, String text, {int? maxLines}) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 16, color: AppColors.textSecondary),
          SizedBox(width: 8),
          Expanded(
            child: Text(
              text,
              style: TextStyle(
                color: AppColors.textSecondary,
                fontSize: 14,
              ),
              maxLines: maxLines ?? 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }

  Color _getStatusColor(String? status) {
    debugPrint('Status: $status');
    switch (status?.toLowerCase()) {
      case 'approved':
        return AppColors.success;
      case 'pending':
        return AppColors.warning;
      case 'rejected':
        return AppColors.danger;
      case 'request approval':
        return AppColors.primary;
      default:
        return AppColors.secondary;
    }
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
