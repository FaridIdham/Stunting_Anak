import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../core/app_colors.dart';
import '../../services/auth_service.dart';

class ChildRegistrationScreen extends StatefulWidget {
  const ChildRegistrationScreen({super.key});

  @override
  State<ChildRegistrationScreen> createState() => _ChildRegistrationScreenState();
}

class _ChildRegistrationScreenState extends State<ChildRegistrationScreen> {
  final _formKey = GlobalKey<FormState>();

  // Data Orang Tua
  final _parentNameController = TextEditingController();
  final _emailController = TextEditingController();
  final _phoneController = TextEditingController();
  final _passwordController = TextEditingController();

  // Data Balita
  final _childNameController = TextEditingController();
  final _nikController = TextEditingController();
  String _gender = 'L';
  DateTime _dateOfBirth = DateTime.now().subtract(const Duration(days: 30 * 18));
  final _weightController = TextEditingController();
  final _heightController = TextEditingController();
  final _addressController = TextEditingController();
  final _posyanduController = TextEditingController();

  bool _isLoading = false;

  Future<void> _submitRegistration() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    try {
      final success = await AuthService().registerChildAndParent(
        parentName: _parentNameController.text.trim(),
        email: _emailController.text.trim(),
        phone: _phoneController.text.trim(),
        password: _passwordController.text.trim(),
        childName: _childNameController.text.trim(),
        childNik: _nikController.text.trim(),
        gender: _gender,
        dateOfBirth: _dateOfBirth,
        birthWeightKg: double.tryParse(_weightController.text) ?? 3.0,
        birthHeightCm: double.tryParse(_heightController.text) ?? 49.0,
        address: _addressController.text.trim(),
        posyanduName: _posyanduController.text.trim(),
      );

      setState(() => _isLoading = false);

      if (success && mounted) {
        // Tampilkan dialog informasi registrasi berhasil
        await showDialog(
          context: context,
          barrierDismissible: false,
          builder: (ctx) => AlertDialog(
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
            title: Row(
              children: const [
                Icon(Icons.check_circle, color: AppColors.statusNormal, size: 28),
                SizedBox(width: 10),
                Text('Registrasi Berhasil!'),
              ],
            ),
            content: Text(
              'Data balita ${_childNameController.text} dan akun orang tua telah berhasil tersimpan di sistem realtime.\n\nSesuai alur, Anda sekarang akan diarahkan ke halaman Login.',
              style: const TextStyle(height: 1.4),
            ),
            actions: [
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primaryTeal,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
                onPressed: () {
                  Navigator.of(ctx).pop();
                  // Masuk ke Fitur Login setelah registrasi
                  Navigator.of(context).pushReplacementNamed('/login');
                },
                child: const Text('Lanjut ke Login'),
              ),
            ],
          ),
        );
      }
    } catch (e) {
      setState(() => _isLoading = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Terjadi kesalahan: $e'), backgroundColor: Colors.red),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF0FDF4), // Emerald subtle tint
      appBar: AppBar(
        title: const Text('Registrasi Balita & Akun', style: TextStyle(fontWeight: FontWeight.bold)),
        backgroundColor: AppColors.parentAccent,
        foregroundColor: Colors.white,
        elevation: 0,
        actions: [
          TextButton.icon(
            onPressed: () => Navigator.pushReplacementNamed(context, '/login'),
            icon: const Icon(Icons.login, color: Colors.white),
            label: const Text('Sudah Ada Akun', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
          )
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Center(
          child: Container(
            constraints: const BoxConstraints(maxWidth: 680),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // Banner Header Full Colour
                  Container(
                    padding: const EdgeInsets.all(22),
                    decoration: BoxDecoration(
                      gradient: AppColors.parentGradient,
                      borderRadius: BorderRadius.circular(24),
                      boxShadow: [
                        BoxShadow(
                          color: AppColors.parentAccent.withOpacity(0.3),
                          blurRadius: 16,
                          offset: const Offset(0, 8),
                        ),
                      ],
                    ),
                    child: Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(14),
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.2),
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(Icons.child_care, color: Colors.white, size: 40),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: const [
                              Text(
                                'Cegah Stunting Sejak Dini!',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              SizedBox(height: 4),
                              Text(
                                'Daftarkan data anak untuk pemantauan tumbuh kembang berbasis AI YOLO & kurva WHO.',
                                style: TextStyle(color: Colors.white70, fontSize: 13),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),

                  // KARTU 1: DATA ORANG TUA (Full Colour Ungu/Biru)
                  Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: AppColors.primaryBlue.withOpacity(0.2)),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.04),
                          blurRadius: 10,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: const [
                            Icon(Icons.family_restroom, color: AppColors.primaryBlue, size: 24),
                            SizedBox(width: 10),
                            Text(
                              'Langkah 1: Data Akun Orang Tua',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: AppColors.primaryBlue,
                              ),
                            ),
                          ],
                        ),
                        const Divider(height: 24),
                        TextFormField(
                          controller: _parentNameController,
                          decoration: InputDecoration(
                            labelText: 'Nama Lengkap Ibu / Ayah',
                            prefixIcon: const Icon(Icons.person, color: AppColors.primaryBlue),
                            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                          ),
                          validator: (v) => v!.isEmpty ? 'Wajib diisi' : null,
                        ),
                        const SizedBox(height: 14),
                        TextFormField(
                          controller: _emailController,
                          keyboardType: TextInputType.emailAddress,
                          decoration: InputDecoration(
                            labelText: 'Alamat Email (Untuk Login)',
                            prefixIcon: const Icon(Icons.email, color: AppColors.primaryBlue),
                            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                          ),
                          validator: (v) => v!.contains('@') ? null : 'Email tidak valid',
                        ),
                        const SizedBox(height: 14),
                        Row(
                          children: [
                            Expanded(
                              child: TextFormField(
                                controller: _phoneController,
                                keyboardType: TextInputType.phone,
                                decoration: InputDecoration(
                                  labelText: 'No. WhatsApp',
                                  prefixIcon: const Icon(Icons.phone, color: AppColors.primaryBlue),
                                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                                ),
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: TextFormField(
                                controller: _passwordController,
                                obscureText: true,
                                decoration: InputDecoration(
                                  labelText: 'Kata Sandi',
                                  prefixIcon: const Icon(Icons.lock, color: AppColors.primaryBlue),
                                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                                ),
                                validator: (v) => v!.length < 6 ? 'Min. 6 karakter' : null,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 20),

                  // KARTU 2: DATA BALITA (Full Colour Emerald/Orange)
                  Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: AppColors.parentAccent.withOpacity(0.2)),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.04),
                          blurRadius: 10,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: const [
                            Icon(Icons.child_care, color: AppColors.parentAccent, size: 24),
                            SizedBox(width: 10),
                            Text(
                              'Langkah 2: Data Balita yang Dipantau',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: AppColors.parentAccent,
                              ),
                            ),
                          ],
                        ),
                        const Divider(height: 24),
                        TextFormField(
                          controller: _childNameController,
                          decoration: InputDecoration(
                            labelText: 'Nama Lengkap Anak / Balita',
                            prefixIcon: const Icon(Icons.face, color: AppColors.parentAccent),
                            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                          ),
                          validator: (v) => v!.isEmpty ? 'Wajib diisi' : null,
                        ),
                        const SizedBox(height: 14),
                        TextFormField(
                          controller: _nikController,
                          keyboardType: TextInputType.number,
                          decoration: InputDecoration(
                            labelText: 'NIK Anak / No. Akta Kelahiran',
                            prefixIcon: const Icon(Icons.badge, color: AppColors.parentAccent),
                            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                          ),
                        ),
                        const SizedBox(height: 14),

                        // Gender Toggle Ceria
                        Row(
                          children: [
                            const Text('Jenis Kelamin: ', style: TextStyle(fontWeight: FontWeight.w600)),
                            const SizedBox(width: 12),
                            ChoiceChip(
                              label: const Text('👦 Laki-laki'),
                              selected: _gender == 'L',
                              selectedColor: Colors.blue.shade100,
                              onSelected: (val) => setState(() => _gender = 'L'),
                            ),
                            const SizedBox(width: 10),
                            ChoiceChip(
                              label: const Text('👧 Perempuan'),
                              selected: _gender == 'P',
                              selectedColor: Colors.pink.shade100,
                              onSelected: (val) => setState(() => _gender = 'P'),
                            ),
                          ],
                        ),
                        const SizedBox(height: 14),

                        // Tanggal Lahir Picker
                        InkWell(
                          onTap: () async {
                            final picked = await showDatePicker(
                              context: context,
                              initialDate: _dateOfBirth,
                              firstDate: DateTime.now().subtract(const Duration(days: 365 * 6)),
                              lastDate: DateTime.now(),
                            );
                            if (picked != null) {
                              setState(() => _dateOfBirth = picked);
                            }
                          },
                          child: InputDecorator(
                            decoration: InputDecoration(
                              labelText: 'Tanggal Lahir Balita',
                              prefixIcon: const Icon(Icons.cake, color: AppColors.parentAccent),
                              border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                            ),
                            child: Text(DateFormat('dd MMMM yyyy').format(_dateOfBirth)),
                          ),
                        ),
                        const SizedBox(height: 14),

                        Row(
                          children: [
                            Expanded(
                              child: TextFormField(
                                controller: _weightController,
                                keyboardType: const TextInputType.numberWithOptions(decimal: true),
                                decoration: InputDecoration(
                                  labelText: 'Berat Lahir (kg)',
                                  prefixIcon: const Icon(Icons.scale, color: AppColors.parentAccent),
                                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                                ),
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: TextFormField(
                                controller: _heightController,
                                keyboardType: const TextInputType.numberWithOptions(decimal: true),
                                decoration: InputDecoration(
                                  labelText: 'Panjang Lahir (cm)',
                                  prefixIcon: const Icon(Icons.height, color: AppColors.parentAccent),
                                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 14),
                        TextFormField(
                          controller: _posyanduController,
                          decoration: InputDecoration(
                            labelText: 'Nama Posyandu Terdekat / Puskesmas',
                            prefixIcon: const Icon(Icons.local_hospital, color: AppColors.parentAccent),
                            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                          ),
                        ),
                        const SizedBox(height: 14),
                        TextFormField(
                          controller: _addressController,
                          decoration: InputDecoration(
                            labelText: 'Alamat Domisili',
                            prefixIcon: const Icon(Icons.home, color: AppColors.parentAccent),
                            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 28),

                  // TOMBOL REGISTRASI BESAR & VIBRANT
                  SizedBox(
                    height: 56,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.parentAccent,
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                        elevation: 4,
                      ),
                      onPressed: _isLoading ? null : _submitRegistration,
                      child: _isLoading
                          ? const CircularProgressIndicator(color: Colors.white)
                          : Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: const [
                                Icon(Icons.save_as, size: 22),
                                SizedBox(width: 10),
                                Text(
                                  'Daftarkan Balita & Lanjut ke Login',
                                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                                ),
                              ],
                            ),
                    ),
                  ),
                  const SizedBox(height: 20),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
