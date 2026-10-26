import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../core/app_colors.dart';
import '../../models/notification_model.dart';
import '../../services/realtime_database_service.dart';

class NotificationCenterScreen extends StatelessWidget {
  const NotificationCenterScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final realtimeDb = RealtimeDatabaseService();

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        title: const Text('Pusat Notifikasi Realtime', style: TextStyle(fontWeight: FontWeight.bold)),
        backgroundColor: AppColors.featureNotification,
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: AnimatedBuilder(
        animation: realtimeDb,
        builder: (context, _) {
          final list = realtimeDb.notifications;

          if (list.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: const [
                  Icon(Icons.notifications_off_outlined, size: 60, color: Colors.grey),
                  SizedBox(height: 14),
                  Text('Belum ada notifikasi.', style: TextStyle(fontSize: 16, color: Colors.grey)),
                ],
              ),
            );
          }

          return ListView.separated(
            padding: const EdgeInsets.all(16),
            itemCount: list.length,
            separatorBuilder: (_, __) => const SizedBox(height: 12),
            itemBuilder: (context, index) {
              final notif = list[index];
              Color iconBg;
              IconData iconData;

              switch (notif.type) {
                case NotificationType.stuntingAlert:
                  iconBg = Colors.red;
                  iconData = Icons.warning_rounded;
                  break;
                case NotificationType.posyanduSchedule:
                  iconBg = Colors.blue;
                  iconData = Icons.calendar_today;
                  break;
                case NotificationType.doctorConsultation:
                  iconBg = Colors.teal;
                  iconData = Icons.medical_services;
                  break;
                case NotificationType.nutritionTip:
                  iconBg = Colors.orange;
                  iconData = Icons.restaurant;
                  break;
                case NotificationType.systemAnnouncement:
                  iconBg = Colors.purple;
                  iconData = Icons.campaign;
                  break;
              }

              return InkWell(
                onTap: () => realtimeDb.markNotificationAsRead(notif.id),
                borderRadius: BorderRadius.circular(16),
                child: Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: notif.isRead ? Colors.white : iconBg.withOpacity(0.06),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: notif.isRead ? Colors.grey.shade200 : iconBg.withOpacity(0.4),
                      width: notif.isRead ? 1 : 1.5,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.03),
                        blurRadius: 8,
                        offset: const Offset(0, 3),
                      ),
                    ],
                  ),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: iconBg.withOpacity(0.15),
                          shape: BoxShape.circle,
                        ),
                        child: Icon(iconData, color: iconBg, size: 24),
                      ),
                      const SizedBox(width: 14),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Expanded(
                                  child: Text(
                                    notif.title,
                                    style: TextStyle(
                                      fontWeight: notif.isRead ? FontWeight.w600 : FontWeight.bold,
                                      fontSize: 14.5,
                                      color: const Color(0xFF0F172A),
                                    ),
                                  ),
                                ),
                                if (!notif.isRead)
                                  Container(
                                    width: 8,
                                    height: 8,
                                    decoration: BoxDecoration(
                                      color: iconBg,
                                      shape: BoxShape.circle,
                                    ),
                                  ),
                              ],
                            ),
                            const SizedBox(height: 4),
                            Text(
                              notif.message,
                              style: TextStyle(
                                fontSize: 13,
                                color: Colors.grey.shade700,
                                height: 1.35,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              DateFormat('dd MMM yyyy, HH:mm').format(notif.timestamp),
                              style: TextStyle(fontSize: 11, color: Colors.grey.shade500),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
