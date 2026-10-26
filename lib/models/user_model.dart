enum UserRole { parent, expert, admin }

class UserModel {
  final String uid;
  final String name;
  final String email;
  final String phone;
  final UserRole role;
  final String? password;       // Kata sandi untuk autentikasi ketat
  final String? specialization; // Khusus dokter/pakar (e.g. Dokter Spesialis Anak Sp.A / Ahli Gizi)
  final String? sipNumber;      // Surat Izin Praktik jika dokter
  final String? assignedRegion; // Khusus admin/posyandu
  final DateTime createdAt;

  UserModel({
    required this.uid,
    required this.name,
    required this.email,
    required this.phone,
    required this.role,
    this.password,
    this.specialization,
    this.sipNumber,
    this.assignedRegion,
    required this.createdAt,
  });

  Map<String, dynamic> toMap() {
    return {
      'uid': uid,
      'name': name,
      'email': email,
      'phone': phone,
      'role': role.name,
      'password': password,
      'specialization': specialization,
      'sipNumber': sipNumber,
      'assignedRegion': assignedRegion,
      'createdAt': createdAt.toIso8601String(),
    };
  }

  factory UserModel.fromMap(Map<String, dynamic> map, String uid) {
    return UserModel(
      uid: uid,
      name: map['name'] ?? '',
      email: map['email'] ?? '',
      phone: map['phone'] ?? '',
      role: UserRole.values.firstWhere(
        (e) => e.name == map['role'],
        orElse: () => UserRole.parent,
      ),
      password: map['password'],
      specialization: map['specialization'],
      sipNumber: map['sipNumber'],
      assignedRegion: map['assignedRegion'],
      createdAt: map['createdAt'] != null
          ? DateTime.parse(map['createdAt'])
          : DateTime.now(),
    );
  }
}
