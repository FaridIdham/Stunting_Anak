import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/child_model.dart';
import '../models/stunting_detection_model.dart';
import '../models/notification_model.dart';

/// Supabase Database Service
/// Penyimpanan Database Realtime berbasis Cloud PostgreSQL Supabase
/// Terintegrasi dengan Realtime Channels (Postgres Changes) dan Row Level Security (RLS)
class SupabaseService {
  static final SupabaseService _instance = SupabaseService._internal();
  factory SupabaseService() => _instance;
  SupabaseService._internal();

  // ==================== KREDENSIAL SUPABASE ====================
  // Ganti URL dan Anon Key di bawah ini dengan kredensial project Supabase Anda:
  // Dapat diperoleh dari Dashboard Supabase -> Project Settings -> API
  static const String defaultSupabaseUrl = 'https://xyzstuntingguard.supabase.co';
  static const String defaultSupabaseAnonKey = 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.dummy_anon_key_stunting_ai_2026';

  static String supabaseUrl = defaultSupabaseUrl;
  static String supabaseAnonKey = defaultSupabaseAnonKey;

  bool _isInitialized = false;
  bool get isInitialized => _isInitialized;

  SupabaseClient? get client {
    if (!_isInitialized) return null;
    try {
      return Supabase.instance.client;
    } catch (_) {
      return null;
    }
  }

  /// Inisialisasi koneksi Supabase SDK
  Future<void> initialize({String? customUrl, String? customAnonKey}) async {
    if (customUrl != null) supabaseUrl = customUrl;
    if (customAnonKey != null) supabaseAnonKey = customAnonKey;

    try {
      await Supabase.initialize(
        url: supabaseUrl,
        anonKey: supabaseAnonKey,
        realtimeClientOptions: const RealtimeClientOptions(
          eventsPerSecond: 10,
        ),
      );
      _isInitialized = true;
      debugPrint('⚡ [Supabase] Berhasil terhubung ke Supabase Realtime: $supabaseUrl');
    } catch (e) {
      debugPrint('⚠️ [Supabase] Running in local-resilient fallback mode: $e');
      _isInitialized = false;
    }
  }

  // ==================== OPERASI TABEL CHILDREN (BALITA) ====================
  Future<List<ChildModel>> getChildren() async {
    if (client == null) return [];
    try {
      final response = await client!
          .from('children')
          .select()
          .order('created_at', ascending: false);
      return (response as List).map((row) => _mapToChild(row)).toList();
    } catch (e) {
      debugPrint('❌ [Supabase] Error getChildren: $e');
      return [];
    }
  }

  Future<bool> insertChild(ChildModel child) async {
    if (client == null) return false;
    try {
      await client!.from('children').insert({
        'id': child.id,
        'parent_id': child.parentId,
        'parent_name': child.parentName,
        'child_name': child.childName,
        'nik': child.nik,
        'gender': child.gender,
        'date_of_birth': child.dateOfBirth.toIso8601String(),
        'birth_weight_kg': child.birthWeightKg,
        'birth_height_cm': child.birthHeightCm,
        'address': child.address,
        'posyandu_name': child.posyanduName,
        'created_at': child.createdAt.toIso8601String(),
      });
      debugPrint('✅ [Supabase] Data balita ${child.childName} berhasil disimpan.');
      return true;
    } catch (e) {
      debugPrint('❌ [Supabase] Error insertChild: $e');
      return false;
    }
  }

  Future<bool> updateChild(ChildModel child) async {
    if (client == null) return false;
    try {
      await client!.from('children').update({
        'child_name': child.childName,
        'nik': child.nik,
        'gender': child.gender,
        'date_of_birth': child.dateOfBirth.toIso8601String(),
        'birth_weight_kg': child.birthWeightKg,
        'birth_height_cm': child.birthHeightCm,
        'address': child.address,
        'posyandu_name': child.posyanduName,
      }).eq('id', child.id);
      debugPrint('✅ [Supabase] Data balita ${child.childName} berhasil diupdate.');
      return true;
    } catch (e) {
      debugPrint('❌ [Supabase] Error updateChild: $e');
      return false;
    }
  }

  Future<bool> deleteChild(String id) async {
    if (client == null) return false;
    try {
      // Hapus riwayat deteksi terkait terlebih dahulu (Cascade)
      await client!.from('stunting_detections').delete().eq('child_id', id);
      await client!.from('children').delete().eq('id', id);
      debugPrint('🗑️ [Supabase] Balita $id berhasil dihapus dari cloud.');
      return true;
    } catch (e) {
      debugPrint('❌ [Supabase] Error deleteChild: $e');
      return false;
    }
  }

  // ==================== OPERASI TABEL STUNTING_DETECTIONS ====================
  Future<List<StuntingDetectionModel>> getDetections() async {
    if (client == null) return [];
    try {
      final response = await client!
          .from('stunting_detections')
          .select()
          .order('timestamp', ascending: false);
      return (response as List).map((row) => _mapToDetection(row)).toList();
    } catch (e) {
      debugPrint('❌ [Supabase] Error getDetections: $e');
      return [];
    }
  }

  Future<bool> insertDetection(StuntingDetectionModel det) async {
    if (client == null) return false;
    try {
      await client!.from('stunting_detections').insert({
        'id': det.id,
        'child_id': det.childId,
        'child_name': det.childName,
        'age_months': det.ageInMonths,
        'gender': det.gender,
        'measured_height_cm': det.heightCm,
        'measured_weight_kg': det.weightKg,
        'haz_score': det.zScoreHAZ,
        'waz_score': det.zScoreWAZ,
        'status': det.status.name,
        'yolo_confidence': det.yoloConfidence,
        'validation_status': det.validationStatus.name,
        'doctor_id': det.doctorId,
        'doctor_name': det.doctorName,
        'doctor_notes': det.doctorNotes,
        'nutritional_recommendations': det.nutritionalRecommendations,
        'timestamp': det.timestamp.toIso8601String(),
      });
      debugPrint('✅ [Supabase] Rekam medis deteksi stunting berhasil disimpan.');
      return true;
    } catch (e) {
      debugPrint('❌ [Supabase] Error insertDetection: $e');
      return false;
    }
  }

  Future<bool> updateDetection(StuntingDetectionModel det) async {
    if (client == null) return false;
    try {
      await client!.from('stunting_detections').update({
        'measured_height_cm': det.heightCm,
        'measured_weight_kg': det.weightKg,
        'haz_score': det.zScoreHAZ,
        'status': det.status.name,
        'validation_status': det.validationStatus.name,
        'doctor_notes': det.doctorNotes,
        'doctor_name': det.doctorName,
      }).eq('id', det.id);
      return true;
    } catch (e) {
      debugPrint('❌ [Supabase] Error updateDetection: $e');
      return false;
    }
  }

  Future<bool> deleteDetection(String id) async {
    if (client == null) return false;
    try {
      await client!.from('stunting_detections').delete().eq('id', id);
      return true;
    } catch (e) {
      debugPrint('❌ [Supabase] Error deleteDetection: $e');
      return false;
    }
  }

  // ==================== OPERASI TABEL NOTIFICATIONS ====================
  Future<bool> insertNotification(NotificationModel notif) async {
    if (client == null) return false;
    try {
      await client!.from('notifications').insert({
        'id': notif.id,
        'recipient_id': notif.recipientId,
        'title': notif.title,
        'message': notif.message,
        'type': notif.type.name,
        'is_read': notif.isRead,
        'related_child_id': notif.relatedChildId,
        'created_at': notif.timestamp.toIso8601String(),
      });
      return true;
    } catch (e) {
      debugPrint('❌ [Supabase] Error insertNotification: $e');
      return false;
    }
  }

  // ==================== KOSONGKAN SELURUH DATA SUPABASE ====================
  Future<bool> clearAllData() async {
    if (client == null) return false;
    try {
      // Hapus berurutan agar foreign key constraint tidak bentrok
      await client!.from('stunting_detections').delete().neq('id', '');
      await client!.from('notifications').delete().neq('id', '');
      await client!.from('children').delete().neq('id', '');
      debugPrint('🗑️ [Supabase] Seluruh data cloud (detections, notif, children) berhasil dikosongkan.');
      return true;
    } catch (e) {
      debugPrint('❌ [Supabase] Error clearAllData: $e');
      return false;
    }
  }

  // ==================== STREAM REALTIME CHANGES ====================
  Stream<List<Map<String, dynamic>>>? streamChildren() {
    if (client == null) return null;
    return client!.from('children').stream(primaryKey: ['id']);
  }

  Stream<List<Map<String, dynamic>>>? streamDetections() {
    if (client == null) return null;
    return client!.from('stunting_detections').stream(primaryKey: ['id']);
  }

  // ==================== MAPPERS ====================
  ChildModel _mapToChild(Map<String, dynamic> row) {
    return ChildModel(
      id: row['id'] ?? '',
      parentId: row['parent_id'] ?? '',
      parentName: row['parent_name'] ?? '',
      childName: row['child_name'] ?? '',
      nik: row['nik'] ?? '',
      gender: row['gender'] ?? 'L',
      dateOfBirth: DateTime.tryParse(row['date_of_birth'] ?? '') ?? DateTime.now(),
      birthWeightKg: (row['birth_weight_kg'] as num?)?.toDouble() ?? 3.0,
      birthHeightCm: (row['birth_height_cm'] as num?)?.toDouble() ?? 49.0,
      address: row['address'] ?? '',
      posyanduName: row['posyandu_name'] ?? '',
      createdAt: DateTime.tryParse(row['created_at'] ?? '') ?? DateTime.now(),
    );
  }

  StuntingDetectionModel _mapToDetection(Map<String, dynamic> row) {
    StuntingStatus status;
    try {
      status = StuntingStatus.values.byName(row['status'] ?? 'stunted');
    } catch (_) {
      status = StuntingStatus.stunted;
    }

    DoctorValidation valStatus;
    try {
      valStatus = DoctorValidation.values.byName(row['validation_status'] ?? 'pending');
    } catch (_) {
      valStatus = DoctorValidation.pending;
    }

    return StuntingDetectionModel(
      id: row['id'] ?? '',
      childId: row['child_id'] ?? '',
      childName: row['child_name'] ?? '',
      ageInMonths: row['age_months'] ?? 12,
      gender: row['gender'] ?? 'L',
      heightCm: (row['measured_height_cm'] as num?)?.toDouble() ?? 75.0,
      weightKg: (row['measured_weight_kg'] as num?)?.toDouble() ?? 9.0,
      zScoreHAZ: (row['haz_score'] as num?)?.toDouble() ?? -2.0,
      zScoreWAZ: (row['waz_score'] as num?)?.toDouble() ?? -1.0,
      status: status,
      yoloConfidence: (row['yolo_confidence'] as num?)?.toDouble() ?? 0.95,
      validationStatus: valStatus,
      doctorId: row['doctor_id'],
      doctorName: row['doctor_name'],
      doctorNotes: row['doctor_notes'],
      nutritionalRecommendations: List<String>.from(row['nutritional_recommendations'] ?? []),
      timestamp: DateTime.tryParse(row['timestamp'] ?? '') ?? DateTime.now(),
    );
  }
}
