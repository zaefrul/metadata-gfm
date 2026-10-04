import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:GEMS/data/local/offline_database.dart';
import 'package:GEMS/data/repository/utility_repository.dart';
import 'package:GEMS/view/gems_chrome.dart';
import 'package:intl/intl.dart';
import 'package:toast/toast.dart';

class UnsentReadingsScreen extends StatefulWidget {
  const UnsentReadingsScreen({super.key});

  @override
  State<UnsentReadingsScreen> createState() => _UnsentReadingsScreenState();
}

class _UnsentReadingsScreenState extends State<UnsentReadingsScreen> {
  final _utility = UtilityRepository.instance;
  final _when = DateFormat('d MMM yyyy, HH:mm');

  Future<void> _retry(UtilityPendingReading reading) async {
    await _utility.requeue(reading);
    final report = await _utility.syncPending();
    if (!mounted) return;
    if (report.needsLogin) {
      Toast.show('Please log in again to sync ${report.remaining} readings.');
    }
  }

  Future<void> _discard(UtilityPendingReading reading) async {
    final id = reading.id;
    if (id == null) return;
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: Text('Discard reading', style: GemsChrome.heading(size: 18)),
        content: Text(
          'This reading will not be sent.',
          style: GemsChrome.body(),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, false),
            child: Text('Cancel', style: GemsChrome.body(color: GemsChrome.textSoft)),
          ),
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, true),
            child: Text('Discard', style: GemsChrome.body(color: GemsChrome.danger)),
          ),
        ],
      ),
    );
    if (confirmed == true) {
      await _utility.discard(id);
    }
  }

  Future<void> _edit(UtilityPendingReading reading) async {
    final payload = jsonDecode(reading.payloadJson);
    if (payload is! Map) return;
    final fields = <String, String>{};
    final rawFields = payload['fields'];
    if (rawFields is Map) {
      rawFields.forEach((key, value) {
        fields[key.toString()] = value?.toString() ?? '';
      });
    }
    final isEnergy = reading.kind == 'energy_reading';
    final edited = await showDialog<Map<String, String>>(
      context: context,
      builder: (dialogContext) => _EditReadingDialog(
        isEnergy: isEnergy,
        fields: fields,
      ),
    );
    if (edited == null) return;
    final previous = payload['summary']?.toString() ?? '';
    final meterName = previous.contains(':') ? previous.split(':').first.trim() : 'Meter';
    final summary = isEnergy
        ? '$meterName: ${edited['cumulativeKwh']} kWh on ${edited['readingDate']}'
        : '$meterName: ${edited['utilityReading']} m³';
    edited.remove('meterName');
    await _utility.requeue(reading, fields: edited, summary: summary);
    final report = await _utility.syncPending();
    if (!mounted) return;
    if (report.needsLogin) {
      Toast.show('Please log in again to sync ${report.remaining} readings.');
    }
  }

  @override
  Widget build(BuildContext context) {
    ToastContext().init(context);
    return Scaffold(
      backgroundColor: GemsChrome.page,
      appBar: gemsAppBar(title: const Text('Unsent readings')),
      body: StreamBuilder<List<UtilityPendingReading>>(
        stream: _utility.unsent$,
        builder: (context, snapshot) {
          final rows = snapshot.data ?? const <UtilityPendingReading>[];
          if (rows.isEmpty) {
            return Center(
              child: Text(
                'Nothing waiting to send.',
                style: GemsChrome.body(color: GemsChrome.textSoft),
              ),
            );
          }
          return ListView.separated(
            padding: const EdgeInsets.fromLTRB(12, 12, 12, 24),
            itemCount: rows.length,
            separatorBuilder: (_, __) => const SizedBox(height: 10),
            itemBuilder: (_, i) {
              final row = rows[i];
              final failed = row.status == 'failed';
              final summary = _summary(row);
              return GemsAccentCard(
                accent: failed ? GemsChrome.danger : GemsChrome.primary,
                onTap: () {},
                child: Padding(
                  padding: const EdgeInsets.all(12),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(summary, style: GemsChrome.body(size: 15, weight: FontWeight.w600)),
                      const SizedBox(height: 4),
                      Text(
                        _when.format(row.capturedAt.toLocal()),
                        style: GemsChrome.body(size: 13, color: GemsChrome.textSoft),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        failed ? 'Not accepted' : 'Waiting to send',
                        style: GemsChrome.body(
                          size: 13,
                          weight: FontWeight.w600,
                          color: failed ? GemsChrome.danger : GemsChrome.primary,
                        ),
                      ),
                      if (failed && (row.lastError ?? '').isNotEmpty) ...[
                        const SizedBox(height: 4),
                        Text(
                          row.lastError!,
                          style: GemsChrome.body(size: 13, color: GemsChrome.textSoft),
                        ),
                      ],
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          if (failed)
                            TextButton(
                              onPressed: () => _edit(row),
                              child: const Text('Edit'),
                            ),
                          TextButton(
                            onPressed: () => _retry(row),
                            child: const Text('Retry'),
                          ),
                          TextButton(
                            onPressed: () => _discard(row),
                            child: Text('Discard', style: GemsChrome.body(color: GemsChrome.danger)),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }

  String _summary(UtilityPendingReading row) {
    try {
      final payload = jsonDecode(row.payloadJson);
      if (payload is Map && payload['summary'] != null) {
        return payload['summary'].toString();
      }
    } catch (_) {}
    return row.kind == 'energy_reading' ? 'Electricity reading' : 'Water reading';
  }
}

class _EditReadingDialog extends StatefulWidget {
  const _EditReadingDialog({required this.isEnergy, required this.fields});

  final bool isEnergy;
  final Map<String, String> fields;

  @override
  State<_EditReadingDialog> createState() => _EditReadingDialogState();
}

class _EditReadingDialogState extends State<_EditReadingDialog> {
  late final TextEditingController _primary;
  late final TextEditingController _demand;
  late final TextEditingController _remark;
  late DateTime _date;

  @override
  void initState() {
    super.initState();
    if (widget.isEnergy) {
      _primary = TextEditingController(text: widget.fields['cumulativeKwh'] ?? '');
      _demand = TextEditingController(text: widget.fields['maxDemandKw'] ?? '');
      _remark = TextEditingController(text: widget.fields['remark'] ?? '');
      _date = DateTime.tryParse(widget.fields['readingDate'] ?? '') ?? DateTime.now();
    } else {
      _primary = TextEditingController(text: widget.fields['utilityReading'] ?? '');
      _demand = TextEditingController();
      _remark = TextEditingController();
      _date = DateTime.now();
    }
  }

  @override
  void dispose() {
    _primary.dispose();
    _demand.dispose();
    _remark.dispose();
    super.dispose();
  }

  void _save() {
    final value = double.tryParse(_primary.text.trim());
    if (value == null || value < 0) {
      Toast.show('Enter a number of 0 or more');
      return;
    }
    final next = Map<String, String>.from(widget.fields);
    if (widget.isEnergy) {
      if (_demand.text.trim().isNotEmpty && double.tryParse(_demand.text.trim()) == null) {
        Toast.show('Maximum demand must be a number');
        return;
      }
      next['cumulativeKwh'] = _primary.text.trim();
      next['readingDate'] = DateFormat('yyyy-MM-dd').format(_date);
      if (_demand.text.trim().isEmpty) {
        next.remove('maxDemandKw');
      } else {
        next['maxDemandKw'] = _demand.text.trim();
      }
      if (_remark.text.trim().isEmpty) {
        next.remove('remark');
      } else {
        next['remark'] = _remark.text.trim();
      }
      next['meterName'] = widget.fields['meterName'] ?? 'Meter';
    } else {
      next['utilityReading'] = _primary.text.trim();
    }
    Navigator.pop(context, next);
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text('Edit reading', style: GemsChrome.heading(size: 18)),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (widget.isEnergy)
            OutlinedButton(
              onPressed: () async {
                final today = DateTime.now();
                final picked = await showDatePicker(
                  context: context,
                  initialDate: _date.isAfter(today) ? today : _date,
                  firstDate: DateTime(today.year - 2),
                  lastDate: today,
                );
                if (picked != null) setState(() => _date = picked);
              },
              child: Text(DateFormat('yyyy-MM-dd').format(_date)),
            ),
          TextField(
            controller: _primary,
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
            decoration: gemsFieldDecoration(
              label: widget.isEnergy ? 'Cumulative kWh' : 'Reading (m³)',
            ),
          ),
          if (widget.isEnergy) ...[
            const SizedBox(height: 8),
            TextField(
              controller: _demand,
              decoration: gemsFieldDecoration(label: 'Maximum demand'),
            ),
            const SizedBox(height: 8),
            TextField(
              controller: _remark,
              decoration: gemsFieldDecoration(label: 'Remark'),
            ),
          ],
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: Text('Cancel', style: GemsChrome.body(color: GemsChrome.textSoft)),
        ),
        TextButton(
          onPressed: _save,
          child: Text('Save', style: GemsChrome.body(weight: FontWeight.w600, color: GemsChrome.primary)),
        ),
      ],
    );
  }
}
