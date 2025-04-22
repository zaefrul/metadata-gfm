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

  _MaterialRequestState(RequestTask value)
      : _bloc = MaterialTask(value.woTaskRequestId ?? '');

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _bloc.loadingState$.listen((event) {
      if (event == true) {
        showDialog(
          context: navigatorKey.currentContext!,
          barrierDismissible: false,
          builder: (_) => const Center(child: CircularProgressIndicator()),
        );
      } else if (event == false) {
        Navigator.pop(context);
      }
    });
    _bloc.err$.listen((event) => Toast.show(event, duration: 4));
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
      body: RefreshIndicator(
        onRefresh: _bloc.refresh,
        child: SingleChildScrollView(
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
      floatingActionButton: widget.isCheckout
          ? null
          : StreamBuilder<RequestTask>(
              stream: _bloc.detail$.cast<RequestTask>(),
              builder: (context, snapshot) {
                // If statusId is not "33" and this is an approval case, hide buttons.
                if (snapshot.hasData &&
                    snapshot.data!.statusId != "33" &&
                    widget.isApproval) {
                  return Container();
                }
                return Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    if ((snapshot.data?.statusId ?? "-1") == "33")
                      _BuildRejectButton(
                        (value) => _bloc
                            .reject(value)
                            .then((_) => Navigator.pop(context))
                            .catchError((e) => print(e)),
                        (e) => Toast.show(e),
                      ),
                    if ((snapshot.data?.statusId ?? "-1") == "33")
                      const SizedBox(width: 12),
                    _FloatingButton(
                      _bloc.titleButton(snapshot.data?.statusId ?? "-1"),
                      () => _bloc.onclick(widget.isApproval)
                        .then((_) => Navigator.pop(context))
                        .catchError((e) => print(e)),
                      color: _bloc.colorButton(snapshot.data?.statusId ?? "-1"),
                    ),
                  ],
                );
              },
            ),
    );
  }
}

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
    return TableRow(
      children: [
        TableCell(
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 8.0),
            child: Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
          ),
        ),
        TableCell(
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 8.0),
            child: Text(value),
          ),
        ),
      ],
    );
  }
}

class _Title extends StatelessWidget {
  const _Title({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return const ListTile(
      title: Text(
        "Material",
        style: TextStyle(fontWeight: FontWeight.bold),
      ),
    );
  }
}

class _FloatingButton extends StatelessWidget {
  final String status;
  final Color color;
  final VoidCallback onTap;  // Changed type to VoidCallback

  const _FloatingButton(
    this.status,
    this.onTap, {
    Key? key,
    required this.color, // Marked as required so it must be provided
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return FloatingActionButton.extended(
      label: Text(
        status,
        style: TextStyle(
          color: color == colorNull ? Colors.black : Colors.white,
        ),
      ),
      backgroundColor: color,
      onPressed: onTap,
    );
  }
}

class _ListView extends StatelessWidget {
  final Stream<List<item.Material>> _stream;
  final bool isApproval;

  const _ListView(this._stream, this.isApproval, {Key? key}) : super(key: key);

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
          scrollDirection: Axis.vertical,
          children: List.generate(data.length, (index) => _Material(index + 1, data[index], isApproval)),
        );
      },
    );
  }
}

class _Material extends StatelessWidget {
  final bool isApproval;
  final bool isUnavailable;
  final item.Material _material;
  final int index;

  _Material(this.index, item.Material material, this.isApproval)
      : isUnavailable = material.statusStorekeeper == "Not Enough",
        _material = material;

  @override
  Widget build(BuildContext context) {
    return ExpansionTile(
      title: Padding(
        padding: const EdgeInsets.symmetric(vertical: 8.0),
        child: Text(
          "$index.  Material ${_material.itemDescription}",
          overflow: TextOverflow.ellipsis,
        ),
      ),
      subtitle: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          text(value: "${_material.assetGroupName} |  ${_material.itemTypeDesc}", top: 8.0),
          text(
            value: "Quantity Request : ${_material.woTaskPartsQuantity}",
            color: isUnavailable ? colorTheme4 : null,
          ),
        ],
      ),
      children: [
        if (isApproval)
          Align(
            alignment: Alignment.centerLeft,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 22.0, vertical: 16),
              child: Text(_material.woTaskPartsRemark ?? ''),
            ),
          ),
        if (!isApproval)
          Align(
            alignment: Alignment.centerLeft,
            child: Padding(
              padding: const EdgeInsets.only(left: 12.0, top: 6),
              child: Text("- Threshold: " + (_material.partThreshold ?? "N/A")),
            ),
          ),
        if (!isApproval)
          Align(
            alignment: Alignment.centerLeft,
            child: Padding(
              padding: const EdgeInsets.only(left: 12.0, top: 6, bottom: 12),
              child: Text("- Stock Available: " + (_material.partAvailable ?? "N/A")),
            ),
          ),
      ],
    );
  }

  Widget text({required String value, double top = 3.0, Color? color}) {
    return Padding(
      padding: EdgeInsets.only(top: top),
      child: Text(
        value,
        style: TextStyle(color: color ?? colorTheme3),
      ),
    );
  }
}

class _BuildRejectButton extends StatelessWidget {
  final String label;
  final Future<void> Function(String) reject;
  final Function(String) alert;

  const _BuildRejectButton(this.reject, this.alert, {Key? key})
      : label = "Reject",
        super(key: key);

  @override
  Widget build(BuildContext context) {
    return FloatingActionButton.extended(
      heroTag: "reject_button",
      label: Text(label),
      backgroundColor: Colors.red,
      onPressed: () => showDialog(context: navigatorKey.currentContext!, builder: _buildDialog),
    );
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
        reject(text).then((_) => alert("Success")).catchError(alert);
      },
    );
  }
}
