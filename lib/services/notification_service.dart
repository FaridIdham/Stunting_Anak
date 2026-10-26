import 'package:flutter/foundation.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import '../models/notification_model.dart';
import 'realtime_database_service.dart';

/// Service Notifikasi Realtime Multiplatform (Android & iOS)
class NotificationService {
  static final NotificationService _instance = NotificationService._internal();
  factory NotificationService() => _instance;
  NotificationService._internal();

  final FlutterLocalNotificationsPlugin _localNotifications = FlutterLocalNotificationsPlugin();

  Future<void> initialize() async {
    // 1. Inisialisasi Android Settings (Notifikasi Channel)
    const AndroidInitializationSettings androidSettings =
        AndroidInitializationSettings('@mipmap/ic_launcher');

    // 2. Inisialisasi iOS Settings (Izin Banner, Badge, Suara)
    const DarwinInitializationSettings iosSettings = DarwinInitializationSettings(
      requestAlertPermission: true,
      requestBadgePermission: true,
      requestSoundPermission: true,
    );

    const InitializationSettings initSettings = InitializationSettings(
      android: androidSettings,
      iOS: iosSettings,
    );

    await _localNotifications.initialize(
      initSettings,
      onDidReceiveNotificationResponse: (NotificationResponse response) {
        // Handle navigasi ketika notifikasi diklik pengguna
        debugPrint('Notifikasi diklik: ${response.payload}');
      },
    );

    // 3. Konfigurasi Khusus Android 13+ & iOS Push Notifications
    await _requestPermissions();
  }

  Future<void> _requestPermissions() async {
    // Request permission untuk Android 13+
    final androidPlugin = _localNotifications
        .resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>();
    if (androidPlugin != null) {
      await androidPlugin.requestNotificationsPermission();
    }

    // Request permission untuk iOS
    final iosPlugin = _localNotifications
        .resolvePlatformSpecificImplementation<IOSFlutterLocalNotificationsPlugin>();
    if (iosPlugin != null) {
      await iosPlugin.requestPermissions(
        alert: true,
        badge: true,
        sound: true,
      );
    }
  }

  /// Menampilkan Notifikasi Instan di Layar HP (Android & iOS)
  Future<void> showNotification({
    required int id,
    required String title,
    required String body,
    String? payload,
  }) async {
    // Konfigurasi Notifikasi Android
    const AndroidNotificationDetails androidDetails = AndroidNotificationDetails(
      'stunting_alerts_channel',
      'Peringatan Stunting & Posyandu',
      channelDescription: 'Saluran notifikasi pemantauan gizi dan peringatan stunting',
      importance: Importance.max,
      priority: Priority.high,
      showWhen: true,
      icon: '@mipmap/ic_launcher',
    );

    // Konfigurasi Notifikasi iOS
    const DarwinNotificationDetails iosDetails = DarwinNotificationDetails(
      presentAlert: true,
      presentBadge: true,
      presentSound: true,
    );

    const NotificationDetails platformDetails = NotificationDetails(
      android: androidDetails,
      iOS: iosDetails,
    );

    await _localNotifications.show(
      id,
      title,
      body,
      platformDetails,
      payload: payload,
    );
  }
}
