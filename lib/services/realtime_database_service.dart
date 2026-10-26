import 'dart:async';
import 'package:flutter/foundation.dart';
import '../models/child_model.dart';
import '../models/stunting_detection_model.dart';
import '../models/notification_model.dart';
import '../models/user_model.dart';
import 'supabase_service.dart';

/// Realtime Database Service
/// Mendukung Supabase Realtime Database (PostgreSQL Cloud) & Firebase
/// Disertai in-memory reactive state controller untuk seamless local development & offline-first
class RealtimeDatabaseService extends ChangeNotifier {
  static final RealtimeDatabaseService _instance = RealtimeDatabaseService._internal();
  factory RealtimeDatabaseService() => _instance;

  final SupabaseService _supabase = SupabaseService();

  RealtimeDatabaseService._internal() {
    _seedInitialData();
    _initSupabaseSync();
  }

  // Reactive Data Stores (Realtime Cache & Live Streams)
  final List<ChildModel> _children = [];
  final List<StuntingDetectionModel> _detections = [];
  final List<NotificationModel> _notifications = [];
  final List<UserModel> _users = [];

  // Stream Controllers untuk sinkronisasi realtime antar pengguna
  final _childStreamController = StreamController<List<ChildModel>>.broadcast();
  final _detectionStreamController = StreamController<List<StuntingDetectionModel>>.broadcast();
  final _notificationStreamController = StreamController<List<NotificationModel>>.broadcast();

  Stream<List<ChildModel>> get childrenStream => _childStreamController.stream;
  Stream<List<StuntingDetectionModel>> get detectionsStream => _detectionStreamController.stream;
  Stream<List<NotificationModel>> get notificationsStream => _notificationStreamController.stream;

  List<ChildModel> get children => List.unmodifiable(_children);
  List<StuntingDetectionModel> get detections => List.unmodifiable(_detections);
  List<NotificationModel> get notifications => List.unmodifiable(_notifications);

  // Inisialisasi Sinkronisasi Realtime dengan Supabase Cloud
  Future<void> _initSupabaseSync() async {
    try {
      final cloudChildren = await _supabase.getChildren();
      if (cloudChildren.isNotEmpty) {
        _children.clear();
        _children.addAll(cloudChildren);
        _childStreamController.add(_children);
        notifyListeners();
      }

      final cloudDetections = await _supabase.getDetections();
      if (cloudDetections.isNotEmpty) {
        _detections.clear();
        _detections.addAll(cloudDetections);
        _detectionStreamController.add(_detections);
        notifyListeners();
      }
    } catch (e) {
      debugPrint('ℹ️ [RealtimeDB] Supabase sync fallback: $e');
    }
  }

  // ==================== OPERASI DATA ANAK ====================
  Future<void> registerChild(ChildModel child) async {
    _children.insert(0, child);
    _childStreamController.add(_children);
    notifyListeners();

    // Simpan ke Supabase Cloud Database Realtime
    unawaited(_supabase.insertChild(child));

    // Trigger notifikasi sambutan pendaftaran anak
    await sendNotification(
      NotificationModel(
        id: 'NOTIF-${DateTime.now().millisecondsSinceEpoch}',
        recipientId: child.parentId,
        title: '🎉 Pendaftaran Berhasil!',
        message: 'Data balita ${child.childName} berhasil didaftarkan. Silakan login untuk memulai pemantauan stunting.',
        type: NotificationType.systemAnnouncement,
        timestamp: DateTime.now(),
        relatedChildId: child.id,
      ),
    );
  }

  ChildModel? getChildById(String id) {
    try {
      return _children.firstWhere((c) => c.id == id);
    } catch (_) {
      return null;
    }
  }

  List<ChildModel> getChildrenByParent(String parentPhone) {
    final clean = parentPhone.replaceAll(RegExp(r'\D'), '');
    return _children.where((c) {
      final pId = c.parentId.replaceAll(RegExp(r'\D'), '');
      return c.parentId == parentPhone ||
          c.parentId == 'USER-$parentPhone' ||
          (clean.isNotEmpty && pId.contains(clean));
    }).toList();
  }

  // Update data balita secara realtime
  Future<void> updateChild(ChildModel updated) async {
    final index = _children.indexWhere((c) => c.id == updated.id);
    if (index != -1) {
      _children[index] = updated;
      _childStreamController.add(_children);
      notifyListeners();

      // Sinkronkan ke Supabase Cloud
      unawaited(_supabase.updateChild(updated));
    }
  }

  // Hapus data balita secara realtime
  Future<void> deleteChild(String id) async {
    _children.removeWhere((c) => c.id == id);
    _detections.removeWhere((d) => d.childId == id);
    _childStreamController.add(_children);
    _detectionStreamController.add(_detections);
    notifyListeners();

    // Hapus dari Supabase Cloud
    unawaited(_supabase.deleteChild(id));
  }

  // Update rekam medis pemeriksaan stunting
  Future<void> updateDetection(StuntingDetectionModel updated) async {
    final index = _detections.indexWhere((d) => d.id == updated.id);
    if (index != -1) {
      _detections[index] = updated;
      _detectionStreamController.add(_detections);
      notifyListeners();

      // Sinkronkan ke Supabase Cloud
      unawaited(_supabase.updateDetection(updated));
    }
  }

  // Hapus pemeriksaan stunting
  Future<void> deleteDetection(String id) async {
    _detections.removeWhere((d) => d.id == id);
    _detectionStreamController.add(_detections);
    notifyListeners();

    // Hapus dari Supabase Cloud
    unawaited(_supabase.deleteDetection(id));
  }

  // ==================== OPERASI DETEKSI YOLO STUNTING ====================
  Future<void> saveDetection(StuntingDetectionModel detection) async {
    _detections.insert(0, detection);
    _detectionStreamController.add(_detections);
    notifyListeners();

    // Simpan rekam medis ke Supabase Cloud
    unawaited(_supabase.insertDetection(detection));

    // Notifikasi Otomatis Berdasarkan Tingkat Keparahan
    if (detection.status == StuntingStatus.severelyStunted || detection.status == StuntingStatus.stunted) {
      await sendNotification(
        NotificationModel(
          id: 'ALERT-${DateTime.now().millisecondsSinceEpoch}',
          recipientId: 'PARENT',
          title: '⚠️ Peringatan Stunting Terdeteksi: ${detection.childName}',
          message: 'Hasil scan YOLO menunjukkan indikasi ${detection.statusText} (Z-Score HAZ: ${detection.zScoreHAZ}). Laporan diteruskan ke Dokter Spesialis untuk verifikasi.',
          type: NotificationType.stuntingAlert,
          timestamp: DateTime.now(),
          relatedChildId: detection.childId,
          relatedDetectionId: detection.id,
        ),
      );

      // Notifikasi otomatis ke antrean Dokter / Pakar
      await sendNotification(
        NotificationModel(
          id: 'DOC-${DateTime.now().millisecondsSinceEpoch}',
          recipientId: 'EXPERT',
          title: '🩺 Kasus Baru Memerlukan Validasi',
          message: 'Pasien ${detection.childName} (${detection.ageInMonths} Bulan) terindikasi ${detection.statusText}. Mohon tinjau rekam medis dan berikan resep intervensi.',
          type: NotificationType.doctorConsultation,
          timestamp: DateTime.now(),
          relatedChildId: detection.childId,
          relatedDetectionId: detection.id,
        ),
      );
    } else {
      await sendNotification(
        NotificationModel(
          id: 'OK-${DateTime.now().millisecondsSinceEpoch}',
          recipientId: 'PARENT',
          title: '🌟 Pertumbuhan Normal: ${detection.childName}',
          message: 'Alhamdulillah, tinggi badan anak berada dalam batas normal WHO (HAZ: ${detection.zScoreHAZ}). Pertahankan asupan gizi seimbang!',
          type: NotificationType.nutritionTip,
          timestamp: DateTime.now(),
          relatedChildId: detection.childId,
          relatedDetectionId: detection.id,
        ),
      );
    }
  }

  // Dokter Memvalidasi dan Memberi Catatan Klinis
  Future<void> validateDetectionByDoctor({
    required String detectionId,
    required String doctorId,
    required String doctorName,
    required String notes,
    required DoctorValidation status,
  }) async {
    final index = _detections.indexWhere((d) => d.id == detectionId);
    if (index != -1) {
      final old = _detections[index];
      _detections[index] = StuntingDetectionModel(
        id: old.id,
        childId: old.childId,
        childName: old.childName,
        timestamp: old.timestamp,
        ageInMonths: old.ageInMonths,
        gender: old.gender,
        heightCm: old.heightCm,
        weightKg: old.weightKg,
        zScoreHAZ: old.zScoreHAZ,
        zScoreWAZ: old.zScoreWAZ,
        status: old.status,
        yoloConfidence: old.yoloConfidence,
        keypoints: old.keypoints,
        validationStatus: status,
        doctorNotes: notes,
        doctorName: doctorName,
        doctorId: doctorId,
        imagePath: old.imagePath,
        nutritionalRecommendations: old.nutritionalRecommendations,
      );
      _detectionStreamController.add(_detections);
      notifyListeners();

      // Sinkronkan ke Supabase Cloud
      unawaited(_supabase.updateDetection(_detections[index]));

      // Kirim notifikasi realtime ke Orang Tua bahwa dokter telah memverifikasi
      await sendNotification(
        NotificationModel(
          id: 'VERIF-${DateTime.now().millisecondsSinceEpoch}',
          recipientId: old.childId,
          title: '📋 Validasi Medis dari $doctorName',
          message: 'Catatan dokter: "$notes"',
          type: NotificationType.doctorConsultation,
          timestamp: DateTime.now(),
          relatedChildId: old.childId,
          relatedDetectionId: old.id,
        ),
      );
    }
  }

  // ==================== NOTIFIKASI REALTIME ====================
  Future<void> sendNotification(NotificationModel notification) async {
    _notifications.insert(0, notification);
    _notificationStreamController.add(_notifications);
    notifyListeners();

    // Simpan ke Supabase Cloud
    unawaited(_supabase.insertNotification(notification));
  }

  Future<void> markNotificationAsRead(String id) async {
    final index = _notifications.indexWhere((n) => n.id == id);
    if (index != -1) {
      final old = _notifications[index];
      _notifications[index] = NotificationModel(
        id: old.id,
        recipientId: old.recipientId,
        title: old.title,
        message: old.message,
        type: old.type,
        timestamp: old.timestamp,
        isRead: true,
        relatedChildId: old.relatedChildId,
        relatedDetectionId: old.relatedDetectionId,
      );
      _notificationStreamController.add(_notifications);
      notifyListeners();
    }
  }

  int get unreadNotificationCount => _notifications.where((n) => !n.isRead).length;

  // ==================== DATA STATISTIK UNTUK ADMIN ====================
  Map<String, dynamic> getAdminStatistics() {
    final totalScans = _detections.length;
    final stuntedCount = _detections.where((d) =>
        d.status == StuntingStatus.stunted || d.status == StuntingStatus.severelyStunted).length;
    final normalCount = _detections.where((d) => d.status == StuntingStatus.normal).length;
    final severelyStuntedCount = _detections.where((d) => d.status == StuntingStatus.severelyStunted).length;

    final stuntingRate = totalScans > 0 ? (stuntedCount / totalScans * 100).toStringAsFixed(1) : '0.0';

    return {
      'totalChildren': _children.length,
      'totalScans': totalScans,
      'stuntedCount': stuntedCount,
      'severelyStuntedCount': severelyStuntedCount,
      'normalCount': normalCount,
      'stuntingRate': stuntingRate,
      'pendingValidations': _detections.where((d) => d.validationStatus == DoctorValidation.pending).length,
    };
  }

  // Mengosongkan seluruh data dari database (Balita, Deteksi Stunting, Notifikasi)
  Future<void> clearAllData() async {
    _children.clear();
    _detections.clear();
    _notifications.clear();
    _childStreamController.add(_children);
    _detectionStreamController.add(_detections);
    _notificationStreamController.add(_notifications);
    notifyListeners();

    // Hapus seluruh data dari Supabase Cloud
    unawaited(_supabase.clearAllData());
    debugPrint('🧹 [RealtimeDB] Seluruh database lokal & Supabase telah dikosongkan.');
  }

  void _seedInitialData() {
    // Database dalam kondisi bersih/kosong (clean slate) sesuai instruksi pengguna.
    // Data baru akan tercatat realtime saat pendaftaran anak atau scan dilakukan.
  }
}
