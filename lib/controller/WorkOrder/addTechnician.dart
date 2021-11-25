import 'package:flutter/material.dart';
import 'package:gfm_gems/model/workorder.dart';

class AddTechnicianCheckList extends StatefulWidget {
  final List<WorkOrderStatus> listTechnician;
  final List<WorkOrderStatus> assistantList;

  AddTechnicianCheckList({this.listTechnician, this.assistantList});

  @override
  _AddTechnicianCheckListState createState() => _AddTechnicianCheckListState();
}

class _AddTechnicianCheckListState extends State<AddTechnicianCheckList> {
  List<WorkOrderStatus> listTechnicianSearch = List<WorkOrderStatus>();
  List<WorkOrderStatus> listTechnicianSelected = List<WorkOrderStatus>();
  TextEditingController _controller;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController();
    listTechnicianSearch.addAll(widget.listTechnician);
    listTechnicianSelected.addAll(widget.assistantList);

    _controller.addListener(() {
      var text = _controller.text;
      setState(() {
        if (text.length > 0) {
          listTechnicianSearch = List<WorkOrderStatus>();

          widget.listTechnician.forEach((f) {
            if (f.userName.toLowerCase().contains(text.toLowerCase()))
              listTechnicianSearch.add(f);
          });
        } else {
          listTechnicianSearch = widget.listTechnician;
        }
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: new Text("Add Technician Assistant"),
        backgroundColor: Colors.white,
      ),
      body: Container(
        padding: EdgeInsets.all(20),
        child: Column(
          children: <Widget>[
            TextField(
              controller: _controller,
              decoration: InputDecoration(
                hintText: "Search",
                icon: Icon(
                  Icons.search,
                ),
              ),
            ),
            Expanded(
              child: ListView(
                children: listTechnicianSearch
                    .map(
                      (f) => new CheckboxListTile(
                        title: new Text(f.userName),
                        value: listTechnicianSelected.contains(f),
                        onChanged: (value) {
                          print(value);
                          if (value) {
                            if (listTechnicianSelected.contains(f) == false)
                              setState(() => listTechnicianSelected.add(f));
                          } else
                            setState(() => listTechnicianSelected
                                .removeWhere((technician) => technician == f));
                        },
                      ),
                    )
                    .toList(),
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        label: new Text("Done"),
        onPressed: () {
          Navigator.of(context).pop(listTechnicianSelected);
        },
      ),
    );
  }
}
