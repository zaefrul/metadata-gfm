import 'package:flutter/material.dart';
import 'package:GEMS/controller/Storekeeper/utils/bloc/bloc_inventory.dart';
import 'package:GEMS/controller/Storekeeper/utils/constant.dart';
import 'package:GEMS/model/complaint.dart';
import 'package:GEMS/view/gems_chrome.dart';
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
        Expanded(
          child: Text(
            title,
            overflow: TextOverflow.ellipsis,
            style: GemsChrome.body(size: 15, weight: FontWeight.w600),
          ),
        ),
        Text(number, style: GemsChrome.body(color: GemsChrome.textSoft)),
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
                  Text('Store :  ', style: GemsChrome.body(size: 16)),
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
          return Padding(
            padding: const EdgeInsets.fromLTRB(12, 0, 12, 10),
            child: DecoratedBox(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(GemsChrome.radius),
                border: Border.all(color: GemsChrome.border),
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(GemsChrome.radius),
                child: ExpansionTile(
                title: text(value.itemName ?? 'Unknown', (value.itemTypes?.length ?? 0).toString()),
                children: value.itemTypes?.map((x) {
                  return ListTile(
                    title: text(x.itemTypeDesc ?? "", (x.parts?.length ?? 0).toString()),
                    trailing: const Icon(Icons.navigate_next, color: GemsChrome.textSoft),
                    onTap: () {
                      Navigator.pushNamed(context, routeMaterialInfo,
                          arguments: x);
                    },
                  );
                }).toList() ?? [],
                ),
              ),
            ),
          );
        },
        itemCount: data.length,
        separatorBuilder: (BuildContext context, int index) => const SizedBox.shrink(),
      ),
    );
  }
}
