import 'package:bill_vault/Service/firebase_service.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'Settings/helper/providers.dart';
import 'Settings/utils/p_colors.dart';
import 'Settings/utils/p_pages.dart';
import 'Settings/utils/p_routes.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  try {
    // Initialize Firebase
    await Firebase.initializeApp();
    
    // Initialize default data (run this once when app starts)
    await FirebaseService.initializeDefaultData();
    
    print('Firebase initialized successfully');
  } catch (e) {
    print('Error initializing Firebase: $e');
  }
  
  runApp(MultiProvider(providers: providers, child: const MyApp()));
}

final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      navigatorKey: navigatorKey,
      title: 'BillVault',
      theme: ThemeData(
        brightness: Brightness.dark,
        highlightColor: PColors.white,
        splashColor: Colors.transparent,
        scaffoldBackgroundColor: PColors.color000000,
        colorScheme: ColorScheme.fromSeed(
          seedColor: PColors.white,
          brightness: Brightness.dark,
        ),
        iconTheme: IconThemeData(color: PColors.white),
        useMaterial3: true,
        appBarTheme: AppBarTheme(
          backgroundColor: PColors.color000000,
          surfaceTintColor: PColors.color000000,
          foregroundColor: PColors.white,
          centerTitle: false,
        ),
      ),
      initialRoute: PPages.splash,
      onGenerateRoute: Routes.genericRoute,
    );
  }
}