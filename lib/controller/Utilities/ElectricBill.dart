import 'package:flutter/material.dart';
import 'package:GEMS/data/repository/utility_repository.dart';
import 'package:GEMS/model/energy.dart';
import 'package:GEMS/view/gems_chrome.dart';
import 'package:intl/intl.dart';
import 'package:toast/toast.dart';

import '../../main.dart';

class ElectricBillScreen extends StatefulWidget {
  const ElectricBillScreen({super.key});

  @override
  State<ElectricBillScreen> createState() => _ElectricBillScreenState();
}

class _ElectricBillScreenState extends State<ElectricBillScreen> {
  final _utility = UtilityRepository.instance;
  final _kwh = TextEditingController();
  final _demand = TextEditingController();
  final _remark = TextEditingController();
  final _dateFormat = DateFormat('yyyy-MM-dd');

  List<EnergyMeter> _meters = [];
  EnergyMeter? _meter;
  EnergyMe? _me;
  DateTime _date = DateTime.now();
  bool _loading = true;
  bool _submitting = false;
  bool _fromCache = false;
  String? _loadError;

  bool get _canRecord => _me?.canRecord ?? false;

  @override
  void initState() {
    super.initState();
    _load();
  }

  @override
  void dispose() {
    _kwh.dispose();
    _demand.dispose();
    _remark.dispose();
    super.dispose();
  }

  Future<void> _load() async {
    setState(() {
      _loading = true;
      _loadError = null;
    });
    try {
      final form = await _utility.loadEnergyForm();
      if (!mounted) return;
      setState(() {
        _me = form.me;
        _meters = form.meters;
        _fromCache = form.fromCache;
        _meter ??= form.meters.isEmpty ? null : form.meters.first;
        _loading = false;
      });
    } catch (err) {
      if (!mounted) return;
      setState(() {
        _loadError = err.toString();
        _loading = false;
      });
    }
  }

  Future<void> _pickDate() async {
    final today = DateTime.now();
    final picked = await showDatePicker(
      context: context,
      initialDate: _date.isAfter(today) ? today : _date,
      firstDate: DateTime(today.year - 2),
      lastDate: today,
    );
    if (picked != null) {
      setState(() => _date = picked);
    }
  }

  void _confirm() {
    if (_submitting || !_canRecord) return;
    FocusScope.of(context).unfocus();
    var started = false;
    showDialog(
      context: navigatorKey.currentContext!,
      builder: (_) => AlertDialog(
        title: Text('Confirmation', style: GemsChrome.heading(size: 18)),
        content: Text(
          'Save this cumulative meter reading?',
          style: GemsChrome.body(),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Cancel', style: GemsChrome.body(color: GemsChrome.textSoft)),
          ),
          TextButton(
            onPressed: () {
              if (started) return;
              started = true;
              Navigator.pop(context);
              _submit();
            },
            child: Text(
              'OK',
              style: GemsChrome.body(weight: FontWeight.w600, color: GemsChrome.primary),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _submit() async {
    if (_submitting) return;
    final meter = _meter;
    if (meter == null) {
      Toast.show('Select a meter');
      return;
    }
    final kwh = double.tryParse(_kwh.text.trim());
    if (kwh == null || kwh < 0) {
      Toast.show('Enter a cumulative reading of 0 or more');
      return;
    }
    final demandText = _demand.text.trim();
    if (demandText.isNotEmpty && double.tryParse(demandText) == null) {
      Toast.show('Maximum demand must be a number');
      return;
    }
    if (_remark.text.trim().length > 300) {
      Toast.show('Remark must be 300 characters or less');
      return;
    }
    setState(() => _submitting = true);
    try {
      final result = await _utility.saveEnergyReading(
        meterId: meter.meterId,
        meterName: meter.meterName,
        readingDate: _dateFormat.format(_date),
        cumulativeKwh: _kwh.text.trim(),
        maxDemandKw: demandText,
        remark: _remark.text.trim(),
      );
      if (!mounted) return;
      if (result.rejected) {
        Toast.show(result.message, duration: 4);
        return;
      }
      Toast.show(result.message, duration: 4);
      Navigator.pop(context);
    } catch (err) {
      Toast.show(err.toString(), duration: 4);
    } finally {
      if (mounted) setState(() => _submitting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    ToastContext().init(context);
    return Scaffold(
      backgroundColor: GemsChrome.page,
      appBar: gemsAppBar(title: const Text('Electricity reading')),
      body: _loading
          ? const Center(child: CircularProgressIndicator(color: GemsChrome.primary))
          : _loadError != null
              ? Center(
                  child: Padding(
                    padding: const EdgeInsets.all(24),
                    child: Text(_loadError!, textAlign: TextAlign.center),
                  ),
                )
              : ListView(
                  padding: const EdgeInsets.all(12),
                  children: [
                    if (!_canRecord)
                      Padding(
                        padding: const EdgeInsets.only(bottom: 12),
                        child: Text(
                          'You can view meters, but this account cannot record readings.',
                          style: GemsChrome.body(size: 13, color: GemsChrome.textSoft),
                        ),
                      ),
                    if (_fromCache)
                      Padding(
                        padding: const EdgeInsets.only(bottom: 12),
                        child: Text(
                          'Offline: using the meters saved on this phone. The reading will be sent when the network is back.',
                          style: GemsChrome.body(size: 13, color: GemsChrome.textSoft),
                        ),
                      ),
                    GemsFormSection(
                      title: 'Daily reading',
                      icon: Icons.bolt_outlined,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          DropdownButtonFormField<EnergyMeter>(
                            decoration: gemsFieldDecoration(label: 'Meter'),
                            isExpanded: true,
                            value: _meter,
                            hint: Text('Select meter', style: GemsChrome.body(color: GemsChrome.muted)),
                            items: _meters
                                .map((meter) => DropdownMenuItem(
                                      value: meter,
                                      child: Text(meter.label, style: GemsChrome.body(size: 14)),
                                    ))
                                .toList(),
                            onChanged: _canRecord
                                ? (meter) => setState(() => _meter = meter)
                                : null,
                          ),
                          const SizedBox(height: 12),
                          OutlinedButton.icon(
                            onPressed: _canRecord ? _pickDate : null,
                            icon: const Icon(Icons.event_outlined),
                            label: Text(
                              'Reading date ${_dateFormat.format(_date)}',
                              style: GemsChrome.body(weight: FontWeight.w600),
                            ),
                          ),
                          const SizedBox(height: 12),
                          TextField(
                            controller: _kwh,
                            enabled: _canRecord,
                            keyboardType: const TextInputType.numberWithOptions(decimal: true),
                            decoration: gemsFieldDecoration(
                              label: 'Cumulative meter reading (kWh)',
                              enabled: _canRecord,
                            ),
                          ),
                          const SizedBox(height: 12),
                          TextField(
                            controller: _demand,
                            enabled: _canRecord,
                            keyboardType: const TextInputType.numberWithOptions(decimal: true),
                            decoration: gemsFieldDecoration(
                              label: 'Maximum demand (optional)',
                              enabled: _canRecord,
                            ),
                          ),
                          const SizedBox(height: 12),
                          TextField(
                            controller: _remark,
                            enabled: _canRecord,
                            maxLength: 300,
                            decoration: gemsFieldDecoration(
                              label: 'Remark (optional)',
                              enabled: _canRecord,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
      floatingActionButton: FloatingActionButton.extended(
        backgroundColor: GemsChrome.primary,
        foregroundColor: Colors.white,
        onPressed: _submitting || !_canRecord ? null : _confirm,
        label: Text(_submitting ? 'Submitting...' : 'Submit'),
      ),
    );
  }
}
