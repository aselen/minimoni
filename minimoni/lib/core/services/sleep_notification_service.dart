import 'package:hive_flutter/hive_flutter.dart';
import '../models/sleep_model.dart';
import '../models/sleep_notification_model.dart';
import '../models/baby_model.dart';
import 'sleep_storage_service.dart';
import 'baby_storage_service.dart';

class SleepNotificationService {
  static const String _boxName = 'sleep_notifications';
  static Box<SleepNotificationModel>? _box;

  static SleepNotificationService? _instance;
  static SleepNotificationService get instance {
    _instance ??= SleepNotificationService._();
    return _instance!;
  }

  SleepNotificationService._();

  static Future<void> initialize() async {
    _box = Hive.box<SleepNotificationModel>(_boxName);
  }

  Box<SleepNotificationModel> get _notificationBox {
    if (_box == null || !_box!.isOpen) {
      _box = Hive.box<SleepNotificationModel>(_boxName);
      if (_box == null || !_box!.isOpen) {
        throw Exception('Notification box is not initialized');
      }
    }
    return _box!;
  }

  // Akıllı uyku analizi ve bildirim oluşturma
  Future<void> analyzeSleepAndCreateNotifications(String babyId) async {
    try {
      final babies = await BabyStorageService.instance.getAllBabies();
      final baby = babies.firstWhere(
        (b) => b.id == babyId,
        orElse: () => throw Exception('Baby not found'),
      );

      final sleepRecords = await SleepStorageService.instance
          .getSleepRecordsForBaby(babyId);
      if (sleepRecords.isEmpty) return;

      // Son 7 günlük uyku kayıtları
      final now = DateTime.now();
      final weekAgo = now.subtract(const Duration(days: 7));
      final recentSleeps =
          sleepRecords
              .where(
                (sleep) =>
                    sleep.startTime.isAfter(weekAgo) && sleep.endTime != null,
              )
              .toList();

      // Aktif uyku kontrolü
      final activeSleep = await SleepStorageService.instance
          .getActiveSleepRecord(babyId);

      // 1. Uzun süre uyanık kalma uyarısı
      await _checkLongAwakeTime(baby, activeSleep, recentSleeps);

      // 2. Uyku düzeni analizi
      await _analyzeSleepPattern(baby, recentSleeps);

      // 3. Uyku kilometre taşları
      await _checkSleepMilestones(baby, sleepRecords);

      // 4. Uyku ipuçları
      await _generateSleepTips(baby, recentSleeps);
    } catch (e) {
      print('Error analyzing sleep: $e');
    }
  }

  // Uzun süre uyanık kalma kontrolü
  Future<void> _checkLongAwakeTime(
    BabyModel baby,
    SleepModel? activeSleep,
    List<SleepModel> recentSleeps,
  ) async {
    if (activeSleep != null) return; // Şu anda uyuyor

    if (recentSleeps.isEmpty) return;

    final lastSleep = recentSleeps.first;
    final timeSinceLastSleep = DateTime.now().difference(lastSleep.endTime!);

    // Bebek yaşına göre maksimum uyanık kalma süreleri (saat)
    final maxAwakeHours = _getMaxAwakeHours(baby.ageInMonths);

    if (timeSinceLastSleep.inHours >= maxAwakeHours) {
      final notification = SleepNotificationModel.create(
        babyId: baby.id,
        type: NotificationType.sleepWarning,
        title: 'Uyku Zamanı!',
        message:
            '${baby.name} ${timeSinceLastSleep.inHours} saattir uyanık. '
            'Uykusu gelmiş olabilir. 😴',
        metadata: {
          'awakeHours': timeSinceLastSleep.inHours,
          'maxAwakeHours': maxAwakeHours,
        },
      );

      await addNotification(notification);
    }
  }

  // Uyku düzeni analizi
  Future<void> _analyzeSleepPattern(
    BabyModel baby,
    List<SleepModel> recentSleeps,
  ) async {
    if (recentSleeps.length < 3) return;

    // Günlük ortalama uyku süresi
    final totalSleepMinutes = recentSleeps
        .where((sleep) => sleep.duration != null)
        .fold(0, (sum, sleep) => sum + sleep.duration!.inMinutes);

    final averageSleepHours = totalSleepMinutes / recentSleeps.length / 60;

    // Bebek yaşına göre ideal uyku süreleri
    final idealSleepHours = _getIdealSleepHours(baby.ageInMonths);

    if (averageSleepHours < idealSleepHours * 0.8) {
      final notification = SleepNotificationModel.create(
        babyId: baby.id,
        type: NotificationType.sleepPattern,
        title: 'Uyku Düzeni Analizi',
        message:
            '${baby.name} son günlerde ortalamadan daha az uyuyor. '
            'Uyku düzenini kontrol etmek ister misiniz? 📊',
        metadata: {
          'averageSleepHours': averageSleepHours,
          'idealSleepHours': idealSleepHours,
        },
      );

      await addNotification(notification);
    }
  }

  // Uyku kilometre taşları
  Future<void> _checkSleepMilestones(
    BabyModel baby,
    List<SleepModel> allSleeps,
  ) async {
    // İlk gece uykusu (6+ saat)
    final nightSleeps =
        allSleeps
            .where(
              (sleep) =>
                  sleep.type == SleepType.nightSleep &&
                  sleep.duration != null &&
                  sleep.duration!.inHours >= 6,
            )
            .toList();

    if (nightSleeps.isNotEmpty &&
        !await _hasMilestoneNotification(baby.id, 'first_night_sleep')) {
      final notification = SleepNotificationModel.create(
        babyId: baby.id,
        type: NotificationType.sleepMilestone,
        title: 'İlk Gece Uykusu! 🏆',
        message:
            '${baby.name} ilk kez 6+ saat gece uykusu uyudu! '
            'Bu büyük bir gelişim!',
        metadata: {
          'milestone': 'first_night_sleep',
          'duration': nightSleeps.first.duration!.inHours,
        },
      );

      await addNotification(notification);
    }

    // 7 gün üst üste uyku takibi
    final today = DateTime.now();
    final weekAgo = today.subtract(const Duration(days: 7));
    final weekSleeps =
        allSleeps.where((sleep) => sleep.startTime.isAfter(weekAgo)).toList();

    if (weekSleeps.length >= 7 &&
        !await _hasMilestoneNotification(baby.id, 'week_tracking')) {
      final notification = SleepNotificationModel.create(
        babyId: baby.id,
        type: NotificationType.sleepMilestone,
        title: 'Haftalık Takip Tamamlandı! 📅',
        message:
            '${baby.name} için 7 gün üst üste uyku takibi yaptınız! '
            'Tutarlılık çok önemli!',
        metadata: {
          'milestone': 'week_tracking',
          'daysTracked': weekSleeps.length,
        },
      );

      await addNotification(notification);
    }
  }

  // Uyku ipuçları
  Future<void> _generateSleepTips(
    BabyModel baby,
    List<SleepModel> recentSleeps,
  ) async {
    if (recentSleeps.isEmpty) return;

    // Son 3 günde uyku ipucu verilmediyse
    final threeDaysAgo = DateTime.now().subtract(const Duration(days: 3));
    final recentTips = await getNotificationsForBaby(baby.id);
    final hasRecentTip = recentTips.any(
      (notification) =>
          notification.type == NotificationType.sleepTip &&
          notification.createdAt.isAfter(threeDaysAgo),
    );

    if (!hasRecentTip) {
      final tips = [
        'Bebekler için uyku rutini çok önemli. Her gece aynı saatte uykuya geçiş yapın.',
        'Uyku öncesi sakin aktiviteler (kitap okuma, ninni) uyku kalitesini artırır.',
        'Oda sıcaklığının 18-22°C arasında olması ideal uyku için önemli.',
        'Gündüz uykuları gece uykusunu destekler. Kısa gündüz uykularını atlamayın.',
        'Bebek uykuya dalarken hafif beyaz gürültü (fan sesi gibi) yardımcı olabilir.',
      ];

      final randomTip = tips[DateTime.now().millisecond % tips.length];

      final notification = SleepNotificationModel.create(
        babyId: baby.id,
        type: NotificationType.sleepTip,
        title: 'Uyku İpucu 💡',
        message: randomTip,
        metadata: {'tipIndex': DateTime.now().millisecond % tips.length},
      );

      await addNotification(notification);
    }
  }

  // Bebek yaşına göre maksimum uyanık kalma süresi
  int _getMaxAwakeHours(int ageInMonths) {
    if (ageInMonths <= 3) return 1; // 0-3 ay: 1 saat
    if (ageInMonths <= 6) return 2; // 3-6 ay: 2 saat
    if (ageInMonths <= 12) return 3; // 6-12 ay: 3 saat
    if (ageInMonths <= 18) return 4; // 12-18 ay: 4 saat
    return 5; // 18+ ay: 5 saat
  }

  // Bebek yaşına göre ideal uyku süresi
  double _getIdealSleepHours(int ageInMonths) {
    if (ageInMonths <= 3) return 16.0; // 0-3 ay: 16 saat
    if (ageInMonths <= 6) return 14.0; // 3-6 ay: 14 saat
    if (ageInMonths <= 12) return 13.0; // 6-12 ay: 13 saat
    if (ageInMonths <= 18) return 12.0; // 12-18 ay: 12 saat
    return 11.0; // 18+ ay: 11 saat
  }

  // Bildirim ekleme
  Future<bool> addNotification(SleepNotificationModel notification) async {
    try {
      await _notificationBox.put(notification.id, notification);
      return true;
    } catch (e) {
      print('Error adding notification: $e');
      return false;
    }
  }

  // Bebek için bildirimleri getir
  Future<List<SleepNotificationModel>> getNotificationsForBaby(
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
      print('Error getting notifications for baby: $e');
      return [];
    }
  }

  // Okunmamış bildirimleri getir
  Future<List<SleepNotificationModel>> getUnreadNotifications(
    String babyId,
  ) async {
    try {
      final notifications = await getNotificationsForBaby(babyId);
      return notifications
          .where((notification) => !notification.isRead)
          .toList();
    } catch (e) {
      print('Error getting unread notifications: $e');
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
      print('Error marking notification as read: $e');
      return false;
    }
  }

  // Bildirimi sil
  Future<bool> deleteNotification(String notificationId) async {
    try {
      await _notificationBox.delete(notificationId);
      return true;
    } catch (e) {
      print('Error deleting notification: $e');
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
            notification.type == NotificationType.sleepMilestone &&
            notification.metadata?['milestone'] == milestone,
      );
    } catch (e) {
      return false;
    }
  }

  // Tüm bildirimleri temizle (sadece test için)
  Future<bool> clearAllNotifications() async {
    try {
      await _notificationBox.clear();
      return true;
    } catch (e) {
      print('Error clearing all notifications: $e');
      return false;
    }
  }
}
