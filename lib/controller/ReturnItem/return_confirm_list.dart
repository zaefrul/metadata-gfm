import 'package:flutter/material.dart';
import 'package:GEMS/view/gems_chrome.dart';
import 'package:GEMS/controller/ReturnItem/bloc/bloc_return.dart';
import 'package:GEMS/model/return_ticket_models.dart';
import 'package:toast/toast.dart';
import 'package:intl/intl.dart';

class ReturnConfirmList extends StatefulWidget {
  @override
  _ReturnConfirmListState createState() => _ReturnConfirmListState();
}

class _ReturnConfirmListState extends State<ReturnConfirmList> {
  final ReturnItemBloc _bloc = ReturnItemBloc();
  
  @override
  void initState() {
    super.initState();
    _bloc.loadPendingReturns();
  }
  
  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    ToastContext().init(context);
  }
  
  Future<void> _refresh() async {
    await _bloc.loadPendingReturns();
  }
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: GemsChrome.page,
      appBar: gemsAppBar(
        title: Row(
          children: [
            Text('Pending Returns', style: GemsChrome.heading(size: 18)),
            SizedBox(width: 8),
            StreamBuilder<int>(
              stream: _bloc.pendingCount$,
              builder: (context, snapshot) {
                int count = snapshot.data ?? 0;
                if (count == 0) return SizedBox.shrink();
                
                return Container(
                  padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: GemsChrome.danger,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    count.toString(),
                    style: GemsChrome.body(
                      size: 12,
                      weight: FontWeight.w700,
                      color: Colors.white,
                    ),
                  ),
                );
              },
            ),
          ],
        ),
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
              
              return StreamBuilder<List<ReturnTicketSummary>>(
                stream: _bloc.pendingReturns$,
                builder: (context, snapshot) {
                  if (isLoading && (!snapshot.hasData || snapshot.data!.isEmpty)) {
                    return const Center(child: CircularProgressIndicator(color: GemsChrome.primary));
                  }
                  
                  List<ReturnTicketSummary> returns = snapshot.data ?? [];
                  
                  if (returns.isEmpty) {
                    return _buildEmptyState();
                  }
                  
                  return RefreshIndicator(
                    onRefresh: _refresh,
                    color: GemsChrome.primary,
                    child: ListView.builder(
                      padding: EdgeInsets.all(16),
                      itemCount: returns.length,
                      itemBuilder: (context, index) {
                        return _buildReturnCard(returns[index]);
                      },
                    ),
                  );
                },
              );
            },
          );
        },
      ),
    );
  }
  
  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.check_circle_outline, size: 64, color: GemsChrome.success),
          const SizedBox(height: 16),
          Text(
            'All caught up',
            style: GemsChrome.heading(size: 18),
          ),
          const SizedBox(height: 8),
          Text(
            'No pending returns to confirm',
            style: GemsChrome.body(color: GemsChrome.textSoft),
          ),
        ],
      ),
    );
  }
  
  Widget _buildReturnCard(ReturnTicketSummary ticket) {
    debugPrint('Building card for ticket ID: ${ticket.returnTicketId}, Items: ${ticket.items.length}, woTaskNo: ${ticket.woTaskNo}');
    final ReturnTicketItem? firstItem =
      ticket.items.isNotEmpty ? ticket.items.first : null;
    final String subtitle =
      (firstItem != null && firstItem.itemDescription.isNotEmpty)
        ? firstItem.itemDescription
        : 'Pending items';
    final String workOrderLabel =
      ticket.woTaskNo.isNotEmpty ? ticket.woTaskNo : 'Work Order Pending';
    final DateTime? submitted = ticket.submittedAt;
    return GemsAccentCard(
      margin: const EdgeInsets.only(bottom: 10),
      accent: _getPriorityColor(submitted),
      onTap: () => _navigateToDetail(ticket.returnTicketId),
      child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          workOrderLabel,
                          style: GemsChrome.body(size: 15, weight: FontWeight.w600),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          subtitle,
                          style: GemsChrome.body(size: 12, color: GemsChrome.textSoft),
                        ),
                      ],
                    ),
                  ),
                  const Icon(Icons.chevron_right, size: 20, color: GemsChrome.muted),
                ],
              ),
              SizedBox(height: 12),
              
              // Technician info
              Container(
                padding: EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: GemsChrome.primarySoft,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.person_outline, size: 16, color: GemsChrome.primary),
                    SizedBox(width: 8),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            ticket.siteName,
                            style: GemsChrome.body(size: 11, weight: FontWeight.w500, color: GemsChrome.primary),
                          ),
                          Text(
                            ticket.technicianName,
                            style: GemsChrome.body(size: 13, weight: FontWeight.w600),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(height: 12),
              _buildOrderMetadata(ticket),

              SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: _buildInfoChip(
                      label: 'Items Pending',
                      value: ticket.itemCount.toString(),
                      icon: Icons.inventory_2,
                    ),
                  ),
                  SizedBox(width: 8),
                  Expanded(
                    child: _buildInfoChip(
                      label: 'Part Subs',
                      value: ticket.partSubIds.length.toString(),
                      icon: Icons.qr_code_2,
                    ),
                  ),
                ],
              ),

              SizedBox(height: 12),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      const Icon(Icons.schedule, size: 14, color: GemsChrome.muted),
                      const SizedBox(width: 4),
                      Text(
                        'Submitted: ${_formatDate(submitted)}',
                        style: GemsChrome.body(size: 11, color: GemsChrome.textSoft),
                      ),
                    ],
                  ),
                  Container(
                    padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: GemsChrome.warningSoft,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      _getTimeAgo(submitted),
                      style: GemsChrome.body(
                        size: 11,
                        weight: FontWeight.w600,
                        color: GemsChrome.warning,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
    );
  }
  
  Widget _buildOrderMetadata(ReturnTicketSummary ticket) {
    final wo = ticket.woTaskNo.isNotEmpty ? ticket.woTaskNo : 'N/A';
    final mr = ticket.woTaskRequestNo.isNotEmpty ? ticket.woTaskRequestNo : 'N/A';
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Work Order',
          style: GemsChrome.body(size: 11, color: GemsChrome.textSoft),
        ),
        SizedBox(height: 4),
        Container(
          width: double.infinity,
          padding: EdgeInsets.symmetric(horizontal: 12, vertical: 10),
          decoration: BoxDecoration(
            color: GemsChrome.primarySoft,
            borderRadius: BorderRadius.circular(8),
          ),
          child: Text(
            wo,
            style: GemsChrome.body(size: 13, weight: FontWeight.w600, color: GemsChrome.primary),
          ),
        ),
        SizedBox(height: 10),
        Text(
          'Material Request',
          style: GemsChrome.body(size: 11, color: GemsChrome.textSoft),
        ),
        SizedBox(height: 4),
        Container(
          width: double.infinity,
          padding: EdgeInsets.symmetric(horizontal: 12, vertical: 10),
          decoration: BoxDecoration(
            color: GemsChrome.primarySoft,
            borderRadius: BorderRadius.circular(8),
          ),
          child: Text(
            mr,
            style: GemsChrome.body(size: 13, weight: FontWeight.w600, color: GemsChrome.primary),
          ),
        ),
      ],
    );
  }

  Widget _buildInfoChip({
    required String label,
    required String value,
    required IconData icon,
  }) {
    const Color bgColor = GemsChrome.primarySoft;
    const Color iconColor = GemsChrome.primary;
    return Container(
      padding: EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        children: [
          Icon(icon, size: 16, color: iconColor),
          SizedBox(width: 6),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: GemsChrome.body(size: 11, color: GemsChrome.textSoft),
                ),
                Text(
                  value,
                  style: GemsChrome.body(size: 12, weight: FontWeight.w700, color: iconColor),
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
  
  Color _getPriorityColor(DateTime? date) {
    if (date == null) return GemsChrome.muted;
    final diff = DateTime.now().difference(date);
    if (diff.inHours < 24) return GemsChrome.success;
    if (diff.inDays < 3) return GemsChrome.warning;
    return GemsChrome.danger;
  }

  String _formatDate(DateTime? date) {
    if (date == null) return 'N/A';
    return DateFormat('dd MMM yyyy, HH:mm').format(date);
  }

  String _getTimeAgo(DateTime? date) {
    if (date == null) return '';
    final diff = DateTime.now().difference(date);
    if (diff.inMinutes < 60) return '${diff.inMinutes}m ago';
    if (diff.inHours < 24) return '${diff.inHours}h ago';
    if (diff.inDays < 7) return '${diff.inDays}d ago';
    return '${(diff.inDays / 7).floor()}w ago';
  }

  void _navigateToDetail(String ticketId) {
    Navigator.pushNamed(
      context,
      '/return-confirm-detail',
      arguments: ticketId,
    ).then((_) => _refresh());
  }
  
  @override
  void dispose() {
    _bloc.dispose();
    super.dispose();
  }
}
