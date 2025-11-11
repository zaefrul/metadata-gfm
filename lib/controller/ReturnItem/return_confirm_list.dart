import 'package:flutter/material.dart';
import 'package:GEMS/controller/ReturnItem/bloc/bloc_return.dart';
import 'package:GEMS/model/return_item.dart';
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
              
              return StreamBuilder<List<PendingReturn>>(
                stream: _bloc.pendingReturns$,
                builder: (context, snapshot) {
                  if (isLoading && (!snapshot.hasData || snapshot.data!.isEmpty)) {
                    return Center(child: CircularProgressIndicator(color: AppColors.primary));
                  }
                  
                  List<PendingReturn> returns = snapshot.data ?? [];
                  
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
  
  Widget _buildReturnCard(PendingReturn item) {
    return Card(
      margin: EdgeInsets.only(bottom: 12),
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: () => _navigateToDetail(item),
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
                      color: _getPriorityColor(item.returnRequestDate),
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                  SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          item.partName ?? 'Unknown Item',
                          style: GoogleFonts.poppins(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            color: AppColors.textPrimary,
                          ),
                        ),
                        SizedBox(height: 2),
                        Text(
                          'Code: ${item.partCode ?? 'N/A'}',
                          style: GoogleFonts.poppins(
                            fontSize: 12,
                            color: AppColors.textSecondary,
                          ),
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
                            'Technician',
                            style: GoogleFonts.poppins(
                              fontSize: 10,
                              color: AppColors.primary,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          Text(
                            item.technicianName ?? 'Unknown',
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
              
              // Return details grid
              Row(
                children: [
                  Expanded(
                    child: _buildInfoChip(
                      'Quantity',
                      (item.quantityReturned ?? 0).toString(),
                      Icons.inventory_2,
                      AppColors.accentLight,
                      AppColors.accent,
                    ),
                  ),
                  SizedBox(width: 8),
                  Expanded(
                    child: _buildInfoChip(
                      'WO',
                      item.workOrderNo ?? 'N/A',
                      Icons.description,
                      AppColors.infoLight,
                      AppColors.info,
                    ),
                  ),
                ],
              ),
              SizedBox(height: 12),
              
              // Return reason
              Row(
                children: [
                  Container(
                    padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: _getReasonColor(item.returnReason).withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(6),
                      border: Border.all(
                        color: _getReasonColor(item.returnReason),
                        width: 1,
                      ),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          _getReasonIcon(item.returnReason),
                          size: 14,
                          color: _getReasonColor(item.returnReason),
                        ),
                        SizedBox(width: 4),
                        Text(
                          _formatReason(item.returnReason),
                          style: GoogleFonts.poppins(
                            fontSize: 11,
                            color: _getReasonColor(item.returnReason),
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              
              // Remarks (if any)
              if (item.returnRemarks != null && item.returnRemarks!.isNotEmpty) ...[
                SizedBox(height: 10),
                Container(
                  padding: EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: AppColors.gray100,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Icon(Icons.comment, size: 14, color: AppColors.gray600),
                      SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          item.returnRemarks!,
                          style: GoogleFonts.poppins(
                            fontSize: 12,
                            color: AppColors.textSecondary,
                            fontStyle: FontStyle.italic,
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
              
              SizedBox(height: 12),
              
              // Footer: Request date
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      Icon(Icons.schedule, size: 14, color: AppColors.gray500),
                      SizedBox(width: 4),
                      Text(
                        'Requested: ${_formatDate(item.returnRequestDate)}',
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
                      _getTimeAgo(item.returnRequestDate),
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
  
  Widget _buildInfoChip(String label, String value, IconData icon, Color bgColor, Color iconColor) {
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
                    color: iconColor.withValues(alpha: 0.8),
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
  
  Color _getPriorityColor(String? requestDate) {
    if (requestDate == null) return AppColors.gray400;
    
    try {
      DateTime date = DateTime.parse(requestDate);
      Duration diff = DateTime.now().difference(date);
      
      if (diff.inHours < 24) return AppColors.success; // Recent
      if (diff.inDays < 3) return AppColors.warning; // Normal
      return AppColors.danger; // Urgent
    } catch (e) {
      return AppColors.gray400;
    }
  }
  
  Color _getReasonColor(String? reason) {
    switch (reason) {
      case 'unused_excess':
        return AppColors.info;
      case 'wrong_part':
        return AppColors.warning;
      case 'damaged':
        return AppColors.danger;
      default:
        return AppColors.gray600;
    }
  }
  
  IconData _getReasonIcon(String? reason) {
    switch (reason) {
      case 'unused_excess':
        return Icons.inventory;
      case 'wrong_part':
        return Icons.error_outline;
      case 'damaged':
        return Icons.warning;
      default:
        return Icons.help_outline;
    }
  }
  
  String _formatReason(String? reason) {
    switch (reason) {
      case 'unused_excess':
        return 'Unused / Excess';
      case 'wrong_part':
        return 'Wrong Part';
      case 'damaged':
        return 'Damaged';
      case 'other':
        return 'Other';
      default:
        return reason ?? 'Unknown';
    }
  }
  
  String _formatDate(String? dateStr) {
    if (dateStr == null || dateStr.isEmpty) return 'N/A';
    try {
      DateTime date = DateTime.parse(dateStr);
      return DateFormat('dd MMM yyyy, HH:mm').format(date);
    } catch (e) {
      return dateStr;
    }
  }
  
  String _getTimeAgo(String? dateStr) {
    if (dateStr == null) return '';
    
    try {
      DateTime date = DateTime.parse(dateStr);
      Duration diff = DateTime.now().difference(date);
      
      if (diff.inMinutes < 60) return '${diff.inMinutes}m ago';
      if (diff.inHours < 24) return '${diff.inHours}h ago';
      if (diff.inDays < 7) return '${diff.inDays}d ago';
      return '${(diff.inDays / 7).floor()}w ago';
    } catch (e) {
      return '';
    }
  }
  
  void _navigateToDetail(PendingReturn item) {
    Navigator.pushNamed(
      context,
      '/return-confirm-detail',
      arguments: item.returnId,
    ).then((_) => _refresh());
  }
  
  @override
  void dispose() {
    _bloc.dispose();
    super.dispose();
  }
}
