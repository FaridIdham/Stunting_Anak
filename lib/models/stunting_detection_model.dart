enum StuntingStatus { normal, stunted, severelyStunted, tall }
enum DoctorValidation { pending, approved, revisionRequired }

class StuntingDetectionModel {
  final String id;
  final String childId;
  final String childName;
  final DateTime timestamp;
  final int ageInMonths;
  final String gender;
  final double heightCm;
  final double weightKg;
  final double zScoreHAZ; // Height-for-Age Z-score (TB/U)
  final double zScoreWAZ; // Weight-for-Age Z-score (BB/U)
  final StuntingStatus status;
  final double yoloConfidence;
  final List<Map<String, dynamic>>? keypoints;
  final DoctorValidation validationStatus;
  final String? doctorNotes;
  final String? doctorName;
  final String? doctorId;
  final String? imagePath;
  final List<String> nutritionalRecommendations;

  StuntingDetectionModel({
    required this.id,
    required this.childId,
    required this.childName,
    required this.timestamp,
    required this.ageInMonths,
    required this.gender,
    required this.heightCm,
    required this.weightKg,
    required this.zScoreHAZ,
    required this.zScoreWAZ,
    required this.status,
    required this.yoloConfidence,
    this.keypoints,
    this.validationStatus = DoctorValidation.pending,
    this.doctorNotes,
    this.doctorName,
    this.doctorId,
    this.imagePath,
    required this.nutritionalRecommendations,
  });

  String get statusText {
    switch (status) {
      case StuntingStatus.normal:
        return 'Gizi Baik / Normal';
      case StuntingStatus.stunted:
        return 'Stunting (Pendek)';
      case StuntingStatus.severelyStunted:
        return 'Severely Stunted (Sangat Pendek)';
      case StuntingStatus.tall:
        return 'Tinggi (Di atas Rata-rata)';
    }
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'childId': childId,
      'childName': childName,
      'timestamp': timestamp.toIso8601String(),
      'ageInMonths': ageInMonths,
      'gender': gender,
      'heightCm': heightCm,
      'weightKg': weightKg,
      'zScoreHAZ': zScoreHAZ,
      'zScoreWAZ': zScoreWAZ,
      'status': status.name,
      'yoloConfidence': yoloConfidence,
      'keypoints': keypoints,
      'validationStatus': validationStatus.name,
      'doctorNotes': doctorNotes,
      'doctorName': doctorName,
      'doctorId': doctorId,
      'imagePath': imagePath,
      'nutritionalRecommendations': nutritionalRecommendations,
    };
  }

  factory StuntingDetectionModel.fromMap(Map<String, dynamic> map, String id) {
    return StuntingDetectionModel(
      id: id,
      childId: map['childId'] ?? '',
      childName: map['childName'] ?? '',
      timestamp: map['timestamp'] != null
          ? DateTime.parse(map['timestamp'])
          : DateTime.now(),
      ageInMonths: map['ageInMonths'] ?? 0,
      gender: map['gender'] ?? 'L',
      heightCm: (map['heightCm'] as num?)?.toDouble() ?? 0.0,
      weightKg: (map['weightKg'] as num?)?.toDouble() ?? 0.0,
      zScoreHAZ: (map['zScoreHAZ'] as num?)?.toDouble() ?? 0.0,
      zScoreWAZ: (map['zScoreWAZ'] as num?)?.toDouble() ?? 0.0,
      status: StuntingStatus.values.firstWhere(
        (e) => e.name == map['status'],
        orElse: () => StuntingStatus.normal,
      ),
      yoloConfidence: (map['yoloConfidence'] as num?)?.toDouble() ?? 0.95,
      keypoints: (map['keypoints'] as List<dynamic>?)
          ?.map((e) => Map<String, dynamic>.from(e as Map))
          .toList(),
      validationStatus: DoctorValidation.values.firstWhere(
        (e) => e.name == map['validationStatus'],
        orElse: () => DoctorValidation.pending,
      ),
      doctorNotes: map['doctorNotes'],
      doctorName: map['doctorName'],
      doctorId: map['doctorId'],
      imagePath: map['imagePath'],
      nutritionalRecommendations: List<String>.from(
          map['nutritionalRecommendations'] ?? []),
    );
  }
}
