import 'package:hive_flutter/hive_flutter.dart';
import '../models/sleep_model.dart';

class SleepStorageService {
  static const String _boxName = 'sleep_records';
  static Box<SleepModel>? _box;

  static SleepStorageService? _instance;
  static SleepStorageService get instance {
    _instance ??= SleepStorageService._();
    return _instance!;
  }

  SleepStorageService._();

  static Future<void> initialize() async {
    _box = Hive.box<SleepModel>(_boxName);
  }

  Box<SleepModel> get _sleepBox {
    if (_box == null || !_box!.isOpen) {
      // Fallback to get box if not initialized
      _box = Hive.box<SleepModel>(_boxName);
      if (_box == null || !_box!.isOpen) {
        throw Exception('Sleep box is not initialized');
      }
    }
    return _box!;
  }

  // Uyku kaydı ekleme
  Future<bool> addSleepRecord(SleepModel sleep) async {
    try {
      await _sleepBox.put(sleep.id, sleep);
      return true;
    } catch (e) {
      print('Error adding sleep record: $e');
      return false;
    }
  }

  // Uyku kaydı güncelleme
  Future<bool> updateSleepRecord(SleepModel sleep) async {
    try {
      final updatedSleep = sleep.copyWith(updatedAt: DateTime.now());
      await _sleepBox.put(sleep.id, updatedSleep);
      return true;
    } catch (e) {
      print('Error updating sleep record: $e');
      return false;
    }
  }

  // Aktif uyku kaydını sonlandırma
  Future<bool> endSleepRecord(String sleepId, DateTime endTime) async {
    try {
      final sleep = _sleepBox.get(sleepId);
      if (sleep != null) {
        final updatedSleep = sleep.copyWith(
          endTime: endTime,
          updatedAt: DateTime.now(),
        );
        await _sleepBox.put(sleepId, updatedSleep);
        return true;
      }
      return false;
    } catch (e) {
      print('Error ending sleep record: $e');
      return false;
    }
  }

  // Belirli bebeğin uyku kayıtlarını getir
  Future<List<SleepModel>> getSleepRecordsForBaby(
    String babyId, {
    int? limit,
  }) async {
    try {
      final sleepRecords =
          _sleepBox.values.where((sleep) => sleep.babyId == babyId).toList();

      // Tarihe göre sırala (en yeni önce)
      sleepRecords.sort((a, b) => b.startTime.compareTo(a.startTime));

      if (limit != null && limit > 0) {
        return sleepRecords.take(limit).toList();
      }

      return sleepRecords;
    } catch (e) {
      print('Error getting sleep records for baby: $e');
      return [];
    }
  }

  // Bugünkü uyku kayıtlarını getir
  Future<List<SleepModel>> getTodaySleepRecords(String babyId) async {
    try {
      final today = DateTime.now();
      final sleepRecords = await getSleepRecordsForBaby(babyId);

      return sleepRecords.where((sleep) {
        return sleep.startTime.day == today.day &&
            sleep.startTime.month == today.month &&
            sleep.startTime.year == today.year;
      }).toList();
    } catch (e) {
      print('Error getting today\'s sleep records: $e');
      return [];
    }
  }

  // Aktif uyku kaydını getir
  Future<SleepModel?> getActiveSleepRecord(String babyId) async {
    try {
      final sleepRecords = await getSleepRecordsForBaby(babyId);
      for (final sleep in sleepRecords) {
        if (sleep.isActive) {
          return sleep;
        }
      }
      return null;
    } catch (e) {
      print('Error getting active sleep record: $e');
      return null;
    }
  }

  // Belirli tarih aralığındaki uyku kayıtlarını getir
  Future<List<SleepModel>> getSleepRecordsByDateRange(
    String babyId,
    DateTime startDate,
    DateTime endDate,
  ) async {
    try {
      final sleepRecords = await getSleepRecordsForBaby(babyId);
      return sleepRecords.where((sleep) {
        return sleep.startTime.isAfter(startDate) &&
            sleep.startTime.isBefore(endDate);
      }).toList();
    } catch (e) {
      print('Error getting sleep records by date range: $e');
      return [];
    }
  }

  // Uyku istatistiklerini getir
  Future<Map<String, dynamic>> getSleepStats(String babyId) async {
    try {
      final today = DateTime.now();
      final thisWeek = today.subtract(const Duration(days: 7));
      final thisMonth = DateTime(today.year, today.month, 1);

      final todaySleeps = await getTodaySleepRecords(babyId);
      final weekSleeps = await getSleepRecordsByDateRange(
        babyId,
        thisWeek,
        today,
      );
      final monthSleeps = await getSleepRecordsByDateRange(
        babyId,
        thisMonth,
        today,
      );

      // Bugünkü toplam uyku süresi
      final todayTotalMinutes = todaySleeps
          .where((sleep) => sleep.duration != null)
          .fold(0, (sum, sleep) => sum + sleep.duration!.inMinutes);

      // Haftalık ortalama uyku süresi
      final weeklyAverage =
          weekSleeps.isEmpty
              ? 0.0
              : weekSleeps
                      .where((sleep) => sleep.duration != null)
                      .fold(
                        0,
                        (sum, sleep) => sum + sleep.duration!.inMinutes,
                      ) /
                  7;

      // En uzun uyku
      final longestSleep = monthSleeps
          .where((sleep) => sleep.duration != null)
          .fold<Duration?>(null, (longest, sleep) {
            if (longest == null || sleep.duration! > longest) {
              return sleep.duration!;
            }
            return longest;
          });

      return {
        'todayCount': todaySleeps.length,
        'todayTotalMinutes': todayTotalMinutes,
        'todayTotalHours': (todayTotalMinutes / 60).toStringAsFixed(1),
        'weeklyCount': weekSleeps.length,
        'weeklyAverageMinutes': weeklyAverage.round(),
        'weeklyAverageHours': (weeklyAverage / 60).toStringAsFixed(1),
        'monthlyCount': monthSleeps.length,
        'longestSleepMinutes': longestSleep?.inMinutes ?? 0,
        'longestSleepHours':
            longestSleep != null
                ? (longestSleep.inMinutes / 60).toStringAsFixed(1)
                : '0.0',
        'hasActiveSleep': await getActiveSleepRecord(babyId) != null,
      };
    } catch (e) {
      print('Error getting sleep stats: $e');
      return {
        'todayCount': 0,
        'todayTotalMinutes': 0,
        'todayTotalHours': '0.0',
        'weeklyCount': 0,
        'weeklyAverageMinutes': 0,
        'weeklyAverageHours': '0.0',
        'monthlyCount': 0,
        'longestSleepMinutes': 0,
        'longestSleepHours': '0.0',
        'hasActiveSleep': false,
      };
    }
  }

  // Uyku kaydını silme
  Future<bool> deleteSleepRecord(String sleepId) async {
    try {
      await _sleepBox.delete(sleepId);
      return true;
    } catch (e) {
      print('Error deleting sleep record: $e');
      return false;
    }
  }

  // Tüm uyku kayıtlarını silme (sadece test için)
  Future<bool> clearAllSleepRecords() async {
    try {
      await _sleepBox.clear();
      return true;
    } catch (e) {
      print('Error clearing all sleep records: $e');
      return false;
    }
  }
}
