import 'package:hive_flutter/hive_flutter.dart';
import '../models/feeding_model.dart';
import '../models/baby_model.dart';
import 'feeding_storage_service.dart';
import 'baby_storage_service.dart';
import 'notification_service.dart';

class FeedingNotificationService {
  static const String _boxName = 'feeding_notifications';
  static Box<FeedingNotificationModel>? _box;

  static FeedingNotificationService? _instance;
  static FeedingNotificationService get instance {
    _instance ??= FeedingNotificationService._();
    return _instance!;
  }

  FeedingNotificationService._();

  static Future<void> initialize() async {
    _box = Hive.box<FeedingNotificationModel>(_boxName);
  }

  Box<FeedingNotificationModel> get _notificationBox {
    if (_box == null || !_box!.isOpen) {
      _box = Hive.box<FeedingNotificationModel>(_boxName);
      if (_box == null || !_box!.isOpen) {
        throw Exception('Feeding notification box is not initialized');
      }
    }
    return _box!;
  }

  // Beslenme sonrası analiz ve bildirim oluşturma
  Future<void> analyzeFeedingAndCreateNotifications(String babyId) async {
    try {
      final babies = await BabyStorageService.instance.getAllBabies();
      final baby = babies.firstWhere(
        (b) => b.id == babyId,
        orElse: () => throw Exception('Baby not found'),
      );

      final feedingRecords = await FeedingStorageService.instance
          .getRecentFeedingsForBaby(babyId, limit: 50);
      if (feedingRecords.isEmpty) return;

      // Son 24 saatlik beslenme kayıtları
      final now = DateTime.now();
      final dayAgo = now.subtract(const Duration(days: 1));
      final recentFeedings =
          feedingRecords
              .where((feeding) => feeding.timestamp.isAfter(dayAgo))
              .toList();

      // 1. Beslenme sıklığı analizi
      await _analyzeFeedingFrequency(baby, recentFeedings);

      // 2. Beslenme miktarı analizi
      await _analyzeFeedingAmount(baby, recentFeedings);

      // 3. Beslenme kilometre taşları
      await _checkFeedingMilestones(baby, feedingRecords);

      // 4. Beslenme ipuçları
      await _generateFeedingTips(baby, recentFeedings);
    } catch (e) {
      print('Error analyzing feeding: $e');
    }
  }

  // Beslenme sıklığı analizi
  Future<void> _analyzeFeedingFrequency(
    BabyModel baby,
    List<FeedingModel> recentFeedings,
  ) async {
    if (recentFeedings.length < 3) return;

    // Ortalama beslenme aralığı
    final intervals = <Duration>[];
    for (int i = 1; i < recentFeedings.length; i++) {
      final interval = recentFeedings[i - 1].timestamp.difference(
        recentFeedings[i].timestamp,
      );
      intervals.add(interval);
    }

    final averageInterval =
        intervals.fold<Duration>(
          Duration.zero,
          (sum, interval) => sum + interval,
        ) ~/
        intervals.length;

    // Bebek yaşına göre ideal beslenme aralığı
    final idealInterval = _getIdealFeedingInterval(baby.ageInMonths);

    if (averageInterval.inHours > idealInterval.inHours * 1.5) {
      final notification = FeedingNotificationModel.create(
        babyId: baby.id,
        type: FeedingNotificationType.frequencyWarning,
        title: 'Beslenme Sıklığı Uyarısı',
        message:
            '${baby.name} için beslenme aralıkları uzamış. '
            'Daha sık beslenme gerekebilir. 🍼',
        metadata: {
          'averageInterval': averageInterval.inHours,
          'idealInterval': idealInterval.inHours,
        },
      );

      await addNotification(notification);
    }
  }

  // Beslenme miktarı analizi
  Future<void> _analyzeFeedingAmount(
    BabyModel baby,
    List<FeedingModel> recentFeedings,
  ) async {
    if (recentFeedings.isEmpty) return;

    // Son 24 saatteki toplam beslenme miktarı
    final totalAmount = recentFeedings
        .where((feeding) => feeding.amount != null)
        .fold(0.0, (sum, feeding) => sum + (feeding.amount ?? 0));

    // Bebek yaşına göre ideal günlük miktar
    final idealDailyAmount = _getIdealDailyAmount(baby.ageInMonths);

    if (totalAmount < idealDailyAmount * 0.8) {
      final notification = FeedingNotificationModel.create(
        babyId: baby.id,
        type: FeedingNotificationType.amountWarning,
        title: 'Beslenme Miktarı Uyarısı',
        message:
            '${baby.name} bugün ortalamadan daha az beslendi. '
            'Beslenme miktarını kontrol etmek ister misiniz? 📊',
        metadata: {'totalAmount': totalAmount, 'idealAmount': idealDailyAmount},
      );

      await addNotification(notification);
    }
  }

  // Beslenme kilometre taşları
  Future<void> _checkFeedingMilestones(
    BabyModel baby,
    List<FeedingModel> allFeedings,
  ) async {
    // İlk 100 beslenme
    if (allFeedings.length >= 100 &&
        !await _hasMilestoneNotification(baby.id, 'first_100_feedings')) {
      final notification = FeedingNotificationModel.create(
        babyId: baby.id,
        type: FeedingNotificationType.milestone,
        title: '100. Beslenme! 🎉',
        message:
            '${baby.name} için 100. beslenme kaydı! '
            'Bu büyük bir başarı!',
        metadata: {
          'milestone': 'first_100_feedings',
          'totalFeedings': allFeedings.length,
        },
      );

      await addNotification(notification);
    }

    // 7 gün üst üste beslenme takibi
    final today = DateTime.now();
    final weekAgo = today.subtract(const Duration(days: 7));
    final weekFeedings =
        allFeedings
            .where((feeding) => feeding.timestamp.isAfter(weekAgo))
            .toList();

    if (weekFeedings.length >= 20 &&
        !await _hasMilestoneNotification(baby.id, 'week_tracking')) {
      final notification = FeedingNotificationModel.create(
        babyId: baby.id,
        type: FeedingNotificationType.milestone,
        title: 'Haftalık Takip Tamamlandı! 📅',
        message:
            '${baby.name} için 7 gün üst üste beslenme takibi yaptınız! '
            'Tutarlılık çok önemli!',
        metadata: {'milestone': 'week_tracking', 'daysTracked': 7},
      );

      await addNotification(notification);
    }
  }

  // Beslenme ipuçları
  Future<void> _generateFeedingTips(
    BabyModel baby,
    List<FeedingModel> recentFeedings,
  ) async {
    if (recentFeedings.isEmpty) return;

    // Son 3 günde ipucu verilmediyse
    final threeDaysAgo = DateTime.now().subtract(const Duration(days: 3));
    final recentTips = await getNotificationsForBaby(baby.id);
    final hasRecentTip = recentTips.any(
      (notification) =>
          notification.type == FeedingNotificationType.tip &&
          notification.createdAt.isAfter(threeDaysAgo),
    );

    if (!hasRecentTip) {
      final tips = [
        'Bebekler için beslenme rutini çok önemli. Her gün aynı saatlerde beslenme yapın.',
        'Beslenme öncesi bebeğinizin rahat olduğundan emin olun. Gaz çıkarma önemli.',
        'Bebek doyduğunda işaretler verir. Bu işaretleri öğrenmek beslenme kalitesini artırır.',
        'Gece beslenmeleri bebek büyüdükçe azalır. Bu normal bir gelişim sürecidir.',
        'Bebek beslenirken göz teması kurmak bağlanmayı güçlendirir.',
      ];

      final randomTip = tips[DateTime.now().millisecond % tips.length];

      final notification = FeedingNotificationModel.create(
        babyId: baby.id,
        type: FeedingNotificationType.tip,
        title: 'Beslenme İpucu 💡',
        message: randomTip,
        metadata: {'tipIndex': DateTime.now().millisecond % tips.length},
      );

      await addNotification(notification);
    }
  }

  // Bebek yaşına göre ideal beslenme aralığı
  Duration _getIdealFeedingInterval(int ageInMonths) {
    if (ageInMonths <= 1) return const Duration(hours: 2); // 0-1 ay: 2 saat
    if (ageInMonths <= 3) return const Duration(hours: 3); // 1-3 ay: 3 saat
    if (ageInMonths <= 6) return const Duration(hours: 4); // 3-6 ay: 4 saat
    if (ageInMonths <= 12) return const Duration(hours: 5); // 6-12 ay: 5 saat
    return const Duration(hours: 6); // 12+ ay: 6 saat
  }

  // Bebek yaşına göre ideal günlük miktar (ml)
  double _getIdealDailyAmount(int ageInMonths) {
    if (ageInMonths <= 1) return 600.0; // 0-1 ay: 600ml
    if (ageInMonths <= 3) return 800.0; // 1-3 ay: 800ml
    if (ageInMonths <= 6) return 1000.0; // 3-6 ay: 1000ml
    if (ageInMonths <= 12) return 1200.0; // 6-12 ay: 1200ml
    return 1400.0; // 12+ ay: 1400ml
  }

  // Bildirim ekleme
  Future<bool> addNotification(FeedingNotificationModel notification) async {
    try {
      await _notificationBox.put(notification.id, notification);
      return true;
    } catch (e) {
      print('Error adding feeding notification: $e');
      return false;
    }
  }

  // Bebek için bildirimleri getir
  Future<List<FeedingNotificationModel>> getNotificationsForBaby(
    String babyId,
  ) async {
    try {
      final notifications =
          _notificationBox.values
              .where((notification) => notification.babyId == babyId)
              .toList();

      notifications.sort((a, b) => b.createdAt.compareTo(a.createdAt));
      return notifications;
    } catch (e) {
      print('Error getting feeding notifications for baby: $e');
      return [];
    }
  }

  // Okunmamış bildirimleri getir
  Future<List<FeedingNotificationModel>> getUnreadNotifications(
    String babyId,
  ) async {
    try {
      final notifications = await getNotificationsForBaby(babyId);
      return notifications
          .where((notification) => !notification.isRead)
          .toList();
    } catch (e) {
      print('Error getting unread feeding notifications: $e');
      return [];
    }
  }

  // Bildirimi okundu olarak işaretle
  Future<bool> markAsRead(String notificationId) async {
    try {
      final notification = _notificationBox.get(notificationId);
      if (notification != null) {
        final updatedNotification = notification.copyWith(isRead: true);
        await _notificationBox.put(notificationId, updatedNotification);
        return true;
      }
      return false;
    } catch (e) {
      print('Error marking feeding notification as read: $e');
      return false;
    }
  }

  // Bildirimi sil
  Future<bool> deleteNotification(String notificationId) async {
    try {
      await _notificationBox.delete(notificationId);
      return true;
    } catch (e) {
      print('Error deleting feeding notification: $e');
      return false;
    }
  }

  // Kilometre taşı bildirimi var mı kontrol et
  Future<bool> _hasMilestoneNotification(
    String babyId,
    String milestone,
  ) async {
    try {
      final notifications = await getNotificationsForBaby(babyId);
      return notifications.any(
        (notification) =>
            notification.type == FeedingNotificationType.milestone &&
            notification.metadata?['milestone'] == milestone,
      );
    } catch (e) {
      return false;
    }
  }

  // Tüm bildirimleri temizle
  Future<bool> clearAllNotifications() async {
    try {
      await _notificationBox.clear();
      return true;
    } catch (e) {
      print('Error clearing all feeding notifications: $e');
      return false;
    }
  }
}

// Feeding Notification Model
class FeedingNotificationModel {
  final String id;
  final String babyId;
  final FeedingNotificationType type;
  final String title;
  final String message;
  final DateTime createdAt;
  final DateTime? scheduledFor;
  final bool isRead;
  final bool isActive;
  final Map<String, dynamic>? metadata;

  FeedingNotificationModel({
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

  factory FeedingNotificationModel.create({
    required String babyId,
    required FeedingNotificationType type,
    required String title,
    required String message,
    DateTime? scheduledFor,
    Map<String, dynamic>? metadata,
  }) {
    final now = DateTime.now();
    return FeedingNotificationModel(
      id: 'feeding_notification_${now.millisecondsSinceEpoch}',
      babyId: babyId,
      type: type,
      title: title,
      message: message,
      createdAt: now,
      scheduledFor: scheduledFor,
      metadata: metadata,
    );
  }

  FeedingNotificationModel copyWith({
    String? id,
    String? babyId,
    FeedingNotificationType? type,
    String? title,
    String? message,
    DateTime? createdAt,
    DateTime? scheduledFor,
    bool? isRead,
    bool? isActive,
    Map<String, dynamic>? metadata,
  }) {
    return FeedingNotificationModel(
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
      case FeedingNotificationType.frequencyWarning:
        return '⏰';
      case FeedingNotificationType.amountWarning:
        return '📊';
      case FeedingNotificationType.milestone:
        return '🏆';
      case FeedingNotificationType.tip:
        return '💡';
    }
  }

  @override
  String toString() {
    return 'FeedingNotificationModel{id: $id, type: $type, title: $title, isRead: $isRead}';
  }
}

enum FeedingNotificationType {
  frequencyWarning('Beslenme Sıklığı Uyarısı'),
  amountWarning('Beslenme Miktarı Uyarısı'),
  milestone('Beslenme Kilometre Taşı'),
  tip('Beslenme İpucu');

  const FeedingNotificationType(this.displayName);

  final String displayName;
}

// Hive Adapters
class FeedingNotificationModelAdapter
    extends TypeAdapter<FeedingNotificationModel> {
  @override
  final int typeId = 14;

  @override
  FeedingNotificationModel read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return FeedingNotificationModel(
      id: fields[0] as String,
      babyId: fields[1] as String,
      type: fields[2] as FeedingNotificationType,
      title: fields[3] as String,
      message: fields[4] as String,
      createdAt: fields[5] as DateTime,
      scheduledFor: fields[6] as DateTime?,
      isRead: fields[7] as bool,
      isActive: fields[8] as bool,
      metadata: (fields[9] as Map?)?.cast<String, dynamic>(),
    );
  }

  @override
  void write(BinaryWriter writer, FeedingNotificationModel obj) {
    writer
      ..writeByte(10)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.babyId)
      ..writeByte(2)
      ..write(obj.type)
      ..writeByte(3)
      ..write(obj.title)
      ..writeByte(4)
      ..write(obj.message)
      ..writeByte(5)
      ..write(obj.createdAt)
      ..writeByte(6)
      ..write(obj.scheduledFor)
      ..writeByte(7)
      ..write(obj.isRead)
      ..writeByte(8)
      ..write(obj.isActive)
      ..writeByte(9)
      ..write(obj.metadata);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is FeedingNotificationModelAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

class FeedingNotificationTypeAdapter
    extends TypeAdapter<FeedingNotificationType> {
  @override
  final int typeId = 15;

  @override
  FeedingNotificationType read(BinaryReader reader) {
    switch (reader.readByte()) {
      case 0:
        return FeedingNotificationType.frequencyWarning;
      case 1:
        return FeedingNotificationType.amountWarning;
      case 2:
        return FeedingNotificationType.milestone;
      case 3:
        return FeedingNotificationType.tip;
      default:
        return FeedingNotificationType.frequencyWarning;
    }
  }

  @override
  void write(BinaryWriter writer, FeedingNotificationType obj) {
    switch (obj) {
      case FeedingNotificationType.frequencyWarning:
        writer.writeByte(0);
        break;
      case FeedingNotificationType.amountWarning:
        writer.writeByte(1);
        break;
      case FeedingNotificationType.milestone:
        writer.writeByte(2);
        break;
      case FeedingNotificationType.tip:
        writer.writeByte(3);
        break;
    }
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is FeedingNotificationTypeAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
