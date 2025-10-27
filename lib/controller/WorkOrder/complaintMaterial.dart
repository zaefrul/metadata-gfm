import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:toast/toast.dart';

import 'package:GEMS/controller/WorkOrder/material_arguments.dart';
import 'package:GEMS/data/repository/work_order_detail_repository.dart';
import 'package:GEMS/model/complaint.dart';
import 'package:GEMS/utils/reference.dart';

class MaterialEdit extends StatefulWidget {
  const MaterialEdit(this.args, {super.key});

  final MaterialEditArguments args;

  @override
  State<MaterialEdit> createState() => _MaterialEditState();
}

class _MaterialEditState extends State<MaterialEdit> {
  final _repository = WorkOrderDetailRepository();
  late final TextEditingController _quantityController;
  late final TextEditingController _remarkController;

  bool _submitting = false;
  int? _quantityValue;

  ComplaintD get _material => widget.args.material;

  @override
  void initState() {
    super.initState();
    _quantityController = TextEditingController(
      text: _material.woTaskPartsQuantity ?? '',
    );
    _remarkController = TextEditingController(
      text: _material.woTaskPartsRemark ?? '',
    );
    _quantityController.addListener(_onQuantityChanged);
    _onQuantityChanged();
  }

  @override
  void dispose() {
    _quantityController.removeListener(_onQuantityChanged);
    _quantityController.dispose();
    _remarkController.dispose();
    super.dispose();
  }

  void _onQuantityChanged() {
    final raw = _quantityController.text.trim();
    setState(() {
      _quantityValue = int.tryParse(raw);
    });
  }

  bool get _isQuantityValid => _quantityValue != null && _quantityValue! > 0;

  Future<void> _submit() async {
    final materialId = _material.woTaskPartsId;
    if (materialId == null || materialId.isEmpty) {
      Toast.show('Missing material identifier');
      return;
    }
    if (!_isQuantityValid) {
      Toast.show('Quantity must be greater than zero.');
      return;
    }

    setState(() {
      _submitting = true;
    });

    try {
      final result = await _repository.updateMaterial(
        workOrderId: widget.args.workOrderId,
        materialId: materialId,
        quantity: _quantityController.text.trim(),
        remark: _remarkController.text.trim(),
        itemDescription: _material.itemDescription,
        assetGroupName: _material.assetGroupName,
        itemTypeDesc: _material.itemTypeDesc,
        previousQuantity: _material.woTaskPartsQuantity,
      );

      _showResultToast(result);
      if (mounted) {
        Navigator.pop(context, true);
      }
    } catch (err, st) {
      debugPrint('Failed to update material: $err\n$st');
      if (mounted) {
        Toast.show('Failed to save changes');
      }
    } finally {
      if (mounted) {
        setState(() {
          _submitting = false;
        });
      }
    }
  }

  void _showResultToast(WorkOrderActionResult result) {
    switch (result) {
      case WorkOrderActionResult.success:
        Toast.show('Material updated successfully.', duration: 3);
        break;
      case WorkOrderActionResult.queued:
        Toast.show('Update queued and will sync when online.', duration: 3);
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    ToastContext().init(context);

    return Scaffold(
      backgroundColor: AppColors.gray100,
      appBar: AppBar(
        title: Text(
          'Material / Item',
          style: GoogleFonts.poppins(
            fontWeight: FontWeight.w600,
            color: AppColors.textPrimary,
          ),
        ),
        elevation: 0,
        backgroundColor: AppColors.bgAppBar,
        centerTitle: true,
        iconTheme: const IconThemeData(color: AppColors.primary),
      ),
      body: Stack(
        children: [
          SingleChildScrollView(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildInformationSection(),
                const SizedBox(height: 20),
                _buildEditSection(),
                const SizedBox(height: 120),
              ],
            ),
          ),
          if (_submitting)
            Positioned.fill(
              child: Container(
                color: Colors.black.withValues(alpha: 0.1),
                child: const Center(
                  child: CircularProgressIndicator(),
                ),
              ),
            ),
        ],
      ),
      bottomNavigationBar: SafeArea(
        minimum: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        child: SizedBox(
          width: double.infinity,
          child: ElevatedButton.icon(
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              foregroundColor: AppColors.onPrimary,
              padding: const EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            onPressed: _isQuantityValid && !_submitting ? _submit : null,
            icon: const Icon(Icons.save_outlined),
            label: Text(
              'Save Changes',
              style: GoogleFonts.poppins(fontWeight: FontWeight.w600),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildInformationSection() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 12,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.inventory_outlined, color: AppColors.primary),
              const SizedBox(width: 12),
              Text(
                'Item Information',
                style: GoogleFonts.poppins(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          _buildInfoRow('Description', _material.itemDescription ?? '-'),
          _buildInfoRow('Type', _material.itemTypeDesc ?? '-'),
          _buildInfoRow('Group', _material.assetGroupName ?? '-'),
          _buildInfoRow('Status', _material.statusDesc ?? '-'),
        ],
      ),
    );
  }

  Widget _buildEditSection() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 12,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.edit_outlined, color: AppColors.primary),
              const SizedBox(width: 12),
              Text(
                'Edit Details',
                style: GoogleFonts.poppins(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          TextFormField(
            controller: _quantityController,
            keyboardType: TextInputType.number,
            decoration: _inputDecoration('Quantity').copyWith(
              errorText: _quantityController.text.isEmpty
                  ? 'Quantity is required'
                  : !_isQuantityValid
                      ? 'Quantity must be greater than zero'
                      : null,
            ),
          ),
          const SizedBox(height: 16),
          TextFormField(
            controller: _remarkController,
            maxLines: 3,
            decoration: _inputDecoration('Remark (optional)'),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: GoogleFonts.poppins(
              fontSize: 13,
              color: AppColors.textSecondary,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            value,
            style: GoogleFonts.poppins(
              fontSize: 15,
              fontWeight: FontWeight.w600,
              color: AppColors.textPrimary,
            ),
          ),
        ],
      ),
    );
  }

  InputDecoration _inputDecoration(String label) {
    return InputDecoration(
      labelText: label,
      labelStyle: GoogleFonts.poppins(color: AppColors.textSecondary),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: AppColors.gray300),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: AppColors.primary),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: AppColors.gray300),
      ),
      filled: true,
      fillColor: AppColors.white,
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
    );
  }
}
