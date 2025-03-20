import 'package:flutter/material.dart';
import 'package:date_format/date_format.dart';
import 'package:gfm_gems/utils/network.dart';
import 'package:gfm_gems/view/dialog.dart';
import 'package:intl/intl.dart';

class ComplaintSectionC_RectTime extends StatefulWidget {
  final bool viewer;
  final String id;

  const ComplaintSectionC_RectTime(
      {Key key, @required this.viewer, @required this.id})
      : super(key: key);
  @override
  _ComplaintSectionEState createState() => _ComplaintSectionEState();
}

class _ComplaintSectionEState extends State<ComplaintSectionC_RectTime> {
  double _height;

  double _width;

  String _setTime, _setDate;

  String _hour, _minute, _time;

  String dateTime;

  DateTime selectedDate = DateTime.now();

  TimeOfDay selectedTime = TimeOfDay(hour: 00, minute: 00);

  TextEditingController _dateController = TextEditingController();

  TextEditingController _timeController = TextEditingController();

  Provider provider;

  bool loading = false;

  @override
  void initState() {
    super.initState();
    selectedDate = DateTime.now();
    _dateController.text = DateFormat.yMd().format(selectedDate);
    selectedTime = TimeOfDay.now();
    _hour = selectedTime.hour.toString();
    _minute = selectedTime.minute.toString();
    _time = _hour + ' : ' + _minute;
    _timeController.text = _time;
    _timeController.text = formatDate(
        DateTime(selectedDate.year, selectedDate.month, selectedDate.day,
            selectedTime.hour, selectedTime.minute),
        [hh, ':', nn, " ", am]).toString();
    provider = Provider(
        taskID: widget.id,
        fetchURL: "/api/m_wo.php?type=wo_rectify_time&woTaskId=");
  }

  @override
  Widget build(BuildContext context) {
    _width = MediaQuery.of(context).size.width;
    _height = MediaQuery.of(context).size.height;
    return Scaffold(
      appBar: AppBar(
        title: new Text("C. Rectification Time"),
        backgroundColor: Colors.white,
      ),
      body: new Container(
        padding: EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "Date:",
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 24),
            ),
            SizedBox(height: 12),
            InkWell(
              onTap: () {
                _selectDate(context);
              },
              child: Container(
                height: _height / 9,
                alignment: Alignment.center,
                decoration: BoxDecoration(color: Colors.grey[200]),
                child: TextFormField(
                  style: TextStyle(fontSize: 40),
                  textAlign: TextAlign.center,
                  enabled: false,
                  keyboardType: TextInputType.text,
                  controller: _dateController,
                  onSaved: (String val) {
                    _setDate = val;
                  },
                  decoration: InputDecoration(
                      disabledBorder:
                          UnderlineInputBorder(borderSide: BorderSide.none),
                      contentPadding: EdgeInsets.only(top: 0.0)),
                ),
              ),
            ),
            SizedBox(height: 20),
            Text(
              "Time:",
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 24),
            ),
            SizedBox(height: 12),
            InkWell(
              onTap: () {
                _selectTime(context);
              },
              child: Container(
                height: _height / 9,
                alignment: Alignment.center,
                decoration: BoxDecoration(color: Colors.grey[200]),
                child: TextFormField(
                  style: TextStyle(fontSize: 40),
                  textAlign: TextAlign.center,
                  onSaved: (String val) {
                    _setTime = val;
                  },
                  enabled: false,
                  keyboardType: TextInputType.text,
                  controller: _timeController,
                  decoration: InputDecoration(
                      disabledBorder:
                          UnderlineInputBorder(borderSide: BorderSide.none),
                      // labelText: 'Time',
                      contentPadding: EdgeInsets.all(5)),
                ),
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: widget.viewer
          ? null
          : FloatingActionButton.extended(
              label: new Text("Save"),
              onPressed: () {
                //   if (remark.length > 2) {
                // setState(() => loading = true);
                // provider
                //     .post(url: "/api/m_wo.php", body: {
                //       "action": "rectify_time",
                //       "woTaskId": widget.id,
                //       "date": _setDate,
                //       "time": _setTime
                //     })
                //     .then((onValue) => alert(onValue))
                //     .then((value) {
                //       setState(() => loading = false);
                //     })
                //     .catchError((err) => alert(err))
                //     .whenComplete(() => setState(() => loading = false));
                // } else {
                //   Toast.show("You must enter at least total of 2 characters", context,gravity: Toast.CENTER);
                // }
              }),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
    );
  }

  Future<Null> _selectDate(BuildContext context) async {
    final DateTime picked = await showDatePicker(
        context: context,
        initialDate: selectedDate,
        initialDatePickerMode: DatePickerMode.day,
        firstDate: DateTime(2015),
        lastDate: DateTime(2101));
    setState(() {
      selectedDate = picked;
      _dateController.text = DateFormat.yMd().format(selectedDate);
    });
  }

  Future<Null> _selectTime(BuildContext context) async {
    final TimeOfDay picked = await showTimePicker(
      context: context,
      initialTime: selectedTime,
    );
    setState(() {
      selectedTime = picked;
      _hour = selectedTime.hour.toString();
      _minute = selectedTime.minute.toString();
      _time = _hour + ' : ' + _minute;
      _timeController.text = _time;
      _timeController.text = formatDate(
          DateTime(2019, 08, 1, selectedTime.hour, selectedTime.minute),
          [hh, ':', nn, " ", am]).toString();
    });
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
