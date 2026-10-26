enum NotificationType {
  stuntingAlert,
  posyanduSchedule,
  doctorConsultation,
  nutritionTip,
  systemAnnouncement
}

class NotificationModel {
  final String id;
  final String recipientId; // Bisa spesifik userId atau 'ALL_PARENTS', 'ALL_DOCTORS'
  final String title;
  final String message;
  final NotificationType type;
  final DateTime timestamp;
  final bool isRead;
  final String? relatedChildId;
  final String? relatedDetectionId;

  NotificationModel({
    required this.id,
    required this.recipientId,
    required this.title,
    required this.message,
    required this.type,
    required this.timestamp,
    this.isRead = false,
    this.relatedChildId,
    this.relatedDetectionId,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'recipientId': recipientId,
      'title': title,
      'message': message,
      'type': type.name,
      'timestamp': timestamp.toIso8601String(),
      'isRead': isRead,
      'relatedChildId': relatedChildId,
      'relatedDetectionId': relatedDetectionId,
    };
  }

  factory NotificationModel.fromMap(Map<String, dynamic> map, String id) {
    return NotificationModel(
      id: id,
      recipientId: map['recipientId'] ?? '',
      title: map['title'] ?? '',
      message: map['message'] ?? '',
      type: NotificationType.values.firstWhere(
        (e) => e.name == map['type'],
        orElse: () => NotificationType.systemAnnouncement,
      ),
      timestamp: map['timestamp'] != null
          ? DateTime.parse(map['timestamp'])
          : DateTime.now(),
      isRead: map['isRead'] ?? false,
      relatedChildId: map['relatedChildId'],
      relatedDetectionId: map['relatedDetectionId'],
    );
  }
}
