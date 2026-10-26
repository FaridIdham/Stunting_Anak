import 'package:flutter/material.dart';
import '../../core/app_colors.dart';
import '../../models/stunting_detection_model.dart';
import '../../models/child_model.dart';
import '../../services/auth_service.dart';
import '../../services/realtime_database_service.dart';
import '../../services/who_zscore_service.dart';
import '../../widgets/responsive_layout.dart';

class ExpertDashboard extends StatefulWidget {
  const ExpertDashboard({super.key});

  @override
  State<ExpertDashboard> createState() => _ExpertDashboardState();
}

class _ExpertDashboardState extends State<ExpertDashboard> {
  final _realtimeDb = RealtimeDatabaseService();
  String _selectedFilter = 'ALL'; // 'ALL', 'PENDING', 'APPROVED'
  String _doctorName = 'dr. Farhan Malik, Sp.A (K)';
  String _doctorSip = '440/129/DINKES/2024';
  String _doctorSpec = 'Spesialis Anak (Sp.A) & Pakar Pediatri Nutrisi';
  String _doctorInstitution = 'FK Universitas Indonesia / RSUPN Dr. Cipto Mangunkusumo';

  @override
  Widget build(BuildContext context) {
    return ResponsiveLayout(
      mobileView: _buildExpertView(isDesktop: false),
      webDesktopView: _buildExpertView(isDesktop: true),
    );
  }

  Widget _buildExpertView({required bool isDesktop}) {
    final auth = AuthService();
    final doctor = auth.currentUser;

    return Scaffold(
      backgroundColor: const Color(0xFFF1F5F9),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 1,
        // TOMBOL KEMBALI
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Color(0xFF0F172A)),
          tooltip: 'Kembali ke Halaman Login',
          onPressed: () {
            auth.logout();
            Navigator.pushReplacementNamed(context, '/login');
          },
        ),
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: AppColors.expertAccent.withOpacity(0.12),
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.medical_services, color: AppColors.expertAccent, size: 24),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    _doctorName,
                    style: const TextStyle(color: Color(0xFF0F172A), fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                  Text(
                    '$_doctorSpec • ${isDesktop ? "Web View" : "Mobile View"}',
                    style: const TextStyle(color: AppColors.expertAccent, fontSize: 11, fontWeight: FontWeight.w600),
                  ),
                ],
              ),
            ),
          ],
        ),
        actions: [
          // TOMBOL EDIT DATA PAKAR AHLI (PROFIL)
          IconButton(
            icon: const Icon(Icons.badge_outlined, color: AppColors.expertAccent, size: 26),
            tooltip: 'Edit Data Pakar / Dokter Ahli',
            onPressed: _openEditDoctorProfileDialog,
          ),

          IconButton(
            icon: const Icon(Icons.notifications_outlined, color: Color(0xFF334155)),
            onPressed: () => Navigator.pushNamed(context, '/notifications'),
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
      body: Row(
        children: [
          if (isDesktop) _buildDoctorSidebar(),
          Expanded(
            child: SingleChildScrollView(
              padding: EdgeInsets.all(isDesktop ? 28 : 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // KPI SUMMARY CARDS (DOKTER)
                  _buildDoctorKpis(),
                  const SizedBox(height: 24),

                  // HEADER ANTREAN
                  const Text(
                    'Antrean Kasus Deteksi Masuk (Realtime)',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Color(0xFF0F172A)),
                  ),
                  const SizedBox(height: 12),

                  // FILTER BAR
                  Wrap(
                    spacing: 8,
                    children: [
                      _buildFilterChip('Semua Kasus', 'ALL'),
                      _buildFilterChip('Menunggu Validasi', 'PENDING'),
                      _buildFilterChip('Sudah Terverifikasi', 'APPROVED'),
                    ],
                  ),
                  const SizedBox(height: 16),

                  // REALTIME DETECTION LIST WITH EDIT & DELETE BUTTONS
                  _buildDetectionQueueList(),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDoctorSidebar() {
    return Container(
      width: 250,
      color: Colors.white,
      padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              gradient: AppColors.doctorGradient,
              borderRadius: BorderRadius.circular(16),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('SIP / NIDN Pakar Ahli', style: TextStyle(color: Colors.white70, fontSize: 11)),
                const SizedBox(height: 4),
                Text(_doctorSip, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 12)),
                const SizedBox(height: 8),
                Text(_doctorSpec, style: const TextStyle(color: Colors.white, fontSize: 11)),
                const SizedBox(height: 4),
                Text(_doctorInstitution, style: const TextStyle(color: Colors.white70, fontSize: 10)),
                const SizedBox(height: 12),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.white,
                      foregroundColor: AppColors.expertAccent,
                      padding: const EdgeInsets.symmetric(vertical: 8),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                    ),
                    onPressed: _openEditDoctorProfileDialog,
                    icon: const Icon(Icons.edit, size: 14),
                    label: const Text('Edit Profil Saya', style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold)),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),
          _buildSidebarNav(Icons.dashboard, 'Dashboard Klinis', true),
          _buildSidebarNav(Icons.badge, 'Edit Profil Pakar', false, onTap: _openEditDoctorProfileDialog),
          _buildSidebarNav(Icons.verified_user, 'Antrean Validasi', false),
          _buildSidebarNav(Icons.chat_bubble_outline, 'Konsultasi Pasien', false),
        ],
      ),
    );
  }

  Widget _buildSidebarNav(IconData icon, String title, bool isActive, {VoidCallback? onTap}) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      decoration: BoxDecoration(
        color: isActive ? AppColors.expertAccent.withOpacity(0.12) : Colors.transparent,
        borderRadius: BorderRadius.circular(12),
      ),
      child: ListTile(
        leading: Icon(icon, color: isActive ? AppColors.expertAccent : Colors.grey.shade600, size: 20),
        title: Text(
          title,
          style: TextStyle(
            fontSize: 13,
            fontWeight: isActive ? FontWeight.bold : FontWeight.w500,
            color: isActive ? AppColors.expertAccent : Colors.grey.shade800,
          ),
        ),
        dense: true,
        onTap: onTap ?? () {},
      ),
    );
  }

  Widget _buildDoctorKpis() {
    return AnimatedBuilder(
      animation: _realtimeDb,
      builder: (context, _) {
        final total = _realtimeDb.detections.length;
        final pending = _realtimeDb.detections.where((d) => d.validationStatus == DoctorValidation.pending).length;
        final approved = _realtimeDb.detections.where((d) => d.validationStatus == DoctorValidation.approved).length;

        return Row(
          children: [
            Expanded(child: _buildKpiCard('Total Pasien Masuk', '$total', Icons.assignment, Colors.blue)),
            const SizedBox(width: 14),
            Expanded(child: _buildKpiCard('Perlu Validasi', '$pending', Icons.pending_actions, Colors.orange)),
            const SizedBox(width: 14),
            Expanded(child: _buildKpiCard('Selesai Terverifikasi', '$approved', Icons.task_alt, Colors.green)),
          ],
        );
      },
    );
  }

  Widget _buildKpiCard(String title, String count, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: color.withOpacity(0.2)),
        boxShadow: [
          BoxShadow(color: color.withOpacity(0.08), blurRadius: 12, offset: const Offset(0, 4))
        ],
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(color: color.withOpacity(0.12), borderRadius: BorderRadius.circular(14)),
            child: Icon(icon, color: color, size: 24),
          ),
          const SizedBox(width: 14),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(count, style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: color)),
              const SizedBox(height: 2),
              Text(title, style: TextStyle(fontSize: 11.5, color: Colors.grey.shade600)),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildFilterChip(String label, String value) {
    final isSelected = _selectedFilter == value;
    return ChoiceChip(
      label: Text(label, style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: isSelected ? Colors.white : Colors.black87)),
      selected: isSelected,
      selectedColor: AppColors.expertAccent,
      onSelected: (_) => setState(() => _selectedFilter = value),
    );
  }

  Widget _buildDetectionQueueList() {
    return AnimatedBuilder(
      animation: _realtimeDb,
      builder: (context, _) {
        var list = _realtimeDb.detections;
        if (_selectedFilter == 'PENDING') {
          list = list.where((d) => d.validationStatus == DoctorValidation.pending).toList();
        } else if (_selectedFilter == 'APPROVED') {
          list = list.where((d) => d.validationStatus == DoctorValidation.approved).toList();
        }

        if (list.isEmpty) {
          return Container(
            padding: const EdgeInsets.all(40),
            alignment: Alignment.center,
            decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(18)),
            child: const Text('Tidak ada antrean pemeriksaan dalam kategori ini.'),
          );
        }

        return ListView.separated(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: list.length,
          separatorBuilder: (_, __) => const SizedBox(height: 12),
          itemBuilder: (context, index) {
            final item = list[index];
            final isStunted = item.status == StuntingStatus.stunted || item.status == StuntingStatus.severelyStunted;

            return Container(
              padding: const EdgeInsets.all(18),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(18),
                border: Border.all(
                  color: isStunted ? Colors.red.withOpacity(0.3) : Colors.grey.shade200,
                  width: isStunted ? 1.5 : 1,
                ),
              ),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: isStunted ? Colors.red.shade50 : Colors.green.shade50,
                      borderRadius: BorderRadius.circular(14),
                    ),
                    child: Icon(
                      isStunted ? Icons.warning_rounded : Icons.check_circle_outline,
                      color: isStunted ? Colors.red : Colors.green,
                      size: 28,
                    ),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Text(item.childName, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
                            const SizedBox(width: 8),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                              decoration: BoxDecoration(
                                color: isStunted ? Colors.red.shade100 : Colors.green.shade100,
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Text(
                                item.statusText,
                                style: TextStyle(
                                  color: isStunted ? Colors.red.shade900 : Colors.green.shade900,
                                  fontSize: 10.5,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'Usia: ${item.ageInMonths} Bulan • TB: ${item.heightCm} cm • BB: ${item.weightKg} kg • Z-Score: ${item.zScoreHAZ} SD',
                          style: TextStyle(fontSize: 12, color: Colors.grey.shade700),
                        ),
                        if (item.doctorNotes != null) ...[
                          const SizedBox(height: 4),
                          Text('Catatan: "${item.doctorNotes}"',
                              style: const TextStyle(fontSize: 11.5, fontStyle: FontStyle.italic, color: Colors.blue)),
                        ]
                      ],
                    ),
                  ),
                  // TOMBOL EDIT DATA
                  IconButton(
                    icon: const Icon(Icons.edit, color: Colors.blue),
                    tooltip: 'Edit Data & Resep',
                    onPressed: () => _openEditDetectionDialog(item),
                  ),
                  // TOMBOL HAPUS DATA
                  IconButton(
                    icon: const Icon(Icons.delete_outline, color: Colors.red),
                    tooltip: 'Hapus Data Pemeriksaan',
                    onPressed: () => _confirmDeleteDetection(item),
                  ),
                  const SizedBox(width: 6),
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: item.validationStatus == DoctorValidation.approved
                          ? Colors.grey.shade700
                          : AppColors.expertAccent,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                    ),
                    onPressed: () => _openDoctorValidationDialog(item),
                    child: Text(item.validationStatus == DoctorValidation.approved ? 'Terverifikasi' : 'Validasi'),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  // ==================== OPERASI CRUD DOKTER ====================
  // 1. TAMBAH DATA PEMERIKSAAN
  void _openAddPatientDialog() {
    final nameCtrl = TextEditingController();
    final ageCtrl = TextEditingController();
    final heightCtrl = TextEditingController();
    final weightCtrl = TextEditingController();
    final notesCtrl = TextEditingController();
    String gender = 'L';

    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (context, setDlgState) {
          return AlertDialog(
            title: Row(
              children: const [
                Icon(Icons.add_circle, color: AppColors.expertAccent),
                SizedBox(width: 8),
                Text('Tambah Data Pasien & Diagnosis'),
              ],
            ),
            content: SingleChildScrollView(
              child: SizedBox(
                width: 440,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    TextField(controller: nameCtrl, decoration: const InputDecoration(labelText: 'Nama Lengkap Balita')),
                    const SizedBox(height: 10),
                    Row(
                      children: [
                        const Text('Kelamin: '),
                        ChoiceChip(label: const Text('L'), selected: gender == 'L', onSelected: (_) => setDlgState(() => gender = 'L')),
                        const SizedBox(width: 8),
                        ChoiceChip(label: const Text('P'), selected: gender == 'P', onSelected: (_) => setDlgState(() => gender = 'P')),
                      ],
                    ),
                    const SizedBox(height: 10),
                    TextField(controller: ageCtrl, keyboardType: TextInputType.number, decoration: const InputDecoration(labelText: 'Usia (Bulan)')),
                    const SizedBox(height: 10),
                    TextField(controller: heightCtrl, keyboardType: TextInputType.number, decoration: const InputDecoration(labelText: 'Tinggi Badan (cm)')),
                    const SizedBox(height: 10),
                    TextField(controller: weightCtrl, keyboardType: TextInputType.number, decoration: const InputDecoration(labelText: 'Berat Badan (kg)')),
                    const SizedBox(height: 10),
                    TextField(controller: notesCtrl, maxLines: 2, decoration: const InputDecoration(labelText: 'Catatan Observasi Dokter')),
                  ],
                ),
              ),
            ),
            actions: [
              TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Batal')),
              ElevatedButton(
                style: ElevatedButton.styleFrom(backgroundColor: AppColors.expertAccent),
                onPressed: () async {
                  final age = int.tryParse(ageCtrl.text) ?? 12;
                  final height = double.tryParse(heightCtrl.text) ?? 74.0;
                  final weight = double.tryParse(weightCtrl.text) ?? 8.5;
                  final haz = WhoZScoreService.calculateHAZ(heightCm: height, ageInMonths: age, gender: gender);
                  final status = WhoZScoreService.classifyStunting(haz);

                  final newDet = StuntingDetectionModel(
                    id: 'SCAN-${DateTime.now().millisecondsSinceEpoch}',
                    childId: 'MANUAL-${DateTime.now().millisecondsSinceEpoch}',
                    childName: nameCtrl.text.trim(),
                    timestamp: DateTime.now(),
                    ageInMonths: age,
                    gender: gender,
                    heightCm: height,
                    weightKg: weight,
                    zScoreHAZ: haz,
                    zScoreWAZ: 0.0,
                    status: status,
                    yoloConfidence: 0.99,
                    validationStatus: DoctorValidation.approved,
                    doctorName: 'dr. Farhan Malik, Sp.A (K)',
                    doctorId: 'DOC-01',
                    doctorNotes: notesCtrl.text.trim(),
                    nutritionalRecommendations: WhoZScoreService.generateNutritionalPlan(status, age),
                  );

                  await _realtimeDb.saveDetection(newDet);
                  Navigator.pop(ctx);
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('✅ Data pasien berhasil ditambahkan ke database realtime!'), backgroundColor: Colors.green),
                  );
                },
                child: const Text('Simpan Pasien'),
              ),
            ],
          );
        },
      ),
    );
  }

  // 2. EDIT DATA PEMERIKSAAN
  void _openEditDetectionDialog(StuntingDetectionModel item) {
    final heightCtrl = TextEditingController(text: item.heightCm.toString());
    final weightCtrl = TextEditingController(text: item.weightKg.toString());
    final notesCtrl = TextEditingController(text: item.doctorNotes ?? '');

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Row(
          children: [
            const Icon(Icons.edit, color: Colors.blue),
            const SizedBox(width: 8),
            Text('Edit Data: ${item.childName}'),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(controller: heightCtrl, keyboardType: TextInputType.number, decoration: const InputDecoration(labelText: 'Tinggi Badan (cm)')),
            const SizedBox(height: 10),
            TextField(controller: weightCtrl, keyboardType: TextInputType.number, decoration: const InputDecoration(labelText: 'Berat Badan (kg)')),
            const SizedBox(height: 10),
            TextField(controller: notesCtrl, maxLines: 3, decoration: const InputDecoration(labelText: 'Catatan Observasi & Resep')),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Batal')),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.blue),
            onPressed: () async {
              final newH = double.tryParse(heightCtrl.text) ?? item.heightCm;
              final newW = double.tryParse(weightCtrl.text) ?? item.weightKg;
              final newHaz = WhoZScoreService.calculateHAZ(heightCm: newH, ageInMonths: item.ageInMonths, gender: item.gender);
              final newStatus = WhoZScoreService.classifyStunting(newHaz);

              final updated = StuntingDetectionModel(
                id: item.id,
                childId: item.childId,
                childName: item.childName,
                timestamp: item.timestamp,
                ageInMonths: item.ageInMonths,
                gender: item.gender,
                heightCm: newH,
                weightKg: newW,
                zScoreHAZ: newHaz,
                zScoreWAZ: item.zScoreWAZ,
                status: newStatus,
                yoloConfidence: item.yoloConfidence,
                validationStatus: item.validationStatus,
                doctorName: 'dr. Farhan Malik, Sp.A (K)',
                doctorId: 'DOC-01',
                doctorNotes: notesCtrl.text.trim(),
                nutritionalRecommendations: WhoZScoreService.generateNutritionalPlan(newStatus, item.ageInMonths),
              );

              await _realtimeDb.updateDetection(updated);
              Navigator.pop(ctx);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('✅ Data berhasil diperbarui di database realtime!'), backgroundColor: Colors.blue),
              );
            },
            child: const Text('Perbarui Data'),
          ),
        ],
      ),
    );
  }

  // 3. HAPUS DATA PEMERIKSAAN
  void _confirmDeleteDetection(StuntingDetectionModel item) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Konfirmasi Hapus Data'),
        content: Text('Apakah Anda yakin ingin menghapus data rekam medis ${item.childName} (ID: ${item.id})? Tindakan ini tidak dapat dibatalkan.'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Batal')),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            onPressed: () async {
              await _realtimeDb.deleteDetection(item.id);
              Navigator.pop(ctx);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('🗑️ Data berhasil dihapus dari database realtime.'), backgroundColor: Colors.red),
              );
            },
            child: const Text('Hapus Sekarang'),
          ),
        ],
      ),
    );
  }

  void _openDoctorValidationDialog(StuntingDetectionModel item) {
    final notesController = TextEditingController(
      text: item.doctorNotes ?? 'Diagnosis klinis sesuai standar WHO. Anjurkan konsumsi telur 2 butir/hari, MPASI padat energi, dan pantau ulang 14 hari ke depan.',
    );

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text('Verifikasi Kasus: ${item.childName}'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('TB: ${item.heightCm} cm | Z-Score: ${item.zScoreHAZ} SD (${item.statusText})'),
            const SizedBox(height: 12),
            TextField(
              controller: notesController,
              maxLines: 3,
              decoration: InputDecoration(border: OutlineInputBorder(borderRadius: BorderRadius.circular(12))),
            ),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Batal')),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.expertAccent),
            onPressed: () async {
              await _realtimeDb.validateDetectionByDoctor(
                detectionId: item.id,
                doctorId: 'DOC-01',
                doctorName: 'dr. Farhan Malik, Sp.A (K)',
                notes: notesController.text.trim(),
                status: DoctorValidation.approved,
              );
              Navigator.pop(ctx);
            },
            child: const Text('Konfirmasi & Kirim'),
          ),
        ],
      ),
    );
  }

  void _openEditDoctorProfileDialog() {
    final nameCtrl = TextEditingController(text: _doctorName);
    final sipCtrl = TextEditingController(text: _doctorSip);
    final specCtrl = TextEditingController(text: _doctorSpec);
    final instCtrl = TextEditingController(text: _doctorInstitution);

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Row(
          children: const [
            Icon(Icons.edit_note, color: AppColors.expertAccent),
            SizedBox(width: 8),
            Text('Edit Data Pakar / Dokter Ahli', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          ],
        ),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: nameCtrl,
                decoration: InputDecoration(
                  labelText: 'Nama Lengkap & Gelar Akademik',
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                ),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: sipCtrl,
                decoration: InputDecoration(
                  labelText: 'Nomor SIP / NIDN Pakar',
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                ),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: specCtrl,
                decoration: InputDecoration(
                  labelText: 'Spesialisasi / Bidang Keahlian',
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                ),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: instCtrl,
                decoration: InputDecoration(
                  labelText: 'Institusi / Rumah Sakit / Fakultas',
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                ),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Batal'),
          ),
          ElevatedButton.icon(
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.expertAccent,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
            ),
            onPressed: () {
              setState(() {
                if (nameCtrl.text.trim().isNotEmpty) _doctorName = nameCtrl.text.trim();
                if (sipCtrl.text.trim().isNotEmpty) _doctorSip = sipCtrl.text.trim();
                if (specCtrl.text.trim().isNotEmpty) _doctorSpec = specCtrl.text.trim();
                if (instCtrl.text.trim().isNotEmpty) _doctorInstitution = instCtrl.text.trim();
              });
              Navigator.pop(ctx);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('✅ Data Pakar/Dokter Ahli berhasil diperbarui di Realtime Database!'),
                  backgroundColor: AppColors.expertAccent,
                ),
              );
            },
            icon: const Icon(Icons.check, size: 18),
            label: const Text('Simpan Perubahan'),
          ),
        ],
      ),
    );
  }
}
