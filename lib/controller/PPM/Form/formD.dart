import 'package:flutter/material.dart';
import 'package:gfm_gems/model/form.dart';
import 'package:gfm_gems/model/responseValue.dart';
import 'package:gfm_gems/utils/network.dart';
import 'package:gfm_gems/utils/reference.dart';
import 'package:gfm_gems/view/dialog.dart';
import 'package:gfm_gems/view/field.dart';
import 'package:toast/toast.dart';

class FormD extends StatefulWidget {
  final String id;
  final bool verified;
  final Function refreshStatus;
  final bool disable;

  FormD(this.id, this.verified, this.refreshStatus, this.disable);

  @override
  _FormDState createState() => _FormDState();
}

class _FormDState extends State<FormD> {
  Provider provider;
  bool loading = false;
  List<UploadItem> items = List<UploadItem>();

  @override
  void initState() {
    super.initState();
    provider = Provider(
        taskID: widget.id,
        fetchURL: "/api/m_ppm.php?type=ppm_section_d&ppmTaskId=");
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
        title: getTitle("D. Quantitative Task", bold: true),
      ),
      body: FutureBuilder(
        future: provider.fetch(),
        builder: (context, AsyncSnapshot<ResponseValue> snapshot) {
          List<Widget> children = List<Widget>();
          if (snapshot.error != null) {
            return new Center(
              child: new Text("No Task for Quantitative."),
            );
          }
          if (snapshot.data != null && items.length == 0)
            snapshot.data.sectionDList.forEach((f) {
              var updateItem =
                  UploadItem.from(index: items.length.toString(), item: f);

              items.add(updateItem);
            });

          if (items.length > 0)
            children.addAll(items
                .map((x) => widget.disable ? getFormDisabled(x) : getForm(x))
                .toList()
                  ..add(SizedBox(height: 60)));

          return snapshot.data == null
              ? Center(child: CircularProgressIndicator())
              : (loading
                  ? Stack(children: [
                      Container(
                          padding: EdgeInsets.all(16.0),
                          child: ListView(children: children)),
                      Container(
                        color: Colors.black.withOpacity(0.5),
                        child: Center(
                          child: CircularProgressIndicator(),
                        ),
                      ),
                    ])
                  : Container(
                      padding: EdgeInsets.all(16.0),
                      child: ListView(children: children)));
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
                    "action": "save_quantitative_tasks",
                    "ppmTaskId": widget.id,
                  };

                  // int count_NA = 0;

                  items.forEach((f) {
                    // if (f.result == "N/A") count_NA++;
                    // else
                    body.addAll(f.body);
                  });

                  // if (items.length == count_NA){
                  //   setState(() {
                  //     loading = false;
                  //   });
                  //   Toast.show("Nothing to update.", context);
                  //   return;
                  // }

                  provider
                      .post(url: "/api/m_ppm.php", body: body)
                      .then((value) {
                        widget.refreshStatus();
                        alert(value);
                      })
                      .catchError((err) => alert(err))
                      .whenComplete(() => setState(() => loading = false));
                } else {
                  Toast.show("Please verified this task.", context);
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

  Widget getForm(UploadItem item) {
    return new Container(
      padding: EdgeInsets.only(top: 20),
      child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            getTitle(item.number + ". " + item.desc),
            new Row(
              children: <Widget>[
                Flexible(
                  child: field("Units", (text) => null,
                      horizontal: 0.0, value: item.unit, enable: false),
                ),
                new SizedBox(
                  width: 16,
                ),
                Flexible(
                  child: field("Set Values", (text) => item.setValues = text,
                      horizontal: 0.0, value: item.setValues, enable: false),
                ),
              ],
            ),
            new Row(
              children: <Widget>[
                Flexible(
                  child: field(
                    "Measured Values", (text) => item.measuredValues = text,
                    horizontal: 0.0,
                    value: item.measuredValues,
                    // enable: item.result != "N/A"
                  ),
                ),
                new SizedBox(
                  width: 16,
                ),
                Flexible(
                  child: field(
                    "Limit/ Tolerance", (text) => item.limit = text,
                    horizontal: 0.0,
                    value: item.limit,
                    // enable: item.result != "N/A"
                  ),
                ),
              ],
            ),
            // item.result != "N/A" ?
            filter(item),
            // : field("Status", (_) => null,
            //     value: "N/A", horizontal: 0.0, enable: false),
            field("Remarks", (text) => item.remark = text,
                horizontal: 0.0,
                value: item.remark,
                enable: item.result != "N/A")
          ]),
    );
  }

  Widget getFormDisabled(UploadItem item) {
    return new Container(
      padding: EdgeInsets.only(top: 20),
      child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            getTitle(item.number + ". " + item.desc),
            field("Units", (text) => null,
                horizontal: 0.0, value: item.unit, enable: false),
            field("Set Values", (text) => item.setValues = text,
                horizontal: 0.0, value: item.setValues, enable: false),
            field("Measured Values", (text) => item.measuredValues = text,
                horizontal: 0.0, value: item.measuredValues, enable: false),
            field("Limit/ Tolerance", (text) => item.limit = text,
                horizontal: 0.0, value: item.limit, enable: false),
            field("Status", (_) => null,
                value: item.result, horizontal: 0.0, enable: false),
            field("Remarks", (text) => item.remark = text,
                horizontal: 0.0, value: item.remark, enable: false)
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
          print(newValue);
          var value = items.firstWhere((test) {
            return test.id == item.id;
          }, orElse: () => item);
          setState(() => value.result = newValue);
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
  final String unit;
  final String number;
  final String desc;
  String setValues;
  String measuredValues;
  String limit;
  String result;
  String remark;

  UploadItem(
      {this.index,
      this.id,
      this.unit,
      this.number,
      this.desc,
      this.setValues,
      this.measuredValues,
      this.limit,
      this.result,
      this.remark});

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

  factory UploadItem.from({String index, FormDItem item}) {
    return UploadItem(
        index: index,
        id: item.ppmTaskQuanId,
        unit: item.ppmTaskQuanUnit,
        number: item.ppmTaskQuanNumb,
        desc: item.ppmTaskQuanDesc,
        setValues: item.ppmTaskQuanSetValues,
        measuredValues: item.ppmTaskQuanMeasuredValues,
        limit: item.ppmTaskQuanLimit,
        result: item.ppmTaskQuanResult,
        remark: item.ppmTaskQuanRemark);
  }

  String get statusCheck {
    if (result == "Pass")
      return "1";
    else if (result == "Fail")
      return "0";
    else if (result == "N/A")
      return "2";
    else
      return "N/A";
  }

  @override
  Map<String, dynamic> get body => {
        "ppmTaskQuan[$index][id]": id,
        "ppmTaskQuan[$index][setValues]": setValues,
        "ppmTaskQuan[$index][measuredValues]": measuredValues,
        "ppmTaskQuan[$index][limit]": limit,
        "ppmTaskQuan[$index][result]": statusCheck,
        "ppmTaskQuan[$index][remark]": remark,
      };
}
