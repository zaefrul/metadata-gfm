import 'package:flutter/material.dart';
import 'package:GEMS/controller/ReturnItem/bloc/bloc_return.dart';
import 'package:GEMS/model/return_item.dart';
import 'package:GEMS/model/user.dart';
import 'package:GEMS/utils/reference.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:toast/toast.dart';
import 'package:intl/intl.dart';

class ReturnItemList extends StatefulWidget {
  @override
  _ReturnItemListState createState() => _ReturnItemListState();
}

class _ReturnItemListState extends State<ReturnItemList> {
  final ReturnItemBloc _bloc = ReturnItemBloc();
  User? _user;
  
  @override
  void initState() {
    super.initState();
    _loadUser();
  }
  
  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    ToastContext().init(context);
  }
  
  Future<void> _loadUser() async {
    var pref = await User.getPrefUser;
    _user = User.fromMap(pref);
    if (_user != null) {
      _bloc.loadCollectedItems(_user!.userID);
    }
  }
  
  Future<void> _refresh() async {
    if (_user != null) {
      await _bloc.loadCollectedItems(_user!.userID);
    }
  }
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bgDefault,
      appBar: AppBar(
        title: Text('Return Items', style: GoogleFonts.poppins(fontWeight: FontWeight.w600)),
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
              
              return StreamBuilder<List<CollectedItem>>(
                stream: _bloc.collectedItems$,
                builder: (context, snapshot) {
                  if (isLoading && (!snapshot.hasData || snapshot.data!.isEmpty)) {
                    return Center(child: CircularProgressIndicator(color: AppColors.primary));
                  }
                  
                  List<CollectedItem> items = snapshot.data ?? [];
                  
                  if (items.isEmpty) {
                    return _buildEmptyState();
                  }
                  
                  return RefreshIndicator(
                    onRefresh: _refresh,
                    color: AppColors.primary,
                    child: ListView.builder(
                      padding: EdgeInsets.all(16),
                      itemCount: items.length,
                      itemBuilder: (context, index) {
                        return _buildItemCard(items[index]);
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
          Icon(Icons.inventory_2_outlined, size: 80, color: AppColors.gray400),
          SizedBox(height: 16),
          Text(
            'No Collected Items',
            style: GoogleFonts.poppins(fontSize: 18, color: AppColors.gray600, fontWeight: FontWeight.w500),
          ),
          SizedBox(height: 8),
          Text(
            'Items you collect will appear here',
            style: GoogleFonts.poppins(fontSize: 14, color: AppColors.gray500),
          ),
        ],
      ),
    );
  }
  
  Widget _buildItemCard(CollectedItem item) {
    bool hasPending = item.hasPendingReturn ?? false;
    int availableQty = item.quantityAvailableToReturn ?? 0;
    bool canReturn = !hasPending && availableQty > 0;
    
    return Card(
      margin: EdgeInsets.only(bottom: 12),
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: canReturn ? () => _navigateToDetail(item) : null,
        child: Padding(
          padding: EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header with status badge
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Text(
                      item.partName ?? 'Unknown Item',
                      style: GoogleFonts.poppins(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: AppColors.textPrimary,
                      ),
                    ),
                  ),
                  if (hasPending)
                    Container(
                      padding: EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                      decoration: BoxDecoration(
                        color: AppColors.warningLight,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        'Pending',
                        style: GoogleFonts.poppins(
                          fontSize: 12,
                          color: AppColors.warningDark,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  if (!canReturn && !hasPending)
                    Container(
                      padding: EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                      decoration: BoxDecoration(
                        color: AppColors.gray200,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        'Not Available',
                        style: GoogleFonts.poppins(
                          fontSize: 12,
                          color: AppColors.gray600,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                ],
              ),
              SizedBox(height: 8),
              
              // Part code
              Text(
                'Code: ${item.partCode ?? 'N/A'}',
                style: GoogleFonts.poppins(fontSize: 13, color: AppColors.textSecondary),
              ),
              SizedBox(height: 4),
              
              // WO number
              Text(
                'WO: ${item.workOrderNo ?? 'N/A'}',
                style: GoogleFonts.poppins(fontSize: 13, color: AppColors.textSecondary),
              ),
              SizedBox(height: 12),
              
              // Quantity info chips
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  _buildQuantityChip(
                    'Collected',
                    (item.quantityCollected ?? 0).toString(),
                    AppColors.primary50,
                    AppColors.primary,
                  ),
                  _buildQuantityChip(
                    'In Possession',
                    (item.partsInPossession ?? 0).toString(),
                    AppColors.successLight,
                    AppColors.success,
                  ),
                  _buildQuantityChip(
                    'Available',
                    availableQty.toString(),
                    availableQty > 0 ? AppColors.accentLight : AppColors.gray200,
                    availableQty > 0 ? AppColors.accent : AppColors.gray600,
                  ),
                ],
              ),
              SizedBox(height: 12),
              
              // Collected date
              Row(
                children: [
                  Icon(Icons.calendar_today, size: 14, color: AppColors.gray500),
                  SizedBox(width: 6),
                  Text(
                    'Collected: ${_formatDate(item.collectedDate)}',
                    style: GoogleFonts.poppins(fontSize: 12, color: AppColors.textSecondary),
                  ),
                ],
              ),
              
              // Pending return info
              if (hasPending && item.pendingReturnQuantity != null) ...[
                SizedBox(height: 10),
                Container(
                  padding: EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: AppColors.warningLight,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: AppColors.warning, width: 1),
                  ),
                  child: Row(
                    children: [
                      Icon(Icons.hourglass_empty, size: 16, color: AppColors.warningDark),
                      SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          'Return pending: ${item.pendingReturnQuantity} items awaiting confirmation',
                          style: GoogleFonts.poppins(
                            fontSize: 12,
                            color: AppColors.warningDark,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
              
              // Return button
              if (canReturn) ...[
                SizedBox(height: 12),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    onPressed: () => _navigateToDetail(item),
                    icon: Icon(Icons.keyboard_return, size: 18),
                    label: Text(
                      'Return Items',
                      style: GoogleFonts.poppins(fontWeight: FontWeight.w600),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      foregroundColor: AppColors.onPrimary,
                      padding: EdgeInsets.symmetric(vertical: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
  
  Widget _buildQuantityChip(String label, String value, Color bgColor, Color textColor) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            '$label: ',
            style: GoogleFonts.poppins(fontSize: 11, color: textColor.withValues(alpha: 0.8)),
          ),
          Text(
            value,
            style: GoogleFonts.poppins(
              fontSize: 11,
              fontWeight: FontWeight.bold,
              color: textColor,
            ),
          ),
        ],
      ),
    );
  }
  
  String _formatDate(String? dateStr) {
    if (dateStr == null || dateStr.isEmpty) return 'N/A';
    try {
      DateTime date = DateTime.parse(dateStr);
      return DateFormat('dd MMM yyyy').format(date);
    } catch (e) {
      return dateStr;
    }
  }
  
  void _navigateToDetail(CollectedItem item) {
    Navigator.pushNamed(
      context,
      '/return-item-detail',
      arguments: item,
    ).then((_) => _refresh());
  }
  
  @override
  void dispose() {
    _bloc.dispose();
    super.dispose();
  }
}
