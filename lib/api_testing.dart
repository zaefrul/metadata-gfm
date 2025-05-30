import 'dart:async';

import 'package:flutter/material.dart';
import 'package:GEMS/utils/network.dart';
import 'package:GEMS/utils/reference.dart';

final String api_rect = '/api/m_wo.php?type=wr_rectification_time&woTaskId=';
final String api_save = 'save_wr_rectification_time, woTaskId=';
final String id = '90';

class APILIST extends StatefulWidget {
  const APILIST({super.key});

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
        title: const Text("testing"),
      ),
      body: SizedBox(
        height: MediaQuery.of(context).size.height,
        child: Column(
          children: [
            Expanded(
              child: ListView(
                children: [api_rect, api_save]
                    .map((e) => TileBuild(
                          url: e,
                          sink: _result.sink,
                          isGet: e == api_rect,
                          isPost: e == api_save,
                        ))
                    .toList(),
              ),
            ),
            Center(
              child: StreamBuilder<String>(
                stream: _result.stream,
                builder: (context, snapshot) {
                  if (!snapshot.hasData) return Container();
                  return Text(snapshot.data!);
                },
              ),
            )
          ],
        ),
      ),
    );
  }
}

class TileBuild extends StatelessWidget {
  final String url;
  final Sink<String> sink;
  final bool isGet;
  final bool isPost;

  const TileBuild({
    super.key,
    required this.url,
    required this.sink,
    this.isGet = false,
    this.isPost = false,
  });

  void onTap() {
    final Provider provider = Provider(fetchURL: url, taskID: id);
    try {
      Future result;
      if (isGet) {
        result = provider.fetch();
      } else {
        result = provider.post(url: url, body: {"action": url});
      }
      sink.add(result.toString());
    } catch (e) {
      sink.add(e.toString());
    }
  }

  @override
  Widget build(BuildContext context) {
    return ListTile(
      title: Text("API $url"),
      onTap: onTap,
      trailing: TextButton(
        onPressed: onTap,
        child: const Text('TEST'),
      ),
    );
  }
}

class SampleScreen extends StatelessWidget {
  const SampleScreen({super.key});

  Widget status(String title, Color color) => Container(
        alignment: Alignment.center,
        height: 30.0,
        width: 100.0,
        decoration: BoxDecoration(
            color: color, borderRadius: BorderRadius.circular(20.0)),
        child: Text(title,
            style: const TextStyle(
                color: Colors.white, fontFamily: 'Avenir')),
      );

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "Demo LKIM",
              style: TextStyle(
                  fontWeight: FontWeight.bold, color: colorTheme3),
            ),
            const Text(
              "WRLKIM20041700002",
              style: TextStyle(fontSize: 16),
            )
          ],
        ),
        leading: const Icon(Icons.chevron_left_outlined, size: 32),
      ),
      body: ListView(
        padding: const EdgeInsets.only(top: 12),
        children: [
          ListTile(
            title: Row(
              children: [
                const Text("A. Complaints Details"),
                const Spacer(),
                status("Info", colorTheme2)
              ],
            ),
            trailing: const Icon(Icons.arrow_right),
          ),
          const Divider(thickness: 1),
          ListTile(
            title: Row(
              children: [
                const Text("B. Assign Executor"),
                const Spacer(),
                status("Pending", colorTheme4)
              ],
            ),
            trailing: const Icon(Icons.arrow_right),
          ),
          const Divider(thickness: 1),
          ListTile(
            title: Row(
              children: [
                const Text("C. Rectification Time"),
                const Spacer(),
                status("Pending", colorTheme4)
              ],
            ),
            trailing: const Icon(Icons.arrow_right),
          )
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        backgroundColor: colorTheme3,
        label: const Text("Submit"),
        onPressed: () {},
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
    );
  }
}
