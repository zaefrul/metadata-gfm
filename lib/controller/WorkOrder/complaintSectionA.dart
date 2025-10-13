import 'package:flutter/material.dart';
import 'package:GEMS/controller/PPM/Form/openImage.dart';
import 'package:GEMS/controller/WorkOrder/pending_sync.dart';
import 'package:GEMS/controller/WorkOrder/widgets/pending_sync_banner.dart';
import 'package:GEMS/model/workorder.dart';
import 'package:GEMS/utils/network.dart';
import 'package:url_launcher/url_launcher.dart';
// import 'package:GEMS/controller/Storekeeper/utils/constant.dart'; // for colorTheme2
import 'package:GEMS/utils/reference.dart';
import 'package:shimmer/shimmer.dart';
import '../../main.dart';

class ComplaintSectionA extends StatefulWidget {
  final bool viewer;
  final String id;
  final PendingSyncController? pendingSync;

  const ComplaintSectionA({
    super.key,
    required this.id,
    this.viewer = false,
    this.pendingSync,
  });

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
      debugPrint('this is result from fetch, but at complaintSectionA.dart');
      debugPrint(result.toString());
      if (result.woDetail == null) {
        throw Exception("woDetail came back null");
      }
      debugPrint(result.woDetail.toString());
      return result.woDetail!;
    } catch (err) {
      debugPrint("Error fetching complaint details: $err");
      rethrow;
    }
  }

  @override
  Widget build(BuildContext context) {
    final isWide = MediaQuery.of(context).size.width > 600;

    final header = widget.pendingSync != null
        ? PendingSyncIndicator(controller: widget.pendingSync!)
        : const SizedBox.shrink();

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
      body: Column(
        children: [
          header,
          Expanded(
            child: FutureBuilder<WorkOrderDetail>(
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
          ),
        ],
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
                const SizedBox(height: 4),
                Text(
                  img.woTaskUploadDesc,
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
    final src = img.documentSrc.startsWith('//')
        ? 'https:${img.documentSrc}'
        : img.documentSrc;
  final latitude = double.tryParse(img.woTaskUploadLatitude.toString());
  final longitude = double.tryParse(img.woTaskUploadLongitude.toString());

    void openViewer() {
      Navigator.push(
        context,
        MaterialPageRoute(builder: (_) => ImageViewer(url: src)),
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
                openViewer();
              },
            ),
            ListTile(
              leading: Icon(Icons.map),
              title: Text('Open Map'),
              onTap: () {
                Navigator.pop(context);
                if (latitude != null && longitude != null) {
                  _openMap(latitude, longitude);
                }
              },
            ),
          ],
        ),
      ),
    );
  }

  List<_FieldRow> _makeFields(WorkOrderDetail d) => [
    _FieldRow(Icons.request_page,         "Work Request No",         d.woTaskRequestNo),
    _FieldRow(Icons.confirmation_number,  "Work Order No",      d.woTaskNo),
    _FieldRow(Icons.person,               "Reported by",        d.woTaskReportedBy),
    _FieldRow(Icons.phone,                "Phone No",           d.woTaskPhoneNo),
    _FieldRow(Icons.email,                "Email",              d.woTaskEmail),
    _FieldRow(Icons.calendar_today,       "Reported Date/Time", d.woTaskTimeResponded),
    _FieldRow(Icons.category,             "Category",           d.woTaskCategory),
    _FieldRow(Icons.business,             "Client",             d.woTaskClient),
    _FieldRow(Icons.place,                "Location",           d.zoneName),
    _FieldRow(Icons.description,         "Description",        d.woTaskComplaint),
  ];

}

Future<void> _openMap(double lat, double lng) async {
  final String googleMapsUrl = 'https://www.google.com/maps/search/?api=1&query=$lat,$lng';
  final String appleMapsUrl = 'https://maps.apple.com/?q=$lat,$lng&sll=$lat,$lng&z=16';

  final Uri googleUri = Uri.parse(googleMapsUrl);
  final Uri appleUri = Uri.parse(appleMapsUrl);

  if (await canLaunchUrl(googleUri)) {
    await launchUrl(googleUri);
  } else if (await canLaunchUrl(appleUri)) {
    await launchUrl(appleUri);
  } else {
    throw 'Could not launch any map for $lat,$lng';
  }
}

class _FieldRow {
  final IconData icon;
  final String label;
  final String value;
  _FieldRow(this.icon, this.label, this.value);
}