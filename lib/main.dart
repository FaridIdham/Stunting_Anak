import 'package:flutter/material.dart';
import 'core/app_colors.dart';
import 'models/child_model.dart';
import 'models/stunting_detection_model.dart';
import 'screens/auth/child_registration_screen.dart';
import 'screens/auth/login_screen.dart';
import 'screens/parent/parent_dashboard.dart';
import 'screens/parent/yolo_scan_screen.dart';
import 'screens/parent/stunting_result_screen.dart';
import 'screens/parent/growth_chart_screen.dart';
import 'screens/expert/expert_dashboard.dart';
import 'screens/admin/admin_dashboard.dart';
import 'screens/notifications/notification_center_screen.dart';
import 'screens/parent/nutrition_tips_screen.dart';
import 'screens/parent/doctor_consult_screen.dart';

import 'services/notification_service.dart';
import 'services/supabase_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Inisialisasi Database Realtime Supabase
  try {
    await SupabaseService().initialize();
  } catch (e) {
    debugPrint('Supabase running with resilient fallback: $e');
  }
  
  // Inisialisasi Service Notifikasi Multiplatform (Android & iOS)
  try {
    await NotificationService().initialize();
  } catch (e) {
    debugPrint('Notification service running in standalone mode: $e');
  }
  
  runApp(const StuntingDetectApp());
}

class StuntingDetectApp extends StatelessWidget {
  const StuntingDetectApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'StuntingGuard AI - Deteksi Stunting Anak',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        primaryColor: AppColors.primaryTeal,
        scaffoldBackgroundColor: const Color(0xFFF8FAFC),
        colorScheme: ColorScheme.fromSeed(
          seedColor: AppColors.primaryTeal,
          primary: AppColors.primaryTeal,
          secondary: AppColors.featureYoloScan,
        ),
        appBarTheme: const AppBarTheme(
          centerTitle: false,
          elevation: 0,
        ),
      ),
      // Alur Utama:
      // 1. Registrasi Anak (/register_child)
      // 2. Masuk ke Fitur Login (/login)
      // 3. Setelah Login Berhasil -> Masuk Fitur Utama (/parent_dashboard / /expert_dashboard / /admin_dashboard)
      initialRoute: '/register_child',
      routes: {
        '/register_child': (context) => const ChildRegistrationScreen(),
        '/login': (context) => const LoginScreen(),
        '/parent_dashboard': (context) => const ParentDashboard(),
        '/expert_dashboard': (context) => const ExpertDashboard(),
        '/admin_dashboard': (context) => const AdminDashboard(),
        '/notifications': (context) => const NotificationCenterScreen(),
        '/growth_charts': (context) => const GrowthChartScreen(),
        '/nutrition_tips': (context) => const NutritionTipsScreen(),
        '/doctor_consult': (context) => const DoctorConsultScreen(),
      },
      onGenerateRoute: (settings) {
        if (settings.name == '/yolo_scan') {
          final child = settings.arguments as ChildModel;
          return MaterialPageRoute(
            builder: (context) => YoloScanScreen(child: child),
          );
        }
        if (settings.name == '/stunting_result') {
          final detection = settings.arguments as StuntingDetectionModel;
          return MaterialPageRoute(
            builder: (context) => StuntingResultScreen(detection: detection),
          );
        }
        return null;
      },
    );
  }
}
