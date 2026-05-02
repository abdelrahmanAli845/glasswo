import  'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:glass_wo/models/bouns.dart';
import 'package:glass_wo/screens/dashboard/dashboard.dart';
import '../../service/local_storage_service.dart';
import '../../models/daily_record.dart';
import '../../models/worker.dart';
import '../bouns/bouns_screen.dart';
import '../dailyScreen/daily_screen.dart';
import '../product_screen/product_screen.dart';
import '../worker screen/workers_screen.dart';

class HomeScreen extends StatefulWidget {
const HomeScreen({super.key});

@override
State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {

List<Worker> workers = [];
List<DailyRecord> records = [];
@override
void initState() {
 super.initState();
}


/// 📊 حسابات سريعة
int get totalWorkers => workers.length;

int get todayAttendance {
final today = DateTime.now();
return records.where((r) =>
r.date.day == today.day &&
r.date.month == today.month &&
r.date.year == today.year).length;
}

int get overtimeToday {
final today = DateTime.now();
return records.where((r) =>
r.date.day == today.day &&
r.date.month == today.month &&
r.date.year == today.year &&
r.onTime).length;
}

@override
Widget build(BuildContext context) {

final items = [
{"title": "العمال", "icon": Icons.people},
{"title": "المنتجات", "icon": Icons.factory},
{"title": "إدارة اليوم", "icon": Icons.calendar_today},
{"title": "التقارير", "icon": Icons.bar_chart},
 {"title": "الحوافز", "icon": Icons.settings_ethernet},

];

return Scaffold(
appBar: AppBar(title: const Text("لوحة التحكم 👑")),

body: Column(
children: [

/// 🔥 Stats فوق


/// 🔥 المينيو
Expanded(
child: GridView.builder(
padding:  EdgeInsets.all(16.w),
itemCount: items.length,
gridDelegate:
const SliverGridDelegateWithFixedCrossAxisCount(
crossAxisCount: 2,
mainAxisSpacing: 12,
crossAxisSpacing: 12,
),
itemBuilder: (_, i) {
final item = items[i];

return InkWell(
borderRadius: BorderRadius.circular(20.r),
onTap: () {
if (i == 0) {
Navigator.push(context,
MaterialPageRoute(builder: (_) => WorkersScreen()));
} else if (i == 1) {
Navigator.push(context,
MaterialPageRoute(builder: (_) => ProductsScreen()));
} else if (i == 2) {
Navigator.push(context,
MaterialPageRoute(builder: (_) => DailyScreen()));
} else if (i == 3) {
Navigator.push(
context,
MaterialPageRoute(
builder: (_) => DashboardScreen(

),
),
);
}else if (i == 4) {
 Navigator.push(
  context,
  MaterialPageRoute(
   builder: (_) => BonusScreen()
  ),
 );
}
},

child: Container(
decoration: BoxDecoration(
color: Colors.white,
borderRadius: BorderRadius.circular(20.r),
 boxShadow: const [
BoxShadow(
blurRadius: 10,
color: Colors.black12,
)
],
),
child: Column(
mainAxisAlignment: MainAxisAlignment.center,
children: [
Icon(item['icon'] as IconData, size: 40.w),
 SizedBox(height: 10.h),
Text(item['title'] as String),
],
),
),
);
},
),
),
],
),
);
}

/// 📊 كارت الإحصائية
Widget _buildStatCard(String title, int value) {
return Expanded(
child: Container(
margin:  EdgeInsets.symmetric(horizontal: 4.w),
padding:  EdgeInsets.all(12.w),
decoration: BoxDecoration(
color: Colors.blue.shade50,
borderRadius: BorderRadius.circular(15.r),
),
child: Column(
children: [
Text(title, style:  TextStyle(fontSize: 12.sp)),
 SizedBox(height: 5.h),
Text(
value.toString(),
style:  TextStyle(
fontSize: 18.sp,
fontWeight: FontWeight.bold),
),
],
),
),
);
}
}