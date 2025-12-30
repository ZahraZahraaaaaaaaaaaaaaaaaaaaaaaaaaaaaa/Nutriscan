import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:smart_food_scanner/providers/product_provider.dart';
import 'package:smart_food_scanner/providers/user_profile_provider.dart';
import 'package:smart_food_scanner/providers/history_provider.dart';
import 'package:smart_food_scanner/providers/auth_provider.dart';
import 'package:smart_food_scanner/screens/splash_screen.dart';
import 'package:smart_food_scanner/theme/app_theme.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize Firebase
  // Note: Firebase must be configured in platform-specific files
  // For Android: google-services.json in android/app/
  // For iOS: GoogleService-Info.plist in ios/Runner/
  // For Web: Firebase config in web/index.html
  try {
    await Firebase.initializeApp();
  } catch (e) {
    debugPrint('Firebase initialization error: $e');
    debugPrint(
        'App will continue without Firebase. Some features may be limited.');
    // Continue without Firebase if initialization fails
  }

  runApp(const SmartFoodScannerApp());
}

class SmartFoodScannerApp extends StatelessWidget {
  const SmartFoodScannerApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthProvider()),
        ChangeNotifierProvider(create: (_) => ProductProvider()),
        ChangeNotifierProvider(create: (_) => UserProfileProvider()),
        ChangeNotifierProvider(create: (_) => HistoryProvider()),
      ],
      child: MaterialApp(
        title: 'Smart Food Scanner',
        theme: AppTheme.lightTheme,
        home: const SplashScreen(),
        debugShowCheckedModeBanner: false,
      ),
    );
  }
}
