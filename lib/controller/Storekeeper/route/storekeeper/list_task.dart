import 'package:flutter/material.dart';
import 'package:GEMS/controller/Storekeeper/utils/bloc/bloc_inventory.dart';
import 'package:GEMS/controller/Storekeeper/utils/constant.dart';
import 'package:GEMS/model/complaint.dart';
import 'package:GEMS/view/gems_chrome.dart';

class TaskList extends StatelessWidget {
  final BlocInventory bloc;
  const TaskList(this.bloc, {super.key});

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
            padding: const EdgeInsets.fromLTRB(12, 12, 12, 12),
            itemBuilder: (ctx, index) {
              final task = snapshot.data![index];
              return _Tile(
                bloc.status(task.statusId ?? ""),
                task,
                bloc.refresh,
              );
            },
            itemCount: snapshot.data?.length ?? 0,
            separatorBuilder: (ctx, index) => const SizedBox(height: 10),
          ),
        );
      },
    );
  }
}

class _Tile extends StatelessWidget {
  final String status;
  final RequestTask value;
  final Function refresh;

  const _Tile(this.status, this.value, this.refresh);

  @override
  Widget build(BuildContext context) {
    final style = GemsStatusStyle.forInventory(status);
    return GemsAccentCard(
      accent: style.foreground,
      onTap: () {
        Navigator.pushNamed(context, routeStockRequest, arguments: value)
            .then((_) => refresh());
      },
      child: Padding(
        padding: const EdgeInsets.fromLTRB(12, 12, 12, 12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Text(
                    value.woTaskRequestNo ?? 'N/A',
                    style: GemsChrome.body(size: 15, weight: FontWeight.w600),
                  ),
                ),
                const SizedBox(width: 8),
                _chip(status, style),
              ],
            ),
            const SizedBox(height: 6),
            text(value.requestBy ?? 'Unknown'),
            text(value.requestTime ?? 'Unknown'),
            text(value.woTaskNo ?? 'N/A'),
          ],
        ),
      ),
    );
  }

  Widget text(String value) {
    return Padding(
      padding: const EdgeInsets.only(top: 2),
      child: Text(value, style: GemsChrome.body(size: 13, color: GemsChrome.textSoft)),
    );
  }

  Widget _chip(String label, GemsStatusStyle style) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: style.background,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        label,
        style: GemsChrome.body(
          size: 12,
          weight: FontWeight.w600,
          color: style.foreground,
        ),
      ),
    );
  }
}