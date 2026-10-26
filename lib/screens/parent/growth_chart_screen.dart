import 'package:flutter/material.dart';
import '../../core/app_colors.dart';
import '../../services/auth_service.dart';
import '../../services/realtime_database_service.dart';

class GrowthChartScreen extends StatelessWidget {
  const GrowthChartScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final auth = AuthService();
    final child = auth.selectedChild ??
        (RealtimeDatabaseService().children.isNotEmpty
            ? RealtimeDatabaseService().children.first
            : null);

    final detections = RealtimeDatabaseService()
        .detections
        .where((d) => child != null && d.childId == child.id)
        .toList();

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        title: const Text('Kurva Pertumbuhan KMS (WHO)', style: TextStyle(fontWeight: FontWeight.bold)),
        backgroundColor: AppColors.featureKMSChart,
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // INFORMASI KURVA WHO
            Container(
              padding: const EdgeInsets.all(18),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: AppColors.featureKMSChart.withOpacity(0.3)),
                boxShadow: [
                  BoxShadow(color: AppColors.featureKMSChart.withOpacity(0.08), blurRadius: 12, offset: const Offset(0, 4)),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: const [
                      Icon(Icons.insights, color: AppColors.featureKMSChart, size: 24),
                      SizedBox(width: 10),
                      Text(
                        'Standar Antropometri WHO & Kemenkes RI',
                        style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Grafik membandingkan panjang/tinggi badan ${child?.childName ?? "Balita"} terhadap kurva baku WHO Child Growth Standards.',
                    style: const TextStyle(fontSize: 12.5, color: Color(0xFF64748B)),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 20),

            // VISUALISASI KURVA STANDAR PERTUMBUHAN
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 10),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Kurva Panjang/Tinggi Badan Menurut Umur (PB/U)',
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                  ),
                  const SizedBox(height: 16),
                  Container(
                    height: 240,
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: const Color(0xFFF1F5F9),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.show_chart, size: 64, color: AppColors.featureKMSChart.withOpacity(0.7)),
                          const SizedBox(height: 8),
                          const Text('Grafik Baku WHO Standard (0 - 60 Bulan)',
                              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                          const SizedBox(height: 6),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              _buildLegendItem('Median (+0 SD)', Colors.green),
                              const SizedBox(width: 12),
                              _buildLegendItem('Garis Batas Stunting (-2 SD)', Colors.orange),
                              const SizedBox(width: 12),
                              _buildLegendItem('Stunting Berat (-3 SD)', Colors.red),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 20),

            // LOG PENGUKURAN
            const Text(
              'Log Pengukuran Terkini',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),

            if (detections.isEmpty)
              const Center(child: Text('Belum ada data pengukuran.'))
            else
              ...detections.map((det) => Container(
                    margin: const EdgeInsets.only(bottom: 10),
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(color: Colors.grey.shade200),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('Usia ${det.ageInMonths} Bulan: ${det.heightCm} cm',
                                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                            Text('BB: ${det.weightKg} kg • Akurasi YOLO: ${(det.yoloConfidence * 100).toInt()}%',
                                style: const TextStyle(fontSize: 12, color: Colors.grey)),
                          ],
                        ),
                        Chip(
                          label: Text(
                            'HAZ ${det.zScoreHAZ} SD',
                            style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold),
                          ),
                          backgroundColor: det.zScoreHAZ >= -2.0 ? Colors.green.shade100 : Colors.orange.shade100,
                        ),
                      ],
                    ),
                  )),
          ],
        ),
      ),
    );
  }

  Widget _buildLegendItem(String label, Color color) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(width: 10, height: 10, decoration: BoxDecoration(color: color, shape: BoxShape.circle)),
        const SizedBox(width: 4),
        Text(label, style: TextStyle(fontSize: 11, color: Colors.grey.shade800, fontWeight: FontWeight.w600)),
      ],
    );
  }
}
