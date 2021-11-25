import 'package:flutter/material.dart';
import 'package:gfm_gems/controller/Storekeeper/utils/bloc/bloc_inventory.dart';
import 'package:gfm_gems/controller/Storekeeper/utils/constant.dart';
import 'package:gfm_gems/model/complaint.dart';

class MyStock extends StatelessWidget {
  final BlocInventory bloc;

  MyStock(this.bloc);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 8.0, bottom: 40),
      child: StreamBuilder<List<ComplaintDGroupStore>>(
        stream: bloc.materials$,
        builder: (ctx, snapshot) {
          return SingleChildScrollView(
            child: Column(
              children: [
                _filter,
                if (snapshot.hasData) _body(snapshot.data, context: context),
                if (snapshot.hasData == false)
                  Container(child: Center(child: Text("Loading..."))),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget text(title, number, {bool hero = false}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: <Widget>[
        Expanded(child: Text(title, overflow: TextOverflow.ellipsis)),
        Text(number),
      ],
    );
  }

  Widget get _filter => StreamBuilder<List<ComplaintDStore>>(
      stream: bloc.stores$,
      builder: (context, snapshotList) {
        if (snapshotList.data == null) return Container();
        return StreamBuilder<ComplaintDStore>(
            stream: bloc.store$,
            builder: (context, snapshot) {
              return Padding(
                padding: EdgeInsets.all(12),
                child: Row(
                  children: [
                    Text(
                      "Store :  ",
                      style: TextStyle(fontSize: 16),
                    ),
                    DropdownButton<ComplaintDStore>(
                      underline: new Container(),
                      value: snapshot.data,
                      hint: Text("Select Store"),
                      onChanged: (ComplaintDStore newValue) =>
                          bloc.store = newValue,
                      items: snapshotList.data
                          .map<DropdownMenuItem<ComplaintDStore>>(
                              (ComplaintDStore value) {
                        return DropdownMenuItem<ComplaintDStore>(
                          value: value,
                          child: Text(value.itemName),
                        );
                      }).toList(),
                    ),
                  ],
                ),
              );
            });
      });

  Widget _body(List<ComplaintDGroupStore> data, {BuildContext context}) =>
      RefreshIndicator(
        onRefresh: () => bloc.getStore(context),
        child: ListView.separated(
          primary: true,
          shrinkWrap: true,
          itemBuilder: (BuildContext context, int index) {
            List<ComplaintDGroupStore> values = data;
            ComplaintDGroupStore value = values[index];
            return ExpansionTile(
                title: text(value.itemName, value.itemTypes.length.toString()),
                children: value.itemTypes
                    .map((x) => ListTile(
                          title: text(
                              x.itemTypeDesc ?? "", x.parts.length.toString()),
                          trailing: Icon(Icons.navigate_next),
                          onTap: () {
                            Navigator.pushNamed(context, routeMaterialInfo,
                                arguments: x);
                          },
                        ))
                    .toList());
          },
          itemCount: data.length,
          separatorBuilder: (BuildContext context, int index) => Divider(),
        ),
      );
}
