import 'dart:async';

import 'package:flutter/material.dart';
import 'package:GEMS/controller/PPM/Form/openImage.dart';
import 'package:GEMS/controller/WorkOrder/pending_sync.dart';
import 'package:GEMS/controller/WorkOrder/widgets/pending_sync_banner.dart';
import 'package:GEMS/data/repository/work_order_detail_repository.dart';
import 'package:GEMS/model/workorder.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:GEMS/utils/biometric_lock_manager.dart';
// import 'package:GEMS/controller/Storekeeper/utils/constant.dart'; // for colorTheme2
import 'package:GEMS/utils/reference.dart';
import 'package:shimmer/shimmer.dart';
import '../../main.dart';

class ComplaintSectionA extends StatefulWidget {
  final bool viewer;
  final String id;
  final PendingSyncController? pendingSync;
  final Stream<WorkOrderSnapshotData?>? snapshotStream;
  final WorkOrderSnapshotData? initialSnapshot;

  const ComplaintSectionA({
    super.key,
    required this.id,
    this.viewer = false,
    this.pendingSync,
  this.snapshotStream,
    this.initialSnapshot,
  });

  @override
  _ComplaintSectionAState createState() => _ComplaintSectionAState(id);
}

class _ComplaintSectionAState extends State<ComplaintSectionA> {
  late final WorkOrderDetailRepository _repository;
  late Future<WorkOrderDetail?> _detailFuture;
  WorkOrderDetail? _snapshotDetail;
  StreamSubscription<WorkOrderSnapshotData?>? _snapshotSub;

  _ComplaintSectionAState(String id);

  @override
  void initState() {
    super.initState();
    _repository = WorkOrderDetailRepository();
    _snapshotDetail = widget.initialSnapshot?.complaintDetail;
    _detailFuture = _loadDetail();
  _snapshotSub = widget.snapshotStream?.listen((snapshot) {
      if (!mounted || snapshot == null || snapshot.complaintDetail == null) {
        return;
      }
      setState(() {
        _snapshotDetail = snapshot.complaintDetail;
      });
    });
  }

  Future<WorkOrderDetail?> _loadDetail({bool forceRefresh = false}) async {
    final detail = await _repository.getComplaintDetail(
      workOrderId: widget.id,
      forceRefresh: forceRefresh,
    );
    if (detail == null && forceRefresh) {
      throw Exception('Unable to load complaint details.');
    }
    return detail;
  }

  Future<void> _refreshDetail() async {
    setState(() {
      _detailFuture = _loadDetail(forceRefresh: true);
    });
    await _detailFuture;
  }

  @override
  void dispose() {
    _snapshotSub?.cancel();
    super.dispose();
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
            child: FutureBuilder<WorkOrderDetail?>(
              future: _detailFuture,
              builder: (ctx, snap) {
                if (snap.connectionState == ConnectionState.waiting &&
                    _snapshotDetail == null) {
                  return _buildLoadingPlaceholder(isWide);
                }
                final detail = snap.data ?? _snapshotDetail;
                if (snap.hasError && detail == null) {
                  return _buildErrorState(snap.error.toString());
                }
                if (detail == null) {
                  return _buildErrorState(
                    'Complaint details are not cached yet for offline use. Please reconnect and refresh.',
                  );
                }
                return isWide
                    ? _buildGrid(context, detail)
                    : _buildList(context, detail);
              },
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
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: colorTheme3.withOpacity(0.12),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(icon, color: colorTheme3),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    label,
                    style: const TextStyle(
                      fontSize: 12,
                      color: Colors.black54,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    value,
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildErrorState(String message) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.info_outline,
              size: 48,
              color: colorTheme3.withOpacity(0.6),
            ),
            const SizedBox(height: 16),
            Text(
              message,
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 14),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: _refreshDetail,
              style: ElevatedButton.styleFrom(
                backgroundColor: colorTheme2,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              child: const Text('Try Again'),
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

  // Use BiometricLockManager to prevent biometric prompt when returning from maps
  if (await canLaunchUrl(googleUri)) {
    await BiometricLockManager.launchExternalUrl(googleUri);
  } else if (await canLaunchUrl(appleUri)) {
    await BiometricLockManager.launchExternalUrl(appleUri);
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
