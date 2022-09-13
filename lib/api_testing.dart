import 'dart:async';

import 'package:flutter/material.dart';
import 'package:gfm_gems/utils/network.dart';
import 'package:gfm_gems/utils/reference.dart';

final String api_rect = '/api/m_wo.php?type=wr_rectification_time&woTaskId=';
final String api_save = 'save_wr_rectification_time, woTaskId=';
final String id = '90';

class APILIST extends StatefulWidget {
  @override
  _APILISTState createState() => _APILISTState();
}

class _APILISTState extends State<APILIST> {
  final StreamController<String> _result = StreamController<String>();

  @override
  void dispose() {
    _result.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("testing"),
      ),
      body: Container(
        height: MediaQuery.of(context).size.height,
        child: Column(
          children: [
            Expanded(
              child: ListView(
                  children: [api_rect, api_save]
                      .map((e) => TileBuild(
                            url: e,
                            sink: _result.sink,
                            isGet: api_rect == e,
                            isPost: api_save == e,
                          ))
                      .toList()),
            ),
            Center(
                child: StreamBuilder(
              stream: _result.stream,
              builder: (context, snapshot) {
                if (snapshot.data == null) return Container();
                final result = snapshot.data;
                return Text(result);
              },
            ))
          ],
        ),
      ),
    );
  }
}

class TileBuild extends StatelessWidget {
  final String url;
  final Sink sink;
  final bool isGet;
  final bool isPost;

  const TileBuild(
      {Key key,
      @required this.url,
      @required this.sink,
      this.isGet = false,
      this.isPost = false})
      : super(key: key);
  @override
  Widget build(BuildContext context) {
    return ListTile(
      title: Text("API $url"),
      onTap: onTap,
      trailing: TextButton(
        child: Text('TEST'),
        onPressed: onTap,
      ),
    );
  }

  void onTap() {
    final Provider provider = Provider(
      fetchURL: url,
      taskID: id,
    );

    try {
      var result;
      if (isGet)
        result = provider.fetch();
      else
        result = provider.post();

      sink.add(result);
    } catch (e) {
      sink.add(e.toString());
    }
  }
}

class SampleScreen extends StatelessWidget {
  Widget status(String title, Color color) => Container(
      alignment: Alignment.center,
      height: 30.0,
      width: 100.0,
      decoration: BoxDecoration(
          color: color, borderRadius: new BorderRadius.circular(20.0)),
      child: new Text(title,
          style: TextStyle(color: Colors.white, fontFamily: 'Avenir')));

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        title: Column(
          children: [
            Text(
              "Demo LKIM",
              style: TextStyle(fontWeight: FontWeight.bold, color: colorTheme3),
            ),
            Text(
              "WRLKIM20041700002",
              style: TextStyle(fontSize: 16),
            )
          ],
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.start,
        ),
        leading: Icon(Icons.chevron_left_outlined, size: 32),
      ),
      body: ListView(
        padding: EdgeInsets.only(top: 12),
        children: [
          ListTile(
            title: Row(
              children: [
                Text("A. Complaints Details"),
                Spacer(),
                status("Info", colorTheme2)
              ],
            ),
            trailing: Icon(Icons.arrow_right),
          ),
          Divider(thickness: 1),
          ListTile(
            title: Row(
              children: [
                Text("B. Assign Executor"),
                Spacer(),
                status("Pending", colorTheme4)
              ],
            ),
            trailing: Icon(Icons.arrow_right),
          ),
          Divider(thickness: 1),
          ListTile(
            title: Row(
              children: [
                Text("C. Rectification Time"),
                Spacer(),
                status("Pending", colorTheme4)
              ],
            ),
            trailing: Icon(Icons.arrow_right),
          )
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        backgroundColor: colorTheme3,
        label: Text("Submit"),
        onPressed: () {},
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
    );
  }
}
