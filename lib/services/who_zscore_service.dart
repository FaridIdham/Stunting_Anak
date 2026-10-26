import 'dart:math';
import '../models/stunting_detection_model.dart';

/// Implementasi Algoritma Standar Antropometri WHO (World Health Organization)
/// dan Kemenkes RI No. 2 Tahun 2020:
/// Metode LMS (Lambda-Mu-Sigma) untuk menghitung Z-Score TB/U (Height-for-Age) dan BB/U (Weight-for-Age)
class WhoZScoreService {
  // Referensi Data Standar WHO Median (M), Box-Cox (L), dan Koefisien Variasi (S)
  // Berdasarkan Usia (0 - 60 Bulan) untuk Laki-laki & Perempuan (Height-for-Age)
  
  static final Map<int, List<double>> _whoHeightBoy = {
    0: [1.0, 49.9, 0.0379],  // [L, M (cm), S]
    1: [1.0, 54.7, 0.0356],
    2: [1.0, 58.4, 0.0343],
    3: [1.0, 61.4, 0.0336],
    6: [1.0, 67.6, 0.0329],
    9: [1.0, 72.0, 0.0330],
    12: [1.0, 75.7, 0.0334],
    18: [1.0, 82.3, 0.0343],
    24: [1.0, 87.8, 0.0355],
    30: [1.0, 92.4, 0.0366],
    36: [1.0, 96.1, 0.0375],
    42: [1.0, 99.9, 0.0384],
    48: [1.0, 103.3, 0.0392],
    54: [1.0, 106.7, 0.0399],
    60: [1.0, 110.0, 0.0406],
  };

  static final Map<int, List<double>> _whoHeightGirl = {
    0: [1.0, 49.1, 0.0378],
    1: [1.0, 53.7, 0.0355],
    2: [1.0, 57.1, 0.0342],
    3: [1.0, 59.8, 0.0335],
    6: [1.0, 65.7, 0.0328],
    9: [1.0, 70.1, 0.0329],
    12: [1.0, 74.0, 0.0335],
    18: [1.0, 80.7, 0.0346],
    24: [1.0, 86.4, 0.0359],
    30: [1.0, 91.2, 0.0371],
    36: [1.0, 95.1, 0.0381],
    42: [1.0, 99.0, 0.0390],
    48: [1.0, 102.7, 0.0398],
    54: [1.0, 106.2, 0.0406],
    60: [1.0, 109.4, 0.0413],
  };

  /// Menghitung Height-for-Age Z-Score (HAZ / Z-Score TB/U) menggunakan formula LMS:
  /// Z = [(y / M)^L - 1] / (L * S) jika L != 0
  /// Z = ln(y / M) / S jika L == 0
  static double calculateHAZ({
    required double heightCm,
    required int ageInMonths,
    required String gender,
  }) {
    final table = (gender.toUpperCase() == 'P') ? _whoHeightGirl : _whoHeightBoy;

    // Interpolasi linier jika bulan di antara key tabel
    final keys = table.keys.toList()..sort();
    int lowerKey = keys.first;
    int upperKey = keys.last;

    for (int k in keys) {
      if (k <= ageInMonths) lowerKey = k;
      if (k >= ageInMonths) {
        upperKey = k;
        break;
      }
    }

    double l, m, s;
    if (lowerKey == upperKey) {
      l = table[lowerKey]![0];
      m = table[lowerKey]![1];
      s = table[lowerKey]![2];
    } else {
      double t = (ageInMonths - lowerKey) / (upperKey - lowerKey);
      l = table[lowerKey]![0] + t * (table[upperKey]![0] - table[lowerKey]![0]);
      m = table[lowerKey]![1] + t * (table[upperKey]![1] - table[lowerKey]![1]);
      s = table[lowerKey]![2] + t * (table[upperKey]![2] - table[lowerKey]![2]);
    }

    double zScore;
    if (l.abs() < 0.01) {
      zScore = log(heightCm / m) / s;
    } else {
      zScore = (pow(heightCm / m, l) - 1.0) / (l * s);
    }

    // Bulatkan ke 2 desimal
    return (zScore * 100).roundToDouble() / 100;
  }

  /// Menghitung Weight-for-Age Z-score (BB/U) estimasi kasar
  static double calculateWAZ({
    required double weightKg,
    required int ageInMonths,
    required String gender,
  }) {
    // Estimasi bobot median anak normal
    double medianWeight = 3.3 + (0.6 * ageInMonths);
    if (ageInMonths > 12) {
      medianWeight = 9.0 + (0.2 * (ageInMonths - 12));
    }
    double sd = medianWeight * 0.12;
    double z = (weightKg - medianWeight) / sd;
    return (z * 100).roundToDouble() / 100;
  }

  /// Klasifikasi Status Stunting Berdasarkan Pedoman Kemenkes RI & WHO
  static StuntingStatus classifyStunting(double haz) {
    if (haz < -3.0) {
      return StuntingStatus.severelyStunted; // Sangat Pendek / Parah
    } else if (haz < -2.0) {
      return StuntingStatus.stunted;         // Pendek / Stunting
    } else if (haz <= 2.0) {
      return StuntingStatus.normal;          // Normal
    } else {
      return StuntingStatus.tall;            // Tinggi
    }
  }

  /// Menghasilkan Rekomendasi Nutrisi Klinis berbasis AI berdasarkan status stunting
  static List<String> generateNutritionalPlan(StuntingStatus status, int ageInMonths) {
    switch (status) {
      case StuntingStatus.severelyStunted:
        return [
          '🚨 Prioritas Rujukan: Segera bawa anak ke Dokter Spesialis Anak (Sp.A) di Faskes/RSUD terdekat.',
          '🥩 Asupan Protein Hewani Tinggi: Minimal 2 butir telur per hari, hati ayam, dan ikan kembung/salmon.',
          '🥛 Pemberian Pangan Olahan untuk Keperluan Medis Khusus (PKMK) / Formula Padat Energi sesuai anjuran dokter.',
          '💊 Suplementasi Mikronutrien: Sirup Zink (20 mg/hari selama 14 hari) dan suplemen Zat Besi (Fe).',
          '🩺 Evaluasi infeksi kronis (Tuberkulosis / ISK) yang sering menghambat penyerapan gizi.'
        ];
      case StuntingStatus.stunted:
        return [
          '⚠️ Intervensi Gizi 1000 Hari Pertama Kehidupan (HPK) intensif.',
          '🍳 Tingkatkan variasi MPASI padat gizi berbasis protein hewani (daging sapi, ayam, telur, ikan bandeng/kembung).',
          '🥑 Tambahkan asupan lemak sehat (santan, minyak kelapa, keju) untuk meningkatkan densitas kalori.',
          '🥦 Suplemen vitamin A, zinc, dan garam beryodium teratur di Posyandu.',
          '📈 Jadwalkan monitoring berkala tinggi badan tiap 2 minggu sekali via aplikasi.'
        ];
      case StuntingStatus.normal:
        return [
          '✅ Pertumbuhan anak optimal sesuai kurva standar WHO!',
          '🥗 Pertahankan pola makan gizi seimbang: Isi Piringku (1/3 karbohidrat, 1/3 sayur-buah, 1/3 lauk pauk protein tinggi).',
          '🏃‍♂️ Stimulasi aktivitas motorik kasar dan waktu tidur malam cukup (10-12 jam) untuk pelepasan Growth Hormone.',
          '💉 Lengkapi imunisasi dasar dan pantau rutin penimbangan bulanan di Posyandu.'
        ];
      case StuntingStatus.tall:
        return [
          '🌟 Pertumbuhan tinggi anak sangat baik di atas rata-rata populasi.',
          '🍎 Jaga kecukupan gizi mikro kalsium dan vitamin D untuk mendukung perkembangan kepadatan tulang.',
          '🛡️ Tetap jaga keseimbangan berat badan terhadap tinggi badan (BB/TB) agar terhindar dari gizi lebih.'
        ];
    }
  }
}
