import 'package:flutter/material.dart';
import 'package:GEMS/controller/Storekeeper/utils/constant.dart';
import 'package:GEMS/utils/network.dart';
import 'package:photo_view/photo_view.dart';
import 'package:toast/toast.dart';
import '../../../../main.dart';

class CheckinDetails extends StatelessWidget {
  final String id;

  const CheckinDetails({required Key key, required this.id}) : super(key: key);
  @override
  Widget build(BuildContext context) {
    final Provider provider =
        Provider(fetchURL: "/do/check_in_mobile_details/", taskID: id);
    provider.context = context;

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        title: Text("Check In Information"),
        centerTitle: true,
      ),
      body: FutureBuilder<dynamic>(
          future: provider.getJson(url: "/do/check_in_mobile_details/"),
          builder: (context, snapshot) {
            if (snapshot.data == null) {
              return Center(child: CircularProgressIndicator());
            }

            final data = snapshot.data;

            return ListView(
              children: [
                _Info(data),
                Divider(color: Colors.black38),
                Padding(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 16.0, vertical: 12),
                  child: Row(
                    children: [
                      Text(
                        "List of DO attachments : ",
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                      Spacer(),
                      if (data["doUploads"].length == 0) Text("No Do Uploaded"),
                      if (data["doUploads"].length > 0)
                        Text("${data["doUploads"].length} File")
                      // IconButton(icon: Icon(Icons.add), onPressed: () {})
                    ],
                  ),
                ),
                AttachmentsDO(data["doUploads"]),
                Divider(color: Colors.black38),
                _ListView(data["doItems"]),
              ],
            );
          }),
    );
  }
}

class _Info extends StatelessWidget {
  final String doDate;
  final String doId;
  final String doNo;
  final String doTimestamp;
  final String supplierName;
  final String totalCost;
  final String userFirstName;

  _Info(Map data)
      : doDate = data["doDate"],
        doId = data["doId"],
        doNo = data["doNo"],
        doTimestamp = data["doTimestamp"],
        supplierName = data["supplierName"],
        totalCost = data["totalCost"],
        userFirstName = data["userFirstName"];

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
      child: Table(
        columnWidths: {
          0: FractionColumnWidth(.40),
        },
        children: <TableRow>[
          // row("PR No : ", "PR023212G"),
          row("Do No : ", doNo),
          row("Vendor Selection : ", supplierName),
          row("Request By : ", userFirstName),
          row("Date Time : ", doDate),
          row("Total Price (RM) : ", totalCost),
        ],
      ),
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

class _ListView extends StatelessWidget {
  final List items;

  const _ListView(this.items);

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: EdgeInsets.only(bottom: 20),
      physics: NeverScrollableScrollPhysics(),
      shrinkWrap: true,
      scrollDirection: Axis.vertical,
      children: List.generate(
        items.length,
        (index) => _Material(index + 1, items[index]),
      ),
    );
  }
}

class _Material extends StatelessWidget {
  final Map data;
  final int index;

  const _Material(this.index, this.data);

  @override
  Widget build(BuildContext context) {
    final String doItemCost = data["doItemCost"];
    final String doItemTotal = data["doItemTotal"];
    final String doItemTotalCost = data["doItemTotalCost"];
    final String doItemValidity = data["doItemValidity"];
    final String doItemWarranty = data["doItemWarranty"];
    final String doNo = data["doNo"];
    final String groupName = data["assetGroupName"];
    final String itemTypeDesc = data["itemTypeDesc"];
    final String itemDesc = data["itemDescription"];

    return ExpansionTile(
      title: Padding(
        padding: const EdgeInsets.symmetric(vertical: 8.0),
        child: Text(
          '$index.  $itemDesc',
          overflow: TextOverflow.fade,
        ),
      ),
      subtitle: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        text(value: "$groupName | $itemTypeDesc"),
        Row(
          children: [
            text(value: "RM $doItemCost"),
            SizedBox(width: 12),
            text(value: "Quantity : $doItemTotal"),
          ],
        ),
        text(value: "Total Cost : RM $doItemTotalCost"),
      ]),
      children: [
        SizedBox(height: 12),
        Align(
          alignment: Alignment.centerLeft,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 22.0, vertical: 8),
            child: Text('Validity : $doItemValidity'),
          ),
        ),
        Align(
          alignment: Alignment.centerLeft,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 22.0),
            child: Text('Warranty : $doItemWarranty'),
          ),
        ),
        SizedBox(height: 12)
        // if (newUpload)
        //   TextButton(
        //       onPressed: () => _showMyDialog(context),
        //       child: Text(
        //         "Report",
        //         style: TextStyle(color: colorTheme4),
        //       )),
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

  Future<void> _showMyDialog(BuildContext context) async {
    return showDialog<void>(
      context: navigatorKey.currentContext!,
      barrierDismissible: false, // user must tap button!
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Report Item'),
          content: TextField(
            decoration: InputDecoration(labelText: "Report : "),
          ),
          actions: <Widget>[
            TextButton(
              child: Text('Submit'),
              onPressed: () {
                Navigator.of(context).pop();
                Toast.show("Report Submitted");
              },
            ),
          ],
        );
      },
    );
  }
}

class AttachmentsDO extends StatelessWidget {
  final List items;
  const AttachmentsDO(this.items, {super.key});

  @override
  Widget build(BuildContext context) {
    ToastContext().init(context);
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0),
      child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: List.generate(
            items.length,
            (index) => TextButton(
              onPressed: () => Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (_) => ViewImage(
                    key: Key(items[index]["file"]),
                    url: items[index]["file"],
                  ),
                ),
              ),
              child: Text(
                "${index + 1}. ${items[index]["file"]}",
              ),
            ),
          )),
    );
  }
}

class ViewImage extends StatelessWidget {
  final String url;

  const ViewImage({required Key key, required this.url}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(child: PhotoView(imageProvider: NetworkImage(url)));
  }
}
