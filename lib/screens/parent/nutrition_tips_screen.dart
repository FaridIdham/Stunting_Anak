import 'package:flutter/material.dart';
import '../../core/app_colors.dart';

class NutritionTipsScreen extends StatefulWidget {
  const NutritionTipsScreen({Key? key}) : super(key: key);

  @override
  State<NutritionTipsScreen> createState() => _NutritionTipsScreenState();
}

class _NutritionTipsScreenState extends State<NutritionTipsScreen> {
  double _childWeight = 9.8;
  int _childAgeMonths = 18;

  double get _targetProtein => _childWeight * 1.5;
  int get _eggCount => (_targetProtein / 6.5).round().clamp(1, 4);
  int get _minCalorie => (_childWeight * 85).round();
  int get _maxCalorie => (_childWeight * 100).round();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, color: Color(0xFF0F172A), size: 20),
          onPressed: () => Navigator.pop(context),
          tooltip: 'Kembali ke Dashboard',
        ),
        title: const Text(
          'Gizi & MPASI Anti-Stunting',
          style: TextStyle(
            color: Color(0xFF0F172A),
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: false,
        actions: [
          Container(
            margin: const EdgeInsets.only(right: 16),
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
            decoration: BoxDecoration(
              color: const Color(0xFFFEF3C7),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: const Color(0xFFFDE68A)),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: const [
                Text('🍳', style: TextStyle(fontSize: 14)),
                SizedBox(width: 4),
                Text(
                  'Protein Tinggi',
                  style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Color(0xFF92400E)),
                ),
              ],
            ),
          )
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // TOMBOL KEMBALI PROMINENT
            InkWell(
              onTap: () => Navigator.pop(context),
              borderRadius: BorderRadius.circular(10),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: const Color(0xFFE2E8F0)),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: const [
                    Icon(Icons.arrow_back, size: 16, color: Color(0xFF0F766E)),
                    SizedBox(width: 6),
                    Text(
                      'Kembali ke Dashboard Utama',
                      style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Color(0xFF0F766E)),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),

            // HERO BANNER EDUKASI
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Color(0xFFFFFBEB), Color(0xFFFEF3C7)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(18),
                border: Border.all(color: const Color(0xFFFDE68A)),
                boxShadow: [
                  BoxShadow(
                    color: Colors.amber.withOpacity(0.08),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  )
                ],
              ),
              child: Row(
                children: [
                  Container(
                    width: 56,
                    height: 56,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(14),
                    ),
                    alignment: Alignment.center,
                    child: const Text('🥚', style: TextStyle(fontSize: 32)),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: const [
                        Text(
                          'Prioritas Protein Hewani (Telur & Ikan)',
                          style: TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF78350F),
                          ),
                        ),
                        SizedBox(height: 4),
                        Text(
                          'Protein hewani mengandung asam amino esensial lengkap yang langsung merangsang lempeng pertumbuhan tulang (epiphyseal plate) balita.',
                          style: TextStyle(fontSize: 12, color: Color(0xFF92400E), height: 1.4),
                        ),
                      ],
                    ),
                  )
                ],
              ),
            ),
            const SizedBox(height: 20),

            // KALKULATOR INTERAKTIF PROTEIN & KALORI
            Container(
              padding: const EdgeInsets.all(18),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: const Color(0xFFE2E8F0)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: const [
                      Text('🧮', style: TextStyle(fontSize: 20)),
                      SizedBox(width: 8),
                      Text(
                        'Kalkulator Kebutuhan Protein Harian',
                        style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: Color(0xFF0F172A)),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  const Text(
                    'Geser berat badan anak untuk melihat target gram protein harian:',
                    style: TextStyle(fontSize: 12, color: Color(0xFF64748B)),
                  ),
                  const SizedBox(height: 12),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Berat Badan: ${_childWeight.toStringAsFixed(1)} kg',
                        style: const TextStyle(fontWeight: FontWeight.bold, color: Color(0xFF0F766E)),
                      ),
                      Text(
                        'Usia: $_childAgeMonths Bulan',
                        style: const TextStyle(fontWeight: FontWeight.w600, color: Color(0xFF64748B)),
                      ),
                    ],
                  ),
                  Slider(
                    value: _childWeight,
                    min: 5.0,
                    max: 20.0,
                    divisions: 30,
                    activeColor: const Color(0xFF0D9488),
                    onChanged: (val) {
                      setState(() {
                        _childWeight = val;
                      });
                    },
                  ),
                  const SizedBox(height: 10),
                  Row(
                    children: [
                      Expanded(
                        child: _buildMetricCard(
                          '${_targetProtein.toStringAsFixed(1)} g',
                          'Target Protein/Hari',
                          const Color(0xFF0D9488),
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: _buildMetricCard(
                          '$_eggCount Butir Telur',
                          'Atau 60g Ikan/Daging',
                          const Color(0xFFD97706),
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: _buildMetricCard(
                          '$_minCalorie - $_maxCalorie',
                          'kkal Energi Total',
                          const Color(0xFF2563EB),
                        ),
                      ),
                    ],
                  )
                ],
              ),
            ),
            const SizedBox(height: 22),

            // DAFTAR RESEP MPASI PADAT GIZI
            const Text(
              'Rekomendasi Menu Resep Padat Protein',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Color(0xFF0F172A)),
            ),
            const SizedBox(height: 12),

            _buildRecipeTile(
              emoji: '🥣',
              title: 'Bubur Hati Ayam Santan Gurih',
              tag: 'Kaya Zat Besi & Zinc',
              age: 'Usia 6 - 24 Bulan',
              calories: '145 kkal',
              protein: '8.2 g Protein',
              ingredients: 'Beras pulen, 35g hati ayam segar kukus, 20ml santan matang, wortel, 1 sdt minyak kelapa.',
              tip: 'Zat besi heme dari hati ayam mencegah anemia mikrositik penghambat tinggi badan anak.',
            ),
            const SizedBox(height: 12),

            _buildRecipeTile(
              emoji: '🐟',
              title: 'Tim Nasi Ikan Kembung & Telur',
              tag: 'Tinggi Omega-3 DHA',
              age: 'Usia 8 - 24 Bulan',
              calories: '175 kkal',
              protein: '9.5 g Protein',
              ingredients: 'Nasi lembek, 30g daging kembung tanpa duri, 1 butir telur puyuh, kaldu tulang sumsum.',
              tip: 'Ikan kembung lokal memiliki asam lemak Omega-3 dan kalsium lebih padat daripada ikan impor.',
            ),
            const SizedBox(height: 12),

            _buildRecipeTile(
              emoji: '🥑',
              title: 'Puding Alpukat Keju & Pisang',
              tag: 'Booster Kalori Sehat',
              age: 'Selingan Sore (Snack)',
              calories: '130 kkal',
              protein: '4.5 g Protein',
              ingredients: '1/2 alpukat mentega, 1 sdm keju parut halus, 1/2 pisang ambon, susu UHT/ASI.',
              tip: 'Snack berdensitas energi tinggi memastikan kebutuhan kalori balita selalu surplus untuk kejar tumbuh.',
            ),
            const SizedBox(height: 20),

            // TOMBOL KEMBALI BAWAH
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primaryTeal,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
                icon: const Icon(Icons.arrow_back),
                label: const Text('Kembali ke Dashboard Utama', style: TextStyle(fontWeight: FontWeight.bold)),
                onPressed: () => Navigator.pop(context),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMetricCard(String val, String label, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
      decoration: BoxDecoration(
        color: const Color(0xFFF8FAFC),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: const Color(0xFFCBD5E1)),
      ),
      child: Column(
        children: [
          Text(val, style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: color)),
          const SizedBox(height: 4),
          Text(
            label,
            textAlign: TextAlign.center,
            style: const TextStyle(fontSize: 10, color: Color(0xFF64748B)),
          ),
        ],
      ),
    );
  }

  Widget _buildRecipeTile({
    required String emoji,
    required String title,
    required String tag,
    required String age,
    required String calories,
    required String protein,
    required String ingredients,
    required String tip,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE2E8F0)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.02),
            blurRadius: 8,
            offset: const Offset(0, 2),
          )
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: const Color(0xFFF1F5F9),
                  borderRadius: BorderRadius.circular(10),
                ),
                alignment: Alignment.center,
                child: Text(emoji, style: const TextStyle(fontSize: 24)),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                    const SizedBox(height: 2),
                    Text(age, style: const TextStyle(fontSize: 11, color: Color(0xFF64748B))),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: const Color(0xFFFEF3C7),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  tag,
                  style: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: Color(0xFF92400E)),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(color: const Color(0xFFF1F5F9), borderRadius: BorderRadius.circular(6)),
                child: Text(calories, style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w600)),
              ),
              const SizedBox(width: 6),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(color: const Color(0xFFF1F5F9), borderRadius: BorderRadius.circular(6)),
                child: Text(protein, style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w600)),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            'Bahan: $ingredients',
            style: const TextStyle(fontSize: 12, color: Color(0xFF334155)),
          ),
          const SizedBox(height: 8),
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: const Color(0xFFECFDF5),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: const Color(0xFFA7F3D0)),
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('💡', style: TextStyle(fontSize: 12)),
                const SizedBox(width: 6),
                Expanded(
                  child: Text(
                    tip,
                    style: const TextStyle(fontSize: 11, color: Color(0xFF065F46), fontStyle: FontStyle.italic),
                  ),
                ),
              ],
            ),
          )
        ],
      ),
    );
  }
}
