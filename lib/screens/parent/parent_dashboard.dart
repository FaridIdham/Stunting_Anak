import 'package:flutter/material.dart';
import '../../core/app_colors.dart';
import '../../models/stunting_detection_model.dart';
import '../../models/child_model.dart';
import '../../services/auth_service.dart';
import '../../services/realtime_database_service.dart';
import '../../widgets/full_color_card.dart';

class ParentDashboard extends StatefulWidget {
  const ParentDashboard({super.key});

  @override
  State<ParentDashboard> createState() => _ParentDashboardState();
}

class _ParentDashboardState extends State<ParentDashboard> {
  final _realtimeDb = RealtimeDatabaseService();

  @override
  Widget build(BuildContext context) {
    final auth = AuthService();
    final currentChild = auth.selectedChild ??
        (_realtimeDb.children.isNotEmpty ? _realtimeDb.children.first : null);

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'StuntingGuard AI',
              style: TextStyle(color: Color(0xFF0F172A), fontSize: 18, fontWeight: FontWeight.w900),
            ),
            Text(
              'Akses Orang Tua (Mobile)',
              style: TextStyle(color: AppColors.parentAccent, fontSize: 12, fontWeight: FontWeight.w600),
            ),
          ],
        ),
        actions: [
          // Icon Notifikasi dengan Realtime Badge
          AnimatedBuilder(
            animation: _realtimeDb,
            builder: (context, _) {
              final unread = _realtimeDb.unreadNotificationCount;
              return Stack(
                alignment: Alignment.center,
                children: [
                  IconButton(
                    icon: const Icon(Icons.notifications_outlined, color: Color(0xFF334155), size: 26),
                    onPressed: () => Navigator.pushNamed(context, '/notifications'),
                  ),
                  if (unread > 0)
                    Positioned(
                      top: 8,
                      right: 8,
                      child: Container(
                        padding: const EdgeInsets.all(4),
                        decoration: const BoxDecoration(
                          color: AppColors.featureNotification,
                          shape: BoxShape.circle,
                        ),
                        child: Text(
                          '$unread',
                          style: const TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold),
                        ),
                      ),
                    ),
                ],
              );
            },
          ),
          IconButton(
            icon: const Icon(Icons.logout, color: Colors.redAccent),
            tooltip: 'Keluar',
            onPressed: () {
              auth.logout();
              Navigator.pushReplacementNamed(context, '/login');
            },
          ),
        ],
      ),
      body: currentChild == null
          ? _buildNoChildView()
          : Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 960),
                child: SingleChildScrollView(
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      // HERO CARD BALITA AKTIF (Gradien Emerald Cerah)
                      _buildChildHeroCard(currentChild),
                      const SizedBox(height: 20),

                      // TOMBOL UTAMA: SCAN KAMERA YOLO STUNTING (Full Colour Cyan)
                      _buildYoloScanActionCard(currentChild),
                      const SizedBox(height: 20),

                      // STATUS TERBARU & KMS CARD
                      _buildLatestDetectionStatusCard(currentChild),
                      const SizedBox(height: 20),

                      // GRID FITUR UTAMA FULL COLOUR
                      const Text(
                        'Menu Layanan Terpadu',
                        style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Color(0xFF0F172A)),
                      ),
                      const SizedBox(height: 12),
                      _buildFullColorFeatureGrid(currentChild),
                      const SizedBox(height: 24),

                      // RIWAYAT PENGUKURAN REALTIME
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text(
                            'Riwayat Tumbuh Kembang',
                            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Color(0xFF0F172A)),
                          ),
                          TextButton(
                            onPressed: () => Navigator.pushNamed(context, '/growth_charts'),
                            child: const Text('Lihat Grafik Lengkap', style: TextStyle(color: AppColors.featureKMSChart)),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      _buildDetectionHistoryList(currentChild),
                      const SizedBox(height: 30),
                    ],
                  ),
                ),
              ),
            ),
    );
  }

  Widget _buildChildHeroCard(ChildModel child) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: AppColors.parentGradient,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: AppColors.parentAccent.withOpacity(0.35),
            blurRadius: 18,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            children: [
              Container(
                width: 60,
                height: 60,
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.2),
                  shape: BoxShape.circle,
                  border: Border.all(color: Colors.white, width: 2),
                ),
                child: Center(
                  child: Text(
                    child.gender == 'L' ? '👦' : '👧',
                    style: const TextStyle(fontSize: 32),
                  ),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      child.childName,
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Usia: ${child.ageFormatted} • ${child.posyanduName}',
                      style: const TextStyle(fontSize: 13, color: Colors.white70),
                    ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.25),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  'NIK: ${child.nik.substring(0, 6)}...',
                  style: const TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.bold),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.18),
              borderRadius: BorderRadius.circular(14),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildMiniStat('Berat Lahir', '${child.birthWeightKg} kg'),
                Container(height: 24, width: 1, color: Colors.white30),
                _buildMiniStat('Panjang Lahir', '${child.birthHeightCm} cm'),
                Container(height: 24, width: 1, color: Colors.white30),
                _buildMiniStat('Jenis Kelamin', child.gender == 'L' ? 'Laki-laki' : 'Perempuan'),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMiniStat(String label, String value) {
    return Column(
      children: [
        Text(label, style: const TextStyle(fontSize: 11, color: Colors.white70)),
        const SizedBox(height: 2),
        Text(value, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: Colors.white)),
      ],
    );
  }

  Widget _buildYoloScanActionCard(ChildModel child) {
    return Container(
      decoration: BoxDecoration(
        gradient: AppColors.yoloGradient,
        borderRadius: BorderRadius.circular(22),
        boxShadow: [
          BoxShadow(
            color: AppColors.featureYoloScan.withOpacity(0.4),
            blurRadius: 18,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () {
            Navigator.pushNamed(context, '/yolo_scan', arguments: child);
          },
          borderRadius: BorderRadius.circular(22),
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.15),
                        blurRadius: 8,
                      )
                    ],
                  ),
                  child: const Icon(Icons.camera_alt, color: AppColors.featureYoloScan, size: 30),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: const [
                      Text(
                        'Pindai Stunting dengan YOLO',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 17,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      SizedBox(height: 4),
                      Text(
                        'Estimasi tinggi badan & kurva WHO otomatis dalam 3 detik.',
                        style: TextStyle(color: Colors.white70, fontSize: 12),
                      ),
                    ],
                  ),
                ),
                const Icon(Icons.arrow_forward_ios, color: Colors.white, size: 18),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildLatestDetectionStatusCard(ChildModel child) {
    return AnimatedBuilder(
      animation: _realtimeDb,
      builder: (context, _) {
        final scans = _realtimeDb.detections.where((d) => d.childId == child.id).toList();
        if (scans.isEmpty) {
          return Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.amber.shade50,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: Colors.amber.shade200),
            ),
            child: Row(
              children: const [
                Icon(Icons.info_outline, color: Colors.amber),
                SizedBox(width: 12),
                Expanded(
                  child: Text(
                    'Belum ada riwayat deteksi. Tekan tombol kamera YOLO di atas untuk deteksi pertama.',
                    style: TextStyle(fontSize: 13, color: Colors.brown),
                  ),
                )
              ],
            ),
          );
        }

        final latest = scans.first;
        Color badgeColor;
        Color badgeBg;
        IconData badgeIcon;

        switch (latest.status) {
          case StuntingStatus.normal:
            badgeColor = AppColors.statusNormal;
            badgeBg = AppColors.statusNormalBg;
            badgeIcon = Icons.check_circle;
            break;
          case StuntingStatus.stunted:
            badgeColor = AppColors.statusStunted;
            badgeBg = AppColors.statusStuntedBg;
            badgeIcon = Icons.warning_amber_rounded;
            break;
          case StuntingStatus.severelyStunted:
            badgeColor = AppColors.statusSevere;
            badgeBg = AppColors.statusSevereBg;
            badgeIcon = Icons.dangerous;
            break;
          case StuntingStatus.tall:
            badgeColor = AppColors.statusTall;
            badgeBg = AppColors.statusTallBg;
            badgeIcon = Icons.star;
            break;
        }

        return Container(
          padding: const EdgeInsets.all(18),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: badgeColor.withOpacity(0.3), width: 1.5),
            boxShadow: [
              BoxShadow(
                color: badgeColor.withOpacity(0.1),
                blurRadius: 14,
                offset: const Offset(0, 6),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Status Pertumbuhan Terkini',
                    style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Color(0xFF64748B)),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(color: badgeBg, borderRadius: BorderRadius.circular(20)),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(badgeIcon, color: badgeColor, size: 14),
                        const SizedBox(width: 4),
                        Text(
                          latest.statusText,
                          style: TextStyle(color: badgeColor, fontSize: 12, fontWeight: FontWeight.bold),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 14),
              Row(
                children: [
                  Expanded(
                    child: _buildMetricItem('Tinggi Badan (YOLO)', '${latest.heightCm} cm', Icons.height, AppColors.featureYoloScan),
                  ),
                  Expanded(
                    child: _buildMetricItem('Z-Score TB/U', '${latest.zScoreHAZ} SD', Icons.analytics, AppColors.featureKMSChart),
                  ),
                  Expanded(
                    child: _buildMetricItem('Berat Badan', '${latest.weightKg} kg', Icons.scale, AppColors.featureNutrition),
                  ),
                ],
              ),
              if (latest.doctorNotes != null) ...[
                const Divider(height: 24),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Icon(Icons.verified, color: AppColors.featureDoctor, size: 18),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        'Catatan ${latest.doctorName}: "${latest.doctorNotes}"',
                        style: const TextStyle(fontSize: 12.5, fontStyle: FontStyle.italic, color: Color(0xFF334155)),
                      ),
                    ),
                  ],
                ),
              ],
            ],
          ),
        );
      },
    );
  }

  Widget _buildMetricItem(String label, String value, IconData icon, Color color) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 4),
      padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 8),
      decoration: BoxDecoration(
        color: color.withOpacity(0.08),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        children: [
          Icon(icon, color: color, size: 18),
          const SizedBox(height: 4),
          Text(value, style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: color)),
          const SizedBox(height: 2),
          Text(label, textAlign: TextAlign.center, style: const TextStyle(fontSize: 10, color: Color(0xFF64748B))),
        ],
      ),
    );
  }

  Widget _buildFullColorFeatureGrid(ChildModel child) {
    final features = [
      {
        'title': 'Kamera YOLO',
        'subtitle': 'Scan Tubuh AI',
        'icon': Icons.qr_code_scanner,
        'color': AppColors.featureYoloScan,
        'route': '/yolo_scan',
      },
      {
        'title': 'Kurva KMS WHO',
        'subtitle': 'Grafik Standar',
        'icon': Icons.show_chart,
        'color': AppColors.featureKMSChart,
        'route': '/growth_charts',
      },
      {
        'title': 'Gizi & MPASI',
        'subtitle': 'Menu Cegah Stunting',
        'icon': Icons.restaurant_menu,
        'color': AppColors.featureNutrition,
        'route': '/nutrition_tips',
      },
      {
        'title': 'Konsul Dokter',
        'subtitle': 'Pakar Spesialis',
        'icon': Icons.medical_services,
        'color': AppColors.featureDoctor,
        'route': '/doctor_consult',
      },
    ];

    return GridView.builder(
      physics: const NeverScrollableScrollPhysics(),
      shrinkWrap: true,
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        mainAxisSpacing: 14,
        crossAxisSpacing: 14,
        childAspectRatio: 1.45,
      ),
      itemCount: features.length,
      itemBuilder: (context, index) {
        final item = features[index];
        final color = item['color'] as Color;
        return InkWell(
          onTap: () {
            final route = item['route'] as String;
            if (route == '/yolo_scan') {
              Navigator.pushNamed(context, '/yolo_scan', arguments: child);
            } else if (route.isNotEmpty) {
              Navigator.pushNamed(context, route);
            }
          },
          borderRadius: BorderRadius.circular(18),
          child: Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(18),
              border: Border.all(color: color.withOpacity(0.2), width: 1.5),
              boxShadow: [
                BoxShadow(
                  color: color.withOpacity(0.12),
                  blurRadius: 12,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: color,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Icon(item['icon'] as IconData, color: Colors.white, size: 20),
                ),
                const SizedBox(height: 10),
                Text(
                  item['title'] as String,
                  style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Color(0xFF0F172A)),
                ),
                const SizedBox(height: 2),
                Text(
                  item['subtitle'] as String,
                  style: const TextStyle(fontSize: 11, color: Color(0xFF64748B)),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildDetectionHistoryList(ChildModel child) {
    return AnimatedBuilder(
      animation: _realtimeDb,
      builder: (context, _) {
        final childDetections = _realtimeDb.detections.where((d) => d.childId == child.id).toList();
        if (childDetections.isEmpty) {
          return const Center(child: Text('Belum ada riwayat pemeriksaan.'));
        }

        return ListView.separated(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: childDetections.length,
          separatorBuilder: (_, __) => const SizedBox(height: 10),
          itemBuilder: (context, index) {
            final item = childDetections[index];
            return Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: Colors.grey.shade200),
              ),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: item.status == StuntingStatus.normal
                          ? AppColors.statusNormalBg
                          : AppColors.statusStuntedBg,
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      Icons.accessibility_new,
                      color: item.status == StuntingStatus.normal
                          ? AppColors.statusNormal
                          : AppColors.statusStunted,
                      size: 22,
                    ),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          '${item.heightCm} cm • ${item.statusText}',
                          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                        ),
                        const SizedBox(height: 3),
                        Text(
                          'Z-Score HAZ: ${item.zScoreHAZ} SD • Akurasi YOLO: ${(item.yoloConfidence * 100).toInt()}%',
                          style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
                        ),
                      ],
                    ),
                  ),
                  Chip(
                    label: Text(
                      item.validationStatus == DoctorValidation.approved ? 'Terverifikasi' : 'Menunggu Dokter',
                      style: TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                        color: item.validationStatus == DoctorValidation.approved ? Colors.green : Colors.orange,
                      ),
                    ),
                    backgroundColor: item.validationStatus == DoctorValidation.approved
                        ? Colors.green.shade50
                        : Colors.orange.shade50,
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildNoChildView() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.child_care, size: 70, color: AppColors.parentAccent),
            const SizedBox(height: 16),
            const Text(
              'Belum Ada Balita Terdaftar',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            const Text(
              'Silakan daftarkan anak Anda terlebih dahulu untuk memulai pengukuran stunting.',
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.grey),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              style: ElevatedButton.styleFrom(backgroundColor: AppColors.parentAccent),
              onPressed: () => Navigator.pushNamed(context, '/register_child'),
              child: const Text('Registrasi Balita'),
            )
          ],
        ),
      ),
    );
  }
}
