import 'package:flutter/material.dart';
import 'package:GEMS/controller/Storekeeper/utils/bloc/bloc_inventory.dart';
import 'package:GEMS/controller/Storekeeper/utils/constant.dart';
import 'package:GEMS/model/complaint.dart';

class TaskList extends StatelessWidget {
  final BlocInventory bloc;
  TaskList(this.bloc);

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<List<RequestTask>>(
      stream: bloc.task$ as Stream<List<RequestTask>>?,
      builder: (ctx, snapshot) {
        if (!snapshot.hasData || snapshot.data == null) {
          return Center(child: CircularProgressIndicator());
        }

        return RefreshIndicator(
          onRefresh: bloc.refresh,
          child: ListView.separated(
            shrinkWrap: true,
            primary: true,
            physics: NeverScrollableScrollPhysics(),
            padding: EdgeInsets.only(top: 12, bottom: 12),
            itemBuilder: (ctx, index) {
              final task = snapshot.data![index];
              return _Tile(
                bloc.status(task.statusId ?? ""),
                task,
                index,
                bloc.color(task.statusId ?? ""),
                bloc.refresh,
              );
            },
            itemCount: snapshot.data?.length ?? 0,
            separatorBuilder: (ctx, index) => Divider(),
          ),
        );
      },
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
      title: Text(
        value.woTaskRequestNo ?? "N/A",
        style: TextStyle(fontWeight: FontWeight.bold),
      ),
      subtitle: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          text(value: value.requestBy ?? "Unknown", top: 8.0),
          text(value: value.requestTime ?? "Unknown"),
          text(value: value.woTaskNo ?? "N/A"),
        ],
      ),
      trailing: state,
      onTap: () {
        Navigator.pushNamed(context, routeStockRequest, arguments: value)
            .then((_) => refresh());
      },
    );
  }

  Widget text({required String value, double top = 3.0}) {
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
          status,
          style: TextStyle(color: Colors.white, fontSize: 16),
        ),
      ),
    );
  }
}