import 'package:flutter/material.dart';
import '../../core/app_colors.dart';

class DoctorConsultScreen extends StatefulWidget {
  const DoctorConsultScreen({Key? key}) : super(key: key);

  @override
  State<DoctorConsultScreen> createState() => _DoctorConsultScreenState();
}

class _DoctorConsultScreenState extends State<DoctorConsultScreen> {
  final TextEditingController _messageController = TextEditingController();
  final ScrollController _scrollController = ScrollController();

  final List<Map<String, String>> _messages = [
    {
      'sender': 'doctor',
      'name': 'dr. Farhan Malik, Sp.A (K)',
      'text': 'Halo Ayah/Bunda! Saya telah meninjau hasil pemantauan tinggi badan balita Anda di StuntingGuard AI. Ada yang ingin dikonsultasikan mengenai gizi atau kenaikan tinggi badannya?',
      'time': '14:30',
    },
    {
      'sender': 'parent',
      'name': 'Bunda Rayyan',
      'text': 'Selamat siang dokter, hasil scan kemarin anak saya tinggi 76.5 cm (Z-score -2.12 SD). Apakah perlu suplemen zat besi tambahan dok?',
      'time': '14:32',
    },
    {
      'sender': 'doctor',
      'name': 'dr. Farhan Malik, Sp.A (K)',
      'text': 'Baik Bunda, Z-Score -2.12 SD memerlukan perhatian agar tidak berlanjut ke stunting berat. Kuncinya perbanyak protein hewani 2 butir telur/hari, hati ayam kukus, dan suplemen zat besi tetes sesuai anjuran posyandu.',
      'time': '14:35',
    },
  ];

  void _sendMessage() {
    final text = _messageController.text.trim();
    if (text.isEmpty) return;

    final now = DateTime.now();
    final timeStr = '${now.hour.toString().padLeft(2, '0')}:${now.minute.toString().padLeft(2, '0')}';

    setState(() {
      _messages.add({
        'sender': 'parent',
        'name': 'Anda',
        'text': text,
        'time': timeStr,
      });
      _messageController.clear();
    });

    _scrollToBottom();

    // Auto-reply dari dokter spesialis
    Future.delayed(const Duration(milliseconds: 900), () {
      if (!mounted) return;
      setState(() {
        _messages.add({
          'sender': 'doctor',
          'name': 'dr. Farhan Malik, Sp.A (K)',
          'text': 'Terima kasih pertanyaannya Bunda. Terkait asupan gizi anak Anda, pastikan porsi protein hewani selalu ada di setiap sesi makan (sarapan, makan siang, makan malam) dan batasi camilan manis 2 jam sebelum makan utama.',
          'time': timeStr,
        });
      });
      _scrollToBottom();
    });
  }

  void _scrollToBottom() {
    Future.delayed(const Duration(milliseconds: 100), () {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

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
          'Konsultasi Dokter Spesialis Anak',
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
              color: const Color(0xFFE0F2FE),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: const Color(0xFFBAE6FD)),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: const [
                Text('🩺', style: TextStyle(fontSize: 14)),
                SizedBox(width: 4),
                Text(
                  'Telemedisin Realtime',
                  style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Color(0xFF0369A1)),
                ),
              ],
            ),
          )
        ],
      ),
      body: Column(
        children: [
          // PROFIL DOKTER DENGAN TOMBOL KEMBALI
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            color: Colors.white,
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    InkWell(
                      onTap: () => Navigator.pop(context),
                      borderRadius: BorderRadius.circular(8),
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                        decoration: BoxDecoration(
                          color: const Color(0xFFF1F5F9),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Row(
                          children: const [
                            Icon(Icons.arrow_back, size: 14, color: Color(0xFF0F766E)),
                            SizedBox(width: 4),
                            Text('Kembali', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Color(0xFF0F766E))),
                          ],
                        ),
                      ),
                    ),
                    Row(
                      children: [
                        Container(
                          width: 8,
                          height: 8,
                          decoration: const BoxDecoration(
                            color: Color(0xFF10B981),
                            shape: BoxShape.circle,
                          ),
                        ),
                        const SizedBox(width: 6),
                        const Text(
                          'Online Realtime',
                          style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Color(0xFF059669)),
                        ),
                      ],
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                Row(
                  children: [
                    CircleAvatar(
                      radius: 22,
                      backgroundColor: const Color(0xFFE0F2FE),
                      child: const Text('👨‍⚕️', style: TextStyle(fontSize: 22)),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: const [
                          Text(
                            'dr. Farhan Malik, Sp.A (K)',
                            style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Color(0xFF0F172A)),
                          ),
                          Text(
                            'Spesialis Anak Konsultan Nutrisi & Metabolik',
                            style: TextStyle(fontSize: 11, color: Color(0xFF64748B)),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const Divider(height: 1, thickness: 1, color: Color(0xFFE2E8F0)),

          // PESAN CHAT
          Expanded(
            child: ListView.builder(
              controller: _scrollController,
              padding: const EdgeInsets.all(16),
              itemCount: _messages.length,
              itemBuilder: (context, index) {
                final msg = _messages[index];
                final isDoc = msg['sender'] == 'doctor';

                return Container(
                  margin: const EdgeInsets.only(bottom: 14),
                  alignment: isDoc ? Alignment.centerLeft : Alignment.centerRight,
                  child: Container(
                    constraints: BoxConstraints(
                      maxWidth: MediaQuery.of(context).size.width * 0.78,
                    ),
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                    decoration: BoxDecoration(
                      color: isDoc ? Colors.white : const Color(0xFF0D9488),
                      borderRadius: BorderRadius.only(
                        topLeft: const Radius.circular(16),
                        topRight: const Radius.circular(16),
                        bottomLeft: Radius.circular(isDoc ? 4 : 16),
                        bottomRight: Radius.circular(isDoc ? 16 : 4),
                      ),
                      border: isDoc ? Border.all(color: const Color(0xFFE2E8F0)) : null,
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.03),
                          blurRadius: 4,
                          offset: const Offset(0, 2),
                        )
                      ],
                    ),
                    child: Column(
                      crossAxisAlignment: isDoc ? CrossAxisAlignment.start : CrossAxisAlignment.end,
                      children: [
                        Text(
                          msg['name'] ?? '',
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.bold,
                            color: isDoc ? const Color(0xFF0369A1) : Colors.white70,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          msg['text'] ?? '',
                          style: TextStyle(
                            fontSize: 13,
                            color: isDoc ? const Color(0xFF0F172A) : Colors.white,
                            height: 1.4,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          msg['time'] ?? '',
                          style: TextStyle(
                            fontSize: 10,
                            color: isDoc ? const Color(0xFF94A3B8) : Colors.white60,
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),

          // INPUT CHAT
          Container(
            padding: const EdgeInsets.all(12),
            decoration: const BoxDecoration(
              color: Colors.white,
              border: Border(top: BorderSide(color: Color(0xFFE2E8F0))),
            ),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _messageController,
                    decoration: InputDecoration(
                      hintText: 'Tulis pertanyaan untuk dr. Farhan Malik...',
                      hintStyle: const TextStyle(fontSize: 13, color: Color(0xFF94A3B8)),
                      filled: true,
                      fillColor: const Color(0xFFF8FAFC),
                      contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: const BorderSide(color: Color(0xFFCBD5E1)),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: const BorderSide(color: Color(0xFFCBD5E1)),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: const BorderSide(color: Color(0xFF0D9488)),
                      ),
                    ),
                    onSubmitted: (_) => _sendMessage(),
                  ),
                ),
                const SizedBox(width: 8),
                IconButton(
                  style: IconButton.styleFrom(
                    backgroundColor: const Color(0xFF0D9488),
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  icon: const Icon(Icons.send_rounded, size: 20),
                  onPressed: _sendMessage,
                  tooltip: 'Kirim Pertanyaan',
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
