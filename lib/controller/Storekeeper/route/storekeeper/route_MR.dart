// lib/controller/Storekeeper/route/storekeeper/route_MR.dart

import 'package:flutter/material.dart';
import 'package:gfm_gems/controller/Storekeeper/utils/bloc/bloc_task.dart';
import 'package:gfm_gems/controller/Storekeeper/utils/constant.dart';
import 'package:gfm_gems/controller/Storekeeper/utils/widget/dialog.dart';
import 'package:gfm_gems/model/complaint.dart';
import 'package:gfm_gems/model/material.dart' as item;
import 'package:toast/toast.dart';
import '../../../../main.dart';

class MaterialRequest extends StatefulWidget {
  final RequestTask value;
  final bool isApproval;
  final bool isCheckout;

  const MaterialRequest({
    required this.value,
    this.isApproval = false,
    this.isCheckout = false,
    Key? key,
  }) : super(key: key);

  @override
  _MaterialRequestState createState() => _MaterialRequestState(value);
}

class _MaterialRequestState extends State<MaterialRequest> {
  final MaterialTask _bloc;
  bool _loading = false;

  _MaterialRequestState(RequestTask value)
      : _bloc = MaterialTask(value.woTaskRequestId ?? '');

  @override
  void initState() {
    super.initState();
    // listen to loadingState$ and update page‐level spinner
    _bloc.loadingState$.listen((isLoading) {
      if (mounted) setState(() => _loading = isLoading);
    });
    // show any errors as toasts
    _bloc.err$.listen((err) {
      Toast.show(err, duration: 4, gravity: Toast.bottom);
    });
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
        title: const Text("Material Requisition Form"),
        backgroundColor: Colors.white,
        centerTitle: true,
      ),

      // Stack lets us overlay a spinner on top of the normal UI
      body: Stack(
        children: [
          // your existing scrollable content
          RefreshIndicator(
            onRefresh: _bloc.refresh,
            child: SingleChildScrollView(
              physics: const AlwaysScrollableScrollPhysics(),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  _Info(_bloc.detail$),
                  const Divider(color: Colors.black38),
                  const _Title(),
                  _ListView(_bloc.materials$, widget.isApproval),
                ],
              ),
            ),
          ),

          // full‐screen loading overlay
          if (_loading)
            Container(
              color: Colors.black.withOpacity(0.5),
              child: const Center(
                child: CircularProgressIndicator(),
              ),
            ),
        ],
      ),

      floatingActionButton: widget.isCheckout
          ? null
          : StreamBuilder<RequestTask>(
              stream: _bloc.detail$.cast<RequestTask>(),
              builder: (context, snapshot) {
                final statusId = snapshot.data?.statusId ?? "-1";

                // hide buttons if not in 33 and this is an approval screen
                if (widget.isApproval && statusId != "33") {
                  return Container();
                }

                return Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    if (statusId == "33")
                      _BuildRejectButton(
                        (value) => _bloc
                            .reject(value)
                            .then((_) => Navigator.pop(context))
                            .catchError((e) => print(e)),
                        (e) => Toast.show(e),
                      ),
                    if (statusId == "33") const SizedBox(width: 12),
                    _FloatingButton(
                      _bloc.titleButton(statusId),
                      () => _bloc
                          .onclick(widget.isApproval)
                          .then((_) => Navigator.pop(context))
                          .catchError((e) => print(e)),
                      color: _bloc.colorButton(statusId),
                    ),
                  ],
                );
              },
            ),
    );
  }
}

/// Displays the top table of MR metadata
class _Info extends StatelessWidget {
  final Stream<RequestTask> _stream;

  const _Info(this._stream, {Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
      child: StreamBuilder<RequestTask>(
        stream: _stream,
        builder: (context, snapshot) {
          final data = snapshot.data;
          return Table(
            columnWidths: const {0: FractionColumnWidth(0.30)},
            children: <TableRow>[
              row("MR No : ", data?.woTaskRequestNo ?? ""),
              row("Request Date : ", data?.requestTime ?? ""),
              row("Request By : ", data?.requestBy ?? ""),
              row("WO No : ", data?.woTaskNo ?? ""),
              row("Priority : ", data?.woSeverityDesc ?? ""),
              row("Location : ", data?.siteName ?? ""),
              if ((data?.collectTime ?? "").isNotEmpty)
                row("Checkout Date : ", data?.collectTime ?? ""),
            ],
          );
        },
      ),
    );
  }

  TableRow row(String title, String value) {
    return TableRow(children: [
      TableCell(
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 8.0),
          child:
              Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
        ),
      ),
      TableCell(
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 8.0),
          child: Text(value),
        ),
      ),
    ]);
  }
}

/// Section header
class _Title extends StatelessWidget {
  const _Title({Key? key}) : super(key: key);
  @override
  Widget build(BuildContext context) => const ListTile(
        title: Text("Material", style: TextStyle(fontWeight: FontWeight.bold)),
      );
}

/// Floating action button for approve/checkout
class _FloatingButton extends StatelessWidget {
  final String status;
  final VoidCallback onTap;
  final Color color;

  const _FloatingButton(this.status, this.onTap,
      {Key? key, required this.color})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return FloatingActionButton.extended(
      label: Text(status,
          style: TextStyle(
              color: color == colorNull ? Colors.black : Colors.white)),
      backgroundColor: color,
      onPressed: onTap,
    );
  }
}

/// List of requested materials
class _ListView extends StatelessWidget {
  final Stream<List<item.Material>> _stream;
  final bool isApproval;

  const _ListView(this._stream, this.isApproval, {Key? key})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<List<item.Material>>(
      stream: _stream,
      builder: (context, snapshot) {
        if (!snapshot.hasData) return Container();
        final data = snapshot.data!;
        return ListView(
          padding: const EdgeInsets.only(bottom: 60),
          physics: const NeverScrollableScrollPhysics(),
          shrinkWrap: true,
          children: List.generate(
            data.length,
            (i) => _Material(i + 1, data[i], isApproval),
          ),
        );
      },
    );
  }
}

/// Single material tile
class _Material extends StatelessWidget {
  final int index;
  final item.Material _material;
  final bool isApproval;
  final bool isUnavailable;

  _Material(this.index, this._material, this.isApproval)
      : isUnavailable = _material.statusStorekeeper == "Not Enough";

  @override
  Widget build(BuildContext context) {
    return ExpansionTile(
      title: Text(
        "$index. Material ${_material.itemDescription}",
        overflow: TextOverflow.ellipsis,
      ),
      subtitle: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text("${_material.assetGroupName} | ${_material.itemTypeDesc}"),
          Text(
            "Quantity Request: ${_material.woTaskPartsQuantity}",
            style: TextStyle(color: isUnavailable ? colorTheme4 : null),
          ),
        ],
      ),
      children: [
        if (isApproval)
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 16),
            child: Text(_material.woTaskPartsRemark ?? ''),
          ),
        if (!isApproval) ...[
          Padding(
            padding: const EdgeInsets.only(left: 12, top: 6),
            child: Text("- Threshold: ${_material.partThreshold ?? "N/A"}"),
          ),
          Padding(
            padding: const EdgeInsets.only(left: 12, top: 6, bottom: 12),
            child: Text("- Stock Available: ${_material.partAvailable ?? "N/A"}"),
          ),
        ],
      ],
    );
  }
}

/// Reject button in approval mode
class _BuildRejectButton extends StatelessWidget {
  final Future<void> Function(String) reject;
  final Function(String) alert;

  const _BuildRejectButton(this.reject, this.alert, {Key? key})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return FloatingActionButton.extended(
      heroTag: "reject_button",
      label: const Text("Reject"),
      backgroundColor: Colors.red,
      onPressed: () => showDialog(
        context: navigatorKey.currentContext!,
        builder: (_) => CustomDialog(
          rootPage: "/workorder",
          title: "Remark",
          description: "Remark",
          buttonText: "Okay",
          secondButton: false,
          cancel: true,
          image: Image.asset("assets/icon_trans.png", height: 40),
          okayTapped: () {
            Navigator.pop(context);
            Navigator.pop(context);
          },
          remarkTapped: (text) {
            Navigator.pop(context);
            reject(text).then((_) => alert("Success")).catchError(alert);
          },
        ),
      ),
    );
  }
}
