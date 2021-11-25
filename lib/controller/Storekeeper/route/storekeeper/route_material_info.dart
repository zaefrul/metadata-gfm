import 'package:flutter/material.dart';
import 'package:gfm_gems/controller/Storekeeper/utils/constant.dart';
import 'package:gfm_gems/model/complaint.dart';

class MaterialInfo extends StatelessWidget {
  final ComplaintDType value;

  MaterialInfo({@required this.value});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
          title: Text(this.value.itemTypeDesc), backgroundColor: Colors.white),
      body: ListView.separated(
        itemBuilder: (BuildContext context, int index) {
          final ComplaintMaterial material = value.parts[index];
          return ExpansionTile(
              title:
                  text(material.itemDescription, material.partCount.toString()),
              children: [
                expandedView(material),
                TextButton(
                    child: Text("View Details"),
                    onPressed: () => Navigator.pushNamed(context, routeDetails,
                        arguments: material.partId))
              ]);
        },
        itemCount: value.parts.length,
        separatorBuilder: (BuildContext context, int index) => Divider(),
      ),
    );
  }

  Widget text(title, number) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: <Widget>[
        Expanded(
            child: Text(
          title,
          overflow: TextOverflow.ellipsis,
        )),
        Text(number),
      ],
    );
  }

  Widget expandedView(ComplaintMaterial material) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.max,
        children: <Widget>[
          Text(material.itemTypeDesc ?? "No description"),
        ],
      ),
    );
  }
}
