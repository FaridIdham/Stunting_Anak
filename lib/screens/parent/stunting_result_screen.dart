import 'package:flutter/material.dart';
import '../../core/app_colors.dart';
import '../../models/stunting_detection_model.dart';

class StuntingResultScreen extends StatelessWidget {
  final StuntingDetectionModel detection;

  const StuntingResultScreen({super.key, required this.detection});

  @override
  Widget build(BuildContext context) {
    Color statusColor;
    Color statusBg;
    IconData statusIcon;

    switch (detection.status) {
      case StuntingStatus.normal:
        statusColor = AppColors.statusNormal;
        statusBg = AppColors.statusNormalBg;
        statusIcon = Icons.check_circle;
        break;
      case StuntingStatus.stunted:
        statusColor = AppColors.statusStunted;
        statusBg = AppColors.statusStuntedBg;
        statusIcon = Icons.warning_amber_rounded;
        break;
      case StuntingStatus.severelyStunted:
        statusColor = AppColors.statusSevere;
        statusBg = AppColors.statusSevereBg;
        statusIcon = Icons.dangerous;
        break;
      case StuntingStatus.tall:
        statusColor = AppColors.statusTall;
        statusBg = AppColors.statusTallBg;
        statusIcon = Icons.star;
        break;
    }

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        title: const Text('Hasil Deteksi Stunting AI', style: TextStyle(fontWeight: FontWeight.bold)),
        backgroundColor: statusColor,
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 800),
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(20),
            child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // STATUS BANNER UTAMA (FULL COLOUR)
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(24),
                border: Border.all(color: statusColor.withOpacity(0.3), width: 2),
                boxShadow: [
                  BoxShadow(
                    color: statusColor.withOpacity(0.18),
                    blurRadius: 20,
                    offset: const Offset(0, 8),
                  ),
                ],
              ),
              child: Column(
                children: [
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: statusBg,
                      shape: BoxShape.circle,
                    ),
                    child: Icon(statusIcon, color: statusColor, size: 54),
                  ),
                  const SizedBox(height: 14),
                  Text(
                    detection.statusText,
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.w900,
                      color: statusColor,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    'Pasien: ${detection.childName} (${detection.ageInMonths} Bulan)',
                    style: const TextStyle(fontSize: 14, color: Color(0xFF475569), fontWeight: FontWeight.w600),
                  ),
                  const SizedBox(height: 16),

                  // Z-SCORE GAUGE VISUALIZATION
                  Container(
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: Colors.grey.shade100,
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Column(
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Text('Skor Z Antropometri (TB/U):', style: TextStyle(fontWeight: FontWeight.w600, fontSize: 13)),
                            Text(
                              '${detection.zScoreHAZ} SD',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: statusColor,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 10),
                        // Bar visual range WHO
                        ClipRRect(
                          borderRadius: BorderRadius.circular(6),
                          child: Row(
                            children: [
                              Expanded(flex: 2, child: Container(height: 10, color: Colors.red.shade400)), // < -3
                              Expanded(flex: 2, child: Container(height: 10, color: Colors.orange.shade400)), // -3 to -2
                              Expanded(flex: 4, child: Container(height: 10, color: Colors.green.shade400)), // -2 to +2
                              Expanded(flex: 2, child: Container(height: 10, color: Colors.indigo.shade400)), // > +2
                            ],
                          ),
                        ),
                        const SizedBox(height: 6),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: const [
                            Text('<-3 SD\n(Parah)', textAlign: TextAlign.center, style: TextStyle(fontSize: 9.5, color: Colors.red)),
                            Text('-2 SD\n(Stunting)', textAlign: TextAlign.center, style: TextStyle(fontSize: 9.5, color: Colors.orange)),
                            Text('0 SD\n(Median WHO)', textAlign: TextAlign.center, style: TextStyle(fontSize: 9.5, color: Colors.green)),
                            Text('>+2 SD\n(Tinggi)', textAlign: TextAlign.center, style: TextStyle(fontSize: 9.5, color: Colors.indigo)),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 20),

            // METRIK RINCIAN INFERENSI YOLO & WHO
            Row(
              children: [
                Expanded(
                  child: _buildResultTile(
                    'Tinggi Badan',
                    '${detection.heightCm} cm',
                    Icons.straighten,
                    AppColors.featureYoloScan,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _buildResultTile(
                    'Berat Badan',
                    '${detection.weightKg} kg',
                    Icons.monitor_weight,
                    AppColors.featureNutrition,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _buildResultTile(
                    'Akurasi YOLO',
                    '${(detection.yoloConfidence * 100).toInt()}%',
                    Icons.verified_user,
                    AppColors.featureKMSChart,
                  ),
                ),
              ],
            ),

            const SizedBox(height: 20),

            // KARTU STATUS VALIDASI DOKTER / PAKAR
            Container(
              padding: const EdgeInsets.all(18),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(18),
                border: Border.all(color: AppColors.featureDoctor.withOpacity(0.3)),
              ),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: AppColors.featureDoctor.withOpacity(0.1),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(Icons.medical_services, color: AppColors.featureDoctor, size: 26),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Verifikasi Pakar Dokter Anak',
                          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          detection.validationStatus == DoctorValidation.approved
                              ? 'Telah diverifikasi oleh ${detection.doctorName}'
                              : 'Terkirim ke antrean dokter ahli untuk validasi klinis.',
                          style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
                        ),
                      ],
                    ),
                  ),
                  Chip(
                    label: Text(
                      detection.validationStatus == DoctorValidation.approved ? 'Terverifikasi' : 'Menunggu',
                      style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold),
                    ),
                    backgroundColor: detection.validationStatus == DoctorValidation.approved
                        ? Colors.green.shade100
                        : Colors.orange.shade100,
                  ),
                ],
              ),
            ),

            const SizedBox(height: 20),

            // REKOMENDASI GIZI KLINIS & TINDAKAN
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.04),
                    blurRadius: 10,
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: const [
                      Icon(Icons.restaurant, color: AppColors.featureNutrition, size: 22),
                      SizedBox(width: 8),
                      Text(
                        'Rencana Intervensi Nutrisi Berbasis AI',
                        style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: Color(0xFF0F172A)),
                      ),
                    ],
                  ),
                  const Divider(height: 24),
                  ...detection.nutritionalRecommendations.map((rec) => Padding(
                        padding: const EdgeInsets.only(bottom: 10),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text('• ', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                            Expanded(child: Text(rec, style: const TextStyle(fontSize: 13, height: 1.4))),
                          ],
                        ),
                      )),
                ],
              ),
            ),

            const SizedBox(height: 28),

            // TOMBOL AKSI
            ElevatedButton.icon(
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primaryBlue,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              ),
              onPressed: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Menghubungkan ke Dokter Spesialis Anak...'),
                    backgroundColor: AppColors.primaryBlue,
                  ),
                );
              },
              icon: const Icon(Icons.chat),
              label: const Text('Konsultasi Dokter Terkait Hasil Ini', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
            ),
            const SizedBox(height: 12),
            OutlinedButton(
              style: OutlinedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              ),
              onPressed: () => Navigator.pushReplacementNamed(context, '/parent_dashboard'),
              child: const Text('Kembali ke Dashboard Utama', style: TextStyle(fontWeight: FontWeight.bold)),
            ),
            const SizedBox(height: 24),
          ],
        ),
      ),
    ),
  ),
);
  }

  Widget _buildResultTile(String label, String value, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: color.withOpacity(0.25)),
      ),
      child: Column(
        children: [
          Icon(icon, color: color, size: 22),
          const SizedBox(height: 6),
          Text(value, style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: color)),
          const SizedBox(height: 2),
          Text(label, textAlign: TextAlign.center, style: const TextStyle(fontSize: 11, color: Color(0xFF64748B))),
        ],
      ),
    );
  }
}
