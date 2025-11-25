import 'package:flutter/foundation.dart';
import 'package:rxdart/rxdart.dart';
import 'package:GEMS/controller/Storekeeper/utils/bloc/bloc.dart';
import 'package:GEMS/model/return_ticket_models.dart';

import '../return_ticket_service.dart';

class ReturnItemBloc extends Bloc {
  final ReturnTicketService _service = ReturnTicketService();

  final BehaviorSubject<List<ReturnPartGroup>> _collectedItems =
      BehaviorSubject.seeded(const <ReturnPartGroup>[]);
    final BehaviorSubject<List<ReturnTicketSummary>> _pendingReturns =
      BehaviorSubject.seeded(const <ReturnTicketSummary>[]);
  final BehaviorSubject<int> _pendingCount = BehaviorSubject.seeded(0);

  Stream<List<ReturnPartGroup>> get collectedItems$ => _collectedItems.stream;
  Stream<List<ReturnTicketSummary>> get pendingReturns$ => _pendingReturns.stream;
  Stream<int> get pendingCount$ => _pendingCount.stream;

  Future<void> loadCollectedItems() => checker(_fetchCollectedItems());

  Future<void> _fetchCollectedItems() async {
    debugPrint('Fetching collected part instances (ReturnTicketService)');
    final itemsFuture = _service.fetchCollectedItems();
    final summaryFuture = _service.fetchCollectedSummary();

    final items = await itemsFuture;
    final summary = await summaryFuture;

    final List<ReturnPartInstance> serializedItems =
        items.where((item) => item.isSerialized).toList(growable: true);
    final List<ReturnPartInstance> quantityItems = summary
        .where((entry) => entry.quantityAvailableToReturn > 0)
        .map(ReturnPartInstance.fromSummary)
        .toList(growable: true);

    final combined = <ReturnPartInstance>[
      ...serializedItems,
      ...quantityItems,
    ];

    final groups = _groupByPart(combined);
    _collectedItems.sink.add(groups);
  }

  List<ReturnPartGroup> _groupByPart(List<ReturnPartInstance> items) {
    if (items.isEmpty) return const <ReturnPartGroup>[];

    final Map<String, List<ReturnPartInstance>> grouped = {};
    for (final item in items) {
      final key = '${item.partId}::${item.itemDescription}';
      grouped.putIfAbsent(key, () => <ReturnPartInstance>[]).add(item);
    }

    final groups = grouped.values.map((instances) {
      instances.sort((a, b) => _compareCheckout(a.checkOutTime, b.checkOutTime));
      final first = instances.first;
      return ReturnPartGroup(
        partId: first.partId,
        itemDescription: first.itemDescription,
        instances: List.unmodifiable(instances),
      );
    }).toList(growable: false);

    groups.sort((a, b) => a.itemDescription
        .toLowerCase()
        .compareTo(b.itemDescription.toLowerCase()));
    return groups;
  }

  int _compareCheckout(String? a, String? b) {
    if (a == null && b == null) return 0;
    if (a == null) return 1;
    if (b == null) return -1;
    final dateA = DateTime.tryParse(a);
    final dateB = DateTime.tryParse(b);
    if (dateA == null && dateB == null) return 0;
    if (dateA == null) return 1;
    if (dateB == null) return -1;
    return dateA.compareTo(dateB);
  }

  Future<ReturnSubmissionResult> submitReturnByPartSub({
    required List<String> partSubIds,
    required String returnReason,
    String? returnRemarks,
  }) async {
    final payload = [
      ReturnPartsRequestItem(
        partSubIds: partSubIds,
        returnReason: returnReason,
        returnRemarks: returnRemarks,
      ),
    ];

    return await checker(
      _service.submitReturn(items: payload),
    ) as ReturnSubmissionResult;
  }

  Future<ReturnSubmissionResult> submitReturnByQuantity({
    required String woTaskPartsId,
    required int quantity,
    required String returnReason,
    String? returnRemarks,
  }) async {
    final payload = [
      ReturnPartsRequestItem(
        woTaskPartsId: woTaskPartsId,
        quantity: quantity,
        returnReason: returnReason,
        returnRemarks: returnRemarks,
      ),
    ];

    return await checker(
      _service.submitReturn(items: payload),
    ) as ReturnSubmissionResult;
  }

  Future<ReturnSubmissionResult> submitGroupedReturn({
    required ReturnPartGroup group,
    required int quantity,
    required String returnReason,
    String? returnRemarks,
  }) async {
    final payload = _buildGroupedPayload(
      group: group,
      quantity: quantity,
      returnReason: returnReason,
      returnRemarks: returnRemarks,
    );

    final result = await checker(
      _service.submitReturn(items: payload),
    ) as ReturnSubmissionResult;

    await loadCollectedItems();
    return result;
  }

  List<ReturnPartsRequestItem> _buildGroupedPayload({
    required ReturnPartGroup group,
    required int quantity,
    required String returnReason,
    String? returnRemarks,
  }) {
    int remaining = quantity;
    if (remaining <= 0) {
      throw Exception('Quantity must be greater than zero');
    }

    final List<ReturnPartsRequestItem> payload = [];

    final serialized = group.serializedInstances.toList(growable: false)
      ..sort((a, b) => _compareCheckout(a.checkOutTime, b.checkOutTime));

    final Map<String, List<String>> serialsByRequest = {};
    for (final instance in serialized) {
      if (remaining == 0) break;
      if (instance.quantityAvailableToReturn <= 0) {
        continue;
      }
      serialsByRequest
          .putIfAbsent(instance.woTaskPartsId, () => <String>[])
          .add(instance.partSubId);
      remaining -= 1;
    }

    serialsByRequest.forEach((_, partSubIds) {
      payload.add(ReturnPartsRequestItem(
        partSubIds: partSubIds,
        returnReason: returnReason,
        returnRemarks: returnRemarks,
      ));
    });

    if (remaining > 0) {
      final bulk = group.bulkBuckets.toList(growable: false)
        ..sort((a, b) => _compareCheckout(a.checkOutTime, b.checkOutTime));

      for (final bucket in bulk) {
        if (remaining == 0) break;
        final available = bucket.quantityAvailableToReturn;
        if (available <= 0) continue;
        final take = remaining < available ? remaining : available;
        payload.add(ReturnPartsRequestItem(
          woTaskPartsId: bucket.woTaskPartsId,
          quantity: take,
          returnReason: returnReason,
          returnRemarks: returnRemarks,
        ));
        remaining -= take;
      }
    }

    if (remaining > 0) {
      throw Exception('Not enough items available to return for ${group.itemDescription}');
    }

    return payload;
  }

  Future<void> loadPendingReturns({bool includeDetails = true}) =>
      checker(_fetchPendingReturns(includeDetails: includeDetails));

  Future<void> _fetchPendingReturns({bool includeDetails = true}) async {
    final tickets =
        await _service.fetchReturnTickets(includeDetails: includeDetails);
    _pendingReturns.sink.add(tickets);
    _pendingCount.sink.add(tickets.length);
  }

  ReturnTicketSummary? findTicket(String ticketId) {
    try {
      return _pendingReturns.value
          .firstWhere((e) => e.returnTicketId == ticketId);
    } catch (_) {
      return null;
    }
  }

  Future<ReturnTicketSummary?> refreshAndFind(String ticketId) async {
    await loadPendingReturns(includeDetails: true);
    return findTicket(ticketId);
  }

  Future<ReturnVerifyResult> verifyTicket({
    required String ticketId,
    required String action,
    List<String>? partSubIds,
    String? remark,
  }) async {
    final result = await checker(
      _service.verifyTicket(
        returnTicketId: ticketId,
        action: action,
        partSubIds: partSubIds,
        remark: remark,
      ),
    ) as ReturnVerifyResult;

    // Refresh local cache after verification so list reflects new status
    await loadPendingReturns(includeDetails: true);
    return result;
  }
  
  @override
  void dispose() {
    _collectedItems.close();
    _pendingReturns.close();
    _pendingCount.close();
    super.dispose();
  }
}
