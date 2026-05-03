import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:glass_wo/screens/dashboard/dashboard.dart';
import '../bouns/bouns_screen.dart';
import '../dailyScreen/daily_screen.dart';
import '../product_screen/product_screen.dart';
import '../settings/settings_screen.dart';
import '../worker screen/workers_screen.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final items = [
      {"title": "العمال", "icon": Icons.people},
      {"title": "المنتجات", "icon": Icons.factory},
      {"title": "إدارة اليوم", "icon": Icons.calendar_today},
      {"title": "التقارير", "icon": Icons.bar_chart},
      {"title": "الحوافز", "icon": Icons.settings_ethernet},
      {"title": "الإعدادات", "icon": Icons.settings},
    ];

    return Scaffold(
      appBar: AppBar(title: const Text("لوحة التحكم 👑")),
      body: GridView.builder(
        padding: EdgeInsets.all(16.w),
        itemCount: items.length,
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
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
                Navigator.push(context, MaterialPageRoute(builder: (_) => WorkersScreen()));
              } else if (i == 1) {
                Navigator.push(context, MaterialPageRoute(builder: (_) => ProductsScreen()));
              } else if (i == 2) {
                Navigator.push(context, MaterialPageRoute(builder: (_) => DailyScreen()));
              } else if (i == 3) {
                Navigator.push(context, MaterialPageRoute(builder: (_) => DashboardScreen()));
              } else if (i == 4) {
                Navigator.push(context, MaterialPageRoute(builder: (_) => BonusScreen()));
              } else if (i == 5) {
                Navigator.push(context, MaterialPageRoute(builder: (_) => const SettingsScreen()));
              }
            },
            child: Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20.r),
                boxShadow: const [BoxShadow(blurRadius: 10, color: Colors.black12)],
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
    );
  }
}
