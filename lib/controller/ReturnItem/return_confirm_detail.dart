import 'package:flutter/material.dart';
import 'package:GEMS/controller/ReturnItem/bloc/bloc_return.dart';
import 'package:GEMS/model/return_item.dart';
import 'package:GEMS/utils/reference.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:toast/toast.dart';
import 'package:intl/intl.dart';

class ReturnConfirmDetail extends StatefulWidget {
  final int returnId;
  
  const ReturnConfirmDetail({required this.returnId});
  
  @override
  _ReturnConfirmDetailState createState() => _ReturnConfirmDetailState();
}

class _ReturnConfirmDetailState extends State<ReturnConfirmDetail> {
  final ReturnItemBloc _bloc = ReturnItemBloc();
  PendingReturn? _returnDetail;
  bool _isConfirming = false;
  
  @override
  void initState() {
    super.initState();
    _loadDetail();
  }
  
  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    ToastContext().init(context);
  }
  
  Future<void> _loadDetail() async {
    try {
      PendingReturn? detail = await _bloc.getReturnDetail(widget.returnId.toString());
      setState(() {
        _returnDetail = detail;
      });
    } catch (e) {
      Toast.show('Failed to load return details', duration: Toast.lengthLong, gravity: Toast.bottom);
    }
  }
  
  Future<void> _confirmReturn() async {
    if (_returnDetail == null) return;
    
    // Show confirmation dialog
    bool? confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Confirm Return Receipt', style: GoogleFonts.poppins()),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Are you sure you want to confirm receipt of this return?',
              style: GoogleFonts.poppins(fontSize: 14),
            ),
            SizedBox(height: 16),
            Container(
              padding: EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: AppColors.warningLight,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: AppColors.warning, width: 1),
              ),
              child: Row(
                children: [
                  Icon(Icons.info_outline, color: AppColors.warningDark, size: 20),
                  SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'This action will update the inventory and cannot be undone.',
                      style: GoogleFonts.poppins(
                        fontSize: 12,
                        color: AppColors.warningDark,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(height: 12),
            _buildConfirmationDetail('Item', _returnDetail!.partName ?? 'N/A'),
            _buildConfirmationDetail('Quantity', (_returnDetail!.quantityReturned ?? 0).toString()),
            _buildConfirmationDetail('Technician', _returnDetail!.technicianName ?? 'N/A'),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text('Cancel', style: GoogleFonts.poppins(color: AppColors.gray600)),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.success,
              foregroundColor: AppColors.white,
            ),
            child: Text('Confirm Receipt', style: GoogleFonts.poppins(fontWeight: FontWeight.w600)),
          ),
        ],
      ),
    );
    
    if (confirmed != true) return;
    
    setState(() {
      _isConfirming = true;
    });
    
    try {
      await _bloc.confirmReturn(widget.returnId.toString());
      Toast.show('Return confirmed successfully!', duration: Toast.lengthLong, gravity: Toast.bottom);
      Navigator.pop(context, true); // Return with success flag
    } catch (e) {
      Toast.show('Failed to confirm return: ${e.toString()}', duration: Toast.lengthLong, gravity: Toast.bottom);
      setState(() {
        _isConfirming = false;
      });
    }
  }
  
  Widget _buildConfirmationDetail(String label, String value) {
    return Padding(
      padding: EdgeInsets.only(bottom: 6),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            '$label:',
            style: GoogleFonts.poppins(fontSize: 12, color: AppColors.gray600),
          ),
          Text(
            value,
            style: GoogleFonts.poppins(fontSize: 12, fontWeight: FontWeight.w600),
          ),
        ],
      ),
    );
  }
  
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
              
              if (isLoading || _returnDetail == null) {
                return Center(child: CircularProgressIndicator(color: AppColors.primary));
              }
              
              return SingleChildScrollView(
                padding: EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    _buildStatusCard(),
                    SizedBox(height: 16),
                    _buildItemDetailsCard(),
                    SizedBox(height: 16),
                    _buildTechnicianCard(),
                    SizedBox(height: 16),
                    _buildReturnInfoCard(),
                    if (_returnDetail!.returnRemarks != null && _returnDetail!.returnRemarks!.isNotEmpty) ...[
                      SizedBox(height: 16),
                      _buildRemarksCard(),
                    ],
                    SizedBox(height: 16),
                    _buildTimelineCard(),
                    SizedBox(height: 24),
                    _buildConfirmButton(),
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
            colors: [AppColors.warningLight, AppColors.warningLight.withValues(alpha: 0.5)],
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
                    'PENDING CONFIRMATION',
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
  
  Widget _buildItemDetailsCard() {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.inventory_2, color: AppColors.primary, size: 20),
                SizedBox(width: 8),
                Text(
                  'Item Details',
                  style: GoogleFonts.poppins(fontSize: 16, fontWeight: FontWeight.w600),
                ),
              ],
            ),
            SizedBox(height: 16),
            _buildDetailRow('Item Name', _returnDetail!.partName ?? 'N/A', Icons.label),
            _buildDetailRow('Part Code', _returnDetail!.partCode ?? 'N/A', Icons.qr_code),
            _buildDetailRow('Unit', _returnDetail!.partUnit ?? 'N/A', Icons.scale),
            Divider(height: 24),
            Container(
              padding: EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: AppColors.accentLight,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      Icon(Icons.numbers, color: AppColors.accent, size: 20),
                      SizedBox(width: 8),
                      Text(
                        'Return Quantity',
                        style: GoogleFonts.poppins(
                          fontSize: 14,
                          color: AppColors.accent,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                  Text(
                    (_returnDetail!.quantityReturned ?? 0).toString(),
                    style: GoogleFonts.poppins(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: AppColors.accent,
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
  
  Widget _buildTechnicianCard() {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.person, color: AppColors.primary, size: 20),
                SizedBox(width: 8),
                Text(
                  'Technician Information',
                  style: GoogleFonts.poppins(fontSize: 16, fontWeight: FontWeight.w600),
                ),
              ],
            ),
            SizedBox(height: 16),
            _buildDetailRow('Name', _returnDetail!.technicianName ?? 'N/A', Icons.badge),
            _buildDetailRow('Work Order', _returnDetail!.workOrderNo ?? 'N/A', Icons.description),
            _buildDetailRow('Site', _returnDetail!.siteName ?? 'N/A', Icons.location_on),
          ],
        ),
      ),
    );
  }
  
  Widget _buildReturnInfoCard() {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.info, color: AppColors.primary, size: 20),
                SizedBox(width: 8),
                Text(
                  'Return Information',
                  style: GoogleFonts.poppins(fontSize: 16, fontWeight: FontWeight.w600),
                ),
              ],
            ),
            SizedBox(height: 16),
            Container(
              padding: EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: _getReasonColor(_returnDetail!.returnReason).withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(
                  color: _getReasonColor(_returnDetail!.returnReason),
                  width: 1.5,
                ),
              ),
              child: Row(
                children: [
                  Icon(
                    _getReasonIcon(_returnDetail!.returnReason),
                    color: _getReasonColor(_returnDetail!.returnReason),
                    size: 24,
                  ),
                  SizedBox(width: 12),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Return Reason',
                        style: GoogleFonts.poppins(
                          fontSize: 11,
                          color: _getReasonColor(_returnDetail!.returnReason).withValues(alpha: 0.8),
                        ),
                      ),
                      Text(
                        _formatReason(_returnDetail!.returnReason),
                        style: GoogleFonts.poppins(
                          fontSize: 15,
                          fontWeight: FontWeight.bold,
                          color: _getReasonColor(_returnDetail!.returnReason),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            if (_returnDetail!.returnDeadlineDate != null) ...[
              SizedBox(height: 12),
              Container(
                padding: EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: AppColors.infoLight,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  children: [
                    Icon(Icons.event, color: AppColors.info, size: 20),
                    SizedBox(width: 12),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Deadline',
                          style: GoogleFonts.poppins(
                            fontSize: 11,
                            color: AppColors.info,
                          ),
                        ),
                        Text(
                          _formatDate(_returnDetail!.returnDeadlineDate),
                          style: GoogleFonts.poppins(
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                            color: AppColors.info,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
  
  Widget _buildRemarksCard() {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.comment, color: AppColors.primary, size: 20),
                SizedBox(width: 8),
                Text(
                  'Remarks',
                  style: GoogleFonts.poppins(fontSize: 16, fontWeight: FontWeight.w600),
                ),
              ],
            ),
            SizedBox(height: 12),
            Container(
              padding: EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: AppColors.gray100,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                _returnDetail!.returnRemarks!,
                style: GoogleFonts.poppins(
                  fontSize: 14,
                  color: AppColors.textSecondary,
                  height: 1.5,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
  
  Widget _buildTimelineCard() {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.timeline, color: AppColors.primary, size: 20),
                SizedBox(width: 8),
                Text(
                  'Timeline',
                  style: GoogleFonts.poppins(fontSize: 16, fontWeight: FontWeight.w600),
                ),
              ],
            ),
            SizedBox(height: 16),
            _buildTimelineItem(
              'Return Requested',
              _formatDate(_returnDetail!.returnRequestDate),
              Icons.send,
              AppColors.info,
            ),
            if (_returnDetail!.returnConfirmedDate != null)
              _buildTimelineItem(
                'Confirmed',
                _formatDate(_returnDetail!.returnConfirmedDate),
                Icons.check_circle,
                AppColors.success,
              ),
          ],
        ),
      ),
    );
  }
  
  Widget _buildTimelineItem(String label, String date, IconData icon, Color color) {
    return Padding(
      padding: EdgeInsets.only(bottom: 12),
      child: Row(
        children: [
          Container(
            padding: EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(icon, color: color, size: 20),
          ),
          SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: GoogleFonts.poppins(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textPrimary,
                  ),
                ),
                Text(
                  date,
                  style: GoogleFonts.poppins(
                    fontSize: 12,
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
            ),
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
  
  Widget _buildConfirmButton() {
    return ElevatedButton(
      onPressed: _isConfirming ? null : _confirmReturn,
      style: ElevatedButton.styleFrom(
        backgroundColor: AppColors.success,
        foregroundColor: AppColors.white,
        padding: EdgeInsets.symmetric(vertical: 16),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        elevation: 2,
      ),
      child: _isConfirming
          ? SizedBox(
              height: 20,
              width: 20,
              child: CircularProgressIndicator(
                strokeWidth: 2,
                valueColor: AlwaysStoppedAnimation<Color>(AppColors.white),
              ),
            )
          : Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.check_circle, size: 22),
                SizedBox(width: 8),
                Text(
                  'Confirm Receipt & Update Inventory',
                  style: GoogleFonts.poppins(fontSize: 16, fontWeight: FontWeight.w600),
                ),
              ],
            ),
    );
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
  
  @override
  void dispose() {
    _bloc.dispose();
    super.dispose();
  }
}
