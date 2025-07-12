import 'package:hive/hive.dart';

part 'sleep_notification_model.g.dart';

@HiveType(typeId: 11)
class SleepNotificationModel extends HiveObject {
  @HiveField(0)
  final String id;

  @HiveField(1)
  final String babyId;

  @HiveField(2)
  final NotificationType type;

  @HiveField(3)
  final String title;

  @HiveField(4)
  final String message;

  @HiveField(5)
  final DateTime createdAt;

  @HiveField(6)
  final DateTime? scheduledFor;

  @HiveField(7)
  final bool isRead;

  @HiveField(8)
  final bool isActive;

  @HiveField(9)
  final Map<String, dynamic>? metadata;

  SleepNotificationModel({
    required this.id,
    required this.babyId,
    required this.type,
    required this.title,
    required this.message,
    required this.createdAt,
    this.scheduledFor,
    this.isRead = false,
    this.isActive = true,
    this.metadata,
  });

  factory SleepNotificationModel.create({
    required String babyId,
    required NotificationType type,
    required String title,
    required String message,
    DateTime? scheduledFor,
    Map<String, dynamic>? metadata,
  }) {
    final now = DateTime.now();
    return SleepNotificationModel(
      id: 'notification_${now.millisecondsSinceEpoch}',
      babyId: babyId,
      type: type,
      title: title,
      message: message,
      createdAt: now,
      scheduledFor: scheduledFor,
      metadata: metadata,
    );
  }

  SleepNotificationModel copyWith({
    String? id,
    String? babyId,
    NotificationType? type,
    String? title,
    String? message,
    DateTime? createdAt,
    DateTime? scheduledFor,
    bool? isRead,
    bool? isActive,
    Map<String, dynamic>? metadata,
  }) {
    return SleepNotificationModel(
      id: id ?? this.id,
      babyId: babyId ?? this.babyId,
      type: type ?? this.type,
      title: title ?? this.title,
      message: message ?? this.message,
      createdAt: createdAt ?? this.createdAt,
      scheduledFor: scheduledFor ?? this.scheduledFor,
      isRead: isRead ?? this.isRead,
      isActive: isActive ?? this.isActive,
      metadata: metadata ?? this.metadata,
    );
  }

  // Notification emoji'si
  String get emoji {
    switch (type) {
      case NotificationType.sleepReminder:
        return '😴';
      case NotificationType.sleepPattern:
        return '📊';
      case NotificationType.sleepMilestone:
        return '🏆';
      case NotificationType.sleepWarning:
        return '⚠️';
      case NotificationType.sleepTip:
        return '💡';
    }
  }

  // Notification rengi
  String get colorHex {
    switch (type) {
      case NotificationType.sleepReminder:
        return '#FF6B9D'; // Pembe
      case NotificationType.sleepPattern:
        return '#4ECDC4'; // Turkuaz
      case NotificationType.sleepMilestone:
        return '#FFD93D'; // Sarı
      case NotificationType.sleepWarning:
        return '#FF6B6B'; // Kırmızı
      case NotificationType.sleepTip:
        return '#6BCF7F'; // Yeşil
    }
  }

  @override
  String toString() {
    return 'SleepNotificationModel{id: $id, type: $type, title: $title, isRead: $isRead}';
  }
}

@HiveType(typeId: 12)
enum NotificationType {
  @HiveField(0)
  sleepReminder('Uyku Hatırlatması'),

  @HiveField(1)
  sleepPattern('Uyku Düzeni'),

  @HiveField(2)
  sleepMilestone('Uyku Kilometre Taşı'),

  @HiveField(3)
  sleepWarning('Uyku Uyarısı'),

  @HiveField(4)
  sleepTip('Uyku İpucu');

  const NotificationType(this.displayName);

  final String displayName;
}
