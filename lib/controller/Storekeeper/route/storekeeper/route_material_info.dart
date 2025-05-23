import 'package:flutter/material.dart';
import 'package:GEMS/controller/Storekeeper/utils/constant.dart';
import 'package:GEMS/model/complaint.dart';

class MaterialInfo extends StatelessWidget {
  final ComplaintDType value;

  const MaterialInfo({Key? key, required this.value}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(value.itemTypeDesc ?? "No description available"),
        backgroundColor: Colors.white,
      ),
      body: ListView.separated(
        itemCount: value.parts?.length ?? 0,
        itemBuilder: (BuildContext context, int index) {
          final ComplaintMaterial material = value.parts?[index] ?? ComplaintMaterial();
          return ExpansionTile(
            title: _text(material.itemDescription ?? "No description", material.partCount.toString()),
            children: [
              _expandedView(material),
              TextButton(
                child: const Text("View Details"),
                onPressed: () => Navigator.pushNamed(
                  context,
                  routeDetails,
                  arguments: material.partId,
                ),
              ),
            ],
          );
        },
        separatorBuilder: (BuildContext context, int index) => const Divider(),
      ),
    );
  }

  Widget _text(String title, String number) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: <Widget>[
        Expanded(
          child: Text(
            title,
            overflow: TextOverflow.ellipsis,
          ),
        ),
        Text(number),
      ],
    );
  }

  Widget _expandedView(ComplaintMaterial material) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(12),
      child: Text(material.itemTypeDesc ?? "No description"),
    );
  }
}
