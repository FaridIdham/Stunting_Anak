import 'package:flutter/material.dart';

class AppColors {
  // Brand Primary & Gradients
  static const Color primaryBlue = Color(0xFF2563EB);
  static const Color primaryTeal = Color(0xFF0D9488);
  static const Color primaryPurple = Color(0xFF7C3AED);
  static const Color primaryPink = Color(0xFFDB2777);
  
  // Role Themes
  static const Color parentAccent = Color(0xFF10B981); // Emerald Green
  static const Color expertAccent = Color(0xFF3B82F6); // Royal Blue
  static const Color adminAccent = Color(0xFF8B5CF6);  // Deep Purple

  // Status Stunting Colors
  static const Color statusNormal = Color(0xFF10B981);       // Z-score >= -2 SD (Sehat)
  static const Color statusNormalBg = Color(0xFFD1FAE5);
  static const Color statusStunted = Color(0xFFF59E0B);      // -3 SD <= Z < -2 SD (Pendek/Stunting)
  static const Color statusStuntedBg = Color(0xFFFEF3C7);
  static const Color statusSevere = Color(0xFFEF4444);       // Z < -3 SD (Sangat Pendek / Parah)
  static const Color statusSevereBg = Color(0xFFFEE2E2);
  static const Color statusTall = Color(0xFF6366F1);         // Z > +2 SD (Tinggi)
  static const Color statusTallBg = Color(0xFFE0E7FF);

  // Feature Colors (Full Colour Theme)
  static const Color featureYoloScan = Color(0xFF06B6D4);     // Cyan AI Vision
  static const Color featureKMSChart = Color(0xFF8B5CF6);     // Violet Growth
  static const Color featureNutrition = Color(0xFFF97316);    // Vibrant Orange
  static const Color featureDoctor = Color(0xFF3B82F6);       // Doctor Blue
  static const Color featureNotification = Color(0xFFEC4899); // Rose Notification
  static const Color featureAdminAnalytics = Color(0xFF4F46E5); // Indigo Admin

  // Background & Surfaces
  static const Color backgroundLight = Color(0xFFF8FAFC);
  static const Color cardWhite = Colors.white;
  static const Color textDark = Color(0xFF0F172A);
  static const Color textMuted = Color(0xFF64748B);
  static const Color borderLight = Color(0xFFE2E8F0);

  // Vibrant Gradient Presets
  static const LinearGradient parentGradient = LinearGradient(
    colors: [Color(0xFF10B981), Color(0xFF06B6D4)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient yoloGradient = LinearGradient(
    colors: [Color(0xFF06B6D4), Color(0xFF3B82F6)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient doctorGradient = LinearGradient(
    colors: [Color(0xFF3B82F6), Color(0xFF8B5CF6)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient adminGradient = LinearGradient(
    colors: [Color(0xFF8B5CF6), Color(0xFFEC4899)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient notificationGradient = LinearGradient(
    colors: [Color(0xFFF43F5E), Color(0xFFFB923C)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );
}
