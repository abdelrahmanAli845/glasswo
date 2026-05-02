import 'package:flutter/material.dart';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:provider/provider.dart';
import '../../models/daily_record.dart';
import '../../models/product.dart';
import '../../models/product_model.dart';
import '../../models/production_item.dart';
import '../../models/shape.dart';
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
 @override
 void initState() {
  super.initState();

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
 }
 @override
 void didUpdateWidget(covariant WorkerCard oldWidget) {
  super.didUpdateWidget(oldWidget);

  if (oldWidget.record != widget.record) {
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
   setState(() {});
  }
 }
 Future<void> pickTime(bool isCheckIn) async {
  final time = await showTimePicker(
   context: context,
   initialTime: TimeOfDay.now(),
  );

  if (time != null) {
   final now = DateTime.now();
   final date = DateTime(
    now.year,
    now.month,
    now.day,
    time.hour,
    time.minute,
   );

   setState(() {
    if (isCheckIn) {
     widget.record.checkIn = date;
    } else {
     widget.record.checkOut = date;
    }
   });

   widget.onChanged();
  }
 }

 double calculateSalary() {
  if (widget.record.isAbsent) {
   return 0;
  }

  double total = widget.worker.dailySalary;

  /// ⏱️ أوفر تايم (مهم حتى لو مفيش بونص)
  if (widget.record.checkIn != null && widget.record.checkOut != null) {
   final duration =
   widget.record.checkOut!.difference(widget.record.checkIn!);
   final hours = duration.inHours;

   final baseHours = widget.worker.workHours;

   if (hours > baseHours) {
    double hourRate = widget.worker.dailySalary / baseHours;
    total += (hours - baseHours) * (hourRate * 2);
   }
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
 @override
 Widget build(BuildContext context) {
  final totalSalary = calculateSalary();

  return GestureDetector(
   onTap: () => setState(() => isExpanded = !isExpanded),
   child: Container(
    margin:  EdgeInsets.symmetric(horizontal: 12.w, vertical: 8.h),
    child: Card(
     shape:
     RoundedRectangleBorder(borderRadius: BorderRadius.circular(16.r)),
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
          Column(
            children: [
             Text("غياب"),

             Switch(
               value: widget.record.isAbsent,
               onChanged: (v) {
                setState(() {
                 widget.record.isAbsent = v;
                });
                widget.onChanged();
               },
              ),
            ],
          ),
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
         /// ⏰ الوقت
         Row(
          children: [
           Expanded(
            child: ElevatedButton(
             onPressed: () => pickTime(true),
             child: Text(
              widget.record.checkIn == null
                  ? "حضور"
                  : "${widget.record.checkIn!.hour}:${widget.record.checkIn!.minute}",
             ),
            ),
           ),
           SizedBox(width: 8.w),
           Expanded(
            child: ElevatedButton(
             onPressed: () => pickTime(false),
             child: Text(
              widget.record.checkOut == null
                  ? "انصراف"
                  : "${widget.record.checkOut!.hour}:${widget.record.checkOut!.minute}",
             ),
            ),
           ),
          ],
         ),

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
  super.dispose();
 }
}
