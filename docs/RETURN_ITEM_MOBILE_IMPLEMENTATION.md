# Return Item Module - Mobile Implementation Guide

> **Status**: Ready to Implement  
> **Backend**: ✅ Complete (API v1.0.0)  
> **Mobile**: 🚧 In Progress  
> **Updated**: 10 November 2025

---

## 📋 Implementation Checklist

### Phase 1: Models & Serialization (Day 1)
- [ ] Create `lib/model/return_item.dart` with built_value models
- [ ] Register serializers in `lib/model/serializers.dart`
- [ ] Run code generation: `flutter pub run build_runner build --delete-conflicting-outputs`
- [ ] Test model serialization/deserialization

### Phase 2: BLoC & Repository (Day 1-2)
- [ ] Create `lib/controller/ReturnItem/bloc/bloc_return.dart`
- [ ] Implement API calls using Provider pattern
- [ ] Add streams for state management
- [ ] Add error handling with toast messages

### Phase 3: Technician Screens (Day 2-3)
- [ ] Create `lib/controller/ReturnItem/return_item_list.dart`
- [ ] Create `lib/controller/ReturnItem/return_item_detail.dart`
- [ ] Add navigation routes to `main.dart`
- [ ] Add menu item to technician drawer

### Phase 4: Storekeeper Screens (Day 3-4)
- [ ] Create `lib/controller/ReturnItem/return_confirm_list.dart`
- [ ] Create `lib/controller/ReturnItem/return_confirm_detail.dart`
- [ ] Add badge counter to storekeeper homepage
- [ ] Integrate pending returns tab

### Phase 5: Testing & Polish (Day 4-5)
- [ ] Test full workflow: eligible items → submit → pending → confirm
- [ ] Test partial returns (batch returns)
- [ ] Test error scenarios (invalid quantity, duplicate, etc.)
- [ ] Add loading indicators and empty states
- [ ] Add pull-to-refresh on lists

---

## 🗄️ Data Models

### 1. CollectedItem Model

```dart
// lib/model/return_item.dart
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'return_item.g.dart';

abstract class CollectedItem implements Built<CollectedItem, CollectedItemBuilder> {
  CollectedItem._();
  
  factory CollectedItem([void Function(CollectedItemBuilder) updates]) = _$CollectedItem;
  
  @BuiltValueField(wireName: 'woTaskPartsId')
  String get woTaskPartsId;
  
  @BuiltValueField(wireName: 'partId')
  String get partId;
  
  @BuiltValueField(wireName: 'partName')
  String get partName;
  
  @BuiltValueField(wireName: 'partCode')
  String get partCode;
  
  @BuiltValueField(wireName: 'quantityCollected')
  int get quantityCollected;
  
  @BuiltValueField(wireName: 'technicianId')
  String get technicianId;
  
  @BuiltValueField(wireName: 'collectedDate')
  String get collectedDate;
  
  @BuiltValueField(wireName: 'workOrderNo')
  String get workOrderNo;
  
  @BuiltValueField(wireName: 'partsInPossession')
  int get partsInPossession;
  
  @BuiltValueField(wireName: 'quantityAlreadyReturned')
  int get quantityAlreadyReturned;
  
  @BuiltValueField(wireName: 'quantityAvailableToReturn')
  int get quantityAvailableToReturn;
  
  @BuiltValueField(wireName: 'hasPendingReturn')
  bool get hasPendingReturn;
  
  @BuiltValueField(wireName: 'pendingReturnId')
  String? get pendingReturnId;
  
  @BuiltValueField(wireName: 'pendingReturnQuantity')
  int? get pendingReturnQuantity;
  
  static Serializer<CollectedItem> get serializer => _$collectedItemSerializer;
}
```

### 2. ReturnRequest Model

```dart
abstract class ReturnRequest implements Built<ReturnRequest, ReturnRequestBuilder> {
  ReturnRequest._();
  
  factory ReturnRequest([void Function(ReturnRequestBuilder) updates]) = _$ReturnRequest;
  
  @BuiltValueField(wireName: 'woTaskPartsId')
  String get woTaskPartsId;
  
  @BuiltValueField(wireName: 'quantityReturned')
  int get quantityReturned;
  
  @BuiltValueField(wireName: 'returnReason')
  String get returnReason;
  
  @BuiltValueField(wireName: 'returnRemarks')
  String? get returnRemarks;
  
  @BuiltValueField(wireName: 'returnDeadlineDate')
  String? get returnDeadlineDate;
  
  static Serializer<ReturnRequest> get serializer => _$returnRequestSerializer;
}
```

### 3. PendingReturn Model

```dart
abstract class PendingReturn implements Built<PendingReturn, PendingReturnBuilder> {
  PendingReturn._();
  
  factory PendingReturn([void Function(PendingReturnBuilder) updates]) = _$PendingReturn;
  
  @BuiltValueField(wireName: 'returnId')
  String get returnId;
  
  @BuiltValueField(wireName: 'woTaskPartsId')
  String get woTaskPartsId;
  
  @BuiltValueField(wireName: 'partId')
  String get partId;
  
  @BuiltValueField(wireName: 'technicianUserId')
  String get technicianUserId;
  
  @BuiltValueField(wireName: 'quantityReturned')
  int get quantityReturned;
  
  @BuiltValueField(wireName: 'returnStatus')
  String get returnStatus;
  
  @BuiltValueField(wireName: 'returnReason')
  String get returnReason;
  
  @BuiltValueField(wireName: 'returnRemarks')
  String? get returnRemarks;
  
  @BuiltValueField(wireName: 'returnRequestDate')
  String get returnRequestDate;
  
  @BuiltValueField(wireName: 'returnDeadlineDate')
  String? get returnDeadlineDate;
  
  @BuiltValueField(wireName: 'returnConfirmedDate')
  String? get returnConfirmedDate;
  
  @BuiltValueField(wireName: 'storekeeperUserId')
  String? get storekeeperUserId;
  
  @BuiltValueField(wireName: 'partName')
  String get partName;
  
  @BuiltValueField(wireName: 'partCode')
  String get partCode;
  
  @BuiltValueField(wireName: 'partUnit')
  String? get partUnit;
  
  @BuiltValueField(wireName: 'technicianName')
  String get technicianName;
  
  @BuiltValueField(wireName: 'workOrderNo')
  String get workOrderNo;
  
  @BuiltValueField(wireName: 'siteName')
  String? get siteName;
  
  static Serializer<PendingReturn> get serializer => _$pendingReturnSerializer;
}
```

### 4. Register Serializers

```dart
// lib/model/serializers.dart
// Add to the existing serializers list:

@SerializersFor([
  // ... existing models ...
  CollectedItem,
  ReturnRequest,
  PendingReturn,
])
```

---

## 🧱 BLoC Implementation

### ReturnItemBloc

```dart
// lib/controller/ReturnItem/bloc/bloc_return.dart

import 'package:rxdart/rxdart.dart';
import 'package:GEMS/controller/Storekeeper/utils/bloc/bloc.dart';
import 'package:GEMS/model/return_item.dart';
import 'package:GEMS/utils/network.dart';
import 'package:GEMS/model/serializers.dart';
import 'dart:convert';

class ReturnItemBloc extends Bloc {
  // Streams
  final BehaviorSubject<List<CollectedItem>> _collectedItems = 
      BehaviorSubject.seeded([]);
  final BehaviorSubject<List<PendingReturn>> _pendingReturns = 
      BehaviorSubject.seeded([]);
  final BehaviorSubject<int> _pendingCount = 
      BehaviorSubject.seeded(0);
  
  // Stream getters
  Stream<List<CollectedItem>> get collectedItems$ => _collectedItems.stream;
  Stream<List<PendingReturn>> get pendingReturns$ => _pendingReturns.stream;
  Stream<int> get pendingCount$ => _pendingCount.stream;
  
  // Base URL for return endpoints
  final String _baseUrl = "/api/m_inventory.php";
  
  /// Load eligible items for technician
  Future<void> loadCollectedItems(String userId) => 
      checker(_fetchCollectedItems(userId));
  
  Future<void> _fetchCollectedItems(String userId) async {
    Provider provider = Provider(fetchURL: "$_baseUrl/return_eligible_items/$userId");
    await provider.init();
    ResponseValue response = await provider.fetch();
    
    if (response.success) {
      if (response.result != null && response.result.isNotEmpty) {
        List<CollectedItem> items = [];
        
        for (var item in response.result) {
          items.add(serializers.deserializeWith(
            CollectedItem.serializer,
            item,
          )!);
        }
        
        _collectedItems.sink.add(items);
      } else {
        _collectedItems.sink.add([]);
      }
    } else {
      throw Exception(response.errmsg ?? "Failed to load collected items");
    }
  }
  
  /// Submit return request
  Future<String> submitReturn({
    required String woTaskPartsId,
    required int quantityReturned,
    required String returnReason,
    String? returnRemarks,
    String? returnDeadlineDate,
  }) => checker(_submitReturnRequest(
    woTaskPartsId: woTaskPartsId,
    quantityReturned: quantityReturned,
    returnReason: returnReason,
    returnRemarks: returnRemarks,
    returnDeadlineDate: returnDeadlineDate,
  ));
  
  Future<String> _submitReturnRequest({
    required String woTaskPartsId,
    required int quantityReturned,
    required String returnReason,
    String? returnRemarks,
    String? returnDeadlineDate,
  }) async {
    Provider provider = Provider(fetchURL: "$_baseUrl/request_return");
    await provider.init();
    
    Map<String, dynamic> body = {
      "woTaskPartsId": woTaskPartsId,
      "quantityReturned": quantityReturned,
      "returnReason": returnReason,
    };
    
    if (returnRemarks != null && returnRemarks.isNotEmpty) {
      body["returnRemarks"] = returnRemarks;
    }
    
    if (returnDeadlineDate != null && returnDeadlineDate.isNotEmpty) {
      body["returnDeadlineDate"] = returnDeadlineDate;
    }
    
    ResponseValue response = await provider.post(
      url: "$_baseUrl/request_return",
      body: body,
    );
    
    if (response.success) {
      return response.result.toString(); // Returns return_id
    } else {
      throw Exception(response.error ?? "Failed to submit return request");
    }
  }
  
  /// Load pending returns for storekeeper
  Future<void> loadPendingReturns() => 
      checker(_fetchPendingReturns());
  
  Future<void> _fetchPendingReturns() async {
    Provider provider = Provider(fetchURL: "$_baseUrl/storekeeper_pending_returns");
    await provider.init();
    ResponseValue response = await provider.fetch();
    
    if (response.success) {
      if (response.result != null && response.result.isNotEmpty) {
        List<PendingReturn> returns = [];
        
        for (var item in response.result) {
          returns.add(serializers.deserializeWith(
            PendingReturn.serializer,
            item,
          )!);
        }
        
        _pendingReturns.sink.add(returns);
        _pendingCount.sink.add(returns.length);
      } else {
        _pendingReturns.sink.add([]);
        _pendingCount.sink.add(0);
      }
    } else {
      throw Exception(response.errmsg ?? "Failed to load pending returns");
    }
  }
  
  /// Get return detail
  Future<PendingReturn> getReturnDetail(String returnId) => 
      checker(_fetchReturnDetail(returnId));
  
  Future<PendingReturn> _fetchReturnDetail(String returnId) async {
    Provider provider = Provider(fetchURL: "$_baseUrl/return_detail/$returnId");
    await provider.init();
    ResponseValue response = await provider.fetch();
    
    if (response.success && response.result != null) {
      return serializers.deserializeWith(
        PendingReturn.serializer,
        response.result,
      )!;
    } else {
      throw Exception(response.errmsg ?? "Failed to load return details");
    }
  }
  
  /// Confirm return receipt (storekeeper)
  Future<void> confirmReturn(String returnId) => 
      checker(_confirmReturnReceipt(returnId));
  
  Future<void> _confirmReturnReceipt(String returnId) async {
    Provider provider = Provider(fetchURL: "$_baseUrl/confirm_return/$returnId");
    await provider.init();
    
    ResponseValue response = await provider.put(
      url: "$_baseUrl/confirm_return/$returnId",
      body: {},
    );
    
    if (!response.success) {
      throw Exception(response.error ?? "Failed to confirm return");
    }
  }
  
  /// Get return statistics
  Future<Map<String, dynamic>> getStatistics({String? userId}) => 
      checker(_fetchStatistics(userId));
  
  Future<Map<String, dynamic>> _fetchStatistics(String? userId) async {
    String url = "$_baseUrl/return_statistics";
    if (userId != null) {
      url += "?userId=$userId";
    }
    
    Provider provider = Provider(fetchURL: url);
    await provider.init();
    ResponseValue response = await provider.fetch();
    
    if (response.success && response.result != null) {
      return response.result as Map<String, dynamic>;
    } else {
      throw Exception(response.errmsg ?? "Failed to load statistics");
    }
  }
  
  @override
  void dispose() {
    _collectedItems.close();
    _pendingReturns.close();
    _pendingCount.close();
    super.dispose();
  }
}
```

---

## 🎨 UI Screens

### 1. Return Item List (Technician)

```dart
// lib/controller/ReturnItem/return_item_list.dart

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
    _user = await User.getPrefUser();
    if (_user != null) {
      _bloc.loadCollectedItems(_user!.userId!);
    }
  }
  
  Future<void> _refresh() async {
    if (_user != null) {
      await _bloc.loadCollectedItems(_user!.userId!);
    }
  }
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Return Items', style: GoogleFonts.poppins()),
        backgroundColor: AppColors.primaryColor,
      ),
      body: StreamBuilder<bool>(
        stream: _bloc.loadingState$,
        builder: (context, loadingSnapshot) {
          bool isLoading = loadingSnapshot.data ?? false;
          
          return StreamBuilder<List<CollectedItem>>(
            stream: _bloc.collectedItems$,
            builder: (context, snapshot) {
              if (isLoading && !snapshot.hasData) {
                return Center(child: CircularProgressIndicator());
              }
              
              List<CollectedItem> items = snapshot.data ?? [];
              
              if (items.isEmpty) {
                return _buildEmptyState();
              }
              
              return RefreshIndicator(
                onRefresh: _refresh,
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
      ),
    );
  }
  
  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.inventory_2_outlined, size: 80, color: Colors.grey),
          SizedBox(height: 16),
          Text(
            'No Collected Items',
            style: GoogleFonts.poppins(fontSize: 18, color: Colors.grey),
          ),
          SizedBox(height: 8),
          Text(
            'Items you collect will appear here',
            style: GoogleFonts.poppins(fontSize: 14, color: Colors.grey[400]),
          ),
        ],
      ),
    );
  }
  
  Widget _buildItemCard(CollectedItem item) {
    bool hasPending = item.hasPendingReturn;
    int availableQty = item.quantityAvailableToReturn;
    
    return Card(
      margin: EdgeInsets.only(bottom: 12),
      elevation: 2,
      child: InkWell(
        onTap: hasPending || availableQty == 0 
            ? null 
            : () => _navigateToDetail(item),
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
                      item.partName,
                      style: GoogleFonts.poppins(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                  if (hasPending)
                    Container(
                      padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: Colors.orange[100],
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        'Pending',
                        style: GoogleFonts.poppins(
                          fontSize: 12,
                          color: Colors.orange[800],
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                ],
              ),
              SizedBox(height: 8),
              
              // Part code
              Text(
                'Code: ${item.partCode}',
                style: GoogleFonts.poppins(fontSize: 13, color: Colors.grey[600]),
              ),
              SizedBox(height: 4),
              
              // WO number
              Text(
                'WO: ${item.workOrderNo}',
                style: GoogleFonts.poppins(fontSize: 13, color: Colors.grey[600]),
              ),
              SizedBox(height: 12),
              
              // Quantity info
              Row(
                children: [
                  _buildQuantityChip(
                    'Collected',
                    item.quantityCollected.toString(),
                    Colors.blue[100]!,
                    Colors.blue[800]!,
                  ),
                  SizedBox(width: 8),
                  _buildQuantityChip(
                    'In Possession',
                    item.partsInPossession.toString(),
                    Colors.green[100]!,
                    Colors.green[800]!,
                  ),
                  SizedBox(width: 8),
                  _buildQuantityChip(
                    'Available',
                    availableQty.toString(),
                    availableQty > 0 ? Colors.purple[100]! : Colors.grey[200]!,
                    availableQty > 0 ? Colors.purple[800]! : Colors.grey[600]!,
                  ),
                ],
              ),
              SizedBox(height: 8),
              
              // Collected date
              Row(
                children: [
                  Icon(Icons.calendar_today, size: 14, color: Colors.grey),
                  SizedBox(width: 4),
                  Text(
                    'Collected: ${_formatDate(item.collectedDate)}',
                    style: GoogleFonts.poppins(fontSize: 12, color: Colors.grey),
                  ),
                ],
              ),
              
              // Pending return info
              if (hasPending && item.pendingReturnQuantity != null) ...[
                SizedBox(height: 8),
                Row(
                  children: [
                    Icon(Icons.hourglass_empty, size: 14, color: Colors.orange),
                    SizedBox(width: 4),
                    Text(
                      'Pending return: ${item.pendingReturnQuantity} items',
                      style: GoogleFonts.poppins(
                        fontSize: 12,
                        color: Colors.orange[800],
                        fontStyle: FontStyle.italic,
                      ),
                    ),
                  ],
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
      padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            '$label: ',
            style: GoogleFonts.poppins(fontSize: 11, color: textColor),
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
  
  String _formatDate(String dateStr) {
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
```

---

## 🔌 Navigation Setup

Add to `main.dart`:

```dart
case '/return-item-list':
  return MaterialPageRoute(builder: (context) => ReturnItemList());

case '/return-item-detail':
  final CollectedItem item = settings.arguments as CollectedItem;
  return MaterialPageRoute(
    builder: (context) => ReturnItemDetail(item: item),
  );

case '/return-confirm-list':
  return MaterialPageRoute(builder: (context) => ReturnConfirmList());

case '/return-confirm-detail':
  final String returnId = settings.arguments as String;
  return MaterialPageRoute(
    builder: (context) => ReturnConfirmDetail(returnId: returnId),
  );
```

---

## 🔧 Provider Extension (if needed)

The existing `Provider` class should already support PUT requests. If not, add:

```dart
// lib/utils/network.dart

Future<ResponseValue> put({
  required String url,
  required Map<String, dynamic> body,
}) async {
  try {
    final response = await http.put(
      Uri.parse("$netDomain$url"),
      headers: headers,
      body: json.encode(body),
    );
    
    return _parseResponse(response);
  } catch (e) {
    return ResponseValue(success: false, errmsg: e.toString());
  }
}
```

---

## 🎯 Next Steps

1. **Create models** (Day 1 morning)
2. **Implement BLoC** (Day 1 afternoon)
3. **Build technician screens** (Day 2)
4. **Build storekeeper screens** (Day 3)
5. **Testing & polish** (Day 4-5)

Ready to start? Let me know which phase you'd like to begin with! 🚀
