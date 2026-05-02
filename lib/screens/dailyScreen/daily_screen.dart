import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:provider/provider.dart';
import '../../models/daily_record.dart';
import '../../service/daily_service.dart';
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

  StreamSubscription? _firestoreSub;
  Timer? _saveDebounce;
  final _service = DailyService();

  @override
  void initState() {
    super.initState();
    Future.microtask(() {
      context.read<ProductProvider>().listen();
      context.read<ModelProvider>().listenAll();
      context.read<ShapeProvider>().listenAll();
      context.read<WorkerProvider>().listen();
      _listenToDate(selectedDate);
    });
  }

  void _listenToDate(DateTime date) {
    _firestoreSub?.cancel();
    setState(() {
      isLoaded = false;
      isSyncing = false;
    });

    _firestoreSub = _service.streamByDate(date).listen(
      (loaded) {
        if (!mounted) return;
        setState(() {
          for (var r in loaded) {
            // فقط حدّث لو مفيش تعديل local في الانتظار
            if (_saveDebounce == null || !_saveDebounce!.isActive) {
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
  }

  // حفظ تلقائي لـ Firestore عند كل تعديل (debounced 800ms)
  void _autoSave() {
    setState(() => isSyncing = true);
    _saveDebounce?.cancel();
    _saveDebounce = Timer(const Duration(milliseconds: 800), () async {
      for (var r in records.values) {
        try {
          await _service.save(r);
        } catch (_) {}
      }
      if (mounted) setState(() => isSyncing = false);
    });
  }

  @override
  void dispose() {
    _firestoreSub?.cancel();
    _saveDebounce?.cancel();
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
              child: Icon(Icons.cloud_done, color: Colors.white),
            ),
          IconButton(
            icon: Icon(Icons.calendar_today),
            onPressed: _pickDate,
          ),
        ],
      ),
      body: ListView(
        children: [
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
                _autoSave();
              },
            );
          }).toList(),
          SizedBox(height: 80.h),
        ],
      ),
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
      _listenToDate(picked);
    }
  }
}
