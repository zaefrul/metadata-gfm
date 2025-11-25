import 'package:flutter/material.dart';
import 'package:GEMS/controller/ReturnItem/bloc/bloc_return.dart';
import 'package:GEMS/model/return_ticket_models.dart';
import 'package:GEMS/utils/reference.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:toast/toast.dart';

class ReturnItemList extends StatefulWidget {
  const ReturnItemList({super.key});

  @override
  State<ReturnItemList> createState() => _ReturnItemListState();
}

class _ReturnItemListState extends State<ReturnItemList> {
  final ReturnItemBloc _bloc = ReturnItemBloc();
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';
  
  @override
  void initState() {
    super.initState();
    _bloc.loadCollectedItems();
    _searchController.addListener(_onSearchChanged);
  }
  
  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    ToastContext().init(context);
  }

  void _onSearchChanged() {
    final value = _searchController.text.trim().toLowerCase();
    if (value != _searchQuery) {
      setState(() {
        _searchQuery = value;
      });
    }
  }

  Future<void> _refresh() async {
    await _bloc.loadCollectedItems();
  }

  List<ReturnPartGroup> _applySearch(List<ReturnPartGroup> items) {
    if (_searchQuery.isEmpty) return items;
    return items.where((item) {
      final needle = _searchQuery;
      bool contains(String? value) =>
          value != null && value.toLowerCase().contains(needle);
      return contains(item.itemDescription) ||
          contains(item.partId) ||
          item.instances.any((instance) =>
              contains(instance.partSubNo) ||
              contains(instance.partSubId) ||
              contains(instance.woTaskNo) ||
              contains(instance.woTaskRequestNo));
    }).toList(growable: false);
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
              
              return StreamBuilder<List<ReturnPartGroup>>(
                stream: _bloc.collectedItems$,
                builder: (context, snapshot) {
                  if (isLoading && (!snapshot.hasData || snapshot.data!.isEmpty)) {
                    return Center(child: CircularProgressIndicator(color: AppColors.primary));
                  }
                  
                  List<ReturnPartGroup> items = snapshot.data ?? [];
                  final filtered = _applySearch(items);
                  final bool hasItems = items.isNotEmpty;
                  final bool hasResults = filtered.isNotEmpty;

                  return Column(
                    children: [
                      _buildSearchField(),
                      Expanded(
                        child: RefreshIndicator(
                          onRefresh: _refresh,
                          color: AppColors.primary,
                          child: hasResults
                              ? ListView.builder(
                                  padding: EdgeInsets.symmetric(
                                      horizontal: 16, vertical: 12),
                                  itemCount: filtered.length,
                                  itemBuilder: (context, index) {
                                    return _buildItemCard(filtered[index]);
                                  },
                                )
                              : _buildEmptyScrollable(
                                  title: hasItems
                                      ? 'No Results'
                                      : 'No Collected Items',
                                  subtitle: hasItems
                                      ? 'Try a different keyword'
                                      : 'Items you collect will appear here',
                                ),
                        ),
                      ),
                    ],
                  );
                },
              );
            },
          );
        },
      ),
    );
  }
  
  Widget _buildEmptyState({String title = 'No Collected Items', String subtitle = 'Items you collect will appear here'}) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.inventory_2_outlined, size: 80, color: AppColors.gray400),
          SizedBox(height: 16),
          Text(
            title,
            style: GoogleFonts.poppins(fontSize: 18, color: AppColors.gray600, fontWeight: FontWeight.w500),
          ),
          SizedBox(height: 8),
          Text(
            subtitle,
            style: GoogleFonts.poppins(fontSize: 14, color: AppColors.gray500),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyScrollable({required String title, required String subtitle}) {
    return ListView(
      physics: const AlwaysScrollableScrollPhysics(),
      padding: EdgeInsets.symmetric(horizontal: 16, vertical: 80),
      children: [
        _buildEmptyState(title: title, subtitle: subtitle),
      ],
    );
  }

  Widget _buildSearchField() {
    return Padding(
      padding: EdgeInsets.fromLTRB(16, 8, 16, 0),
      child: TextField(
        controller: _searchController,
        decoration: InputDecoration(
          hintText: 'Search by item, serial, WO, or MR...',
          prefixIcon: Icon(Icons.search, color: AppColors.gray500),
          suffixIcon: _searchQuery.isEmpty
              ? null
              : IconButton(
                  icon: Icon(Icons.clear, color: AppColors.gray500),
                  onPressed: () {
                    _searchController.clear();
                    _onSearchChanged();
                  },
                ),
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
          contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        ),
      ),
    );
  }
  
  Widget _buildItemCard(ReturnPartGroup group) {
    final bool canReturn = group.totalAvailable > 0;
    final hasSerialized = group.hasSerialized;
    
    return Card(
      margin: EdgeInsets.only(bottom: 12),
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: canReturn ? () => _navigateToDetail(group) : null,
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
                      group.itemDescription,
                      style: GoogleFonts.poppins(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: AppColors.textPrimary,
                      ),
                    ),
                  ),
                  Container(
                    padding:
                        EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                    decoration: BoxDecoration(
                      color: canReturn
                          ? AppColors.successLight
                          : AppColors.gray200,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      canReturn ? 'Available' : 'Unavailable',
                      style: GoogleFonts.poppins(
                        fontSize: 12,
                        color: canReturn
                            ? AppColors.successDark
                            : AppColors.gray600,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),
              SizedBox(height: 8),
              
              // Part code
              Row(
                children: [
                  _buildStatChip('Available', group.totalAvailable.toString(),
                      AppColors.success),
                  SizedBox(width: 8),
                  _buildStatChip(
                      'Collected', group.totalCollected.toString(), AppColors.primary),
                  SizedBox(width: 8),
                  _buildStatChip('Returned', group.totalReturned.toString(),
                      AppColors.warning),
                ],
              ),
              if (hasSerialized) ...[
                SizedBox(height: 12),
                Text(
                  '${group.serializedInstances.length} serial item(s) pending',
                  style: GoogleFonts.poppins(fontSize: 12, color: AppColors.gray600),
                ),
              ],
              
              // Return button
              if (canReturn) ...[
                SizedBox(height: 12),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    onPressed: () => _navigateToDetail(group),
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
  
  void _navigateToDetail(ReturnPartGroup group) {
    Navigator.pushNamed(
      context,
      '/return-item-detail',
      arguments: group,
    ).then((_) => _refresh());
  }

  Widget _buildStatChip(String label, String value, Color color) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.12),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(label,
                style: GoogleFonts.poppins(fontSize: 11, color: color)),
            SizedBox(height: 4),
            Text(
              value,
              style: GoogleFonts.poppins(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: color,
              ),
            ),
          ],
        ),
      ),
    );
  }
  
  @override
  void dispose() {
    _bloc.dispose();
    _searchController.dispose();
    super.dispose();
  }
}
