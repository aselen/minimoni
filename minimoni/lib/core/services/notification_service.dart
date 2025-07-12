import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:async';
import '../models/baby_model.dart';
import 'baby_storage_service.dart';

class NotificationService {
  static final NotificationService _instance = NotificationService._internal();
  factory NotificationService() => _instance;
  NotificationService._internal();

  static final FlutterLocalNotificationsPlugin _notifications =
      FlutterLocalNotificationsPlugin();
  static bool _isInitialized = false;

  // Bildirim kanalları
  static const AndroidNotificationChannel _generalChannel =
      AndroidNotificationChannel(
        'general_notifications',
        'Genel Bildirimler',
        description: 'Genel uygulama bildirimleri',
        importance: Importance.high,
      );

  static const AndroidNotificationChannel _feedingChannel =
      AndroidNotificationChannel(
        'feeding_notifications',
        'Beslenme Bildirimleri',
        description: 'Beslenme zamanı hatırlatmaları',
        importance: Importance.high,
      );

  static const AndroidNotificationChannel _sleepChannel =
      AndroidNotificationChannel(
        'sleep_notifications',
        'Uyku Bildirimleri',
        description: 'Uyku takibi ve hatırlatmaları',
        importance: Importance.high,
      );

  static const AndroidNotificationChannel _diaperChannel =
      AndroidNotificationChannel(
        'diaper_notifications',
        'Bez Değişimi Bildirimleri',
        description: 'Bez değişimi hatırlatmaları',
        importance: Importance.low,
      );

  static const AndroidNotificationChannel _growthChannel =
      AndroidNotificationChannel(
        'growth_notifications',
        'Büyüme Bildirimleri',
        description: 'Büyüme ve gelişim takibi',
        importance: Importance.low,
      );

  // Bildirim türleri
  static const int _feedingNotificationId = 1000;
  static const int _sleepNotificationId = 2000;
  static const int _diaperNotificationId = 3000;
  static const int _growthNotificationId = 4000;
  static const int _dailySummaryNotificationId = 5000;
  static const int _weeklyReportNotificationId = 6000;
  static const int _reminderNotificationId = 7000;

  // Zaman aralıkları
  static const Duration _feedingInterval = Duration(hours: 3);
  static const Duration _diaperInterval = Duration(hours: 2);
  static const Duration _sleepReminderInterval = Duration(hours: 4);

  static Future<void> initialize() async {
    if (_isInitialized) return;

    try {
      const AndroidInitializationSettings initializationSettingsAndroid =
          AndroidInitializationSettings('@mipmap/ic_launcher');

      const DarwinInitializationSettings initializationSettingsIOS =
          DarwinInitializationSettings(
            requestAlertPermission: true,
            requestBadgePermission: true,
            requestSoundPermission: true,
          );

      const InitializationSettings initializationSettings =
          InitializationSettings(
            android: initializationSettingsAndroid,
            iOS: initializationSettingsIOS,
          );

      await _notifications.initialize(
        initializationSettings,
        onDidReceiveNotificationResponse: _onNotificationTapped,
      );

      // Android kanallarını oluştur
      final androidPlugin =
          _notifications
              .resolvePlatformSpecificImplementation<
                AndroidFlutterLocalNotificationsPlugin
              >();

      if (androidPlugin != null) {
        await androidPlugin.createNotificationChannel(_generalChannel);
        await androidPlugin.createNotificationChannel(_feedingChannel);
        await androidPlugin.createNotificationChannel(_sleepChannel);
        await androidPlugin.createNotificationChannel(_diaperChannel);
        await androidPlugin.createNotificationChannel(_growthChannel);
      }

      _isInitialized = true;
      print('NotificationService initialized successfully');
    } catch (e) {
      print('Error initializing NotificationService: $e');
      // Plugin hatası durumunda bile devam et
      _isInitialized = true;
    }
  }

  static void _onNotificationTapped(NotificationResponse response) {
    // Bildirime tıklandığında yapılacak işlemler
    print('Bildirime tıklandı: ${response.payload}');
  }

  // Bildirim ayarlarını kontrol et
  static Future<bool> _isNotificationEnabled(String type) async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool('${type}_notifications') ?? true;
  }

  // Ses ayarlarını kontrol et
  static Future<bool> _isSoundEnabled() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool('sound_enabled') ?? true;
  }

  // Titreşim ayarlarını kontrol et
  static Future<bool> _isVibrationEnabled() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool('vibration_enabled') ?? true;
  }

  // Sessiz saatleri kontrol et
  static Future<bool> _isInQuietHours() async {
    final prefs = await SharedPreferences.getInstance();
    final quietHoursEnabled = prefs.getBool('quiet_hours_enabled') ?? false;

    if (!quietHoursEnabled) return false;

    final now = DateTime.now();
    final currentHour = now.hour;

    final quietStartHour = prefs.getInt('quiet_start_hour') ?? 22;
    final quietEndHour = prefs.getInt('quiet_end_hour') ?? 7;

    if (quietStartHour > quietEndHour) {
      // Gece yarısını kapsayan sessiz saatler (22:00 - 07:00)
      return currentHour >= quietStartHour || currentHour < quietEndHour;
    } else {
      // Normal sessiz saatler
      return currentHour >= quietStartHour && currentHour < quietEndHour;
    }
  }

  // Zaman hatırlatmalarını kontrol et
  static Future<bool> _isTimeReminderEnabled() async {
    final prefs = await SharedPreferences.getInstance();
    final now = DateTime.now();
    final currentHour = now.hour;

    if (currentHour >= 8 && currentHour < 12) {
      return prefs.getBool('morning_reminders') ?? true;
    } else if (currentHour >= 12 && currentHour < 17) {
      return prefs.getBool('afternoon_reminders') ?? true;
    } else if (currentHour >= 17 && currentHour < 21) {
      return prefs.getBool('evening_reminders') ?? true;
    } else {
      return prefs.getBool('night_reminders') ?? false;
    }
  }

  // Beslenme bildirimi gönder
  static Future<void> sendFeedingReminder(BabyModel baby) async {
    if (!_isInitialized) return;
    if (!await _isNotificationEnabled('feeding')) return;
    if (await _isInQuietHours()) return;
    if (!await _isTimeReminderEnabled()) return;

    try {
      final soundEnabled = await _isSoundEnabled();
      final vibrationEnabled = await _isVibrationEnabled();

      final AndroidNotificationDetails androidDetails =
          AndroidNotificationDetails(
            'feeding_notifications',
            'Beslenme Bildirimleri',
            channelDescription: 'Beslenme zamanı hatırlatmaları',
            importance: Importance.high,
            priority: Priority.high,
            sound:
                soundEnabled
                    ? const RawResourceAndroidNotificationSound(
                      'notification_sound',
                    )
                    : null,
            playSound: soundEnabled,
            enableVibration: vibrationEnabled,
            icon: '@mipmap/ic_launcher',
          );

      const DarwinNotificationDetails iOSDetails = DarwinNotificationDetails(
        sound: 'notification_sound.aiff',
        presentAlert: true,
        presentBadge: true,
        presentSound: true,
      );

      final NotificationDetails notificationDetails = NotificationDetails(
        android: androidDetails,
        iOS: iOSDetails,
      );

      await _notifications.show(
        _feedingNotificationId + baby.id.hashCode,
        '🍼 Beslenme Zamanı!',
        '${baby.name} için beslenme zamanı geldi. '
            'Son beslenmeden bu yana 3 saat geçti.',
        notificationDetails,
        payload: 'feeding_reminder_${baby.id}',
      );
    } catch (e) {
      print('Error sending feeding reminder: $e');
    }
  }

  // Uyku bildirimi gönder
  static Future<void> sendSleepReminder(BabyModel baby) async {
    if (!_isInitialized) return;
    if (!await _isNotificationEnabled('sleep')) return;
    if (await _isInQuietHours()) return;
    if (!await _isTimeReminderEnabled()) return;

    try {
      final soundEnabled = await _isSoundEnabled();
      final vibrationEnabled = await _isVibrationEnabled();

      final AndroidNotificationDetails androidDetails =
          AndroidNotificationDetails(
            'sleep_notifications',
            'Uyku Bildirimleri',
            channelDescription: 'Uyku takibi ve hatırlatmaları',
            importance: Importance.high,
            priority: Priority.high,
            sound:
                soundEnabled
                    ? const RawResourceAndroidNotificationSound(
                      'notification_sound',
                    )
                    : null,
            playSound: soundEnabled,
            enableVibration: vibrationEnabled,
            icon: '@mipmap/ic_launcher',
          );

      const DarwinNotificationDetails iOSDetails = DarwinNotificationDetails(
        sound: 'notification_sound.aiff',
        presentAlert: true,
        presentBadge: true,
        presentSound: true,
      );

      final NotificationDetails notificationDetails = NotificationDetails(
        android: androidDetails,
        iOS: iOSDetails,
      );

      await _notifications.show(
        _sleepNotificationId + baby.id.hashCode,
        '😴 Uyku Zamanı!',
        '${baby.name} uykusu gelmiş olabilir. '
            'Uyku takibini başlatmayı unutmayın.',
        notificationDetails,
        payload: 'sleep_reminder_${baby.id}',
      );
    } catch (e) {
      print('Error sending sleep reminder: $e');
    }
  }

  // Bez değişimi bildirimi gönder
  static Future<void> sendDiaperReminder(BabyModel baby) async {
    if (!_isInitialized) return;
    if (!await _isNotificationEnabled('diaper')) return;
    if (await _isInQuietHours()) return;
    if (!await _isTimeReminderEnabled()) return;

    try {
      final soundEnabled = await _isSoundEnabled();
      final vibrationEnabled = await _isVibrationEnabled();

      final AndroidNotificationDetails androidDetails =
          AndroidNotificationDetails(
            'diaper_notifications',
            'Bez Değişimi Bildirimleri',
            channelDescription: 'Bez değişimi hatırlatmaları',
            importance: Importance.low,
            priority: Priority.low,
            sound:
                soundEnabled
                    ? const RawResourceAndroidNotificationSound(
                      'notification_sound',
                    )
                    : null,
            playSound: soundEnabled,
            enableVibration: vibrationEnabled,
            icon: '@mipmap/ic_launcher',
          );

      const DarwinNotificationDetails iOSDetails = DarwinNotificationDetails(
        sound: 'notification_sound.aiff',
        presentAlert: true,
        presentBadge: true,
        presentSound: true,
      );

      final NotificationDetails notificationDetails = NotificationDetails(
        android: androidDetails,
        iOS: iOSDetails,
      );

      await _notifications.show(
        _diaperNotificationId + baby.id.hashCode,
        '👶 Bez Değişimi',
        '${baby.name} için bez değişimi zamanı geldi. '
            'Son değişimden bu yana 2 saat geçti.',
        notificationDetails,
        payload: 'diaper_reminder_${baby.id}',
      );
    } catch (e) {
      print('Error sending diaper reminder: $e');
    }
  }

  // Günlük özet bildirimi gönder
  static Future<void> sendDailySummary(BabyModel baby) async {
    if (!_isInitialized) return;
    if (!await _isNotificationEnabled('daily_summary')) return;
    if (await _isInQuietHours()) return;

    try {
      const AndroidNotificationDetails androidDetails =
          AndroidNotificationDetails(
            'general_notifications',
            'Genel Bildirimler',
            channelDescription: 'Genel uygulama bildirimleri',
            importance: Importance.low,
            priority: Priority.low,
            icon: '@mipmap/ic_launcher',
          );

      const DarwinNotificationDetails iOSDetails = DarwinNotificationDetails(
        presentAlert: true,
        presentBadge: true,
        presentSound: false,
      );

      const NotificationDetails notificationDetails = NotificationDetails(
        android: androidDetails,
        iOS: iOSDetails,
      );

      await _notifications.show(
        _dailySummaryNotificationId + baby.id.hashCode,
        '📊 Günlük Özet',
        '${baby.name} için bugünkü aktivitelerinizi görmek ister misiniz?',
        notificationDetails,
        payload: 'daily_summary_${baby.id}',
      );
    } catch (e) {
      print('Error sending daily summary: $e');
    }
  }

  // Haftalık rapor bildirimi gönder
  static Future<void> sendWeeklyReport(BabyModel baby) async {
    if (!_isInitialized) return;
    if (!await _isNotificationEnabled('weekly_report')) return;
    if (await _isInQuietHours()) return;

    try {
      const AndroidNotificationDetails androidDetails =
          AndroidNotificationDetails(
            'general_notifications',
            'Genel Bildirimler',
            channelDescription: 'Genel uygulama bildirimleri',
            importance: Importance.low,
            priority: Priority.low,
            icon: '@mipmap/ic_launcher',
          );

      const DarwinNotificationDetails iOSDetails = DarwinNotificationDetails(
        presentAlert: true,
        presentBadge: true,
        presentSound: false,
      );

      const NotificationDetails notificationDetails = NotificationDetails(
        android: androidDetails,
        iOS: iOSDetails,
      );

      await _notifications.show(
        _weeklyReportNotificationId + baby.id.hashCode,
        '📈 Haftalık Rapor',
        '${baby.name} için bu haftanın gelişim raporu hazır!',
        notificationDetails,
        payload: 'weekly_report_${baby.id}',
      );
    } catch (e) {
      print('Error sending weekly report: $e');
    }
  }

  // Zamanlanmış bildirimleri başlat
  static Future<void> startScheduledNotifications() async {
    if (!_isInitialized) return;

    try {
      // Her 3 saatte bir beslenme hatırlatması
      Timer.periodic(_feedingInterval, (timer) async {
        final babies = await BabyStorageService.instance.getAllBabies();
        for (final baby in babies) {
          await sendFeedingReminder(baby);
        }
      });

      // Her 2 saatte bir bez değişimi hatırlatması
      Timer.periodic(_diaperInterval, (timer) async {
        final babies = await BabyStorageService.instance.getAllBabies();
        for (final baby in babies) {
          await sendDiaperReminder(baby);
        }
      });

      // Her 4 saatte bir uyku hatırlatması
      Timer.periodic(_sleepReminderInterval, (timer) async {
        final babies = await BabyStorageService.instance.getAllBabies();
        for (final baby in babies) {
          await sendSleepReminder(baby);
        }
      });

      // Günlük özet (her gün saat 20:00'de)
      _scheduleDailySummary();

      // Haftalık rapor (her Pazar saat 10:00'da)
      _scheduleWeeklyReport();
    } catch (e) {
      print('Error starting scheduled notifications: $e');
    }
  }

  // Günlük özet zamanlaması
  static void _scheduleDailySummary() {
    try {
      final now = DateTime.now();
      final scheduledTime = DateTime(now.year, now.month, now.day, 20, 0);

      if (scheduledTime.isBefore(now)) {
        scheduledTime.add(const Duration(days: 1));
      }

      final delay = scheduledTime.difference(now);
      Timer(delay, () async {
        final babies = await BabyStorageService.instance.getAllBabies();
        for (final baby in babies) {
          await sendDailySummary(baby);
        }
        // Ertesi gün için tekrar zamanla
        _scheduleDailySummary();
      });
    } catch (e) {
      print('Error scheduling daily summary: $e');
    }
  }

  // Haftalık rapor zamanlaması
  static void _scheduleWeeklyReport() {
    try {
      final now = DateTime.now();
      final daysUntilSunday = (7 - now.weekday) % 7;
      final scheduledTime = DateTime(
        now.year,
        now.month,
        now.day + daysUntilSunday,
        10,
        0,
      );

      final delay = scheduledTime.difference(now);
      Timer(delay, () async {
        final babies = await BabyStorageService.instance.getAllBabies();
        for (final baby in babies) {
          await sendWeeklyReport(baby);
        }
        // Ertesi hafta için tekrar zamanla
        _scheduleWeeklyReport();
      });
    } catch (e) {
      print('Error scheduling weekly report: $e');
    }
  }

  // Tüm bildirimleri iptal et
  static Future<void> cancelAllNotifications() async {
    if (!_isInitialized) return;

    try {
      await _notifications.cancelAll();
    } catch (e) {
      print('Error canceling all notifications: $e');
    }
  }

  // Belirli bir bebeğin bildirimlerini iptal et
  static Future<void> cancelBabyNotifications(String babyId) async {
    if (!_isInitialized) return;

    try {
      await _notifications.cancel(_feedingNotificationId + babyId.hashCode);
      await _notifications.cancel(_sleepNotificationId + babyId.hashCode);
      await _notifications.cancel(_diaperNotificationId + babyId.hashCode);
      await _notifications.cancel(_growthNotificationId + babyId.hashCode);
      await _notifications.cancel(
        _dailySummaryNotificationId + babyId.hashCode,
      );
      await _notifications.cancel(
        _weeklyReportNotificationId + babyId.hashCode,
      );
    } catch (e) {
      print('Error canceling baby notifications: $e');
    }
  }
}
