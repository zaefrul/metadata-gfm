import 'package:flutter/material.dart';
import 'package:gfm_gems/controller/Storekeeper/utils/bloc/bloc_task.dart';
import 'package:gfm_gems/controller/Storekeeper/utils/constant.dart';
import 'package:gfm_gems/controller/Storekeeper/utils/widget/dialog.dart';
import 'package:gfm_gems/model/complaint.dart';
import 'package:gfm_gems/model/material.dart' as item;
import 'package:toast/toast.dart';

class MaterialRequest extends StatefulWidget {
  final RequestTask value;
  final isApproval;
  final isCheckout;

  MaterialRequest(
      {@required this.value, this.isApproval = false, this.isCheckout = false});

  @override
  _MaterialRequestState createState() => _MaterialRequestState(value);
}

class _MaterialRequestState extends State<MaterialRequest> {
  final MaterialTask _bloc;

  _MaterialRequestState(RequestTask value)
      : this._bloc = MaterialTask(value.woTaskRequestId);

  @override
  void didChangeDependencies() {
    _bloc.loadingState$.listen((event) {
      if (event ?? false)
        showDialog(
          context: context,
          builder: (_) => Center(child: CircularProgressIndicator()),
        );
      else if (event == false) Navigator.pop(context);
    });
    _bloc.err$.listen((event) => Toast.show(event, duration: 4));
    super.didChangeDependencies();
  }

  @override
  void dispose() {
    _bloc.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    ToastContext().init(context);
    return Scaffold(
      appBar: AppBar(
        title: new Text("Material Requisition Form"),
        backgroundColor: Colors.white,
        centerTitle: true,
      ),
      body: RefreshIndicator(
        onRefresh: _bloc.refresh,
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              _Info(_bloc.detail$),
              Divider(color: Colors.black38),
              _Title(),
              _ListView(_bloc.materials$, widget.isApproval),
            ],
          ),
        ),
      ),
      floatingActionButton: widget.isCheckout
          ? null
          : StreamBuilder<RequestTask>(
              stream: _bloc.detail$,
              builder: (context, snapshot) {
                if (snapshot.data != null) if (snapshot.data.statusId !=
                    "33") if (widget.isApproval) return Container();
                return Row(mainAxisAlignment: MainAxisAlignment.end, children: [
                  if ((snapshot.data?.statusId ?? "-1") == "33")
                    _BuildRejectButton(
                      (value) => _bloc
                          .reject(value)
                          .then((value) => Navigator.pop(context))
                          .catchError((e) => print(e)),
                      (e) => Toast.show(e),
                    ),
                  if ((snapshot.data?.statusId ?? "-1") == "33")
                    SizedBox(width: 12),
                  _FloatingButton(
                    _bloc.titleButton(snapshot.data?.statusId ?? "-1"),
                    () => _bloc
                        .onclick(widget.isApproval)
                        .then((value) => Navigator.pop(context))
                        .catchError((e) => print(e)),
                    color: _bloc.colorButton(snapshot.data?.statusId ?? "-1"),
                  ),
                ]);
              }),
    );
  }
}

class _Info extends StatelessWidget {
  // final bool isCheckout;
  final Stream<RequestTask> _stream;

  _Info(this._stream);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
      child: StreamBuilder<RequestTask>(
          stream: _stream,
          builder: (context, snapshot) {
            final data = snapshot.data;

            return Table(
              columnWidths: {
                0: FractionColumnWidth(.30),
              },
              children: <TableRow>[
                row("MR No : ", data?.woTaskRequestNo ?? ""),
                row("Request Date : ", data?.requestTime ?? ""),
                row("Request By : ", data?.requestBy ?? ""),
                // row("Approved By : ", "Khairul Syafiq"),
                row("WO No : ", data?.woTaskNo ?? ""),
                row("Priority : ", data?.woSeverityDesc ?? ""),
                row("Location : ", data?.siteName ?? ""),
                // if (isCheckout) row("Checkout By : ", "Muhammad Zaid"),
                if (data?.collectTime != "")
                  row("Checkout Date : ", data?.collectTime ?? ""),
              ],
            );
          }),
    );
  }

  TableRow row(String title, String value) {
    return TableRow(children: [
      TableCell(
          child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 8.0),
        child: Text(
          title,
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
      )),
      TableCell(
          child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 8.0),
        child: Text(value),
      )),
    ]);
  }
}

class _Title extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return ListTile(
      // onTap: () => onPressed(context),
      title: Text(
        "Material",
        style: TextStyle(fontWeight: FontWeight.bold),
      ),
      // trailing: Icon(Icons.add, color: Colors.grey),
    );
  }

  // void onPressed(BuildContext context) =>
  //     Navigator.pushNamed(context, routeTechnicianDetail).then(
  //       (value) => value != null ? bloc.setSink(value) : null,
  //     );
}

class _FloatingButton extends StatelessWidget {
  final String status;
  final Color color;
  final Function onTap;

  _FloatingButton(this.status, this.onTap, {this.color});

  @override
  Widget build(BuildContext context) {
    return FloatingActionButton.extended(
        label: Text(
          status,
          style: TextStyle(
            color: color == colorNull ? Colors.black : Colors.white,
          ),
        ),
        backgroundColor: color ?? colorTheme1,
        onPressed: onTap);
  }
}

class _ListView extends StatelessWidget {
  final Stream<List<item.Material>> _stream;
  final bool isApproval;

  const _ListView(this._stream, this.isApproval, {Key key}) : super(key: key);
  @override
  Widget build(BuildContext context) {
    return StreamBuilder<List<item.Material>>(
        stream: _stream,
        builder: (context, snapshot) {
          if (snapshot.data == null) return Container();
          final data = snapshot.data;

          return ListView(
            padding: EdgeInsets.only(bottom: 60),
            physics: NeverScrollableScrollPhysics(),
            shrinkWrap: true,
            scrollDirection: Axis.vertical,
            children: List.generate(
              data.length,
              (index) => _Material(index + 1, data[index], isApproval),
            ),
          );
        });
  }
}

class _Material extends StatelessWidget {
  final bool isApproval;
  final bool isUnavailable;
  final item.Material _material;

  final int index;

  _Material(this.index, item.Material material, this.isApproval)
      : this.isUnavailable = material.statusStorekeeper == "Not Enough",
        this._material = material;

  @override
  Widget build(BuildContext context) {
    return ExpansionTile(
      title: Padding(
        padding: const EdgeInsets.symmetric(vertical: 8.0),
        child: Text(
          index.toString() + '.  Material ${_material.itemDescription}',
          overflow: TextOverflow.ellipsis,
        ),
      ),
      subtitle: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        text(
            value: "${_material.assetGroupName} |  ${_material.itemTypeDesc}",
            top: 8.0),
        text(
            value: "Quantity Request : ${_material.woTaskPartsQuantity}",
            color: isUnavailable ? colorTheme4 : null),
      ]),
      children: [
        if (isApproval == true)
          Align(
            alignment: Alignment.centerLeft,
            child: Padding(
              padding:
                  const EdgeInsets.symmetric(horizontal: 22.0, vertical: 16),
              child: Text(_material.woTaskPartsRemark),
            ),
          ),
        if (isApproval == false)
          Align(
            alignment: Alignment.centerLeft,
            child: Padding(
              padding: const EdgeInsets.only(left: 12.0, top: 6),
              child: Text("- Threshold: " + _material.partThreshold),
            ),
          ),
        if (isApproval == false)
          Align(
            alignment: Alignment.centerLeft,
            child: Padding(
              padding: const EdgeInsets.only(left: 12.0, top: 6, bottom: 12),
              child: Text("- Stock Available: " + _material.partAvailable),
            ),
          ),
        // if (isApproval == false)
        //   TextButton(
        //       onPressed: () {
        //         Toast.show("Item added to Request");
        //       },
        //       child: Text("Add To Request")),
      ],
    );
  }

  Widget text({@required String value, double top = 3.0, Color color}) {
    return Padding(
      padding: EdgeInsets.only(top: top),
      child: Text(
        value,
        style: TextStyle(color: color == null ? colorTheme3 : color),
      ),
    );
  }
}

class _BuildRejectButton extends StatelessWidget {
  final String label;
  final Function(String) alert;
  final Future<void> Function(String) reject;

  _BuildRejectButton(this.reject, this.alert) : this.label = "Reject";

  @override
  Widget build(BuildContext context) {
    return FloatingActionButton.extended(
        heroTag: "reject_button",
        label: new Text(label),
        backgroundColor: Colors.red,
        onPressed: () => showDialog(context: context, builder: _buildDialog));
  }

  Widget _buildDialog(BuildContext context) {
    return CustomDialog(
      rootPage: "/workorder",
      title: "Remark",
      description: "Remark",
      buttonText: "Okay",
      secondButton: false,
      cancel: true,
      okayTapped: () {
        Navigator.pop(context);
        Navigator.pop(context);
      },
      image: Image.asset("assets/icon_trans.png", height: 40),
      remarkTapped: (text) {
        Navigator.pop(context);
        reject(text).then(alert).catchError(alert);
      },
    );
  }
}
