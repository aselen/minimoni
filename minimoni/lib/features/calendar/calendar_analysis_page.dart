import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:table_calendar/table_calendar.dart';
import '../../core/constants/colors.dart';
import '../../core/services/baby_storage_service.dart';
import '../../core/services/feeding_storage_service.dart';
import '../../core/services/sleep_storage_service.dart';
import '../../core/services/diaper_change_storage_service.dart';
import '../../core/services/memory_storage_service.dart';
import '../../core/services/growth_storage_service.dart';
import '../../core/models/feeding_model.dart';
import '../../core/models/sleep_model.dart';
import '../../core/models/diaper_change_model.dart';
import '../../core/models/memory_model.dart';
import '../../core/models/growth_model.dart';

class CalendarAnalysisPage extends ConsumerStatefulWidget {
  const CalendarAnalysisPage({super.key});

  @override
  ConsumerState<CalendarAnalysisPage> createState() =>
      _CalendarAnalysisPageState();
}

class _CalendarAnalysisPageState extends ConsumerState<CalendarAnalysisPage> {
  DateTime _focusedDay = DateTime.now();
  DateTime? _selectedDay;
  Map<DateTime, List<dynamic>> _events = {};
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _selectedDay = DateTime.now();
    _loadCalendarData();
  }

  Future<void> _loadCalendarData() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final baby = await BabyStorageService.instance.getActiveBaby();
      if (baby == null) {
        setState(() {
          _isLoading = false;
        });
        return;
      }

      // Son 3 ayın verilerini yükle
      final now = DateTime.now();
      final startDate = DateTime(now.year, now.month - 3, 1);
      final endDate = DateTime(now.year, now.month + 1, 0);

      // Tüm verileri paralel olarak yükle
      final futures = await Future.wait([
        FeedingStorageService.instance.getFeedingsForBaby(baby.id),
        SleepStorageService.instance.getSleepRecordsForBaby(baby.id),
        DiaperChangeStorageService.instance.getDiaperChangesForBaby(baby.id),
        MemoryStorageService.instance.getMemoriesForBaby(baby.id),
        Future.value(GrowthStorageService.getGrowthRecordsByBaby(baby.id)),
      ]);

      final feedings = futures[0] as List<FeedingModel>;
      final sleepRecords = futures[1] as List<SleepModel>;
      final diaperChanges = futures[2] as List<DiaperChangeModel>;
      final memories = futures[3] as List<MemoryModel>;
      final growthRecords = futures[4] as List<GrowthModel>;

      // Takvim verilerini organize et
      final events = <DateTime, List<dynamic>>{};

      // Beslenme verilerini ekle
      for (final feeding in feedings) {
        if (feeding.timestamp.isAfter(startDate) &&
            feeding.timestamp.isBefore(endDate)) {
          final date = DateTime(
            feeding.timestamp.year,
            feeding.timestamp.month,
            feeding.timestamp.day,
          );
          events[date] = [...(events[date] ?? []), feeding];
        }
      }

      // Uyku verilerini ekle
      for (final sleep in sleepRecords) {
        if (sleep.startTime.isAfter(startDate) &&
            sleep.startTime.isBefore(endDate)) {
          final date = DateTime(
            sleep.startTime.year,
            sleep.startTime.month,
            sleep.startTime.day,
          );
          events[date] = [...(events[date] ?? []), sleep];
        }
      }

      // Alt değişimi verilerini ekle
      for (final diaper in diaperChanges) {
        if (diaper.timestamp.isAfter(startDate) &&
            diaper.timestamp.isBefore(endDate)) {
          final date = DateTime(
            diaper.timestamp.year,
            diaper.timestamp.month,
            diaper.timestamp.day,
          );
          events[date] = [...(events[date] ?? []), diaper];
        }
      }

      // Anı verilerini ekle
      for (final memory in memories) {
        if (memory.timestamp.isAfter(startDate) &&
            memory.timestamp.isBefore(endDate)) {
          final date = DateTime(
            memory.timestamp.year,
            memory.timestamp.month,
            memory.timestamp.day,
          );
          events[date] = [...(events[date] ?? []), memory];
        }
      }

      // Gelişim verilerini ekle
      for (final growth in growthRecords) {
        if (growth.measurementDate.isAfter(startDate) &&
            growth.measurementDate.isBefore(endDate)) {
          final date = DateTime(
            growth.measurementDate.year,
            growth.measurementDate.month,
            growth.measurementDate.day,
          );
          events[date] = [...(events[date] ?? []), growth];
        }
      }

      setState(() {
        _events = events;
        _isLoading = false;
      });
    } catch (e) {
      print('Error loading calendar data: $e');
      setState(() {
        _isLoading = false;
      });
    }
  }

  List<dynamic> _getEventsForDay(DateTime day) {
    return _events[DateTime(day.year, day.month, day.day)] ?? [];
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.softPink,
      appBar: AppBar(
        title: const Text(
          'Takvim Analizi',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.w600,
            color: AppColors.textDark,
          ),
        ),
        backgroundColor: Colors.white,
        elevation: 0,
        iconTheme: const IconThemeData(color: AppColors.textDark),
      ),
      body:
          _isLoading
              ? const Center(child: CircularProgressIndicator())
              : SingleChildScrollView(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Header
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(16),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.05),
                            blurRadius: 10,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: Row(
                        children: [
                          Container(
                            width: 50,
                            height: 50,
                            decoration: BoxDecoration(
                              color: AppColors.primaryPink.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(25),
                            ),
                            child: const Icon(
                              Icons.calendar_today,
                              color: AppColors.primaryPink,
                              size: 24,
                            ),
                          ),
                          const SizedBox(width: 16),
                          const Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Günlük Takip',
                                  style: TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.w600,
                                    color: AppColors.textDark,
                                  ),
                                ),
                                SizedBox(height: 4),
                                Text(
                                  'Tüm aktivitelerinizi takvim üzerinde görün',
                                  style: TextStyle(
                                    fontSize: 14,
                                    color: AppColors.textMedium,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 24),

                    // Legend
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(16),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.05),
                            blurRadius: 10,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Renkli Göstergeler',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                              color: AppColors.textDark,
                            ),
                          ),
                          const SizedBox(height: 12),
                          Wrap(
                            spacing: 16,
                            runSpacing: 8,
                            children: [
                              _buildLegendItem(
                                '🍼',
                                'Beslenme',
                                AppColors.pastelBlue,
                              ),
                              _buildLegendItem(
                                '😴',
                                'Uyku',
                                AppColors.pastelLavender,
                              ),
                              _buildLegendItem(
                                '🧷',
                                'Alt Değişimi',
                                AppColors.pastelGreen,
                              ),
                              _buildLegendItem(
                                '📸',
                                'Anı',
                                AppColors.pastelPink,
                              ),
                              _buildLegendItem(
                                '📏',
                                'Gelişim',
                                AppColors.pastelYellow,
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 24),

                    // Calendar
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(16),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.05),
                            blurRadius: 10,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: TableCalendar<dynamic>(
                        firstDay: DateTime.utc(2020, 1, 1),
                        lastDay: DateTime.utc(2030, 12, 31),
                        focusedDay: _focusedDay,
                        selectedDayPredicate: (day) {
                          return isSameDay(_selectedDay, day);
                        },
                        eventLoader: _getEventsForDay,
                        startingDayOfWeek: StartingDayOfWeek.monday,
                        locale: 'tr_TR',
                        calendarStyle: CalendarStyle(
                          outsideDaysVisible: false,
                          weekendTextStyle: const TextStyle(
                            color: AppColors.textMedium,
                          ),
                          holidayTextStyle: const TextStyle(
                            color: AppColors.textMedium,
                          ),
                          selectedDecoration: BoxDecoration(
                            color: AppColors.primaryPink,
                            shape: BoxShape.circle,
                          ),
                          todayDecoration: BoxDecoration(
                            color: AppColors.primaryPink.withOpacity(0.3),
                            shape: BoxShape.circle,
                          ),
                          markersMaxCount: 3,
                          markerDecoration: BoxDecoration(
                            color: AppColors.pastelBlue,
                            shape: BoxShape.circle,
                          ),
                        ),
                        headerStyle: const HeaderStyle(
                          formatButtonVisible: false,
                          titleCentered: true,
                          titleTextStyle: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            color: AppColors.textDark,
                          ),
                        ),
                        onDaySelected: (selectedDay, focusedDay) {
                          setState(() {
                            _selectedDay = selectedDay;
                            _focusedDay = focusedDay;
                          });
                        },
                        onPageChanged: (focusedDay) {
                          _focusedDay = focusedDay;
                        },
                        calendarBuilders: CalendarBuilders(
                          markerBuilder: (context, date, events) {
                            if (events.isNotEmpty) {
                              return Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children:
                                    events.take(3).map((event) {
                                      Color color = Colors.grey;
                                      if (event is FeedingModel)
                                        color = AppColors.pastelBlue;
                                      else if (event is SleepModel)
                                        color = AppColors.pastelLavender;
                                      else if (event is DiaperChangeModel)
                                        color = AppColors.pastelGreen;
                                      else if (event is MemoryModel)
                                        color = AppColors.pastelPink;
                                      else if (event is GrowthModel)
                                        color = AppColors.pastelYellow;

                                      return Container(
                                        width: 6,
                                        height: 6,
                                        margin: const EdgeInsets.symmetric(
                                          horizontal: 1,
                                        ),
                                        decoration: BoxDecoration(
                                          color: color,
                                          shape: BoxShape.circle,
                                        ),
                                      );
                                    }).toList(),
                              );
                            }
                            return null;
                          },
                        ),
                      ),
                    ),

                    const SizedBox(height: 24),

                    // Selected Day Details
                    if (_selectedDay != null)
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(20),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(16),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.05),
                              blurRadius: 10,
                              offset: const Offset(0, 2),
                            ),
                          ],
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              '${_selectedDay!.day}/${_selectedDay!.month}/${_selectedDay!.year} - Günlük Özet',
                              style: const TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.w600,
                                color: AppColors.textDark,
                              ),
                            ),
                            const SizedBox(height: 16),
                            _buildDayDetails(_selectedDay!),
                          ],
                        ),
                      ),

                    const SizedBox(height: 20),
                  ],
                ),
              ),
    );
  }

  Widget _buildLegendItem(String emoji, String label, Color color) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 12,
          height: 12,
          decoration: BoxDecoration(color: color, shape: BoxShape.circle),
        ),
        const SizedBox(width: 6),
        Text(emoji, style: const TextStyle(fontSize: 14)),
        const SizedBox(width: 4),
        Text(
          label,
          style: const TextStyle(fontSize: 12, color: AppColors.textMedium),
        ),
      ],
    );
  }

  Widget _buildDayDetails(DateTime day) {
    final events = _getEventsForDay(day);

    if (events.isEmpty) {
      return const Center(
        child: Padding(
          padding: EdgeInsets.all(20),
          child: Text(
            'Bu gün için kayıt bulunmuyor',
            style: TextStyle(color: AppColors.textMedium, fontSize: 14),
          ),
        ),
      );
    }

    // Verileri kategorilere ayır
    final feedings = events.whereType<FeedingModel>().toList();
    final sleepRecords = events.whereType<SleepModel>().toList();
    final diaperChanges = events.whereType<DiaperChangeModel>().toList();
    final memories = events.whereType<MemoryModel>().toList();
    final growthRecords = events.whereType<GrowthModel>().toList();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Beslenme
        if (feedings.isNotEmpty) ...[
          _buildCategoryHeader('🍼', 'Beslenme', feedings.length),
          const SizedBox(height: 8),
          ...feedings.map((feeding) => _buildFeedingItem(feeding)),
          const SizedBox(height: 16),
        ],

        // Uyku
        if (sleepRecords.isNotEmpty) ...[
          _buildCategoryHeader('😴', 'Uyku', sleepRecords.length),
          const SizedBox(height: 8),
          ...sleepRecords.map((sleep) => _buildSleepItem(sleep)),
          const SizedBox(height: 16),
        ],

        // Alt Değişimi
        if (diaperChanges.isNotEmpty) ...[
          _buildCategoryHeader('🧷', 'Alt Değişimi', diaperChanges.length),
          const SizedBox(height: 8),
          ...diaperChanges.map((diaper) => _buildDiaperItem(diaper)),
          const SizedBox(height: 16),
        ],

        // Anılar
        if (memories.isNotEmpty) ...[
          _buildCategoryHeader('📸', 'Anılar', memories.length),
          const SizedBox(height: 8),
          ...memories.map((memory) => _buildMemoryItem(memory)),
          const SizedBox(height: 16),
        ],

        // Gelişim
        if (growthRecords.isNotEmpty) ...[
          _buildCategoryHeader('📏', 'Gelişim', growthRecords.length),
          const SizedBox(height: 8),
          ...growthRecords.map((growth) => _buildGrowthItem(growth)),
        ],
      ],
    );
  }

  Widget _buildCategoryHeader(String emoji, String title, int count) {
    return Row(
      children: [
        Text(emoji, style: const TextStyle(fontSize: 16)),
        const SizedBox(width: 8),
        Text(
          '$title ($count)',
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: AppColors.textDark,
          ),
        ),
      ],
    );
  }

  Widget _buildFeedingItem(FeedingModel feeding) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.pastelBlue.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        children: [
          Text(
            '${feeding.timestamp.hour.toString().padLeft(2, '0')}:${feeding.timestamp.minute.toString().padLeft(2, '0')}',
            style: const TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: AppColors.textDark,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              '${feeding.amount}ml ${feeding.type}',
              style: const TextStyle(fontSize: 12, color: AppColors.textMedium),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSleepItem(SleepModel sleep) {
    final duration =
        sleep.endTime?.difference(sleep.startTime) ?? Duration.zero;
    final hours = duration.inHours;
    final minutes = duration.inMinutes % 60;

    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.pastelLavender.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        children: [
          Text(
            '${sleep.startTime.hour.toString().padLeft(2, '0')}:${sleep.startTime.minute.toString().padLeft(2, '0')}',
            style: const TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: AppColors.textDark,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              sleep.endTime != null
                  ? '${hours}s ${minutes}dk ${sleep.type.displayName}'
                  : '${sleep.type.displayName} (Devam ediyor)',
              style: const TextStyle(fontSize: 12, color: AppColors.textMedium),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDiaperItem(DiaperChangeModel diaper) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.pastelGreen.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        children: [
          Text(
            '${diaper.timestamp.hour.toString().padLeft(2, '0')}:${diaper.timestamp.minute.toString().padLeft(2, '0')}',
            style: const TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: AppColors.textDark,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              diaper.type.displayName,
              style: const TextStyle(fontSize: 12, color: AppColors.textMedium),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMemoryItem(MemoryModel memory) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.pastelPink.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        children: [
          Text(
            '${memory.timestamp.hour.toString().padLeft(2, '0')}:${memory.timestamp.minute.toString().padLeft(2, '0')}',
            style: const TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: AppColors.textDark,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              memory.title,
              style: const TextStyle(fontSize: 12, color: AppColors.textMedium),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildGrowthItem(GrowthModel growth) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.pastelYellow.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        children: [
          Text(
            '${growth.measurementDate.hour.toString().padLeft(2, '0')}:${growth.measurementDate.minute.toString().padLeft(2, '0')}',
            style: const TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: AppColors.textDark,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              'Boy: ${growth.height}cm, Kilo: ${growth.weight}kg',
              style: const TextStyle(fontSize: 12, color: AppColors.textMedium),
            ),
          ),
        ],
      ),
    );
  }
}
