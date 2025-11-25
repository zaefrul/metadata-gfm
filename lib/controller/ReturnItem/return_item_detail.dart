import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:GEMS/controller/ReturnItem/bloc/bloc_return.dart';
import 'package:GEMS/model/return_ticket_models.dart';
import 'package:GEMS/utils/reference.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:toast/toast.dart';
import 'package:intl/intl.dart';

class ReturnItemDetail extends StatefulWidget {
  final ReturnPartGroup group;
  
  const ReturnItemDetail({super.key, required this.group});

  @override
  State<ReturnItemDetail> createState() => _ReturnItemDetailState();
}

class _ReturnItemDetailState extends State<ReturnItemDetail> {
  final ReturnItemBloc _bloc = ReturnItemBloc();
  final TextEditingController _remarksController = TextEditingController();
  final TextEditingController _quantityController = TextEditingController();
  
  String _selectedReason = 'unused_excess';
  late final bool _isQuantityMode;
  late final int _maxQuantity;
  
  final Map<String, String> _reasonOptions = {
    'unused_excess': 'Unused / Excess',
    'wrong_part': 'Wrong Part',
    'damaged': 'Damaged / Defective',
    'other': 'Other Reason',
  };
  
  @override
  void initState() {
    super.initState();
    _maxQuantity = widget.group.totalAvailable;
    _isQuantityMode = widget.group.totalAvailable > 1 || widget.group.hasBulk;
    if (_maxQuantity > 0) {
      _quantityController.text = _maxQuantity.toString();
    }
  }
  
  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    ToastContext().init(context);
  }
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bgDefault,
      appBar: AppBar(
        title: Text('Return Request', style: GoogleFonts.poppins(fontWeight: FontWeight.w600)),
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
              
              return SingleChildScrollView(
                padding: EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Item Info Card
                    _buildItemInfoCard(),
                    SizedBox(height: 20),
                    
                    // Return Form
                    _buildFormCard(isLoading),
                  ],
                ),
              );
            },
          );
        },
      ),
    );
  }
  
  Widget _buildItemInfoCard() {
    final group = widget.group;
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Item Details',
              style: GoogleFonts.poppins(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: AppColors.gray600,
              ),
            ),
            SizedBox(height: 12),
            Text(
              group.itemDescription,
              style: GoogleFonts.poppins(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: AppColors.textPrimary,
              ),
            ),
            SizedBox(height: 8),
            _buildQuantitySummary(group),
            if (group.serializedInstances.isNotEmpty) ...[
              SizedBox(height: 20),
              Text(
                'Serialized Items (${group.serializedInstances.length})',
                style: GoogleFonts.poppins(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: AppColors.gray600,
                ),
              ),
              SizedBox(height: 8),
              ...group.serializedInstances.map(_buildSerializedCard),
            ],
            if (group.bulkBuckets.isNotEmpty) ...[
              SizedBox(height: 20),
              Text(
                'Material Requests (${group.bulkBuckets.length})',
                style: GoogleFonts.poppins(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: AppColors.gray600,
                ),
              ),
              SizedBox(height: 8),
              ...group.bulkBuckets.map(_buildBulkBucketCard),
            ],
          ],
        ),
      ),
    );
  }
  
  Widget _buildQuantitySummary(ReturnPartGroup group) {
    Widget chip(String label, String value, Color color) {
      return Expanded(
        child: Container(
          padding: EdgeInsets.symmetric(vertical: 12, horizontal: 8),
          margin: EdgeInsets.symmetric(horizontal: 4),
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.12),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Column(
            children: [
              Text(
                label,
                style: GoogleFonts.poppins(
                  fontSize: 11,
                  fontWeight: FontWeight.w500,
                  color: color.withValues(alpha: 0.9),
                ),
              ),
              SizedBox(height: 4),
              Text(
                value,
                style: GoogleFonts.poppins(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: color.withValues(alpha: 0.9),
                ),
              ),
            ],
          ),
        ),
      );
    }

    return Row(
      children: [
        chip('Collected', group.totalCollected.toString(), AppColors.primary),
        chip('Returned', group.totalReturned.toString(), AppColors.warning),
        chip('Available', group.totalAvailable.toString(), AppColors.success),
      ],
    );
  }

  Widget _buildQuantityInput() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Return Quantity *',
          style: GoogleFonts.poppins(fontSize: 13, fontWeight: FontWeight.w500),
        ),
        SizedBox(height: 8),
        TextField(
          controller: _quantityController,
          keyboardType: TextInputType.number,
          inputFormatters: [FilteringTextInputFormatter.digitsOnly],
          decoration: InputDecoration(
            hintText: 'Enter quantity (max $_maxQuantity)',
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
            contentPadding: EdgeInsets.all(12),
          ),
          style: GoogleFonts.poppins(fontSize: 14),
        ),
        SizedBox(height: 6),
        Text(
          'Adjust the number if you plan to return less than the available quantity.',
          style: GoogleFonts.poppins(fontSize: 12, color: AppColors.gray600),
        ),
      ],
    );
  }
  
  Widget _buildFormCard(bool isLoading) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Return Information',
              style: GoogleFonts.poppins(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: AppColors.gray600,
              ),
            ),
            SizedBox(height: 16),

            // Return Reason Dropdown
            Text(
              'Return Reason *',
              style: GoogleFonts.poppins(fontSize: 13, fontWeight: FontWeight.w500),
            ),
            SizedBox(height: 8),
            Container(
              padding: EdgeInsets.symmetric(horizontal: 12),
              decoration: BoxDecoration(
                border: Border.all(color: AppColors.gray400),
                borderRadius: BorderRadius.circular(8),
              ),
              child: DropdownButtonHideUnderline(
                child: DropdownButton<String>(
                  value: _selectedReason,
                  isExpanded: true,
                  items: _reasonOptions.entries.map((entry) {
                    return DropdownMenuItem(
                      value: entry.key,
                      child: Text(
                        entry.value,
                        style: GoogleFonts.poppins(fontSize: 14),
                      ),
                    );
                  }).toList(),
                  onChanged: (value) {
                    setState(() {
                      _selectedReason = value!;
                    });
                  },
                ),
              ),
            ),
            SizedBox(height: 16),

            if (_isQuantityMode) ...[
              _buildQuantityInput(),
              SizedBox(height: 16),
            ] else ...[
              SizedBox(height: 8),
              Text(
                'This group has 1 item available to return. It will be submitted using FIFO order.',
                style: GoogleFonts.poppins(fontSize: 12, color: AppColors.gray600),
              ),
              SizedBox(height: 16),
            ],
            
            // Remarks (Optional)
            Text(
              'Remarks (Optional)',
              style: GoogleFonts.poppins(fontSize: 13, fontWeight: FontWeight.w500),
            ),
            SizedBox(height: 8),
            TextField(
              controller: _remarksController,
              maxLines: 3,
              maxLength: 500,
              decoration: InputDecoration(
                hintText: 'Add any additional notes...',
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                contentPadding: EdgeInsets.all(12),
              ),
              style: GoogleFonts.poppins(fontSize: 14),
            ),
            SizedBox(height: 16),
            
            SizedBox(height: 24),
            
            // Submit Button
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: isLoading ? null : _submitReturn,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  foregroundColor: AppColors.onPrimary,
                  padding: EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                  disabledBackgroundColor: AppColors.gray400,
                ),
                child: isLoading
                    ? SizedBox(
                        height: 20,
                        width: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          valueColor: AlwaysStoppedAnimation<Color>(AppColors.white),
                        ),
                      )
                    : Text(
                        'Submit Return Request',
                        style: GoogleFonts.poppins(fontSize: 16, fontWeight: FontWeight.w600),
                      ),
              ),
            ),
            SizedBox(height: 12),
            
            // Cancel Button
            SizedBox(
              width: double.infinity,
              child: OutlinedButton(
                onPressed: isLoading ? null : () => Navigator.pop(context),
                style: OutlinedButton.styleFrom(
                  side: BorderSide(color: AppColors.gray400),
                  padding: EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                child: Text(
                  'Cancel',
                  style: GoogleFonts.poppins(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textPrimary,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
  
  String _formatDateTime(String? raw) {
    if (raw == null || raw.isEmpty) return 'N/A';
    final dt = DateTime.tryParse(raw);
    if (dt == null) return raw;
    return DateFormat('dd MMM yyyy, HH:mm').format(dt);
  }

  Future<void> _submitReturn() async {
    if (widget.group.totalAvailable <= 0) {
      Toast.show('This part is no longer eligible for return',
          duration: Toast.lengthLong, gravity: Toast.bottom);
      return;
    }

    int quantity;
    if (_isQuantityMode) {
      final parsed = _validatedQuantity();
      if (parsed == null) {
        return;
      }
      quantity = parsed;
    } else {
      quantity = 1;
    }

    bool? confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Confirm Return', style: GoogleFonts.poppins(fontWeight: FontWeight.w600)),
        content: Text(
          _isQuantityMode
              ? 'Return $quantity item(s) from ${widget.group.itemDescription}?'
              : 'Return ${widget.group.itemDescription}?',
          style: GoogleFonts.poppins(),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text('Cancel', style: GoogleFonts.poppins(color: AppColors.gray600)),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.primary),
            child: Text('Confirm', style: GoogleFonts.poppins()),
          ),
        ],
      ),
    );
    
    if (confirmed != true) return;
    
    final remarks = _remarksController.text.trim().isEmpty
        ? null
        : _remarksController.text.trim();

    try {
      final result = await _bloc.submitGroupedReturn(
        group: widget.group,
        quantity: quantity,
        returnReason: _selectedReason,
        returnRemarks: remarks,
      );

      if (!mounted) return;
      final ticketId =
          result.returnTicketIds.isNotEmpty ? result.returnTicketIds.first : null;

      Toast.show(
        ticketId == null
            ? 'Return submitted for verification'
            : 'Return ticket #$ticketId queued for verification',
        duration: Toast.lengthLong,
        gravity: Toast.bottom,
      );

      Navigator.pop(context);
    } catch (e) {
      // Error already displayed via error stream
      debugPrint('Submit error: $e');
    }
  }
  
  int? _validatedQuantity() {
    final text = _quantityController.text.trim();
    final value = int.tryParse(text);
    if (value == null || value <= 0) {
      Toast.show('Enter a valid quantity',
          duration: Toast.lengthLong, gravity: Toast.bottom);
      return null;
    }
    if (value > _maxQuantity) {
      Toast.show('Quantity cannot exceed $_maxQuantity',
          duration: Toast.lengthLong, gravity: Toast.bottom);
      return null;
    }
    return value;
  }
  
  @override
  void dispose() {
    _remarksController.dispose();
    _quantityController.dispose();
    _bloc.dispose();
    super.dispose();
  }

  Widget _buildSerializedCard(ReturnPartInstance instance) {
    final serial = instance.partSubNo.isNotEmpty
        ? instance.partSubNo
        : instance.partSubId;
    return Container(
      margin: EdgeInsets.only(bottom: 8),
      padding: EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.gray100,
        borderRadius: BorderRadius.circular(10),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            serial,
            style: GoogleFonts.poppins(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: AppColors.textPrimary,
            ),
          ),
          SizedBox(height: 4),
          Text(
            'WO ${instance.woTaskNo} · MR ${instance.woTaskRequestNo}',
            style: GoogleFonts.poppins(fontSize: 12, color: AppColors.gray600),
          ),
          SizedBox(height: 4),
          Text(
            'Checkout: ${_formatDateTime(instance.checkOutTime)}',
            style: GoogleFonts.poppins(fontSize: 12, color: AppColors.gray600),
          ),
        ],
      ),
    );
  }

  Widget _buildBulkBucketCard(ReturnPartInstance instance) {
    return Container(
      margin: EdgeInsets.only(bottom: 8),
      padding: EdgeInsets.all(12),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: AppColors.gray200),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'MR ${instance.woTaskRequestNo}',
            style: GoogleFonts.poppins(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: AppColors.textPrimary,
            ),
          ),
          SizedBox(height: 4),
          Text(
            'WO ${instance.woTaskNo}',
            style: GoogleFonts.poppins(fontSize: 12, color: AppColors.gray600),
          ),
          SizedBox(height: 4),
          Text(
            'Available: ${instance.quantityAvailableToReturn}',
            style: GoogleFonts.poppins(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: AppColors.success,
            ),
          ),
        ],
      ),
    );
  }
}
