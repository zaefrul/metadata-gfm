import 'package:flutter/material.dart';
import 'package:GEMS/view/gems_chrome.dart';
import 'package:GEMS/controller/ReturnItem/bloc/bloc_return.dart';
import 'package:GEMS/model/return_ticket_models.dart';
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
        title: Text('Reject selected items', style: GemsChrome.heading(size: 18)),
        content: TextField(
          controller: _remarkController,
          maxLines: 3,
          style: GemsChrome.body(size: 14),
          decoration: gemsFieldDecoration(label: 'Rejection remark'),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, null),
            child: Text('Cancel', style: GemsChrome.body(color: GemsChrome.textSoft)),
          ),
          FilledButton(
            style: FilledButton.styleFrom(backgroundColor: GemsChrome.danger),
            onPressed: () {
              if (_remarkController.text.trim().isEmpty) {
                Toast.show('Remark is required when rejecting',
                    duration: Toast.lengthLong, gravity: Toast.bottom);
                return;
              }
              Navigator.pop(context, _remarkController.text.trim());
            },
            child: Text('Reject', style: GemsChrome.body(weight: FontWeight.w600, color: Colors.white)),
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
      backgroundColor: GemsChrome.page,
      appBar: gemsAppBar(
        title: const Text('Confirm Return'),
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
                return const Center(child: CircularProgressIndicator(color: GemsChrome.primary));
              }
              if (_ticket == null) {
                return _buildEmptyState();
              }

              return RefreshIndicator(
                onRefresh: _loadTicket,
                color: GemsChrome.primary,
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
    return DecoratedBox(
      decoration: BoxDecoration(
        color: GemsChrome.warningSoft,
        borderRadius: BorderRadius.circular(GemsChrome.radius),
        border: Border.all(color: GemsChrome.border),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(GemsChrome.radius),
              ),
              child: const Icon(Icons.pending_actions, color: GemsChrome.warning, size: 28),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Return ticket ${_ticket?.returnTicketId ?? ''}',
                    style: GemsChrome.body(
                      size: 13,
                      weight: FontWeight.w600,
                      color: GemsChrome.warning,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Awaiting storekeeper action',
                    style: GemsChrome.body(size: 13, color: GemsChrome.textSoft),
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
    return GemsFormSection(
      title: 'Ticket',
      icon: Icons.receipt_long_outlined,
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
            const Divider(height: 24, color: GemsChrome.border),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('Pending items', style: GemsChrome.body(size: 14, weight: FontWeight.w600)),
                Text(
                  '${_pendingItems.length}',
                  style: GemsChrome.heading(size: 22, color: GemsChrome.primary),
                ),
              ],
            )
          ],
        ),
    );
  }

  Widget _buildItemsCard() {
    final items = _ticket!.items;
    return GemsFormSection(
      title: 'Items',
      icon: Icons.list_alt_outlined,
      child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ...items.map(_buildItemTile).toList(),
          ],
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
        ? GemsChrome.success
        : item.isRejected
            ? GemsChrome.danger
            : GemsChrome.warning;
    final description = item.itemDescription.isNotEmpty
      ? item.itemDescription
      : 'Part ${item.partId}';

    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: DecoratedBox(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(GemsChrome.radius),
          border: Border.all(color: GemsChrome.border),
        ),
        child: ListTile(
          leading: isPending
              ? Checkbox(
                  value: isSelected,
                  activeColor: GemsChrome.primary,
                  onChanged: (_) => _toggleSelection(item.partSubId),
                )
              : Icon(
                  item.isApproved ? Icons.check_circle : Icons.cancel,
                  color: statusColor,
                ),
          onTap: isPending ? () => _toggleSelection(item.partSubId) : null,
          title: Text(description, style: GemsChrome.body(weight: FontWeight.w600)),
          subtitle: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 4),
              Text('Serial: ${item.partSubNo ?? item.partSubId}', style: GemsChrome.body(size: 12, color: GemsChrome.textSoft)),
              Text('Quantity: ${item.quantityReturned}', style: GemsChrome.body(size: 12, color: GemsChrome.textSoft)),
              Text('WO: ${item.woTaskNo}', style: GemsChrome.body(size: 12, color: GemsChrome.textSoft)),
              const SizedBox(height: 4),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                decoration: BoxDecoration(
                  color: statusColor.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  statusText,
                  style: GemsChrome.body(size: 11, weight: FontWeight.w600, color: statusColor),
                ),
              ),
              if (item.remark != null && item.remark!.isNotEmpty) ...[
                const SizedBox(height: 4),
                Text(
                  'Remark: ${item.remark!}',
                  style: GemsChrome.body(size: 12, color: GemsChrome.textSoft),
                ),
              ]
            ],
          ),
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
                  backgroundColor: GemsChrome.success,
                  foregroundColor: Colors.white,
                  disabledBackgroundColor: GemsChrome.success.withValues(alpha: 0.45),
                  disabledForegroundColor: Colors.white,
                  elevation: 0,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(GemsChrome.radius),
                  ),
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
                  backgroundColor: GemsChrome.danger,
                  foregroundColor: Colors.white,
                  disabledBackgroundColor: GemsChrome.danger.withValues(alpha: 0.45),
                  disabledForegroundColor: Colors.white,
                  elevation: 0,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(GemsChrome.radius),
                  ),
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
              style: GemsChrome.body(color: GemsChrome.textSoft),
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
          const Icon(Icons.inventory_2_outlined, size: 64, color: GemsChrome.muted),
          const SizedBox(height: 16),
          Text('Ticket not found', style: GemsChrome.heading(size: 18)),
          const SizedBox(height: 8),
          Text(
            'This return ticket may have been processed already.',
            style: GemsChrome.body(color: GemsChrome.textSoft),
          ),
        ],
      ),
    );
  }
  
  Widget _buildDetailRow(String label, String value, IconData icon) {
    return Padding(
      padding: EdgeInsets.only(bottom: 12),
      child: Row(
        children: [
          Icon(icon, size: 16, color: GemsChrome.primary),
          SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(label, style: GemsChrome.body(size: 12, color: GemsChrome.textSoft)),
                Text(value, style: GemsChrome.body(size: 14, weight: FontWeight.w600)),
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
