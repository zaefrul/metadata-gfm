import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:gfm_gems/controller/PPM/Form/openImage.dart';
import 'package:gfm_gems/model/workorder.dart';
import 'package:gfm_gems/utils/network.dart';
import 'package:url_launcher/url_launcher.dart';
// import 'package:gfm_gems/controller/Storekeeper/utils/constant.dart'; // for colorTheme2
import 'package:gfm_gems/utils/reference.dart';
import 'package:shimmer/shimmer.dart';
import '../../main.dart';

class ComplaintSectionA extends StatefulWidget {
  final bool viewer;
  final String id;

  const ComplaintSectionA({Key? key, required this.id, this.viewer = false})
      : super(key: key);

  @override
  _ComplaintSectionAState createState() => _ComplaintSectionAState(id);
}

class _ComplaintSectionAState extends State<ComplaintSectionA> {
  final Provider _provider;

  _ComplaintSectionAState(String id)
      : _provider = Provider(
          fetchURL: "/api/m_wo.php?type=complaint_details&woTaskId=",
          taskID: id,
        );

  Future<WorkOrderDetail> get _fetch async {
    _provider.context = context;
    try {
      var result = await _provider.fetch();
      if (result.woDetail == null) {
        throw Exception("woDetail came back null");
      }
      return result.woDetail!;
    } catch (err, st) {
      rethrow;
    }
  }

  Widget build(BuildContext context) {
    final isWide = MediaQuery.of(context).size.width > 600;

    return Scaffold(
      appBar: AppBar(
        title: Text("A. Complaint Details"),
        centerTitle: true,
        backgroundColor: Colors.white,
        iconTheme: IconThemeData(color: colorTheme3),
        titleTextStyle: TextStyle(
          color: colorTheme3, fontSize: 18, fontWeight: FontWeight.w600
        ),
      ),
      body: FutureBuilder<WorkOrderDetail>(
        future: _fetch,
        builder: (ctx, snap) {
          if (snap.connectionState == ConnectionState.waiting) {
            return _buildLoadingPlaceholder(isWide);
          }
          if (snap.hasError) {
            return Center(child: Text("Error: ${snap.error}"));
          }
          if (!snap.hasData) {
            return Center(child: Text("No data returned"));
          }
          final d = snap.data!;
          return isWide ? _buildGrid(context, d) : _buildList(context, d);
        }
      ),
    );
  }

  /// 1) Shimmer placeholder
  Widget _buildLoadingPlaceholder(bool isWide) {
    // we'll show 6 placeholder rows
    final count = 6;
    return Padding(
      padding: const EdgeInsets.all(16),
      child: isWide
        ? GridView.builder(
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              crossAxisSpacing: 16,
              mainAxisSpacing: 16,
              childAspectRatio: 4,
            ),
            itemCount: count,
            itemBuilder: (_, __) => _shimmerBox(),
          )
        : ListView.separated(
            itemCount: count,
            separatorBuilder: (_, __) => SizedBox(height: 12),
            itemBuilder: (_, __) => _shimmerBox(),
          )
    );
  }

  Widget _shimmerBox() {
    return Shimmer.fromColors(
      baseColor: Colors.grey.shade300,
      highlightColor: Colors.grey.shade100,
      child: Container(
        height: 48,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(8),
        ),
      ),
    );
  }

  /// 2) Single‑column list on phones
  Widget _buildList(BuildContext ctx, WorkOrderDetail d) {
    final fields = _makeFields(d);
    return ListView.separated(
      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
      separatorBuilder: (_, __) => Divider(height: 1, color: Colors.grey[200]),
      itemCount: fields.length + d.complaintImages.length,
      itemBuilder: (c, i) {
        if (i < fields.length) {
          final f = fields[i];
          return _buildRow(f.icon, f.label, f.value);
        }
        final img = d.complaintImages[i - fields.length];
        return _buildImageRow(img);
      },
    );
  }

  /// 3) Two‑column grid on tablets
  Widget _buildGrid(BuildContext ctx, WorkOrderDetail d) {
    final fields = _makeFields(d);
    return GridView.builder(
      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        mainAxisSpacing: 12,
        crossAxisSpacing: 12,
        childAspectRatio: 4,
      ),
      itemCount: fields.length,
      itemBuilder: (c, i) {
        final f = fields[i];
        return _buildRow(f.icon, f.label, f.value);
      },
    );
  }

  /// shared builder for a row
  Widget _buildRow(IconData icon, String label, String value) {
    return InkWell(
      onTap: () {}, // ripple feedback even if no action
      borderRadius: BorderRadius.circular(8),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 8),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            SizedBox(
              width: 36,
              child: Center(
                child: Icon(icon, size: 24, color: colorTheme2),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(label,
                      style: TextStyle(
                        fontSize: 12,
                        color: colorTheme3,
                      )),
                  const SizedBox(height: 4),
                  Text(value,
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                      )),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// shared builder for an image row
  Widget _buildImageRow(ComplaintImage img) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // the thumbnail
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: Image.network(
              "https:${img.documentSrc}",
              width: 80,
              height: 80,
              fit: BoxFit.cover,
            ),
          ),
          const SizedBox(width: 12),
          // timestamp & coords
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  img.woTaskUploadTimestamp,
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  "${img.woTaskUploadLatitude}, ${img.woTaskUploadLongitude}",
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.black54,
                  ),
                ),
              ],
            ),
          ),
          // tap target
          IconButton(
            icon: Icon(Icons.more_vert, color: Colors.black54),
            onPressed: () => _showImageOptions(img),
          ),
        ],
      ),
    );
  }

  void _showImageOptions(ComplaintImage img) {
  final lat = img.woTaskUploadLatitude;
  final lng = img.woTaskUploadLongitude;
  final src = img.documentSrc;

  Future<void> _openMap() async {
    final googleUrl = Uri.parse('https://www.google.com/maps/search/?api=1&query=$lat,$lng');
    final appleUrl  = Uri.parse('https://maps.apple.com/?sll=$lat,$lng');
    if (await canLaunchUrl(googleUrl)) {
      await launchUrl(googleUrl);
    } else if (await canLaunchUrl(appleUrl)) {
      await launchUrl(appleUrl);
    } else {
      throw 'Could not launch map for $lat,$lng';
    }
  }

  void _openViewer() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => ImageViewer(url: "https:$src")),
    );
  }

  showModalBottomSheet(
    context: navigatorKey.currentContext!,
    builder: (_) => SafeArea(
      child: Wrap(
        children: [
          ListTile(
            leading: Icon(Icons.image),
            title: Text('View Image'),
            onTap: () {
              Navigator.pop(context);
              _openViewer();
            },
          ),
          ListTile(
            leading: Icon(Icons.map),
            title: Text('Open Map'),
            onTap: () {
              Navigator.pop(context);
              _openMap();
            },
          ),
        ],
      ),
    ),
  );
}

  List<_FieldRow> _makeFields(WorkOrderDetail d) => [
    _FieldRow(Icons.confirmation_number,  "Work Order No",      d.woTaskNo),
    _FieldRow(Icons.request_page,         "Request No",         d.woTaskRequestNo),
    _FieldRow(Icons.person,               "Reported by",        d.woTaskReportedBy),
    _FieldRow(Icons.phone,                "Phone No",           d.woTaskPhoneNo),
    _FieldRow(Icons.email,                "Email",              d.woTaskEmail),
    _FieldRow(Icons.calendar_today,       "Reported Date/Time", d.woTaskTimeResponded),
    _FieldRow(Icons.category,             "Category",           d.woTaskCategory),
    _FieldRow(Icons.business,             "Client",             d.woTaskClient),
    _FieldRow(Icons.place,                "Location",           d.woTaskLocation),
    _FieldRow(Icons.description,         "Description",        d.woTaskComplaint),
  ];

  void _openImageOptions(ComplaintImage img) {
    showModalBottomSheet(
      context: navigatorKey.currentContext!,
      builder: (_) => Wrap(children: [
        ListTile(
          leading: Icon(Icons.image),
          title: Text("View Image"),
          onTap: () {
            Navigator.pop(context);
            Navigator.push(context,
                MaterialPageRoute(builder: (_) => ImageViewer(url: "https:" + img.documentSrc)));
          },
        ),
        ListTile(
          leading: Icon(Icons.map),
          title: Text("Open Map"),
          onTap: () {
            Navigator.pop(context);
            launch(
              'https://maps.google.com/?q=${img.woTaskUploadLatitude},${img.woTaskUploadLongitude}'
            );
          },
        ),
      ]),
    );
  }
}

class _FieldRow {
  final IconData icon;
  final String label;
  final String value;
  _FieldRow(this.icon, this.label, this.value);
}