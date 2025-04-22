import 'package:flutter/material.dart';
import 'package:date_format/date_format.dart';
import 'package:gfm_gems/utils/network.dart';
import 'package:gfm_gems/view/dialog.dart';
import 'package:intl/intl.dart';

class ComplaintSectionC_RectTime extends StatefulWidget {
  final bool viewer;
  final String id;

  const ComplaintSectionC_RectTime({Key? key, required this.viewer, required this.id})
      : super(key: key);

  @override
  _ComplaintSectionC_RectTimeState createState() =>
      _ComplaintSectionC_RectTimeState();
}

class _ComplaintSectionC_RectTimeState extends State<ComplaintSectionC_RectTime> {
  late double _height;
  late double _width;

  late String _setTime, _setDate;
  late String _hour, _minute, _time;
  late DateTime selectedDate;
  late TimeOfDay selectedTime;

  final TextEditingController _dateController = TextEditingController();
  final TextEditingController _timeController = TextEditingController();

  late Provider provider;
  bool loading = false;

  @override
  void initState() {
    super.initState();
    selectedDate = DateTime.now();
    _dateController.text = DateFormat.yMd().format(selectedDate);

    selectedTime = TimeOfDay.now();
    _hour = selectedTime.hour.toString();
    _minute = selectedTime.minute.toString();
    _time = '$_hour : $_minute';
    _timeController.text = _time;
    _timeController.text = formatDate(
      DateTime(selectedDate.year, selectedDate.month, selectedDate.day,
          selectedTime.hour, selectedTime.minute),
      [hh, ':', nn, " ", am],
    ).toString();

    provider = Provider(
      taskID: widget.id,
      fetchURL: "/api/m_wo.php?type=wo_rectify_time&woTaskId=",
    );
  }

  @override
  Widget build(BuildContext context) {
    _width = MediaQuery.of(context).size.width;
    _height = MediaQuery.of(context).size.height;
    return Scaffold(
      appBar: AppBar(
        title: const Text("C. Rectification Time"),
        backgroundColor: Colors.white,
      ),
      body: Container(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              "Date:",
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 24),
            ),
            const SizedBox(height: 12),
            InkWell(
              onTap: () => _selectDate(context),
              child: Container(
                height: _height / 9,
                alignment: Alignment.center,
                decoration: BoxDecoration(color: Colors.grey[200]),
                child: TextFormField(
                  style: const TextStyle(fontSize: 40),
                  textAlign: TextAlign.center,
                  enabled: false,
                  keyboardType: TextInputType.text,
                  controller: _dateController,
                  onSaved: (String? val) {
                    _setDate = val ?? "";
                  },
                  decoration: const InputDecoration(
                    disabledBorder:
                        UnderlineInputBorder(borderSide: BorderSide.none),
                    contentPadding: EdgeInsets.only(top: 0.0),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 20),
            const Text(
              "Time:",
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 24),
            ),
            const SizedBox(height: 12),
            InkWell(
              onTap: () => _selectTime(context),
              child: Container(
                height: _height / 9,
                alignment: Alignment.center,
                decoration: BoxDecoration(color: Colors.grey[200]),
                child: TextFormField(
                  style: const TextStyle(fontSize: 40),
                  textAlign: TextAlign.center,
                  onSaved: (String? val) {
                    _setTime = val ?? "";
                  },
                  enabled: false,
                  keyboardType: TextInputType.text,
                  controller: _timeController,
                  decoration: const InputDecoration(
                    disabledBorder:
                        UnderlineInputBorder(borderSide: BorderSide.none),
                    contentPadding: EdgeInsets.all(5),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: widget.viewer
          ? null
          : FloatingActionButton.extended(
              label: const Text("Save"),
              onPressed: () {
                // Implement save functionality as needed for rectification time.
              },
            ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
    );
  }

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: navigatorKey.currentContext!,
      initialDate: selectedDate,
      initialDatePickerMode: DatePickerMode.day,
      firstDate: DateTime(2015),
      lastDate: DateTime(2101),
    );
    if (picked != null) {
      setState(() {
        selectedDate = picked;
        _dateController.text = DateFormat.yMd().format(selectedDate);
      });
    }
  }

  Future<void> _selectTime(BuildContext context) async {
    final TimeOfDay? picked =
        await showTimePicker(context: navigatorKey.currentContext!, initialTime: selectedTime);
    if (picked != null) {
      setState(() {
        selectedTime = picked;
        _hour = selectedTime.hour.toString();
        _minute = selectedTime.minute.toString();
        _time = '$_hour : $_minute';
        _timeController.text = _time;
        _timeController.text = formatDate(
          DateTime(selectedDate.year, selectedDate.month, selectedDate.day,
              selectedTime.hour, selectedTime.minute),
          [hh, ':', nn, " ", am],
        ).toString();
      });
    }
  }

  void alert(String txt) {
    showDialog(
      context: navigatorKey.currentContext!,
      builder: (BuildContext context) => CustomDialog(
        description: txt,
        buttonText: "Okay",
        image: Image.asset(
          "assets/icon_trans.png",
          height: 40,
        ),
      ),
    );
  }
}
