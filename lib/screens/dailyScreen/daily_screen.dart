import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:provider/provider.dart';
import '../../models/daily_record.dart';
import '../../models/work_session.dart';
import '../../models/worker.dart';
import '../../service/daily_service.dart';
import '../../service/local_storage_service.dart';
import 'worker_card.dart';
import '../../providers/product_provider.dart';
import '../../providers/model_provider.dart';
import '../../providers/shape_provider.dart';
import '../../providers/worker_provider.dart';

class DailyScreen extends StatefulWidget {
  @override
  State<DailyScreen> createState() => _DailyScreenState();
}

class _DailyScreenState extends State<DailyScreen> {
  DateTime selectedDate = DateTime.now();
  Map<String, DailyRecord> records = {};
  bool isLoaded = false;
  bool isSyncing = false;

  /// Worker IDs that have unsaved local changes (not yet pushed to Firestore)
  final Set<String> _pendingLocalIds = {};

  StreamSubscription? _firestoreSub;
  final _service = DailyService();
  final _local = LocalStorageService();

  @override
  void initState() {
    super.initState();
    Future.microtask(() {
      context.read<ProductProvider>().listen();
      context.read<ModelProvider>().listenAll();
      context.read<ShapeProvider>().listenAll();
      context.read<WorkerProvider>().listen();
      _loadDate(selectedDate);
    });
  }

  Future<void> _loadDate(DateTime date) async {
    _firestoreSub?.cancel();
    _pendingLocalIds.clear();
    setState(() {
      isLoaded = false;
      isSyncing = false;
    });

    // Check SharedPreferences for unsaved local edits per worker
    final workers = context.read<WorkerProvider>().workers;
    for (final w in workers) {
      final local = await _local.loadRecord(date, w.id);
      if (local != null && mounted) {
        records[w.id] = local;
        _pendingLocalIds.add(w.id);
      }
    }

    // Stream Firestore — only fills in workers with no pending local changes
    _firestoreSub = _service.streamByDate(date).listen(
      (loaded) {
        if (!mounted) return;
        setState(() {
          for (var r in loaded) {
            if (!_pendingLocalIds.contains(r.workerRef.id)) {
              records[r.workerRef.id] = r;
            }
          }
          isLoaded = true;
          isSyncing = false;
        });
      },
      onError: (_) {
        if (!mounted) return;
        setState(() => isLoaded = true);
      },
    );

    // Show UI immediately if we already have local data, otherwise wait for stream
    if (_pendingLocalIds.isNotEmpty && mounted) {
      setState(() => isLoaded = true);
    }
  }

  bool _shouldSave(DailyRecord r) {
    return r.isAbsent ||
        r.sessions.any((s) => s.checkIn != null || s.checkOut != null) ||
        r.productions.any((p) => p.productRef != null) ||
        r.advance != 0 ||
        r.rating != 0 ||
        r.notes.isNotEmpty ||
        r.deductionType != 'none' ||
        r.id.isNotEmpty;
  }

  /// Save to local storage immediately on every change
  void _saveLocal(DailyRecord r) {
    _pendingLocalIds.add(r.workerRef.id);
    _local.saveRecord(r).catchError((_) {});
  }

  /// Save all records to Firestore, then clear local cache
  Future<void> _saveNow() async {
    setState(() => isSyncing = true);
    for (var r in records.values) {
      if (!_shouldSave(r)) continue;
      try {
        await _service.save(r);
        await _local.clearRecord(r.date, r.workerRef.id);
        _pendingLocalIds.remove(r.workerRef.id);
      } catch (_) {}
    }
    if (mounted) setState(() => isSyncing = false);
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("تم الحفظ بنجاح ✓"),
          backgroundColor: Colors.green,
          duration: Duration(seconds: 2),
        ),
      );
    }
  }

  @override
  void dispose() {
    _firestoreSub?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (!isLoaded) {
      return Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    final workers = context.watch<WorkerProvider>().workers;
    final products = context.watch<ProductProvider>().products;
    final models = context.watch<ModelProvider>().models;
    final shapes = context.watch<ShapeProvider>().shapes;

    final hasPending = _pendingLocalIds.isNotEmpty;

    return Scaffold(
      appBar: AppBar(
        title: Text("إدارة اليوم"),
        actions: [
          if (isSyncing)
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 12.w),
              child: Center(
                child: SizedBox(
                  width: 18.w,
                  height: 18.w,
                  child: CircularProgressIndicator(
                    color: Colors.white,
                    strokeWidth: 2,
                  ),
                ),
              ),
            )
          else
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 12.w),
              child: Icon(
                hasPending ? Icons.cloud_upload : Icons.cloud_done,
                color: hasPending ? Colors.orange.shade200 : Colors.white,
              ),
            ),
          IconButton(
            icon: const Icon(Icons.copy_all),
            tooltip: "نسخ من أمس",
            onPressed: _copyFromYesterday,
          ),
          IconButton(
            icon: Icon(Icons.calendar_today),
            onPressed: _pickDate,
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: isSyncing ? null : _saveNow,
        icon: isSyncing
            ? SizedBox(
                width: 20.w,
                height: 20.w,
                child: const CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
              )
            : const Icon(Icons.save),
        label: Text(isSyncing ? "جاري الحفظ..." : "حفظ اليوم"),
      ),
      body: ListView(
        children: [
          _buildDailySummary(workers),
          ...workers.map((w) {
            records.putIfAbsent(
              w.id,
              () => DailyRecord(
                id: '',
                workerRef: FirebaseFirestore.instance.collection('workers').doc(w.id),
                date: selectedDate,
              ),
            );

            return WorkerCard(
              worker: w,
              record: records[w.id]!,
              products: products,
              models: models,
              shapes: shapes,
              onChanged: () {
                setState(() {});
                _saveLocal(records[w.id]!);
              },
            );
          }),
          SizedBox(height: 80.h),
        ],
      ),
    );
  }

  Future<void> _copyFromYesterday() async {
    final yesterday = selectedDate.subtract(const Duration(days: 1));
    final yesterdayRecords = await _service.getByDate(yesterday);
    if (!mounted) return;
    if (yesterdayRecords.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("لا يوجد سجلات لأمس")),
      );
      return;
    }
    setState(() {
      for (final r in yesterdayRecords) {
        final id = r.workerRef.id;
        if (!records.containsKey(id)) continue;
        records[id]!.sessions = r.sessions.map((s) => WorkSession(
          checkIn: s.checkIn != null
              ? DateTime(selectedDate.year, selectedDate.month, selectedDate.day, s.checkIn!.hour, s.checkIn!.minute)
              : null,
          checkOut: s.checkOut != null
              ? DateTime(selectedDate.year, selectedDate.month, selectedDate.day, s.checkOut!.hour, s.checkOut!.minute)
              : null,
        )).toList();
      }
    });
  }

  Widget _buildDailySummary(List<Worker> workers) {
    int present = 0, absent = 0;
    for (final w in workers) {
      final r = records[w.id];
      if (r == null) continue;
      if (r.isAbsent) {
        absent++;
      } else if (r.sessions.any((s) => s.checkIn != null)) {
        present++;
      }
    }
    return Card(
      margin: EdgeInsets.symmetric(horizontal: 12.w, vertical: 8.h),
      color: Colors.blue.shade50,
      child: Padding(
        padding: EdgeInsets.symmetric(vertical: 10.h, horizontal: 16.w),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            _summaryItem("حضر", "$present", Colors.green.shade700),
            _summaryItem("غاب", "$absent", Colors.red.shade700),
          ],
        ),
      ),
    );
  }

  Widget _summaryItem(String label, String value, Color color) {
    return Column(
      children: [
        Text(value, style: TextStyle(fontSize: 16.sp, fontWeight: FontWeight.bold, color: color)),
        Text(label, style: TextStyle(fontSize: 11.sp, color: Colors.grey.shade600)),
      ],
    );
  }

  void _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: selectedDate,
      firstDate: DateTime(2023),
      lastDate: DateTime(2030),
    );

    if (picked != null) {
      setState(() {
        selectedDate = picked;
        records.clear();
      });
      _loadDate(picked);
    }
  }
}
