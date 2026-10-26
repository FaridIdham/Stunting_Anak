import 'package:flutter/foundation.dart';
import '../models/user_model.dart';
import '../models/child_model.dart';
import 'realtime_database_service.dart';

class AuthResult {
  final bool success;
  final String? errorMessage;
  final UserModel? user;

  AuthResult({required this.success, this.errorMessage, this.user});
}

class AuthService extends ChangeNotifier {
  static final AuthService _instance = AuthService._internal();
  factory AuthService() => _instance;

  AuthService._internal();

  UserModel? _currentUser;
  ChildModel? _selectedChild;

  // In-memory registered user database by Phone Number / WhatsApp
  final Map<String, UserModel> _registeredUsersByPhone = {
    // Akun Dokter Terdaftar
    '081198765432': UserModel(
      uid: 'DOC-01',
      name: 'dr. Farhan Malik, Sp.A (K)',
      email: 'dr.farhan@rumahsakit.id',
      phone: '081198765432',
      password: 'password123',
      role: UserRole.expert,
      specialization: 'Dokter Spesialis Anak - Konsultan Nutrisi & Metabolik',
      sipNumber: 'SIP.440/129/DINKES/2024',
      createdAt: DateTime.now().subtract(const Duration(days: 90)),
    ),
    // Akun Admin Terdaftar
    '081388776655': UserModel(
      uid: 'ADM-01',
      name: 'Administrator Dinas Kesehatan',
      email: 'admin@dinkes.go.id',
      phone: '081388776655',
      password: 'password123',
      role: UserRole.admin,
      assignedRegion: 'Pusat Pengendalian Stunting Terpadu Nasional',
      createdAt: DateTime.now().subtract(const Duration(days: 120)),
    ),
    // Akun Dokter & Admin sistem tetap disimpan untuk login pakar/admin
  };

  UserModel? get currentUser => _currentUser;
  ChildModel? get selectedChild => _selectedChild;
  bool get isAuthenticated => _currentUser != null;

  void setSelectedChild(ChildModel child) {
    _selectedChild = child;
    notifyListeners();
  }

  // ==================== ALUR REGISTRASI ANAK & ORANG TUA ====================
  Future<bool> registerChildAndParent({
    required String parentName,
    required String email,
    required String phone,
    required String password,
    required String childName,
    required String childNik,
    required String gender,
    required DateTime dateOfBirth,
    required double birthWeightKg,
    required double birthHeightCm,
    required String address,
    required String posyanduName,
  }) async {
    await Future.delayed(const Duration(milliseconds: 700));

    final cleanPhone = _normalizePhone(phone);

    // 1. Daftarkan Balita ke Realtime Database
    final childId = 'CHILD-${DateTime.now().millisecondsSinceEpoch}';
    final newChild = ChildModel(
      id: childId,
      parentId: cleanPhone,
      parentName: parentName,
      childName: childName,
      nik: childNik,
      gender: gender,
      dateOfBirth: dateOfBirth,
      birthWeightKg: birthWeightKg,
      birthHeightCm: birthHeightCm,
      address: address,
      posyanduName: posyanduName,
      createdAt: DateTime.now(),
    );

    await RealtimeDatabaseService().registerChild(newChild);

    // 2. Simpan User Akun beserta Password Terdaftar
    _registeredUsersByPhone[cleanPhone] = UserModel(
      uid: 'USR-${DateTime.now().millisecondsSinceEpoch}',
      name: parentName,
      email: email,
      phone: cleanPhone,
      password: password,
      role: UserRole.parent,
      createdAt: DateTime.now(),
    );

    notifyListeners();
    return true;
  }

  // ==================== ALUR LOGIN DENGAN NOMOR HP / WHATSAPP ====================
  // "jika Nomor WhatsApp / HP Terdaftar dan password tidak sama dengan waktu melakukan registrasi
  // atau data yang tersimpan di database maka tidak bisa login atau ulani lagi begitu sebaliknya"
  Future<AuthResult> loginWithPhone({
    required String phone,
    required String password,
    required UserRole expectedRole,
  }) async {
    await Future.delayed(const Duration(milliseconds: 600));

    final cleanPhone = _normalizePhone(phone);

    // 1. Validasi Apakah Nomor HP / WhatsApp Terdaftar
    if (!_registeredUsersByPhone.containsKey(cleanPhone)) {
      return AuthResult(
        success: false,
        errorMessage: 'Nomor WhatsApp / HP ($cleanPhone) tidak terdaftar di sistem! Anda tidak dapat masuk ke menu utama. Silakan lakukan Registrasi Balita terlebih dahulu.',
      );
    }

    final user = _registeredUsersByPhone[cleanPhone]!;

    // 2. Validasi Kata Sandi (Password) Harus Sama dengan Waktu Registrasi / Database
    final registeredPassword = user.password ?? '';
    if (registeredPassword.isNotEmpty && registeredPassword != password) {
      return AuthResult(
        success: false,
        errorMessage: 'Kata sandi tidak sesuai dengan data registrasi! Silakan periksa kembali dan ulangi lagi.',
      );
    }

    // 3. Validasi Kesesuaian Peran Hak Akses
    if (user.role != expectedRole) {
      String roleTitle = expectedRole == UserRole.parent ? 'Orang Tua' : (expectedRole == UserRole.expert ? 'Dokter Ahli' : 'Admin');
      return AuthResult(
        success: false,
        errorMessage: 'Nomor HP ini terdaftar bukan sebagai hak akses $roleTitle. Silakan pilih peran yang tepat.',
      );
    }

    _currentUser = user;

    // Otomatis assign balita aktif jika orang tua
    if (user.role == UserRole.parent) {
      final parentChildren = RealtimeDatabaseService().getChildrenByParent(cleanPhone);
      if (parentChildren.isNotEmpty) {
        _selectedChild = parentChildren.first;
      } else if (RealtimeDatabaseService().children.isNotEmpty) {
        _selectedChild = RealtimeDatabaseService().children.first;
      }
    }

    notifyListeners();
    return AuthResult(success: true, user: user);
  }

  bool isPhoneRegistered(String phone) {
    return _registeredUsersByPhone.containsKey(_normalizePhone(phone));
  }

  String _normalizePhone(String phone) {
    return phone.replaceAll(RegExp(r'[^0-9]'), '').trim();
  }

  void logout() {
    _currentUser = null;
    _selectedChild = null;
    notifyListeners();
  }
}
