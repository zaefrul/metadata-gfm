import 'dart:convert';
import 'dart:io';

import 'package:GEMS/model/return_ticket_models.dart';
import 'package:GEMS/utils/network.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class ReturnTicketService {
  static const _listMobileReturn = "/api/wo_request.php/list_mobile_return";
  static const _listMobileReturnSummary =
      "/api/wo_request.php/list_mobile_return_summary";
  static const _returnParts = "/api/wo_request.php/return_parts";
  static const _listVerification = "/api/wo_request.php/list_return_verification";
  static const _verifyReturn = "/api/wo_request.php/verify_return";

  Future<List<ReturnPartInstance>> fetchCollectedItems() async {
    final provider = Provider(fetchURL: _listMobileReturn);
    final result = await provider.getJson(url: _listMobileReturn);
    if (result is List) {
      return result
          .map((e) => ReturnPartInstance.fromJson(e as Map<String, dynamic>))
          .toList(growable: false);
    }
    return [];
  }

  Future<List<ReturnQuantitySummary>> fetchCollectedSummary() async {
    final provider = Provider(fetchURL: _listMobileReturnSummary);
    final result = await provider.getJson(url: _listMobileReturnSummary);
    if (result is List) {
      return result
          .map((e) => ReturnQuantitySummary.fromJson(e as Map<String, dynamic>))
          .toList(growable: false);
    }
    return [];
  }

  Future<ReturnSubmissionResult> submitReturn({
    required List<ReturnPartsRequestItem> items,
  }) async {
    if (items.isEmpty) {
      throw Exception('No items selected for return');
    }

    final raw = await _postJson(_returnParts, {
      'items': items.map((e) => e.toJson()).toList(growable: false),
    });

    return ReturnSubmissionResult.fromJson(raw);
  }

  Future<List<ReturnTicketSummary>> fetchReturnTickets({
    bool includeDetails = false,
    String? siteId,
  }) async {
    final queryBuffer = StringBuffer(_listVerification);
    if (siteId != null && siteId.isNotEmpty) {
      queryBuffer.write('/site/$siteId');
    }
    if (includeDetails) {
      queryBuffer.write(queryBuffer.toString().contains('?') ? '&' : '?');
      queryBuffer.write('detail=1');
    }

    final path = queryBuffer.toString();
    final provider = Provider(fetchURL: path);
    final result = await provider.getJson(url: path);
    if (result is List) {
      return result
          .map((e) => ReturnTicketSummary.fromJson(e as Map<String, dynamic>))
          .toList(growable: false);
    }
    return [];
  }

  Future<ReturnVerifyResult> verifyTicket({
    required String returnTicketId,
    required String action,
    List<String>? partSubIds,
    String? remark,
  }) async {
    final payload = {
      'returnTicketId': returnTicketId,
      'returnId': returnTicketId,
      'action': action,
      if (partSubIds != null && partSubIds.isNotEmpty) 'partSubIds': partSubIds,
      if (remark != null && remark.isNotEmpty) 'remark': remark,
    };

    debugPrint('verify_return payload → ${json.encode(payload)}');

    final raw = await _postJson(_verifyReturn, payload);
    return ReturnVerifyResult.fromJson(raw);
  }

  Future<Map<String, dynamic>> _postJson(String path, Map<String, dynamic> body) async {
    final provider = Provider(fetchURL: path);
    await provider.init();

    final response = await http.post(
      Uri.parse(netDomain + path),
      headers: {
        HttpHeaders.contentTypeHeader: 'application/json',
        'Authorization': provider.token,
        'deviceid': provider.deviceID,
      },
      body: json.encode(body),
    );

    final decoded = json.decode(response.body) as Map<String, dynamic>;
    debugPrint('POST $path → ${response.statusCode}: ${response.body}');

    if (decoded['error'] == 'Signature verification failed' ||
        decoded['error'] == 'Device ID invalid with this login' ||
        decoded['error'] == 'Expired token') {
      provider.alert('Your session already expired, please relogin.');
    }

    if (response.statusCode == 200) {
      if (decoded['success'] == true) {
        final result = decoded['result'];
        if (result is Map<String, dynamic>) {
          return result;
        }
        throw Exception('Unexpected response shape');
      }
      throw Exception(decoded['errmsg'] ?? 'Request failed');
    }
    throw Exception('Server error ${response.statusCode}');
  }
}
