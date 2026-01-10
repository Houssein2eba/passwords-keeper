import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'data/hive_manager.dart';
import 'data/password_repository.dart';
import 'app_lock/app_lock_controller.dart';
import 'app_lock/lock_screen.dart';
import 'ui/home_screen.dart';
import 'ui/edit_entry_screen.dart';
import 'ui/settings_screen.dart';

void main() async {

  WidgetsFlutterBinding.ensureInitialized();
  
  // Initialize Hive
  final hiveManager = HiveManager();
  await hiveManager.init();
  
  // Initialize GetX dependencies
  Get.put(hiveManager);
  Get.put(PasswordRepository());
  Get.put(AppLockController());
  
  // Set system UI overlay style
  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.light,
    ),
  );
  
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      title: 'Password Guardian',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.deepPurple,
        brightness: Brightness.dark,
        scaffoldBackgroundColor: const Color(0xFF1A1A2E),
        colorScheme: const ColorScheme.dark(
          primary: Color(0xFF6C63FF),
          secondary: Color(0xFF6C63FF),
          surface: Color(0xFF2D2D44),
        ),
      ),
      home: const AppWrapper(),
      getPages: [
        GetPage(name: '/home', page: () => const HomeScreen()),
        GetPage(name: '/edit', page: () => const EditEntryScreen()),
        GetPage(name: '/settings', page: () => const SettingsScreen()),
      ],

    );
  }
}

class AppWrapper extends StatelessWidget {
  const AppWrapper({super.key});

  @override
  Widget build(BuildContext context) {
    final AppLockController lockController = Get.find<AppLockController>();
    
    return Obx(() {
      // Show lock screen if locked
      if (lockController.isLocked.value && lockController.isPinSet.value) {
        return const LockScreen();
      }
      
      // Show home screen if unlocked or no PIN set
      return const HomeScreen();
    });
  }
}
