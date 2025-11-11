import 'package:flutter/foundation.dart';
import 'package:rxdart/rxdart.dart';
import 'package:GEMS/controller/Storekeeper/utils/bloc/bloc.dart';
import 'package:GEMS/model/return_item.dart';
import 'package:GEMS/utils/network.dart';
import 'package:GEMS/model/serializers.dart';
import 'package:GEMS/model/responseValue.dart';

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
  
  /// Load eligible items for technician
  Future<void> loadCollectedItems(String userId) => 
      checker(_fetchCollectedItems(userId));
  
  Future<void> _fetchCollectedItems(String userId) async {
    debugPrint("=== Return Items BLoC ===");
    debugPrint("Fetching collected items for user: $userId");
    
    Provider provider = Provider(fetchURL: "/api/m_inventory.php?action=return_eligible_items&id=$userId");
    await provider.init();
    ResponseValue response = await provider.fetch();
    
    if (response.success == true) {
      if (response.result != null && response.result is List && (response.result as List).isNotEmpty) {
        List<CollectedItem> items = [];
        
        for (var item in (response.result as List)) {
          items.add(serializers.deserializeWith(
            CollectedItem.serializer,
            item,
          )!);
        }
        
        debugPrint("Loaded ${items.length} collected items");
        _collectedItems.sink.add(items);
      } else {
        debugPrint("No collected items found");
        _collectedItems.sink.add([]);
      }
    } else {
      throw Exception(response.errmsg);
    }
  }
  
  /// Submit return request
  Future<String> submitReturn({
    required String woTaskPartsId,
    required int quantityReturned,
    required String returnReason,
    String? returnRemarks,
    String? returnDeadlineDate,
  }) async {
    return await checker(_submitReturnRequest(
      woTaskPartsId: woTaskPartsId,
      quantityReturned: quantityReturned,
      returnReason: returnReason,
      returnRemarks: returnRemarks,
      returnDeadlineDate: returnDeadlineDate,
    )) as String;
  }
  
  Future<String> _submitReturnRequest({
    required String woTaskPartsId,
    required int quantityReturned,
    required String returnReason,
    String? returnRemarks,
    String? returnDeadlineDate,
  }) async {
    Provider provider = Provider(fetchURL: "/api/m_inventory.php");
    await provider.init();
    
    Map<String, dynamic> body = {
      "action": "request_return",
      "woTaskPartsId": woTaskPartsId,
      "quantityReturned": quantityReturned.toString(),
      "returnReason": returnReason,
    };
    
    if (returnRemarks != null && returnRemarks.isNotEmpty) {
      body["returnRemarks"] = returnRemarks;
    }
    
    if (returnDeadlineDate != null && returnDeadlineDate.isNotEmpty) {
      body["returnDeadlineDate"] = returnDeadlineDate;
    }
    
    dynamic response = await provider.post(
      url: "/api/m_inventory.php",
      body: body,
    );
    
    // Post method returns ResponseValue on success or throws error
    if (response is ResponseValue) {
      return response.result.toString(); // Returns return_id
    } else {
      return response.toString(); // Returns the errmsg from successful post
    }
  }
  
  /// Load pending returns for storekeeper
  Future<void> loadPendingReturns() => 
      checker(_fetchPendingReturns());
  
  Future<void> _fetchPendingReturns() async {
    Provider provider = Provider(fetchURL: "/api/m_inventory.php?action=storekeeper_pending_returns");
    await provider.init();
    ResponseValue response = await provider.fetch();
    
    if (response.success == true) {
      if (response.result != null && (response.result as List).isNotEmpty) {
        List<PendingReturn> returns = [];
        
        for (var item in (response.result as List)) {
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
      throw Exception(response.errmsg);
    }
  }
  
  /// Get return detail
  Future<PendingReturn> getReturnDetail(String returnId) async {
    return await checker(_fetchReturnDetail(returnId)) as PendingReturn;
  }
  
  Future<PendingReturn> _fetchReturnDetail(String returnId) async {
    Provider provider = Provider(fetchURL: "/api/m_inventory.php?action=return_detail&id=$returnId");
    await provider.init();
    ResponseValue response = await provider.fetch();
    
    if (response.success == true && response.result != null) {
      return serializers.deserializeWith(
        PendingReturn.serializer,
        response.result,
      )!;
    } else {
      throw Exception(response.errmsg);
    }
  }
  
  /// Confirm return receipt (storekeeper)
  Future<void> confirmReturn(String returnId) => 
      checker(_confirmReturnReceipt(returnId));
  
  Future<void> _confirmReturnReceipt(String returnId) async {
    Provider provider = Provider(fetchURL: "/api/m_inventory.php");
    await provider.init();
    
    await provider.put(body: {
      "action": "confirm_return",
      "id": returnId,
    });
    
    // If no exception thrown, operation was successful
    // Provider.put throws error on failure
  }
  
  /// Get return statistics (optional)
  Future<Map<String, dynamic>> getStatistics({String? userId}) async {
    return await checker(_fetchStatistics(userId)) as Map<String, dynamic>;
  }
  
  Future<Map<String, dynamic>> _fetchStatistics(String? userId) async {
    String url = "/api/m_inventory.php?action=return_statistics";
    if (userId != null) {
      url += "&userId=$userId";
    }
    
    Provider provider = Provider(fetchURL: url);
    await provider.init();
    ResponseValue response = await provider.fetch();
    
    if (response.success == true && response.result != null) {
      return response.result as Map<String, dynamic>;
    } else {
      throw Exception(response.errmsg);
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
