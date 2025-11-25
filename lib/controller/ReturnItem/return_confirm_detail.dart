import 'package:flutter/material.dart';
import 'package:GEMS/controller/ReturnItem/bloc/bloc_return.dart';
import 'package:GEMS/model/return_ticket_models.dart';
import 'package:GEMS/utils/reference.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:toast/toast.dart';
import 'package:intl/intl.dart';

class ReturnConfirmDetail extends StatefulWidget {
  final String returnId;
  
  const ReturnConfirmDetail({required this.returnId});
  
  @override
  _ReturnConfirmDetailState createState() => _ReturnConfirmDetailState();
}

class _ReturnConfirmDetailState extends State<ReturnConfirmDetail> {
  final ReturnItemBloc _bloc = ReturnItemBloc();
  final TextEditingController _remarkController = TextEditingController();

  ReturnTicketSummary? _ticket;
  final Set<String> _selectedPartSubs = <String>{};
  bool _isActionInProgress = false;

  @override
  void initState() {
    super.initState();
    _loadTicket();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    ToastContext().init(context);
  }

  Future<void> _loadTicket() async {
    try {
      final detail = await _bloc.refreshAndFind(widget.returnId);
      if (!mounted) return;
      setState(() {
        _ticket = detail;
        _selectedPartSubs
          ..clear()
          ..addAll(detail?.items
                  .where((item) => item.isPending)
                  .map((item) => item.partSubId) ??
              const <String>[]);
      });
    } catch (e) {
      Toast.show('Failed to load ticket details',
          duration: Toast.lengthLong, gravity: Toast.bottom);
    }
  }

  List<ReturnTicketItem> get _pendingItems => _ticket?.items
          .where((item) => item.isPending)
          .toList(growable: false) ??
      const <ReturnTicketItem>[];

  void _toggleSelection(String partSubId) {
    setState(() {
      if (_selectedPartSubs.contains(partSubId)) {
        _selectedPartSubs.remove(partSubId);
      } else {
        _selectedPartSubs.add(partSubId);
      }
    });
  }

  Future<void> _handleAction(String action, {String? remark}) async {
    if (_ticket == null) return;
    if (_selectedPartSubs.isEmpty) {
      Toast.show('Select at least one part first',
          duration: Toast.lengthLong, gravity: Toast.bottom);
      return;
    }

    setState(() => _isActionInProgress = true);
    try {
      final result = await _bloc.verifyTicket(
        ticketId: widget.returnId,
        action: action,
        partSubIds: _selectedPartSubs.toList(growable: false),
        remark: remark,
      );

      Toast.show(
        action == 'approve'
            ? '${result.approvedCount} item(s) approved'
            : '${result.rejectedCount} item(s) rejected',
        duration: Toast.lengthLong,
        gravity: Toast.bottom,
      );

      await _loadTicket();
    } catch (e) {
      Toast.show(e.toString(), duration: Toast.lengthLong, gravity: Toast.bottom);
    } finally {
      if (mounted) {
        setState(() => _isActionInProgress = false);
      }
    }
  }

  Future<void> _promptReject() async {
    _remarkController.clear();
    final remark = await showDialog<String?>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Reject Selected Items', style: GoogleFonts.poppins()),
        content: TextField(
          controller: _remarkController,
          maxLines: 3,
          decoration: InputDecoration(
            hintText: 'Enter rejection remark (required)',
            border: OutlineInputBorder(),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, null),
            child: Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              if (_remarkController.text.trim().isEmpty) {
                Toast.show('Remark is required when rejecting',
                    duration: Toast.lengthLong, gravity: Toast.bottom);
                return;
              }
              Navigator.pop(context, _remarkController.text.trim());
            },
            child: Text('Reject'),
          )
        ],
      ),
    );

    if (remark != null && remark.isNotEmpty) {
      await _handleAction('reject', remark: remark);
    }
  }

  bool get _hasPendingSelection =>
      _selectedPartSubs.isNotEmpty && _pendingItems.isNotEmpty;
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bgDefault,
      appBar: AppBar(
        title: Text('Confirm Return', style: GoogleFonts.poppins(fontWeight: FontWeight.w600)),
        backgroundColor: AppColors.primary,
        elevation: 0,
        foregroundColor: AppColors.onPrimary,
      ),
      body: StreamBuilder<String>(
        stream: _bloc.err$,
        builder: (context, errSnapshot) {
          if (errSnapshot.hasData && errSnapshot.data!.isNotEmpty) {
            WidgetsBinding.instance.addPostFrameCallback((_) {
              Toast.show(errSnapshot.data!, duration: Toast.lengthLong, gravity: Toast.bottom);
            });
          }
          
          return StreamBuilder<bool>(
            stream: _bloc.loadingState$,
            builder: (context, loadingSnapshot) {
              bool isLoading = loadingSnapshot.data ?? false;
              
              if (isLoading && _ticket == null) {
                return Center(child: CircularProgressIndicator(color: AppColors.primary));
              }
              if (_ticket == null) {
                return _buildEmptyState();
              }

              return RefreshIndicator(
                onRefresh: _loadTicket,
                color: AppColors.primary,
                child: ListView(
                  padding: EdgeInsets.all(16),
                  physics: const AlwaysScrollableScrollPhysics(),
                  children: [
                    _buildStatusCard(),
                    SizedBox(height: 16),
                    _buildSummaryCard(),
                    SizedBox(height: 16),
                    _buildItemsCard(),
                    SizedBox(height: 24),
                    _buildActionButtons(),
                  ],
                ),
              );
            },
          );
        },
      ),
    );
  }
  
  Widget _buildStatusCard() {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Container(
        padding: EdgeInsets.all(20),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [AppColors.warningLight, AppColors.warningLight.withOpacity(0.5)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          children: [
            Container(
              padding: EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: AppColors.white,
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(Icons.pending_actions, color: AppColors.warning, size: 32),
            ),
            SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'RETURN TICKET ${_ticket?.returnTicketId ?? ''}',
                    style: GoogleFonts.poppins(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: AppColors.warningDark,
                      letterSpacing: 0.5,
                    ),
                  ),
                  SizedBox(height: 4),
                  Text(
                    'Awaiting storekeeper action',
                    style: GoogleFonts.poppins(
                      fontSize: 13,
                      color: AppColors.textSecondary,
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
  
  Widget _buildSummaryCard() {
    final ticket = _ticket!;
    final ReturnTicketItem? firstItem =
        ticket.items.isNotEmpty ? ticket.items.first : null;

    String _fallback(String primary, String? secondary, {String placeholder = '-'}) {
      if (primary.trim().isNotEmpty) return primary;
      if (secondary != null && secondary.trim().isNotEmpty) return secondary;
      return placeholder;
    }

    final technicianName = _fallback(ticket.technicianName, null);
    final workOrder = _fallback(ticket.woTaskNo, firstItem?.woTaskNo);
    final materialRequest =
        _fallback(ticket.woTaskRequestNo, firstItem?.woTaskRequestNo);
    final siteName = _fallback(ticket.siteName, null);
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildDetailRow('Technician', technicianName, Icons.person),
            _buildDetailRow('Work Order', workOrder, Icons.description),
            _buildDetailRow('Material Request', materialRequest, Icons.list_alt),
            _buildDetailRow('Site', siteName, Icons.location_on),
            _buildDetailRow(
              'Submitted',
              DateFormat('dd MMM yyyy, HH:mm').format(ticket.submittedAt ?? DateTime.now()),
              Icons.schedule,
            ),
            Divider(height: 24),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('Pending Items',
                    style: GoogleFonts.poppins(
                        fontSize: 14, fontWeight: FontWeight.w600)),
                Text('${_pendingItems.length}',
                    style: GoogleFonts.poppins(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                        color: AppColors.primary)),
              ],
            )
          ],
        ),
      ),
    );
  }

  Widget _buildItemsCard() {
    final items = _ticket!.items;
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(8),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
              child: Text('Items',
                  style: GoogleFonts.poppins(
                      fontSize: 16, fontWeight: FontWeight.w600)),
            ),
            ...items.map(_buildItemTile).toList(),
          ],
        ),
      ),
    );
  }

  Widget _buildItemTile(ReturnTicketItem item) {
    final isPending = item.isPending;
    final isSelected = _selectedPartSubs.contains(item.partSubId);
    final statusText = item.isPending
        ? 'Pending verification'
        : item.isApproved
            ? 'Approved'
            : 'Rejected';
    final statusColor = item.isApproved
        ? AppColors.success
        : item.isRejected
            ? AppColors.danger
            : AppColors.warning;
    final description = item.itemDescription.isNotEmpty
      ? item.itemDescription
      : 'Part ${item.partId}';

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: ListTile(
        leading: isPending
            ? Checkbox(
                value: isSelected,
                onChanged: (_) => _toggleSelection(item.partSubId),
              )
            : Icon(
                item.isApproved ? Icons.check_circle : Icons.cancel,
                color: statusColor,
              ),
        onTap: isPending ? () => _toggleSelection(item.partSubId) : null,
      title: Text(description,
            style: GoogleFonts.poppins(fontWeight: FontWeight.w600)),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(height: 4),
            Text('Serial: ${item.partSubNo ?? item.partSubId}',
                style: GoogleFonts.poppins(fontSize: 12)),
            Text('Quantity: ${item.quantityReturned}',
                style: GoogleFonts.poppins(fontSize: 12)),
            Text('WO: ${item.woTaskNo}',
                style: GoogleFonts.poppins(fontSize: 12)),
            SizedBox(height: 4),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
              decoration: BoxDecoration(
                color: statusColor.withOpacity(0.12),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                statusText,
                style: GoogleFonts.poppins(fontSize: 11, color: statusColor),
              ),
            ),
            if (item.remark != null && item.remark!.isNotEmpty) ...[
              SizedBox(height: 4),
              Text('Remark: ${item.remark!}',
                  style: GoogleFonts.poppins(fontSize: 12, fontStyle: FontStyle.italic)),
            ]
          ],
        ),
      ),
    );
  }

  Widget _buildActionButtons() {
    final canAct = _hasPendingSelection && !_isActionInProgress;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Row(
          children: [
            Expanded(
              child: ElevatedButton.icon(
                onPressed: canAct ? () => _handleAction('approve') : null,
                icon: Icon(Icons.check),
                label: Text('Approve Selected'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.success,
                  foregroundColor: AppColors.white,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                ),
              ),
            ),
            SizedBox(width: 12),
            Expanded(
              child: ElevatedButton.icon(
                onPressed: canAct ? _promptReject : null,
                icon: Icon(Icons.close),
                label: Text('Reject Selected'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.danger,
                  foregroundColor: AppColors.white,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                ),
              ),
            ),
          ],
        ),
        if (_pendingItems.isEmpty)
          Padding(
            padding: const EdgeInsets.only(top: 12),
            child: Text(
              'No pending items left in this ticket.',
              style: GoogleFonts.poppins(color: AppColors.gray600),
            ),
          ),
      ],
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.inventory, size: 72, color: AppColors.gray400),
          SizedBox(height: 16),
          Text('Ticket not found',
              style: GoogleFonts.poppins(fontSize: 18, fontWeight: FontWeight.w600)),
          SizedBox(height: 8),
          Text('This return ticket may have been processed already.',
              style: GoogleFonts.poppins(color: AppColors.gray600)),
        ],
      ),
    );
  }
  
  Widget _buildDetailRow(String label, String value, IconData icon) {
    return Padding(
      padding: EdgeInsets.only(bottom: 12),
      child: Row(
        children: [
          Icon(icon, size: 16, color: AppColors.gray600),
          SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: GoogleFonts.poppins(
                    fontSize: 11,
                    color: AppColors.textSecondary,
                  ),
                ),
                Text(
                  value,
                  style: GoogleFonts.poppins(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textPrimary,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
  
  @override
  void dispose() {
    _bloc.dispose();
    _remarkController.dispose();
    super.dispose();
  }
}
