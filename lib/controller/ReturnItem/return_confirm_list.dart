import 'package:flutter/material.dart';
import 'package:GEMS/controller/ReturnItem/bloc/bloc_return.dart';
import 'package:GEMS/model/return_ticket_models.dart';
import 'package:GEMS/utils/reference.dart';
import 'package:google_fonts/google_fonts.dart';
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
      backgroundColor: AppColors.bgDefault,
      appBar: AppBar(
        title: Row(
          children: [
            Text('Pending Returns', style: GoogleFonts.poppins(fontWeight: FontWeight.w600)),
            SizedBox(width: 8),
            StreamBuilder<int>(
              stream: _bloc.pendingCount$,
              builder: (context, snapshot) {
                int count = snapshot.data ?? 0;
                if (count == 0) return SizedBox.shrink();
                
                return Container(
                  padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: AppColors.danger,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    count.toString(),
                    style: GoogleFonts.poppins(
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      color: AppColors.white,
                    ),
                  ),
                );
              },
            ),
          ],
        ),
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
              
              return StreamBuilder<List<ReturnTicketSummary>>(
                stream: _bloc.pendingReturns$,
                builder: (context, snapshot) {
                  if (isLoading && (!snapshot.hasData || snapshot.data!.isEmpty)) {
                    return Center(child: CircularProgressIndicator(color: AppColors.primary));
                  }
                  
                  List<ReturnTicketSummary> returns = snapshot.data ?? [];
                  
                  if (returns.isEmpty) {
                    return _buildEmptyState();
                  }
                  
                  return RefreshIndicator(
                    onRefresh: _refresh,
                    color: AppColors.primary,
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
          Icon(Icons.check_circle_outline, size: 80, color: AppColors.success),
          SizedBox(height: 16),
          Text(
            'All Caught Up!',
            style: GoogleFonts.poppins(fontSize: 18, color: AppColors.gray600, fontWeight: FontWeight.w500),
          ),
          SizedBox(height: 8),
          Text(
            'No pending returns to confirm',
            style: GoogleFonts.poppins(fontSize: 14, color: AppColors.gray500),
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
    return Card(
      margin: EdgeInsets.only(bottom: 12),
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: () => _navigateToDetail(ticket.returnTicketId),
        child: Padding(
          padding: EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header with priority indicator
              Row(
                children: [
                  Container(
                    width: 4,
                    height: 40,
                    decoration: BoxDecoration(
                      color: _getPriorityColor(submitted),
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                  SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          workOrderLabel,
                          style: GoogleFonts.poppins(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            color: AppColors.textPrimary,
                          ),
                        ),
                        SizedBox(height: 2),
                        Text(
                          subtitle,
                          style: GoogleFonts.poppins(
                              fontSize: 12, color: AppColors.textSecondary),
                        ),
                      ],
                    ),
                  ),
                  Icon(Icons.arrow_forward_ios, size: 16, color: AppColors.gray400),
                ],
              ),
              SizedBox(height: 12),
              
              // Technician info
              Container(
                padding: EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: AppColors.primary50,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  children: [
                    Icon(Icons.person, size: 16, color: AppColors.primary),
                    SizedBox(width: 8),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            ticket.siteName,
                            style: GoogleFonts.poppins(
                              fontSize: 10,
                              color: AppColors.primary,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          Text(
                            ticket.technicianName,
                            style: GoogleFonts.poppins(
                              fontSize: 13,
                              color: AppColors.textPrimary,
                              fontWeight: FontWeight.w600,
                            ),
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
                      Icon(Icons.schedule, size: 14, color: AppColors.gray500),
                      SizedBox(width: 4),
                      Text(
                        'Submitted: ${_formatDate(submitted)}',
                        style: GoogleFonts.poppins(fontSize: 11, color: AppColors.gray600),
                      ),
                    ],
                  ),
                  Container(
                    padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: AppColors.warningLight,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      _getTimeAgo(submitted),
                      style: GoogleFonts.poppins(
                        fontSize: 10,
                        color: AppColors.warningDark,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
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
          style: GoogleFonts.poppins(fontSize: 11, color: AppColors.gray600),
        ),
        SizedBox(height: 4),
        Container(
          width: double.infinity,
          padding: EdgeInsets.symmetric(horizontal: 12, vertical: 10),
          decoration: BoxDecoration(
            color: AppColors.primary50,
            borderRadius: BorderRadius.circular(8),
          ),
          child: Text(
            wo,
            style: GoogleFonts.poppins(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: AppColors.primary,
            ),
          ),
        ),
        SizedBox(height: 10),
        Text(
          'Material Request',
          style: GoogleFonts.poppins(fontSize: 11, color: AppColors.gray600),
        ),
        SizedBox(height: 4),
        Container(
          width: double.infinity,
          padding: EdgeInsets.symmetric(horizontal: 12, vertical: 10),
          decoration: BoxDecoration(
            color: AppColors.primary50,
            borderRadius: BorderRadius.circular(8),
          ),
          child: Text(
            mr,
            style: GoogleFonts.poppins(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: AppColors.primary,
            ),
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
    final Color bgColor = AppColors.primary50;
    final Color iconColor = AppColors.primary;
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
                  style: GoogleFonts.poppins(
                    fontSize: 10,
                    color: iconColor.withOpacity(0.8),
                  ),
                ),
                Text(
                  value,
                  style: GoogleFonts.poppins(
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    color: iconColor,
                  ),
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
    if (date == null) return AppColors.gray400;
    final diff = DateTime.now().difference(date);
    if (diff.inHours < 24) return AppColors.success;
    if (diff.inDays < 3) return AppColors.warning;
    return AppColors.danger;
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
