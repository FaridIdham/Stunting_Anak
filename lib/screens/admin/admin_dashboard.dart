import 'package:flutter/material.dart';
import '../../core/app_colors.dart';
import '../../models/child_model.dart';
import '../../models/notification_model.dart';
import '../../services/auth_service.dart';
import '../../services/realtime_database_service.dart';
import '../../widgets/responsive_layout.dart';

class AdminDashboard extends StatefulWidget {
  const AdminDashboard({super.key});

  @override
  State<AdminDashboard> createState() => _AdminDashboardState();
}

class _AdminDashboardState extends State<AdminDashboard> {
  final _realtimeDb = RealtimeDatabaseService();

  final List<Map<String, String>> _expertDoctors = [
    {
      'id': 'doc-01',
      'name': 'dr. Farhan Malik, Sp.A (K)',
      'titleRole': 'Pakar Ahli Pediatri & Spesialis Anak Konsultan',
      'phone': '081198765432',
      'email': 'dr.farhan@rumahsakit.id',
      'sipNumber': 'SIP.440/129/DINKES/2024',
      'nidn': '0012058501',
      'institution': 'Fakultas Kedokteran UI / RS Hermina',
      'specialization': 'Nutrisi & Penyakit Metabolik Anak',
      'status': 'Aktif',
    },
    {
      'id': 'doc-02',
      'name': 'Dr. dr. Anisa Putri, M.Kes, Sp.A',
      'titleRole': 'Pakar Ahli Tumbuh Kembang & Spesialis Anak',
      'phone': '081299887766',
      'email': 'anisa.putri@fk-univ.ac.id',
      'sipNumber': 'SIP.440/215/DINKES/2023',
      'nidn': '0028098203',
      'institution': 'Fakultas Kedokteran / RSUP Nasional',
      'specialization': 'Tumbuh Kembang & Deteksi Dini Stunting',
      'status': 'Aktif',
    },
  ];

  @override
  Widget build(BuildContext context) {
    return ResponsiveLayout(
      mobileView: _buildAdminView(isDesktop: false),
      webDesktopView: _buildAdminView(isDesktop: true),
    );
  }

  Widget _buildAdminView({required bool isDesktop}) {
    final auth = AuthService();
    final admin = auth.currentUser;

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
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
                color: AppColors.adminAccent.withOpacity(0.12),
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.admin_panel_settings, color: AppColors.adminAccent, size: 24),
            ),
            const SizedBox(width: 12),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  admin?.name ?? 'Admin Dinas Kesehatan',
                  style: const TextStyle(color: Color(0xFF0F172A), fontSize: 16, fontWeight: FontWeight.bold),
                ),
                Text(
                  'Portal Manajemen & Pengawasan Wilayah (${isDesktop ? "Web View" : "Mobile View"})',
                  style: const TextStyle(color: AppColors.adminAccent, fontSize: 11, fontWeight: FontWeight.w600),
                ),
              ],
            ),
          ],
        ),
        actions: [

          IconButton(
            icon: const Icon(Icons.broadcast_on_personal, color: AppColors.adminAccent),
            tooltip: 'Broadcast Notifikasi',
            onPressed: _openBroadcastNotificationDialog,
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
          if (isDesktop) _buildAdminSidebar(),
          Expanded(
            child: SingleChildScrollView(
              padding: EdgeInsets.all(isDesktop ? 32 : 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // BANNER BROADCAST CEPAT
                  _buildBroadcastBanner(),
                  const SizedBox(height: 24),

                  // KPI ANALYTICS GRID
                  _buildRealtimeKpiGrid(isDesktop),
                  const SizedBox(height: 28),

                  // HEADER TABEL BALITA
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: const [
                          Text(
                            'Daftar Balita & Data Posyandu Terintegrasi',
                            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Color(0xFF0F172A)),
                          ),
                          Text(
                            'Kelola data anak secara realtime: Edit dan Hapus data',
                            style: TextStyle(fontSize: 12, color: Color(0xFF64748B)),
                          ),
                        ],
                      ),
                    ],
                  ),
                  const SizedBox(height: 14),
                  _buildRegisteredChildrenTable(),
                  const SizedBox(height: 28),
                  _buildExpertDoctorsManagementSection(),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAdminSidebar() {
    return Container(
      width: 260,
      color: Colors.white,
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              gradient: AppColors.adminGradient,
              borderRadius: BorderRadius.circular(16),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: const [
                Text('Sistem Monitoring', style: TextStyle(color: Colors.white70, fontSize: 11)),
                SizedBox(height: 4),
                Text('Satgas Penurunan Stunting', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 14)),
                SizedBox(height: 6),
                Text('Versi: 2.4.0 (YOLOv11 Live)', style: TextStyle(color: Colors.white70, fontSize: 10)),
              ],
            ),
          ),
          const SizedBox(height: 24),
          _buildAdminNavItem(Icons.analytics, 'Dashboard Statistik', true),
          _buildAdminNavItem(Icons.people_alt, 'Manajemen Balita', false),
          _buildAdminNavItem(Icons.medical_services, 'Akreditasi Dokter', false),
          _buildAdminNavItem(Icons.notifications_active, 'Broadcast Notifikasi', false),
          _buildAdminNavItem(Icons.map, 'Peta Sebaran Wilayah', false),
          _buildAdminNavItem(Icons.settings, 'Konfigurasi Sistem', false),
        ],
      ),
    );
  }

  Widget _buildAdminNavItem(IconData icon, String title, bool isActive) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      decoration: BoxDecoration(
        color: isActive ? AppColors.adminAccent.withOpacity(0.12) : Colors.transparent,
        borderRadius: BorderRadius.circular(12),
      ),
      child: ListTile(
        leading: Icon(icon, color: isActive ? AppColors.adminAccent : Colors.grey.shade600, size: 20),
        title: Text(
          title,
          style: TextStyle(
            fontSize: 13,
            fontWeight: isActive ? FontWeight.bold : FontWeight.w500,
            color: isActive ? AppColors.adminAccent : Colors.grey.shade800,
          ),
        ),
        dense: true,
        onTap: () {},
      ),
    );
  }

  Widget _buildBroadcastBanner() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: AppColors.notificationGradient,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFFF43F5E).withOpacity(0.3),
            blurRadius: 16,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Row(
        children: [
          const Icon(Icons.campaign, color: Colors.white, size: 40),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: const [
                Text(
                  'Fitur Notifikasi Realtime Massal',
                  style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold),
                ),
                SizedBox(height: 4),
                Text(
                  'Kirimkan pengingat posyandu, peringatan dini stunting, dan panduan gizi langsung ke smartphone orang tua.',
                  style: TextStyle(color: Colors.white70, fontSize: 12),
                ),
              ],
            ),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.white,
              foregroundColor: const Color(0xFFF43F5E),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            ),
            onPressed: _openBroadcastNotificationDialog,
            child: const Text('Kirim Pengumuman', style: TextStyle(fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }

  Widget _buildRealtimeKpiGrid(bool isDesktop) {
    return AnimatedBuilder(
      animation: _realtimeDb,
      builder: (context, _) {
        final stats = _realtimeDb.getAdminStatistics();

        final items = [
          {'title': 'Total Balita Terdata', 'value': '${stats['totalChildren']}', 'icon': Icons.child_care, 'color': AppColors.parentAccent},
          {'title': 'Total Scan YOLO', 'value': '${stats['totalScans']}', 'icon': Icons.qr_code_scanner, 'color': AppColors.featureYoloScan},
          {'title': 'Prevalensi Stunting', 'value': '${stats['stuntingRate']}%', 'icon': Icons.pie_chart, 'color': Colors.redAccent},
          {'title': 'Perlu Tindakan Dokter', 'value': '${stats['pendingValidations']}', 'icon': Icons.warning, 'color': Colors.amber.shade800},
        ];

        return GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: isDesktop ? 4 : 2,
            crossAxisSpacing: 14,
            mainAxisSpacing: 14,
            childAspectRatio: isDesktop ? 1.6 : 1.3,
          ),
          itemCount: items.length,
          itemBuilder: (context, index) {
            final it = items[index];
            final color = it['color'] as Color;
            return Container(
              padding: const EdgeInsets.all(18),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(18),
                border: Border.all(color: color.withOpacity(0.25)),
                boxShadow: [
                  BoxShadow(
                    color: color.withOpacity(0.08),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(it['icon'] as IconData, color: color, size: 28),
                  const SizedBox(height: 10),
                  Text(it['value'] as String, style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: color)),
                  const SizedBox(height: 2),
                  Text(it['title'] as String, style: const TextStyle(fontSize: 12, color: Color(0xFF64748B))),
                ],
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildRegisteredChildrenTable() {
    return AnimatedBuilder(
      animation: _realtimeDb,
      builder: (context, _) {
        final children = _realtimeDb.children;
        if (children.isEmpty) {
          return Container(
            padding: const EdgeInsets.all(32),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(18),
              border: Border.all(color: Colors.grey.shade200),
            ),
            child: Center(
              child: Column(
                children: [
                  Icon(Icons.child_care, size: 48, color: Colors.grey.shade400),
                  const SizedBox(height: 12),
                  const Text('Belum ada data balita di database realtime.', style: TextStyle(color: Color(0xFF64748B), fontWeight: FontWeight.w600)),
                ],
              ),
            ),
          );
        }

        return Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(18),
            border: Border.all(color: Colors.grey.shade200),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.03),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: ListView.separated(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: children.length,
            separatorBuilder: (_, __) => const Divider(height: 1),
            itemBuilder: (context, index) {
              final c = children[index];
              return Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                child: Row(
                  children: [
                    CircleAvatar(
                      radius: 22,
                      backgroundColor: c.gender == 'L' ? Colors.blue.shade100 : Colors.pink.shade100,
                      child: Text(c.gender == 'L' ? '👦' : '👧', style: const TextStyle(fontSize: 20)),
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Text(c.childName, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15, color: Color(0xFF0F172A))),
                              const SizedBox(width: 8),
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                                decoration: BoxDecoration(
                                  color: (c.gender == 'L' ? Colors.blue : Colors.pink).withOpacity(0.12),
                                  borderRadius: BorderRadius.circular(6),
                                ),
                                child: Text(
                                  c.gender == 'L' ? 'Laki-laki' : 'Perempuan',
                                  style: TextStyle(
                                    fontSize: 10,
                                    fontWeight: FontWeight.bold,
                                    color: c.gender == 'L' ? Colors.blue.shade800 : Colors.pink.shade800,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 4),
                          Text(
                            'NIK: ${c.nik} • Usia: ${c.ageFormatted} (${c.ageInMonths} Bulan) • Posyandu: ${c.posyanduName}',
                            style: const TextStyle(fontSize: 12, color: Color(0xFF64748B)),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            'Orang Tua: ${c.parentName} • Lahir: ${c.birthWeightKg}kg / ${c.birthHeightCm}cm • Alamat: ${c.address}',
                            style: const TextStyle(fontSize: 11, color: Color(0xFF94A3B8)),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 8),
                    // TOMBOL EDIT DATA
                    ElevatedButton.icon(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.amber.shade50,
                        foregroundColor: Colors.amber.shade900,
                        elevation: 0,
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                          side: BorderSide(color: Colors.amber.shade300),
                        ),
                      ),
                      icon: const Icon(Icons.edit, size: 16),
                      label: const Text('Edit', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
                      onPressed: () => _openEditChildDialog(c),
                    ),
                    const SizedBox(width: 8),
                    // TOMBOL HAPUS DATA
                    ElevatedButton.icon(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.red.shade50,
                        foregroundColor: Colors.red.shade700,
                        elevation: 0,
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                          side: BorderSide(color: Colors.red.shade200),
                        ),
                      ),
                      icon: const Icon(Icons.delete_outline, size: 16),
                      label: const Text('Hapus', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
                      onPressed: () => _deleteChildRecord(c),
                    ),
                  ],
                ),
              );
            },
          ),
        );
      },
    );
  }

  // DIALOG TAMBAH DATA BALITA KE REALTIME DATABASE
  void _openAddChildDialog() {
    final nameCtrl = TextEditingController();
    final nikCtrl = TextEditingController();
    final ageCtrl = TextEditingController();
    final parentCtrl = TextEditingController();
    final phoneCtrl = TextEditingController();
    final posyanduCtrl = TextEditingController();
    final weightCtrl = TextEditingController();
    final lengthCtrl = TextEditingController();
    String gender = 'L';

    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          title: Row(
            children: const [
              Icon(Icons.person_add_alt_1, color: AppColors.adminAccent),
              SizedBox(width: 10),
              Text('Tambah Data Balita Baru', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            ],
          ),
          content: SingleChildScrollView(
            child: SizedBox(
              width: 480,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextField(
                    controller: nameCtrl,
                    decoration: const InputDecoration(labelText: 'Nama Lengkap Balita *', prefixIcon: Icon(Icons.badge)),
                  ),
                  const SizedBox(height: 10),
                  TextField(
                    controller: nikCtrl,
                    keyboardType: TextInputType.number,
                    decoration: const InputDecoration(labelText: 'Nomor Induk Kependudukan (NIK) *', prefixIcon: Icon(Icons.pin)),
                  ),
                  const SizedBox(height: 10),
                  Row(
                    children: [
                      Expanded(
                        child: DropdownButtonFormField<String>(
                          value: gender,
                          decoration: const InputDecoration(labelText: 'Jenis Kelamin'),
                          items: const [
                            DropdownMenuItem(value: 'L', child: Text('👦 Laki-laki')),
                            DropdownMenuItem(value: 'P', child: Text('👧 Perempuan')),
                          ],
                          onChanged: (v) => setDialogState(() => gender = v!),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: TextField(
                          controller: ageCtrl,
                          keyboardType: TextInputType.number,
                          decoration: const InputDecoration(labelText: 'Usia (Bulan) *', prefixIcon: Icon(Icons.cake)),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  TextField(
                    controller: parentCtrl,
                    decoration: const InputDecoration(labelText: 'Nama Orang Tua / Wali *', prefixIcon: Icon(Icons.family_restroom)),
                  ),
                  const SizedBox(height: 10),
                  TextField(
                    controller: phoneCtrl,
                    keyboardType: TextInputType.phone,
                    decoration: const InputDecoration(labelText: 'No. WhatsApp / HP Orang Tua *', prefixIcon: Icon(Icons.phone)),
                  ),
                  const SizedBox(height: 10),
                  TextField(
                    controller: posyanduCtrl,
                    decoration: const InputDecoration(labelText: 'Posyandu Terdaftar', prefixIcon: Icon(Icons.local_hospital)),
                  ),
                  const SizedBox(height: 10),
                  Row(
                    children: [
                      Expanded(
                        child: TextField(
                          controller: weightCtrl,
                          keyboardType: const TextInputType.numberWithOptions(decimal: true),
                          decoration: const InputDecoration(labelText: 'BB Lahir (kg)'),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: TextField(
                          controller: lengthCtrl,
                          keyboardType: const TextInputType.numberWithOptions(decimal: true),
                          decoration: const InputDecoration(labelText: 'PB Lahir (cm)'),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Batal')),
            ElevatedButton(
              style: ElevatedButton.styleFrom(backgroundColor: AppColors.adminAccent, foregroundColor: Colors.white),
              onPressed: () async {
                if (nameCtrl.text.trim().isEmpty || parentCtrl.text.trim().isEmpty || phoneCtrl.text.trim().isEmpty) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Harap lengkapi semua kolom wajib (*)'), backgroundColor: Colors.red),
                  );
                  return;
                }
                final ageMonths = int.tryParse(ageCtrl.text.trim()) ?? 12;
                final newChild = ChildModel(
                  id: 'CHILD-${DateTime.now().millisecondsSinceEpoch}',
                  parentId: 'USER-${phoneCtrl.text.trim()}',
                  parentName: parentCtrl.text.trim(),
                  childName: nameCtrl.text.trim(),
                  nik: nikCtrl.text.trim(),
                  gender: gender,
                  dateOfBirth: DateTime.now().subtract(Duration(days: ageMonths * 30)),
                  birthWeightKg: double.tryParse(weightCtrl.text.trim()) ?? 3.1,
                  birthHeightCm: double.tryParse(lengthCtrl.text.trim()) ?? 49.0,
                  address: 'Kelurahan Sejahtera, RT 01/RW 02',
                  posyanduName: posyanduCtrl.text.trim(),
                  createdAt: DateTime.now(),
                );

                await _realtimeDb.registerChild(newChild);
                if (mounted) {
                  Navigator.pop(ctx);
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('✅ Data balita "${newChild.childName}" berhasil ditambahkan ke database realtime!'),
                      backgroundColor: Colors.green,
                    ),
                  );
                }
              },
              child: const Text('Simpan ke Realtime DB'),
            ),
          ],
        ),
      ),
    );
  }

  // DIALOG EDIT DATA BALITA KE REALTIME DATABASE
  void _openEditChildDialog(ChildModel child) {
    final nameCtrl = TextEditingController(text: child.childName);
    final nikCtrl = TextEditingController(text: child.nik);
    final ageCtrl = TextEditingController(text: '${child.ageInMonths}');
    final parentCtrl = TextEditingController(text: child.parentName);
    final phoneCtrl = TextEditingController(text: child.parentId.replaceAll('USER-', ''));
    final posyanduCtrl = TextEditingController(text: child.posyanduName);
    String gender = child.gender;

    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          title: Row(
            children: const [
              Icon(Icons.edit, color: Colors.amber),
              SizedBox(width: 10),
              Text('Edit Data Balita Realtime', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            ],
          ),
          content: SingleChildScrollView(
            child: SizedBox(
              width: 480,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextField(
                    controller: nameCtrl,
                    decoration: const InputDecoration(labelText: 'Nama Lengkap Balita', prefixIcon: Icon(Icons.badge)),
                  ),
                  const SizedBox(height: 10),
                  TextField(
                    controller: nikCtrl,
                    keyboardType: TextInputType.number,
                    decoration: const InputDecoration(labelText: 'NIK', prefixIcon: Icon(Icons.pin)),
                  ),
                  const SizedBox(height: 10),
                  Row(
                    children: [
                      Expanded(
                        child: DropdownButtonFormField<String>(
                          value: gender,
                          decoration: const InputDecoration(labelText: 'Jenis Kelamin'),
                          items: const [
                            DropdownMenuItem(value: 'L', child: Text('👦 Laki-laki')),
                            DropdownMenuItem(value: 'P', child: Text('👧 Perempuan')),
                          ],
                          onChanged: (v) => setDialogState(() => gender = v!),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: TextField(
                          controller: ageCtrl,
                          keyboardType: TextInputType.number,
                          decoration: const InputDecoration(labelText: 'Usia (Bulan)', prefixIcon: Icon(Icons.cake)),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  TextField(
                    controller: parentCtrl,
                    decoration: const InputDecoration(labelText: 'Nama Orang Tua / Wali', prefixIcon: Icon(Icons.family_restroom)),
                  ),
                  const SizedBox(height: 10),
                  TextField(
                    controller: phoneCtrl,
                    keyboardType: TextInputType.phone,
                    decoration: const InputDecoration(labelText: 'WhatsApp / HP', prefixIcon: Icon(Icons.phone)),
                  ),
                  const SizedBox(height: 10),
                  TextField(
                    controller: posyanduCtrl,
                    decoration: const InputDecoration(labelText: 'Nama Posyandu', prefixIcon: Icon(Icons.local_hospital)),
                  ),
                ],
              ),
            ),
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Batal')),
            ElevatedButton(
              style: ElevatedButton.styleFrom(backgroundColor: AppColors.adminAccent, foregroundColor: Colors.white),
              onPressed: () async {
                final ageMonths = int.tryParse(ageCtrl.text.trim()) ?? child.ageInMonths;
                final updated = ChildModel(
                  id: child.id,
                  parentId: child.parentId,
                  parentName: parentCtrl.text.trim(),
                  childName: nameCtrl.text.trim(),
                  nik: nikCtrl.text.trim(),
                  gender: gender,
                  dateOfBirth: DateTime.now().subtract(Duration(days: ageMonths * 30)),
                  birthWeightKg: child.birthWeightKg,
                  birthHeightCm: child.birthHeightCm,
                  address: child.address,
                  posyanduName: posyanduCtrl.text.trim(),
                  createdAt: child.createdAt,
                );

                await _realtimeDb.updateChild(updated);
                if (mounted) {
                  Navigator.pop(ctx);
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('✅ Data balita "${updated.childName}" berhasil diperbarui secara realtime!'),
                      backgroundColor: Colors.green,
                    ),
                  );
                }
              },
              child: const Text('Perbarui Data Realtime'),
            ),
          ],
        ),
      ),
    );
  }

  // DIALOG HAPUS DATA BALITA DARI REALTIME DATABASE
  void _deleteChildRecord(ChildModel child) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Row(
          children: const [
            Icon(Icons.warning_amber_rounded, color: Colors.redAccent, size: 28),
            SizedBox(width: 10),
            Text('Konfirmasi Hapus Data', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Apakah Anda yakin ingin menghapus data balita berikut dari database realtime?'),
            const SizedBox(height: 10),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.red.shade50,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.red.shade200),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Nama Balita: ${child.childName}', style: const TextStyle(fontWeight: FontWeight.bold)),
                  Text('NIK: ${child.nik} • Posyandu: ${child.posyanduName}'),
                  Text('Orang Tua: ${child.parentName} • Alamat: ${child.address}'),
                ],
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              'Perhatian: Semua riwayat deteksi stunting balita ini juga akan dihapus secara permanen.',
              style: TextStyle(fontSize: 11, color: Colors.redAccent, fontStyle: FontStyle.italic),
            ),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Batal')),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.redAccent, foregroundColor: Colors.white),
            onPressed: () async {
              await _realtimeDb.deleteChild(child.id);
              if (mounted) {
                Navigator.pop(ctx);
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('🗑️ Data balita "${child.childName}" berhasil dihapus dari database realtime.'),
                    backgroundColor: Colors.red.shade700,
                  ),
                );
              }
            },
            child: const Text('Ya, Hapus Data'),
          ),
        ],
      ),
    );
  }

  void _openBroadcastNotificationDialog() {
    final titleCtrl = TextEditingController();
    final messageCtrl = TextEditingController();

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Kirim Notifikasi Realtime ke Pengguna'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: titleCtrl,
              decoration: const InputDecoration(labelText: 'Judul Notifikasi'),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: messageCtrl,
              maxLines: 3,
              decoration: const InputDecoration(labelText: 'Pesan Broadcast'),
            ),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Batal')),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.adminAccent),
            onPressed: () async {
              await _realtimeDb.sendNotification(
                NotificationModel(
                  id: 'BROADCAST-${DateTime.now().millisecondsSinceEpoch}',
                  recipientId: 'ALL_PARENTS',
                  title: titleCtrl.text.trim(),
                  message: messageCtrl.text.trim(),
                  type: NotificationType.posyanduSchedule,
                  timestamp: DateTime.now(),
                ),
              );
              Navigator.pop(ctx);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Notifikasi berhasil disiarkan ke semua pengguna secara realtime!'),
                  backgroundColor: Colors.green,
                ),
              );
            },
            child: const Text('Siarkan Sekarang'),
          ),
        ],
      ),
    );
  }

  // ==================== MANAJEMEN PAKAR AHLI & DOKTER SPESIALIS ====================
  Widget _buildExpertDoctorsManagementSection() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0xFFE2E8F0)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.02),
            blurRadius: 10,
            offset: const Offset(0, 4),
          )
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: const [
                  Text(
                    'Manajemen Data Pakar Ahli & Dokter Spesialis',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Color(0xFF0F172A)),
                  ),
                  Text(
                    'Kelola data pakar medis stunting: Tambah Pakar Baru, Edit Profil, dan Hapus Tenaga Pakar',
                    style: TextStyle(fontSize: 12, color: Color(0xFF64748B)),
                  ),
                ],
              ),
              ElevatedButton.icon(
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primaryTeal,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
                icon: const Icon(Icons.person_add_alt_1, size: 18),
                label: const Text('Tambah Data Pakar / Dokter Ahli', style: TextStyle(fontWeight: FontWeight.bold)),
                onPressed: _openAddDoctorDialog,
              ),
            ],
          ),
          const SizedBox(height: 16),
          if (_expertDoctors.isEmpty)
            Container(
              padding: const EdgeInsets.all(32),
              alignment: Alignment.center,
              child: Column(
                children: [
                  const Text('👨‍⚕️', style: TextStyle(fontSize: 32)),
                  const SizedBox(height: 8),
                  const Text('Belum ada data Pakar Ahli terdaftar', style: TextStyle(fontWeight: FontWeight.bold)),
                  const SizedBox(height: 12),
                  ElevatedButton(
                    onPressed: _openAddDoctorDialog,
                    child: const Text('Tambah Data Pakar Sekarang'),
                  ),
                ],
              ),
            )
          else
            ListView.separated(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: _expertDoctors.length,
              separatorBuilder: (_, __) => const Divider(height: 16),
              itemBuilder: (context, index) {
                final doc = _expertDoctors[index];
                return Row(
                  children: [
                    CircleAvatar(
                      radius: 22,
                      backgroundColor: const Color(0xFFE0F2FE),
                      child: const Text('👨‍⚕️', style: TextStyle(fontSize: 20)),
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Text(doc['name'] ?? '', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                              const SizedBox(width: 8),
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                decoration: BoxDecoration(
                                  color: const Color(0xFFDCFCE7),
                                  borderRadius: BorderRadius.circular(6),
                                ),
                                child: Text(
                                  doc['status'] ?? 'Aktif',
                                  style: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: Color(0xFF166534)),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 2),
                          Text(
                            '${doc['titleRole']} • SIP: ${doc['sipNumber']} • NIDN: ${doc['nidn']}',
                            style: const TextStyle(fontSize: 11.5, color: Color(0xFF64748B)),
                          ),
                          Text(
                            '${doc['institution']} • WA: ${doc['phone']}',
                            style: const TextStyle(fontSize: 11, color: Color(0xFF0F766E), fontWeight: FontWeight.w500),
                          ),
                        ],
                      ),
                    ),
                    // TOMBOL EDIT DATA PAKAR AHLI
                    ElevatedButton.icon(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.amber.shade50,
                        foregroundColor: Colors.amber.shade900,
                        elevation: 0,
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                          side: BorderSide(color: Colors.amber.shade200),
                        ),
                      ),
                      icon: const Icon(Icons.edit, size: 16),
                      label: const Text('Edit', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
                      onPressed: () => _openEditDoctorDialog(doc),
                    ),
                    const SizedBox(width: 8),
                    // TOMBOL HAPUS DATA PAKAR AHLI
                    ElevatedButton.icon(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.red.shade50,
                        foregroundColor: Colors.red.shade700,
                        elevation: 0,
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                          side: BorderSide(color: Colors.red.shade200),
                        ),
                      ),
                      icon: const Icon(Icons.delete_outline, size: 16),
                      label: const Text('Hapus', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
                      onPressed: () => _deleteDoctorRecord(doc),
                    ),
                  ],
                );
              },
            ),
        ],
      ),
    );
  }

  void _openAddDoctorDialog() {
    final nameCtrl = TextEditingController();
    final titleCtrl = TextEditingController();
    final nidnCtrl = TextEditingController();
    final sipCtrl = TextEditingController();
    final specCtrl = TextEditingController();
    final instCtrl = TextEditingController();
    final phoneCtrl = TextEditingController();

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text('Tambah Data Pakar Ahli / Dokter Spesialis', style: TextStyle(fontWeight: FontWeight.bold)),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(controller: nameCtrl, decoration: const InputDecoration(labelText: 'Nama Lengkap & Gelar *', hintText: 'dr. Nama Lengkap, Sp.A')),
              const SizedBox(height: 10),
              TextField(controller: titleCtrl, decoration: const InputDecoration(labelText: 'Jabatan / Peran Pakar *', hintText: 'Pakar Ahli Pediatri & Spesialis Anak')),
              const SizedBox(height: 10),
              TextField(controller: nidnCtrl, decoration: const InputDecoration(labelText: 'NIDN / NIP Pakar')),
              const SizedBox(height: 10),
              TextField(controller: sipCtrl, decoration: const InputDecoration(labelText: 'Nomor SIP Medis *', hintText: 'SIP.440/xxx/DINKES/2026')),
              const SizedBox(height: 10),
              TextField(controller: specCtrl, decoration: const InputDecoration(labelText: 'Bidang Spesialisasi *', hintText: 'Nutrisi & Tumbuh Kembang Anak')),
              const SizedBox(height: 10),
              TextField(controller: instCtrl, decoration: const InputDecoration(labelText: 'Institusi / Kampus / RS *', hintText: 'Fakultas Kedokteran / RS Daerah')),
              const SizedBox(height: 10),
              TextField(controller: phoneCtrl, decoration: const InputDecoration(labelText: 'No. WhatsApp Terdaftar *', hintText: '0812xxxxxxxx')),
            ],
          ),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Batal')),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.primaryTeal, foregroundColor: Colors.white),
            onPressed: () {
              if (nameCtrl.text.trim().isEmpty || phoneCtrl.text.trim().isEmpty) return;
              setState(() {
                _expertDoctors.add({
                  'id': 'doc-${DateTime.now().millisecondsSinceEpoch}',
                  'name': nameCtrl.text.trim(),
                  'titleRole': titleCtrl.text.trim().isEmpty ? 'Pakar Ahli Pediatri & Spesialis Anak' : titleCtrl.text.trim(),
                  'nidn': nidnCtrl.text.trim().isEmpty ? '-' : nidnCtrl.text.trim(),
                  'sipNumber': sipCtrl.text.trim(),
                  'specialization': specCtrl.text.trim().isEmpty ? 'Spesialis Anak' : specCtrl.text.trim(),
                  'institution': instCtrl.text.trim().isEmpty ? 'Institusi Kesehatan' : instCtrl.text.trim(),
                  'phone': phoneCtrl.text.trim(),
                  'email': '${phoneCtrl.text.trim()}@stuntingguard.id',
                  'status': 'Aktif',
                });
              });
              Navigator.pop(ctx);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('✅ Data Pakar Ahli "${nameCtrl.text.trim()}" berhasil ditambahkan!'), backgroundColor: Colors.green),
              );
            },
            child: const Text('Simpan'),
          ),
        ],
      ),
    );
  }

  void _openEditDoctorDialog(Map<String, String> doc) {
    final nameCtrl = TextEditingController(text: doc['name']);
    final titleCtrl = TextEditingController(text: doc['titleRole']);
    final nidnCtrl = TextEditingController(text: doc['nidn']);
    final sipCtrl = TextEditingController(text: doc['sipNumber']);
    final specCtrl = TextEditingController(text: doc['specialization']);
    final instCtrl = TextEditingController(text: doc['institution']);
    final phoneCtrl = TextEditingController(text: doc['phone']);

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text('Edit Data Pakar Ahli / Dokter', style: TextStyle(fontWeight: FontWeight.bold)),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(controller: nameCtrl, decoration: const InputDecoration(labelText: 'Nama Lengkap & Gelar *')),
              const SizedBox(height: 10),
              TextField(controller: titleCtrl, decoration: const InputDecoration(labelText: 'Jabatan / Peran Pakar *')),
              const SizedBox(height: 10),
              TextField(controller: nidnCtrl, decoration: const InputDecoration(labelText: 'NIDN / NIP Pakar')),
              const SizedBox(height: 10),
              TextField(controller: sipCtrl, decoration: const InputDecoration(labelText: 'Nomor SIP Medis *')),
              const SizedBox(height: 10),
              TextField(controller: specCtrl, decoration: const InputDecoration(labelText: 'Bidang Spesialisasi *')),
              const SizedBox(height: 10),
              TextField(controller: instCtrl, decoration: const InputDecoration(labelText: 'Institusi / Kampus / RS *')),
              const SizedBox(height: 10),
              TextField(controller: phoneCtrl, decoration: const InputDecoration(labelText: 'No. WhatsApp Terdaftar *')),
            ],
          ),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Batal')),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.amber.shade800, foregroundColor: Colors.white),
            onPressed: () {
              setState(() {
                doc['name'] = nameCtrl.text.trim();
                doc['titleRole'] = titleCtrl.text.trim();
                doc['nidn'] = nidnCtrl.text.trim();
                doc['sipNumber'] = sipCtrl.text.trim();
                doc['specialization'] = specCtrl.text.trim();
                doc['institution'] = instCtrl.text.trim();
                doc['phone'] = phoneCtrl.text.trim();
              });
              Navigator.pop(ctx);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('✅ Data Pakar Ahli "${nameCtrl.text.trim()}" berhasil diperbarui!'), backgroundColor: Colors.amber.shade900),
              );
            },
            child: const Text('Perbarui'),
          ),
        ],
      ),
    );
  }

  void _deleteDoctorRecord(Map<String, String> doc) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Row(
          children: const [
            Icon(Icons.warning_amber_rounded, color: Colors.redAccent, size: 28),
            SizedBox(width: 10),
            Text('Konfirmasi Hapus Ahli', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Apakah Anda yakin ingin menghapus data Pakar/Dokter Ahli "${doc['name']}" dari sistem?'),
            const SizedBox(height: 10),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.red.shade50,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.red.shade200),
              ),
              child: Text(
                'Peran: ${doc['titleRole']}\nSIP: ${doc['sipNumber']} • NIDN: ${doc['nidn']}\nWhatsApp: ${doc['phone']}',
                style: const TextStyle(fontSize: 12),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Batal')),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.redAccent, foregroundColor: Colors.white),
            onPressed: () {
              setState(() {
                _expertDoctors.removeWhere((d) => d['id'] == doc['id']);
              });
              Navigator.pop(ctx);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('🗑️ Data Pakar Ahli "${doc['name']}" berhasil dihapus.'), backgroundColor: Colors.red.shade700),
              );
            },
            child: const Text('Ya, Hapus'),
          ),
        ],
      ),
    );
  }
}
