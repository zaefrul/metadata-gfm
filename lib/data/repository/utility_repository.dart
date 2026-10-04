import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:GEMS/data/local/offline_database.dart';
import 'package:GEMS/model/energy.dart';
import 'package:GEMS/model/meter.dart';
import 'package:GEMS/model/serializers.dart';
import 'package:GEMS/model/user.dart';
import 'package:GEMS/utils/network.dart';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:rxdart/rxdart.dart';
import 'package:uuid/uuid.dart';

const _energyReading = 'energy_reading';
const _waterReading = 'water_reading';
const _cacheEnergyMe = 'energy_me';
const _cacheEnergyMeter = 'energy_meter';
const _cacheWaterMeter = 'water_meter';

enum UtilitySaveStatus { saved, queued, rejected }

class UtilitySaveResult {
  const UtilitySaveResult(this.status, this.message);

  final UtilitySaveStatus status;
  final String message;

  bool get saved => status == UtilitySaveStatus.saved;
  bool get queued => status == UtilitySaveStatus.queued;
  bool get rejected => status == UtilitySaveStatus.rejected;
}

class UtilitySyncReport {
  const UtilitySyncReport({
    required this.sent,
    required this.failed,
    required this.remaining,
    required this.stoppedOffline,
    required this.needsLogin,
  });

  final int sent;
  final int failed;
  final int remaining;
  final bool stoppedOffline;
  final bool needsLogin;
}

class EnergyFormData {
  const EnergyFormData({
    required this.me,
    required this.meters,
    required this.fromCache,
  });

  final EnergyMe? me;
  final List<EnergyMeter> meters;
  final bool fromCache;
}

class EnergyHomeData {
  const EnergyHomeData({
    required this.me,
    required this.meters,
    required this.month,
    required this.fromCache,
  });

  final EnergyMe? me;
  final List<EnergyMeter> meters;
  final EnergyMonth? month;
  final bool fromCache;
}

class _PostOutcome {
  const _PostOutcome._({
    this.message = '',
    this.network = false,
    this.auth = false,
    this.rejected = false,
  });

  const _PostOutcome.saved(String message) : this._(message: message);
  const _PostOutcome.network() : this._(network: true);
  const _PostOutcome.auth(String message) : this._(auth: true, message: message);
  const _PostOutcome.rejected(String message)
      : this._(rejected: true, message: message);

  final String message;
  final bool network;
  final bool auth;
  final bool rejected;
}

/// Sends electricity and water readings, and keeps a local queue for meters
/// that have no signal. The queue drains oldest-first once the GEMS host
/// answers again.
class UtilityRepository {
  UtilityRepository._();

  static final UtilityRepository instance = UtilityRepository._();

  final OfflineDatabase _database = OfflineDatabase.instance;
  final Uuid _uuid = const Uuid();
  final _pendingCount = BehaviorSubject<int>.seeded(0);
  final _failedCount = BehaviorSubject<int>.seeded(0);
  final _unsent = BehaviorSubject<List<UtilityPendingReading>>.seeded(const []);

  Future<UtilitySyncReport>? _inFlight;

  Stream<int> get pendingCount$ => _pendingCount.stream;
  Stream<int> get failedCount$ => _failedCount.stream;
  Stream<List<UtilityPendingReading>> get unsent$ => _unsent.stream;
  Stream<int> get unsentCount$ =>
      _unsent.map((rows) => rows.length).distinct();

  Future<int> unsentCount() => _count();

  Future<int> pendingOnlyCount() async {
    final session = await _sessionContext();
    if (session == null) return 0;
    return _database.countUtilityPending(
      sessionContext: session,
      status: 'pending',
    );
  }

  Future<void> refreshCounts() => _refreshCounts();

  Future<EnergyHomeData> loadEnergyHome({int? year, int? month}) async {
    final now = DateTime.now();
    final y = year ?? now.year;
    final m = month ?? now.month;
    try {
      if (!await _hostReachable()) {
        throw const SocketException('offline');
      }
      final me = EnergyMe.fromJson(await _getMap('/energy/me'));
      final meters = _metersFrom(await _getList('/energy/meter?activeOnly=1'));
      await _writeCache(_cacheEnergyMe, 'me', me.toJson());
      await _writeCacheList(_cacheEnergyMeter, meters.map((meter) => meter.toJson()).toList());
      EnergyMonth? grid;
      try {
        grid = EnergyMonth.fromJson(
          await _getMap('/energy/daily?year=$y&month=$m'),
        );
      } on SocketException {
        grid = null;
      } on TimeoutException {
        grid = null;
      }
      return EnergyHomeData(
        me: me,
        meters: meters,
        month: grid,
        fromCache: false,
      );
    } catch (err) {
      if (!_isTransport(err)) rethrow;
      final meters = await _readMeterCache();
      if (meters == null) {
        throw Exception(
          'No connection, and no electricity meters are saved on this phone yet.',
        );
      }
      return EnergyHomeData(
        me: await _readMeCache(),
        meters: meters,
        month: null,
        fromCache: true,
      );
    }
  }

  Future<EnergyMonth> loadEnergyMonth(int year, int month) async {
    final json = await _getMap('/energy/daily?year=$year&month=$month');
    return EnergyMonth.fromJson(json);
  }

  Future<EnergyFormData> loadEnergyForm() async {
    final home = await loadEnergyHome();
    return EnergyFormData(
      me: home.me,
      meters: home.meters,
      fromCache: home.fromCache,
    );
  }

  Future<List<Meter>> loadWaterMeters() async {
    try {
      if (!await _hostReachable()) {
        throw const SocketException('offline');
      }
      final raw = await _getList('/utility_meter/Water');
      await _writeCacheList(_cacheWaterMeter, raw);
      return deserializeListOf<Meter>(raw).toList();
    } catch (err) {
      if (!_isTransport(err)) rethrow;
      final cached = await _readCacheList(_cacheWaterMeter);
      if (cached == null) {
        throw Exception(
          'No connection, and no water meters are saved on this phone yet.',
        );
      }
      return deserializeListOf<Meter>(cached).toList();
    }
  }

  Future<UtilitySaveResult> saveEnergyReading({
    required String meterId,
    required String meterName,
    required String readingDate,
    required String cumulativeKwh,
    String maxDemandKw = '',
    String remark = '',
  }) {
    final fields = <String, String>{
      'meterId': meterId,
      'readingDate': readingDate,
      'cumulativeKwh': cumulativeKwh,
      if (maxDemandKw.trim().isNotEmpty) 'maxDemandKw': maxDemandKw.trim(),
      if (remark.trim().isNotEmpty) 'remark': remark.trim(),
    };
    return _sendOrQueue(
      kind: _energyReading,
      url: '/energy/reading',
      fields: fields,
      summary: '$meterName: $cumulativeKwh kWh on $readingDate',
      meterId: meterId,
      capturedAt: DateTime.now(),
    );
  }

  Future<UtilitySaveResult> saveWaterReading({
    required String url,
    required Map<String, String> fields,
    required String summary,
    required String meterId,
    required DateTime capturedAt,
  }) {
    return _sendOrQueue(
      kind: _waterReading,
      url: url,
      fields: fields,
      summary: summary,
      meterId: meterId,
      capturedAt: capturedAt,
    );
  }

  Future<List<UtilityPendingReading>> listUnsent() async {
    final session = await _sessionContext();
    if (session == null) return const [];
    return _database.listUtilityPending(sessionContext: session);
  }

  Future<void> discard(int id) async {
    await _database.deleteUtilityPending(id);
    await _refreshCounts();
  }

  Future<void> discardCurrentSession() async {
    final session = await _sessionContext();
    if (session == null) return;
    await _database.discardUtilityReadingsFor(session);
    await _refreshCounts();
  }

  /// Puts a failed reading back in the queue, optionally with edited fields.
  Future<void> requeue(
    UtilityPendingReading reading, {
    Map<String, String>? fields,
    String? summary,
  }) async {
    final id = reading.id;
    if (id == null) return;
    final payload = _decodePayload(reading.payloadJson);
    if (fields != null) {
      payload['fields'] = fields;
    }
    if (summary != null) {
      payload['summary'] = summary;
    }
    await _database.updateUtilityPending(
      id,
      payloadJson: jsonEncode(payload),
      status: 'pending',
      clearError: true,
    );
    await _refreshCounts();
  }

  Future<UtilitySyncReport> syncPending() {
    final current = _inFlight;
    if (current != null) return current;
    late final Future<UtilitySyncReport> run;
    run = _drain().whenComplete(() {
      if (identical(_inFlight, run)) _inFlight = null;
    });
    _inFlight = run;
    return run;
  }

  Future<UtilitySaveResult> _sendOrQueue({
    required String kind,
    required String url,
    required Map<String, String> fields,
    required String summary,
    required String meterId,
    required DateTime capturedAt,
  }) async {
    final payload = <String, dynamic>{
      'url': url,
      'fields': fields,
      'summary': summary,
      'meterId': meterId,
    };
    if (!await _hostReachable()) {
      await _enqueue(kind, payload, capturedAt);
      return const UtilitySaveResult(
        UtilitySaveStatus.queued,
        'Saved offline. It will be sent automatically when the network is back.',
      );
    }
    final outcome = await _post(url, fields);
    if (outcome.network) {
      await _enqueue(kind, payload, capturedAt);
      return const UtilitySaveResult(
        UtilitySaveStatus.queued,
        'Saved offline. It will be sent automatically when the network is back.',
      );
    }
    if (outcome.auth) {
      return UtilitySaveResult(
        UtilitySaveStatus.rejected,
        outcome.message.isEmpty
            ? 'Please log in again, then submit this reading.'
            : outcome.message,
      );
    }
    if (outcome.rejected) {
      return UtilitySaveResult(UtilitySaveStatus.rejected, outcome.message);
    }
    return UtilitySaveResult(
      UtilitySaveStatus.saved,
      outcome.message.isEmpty ? 'Saved' : outcome.message,
    );
  }

  Future<void> _enqueue(
    String kind,
    Map<String, dynamic> payload,
    DateTime capturedAt,
  ) async {
    final session = await _sessionContext();
    if (session == null) {
      throw Exception('Please log in again, then submit this reading.');
    }
    final now = DateTime.now();
    await _database.insertUtilityPending(
      UtilityPendingReading(
        clientRef: _uuid.v4(),
        kind: kind,
        sessionContext: session,
        payloadJson: jsonEncode(payload),
        capturedAt: capturedAt,
        createdAt: now,
      ),
    );
    await _refreshCounts();
    UtilitySyncScheduler.instance.arm();
  }

  Future<UtilitySyncReport> _drain() async {
    var sent = 0;
    var failed = 0;
    var stoppedOffline = false;
    var needsLogin = false;
    try {
      final session = await _sessionContext();
      if (session == null) {
        return const UtilitySyncReport(
          sent: 0,
          failed: 0,
          remaining: 0,
          stoppedOffline: false,
          needsLogin: true,
        );
      }
      final items = await _database.listUtilityPending(
        sessionContext: session,
        status: 'pending',
      );
      if (items.isEmpty) {
        return UtilitySyncReport(
          sent: 0,
          failed: 0,
          remaining: await _count(),
          stoppedOffline: false,
          needsLogin: false,
        );
      }
      if (!await _hostReachable()) {
        return UtilitySyncReport(
          sent: 0,
          failed: 0,
          remaining: await _count(),
          stoppedOffline: true,
          needsLogin: false,
        );
      }
      for (final item in items) {
        final id = item.id;
        if (id == null) continue;
        final payload = _decodePayload(item.payloadJson);
        final url = payload['url']?.toString() ?? '';
        final fields = _stringMap(payload['fields']);
        final outcome = await _post(url, fields);
        final attempts = item.attempts + 1;
        if (outcome.network) {
          await _database.updateUtilityPending(id, attempts: attempts);
          stoppedOffline = true;
          break;
        }
        if (outcome.auth) {
          await _database.updateUtilityPending(id, attempts: attempts);
          needsLogin = true;
          break;
        }
        if (outcome.rejected) {
          await _database.updateUtilityPending(
            id,
            status: 'failed',
            attempts: attempts,
            lastError: outcome.message,
          );
          failed++;
          continue;
        }
        await _database.deleteUtilityPending(id);
        sent++;
      }
    } finally {
      await _refreshCounts();
    }
    return UtilitySyncReport(
      sent: sent,
      failed: failed,
      remaining: _pendingCount.value + _failedCount.value,
      stoppedOffline: stoppedOffline,
      needsLogin: needsLogin,
    );
  }

  Future<_PostOutcome> _post(String url, Map<String, String> fields) async {
    if (url.isEmpty) {
      return const _PostOutcome.rejected('This reading has no destination.');
    }
    try {
      final headers = await _headers();
      final response = await http
          .post(
            Uri.parse(netDomain + url),
            headers: {
              HttpHeaders.contentTypeHeader: 'application/x-www-form-urlencoded',
              ...headers,
            },
            body: fields,
          )
          .timeout(const Duration(seconds: 15));
      if (response.statusCode != 200 || response.body.trim().isEmpty) {
        return const _PostOutcome.network();
      }
      final decoded = json.decode(response.body);
      if (decoded is! Map) {
        return const _PostOutcome.network();
      }
      final body = decoded.map((key, value) => MapEntry(key.toString(), value));
      final error = body['error']?.toString() ?? '';
      final errmsg = body['errmsg']?.toString() ?? '';
      if (_isAuthText(error) || _isAuthText(errmsg)) {
        return _PostOutcome.auth(
          errmsg.isEmpty ? 'Please log in again to sync your readings.' : errmsg,
        );
      }
      if (body['success'] == true) {
        return _PostOutcome.saved(errmsg);
      }
      return _PostOutcome.rejected(
        errmsg.isEmpty ? 'The server rejected this reading.' : errmsg,
      );
    } on SocketException {
      return const _PostOutcome.network();
    } on TimeoutException {
      return const _PostOutcome.network();
    } on http.ClientException {
      return const _PostOutcome.network();
    } on FormatException {
      return const _PostOutcome.network();
    } on IOException {
      return const _PostOutcome.network();
    }
  }

  Future<Map<String, dynamic>> _getMap(String path) async {
    final decoded = await _get(path);
    final result = decoded['result'];
    if (result is Map) {
      return result.map((key, value) => MapEntry(key.toString(), value));
    }
    throw Exception(decoded['errmsg']?.toString() ?? 'Please try again.');
  }

  Future<List<dynamic>> _getList(String path) async {
    final decoded = await _get(path);
    final result = decoded['result'];
    if (result is List) return result;
    if (decoded['error']?.toString() == 'Select query result empty') {
      return const [];
    }
    throw Exception(decoded['errmsg']?.toString() ?? 'Please try again.');
  }

  Future<Map<String, dynamic>> _get(String path) async {
    final headers = await _headers();
    final response = await http
        .get(Uri.parse(netDomain + path), headers: headers)
        .timeout(const Duration(seconds: 15));
    if (response.statusCode != 200 || response.body.trim().isEmpty) {
      throw const SocketException('empty response');
    }
    final decoded = json.decode(response.body);
    if (decoded is! Map) {
      throw const FormatException('unexpected response');
    }
    final body = decoded.map((key, value) => MapEntry(key.toString(), value));
    final error = body['error']?.toString() ?? '';
    final errmsg = body['errmsg']?.toString() ?? '';
    if (_isAuthText(error) || _isAuthText(errmsg)) {
      throw Exception(
        errmsg.isEmpty ? 'Please log in again.' : errmsg,
      );
    }
    if (body['success'] == true) return body;
    if (error == 'Select query result empty') return body;
    throw Exception(errmsg.isEmpty ? 'Please try again.' : errmsg);
  }

  Future<Map<String, String>> _headers() async {
    await NetworkEnvironment.load();
    final user = User.fromMap(await User.getPrefUser);
    return {
      'Authorization': 'Bearer ${user.token}',
      'Deviceid': await getDeviceDetails(),
    };
  }

  Future<bool> _hostReachable() async {
    try {
      final host = Uri.parse(netDomain).host;
      if (host.isEmpty) return false;
      final result = await InternetAddress.lookup(host)
          .timeout(const Duration(seconds: 4));
      return result.isNotEmpty && result.first.rawAddress.isNotEmpty;
    } catch (_) {
      return false;
    }
  }

  bool _isTransport(Object err) {
    return err is SocketException ||
        err is TimeoutException ||
        err is http.ClientException ||
        err is IOException ||
        err is FormatException;
  }

  bool _isAuthText(String value) {
    final text = value.toLowerCase();
    return text.contains('signature verification failed') ||
        text.contains('expired token') ||
        text.contains('device id invalid') ||
        text.contains('please relogin') ||
        text.contains('please log in again');
  }

  Future<String?> _sessionContext() async {
    try {
      await NetworkEnvironment.load();
      final user = User.fromMap(await User.getPrefUser);
      return '${NetworkEnvironment.valueFor(NetworkEnvironment.currentSource)}:${user.userID}';
    } catch (_) {
      return null;
    }
  }

  Future<int> _count() async {
    final session = await _sessionContext();
    if (session == null) return 0;
    return _database.countUtilityPending(sessionContext: session);
  }

  Future<void> _refreshCounts() async {
    final session = await _sessionContext();
    if (session == null) {
      _pendingCount.add(0);
      _failedCount.add(0);
      _unsent.add(const []);
      return;
    }
    final pending = await _database.countUtilityPending(
      sessionContext: session,
      status: 'pending',
    );
    final failed = await _database.countUtilityPending(
      sessionContext: session,
      status: 'failed',
    );
    final rows = await _database.listUtilityPending(sessionContext: session);
    _pendingCount.add(pending);
    _failedCount.add(failed);
    _unsent.add(rows);
  }

  List<EnergyMeter> _metersFrom(List<dynamic> raw) {
    return raw.map((row) {
      if (row is Map<String, dynamic>) return EnergyMeter.fromJson(row);
      if (row is Map) {
        return EnergyMeter.fromJson(
          row.map((key, value) => MapEntry(key.toString(), value)),
        );
      }
      return const EnergyMeter(
        meterId: '',
        siteId: '',
        meterName: '',
        meterDesc: '',
        sortOrder: 0,
        meterStatus: 0,
      );
    }).where((meter) => meter.meterId.isNotEmpty).toList();
  }

  Future<void> _writeCache(String category, String id, Map<String, dynamic> json) {
    return _database.replaceReferenceData(
      category: category,
      items: [
        ReferenceDataEntity(
          referenceId: id,
          category: category,
          updatedAt: DateTime.now(),
          extraJson: jsonEncode(json),
        ),
      ],
    );
  }

  Future<void> _writeCacheList(String category, List<dynamic> rows) {
    return _writeCache(category, 'list', {'rows': rows});
  }

  Future<EnergyMe?> _readMeCache() async {
    final rows = await _database.getReferenceData(category: _cacheEnergyMe);
    if (rows.isEmpty || rows.first.extraJson == null) return null;
    final decoded = jsonDecode(rows.first.extraJson!);
    if (decoded is! Map) return null;
    return EnergyMe.fromJson(
      decoded.map((key, value) => MapEntry(key.toString(), value)),
    );
  }

  Future<List<EnergyMeter>?> _readMeterCache() async {
    final rows = await _readCacheList(_cacheEnergyMeter);
    if (rows == null) return null;
    return _metersFrom(rows);
  }

  Future<List<dynamic>?> _readCacheList(String category) async {
    final rows = await _database.getReferenceData(category: category);
    if (rows.isEmpty || rows.first.extraJson == null) return null;
    final decoded = jsonDecode(rows.first.extraJson!);
    if (decoded is Map && decoded['rows'] is List) {
      return decoded['rows'] as List;
    }
    if (decoded is List) return decoded;
    return null;
  }

  Map<String, dynamic> _decodePayload(String raw) {
    final decoded = jsonDecode(raw);
    if (decoded is Map<String, dynamic>) return decoded;
    if (decoded is Map) {
      return decoded.map((key, value) => MapEntry(key.toString(), value));
    }
    return <String, dynamic>{};
  }

  Map<String, String> _stringMap(dynamic value) {
    if (value is! Map) return <String, String>{};
    return value.map(
      (key, item) => MapEntry(key.toString(), item?.toString() ?? ''),
    );
  }
}

/// Retries the utility queue when the app resumes, the Utilities screen
/// opens, or every minute while something is still waiting.
class UtilitySyncScheduler {
  UtilitySyncScheduler._();

  static final UtilitySyncScheduler instance = UtilitySyncScheduler._();

  Timer? _timer;

  void arm() {
    _timer ??= Timer.periodic(const Duration(seconds: 60), (_) {
      kick();
    });
  }

  Future<void> kick() async {
    try {
      final pending = await UtilityRepository.instance.pendingOnlyCount();
      if (pending == 0) {
        _timer?.cancel();
        _timer = null;
        await UtilityRepository.instance.refreshCounts();
        return;
      }
      arm();
      final report = await UtilityRepository.instance.syncPending();
      if (report.needsLogin) {
        debugPrint(
          'Utility sync waiting for login. ${report.remaining} readings held.',
        );
      }
      final stillPending = await UtilityRepository.instance.pendingOnlyCount();
      if (stillPending == 0) {
        _timer?.cancel();
        _timer = null;
      }
    } catch (err) {
      debugPrint('Utility sync failed: $err');
    }
  }
}
