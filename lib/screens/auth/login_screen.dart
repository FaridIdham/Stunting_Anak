import 'package:flutter/material.dart';
import '../../core/app_colors.dart';
import '../../models/user_model.dart';
import '../../services/auth_service.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  UserRole _selectedRole = UserRole.parent;
  final _phoneController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _isLoading = false;
  String? _errorMessage;

  void _onRoleChanged(UserRole role) {
    setState(() {
      _selectedRole = role;
      _errorMessage = null;
      _phoneController.clear();
      _passwordController.clear();
    });
  }

  Color get _currentRoleColor {
    switch (_selectedRole) {
      case UserRole.parent:
        return AppColors.parentAccent;
      case UserRole.expert:
        return AppColors.expertAccent;
      case UserRole.admin:
        return AppColors.adminAccent;
    }
  }

  LinearGradient get _currentRoleGradient {
    switch (_selectedRole) {
      case UserRole.parent:
        return AppColors.parentGradient;
      case UserRole.expert:
        return AppColors.doctorGradient;
      case UserRole.admin:
        return AppColors.adminGradient;
    }
  }

  Future<void> _handleLogin() async {
    final phone = _phoneController.text.trim();
    final password = _passwordController.text.trim();
    if (phone.isEmpty) {
      setState(() => _errorMessage = 'Nomor HP / WhatsApp wajib diisi');
      return;
    }
    if (password.isEmpty) {
      setState(() => _errorMessage = 'Kata sandi / PIN wajib diisi');
      return;
    }

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    // Validasi ketat nomor HP terdaftar
    final result = await AuthService().loginWithPhone(
      phone: phone,
      password: _passwordController.text.trim(),
      expectedRole: _selectedRole,
    );

    setState(() => _isLoading = false);

    if (!result.success) {
      // Jika nomor HP tidak terdaftar -> DITOLAK masuk ke menu utama!
      setState(() {
        _errorMessage = result.errorMessage;
      });
      return;
    }

    if (mounted) {
      // Masuk ke Fitur Utama sesuai Hak Akses
      switch (_selectedRole) {
        case UserRole.parent:
          Navigator.pushReplacementNamed(context, '/parent_dashboard');
          break;
        case UserRole.expert:
          Navigator.pushReplacementNamed(context, '/expert_dashboard');
          break;
        case UserRole.admin:
          Navigator.pushReplacementNamed(context, '/admin_dashboard');
          break;
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    // Ultra Responsive Breakpoint Handling
    final screenWidth = MediaQuery.of(context).size.width;
    final isCompact = screenWidth < 400;

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: EdgeInsets.symmetric(
              horizontal: screenWidth < 500 ? 16 : 28,
              vertical: 20,
            ),
            child: Container(
              constraints: const BoxConstraints(maxWidth: 480),
              padding: EdgeInsets.all(screenWidth < 500 ? 20 : 32),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(28),
                border: Border.all(color: _currentRoleColor.withOpacity(0.2), width: 1.5),
                boxShadow: [
                  BoxShadow(
                    color: _currentRoleColor.withOpacity(0.12),
                    blurRadius: 24,
                    offset: const Offset(0, 10),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // Header Logo & Title
                  Center(
                    child: Container(
                      padding: const EdgeInsets.all(18),
                      decoration: BoxDecoration(
                        gradient: _currentRoleGradient,
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: _currentRoleColor.withOpacity(0.35),
                            blurRadius: 14,
                            offset: const Offset(0, 6),
                          )
                        ],
                      ),
                      child: const Icon(Icons.health_and_safety, color: Colors.white, size: 40),
                    ),
                  ),
                  const SizedBox(height: 14),
                  const Center(
                    child: Text(
                      'StuntingGuard AI',
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.w900,
                        color: Color(0xFF0F172A),
                      ),
                    ),
                  ),
                  const SizedBox(height: 4),
                  Center(
                    child: Text(
                      'Login Menggunakan Nomor WhatsApp / HP Terdaftar',
                      textAlign: TextAlign.center,
                      style: TextStyle(fontSize: 12.5, color: Colors.grey.shade600),
                    ),
                  ),
                  const SizedBox(height: 22),

                  // ROLE SELECTOR TABS FULL COLOUR
                  const Text(
                    'Pilih Hak Akses Masuk:',
                    style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: Color(0xFF334155)),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Expanded(
                        child: _buildRoleButton(
                          role: UserRole.parent,
                          label: 'Orang Tua',
                          icon: Icons.family_restroom,
                          color: AppColors.parentAccent,
                          badge: 'Mobile',
                        ),
                      ),
                      const SizedBox(width: 6),
                      Expanded(
                        child: _buildRoleButton(
                          role: UserRole.expert,
                          label: 'Dokter Ahli',
                          icon: Icons.medical_services,
                          color: AppColors.expertAccent,
                          badge: 'Web/Mob',
                        ),
                      ),
                      const SizedBox(width: 6),
                      Expanded(
                        child: _buildRoleButton(
                          role: UserRole.admin,
                          label: 'Admin',
                          icon: Icons.admin_panel_settings,
                          color: AppColors.adminAccent,
                          badge: 'Web/Mob',
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 20),

                  // BANNER ERROR JIKA NOMOR HP BELUM TERDAFTAR
                  if (_errorMessage != null) ...[
                    Container(
                      padding: const EdgeInsets.all(14),
                      decoration: BoxDecoration(
                        color: Colors.red.shade50,
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(color: Colors.red.shade300, width: 1.5),
                      ),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Icon(Icons.error_outline, color: Colors.red, size: 22),
                          const SizedBox(width: 10),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text(
                                  'Akses Ditolak!',
                                  style: TextStyle(fontWeight: FontWeight.bold, color: Colors.red, fontSize: 13),
                                ),
                                const SizedBox(height: 2),
                                Text(
                                  _errorMessage!,
                                  style: TextStyle(color: Colors.red.shade900, fontSize: 12, height: 1.35),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 16),
                  ],

                  // Form Login dengan Nomor WhatsApp / HP
                  TextFormField(
                    controller: _phoneController,
                    keyboardType: TextInputType.phone,
                    decoration: InputDecoration(
                      labelText: 'Nomor WhatsApp / HP',
                      hintText: 'Contoh: 081234567890',
                      prefixIcon: Icon(Icons.phone_android, color: _currentRoleColor),
                      suffixIcon: const Icon(Icons.chat, color: Colors.green, size: 20),
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(14)),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(14),
                        borderSide: BorderSide(color: _currentRoleColor, width: 2),
                      ),
                    ),
                  ),
                  const SizedBox(height: 14),
                  TextFormField(
                    controller: _passwordController,
                    obscureText: true,
                    decoration: InputDecoration(
                      labelText: 'Kata Sandi / PIN',
                      prefixIcon: Icon(Icons.lock_outline, color: _currentRoleColor),
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(14)),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(14),
                        borderSide: BorderSide(color: _currentRoleColor, width: 2),
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),

                  // Tombol Masuk Fitur Utama
                  SizedBox(
                    height: 52,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: _currentRoleColor,
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                        elevation: 3,
                      ),
                      onPressed: _isLoading ? null : _handleLogin,
                      child: _isLoading
                          ? const CircularProgressIndicator(color: Colors.white)
                          : Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: const [
                                Icon(Icons.login, size: 20),
                                SizedBox(width: 8),
                                Text(
                                  'Masuk ke Fitur Utama',
                                  style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
                                ),
                              ],
                            ),
                    ),
                  ),

                  const SizedBox(height: 18),

                  // Opsi Registrasi Balita jika belum terdaftar
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.grey.shade50,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: Colors.grey.shade200),
                    ),
                    child: Column(
                      children: [
                        const Text(
                          'Nomor HP Anda belum pernah didaftarkan?',
                          style: TextStyle(fontSize: 12, color: Color(0xFF475569)),
                        ),
                        const SizedBox(height: 4),
                        InkWell(
                          onTap: () => Navigator.pushReplacementNamed(context, '/register_child'),
                          child: Text(
                            '👉 Daftarkan Balita & Nomor HP Sekarang',
                            style: TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.bold,
                              color: AppColors.parentAccent,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildRoleButton({
    required UserRole role,
    required String label,
    required IconData icon,
    required Color color,
    required String badge,
  }) {
    final isSelected = _selectedRole == role;
    return InkWell(
      onTap: () => _onRoleChanged(role),
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 9, horizontal: 4),
        decoration: BoxDecoration(
          color: isSelected ? color : color.withOpacity(0.08),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected ? color : color.withOpacity(0.3),
            width: isSelected ? 2 : 1,
          ),
        ),
        child: Column(
          children: [
            Icon(icon, color: isSelected ? Colors.white : color, size: 20),
            const SizedBox(height: 3),
            Text(
              label,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.bold,
                color: isSelected ? Colors.white : const Color(0xFF0F172A),
              ),
            ),
            const SizedBox(height: 2),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 1),
              decoration: BoxDecoration(
                color: isSelected ? Colors.white.withOpacity(0.25) : color.withOpacity(0.15),
                borderRadius: BorderRadius.circular(6),
              ),
              child: Text(
                badge,
                style: TextStyle(
                  fontSize: 8.5,
                  fontWeight: FontWeight.bold,
                  color: isSelected ? Colors.white : color,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
