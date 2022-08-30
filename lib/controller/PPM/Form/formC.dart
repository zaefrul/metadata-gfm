import 'package:flutter/material.dart';
import 'package:gfm_gems/model/form.dart';
import 'package:gfm_gems/model/responseValue.dart';
import 'package:gfm_gems/utils/network.dart';
import 'package:gfm_gems/utils/reference.dart';
import 'package:gfm_gems/view/dialog.dart';
import 'package:gfm_gems/view/field.dart';
import 'package:toast/toast.dart';

class FormC extends StatefulWidget {
  final String id;
  final bool verified;
  final Function refreshStatus;
  final bool disable;

  FormC(this.id, this.verified, this.refreshStatus, this.disable);

  @override
  _FormCState createState() => _FormCState();
}

class _FormCState extends State<FormC> {
  Provider provider;
  bool loading = false;
  String dropdownValue;
  List<UploadItem> items = List<UploadItem>();

  String assetNo;
  String model;
  String capacity;
  String pmStart;
  String pmEnd;

  @override
  void initState() {
    super.initState();
    provider = Provider(
        taskID: widget.id,
        fetchURL: "/api/m_ppm.php?type=ppm_section_c&ppmTaskId=");
  }

  @override
  Widget build(BuildContext context) {
    provider.context = context;
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        iconTheme: IconThemeData(
          color: colorTheme3,
        ),
        title: getTitle("C. Qualitative Task", bold: true),
      ),
      body: FutureBuilder(
        future: provider.fetch(),
        builder: (context, AsyncSnapshot<ResponseValue> snapshot) {
          List<ListTile> children = [
            ListTile(
              title: new Text("Enviromental Check"),
            )
          ];

          if (snapshot.data != null && items.length == 0)
            snapshot.data.sectionCList.forEach((f) {
              var updateItem =
                  UploadItem.from(index: items.length.toString(), item: f);

              items.add(updateItem);
            });

          if (items.length > 0)
            children.addAll(items
                .map((x) => widget.disable ? getFormDisabled(x) : getForm(x))
                .toList());

          return loading || snapshot.data == null
              ? new Stack(
                  children: <Widget>[
                    ListView(
                      children: children,
                    ),
                    Container(
                      color: Colors.black.withOpacity(0.5),
                      child: Center(
                        child: CircularProgressIndicator(),
                      ),
                    )
                  ],
                )
              : ListView(
                  children: children,
                );
        },
      ),
      floatingActionButton: widget.disable
          ? null
          : FloatingActionButton.extended(
              label: new Text("Save"),
              backgroundColor: colorTheme2,
              onPressed: () {
                if (widget.verified) {
                  setState(() {
                    loading = true;
                  });

                  Map<String, dynamic> body = {
                    "action": "save_qualitative_tasks",
                    "ppmTaskId": widget.id,
                  };

                  // int count_NA = 0;

                  items.forEach((f) {
                    // if (f.result == "N/A") count_NA++;
                    // else
                    body.addAll(f.body);
                  });

                  // if (items.length == count_NA){
                  //   Toast.show("Nothing to update.", context);
                  //   return;
                  // }

                  provider
                      .post(url: "/api/m_ppm.php", body: body)
                      .then((value) {
                    widget.refreshStatus();
                    alert(value);
                  }).catchError((err) {
                    alert(err);
                  }).whenComplete(() {
                    setState(() => loading = false);
                  });
                } else {
                  Toast.show("Please verified this task.");
                }
              },
            ),
    );
  }

  Widget getTitle(String text, {bold = false}) => new Container(
        alignment: Alignment.centerLeft,
        child: new Text(text,
            style: TextStyle(
                fontWeight: bold ? FontWeight.bold : FontWeight.normal,
                color: colorTheme3)),
      );

  ListTile getForm(UploadItem item) {
    print(item);
    return new ListTile(
      title: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            getTitle(item.number + ". " + item.desc),
            // item.result != "N/A" ?
            filter(item),
            // : field("Status", (_) => null,
            //     value: "N/A", horizontal: 0.0, enable: false),
            field(
              "Remark",
              (text) => item.remark = text,
              horizontal: 0.0,
              value: item.remark,
              // enable: (item.result != "N/A")
            ),
            SizedBox(
              height: 30,
            )
          ]),
    );
  }

  ListTile getFormDisabled(UploadItem item) {
    return new ListTile(
      title: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            getTitle(item.number + ". " + item.desc),
            field("Status", (_) => null,
                value: item.statusCheck == "N/A" ? "N/A" : item.result,
                horizontal: 0.0,
                enable: false),
            field("Remark", (text) => item.remark = text,
                horizontal: 0.0, value: item.remark, enable: false),
            SizedBox(
              height: 30,
            )
          ]),
    );
  }

  DropdownButton filter(UploadItem item) {
    return DropdownButton<String>(
        hint: new Text("Status"),
        isExpanded: true,
        style: TextStyle(fontFamily: "Avenir", color: colorTheme3),
        value: item.dropDownValue,
        onChanged: (String newValue) {
          setState(() => item.result = newValue);
        },
        items: [
          DropdownMenuItem(value: "Pass", child: new Text("Pass")),
          DropdownMenuItem(value: "Fail", child: new Text("Fail")),
          DropdownMenuItem(value: "N/A", child: new Text("N/A")),
        ]);
  }

  void alert(String txt) {
    showDialog(
        context: context,
        builder: (BuildContext context) => CustomDialog(
            description: txt,
            buttonText: "Okay",
            image: Image.asset(
              "assets/icon_trans.png",
              height: 40,
            )));
  }
}

class UploadItem {
  final String index;
  final String id;
  final String number;
  final String desc;
  String result;
  String remark;

  UploadItem(
      {this.index, this.id, this.number, this.desc, this.result, this.remark});

  factory UploadItem.from({String index, FormCItem item}) {
    return UploadItem(
        index: index,
        id: item.ppmTaskQualId,
        number: item.ppmTaskQualNumb,
        desc: item.ppmTaskQualDesc,
        result: item.ppmTaskQualResult,
        remark: item.ppmTaskQualRemark);
  }

  String get dropDownValue {
    switch (result) {
      case "Pass":
        return "Pass";
      case "Fail":
        return "Fail";
      case "N/A":
        return "N/A";
      default:
        return null;
    }
  }

  String get statusCheck {
    if (result == "Pass")
      return "1";
    else if (result == "Fail")
      return "0";
    else if (result == "N/A")
      return "2";
    else
      return "";
  }

  @override
  Map<String, dynamic> get body => {
        "ppmTaskQual[$index][id]": id,
        "ppmTaskQual[$index][result]": statusCheck,
        "ppmTaskQual[$index][remark]": remark,
      };
}
