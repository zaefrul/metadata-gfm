import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:GEMS/controller/ReturnItem/bloc/bloc_return.dart';
import 'package:GEMS/model/return_item.dart';
import 'package:GEMS/utils/reference.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:toast/toast.dart';
import 'package:intl/intl.dart';

class ReturnItemDetail extends StatefulWidget {
  final CollectedItem item;
  
  const ReturnItemDetail({Key? key, required this.item}) : super(key: key);

  @override
  _ReturnItemDetailState createState() => _ReturnItemDetailState();
}

class _ReturnItemDetailState extends State<ReturnItemDetail> {
  final ReturnItemBloc _bloc = ReturnItemBloc();
  final TextEditingController _quantityController = TextEditingController();
  final TextEditingController _remarksController = TextEditingController();
  
  String _selectedReason = 'unused_excess';
  DateTime? _selectedDeadline;
  
  final Map<String, String> _reasonOptions = {
    'unused_excess': 'Unused / Excess',
    'wrong_part': 'Wrong Part',
    'damaged': 'Damaged / Defective',
    'other': 'Other Reason',
  };
  
  @override
  void initState() {
    super.initState();
    // Default quantity to maximum available
    _quantityController.text = (widget.item.quantityAvailableToReturn ?? 0).toString();
  }
  
  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    ToastContext().init(context);
  }
  
  @override
  Widget build(BuildContext context) {
    int maxQty = widget.item.quantityAvailableToReturn ?? 0;
    
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
                    _buildFormCard(maxQty, isLoading),
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
              widget.item.partName ?? 'Unknown Item',
              style: GoogleFonts.poppins(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: AppColors.textPrimary,
              ),
            ),
            SizedBox(height: 8),
            _buildInfoRow('Code', widget.item.partCode ?? 'N/A'),
            _buildInfoRow('WO Number', widget.item.workOrderNo ?? 'N/A'),
            _buildInfoRow('Collected', '${widget.item.quantityCollected ?? 0} items'),
            _buildInfoRow('In Possession', '${widget.item.partsInPossession ?? 0} items'),
            _buildInfoRow('Available to Return', '${widget.item.quantityAvailableToReturn ?? 0} items'),
          ],
        ),
      ),
    );
  }
  
  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Text(
            '$label: ',
            style: GoogleFonts.poppins(fontSize: 13, color: AppColors.textSecondary),
          ),
          Text(
            value,
            style: GoogleFonts.poppins(
              fontSize: 13,
              fontWeight: FontWeight.w500,
              color: AppColors.textPrimary,
            ),
          ),
        ],
      ),
    );
  }
  
  Widget _buildFormCard(int maxQty, bool isLoading) {
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
            
            // Quantity Input
            Text(
              'Quantity to Return *',
              style: GoogleFonts.poppins(fontSize: 13, fontWeight: FontWeight.w500),
            ),
            SizedBox(height: 8),
            TextField(
              controller: _quantityController,
              keyboardType: TextInputType.number,
              inputFormatters: [FilteringTextInputFormatter.digitsOnly],
              decoration: InputDecoration(
                hintText: 'Enter quantity (1 - $maxQty)',
                suffixText: 'Max: $maxQty',
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 12),
              ),
              style: GoogleFonts.poppins(fontSize: 14),
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
            
            // Deadline Date (Optional)
            Text(
              'Expected Return Date (Optional)',
              style: GoogleFonts.poppins(fontSize: 13, fontWeight: FontWeight.w500),
            ),
            SizedBox(height: 8),
            InkWell(
              onTap: () => _selectDeadline(),
              child: Container(
                padding: EdgeInsets.all(12),
                decoration: BoxDecoration(
                  border: Border.all(color: AppColors.gray400),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      _selectedDeadline == null
                          ? 'Select date'
                          : DateFormat('dd MMM yyyy, HH:mm').format(_selectedDeadline!),
                      style: GoogleFonts.poppins(
                        fontSize: 14,
                        color: _selectedDeadline == null ? AppColors.gray500 : AppColors.textPrimary,
                      ),
                    ),
                    Icon(Icons.calendar_today, size: 18, color: AppColors.gray500),
                  ],
                ),
              ),
            ),
            SizedBox(height: 24),
            
            // Submit Button
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: isLoading ? null : () => _submitReturn(maxQty),
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
  
  Future<void> _selectDeadline() async {
    final DateTime? pickedDate = await showDatePicker(
      context: context,
      initialDate: DateTime.now().add(Duration(days: 1)),
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(Duration(days: 365)),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: ColorScheme.light(primary: AppColors.primary),
          ),
          child: child!,
        );
      },
    );
    
    if (pickedDate != null) {
      final TimeOfDay? pickedTime = await showTimePicker(
        context: context,
        initialTime: TimeOfDay(hour: 17, minute: 0),
        builder: (context, child) {
          return Theme(
            data: Theme.of(context).copyWith(
              colorScheme: ColorScheme.light(primary: AppColors.primary),
            ),
            child: child!,
          );
        },
      );
      
      if (pickedTime != null) {
        setState(() {
          _selectedDeadline = DateTime(
            pickedDate.year,
            pickedDate.month,
            pickedDate.day,
            pickedTime.hour,
            pickedTime.minute,
          );
        });
      }
    }
  }
  
  Future<void> _submitReturn(int maxQty) async {
    // Validation
    String qtyText = _quantityController.text.trim();
    if (qtyText.isEmpty) {
      Toast.show('Please enter quantity to return', duration: Toast.lengthLong, gravity: Toast.bottom);
      return;
    }
    
    int qty = int.tryParse(qtyText) ?? 0;
    if (qty <= 0) {
      Toast.show('Quantity must be greater than 0', duration: Toast.lengthLong, gravity: Toast.bottom);
      return;
    }
    
    if (qty > maxQty) {
      Toast.show('Quantity cannot exceed $maxQty', duration: Toast.lengthLong, gravity: Toast.bottom);
      return;
    }
    
    // Show confirmation dialog
    bool? confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Confirm Return', style: GoogleFonts.poppins(fontWeight: FontWeight.w600)),
        content: Text(
          'Are you sure you want to return $qty item(s)?',
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
    
    try {
      String? deadlineStr;
      if (_selectedDeadline != null) {
        deadlineStr = DateFormat('yyyy-MM-dd HH:mm:ss').format(_selectedDeadline!);
      }
      
      await _bloc.submitReturn(
        woTaskPartsId: widget.item.woTaskPartsId!,
        quantityReturned: qty,
        returnReason: _selectedReason,
        returnRemarks: _remarksController.text.trim().isEmpty 
            ? null 
            : _remarksController.text.trim(),
        returnDeadlineDate: deadlineStr,
      );
      
      Toast.show(
        'Return request submitted successfully',
        duration: Toast.lengthLong,
        gravity: Toast.bottom,
      );
      
      // Go back to list
      Navigator.pop(context);
    } catch (e) {
      // Error already displayed via error stream
      print('Submit error: $e');
    }
  }
  
  @override
  void dispose() {
    _quantityController.dispose();
    _remarksController.dispose();
    _bloc.dispose();
    super.dispose();
  }
}
