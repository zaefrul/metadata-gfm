import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:toast/toast.dart';

import 'package:GEMS/controller/WorkOrder/material_arguments.dart';
import 'package:GEMS/data/repository/work_order_detail_repository.dart';
import 'package:GEMS/model/complaint.dart';
import 'package:GEMS/utils/reference.dart';

class ComplaintAdd extends StatefulWidget {
  const ComplaintAdd(this.args, {super.key});

  final MaterialAddArguments args;

  @override
  State<ComplaintAdd> createState() => _ComplaintAddState();
}

class _ComplaintAddState extends State<ComplaintAdd> {
  final _repository = WorkOrderDetailRepository();

  final TextEditingController _quantityController = TextEditingController();
  final TextEditingController _remarkController = TextEditingController();

  List<ComplaintDGroup> _groups = const [];
  List<ComplaintDType> _types = const [];
  List<ComplaintDPart> _parts = const [];

  ComplaintDGroup? _selectedGroup;
  ComplaintDType? _selectedType;
  ComplaintDPart? _selectedPart;

  bool _loadingGroups = true;
  bool _loadingOptions = false;
  bool _submitting = false;
  bool _offlineMode = false;
  bool _offlineToastShown = false;

  String? _error; // displayed above the form when loading fails
  int? _quantityValue;

  @override
  void initState() {
    super.initState();
    _quantityController.addListener(_onQuantityChanged);
    _loadGroups();
  }

  @override
  void dispose() {
    _quantityController.removeListener(_onQuantityChanged);
    _quantityController.dispose();
    _remarkController.dispose();
    super.dispose();
  }

  bool get _hasValidSelection => _selectedPart != null && _isQuantityValid;

  bool get _isQuantityValid => _quantityValue != null && _quantityValue! > 0;

  void _onQuantityChanged() {
    final raw = _quantityController.text.trim();
    setState(() {
      _quantityValue = int.tryParse(raw);
    });
  }

  Future<void> _loadGroups({bool forceRefresh = false}) async {
    setState(() {
      _loadingGroups = true;
      _error = null;
      _groups = const [];
      _types = const [];
      _parts = const [];
      _selectedGroup = null;
      _selectedType = null;
      _selectedPart = null;
    });

    final offline =
        await _repository.isOfflineModeEnabled(widget.args.workOrderId);
    if (mounted) {
      setState(() {
        _offlineMode = offline;
        if (!offline) {
          _offlineToastShown = false;
        }
      });
    }

    try {
      final results = await _repository.getMaterialGroups(
        workOrderId: widget.args.workOrderId,
        forceRefresh: forceRefresh,
      );
      if (!mounted) return;
      setState(() {
        _groups = results;
        if (_offlineMode && results.isEmpty) {
          _error =
              'No cached material groups yet. Reconnect and pull to refresh.';
        }
      });
      if (_offlineMode) {
        _showOfflineToastOnce();
      }
    } on StateError catch (err) {
      if (!mounted) return;
      setState(() {
        _error = err.message;
      });
      _showToast(err.message);
    } catch (err, st) {
      debugPrint('Failed to load material groups: $err\n$st');
      if (!mounted) return;
      setState(() {
        _error = 'Unable to load material groups. Pull to retry.';
      });
      _showToast('Unable to load material groups');
    } finally {
      if (mounted) {
        setState(() {
          _loadingGroups = false;
        });
      }
    }
  }

  Future<void> _onGroupChanged(ComplaintDGroup? group) async {
    if (_selectedGroup == group) return;

    setState(() {
      _selectedGroup = group;
      _selectedType = null;
      _selectedPart = null;
      _types = const [];
      _parts = const [];
    });

    final groupId = group?.itemId;
    if (groupId == null || groupId.isEmpty) {
      return;
    }

    await _loadTypes(groupId);
  }

  Future<void> _loadTypes(String groupId, {bool forceRefresh = false}) async {
    setState(() {
      _loadingOptions = true;
      _selectedType = null;
      _selectedPart = null;
      _parts = const [];
    });
    try {
      final results = await _repository.getMaterialTypes(
        workOrderId: widget.args.workOrderId,
        groupId: groupId,
        forceRefresh: forceRefresh,
      );
      if (!mounted) return;
      setState(() {
        _types = results;
      });
      if (_offlineMode && results.isEmpty) {
        _showToast(
            'No cached item types for this group. Reconnect to refresh.');
      }
    } on StateError catch (err) {
      if (!mounted) return;
      _showToast(err.message);
    } catch (err, st) {
      debugPrint('Failed to load material types: $err\n$st');
      if (!mounted) return;
      _showToast('Unable to load item types');
    } finally {
      if (mounted) {
        setState(() {
          _loadingOptions = false;
        });
      }
    }
  }

  Future<void> _onTypeChanged(ComplaintDType? type) async {
    if (_selectedType == type) return;

    setState(() {
      _selectedType = type;
      _selectedPart = null;
      _parts = const [];
    });

    final typeId = type?.itemId;
    if (typeId == null || typeId.isEmpty) {
      return;
    }

    await _loadParts(typeId);
  }

  Future<void> _loadParts(String typeId, {bool forceRefresh = false}) async {
    setState(() {
      _loadingOptions = true;
    });
    try {
      final results = await _repository.getMaterialParts(
        workOrderId: widget.args.workOrderId,
        typeId: typeId,
        forceRefresh: forceRefresh,
      );
      if (!mounted) return;
      setState(() {
        _parts = results;
      });
      if (_offlineMode && results.isEmpty) {
        _showToast('No cached parts for this type. Reconnect to refresh.');
      }
    } on StateError catch (err) {
      if (!mounted) return;
      _showToast(err.message);
    } catch (err, st) {
      debugPrint('Failed to load material parts: $err\n$st');
      if (!mounted) return;
      _showToast('Unable to load parts');
    } finally {
      if (mounted) {
        setState(() {
          _loadingOptions = false;
        });
      }
    }
  }

  void _onPartChanged(ComplaintDPart? part) {
    setState(() {
      _selectedPart = part;
    });

    if (part != null) {
      final quantity = part.itemQuantity ?? '';
      if (quantity.isNotEmpty) {
        _quantityController.text = quantity;
      }
    }
  }

  void _showOfflineToastOnce() {
    if (_offlineToastShown) return;
    _offlineToastShown = true;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      ToastContext().init(context);
      Toast.show(
        'Offline mode is on. Showing cached spare part options.',
        duration: Toast.lengthShort,
        gravity: Toast.bottom,
      );
    });
  }

  void _showToast(String message) {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      ToastContext().init(context);
      Toast.show(
        message,
        duration: Toast.lengthShort,
        gravity: Toast.bottom,
      );
    });
  }

  Future<void> _submit() async {
    final part = _selectedPart;
    if (part == null) {
      Toast.show('Please pick a material item.');
      return;
    }
    if (!_isQuantityValid) {
      Toast.show('Quantity must be greater than zero.');
      return;
    }
    if (part.itemId == null || part.itemId!.isEmpty) {
      Toast.show('Selected material item is missing an identifier.');
      return;
    }

    setState(() {
      _submitting = true;
    });

    try {
      final result = await _repository.addMaterial(
        workOrderId: widget.args.workOrderId,
        itemId: part.itemId!,
        quantity: _quantityController.text.trim(),
        remark: _remarkController.text.trim(),
        itemDescription: part.itemName,
        assetGroupName: _selectedGroup?.itemName,
        itemTypeDesc: _selectedType?.itemName ?? _selectedType?.itemTypeDesc,
      );

      _showResultToast(result);
      if (mounted) {
        Navigator.pop(context, true);
      }
    } catch (err, st) {
      debugPrint('Failed to add material: $err\n$st');
      if (mounted) {
        Toast.show('Failed to add material');
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
        Toast.show('Material added successfully.', duration: 3);
        break;
      case WorkOrderActionResult.queued:
        Toast.show('Material queued and will sync once online.', duration: 3);
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
          'Add Material / Item',
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
          RefreshIndicator(
            onRefresh: () => _loadGroups(forceRefresh: true),
            child: SingleChildScrollView(
              physics: const AlwaysScrollableScrollPhysics(),
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Plan spare parts usage for this work order.',
                    style: GoogleFonts.poppins(
                      fontSize: 14,
                      color: AppColors.textSecondary,
                    ),
                  ),
                  const SizedBox(height: 16),
                  if (_error != null)
                    _ErrorBanner(
                      message: _error!,
                    ),
                  const SizedBox(height: 12),
                  _buildSection(
                    title: 'Item Group',
                    icon: Icons.category_outlined,
                    child: _buildDropdownField<ComplaintDGroup>(
                      label: 'Select group',
                      value: _selectedGroup,
                      items: _groups
                          .map((group) => DropdownMenuItem(
                                value: group,
                                child: Text(group.itemName ?? '-'),
                              ))
                          .toList(),
                      onChanged: _loadingGroups ? null : _onGroupChanged,
                    ),
                  ),
                  const SizedBox(height: 20),
                  _buildSection(
                    title: 'Item Type',
                    icon: Icons.type_specimen_outlined,
                    child: _buildDropdownField<ComplaintDType>(
                      label: 'Select type',
                      value: _selectedType,
                      items: _types
                          .map((type) => DropdownMenuItem(
                                value: type,
                                child: Text(type.itemName ?? '-'),
                              ))
                          .toList(),
                      onChanged: _types.isEmpty
                          ? null
                          : (value) => _onTypeChanged(value),
                    ),
                  ),
                  const SizedBox(height: 20),
                  _buildSection(
                    title: 'Item Part',
                    icon: Icons.inventory_outlined,
                    child: _buildDropdownField<ComplaintDPart>(
                      label: 'Select part',
                      value: _selectedPart,
                      items: _parts
                          .map((part) => DropdownMenuItem(
                                value: part,
                                child: Text(part.itemName ?? '-'),
                              ))
                          .toList(),
                      onChanged: _parts.isEmpty
                          ? null
                          : (value) => _onPartChanged(value),
                    ),
                  ),
                  if (_selectedPart != null) ...[
                    const SizedBox(height: 12),
                    _HighlightCard(
                      title: 'Hints',
                      message:
                          'Available quantity: ${_selectedPart!.itemQuantity ?? '-'}',
                    ),
                  ],
                  const SizedBox(height: 28),
                  _buildSection(
                    title: 'Item Details',
                    icon: Icons.edit_outlined,
                    child: Column(
                      children: [
                        TextFormField(
                          controller: _quantityController,
                          keyboardType: TextInputType.number,
                          decoration: _inputDecoration('Quantity').copyWith(
                            errorText: _quantityValue == null &&
                                    _quantityController.text.isNotEmpty
                                ? 'Invalid number'
                                : !_isQuantityValid &&
                                        _quantityController.text.isNotEmpty
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
                  ),
                  const SizedBox(height: 120),
                ],
              ),
            ),
          ),
          if (_loadingGroups || _loadingOptions || _submitting)
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
            onPressed: _hasValidSelection && !_submitting ? _submit : null,
            icon: const Icon(Icons.save_alt),
            label: Text(
              'Save Material',
              style: GoogleFonts.poppins(
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ),
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

  Widget _buildSection({
    required String title,
    required IconData icon,
    required Widget child,
  }) {
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
              Icon(icon, color: AppColors.primary),
              const SizedBox(width: 12),
              Text(
                title,
                style: GoogleFonts.poppins(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          child,
        ],
      ),
    );
  }

  Widget _buildDropdownField<T>({
    required String label,
    required T? value,
    required List<DropdownMenuItem<T>> items,
    required ValueChanged<T?>? onChanged,
  }) {
    return InputDecorator(
      decoration: _inputDecoration(label),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<T>(
          isExpanded: true,
          value: value,
          hint: Text(
            label,
            style: GoogleFonts.poppins(color: AppColors.textSecondary),
          ),
          items: items,
          onChanged: onChanged,
        ),
      ),
    );
  }
}

class _ErrorBanner extends StatelessWidget {
  const _ErrorBanner({required this.message});

  final String message;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.dangerLight,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.danger),
      ),
      child: Row(
        children: [
          const Icon(Icons.error_outline, color: AppColors.danger),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              message,
              style: GoogleFonts.poppins(
                color: AppColors.dangerDark,
                fontSize: 13,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _HighlightCard extends StatelessWidget {
  const _HighlightCard({required this.title, required this.message});

  final String title;
  final String message;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.infoLight,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.info),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: GoogleFonts.poppins(
              fontWeight: FontWeight.w600,
              color: AppColors.infoDark,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            message,
            style: GoogleFonts.poppins(
              fontSize: 13,
              color: AppColors.textSecondary,
            ),
          ),
        ],
      ),
    );
  }
}
