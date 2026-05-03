import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:glass_wo/firebase_options.dart';
import 'package:glass_wo/providers/bouns_provider.dart';
import 'package:glass_wo/providers/model_provider.dart';
import 'package:glass_wo/providers/product_provider.dart';
import 'package:glass_wo/providers/settings_provider.dart';
import 'package:glass_wo/providers/shape_provider.dart';
import 'package:glass_wo/providers/worker_provider.dart';
import 'package:glass_wo/screens/homeScreen/home_screen.dart';
import 'package:glass_wo/service/model_service.dart';
import 'package:glass_wo/service/product_service.dart';
import 'package:glass_wo/service/shape-service.dart';
import 'package:glass_wo/service/worker_service.dart';
import 'package:glass_wo/utilis/theme.dart';
import 'package:provider/provider.dart';



void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  FirebaseFirestore.instance.settings = const Settings(
    persistenceEnabled: true,
    cacheSizeBytes: Settings.CACHE_SIZE_UNLIMITED,
  );

  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        // Workers
        ChangeNotifierProvider(
          create: (_) => WorkerProvider(WorkerService())..listen(),
        ),
        ChangeNotifierProvider(create: (_) => BonusProvider()..load()),
        ChangeNotifierProvider(create: (_) => SettingsProvider()..load()),
          ChangeNotifierProvider(create: (_) => ModelProvider(ModelService())..listenAll()),

        // Products
        ChangeNotifierProvider(
          create: (_) => ProductProvider(ProductService())..listen(),
        ),

        // Shapes (هنحدد productId جوه الشاشة)
        ChangeNotifierProvider(
          create: (_) => ShapeProvider(ShapeService()),
        ),
      ],
      child: ScreenUtilInit(
        designSize: const Size(384, 784),
    minTextAdapt: true,
    splitScreenMode: true,
    builder: (context, child) { return MaterialApp(
          debugShowCheckedModeBanner: false,
          title: 'Workers System',
          theme: appTheme,
          home: HomeScreen(),
        );}
      ),
    );
  }
}