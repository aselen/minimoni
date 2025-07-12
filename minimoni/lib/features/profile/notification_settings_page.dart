import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../core/constants/colors.dart';
import '../../shared/widgets/modern_header.dart';

class NotificationSettingsPage extends ConsumerStatefulWidget {
  const NotificationSettingsPage({super.key});

  @override
  ConsumerState<NotificationSettingsPage> createState() =>
      _NotificationSettingsPageState();
}

class _NotificationSettingsPageState
    extends ConsumerState<NotificationSettingsPage> {
  bool _feedingNotifications = true;
  bool _sleepNotifications = true;
  bool _growthNotifications = true;
  bool _diaperNotifications = true;
  bool _reminderNotifications = true;
  bool _dailySummaryNotifications = true;
  bool _weeklyReportNotifications = true;
  bool _smartNotifications = true;

  // Zaman ayarları
  bool _morningReminders = true;
  bool _afternoonReminders = true;
  bool _eveningReminders = true;
  bool _nightReminders = false;

  // Ses ve titreşim
  bool _soundEnabled = true;
  bool _vibrationEnabled = true;
  bool _quietHoursEnabled = false;
  TimeOfDay _quietStartTime = const TimeOfDay(hour: 22, minute: 0);
  TimeOfDay _quietEndTime = const TimeOfDay(hour: 7, minute: 0);

  @override
  void initState() {
    super.initState();
    _loadNotificationSettings();
  }

  Future<void> _loadNotificationSettings() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _feedingNotifications = prefs.getBool('feeding_notifications') ?? true;
      _sleepNotifications = prefs.getBool('sleep_notifications') ?? true;
      _growthNotifications = prefs.getBool('growth_notifications') ?? true;
      _diaperNotifications = prefs.getBool('diaper_notifications') ?? true;
      _reminderNotifications = prefs.getBool('reminder_notifications') ?? true;
      _dailySummaryNotifications =
          prefs.getBool('daily_summary_notifications') ?? true;
      _weeklyReportNotifications =
          prefs.getBool('weekly_report_notifications') ?? true;
      _smartNotifications = prefs.getBool('smart_notifications') ?? true;

      _morningReminders = prefs.getBool('morning_reminders') ?? true;
      _afternoonReminders = prefs.getBool('afternoon_reminders') ?? true;
      _eveningReminders = prefs.getBool('evening_reminders') ?? true;
      _nightReminders = prefs.getBool('night_reminders') ?? false;

      _soundEnabled = prefs.getBool('sound_enabled') ?? true;
      _vibrationEnabled = prefs.getBool('vibration_enabled') ?? true;
      _quietHoursEnabled = prefs.getBool('quiet_hours_enabled') ?? false;

      final quietStartHour = prefs.getInt('quiet_start_hour') ?? 22;
      final quietStartMinute = prefs.getInt('quiet_start_minute') ?? 0;
      _quietStartTime = TimeOfDay(
        hour: quietStartHour,
        minute: quietStartMinute,
      );

      final quietEndHour = prefs.getInt('quiet_end_hour') ?? 7;
      final quietEndMinute = prefs.getInt('quiet_end_minute') ?? 0;
      _quietEndTime = TimeOfDay(hour: quietEndHour, minute: quietEndMinute);
    });
  }

  Future<void> _saveNotificationSettings() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('feeding_notifications', _feedingNotifications);
    await prefs.setBool('sleep_notifications', _sleepNotifications);
    await prefs.setBool('growth_notifications', _growthNotifications);
    await prefs.setBool('diaper_notifications', _diaperNotifications);
    await prefs.setBool('reminder_notifications', _reminderNotifications);
    await prefs.setBool(
      'daily_summary_notifications',
      _dailySummaryNotifications,
    );
    await prefs.setBool(
      'weekly_report_notifications',
      _weeklyReportNotifications,
    );
    await prefs.setBool('smart_notifications', _smartNotifications);

    await prefs.setBool('morning_reminders', _morningReminders);
    await prefs.setBool('afternoon_reminders', _afternoonReminders);
    await prefs.setBool('evening_reminders', _eveningReminders);
    await prefs.setBool('night_reminders', _nightReminders);

    await prefs.setBool('sound_enabled', _soundEnabled);
    await prefs.setBool('vibration_enabled', _vibrationEnabled);
    await prefs.setBool('quiet_hours_enabled', _quietHoursEnabled);

    await prefs.setInt('quiet_start_hour', _quietStartTime.hour);
    await prefs.setInt('quiet_start_minute', _quietStartTime.minute);
    await prefs.setInt('quiet_end_hour', _quietEndTime.hour);
    await prefs.setInt('quiet_end_minute', _quietEndTime.minute);
  }

  @override
  Widget build(BuildContext context) {
    print('NotificationSettingsPage build method called'); // Debug print
    return Scaffold(
      backgroundColor: Colors.grey.shade50,
      body: CustomScrollView(
        slivers: [
          ModernHeader(
            title: 'Bildirim Ayarları',
            subtitle: 'Bildirim tercihlerinizi yönetin',
            emoji: '🔔',
            showBackButton: true,
            isDashboard: false,
          ),
          SliverPadding(
            padding: const EdgeInsets.all(20),
            sliver: SliverList(
              delegate: SliverChildListDelegate([
                _buildNotificationTypesSection(),
                const SizedBox(height: 20),
                _buildTimeRemindersSection(),
                const SizedBox(height: 20),
                _buildSoundVibrationSection(),
                const SizedBox(height: 20),
                _buildQuietHoursSection(),
                const SizedBox(height: 50),
              ]),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNotificationTypesSection() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: AppColors.primaryPink.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(
                  Icons.notifications_active,
                  color: AppColors.primaryPink,
                  size: 20,
                ),
              ),
              const SizedBox(width: 12),
              Text(
                'Bildirim Türleri',
                style: GoogleFonts.inter(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textDark,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          _buildNotificationSwitch(
            'Beslenme Bildirimleri',
            'Beslenme zamanı hatırlatmaları',
            Icons.restaurant,
            _feedingNotifications,
            (value) {
              setState(() {
                _feedingNotifications = value;
              });
              _saveNotificationSettings();
            },
          ),
          _buildNotificationSwitch(
            'Uyku Bildirimleri',
            'Uyku takibi ve hatırlatmaları',
            Icons.bedtime,
            _sleepNotifications,
            (value) {
              setState(() {
                _sleepNotifications = value;
              });
              _saveNotificationSettings();
            },
          ),
          _buildNotificationSwitch(
            'Büyüme Bildirimleri',
            'Büyüme ve gelişim takibi',
            Icons.trending_up,
            _growthNotifications,
            (value) {
              setState(() {
                _growthNotifications = value;
              });
              _saveNotificationSettings();
            },
          ),
          _buildNotificationSwitch(
            'Bez Değişimi',
            'Bez değişimi hatırlatmaları',
            Icons.baby_changing_station,
            _diaperNotifications,
            (value) {
              setState(() {
                _diaperNotifications = value;
              });
              _saveNotificationSettings();
            },
          ),
          _buildNotificationSwitch(
            'Genel Hatırlatmalar',
            'Günlük aktivite hatırlatmaları',
            Icons.schedule,
            _reminderNotifications,
            (value) {
              setState(() {
                _reminderNotifications = value;
              });
              _saveNotificationSettings();
            },
          ),
          _buildNotificationSwitch(
            'Günlük Özet',
            'Günlük aktivite özeti',
            Icons.summarize,
            _dailySummaryNotifications,
            (value) {
              setState(() {
                _dailySummaryNotifications = value;
              });
              _saveNotificationSettings();
            },
          ),
          _buildNotificationSwitch(
            'Haftalık Rapor',
            'Haftalık gelişim raporu',
            Icons.assessment,
            _weeklyReportNotifications,
            (value) {
              setState(() {
                _weeklyReportNotifications = value;
              });
              _saveNotificationSettings();
            },
          ),
          _buildNotificationSwitch(
            'Akıllı Bildirimler',
            'AI destekli öneriler',
            Icons.psychology,
            _smartNotifications,
            (value) {
              setState(() {
                _smartNotifications = value;
              });
              _saveNotificationSettings();
            },
          ),
        ],
      ),
    );
  }

  Widget _buildTimeRemindersSection() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.blue.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(
                  Icons.access_time,
                  color: Colors.blue,
                  size: 20,
                ),
              ),
              const SizedBox(width: 12),
              Text(
                'Zaman Hatırlatmaları',
                style: GoogleFonts.inter(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textDark,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          _buildNotificationSwitch(
            'Sabah Hatırlatmaları',
            '08:00 - 12:00 arası',
            Icons.wb_sunny,
            _morningReminders,
            (value) {
              setState(() {
                _morningReminders = value;
              });
              _saveNotificationSettings();
            },
          ),
          _buildNotificationSwitch(
            'Öğleden Sonra',
            '12:00 - 17:00 arası',
            Icons.wb_sunny_outlined,
            _afternoonReminders,
            (value) {
              setState(() {
                _afternoonReminders = value;
              });
              _saveNotificationSettings();
            },
          ),
          _buildNotificationSwitch(
            'Akşam Hatırlatmaları',
            '17:00 - 21:00 arası',
            Icons.nights_stay,
            _eveningReminders,
            (value) {
              setState(() {
                _eveningReminders = value;
              });
              _saveNotificationSettings();
            },
          ),
          _buildNotificationSwitch(
            'Gece Hatırlatmaları',
            '21:00 - 08:00 arası',
            Icons.bedtime,
            _nightReminders,
            (value) {
              setState(() {
                _nightReminders = value;
              });
              _saveNotificationSettings();
            },
          ),
        ],
      ),
    );
  }

  Widget _buildSoundVibrationSection() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.green.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(
                  Icons.volume_up,
                  color: Colors.green,
                  size: 20,
                ),
              ),
              const SizedBox(width: 12),
              Text(
                'Ses ve Titreşim',
                style: GoogleFonts.inter(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textDark,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          _buildNotificationSwitch(
            'Ses',
            'Bildirim sesleri',
            Icons.volume_up,
            _soundEnabled,
            (value) {
              setState(() {
                _soundEnabled = value;
              });
              _saveNotificationSettings();
            },
          ),
          _buildNotificationSwitch(
            'Titreşim',
            'Bildirim titreşimleri',
            Icons.vibration,
            _vibrationEnabled,
            (value) {
              setState(() {
                _vibrationEnabled = value;
              });
              _saveNotificationSettings();
            },
          ),
        ],
      ),
    );
  }

  Widget _buildQuietHoursSection() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.orange.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(
                  Icons.do_not_disturb,
                  color: Colors.orange,
                  size: 20,
                ),
              ),
              const SizedBox(width: 12),
              Text(
                'Sessiz Saatler',
                style: GoogleFonts.inter(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textDark,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          _buildNotificationSwitch(
            'Sessiz Saatler Aktif',
            'Belirli saatlerde bildirimleri sustur',
            Icons.do_not_disturb,
            _quietHoursEnabled,
            (value) {
              setState(() {
                _quietHoursEnabled = value;
              });
              _saveNotificationSettings();
            },
          ),
          if (_quietHoursEnabled) ...[
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: _buildTimeSelector('Başlangıç', _quietStartTime, (
                    time,
                  ) {
                    setState(() {
                      _quietStartTime = time;
                    });
                    _saveNotificationSettings();
                  }),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: _buildTimeSelector('Bitiş', _quietEndTime, (time) {
                    setState(() {
                      _quietEndTime = time;
                    });
                    _saveNotificationSettings();
                  }),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildNotificationSwitch(
    String title,
    String subtitle,
    IconData icon,
    bool value,
    ValueChanged<bool> onChanged,
  ) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: AppColors.primaryPink.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(icon, color: AppColors.primaryPink, size: 20),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: GoogleFonts.inter(
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                    color: AppColors.textDark,
                  ),
                ),
                Text(
                  subtitle,
                  style: GoogleFonts.inter(
                    fontSize: 12,
                    color: AppColors.textLight,
                  ),
                ),
              ],
            ),
          ),
          Switch(
            value: value,
            onChanged: onChanged,
            activeColor: AppColors.primaryPink,
          ),
        ],
      ),
    );
  }

  Widget _buildTimeSelector(
    String title,
    TimeOfDay time,
    ValueChanged<TimeOfDay> onChanged,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: GoogleFonts.inter(
            fontSize: 14,
            fontWeight: FontWeight.w500,
            color: AppColors.textDark,
          ),
        ),
        const SizedBox(height: 8),
        InkWell(
          onTap: () async {
            final newTime = await showTimePicker(
              context: context,
              initialTime: time,
            );
            if (newTime != null) {
              onChanged(newTime);
            }
          },
          child: Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.grey.shade100,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: Colors.grey.shade300),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  '${time.hour.toString().padLeft(2, '0')}:${time.minute.toString().padLeft(2, '0')}',
                  style: GoogleFonts.inter(
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                    color: AppColors.textDark,
                  ),
                ),
                const Icon(Icons.access_time, size: 20),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
