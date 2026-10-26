class ChildModel {
  final String id;
  final String parentId;
  final String parentName;
  final String childName;
  final String nik;
  final String gender; // 'L' (Laki-laki) atau 'P' (Perempuan)
  final DateTime dateOfBirth;
  final double birthWeightKg;
  final double birthHeightCm;
  final String address;
  final String posyanduName;
  final DateTime createdAt;

  ChildModel({
    required this.id,
    required this.parentId,
    required this.parentName,
    required this.childName,
    required this.nik,
    required this.gender,
    required this.dateOfBirth,
    required this.birthWeightKg,
    required this.birthHeightCm,
    required this.address,
    required this.posyanduName,
    required this.createdAt,
  });

  // Menghitung usia anak dalam bulan secara presisi
  int get ageInMonths {
    final now = DateTime.now();
    int months = (now.year - dateOfBirth.year) * 12 + (now.month - dateOfBirth.month);
    if (now.day < dateOfBirth.day) {
      months--;
    }
    return months < 0 ? 0 : months;
  }

  String get ageFormatted {
    final months = ageInMonths;
    final years = months ~/ 12;
    final remainingMonths = months % 12;
    if (years > 0) {
      return '$years Tahun $remainingMonths Bulan';
    }
    return '$months Bulan';
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'parentId': parentId,
      'parentName': parentName,
      'childName': childName,
      'nik': nik,
      'gender': gender,
      'dateOfBirth': dateOfBirth.toIso8601String(),
      'birthWeightKg': birthWeightKg,
      'birthHeightCm': birthHeightCm,
      'address': address,
      'posyanduName': posyanduName,
      'createdAt': createdAt.toIso8601String(),
    };
  }

  factory ChildModel.fromMap(Map<String, dynamic> map, String id) {
    return ChildModel(
      id: id,
      parentId: map['parentId'] ?? '',
      parentName: map['parentName'] ?? '',
      childName: map['childName'] ?? '',
      nik: map['nik'] ?? '',
      gender: map['gender'] ?? 'L',
      dateOfBirth: map['dateOfBirth'] != null
          ? DateTime.parse(map['dateOfBirth'])
          : DateTime.now(),
      birthWeightKg: (map['birthWeightKg'] as num?)?.toDouble() ?? 3.0,
      birthHeightCm: (map['birthHeightCm'] as num?)?.toDouble() ?? 49.0,
      address: map['address'] ?? '',
      posyanduName: map['posyanduName'] ?? '',
      createdAt: map['createdAt'] != null
          ? DateTime.parse(map['createdAt'])
          : DateTime.now(),
    );
  }
}
