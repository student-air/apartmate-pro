import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:apartmate/firebase_options.dart';
import 'package:apartmate/core/bindings/initial_binding.dart';
import 'package:apartmate/core/constants/app_strings.dart';
import 'package:apartmate/core/theme/app_theme.dart';
import 'package:apartmate/core/services/app_notification_service.dart';
import 'package:apartmate/routes/app_pages.dart';
import 'package:apartmate/routes/app_routes.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  await AppNotificationService.init();

  // Ask for notification permission once on first install
  final prefs = await SharedPreferences.getInstance();
  final askedBefore =
      prefs.getBool('notification_permission_asked') ?? false;

  if (!askedBefore) {
    await AppNotificationService.requestPermission();
    await prefs.setBool('notification_permission_asked', true);
  }

  runApp(const ApartMateApp());
}

class ApartMateApp extends StatelessWidget {
  const ApartMateApp({super.key});

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      title: AppStrings.appName,
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light,
      initialBinding: InitialBinding(),
      initialRoute: AppRoutes.splash,
      getPages: AppPages.pages,
      builder: (context, child) {
        precacheImage(
          const AssetImage('assets/images/logo.png'),
          context,
        );

        return child ?? const SizedBox.shrink();
      },
    );
  }
}