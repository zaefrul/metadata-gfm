import 'package:flutter/material.dart';
import 'package:gfm_gems/controller/PPM/Form/openImage.dart';
import 'package:gfm_gems/model/workorder.dart';
import 'package:gfm_gems/utils/network.dart';
import 'package:url_launcher/url_launcher.dart';

class ComplaintSectionA extends StatefulWidget {
  final bool viewer;
  final String id;

  ComplaintSectionA({this.id, this.viewer = false});

  @override
  ComplaintSectionAState createState() => ComplaintSectionAState(id);
}

class ComplaintSectionAState extends State<ComplaintSectionA> {
  final Provider _provider;

  ComplaintSectionAState(String id)
      : _provider = Provider(
            fetchURL: "/api/m_wo.php?type=complaint_details&woTaskId=",
            taskID: id);

  Future<WorkOrderDetail> get _fetch async {
    try {
      _provider.context = context;

      var result = await _provider.fetch();
      return Future.value(result.woDetail);
    } catch (err) {
      return Future.error(err);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: new Text("A. Complaint Details"),
          centerTitle: true,
          backgroundColor: Colors.white,
        ),
        body: FutureBuilder(
          future: _fetch,
          builder: (context, AsyncSnapshot<WorkOrderDetail> snapshot) {
            var value = snapshot.data;
            return value == null
                ? _loading
                : ListView(
                    children: <Widget>[
                      _row("Work Order No: ", value.woTaskNo),
                      _row("Request No: ", value.woTaskRequestNo),
                      _row("Reported by: ", value.woTaskReportedBy),
                      _row("Phone No: ", value.woTaskPhoneNo),
                      _row("Email: ", value.woTaskEmail),
                      _row("Reported Date/Time: ", value.woTaskTimeResponded),
                      _row("Category: ", value.woTaskCategory),
                      _row("Client: ", value.woTaskClient),
                      _row("Location: ", value.woTaskLocation),
                      Padding(
                        padding: const EdgeInsets.all(12.0),
                        child: _title("Description of Complaint"),
                      ),
                      Padding(
                        padding: const EdgeInsets.all(12.0),
                        child: _descriptionView(value.woTaskComplaint),
                      ),
                      value.complaintImages.length >= 1
                          ? _section(value.complaintImages[0])
                          : new Container(),
                      value.complaintImages.length >= 2
                          ? _section(value.complaintImages[1])
                          : new Container(),
                      value.complaintImages.length >= 3
                          ? _section(value.complaintImages[2])
                          : new Container(),
                    ],
                  );
          },
        ));
  }

  Widget get _loading => new Container(
        child: Center(
          child: CircularProgressIndicator(),
        ),
      );

  Widget _title(String text) => new Text(
        text,
        style: TextStyle(fontWeight: FontWeight.bold),
      );
  Widget _subtitle(String text) => new Text(text);

  Widget _row(String title, String value) => Padding(
        padding: const EdgeInsets.all(12.0),
        child: new Row(
          children: <Widget>[_title(title), _subtitle(value)],
        ),
      );

  Widget _descriptionView(String value) => new Container(
      padding: EdgeInsets.all(12),
      decoration: BoxDecoration(
        border: Border.all(color: Colors.black),
      ),
      child: _subtitle(value));

  Widget _section(ComplaintImage item) {
    var latitude = item.woTaskUploadLatitude;
    var longitude = item.woTaskUploadLongitude;
    var date = item.woTaskUploadTimestamp;
    var src = item.documentSrc;
    var desc = item.woTaskUploadDesc;

    return Padding(
      padding: const EdgeInsets.all(12.0),
      child: Column(children: <Widget>[
        ListTile(
            contentPadding: EdgeInsets.only(top: 6.0),
            leading: new Image.network("https:" + src),
            title: new Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                new Text(date),
                new Text(latitude + ", " + longitude)
              ],
            ),
            onTap: () async => _bottomSheet(
                latitude: latitude, longitude: longitude, src: src)),
        TextField(
          controller: TextEditingController(text: desc),
          enabled: false,
        )
      ]),
    );
  }

  void _bottomSheet({latitude, longitude, src}) {
    _openMap() async {
      String googleUrl =
          'https://www.google.com/maps/search/?api=1&query=$latitude,$longitude';
      String appleUrl = 'https://maps.apple.com/?sll=$latitude,$longitude';

      if (await canLaunch(googleUrl))
        await launch(googleUrl);
      else if (await canLaunch(appleUrl))
        await launch(appleUrl);
      else
        throw 'Could not launch url';
    }

    _openViewer() => Navigator.push(
        context,
        MaterialPageRoute(
            builder: (context) => ImageViewer(url: "https:" + src)));

    showModalBottomSheet(
        context: context,
        builder: (BuildContext bc) => Container(
              child: new Wrap(
                children: <Widget>[
                  new ListTile(
                      leading: new Icon(Icons.image),
                      title: new Text('View Image'),
                      onTap: () => _openViewer()),
                  new ListTile(
                      leading: new Icon(Icons.map),
                      title: new Text('Open Map'),
                      onTap: () => _openMap()),
                ],
              ),
            ));
  }
}

class SampleItem {
  final String image;
  final String date;
  final String location;
  final String latitude;
  final String longitude;
  final String comment;

  SampleItem(
      {this.image,
      this.date,
      this.location,
      this.latitude,
      this.longitude,
      this.comment});
}
