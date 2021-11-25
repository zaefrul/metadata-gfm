import 'package:flutter/material.dart';
import 'package:gfm_gems/controller/Storekeeper/utils/bloc/bloc_inventory.dart';
import 'package:gfm_gems/controller/Storekeeper/utils/constant.dart';
import 'package:gfm_gems/model/complaint.dart';

class TaskList extends StatelessWidget {
  final BlocInventory bloc;
  TaskList(this.bloc);

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<List<RequestTask>>(
      stream: bloc.task$,
      builder: (ctx, snapshot) => RefreshIndicator(
        onRefresh: bloc.refresh,
        child: ListView.separated(
          shrinkWrap: true,
          primary: true,
          physics: NeverScrollableScrollPhysics(),
          padding: EdgeInsets.only(top: 12, bottom: 12),
          itemBuilder: (ctx, index) => _Tile(
            bloc.status(snapshot.data[index].statusId),
            snapshot.data[index],
            index,
            bloc.color(snapshot.data[index].statusId),
            bloc.refresh,
          ),
          itemCount: snapshot.data?.length ?? 0,
          separatorBuilder: (ctx, index) => Divider(),
        ),
      ),
    );
  }
}

class _Tile extends StatelessWidget {
  final String status;
  final RequestTask value;
  final Color color;
  final int index;
  final Function refresh;

  _Tile(this.status, this.value, this.index, this.color, this.refresh);

  @override
  Widget build(BuildContext context) {
    return ListTile(
      title: Text(value.woTaskRequestNo,
          style: TextStyle(fontWeight: FontWeight.bold)),
      subtitle: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        text(value: value.requestBy, top: 8.0),
        text(value: value.requestTime),
        text(value: value.woTaskNo),
      ]),
      trailing: state,
      onTap: () {
        Navigator.pushNamed(context, routeStockRequest, arguments: value)
            .then((value) => refresh());
      },
    );
  }

  Widget text({@required String value, double top = 3.0}) {
    return Padding(
      padding: EdgeInsets.only(top: top),
      child: Text(
        value,
        style: TextStyle(color: colorTheme3),
      ),
    );
  }

  Widget get state {
    return Container(
      height: 40,
      width: 170,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        color: color,
      ),
      child: Center(
        child: Text(
          status ?? "Loading",
          style: TextStyle(color: Colors.white, fontSize: 16),
        ),
      ),
    );
  }
}
