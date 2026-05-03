import 'package:flutter/material.dart';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:provider/provider.dart';
import '../../models/daily_record.dart';
import '../../models/product.dart';
import '../../models/product_model.dart';
import '../../models/production_item.dart';
import '../../models/shape.dart';
import '../../models/work_session.dart';
import '../../models/worker.dart';
import '../../providers/bouns_provider.dart';

class WorkerCard extends StatefulWidget {
 final Worker worker;
 final DailyRecord record;
 final List<Product> products;
 final List<ProductModel> models;
 final List<Shape> shapes;
 final VoidCallback onChanged;

 const WorkerCard({
  super.key,
  required this.worker,
  required this.record,
  required this.products,
  required this.models,
  required this.shapes,
  required this.onChanged,
 });

 @override
 State<WorkerCard> createState() => _WorkerCardState();
}

class _WorkerCardState extends State<WorkerCard> {
 late List<ProductionItem> productions;
 bool isExpanded = false;
 late List<TextEditingController> qtyControllers;
 late TextEditingController _advanceController;

 @override
 void initState() {
  super.initState();

  if (widget.record.sessions.isEmpty) {
   widget.record.sessions = [WorkSession()];
  }

  productions = List.from(widget.record.productions);

  if (productions.isEmpty) {
   productions.add(
    ProductionItem(
     productRef: null,
     modelRef: null,
     shapeRef: null,
     quantity: 0,
    ),
   );
  }
  qtyControllers = productions.map((p) {
   return TextEditingController(
    text: p.quantity == 0 ? '' : p.quantity.toString(),
   );
  }).toList();

  _advanceController = TextEditingController(
   text: widget.record.advance == 0 ? '' : widget.record.advance.toString(),
  );
 }
 @override
 void didUpdateWidget(covariant WorkerCard oldWidget) {
  super.didUpdateWidget(oldWidget);

  if (oldWidget.record != widget.record) {
   if (widget.record.sessions.isEmpty) {
    widget.record.sessions = [WorkSession()];
   }

   productions = List.from(widget.record.productions);

   if (productions.isEmpty) {
    productions.add(
     ProductionItem(
      productRef: null,
      modelRef: null,
      shapeRef: null,
      quantity: 0,
     ),
    );
   }
   for (var c in qtyControllers) { c.dispose(); }
   qtyControllers = productions.map((p) {
    return TextEditingController(
     text: p.quantity == 0 ? '' : p.quantity.toString(),
    );
   }).toList();

   _advanceController.dispose();
   _advanceController = TextEditingController(
    text: widget.record.advance == 0 ? '' : widget.record.advance.toString(),
   );
   setState(() {});
  }
 }
 Future<void> pickTime(int sessionIndex, bool isCheckIn) async {
  final time = await showTimePicker(
   context: context,
   initialTime: TimeOfDay.now(),
  );

  if (time != null) {
   final d = widget.record.date;
   final date = DateTime(d.year, d.month, d.day, time.hour, time.minute);

   setState(() {
    final session = widget.record.sessions[sessionIndex];
    if (isCheckIn) {
     session.checkIn = date;
    } else {
     session.checkOut = date;
    }
   });

   widget.onChanged();
  }
 }

 String _formatTime(DateTime? dt) {
  if (dt == null) return '--:--';
  return '${dt.hour.toString().padLeft(2, '0')}:${dt.minute.toString().padLeft(2, '0')}';
 }

 double get _totalWorkedHours {
  double total = 0;
  for (final s in widget.record.sessions) {
   if (s.checkIn == null || s.checkOut == null) continue;
   total += s.checkOut!.difference(s.checkIn!).inMinutes / 60.0;
  }
  return total;
 }

 /// ساعات الأوفر تايم
 double get _overtimeHours {
  final extra = _totalWorkedHours - widget.worker.workHours;
  return extra > 0 ? extra : 0;
 }

 double calculateSalary() {
  if (widget.record.isAbsent) {
   return 0;
  }

  double total = widget.worker.dailySalary;

  if (_overtimeHours > 0) {
   final hourRate = widget.worker.dailySalary / widget.worker.workHours;
   total += _overtimeHours * (hourRate * 2);
  }

  /// 🎁 الحوافز (فقط لو مسموح)
  if (widget.worker.hasBonus) {
   final bonus = context.read<BonusProvider>();

   if (widget.record.rating > 0) {
    int factor = (6 - widget.record.rating);
    total += bonus.qualityBonus / factor;
   }

   if (widget.record.onTime) {
    total += bonus.commitmentBonus;
   }

   for (var item in productions) {
    if (item.shapeRef == null || item.modelRef == null) continue;

    final shape = widget.shapes.firstWhere(
         (s) =>
     s.id == item.shapeRef!.id &&
         s.modelRef.id == item.modelRef!.id,
     orElse: () => Shape(
      id: '',
      name: '',
      target: 0,
      modelRef:
      FirebaseFirestore.instance.collection('models').doc('dummy'),
     ),
    );

    if (shape.id.isNotEmpty && item.quantity >= shape.target) {
     total += bonus.productionBonus;
    }
   }
  }

  /// ❌ الخصومات (تشتغل دايماً)
  switch (widget.record.deductionType) {
   case 'qurofhour':
    total -= widget.worker.dailySalary / widget.worker.workHours / 4;
    break;
   case 'halfofhour':
    total -= widget.worker.dailySalary / widget.worker.workHours / 2;
    break;
   case 'hour':
    total -= widget.worker.dailySalary / widget.worker.workHours;
    break;
   case '2hours':
    total -= (widget.worker.dailySalary / widget.worker.workHours) * 2;
    break;
   case 'quarter':
    total -= widget.worker.dailySalary * 0.25;
    break;
   case 'half':
    total -= widget.worker.dailySalary * 0.5;
    break;
   case 'full':
    total -= widget.worker.dailySalary;
    break;
  }

  widget.record.totalSalary = total;
  return total;
 }
 String _formatHours(double hours) {
  final h = hours.floor();
  final m = ((hours - h) * 60).round();
  if (h == 0) return "${m}د";
  if (m == 0) return "${h}س";
  return "${h}س ${m}د";
 }

 Widget _buildWorkSummary() {
  final total = _totalWorkedHours;
  final overtime = _overtimeHours;
  final overtimePay = overtime > 0
      ? overtime * (widget.worker.dailySalary / widget.worker.workHours) * 2
      : 0.0;

  return Container(
   padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 8.h),
   decoration: BoxDecoration(
    color: Colors.blue.shade50,
    borderRadius: BorderRadius.circular(10.r),
   ),
   child: Row(
    mainAxisAlignment: MainAxisAlignment.spaceAround,
    children: [
     Column(
      children: [
       Text("إجمالي الوقت", style: TextStyle(fontSize: 11.sp, color: Colors.grey.shade600)),
       SizedBox(height: 2.h),
       Text(_formatHours(total), style: TextStyle(fontSize: 13.sp, fontWeight: FontWeight.bold)),
      ],
     ),
     Container(width: 1, height: 30.h, color: Colors.blue.shade200),
     Column(
      children: [
       Text("أوفر تايم", style: TextStyle(fontSize: 11.sp, color: Colors.grey.shade600)),
       SizedBox(height: 2.h),
       Text(
        overtime > 0 ? _formatHours(overtime) : "—",
        style: TextStyle(
         fontSize: 13.sp,
         fontWeight: FontWeight.bold,
         color: overtime > 0 ? Colors.orange.shade700 : Colors.grey,
        ),
       ),
      ],
     ),
     if (overtime > 0) ...[
      Container(width: 1, height: 30.h, color: Colors.blue.shade200),
      Column(
       children: [
        Text("أجر الأوفر", style: TextStyle(fontSize: 11.sp, color: Colors.grey.shade600)),
        SizedBox(height: 2.h),
        Text(
         "+${overtimePay.toStringAsFixed(0)} ج",
         style: TextStyle(fontSize: 13.sp, fontWeight: FontWeight.bold, color: Colors.green.shade700),
        ),
       ],
      ),
     ],
    ],
   ),
  );
 }

 @override
 Widget build(BuildContext context) {
  final totalSalary = calculateSalary();

  return GestureDetector(
   onTap: widget.record.isAbsent ? null : () => setState(() => isExpanded = !isExpanded),
   child: Container(
    margin:  EdgeInsets.symmetric(horizontal: 12.w, vertical: 8.h),
    child: Card(
     color: widget.record.isAbsent ? Colors.red.shade50 : null,
     shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(16.r),
      side: widget.record.isAbsent
          ? BorderSide(color: Colors.red.shade200, width: 1.5)
          : BorderSide.none,
     ),
     elevation: 3,
     child: Padding(
      padding:  EdgeInsets.all(12.w),
      child: Column(
       children: [
        /// 👷‍♂️ اسم العامل + المرتب
        Row(
         mainAxisAlignment: MainAxisAlignment.spaceBetween,
         children: [
          Text(widget.worker.name),
          Row(
           mainAxisSize: MainAxisSize.min,
           children: [
            Text("غياب", style: TextStyle(fontSize: 12.sp)),
            Switch(
              value: widget.record.isAbsent,
              activeThumbColor: Colors.red,
              onChanged: (v) {
               setState(() {
                widget.record.isAbsent = v;
                if (v) isExpanded = false;
               });
               widget.onChanged();
              },
             ),
           ],
          ),
          if (widget.record.isAbsent)
           Container(
            padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 4.h),
            decoration: BoxDecoration(
             color: Colors.red.shade200,
             borderRadius: BorderRadius.circular(12.r),
            ),
            child: Text(
             "غائب",
             style: TextStyle(
              color: Colors.red.shade900,
              fontWeight: FontWeight.bold,
              fontSize: 13.sp,
             ),
            ),
           )
          else
           Row(
            children: [
             Text("${totalSalary.toStringAsFixed(2)} ج"),
             Icon(isExpanded
                 ? Icons.keyboard_arrow_up
                 : Icons.keyboard_arrow_down),
            ],
           ),
         ],
        ),

        SizedBox(height: 10.h),

        if (isExpanded) ...[
         /// ⏰ الأوقات
         ...widget.record.sessions.asMap().entries.map((entry) {
          final i = entry.key;
          final session = entry.value;
          return Padding(
           padding: EdgeInsets.only(bottom: 6.h),
           child: Row(
            children: [
             Expanded(
              child: ElevatedButton(
               onPressed: () => pickTime(i, true),
               child: Text(session.checkIn == null ? "حضور" : _formatTime(session.checkIn)),
              ),
             ),
             SizedBox(width: 6.w),
             Expanded(
              child: ElevatedButton(
               onPressed: () => pickTime(i, false),
               child: Text(session.checkOut == null ? "انصراف" : _formatTime(session.checkOut)),
              ),
             ),
             if (widget.record.sessions.length > 1)
              IconButton(
               icon: Icon(Icons.remove_circle_outline, color: Colors.red.shade400, size: 20.w),
               onPressed: () {
                setState(() => widget.record.sessions.removeAt(i));
                widget.onChanged();
               },
              ),
            ],
           ),
          );
         }),
         TextButton.icon(
          onPressed: () {
           setState(() => widget.record.sessions.add(WorkSession()));
           widget.onChanged();
          },
          icon: Icon(Icons.add_circle_outline, size: 18.w),
          label: const Text("وقت إضافي"),
         ),

         if (_totalWorkedHours > 0) ...[
          SizedBox(height: 8.h),
          _buildWorkSummary(),
         ],

         SizedBox(height: 10.h),
  if (widget.worker.hasBonus) ...[
         /// ⭐️ + 🌙
         Row(
          children: [
           Expanded(
            child: Column(
             children: [
              Text("حوافز الجودة"),
              Row(
               children: List.generate(5, (index) {
                return IconButton(
                 icon: Icon(
                  index < widget.record.rating
                      ? Icons.star
                      : Icons.star_border,
                  color: Colors.amber,
                 ),
                 onPressed: () {
                  setState(() {
                   widget.record.rating = index + 1;
                  });
                  widget.onChanged();
                 },
                );
               }),
              ),
             ],
            ),
           ),
           Column(
            children: [
             Text("حافز الالتزام"),
             Switch(
              value: widget.record.onTime,
              onChanged: (v) {
               setState(() {
                widget.record.onTime = v;
               });
               widget.onChanged();
              },
             ),
            ],
           ),
          ],
         ),
],
         const Divider(),
         DropdownButtonFormField<String>(
          value: widget.record.deductionType,
          decoration: InputDecoration(labelText: "الخصم"),
          items: const [
           DropdownMenuItem(value: 'none', child: Text("بدون")),
           DropdownMenuItem(value: 'qurofhour', child: Text("ربع ساعة")),
           DropdownMenuItem(value: 'halfofhour', child: Text("نص ساعة")),

           DropdownMenuItem(value: 'hour', child: Text("ساعة")),
           DropdownMenuItem(value: '2hours', child: Text("ساعتين")),
           DropdownMenuItem(value: 'quarter', child: Text("ربع يوم")),
           DropdownMenuItem(value: 'half', child: Text("نص يوم")),
           DropdownMenuItem(value: 'full', child: Text("يوم كامل")),
          ],
          onChanged: (v) {
           setState(() {
            widget.record.deductionType = v!;
           });
           widget.onChanged();
          },
         ),
         SizedBox(height: 8.h),
         TextFormField(
          controller: _advanceController,
          keyboardType: TextInputType.number,
          decoration: const InputDecoration(
           labelText: "سلفة",
           prefixIcon: Icon(Icons.money_off),
          ),
          onChanged: (v) {
           widget.record.advance = double.tryParse(v) ?? 0;
           widget.onChanged();
          },
         ),
         const Divider(),
  if (widget.worker.hasBonus) ...[
         /// 📦 الإنتاج
         Column(
          children: productions.map((item) {
           return Column(
            children: [
             /// المنتج
             DropdownButtonFormField<String>(
              value: item.productRef?.id, // 🔥 هنا أهم تعديل

              hint: Text("اختار المنتج"),

              items: widget.products.map((p) {
               return DropdownMenuItem<String>(
                value: p.id,
                child: Text(p.name),
               );
              }).toList(),

              onChanged: (id) {
               setState(() {
                item.productRef = FirebaseFirestore.instance
                    .collection('products')
                    .doc(id);

                item.modelRef = null;
                item.shapeRef = null;

               });
               widget.record.productions = productions; // 🔥 مهم
               widget.onChanged();
              },
             ),
             /// الموديل
             DropdownButtonFormField<String>(
              value: item.modelRef?.id,

              hint: Text("اختار الموديل"),

              items: widget.models
                  .where((m) =>
              item.productRef != null &&
                  m.productRef.id == item.productRef!.id)
                  .map((m) {
               return DropdownMenuItem<String>(
                value: m.id,
                child: Text(m.name),
               );
              }).toList(),

              onChanged: (id) {
               setState(() {
                item.modelRef = FirebaseFirestore.instance
                    .collection('models')
                    .doc(id);

                item.shapeRef = null;

               });
               widget.record.productions = productions; // 🔥 مهم
               widget.onChanged();
              },
             ),
             /// الشكل
             DropdownButtonFormField<String>(
              value: item.shapeRef?.id,

              hint: Text("اختار الشكل"),

              items: widget.shapes
                  .where((s) =>
              item.modelRef != null &&
                  s.modelRef.id == item.modelRef!.id)
                  .map((s) {
               return DropdownMenuItem<String>(
                value: s.id,
                child: Text(s.name),
               );
              }).toList(),

              onChanged: (id) {
               setState(() {
                item.shapeRef = FirebaseFirestore.instance
                    .collection('shapes')
                    .doc(id);
               });
               widget.record.productions = productions; // 🔥 مهم
               widget.onChanged();
              },
             ),
             SizedBox(height: 8.h),
              TextFormField(
              controller: qtyControllers[productions.indexOf(item)],
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(
               labelText: "الكمية",
               prefixIcon: Icon(Icons.numbers),
              ),
              onChanged: (v) {
               item.quantity = int.tryParse(v) ?? 0;
               widget.record.productions = productions; // مهم
               widget.onChanged();
              },
             ),
             SizedBox(height: 10.h),
            ],
           );
          }).toList(),
         ),
         TextButton.icon(
          onPressed: () {
           setState(() {
            productions.add(
             ProductionItem(
              productRef: null,
              modelRef: null,
              shapeRef: null,
              quantity: 0,
             ),
            );
            qtyControllers.add(TextEditingController()); // 👈 ضيف controller جديد
           });
           widget.record.productions = productions; // 🔥 مهم
           widget.onChanged();
          },
          icon: const Icon(Icons.add),
          label: const Text("إضافة"),
         ),
        ]],
        TextFormField(
         initialValue: widget.record.notes,
         decoration: InputDecoration(
          labelText: "ملاحظات",
          prefixIcon: Icon(Icons.note),
         ),
         onChanged: (v) {
          widget.record.notes = v;
          widget.onChanged();
         },
        ),
       ],
      ),
     ),
    ),
   ),
  );
 }
 @override
 void dispose() {
  for (var c in qtyControllers) {
   c.dispose();
  }
  _advanceController.dispose();
  super.dispose();
 }
}
