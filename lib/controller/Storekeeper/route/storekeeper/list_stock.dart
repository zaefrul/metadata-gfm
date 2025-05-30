import 'package:flutter/material.dart';
import 'package:GEMS/controller/Storekeeper/utils/bloc/bloc_inventory.dart';
import 'package:GEMS/controller/Storekeeper/utils/constant.dart';
import 'package:GEMS/model/complaint.dart';
import '../../../../main.dart';

class MyStock extends StatelessWidget {
  final BlocInventory bloc;

  const MyStock(this.bloc, {super.key});

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
                _filter(context),
                if (snapshot.hasData)
                  _body(snapshot.data!, context: navigatorKey.currentContext!)
                else
                  const Center(child: Text("Loading...")),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget text(String title, String number, {bool hero = false}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: <Widget>[
        Expanded(child: Text(title, overflow: TextOverflow.ellipsis)),
        Text(number),
      ],
    );
  }

  Widget _filter(BuildContext context) {
    return StreamBuilder<List<ComplaintDStore>>(
      stream: bloc.stores$,
      builder: (context, snapshotList) {
        if (snapshotList.data == null) return Container();
        return StreamBuilder<ComplaintDStore>(
          stream: bloc.store$,
          builder: (context, snapshot) {
            return Padding(
              padding: const EdgeInsets.all(12),
              child: Row(
                children: [
                  const Text(
                    "Store :  ",
                    style: TextStyle(fontSize: 16),
                  ),
                  DropdownButton<ComplaintDStore>(
                    underline: Container(),
                    value: snapshot.data,
                    hint: const Text("Select Store"),
                    onChanged: (ComplaintDStore? newValue) {
                      if (newValue != null) {
                        bloc.store = newValue;
                      }
                    },
                    items: snapshotList.data!
                        .map<DropdownMenuItem<ComplaintDStore>>((ComplaintDStore value) {
                      return DropdownMenuItem<ComplaintDStore>(
                        value: value,
                        child: Text(value.itemName ?? 'Unknown'),
                      );
                    }).toList(),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  Widget _body(List<ComplaintDGroupStore> data, {required BuildContext context}) {
    return RefreshIndicator(
      onRefresh: () => bloc.getStore(context),
      child: ListView.separated(
        primary: true,
        shrinkWrap: true,
        itemBuilder: (BuildContext context, int index) {
          ComplaintDGroupStore value = data[index];
          return ExpansionTile(
            title: text(value.itemName ?? 'Unknown', (value.itemTypes?.length ?? 0).toString()),
            children: value.itemTypes?.map((x) {
              return ListTile(
                title: text(x.itemTypeDesc ?? "", (x.parts?.length ?? 0).toString()),
                trailing: const Icon(Icons.navigate_next),
                onTap: () {
                  Navigator.pushNamed(context, routeMaterialInfo,
                      arguments: x);
                },
              );
            }).toList() ?? [],
          );
        },
        itemCount: data.length,
        separatorBuilder: (BuildContext context, int index) => const Divider(),
      ),
    );
  }
}
