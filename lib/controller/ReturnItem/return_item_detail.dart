import 'package:flutter/material.dart';
import 'package:GEMS/view/gems_chrome.dart';
import 'package:flutter/services.dart';
import 'package:GEMS/controller/ReturnItem/bloc/bloc_return.dart';
import 'package:GEMS/model/return_ticket_models.dart';
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
      backgroundColor: GemsChrome.page,
      appBar: gemsAppBar(
        title: const Text('Return Request'),
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
    return GemsFormSection(
      title: 'Item details',
      icon: Icons.inventory_2_outlined,
      child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              group.itemDescription,
              style: GemsChrome.heading(size: 18),
            ),
            SizedBox(height: 8),
            _buildQuantitySummary(group),
            if (group.serializedInstances.isNotEmpty) ...[
              SizedBox(height: 20),
              Text(
                'Serialized items (${group.serializedInstances.length})',
                style: GemsChrome.body(size: 13, weight: FontWeight.w600, color: GemsChrome.textSoft),
              ),
              SizedBox(height: 8),
              ...group.serializedInstances.map(_buildSerializedCard),
            ],
            if (group.bulkBuckets.isNotEmpty) ...[
              SizedBox(height: 20),
              Text(
                'Material requests (${group.bulkBuckets.length})',
                style: GemsChrome.body(size: 13, weight: FontWeight.w600, color: GemsChrome.textSoft),
              ),
              SizedBox(height: 8),
              ...group.bulkBuckets.map(_buildBulkBucketCard),
            ],
          ],
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
                style: GemsChrome.body(size: 11, weight: FontWeight.w500, color: color),
              ),
              const SizedBox(height: 4),
              Text(
                value,
                style: GemsChrome.body(size: 16, weight: FontWeight.w700, color: color),
              ),
            ],
          ),
        ),
      );
    }

    return Row(
      children: [
        chip('Collected', group.totalCollected.toString(), GemsChrome.primary),
        chip('Returned', group.totalReturned.toString(), GemsChrome.warning),
        chip('Available', group.totalAvailable.toString(), GemsChrome.success),
      ],
    );
  }

  Widget _buildQuantityInput() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        TextField(
          controller: _quantityController,
          keyboardType: TextInputType.number,
          inputFormatters: [FilteringTextInputFormatter.digitsOnly],
          style: GemsChrome.body(size: 14),
          decoration: gemsFieldDecoration(label: 'Return quantity').copyWith(
            hintText: 'Max $_maxQuantity',
            hintStyle: GemsChrome.body(color: GemsChrome.muted),
          ),
        ),
        const SizedBox(height: 6),
        Text(
          'Adjust the number if you plan to return less than the available quantity.',
          style: GemsChrome.body(size: 12, color: GemsChrome.textSoft),
        ),
      ],
    );
  }
  
  Widget _buildFormCard(bool isLoading) {
    return GemsFormSection(
      title: 'Return information',
      icon: Icons.assignment_return_outlined,
      child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            DropdownButtonFormField<String>(
              value: _selectedReason,
              isExpanded: true,
              decoration: gemsFieldDecoration(label: 'Return reason'),
              style: GemsChrome.body(size: 14),
              items: _reasonOptions.entries.map((entry) {
                return DropdownMenuItem(
                  value: entry.key,
                  child: Text(entry.value, style: GemsChrome.body(size: 14)),
                );
              }).toList(),
              onChanged: (value) {
                setState(() {
                  _selectedReason = value!;
                });
              },
            ),
            SizedBox(height: 16),

            if (_isQuantityMode) ...[
              _buildQuantityInput(),
              SizedBox(height: 16),
            ] else ...[
              SizedBox(height: 8),
              Text(
                'This group has 1 item available to return. It will be submitted using FIFO order.',
                style: GemsChrome.body(size: 12, color: GemsChrome.textSoft),
              ),
              SizedBox(height: 16),
            ],
            
            // Remarks (Optional)
            TextField(
              controller: _remarksController,
              maxLines: 3,
              maxLength: 500,
              style: GemsChrome.body(size: 14),
              decoration: gemsFieldDecoration(label: 'Remarks').copyWith(
                hintText: 'Add any additional notes...',
                hintStyle: GemsChrome.body(color: GemsChrome.muted),
              ),
            ),
            SizedBox(height: 16),
            
            SizedBox(height: 24),
            
            // Submit Button
            SizedBox(
              width: double.infinity,
              child: FilledButton(
                onPressed: isLoading ? null : _submitReturn,
                style: gemsPrimaryButton(),
                child: isLoading
                    ? const SizedBox(
                        height: 20,
                        width: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: Colors.white,
                        ),
                      )
                    : Text(
                        'Submit return request',
                        style: GemsChrome.body(size: 16, weight: FontWeight.w600, color: Colors.white),
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
                  foregroundColor: GemsChrome.text,
                  side: const BorderSide(color: GemsChrome.border),
                  minimumSize: const Size(double.infinity, 44),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(GemsChrome.radius),
                  ),
                ),
                child: Text(
                  'Cancel',
                  style: GemsChrome.body(size: 16, weight: FontWeight.w600, color: GemsChrome.text),
                ),
              ),
            ),
          ],
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
        title: Text('Confirm return', style: GemsChrome.heading(size: 18)),
        content: Text(
          _isQuantityMode
              ? 'Return $quantity item(s) from ${widget.group.itemDescription}?'
              : 'Return ${widget.group.itemDescription}?',
          style: GemsChrome.body(),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text('Cancel', style: GemsChrome.body(color: GemsChrome.textSoft)),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, true),
            style: FilledButton.styleFrom(backgroundColor: GemsChrome.primary),
            child: Text('Confirm', style: GemsChrome.body(weight: FontWeight.w600, color: Colors.white)),
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
        color: GemsChrome.neutralSoft,
        borderRadius: BorderRadius.circular(GemsChrome.radius),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(serial, style: GemsChrome.body(size: 14, weight: FontWeight.w600)),
          const SizedBox(height: 4),
          Text(
            'WO ${instance.woTaskNo} · MR ${instance.woTaskRequestNo}',
            style: GemsChrome.body(size: 12, color: GemsChrome.textSoft),
          ),
          const SizedBox(height: 4),
          Text(
            'Checkout: ${_formatDateTime(instance.checkOutTime)}',
            style: GemsChrome.body(size: 12, color: GemsChrome.textSoft),
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
        border: Border.all(color: GemsChrome.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'MR ${instance.woTaskRequestNo}',
            style: GemsChrome.body(size: 13, weight: FontWeight.w600),
          ),
          const SizedBox(height: 4),
          Text(
            'WO ${instance.woTaskNo}',
            style: GemsChrome.body(size: 12, color: GemsChrome.textSoft),
          ),
          const SizedBox(height: 4),
          Text(
            'Available: ${instance.quantityAvailableToReturn}',
            style: GemsChrome.body(size: 12, weight: FontWeight.w600, color: GemsChrome.success),
          ),
        ],
      ),
    );
  }
}
