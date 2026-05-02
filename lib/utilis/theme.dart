import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import 'app_colors.dart';

final ThemeData appTheme = ThemeData(
  useMaterial3: true,

  /// 🎨 Colors
  colorScheme: ColorScheme.fromSeed(
    seedColor: AppColors.primary,
    primary: AppColors.primary,
    secondary: AppColors.secondary,
  ),

  scaffoldBackgroundColor: AppColors.background,

  /// 🔝 AppBar
  appBarTheme: const AppBarTheme(
    centerTitle: true,
    elevation: 0,
    backgroundColor: AppColors.primary,
    foregroundColor: Colors.white,
  ),

  /// 📦 Cards
  cardTheme: CardThemeData(
    color: AppColors.card,
    elevation: 4,
    shadowColor: Colors.black12,
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(16.r),
    ),
  ),

  /// 🔘 Buttons
  elevatedButtonTheme: ElevatedButtonThemeData(
    style: ElevatedButton.styleFrom(
      backgroundColor: AppColors.primary,
      foregroundColor: Colors.white,
      elevation: 0,
      padding:  EdgeInsets.symmetric(vertical: 12.h),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12.r),
      ),
    ),
  ),

  /// 🧾 Inputs
  inputDecorationTheme: InputDecorationTheme(
    filled: true,
    fillColor: Colors.white,
    contentPadding:
     EdgeInsets.symmetric(horizontal: 12.w, vertical: 10.h),
    border: OutlineInputBorder(
      borderRadius: BorderRadius.circular(12.r),
      borderSide: BorderSide.none,
    ),
    hintStyle: TextStyle(color: Colors.grey.shade600),
  ),

  /// 🔤 Text
  textTheme:  TextTheme(
    titleLarge: TextStyle(
      fontSize: 20.sp,
      fontWeight: FontWeight.bold,
    ),
    bodyMedium: TextStyle(
      fontSize: 14.sp,
    ),
  ),

  /// 🧊 Divider
  dividerTheme: const DividerThemeData(
    thickness: 1,
    space: 20,
  ),
);