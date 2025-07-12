import 'package:hive_flutter/hive_flutter.dart';
import '../models/diaper_change_model.dart';

class DiaperChangeStorageService {
  static const String _boxName = 'diaper_changes';
  static Box<DiaperChangeModel>? _box;

  static DiaperChangeStorageService? _instance;
  static DiaperChangeStorageService get instance {
    _instance ??= DiaperChangeStorageService._();
    return _instance!;
  }

  DiaperChangeStorageService._();

  static Future<void> initialize() async {
    _box = Hive.box<DiaperChangeModel>(_boxName);
  }

  Box<DiaperChangeModel> get _diaperBox {
    if (_box == null || !_box!.isOpen) {
      // Fallback to get box if not initialized
      _box = Hive.box<DiaperChangeModel>(_boxName);
      if (_box == null || !_box!.isOpen) {
        throw Exception('Diaper change box is not initialized');
      }
    }
    return _box!;
  }

  // Alt değişimi kaydı ekleme
  Future<bool> addDiaperChange(DiaperChangeModel diaperChange) async {
    try {
      await _diaperBox.put(diaperChange.id, diaperChange);
      return true;
    } catch (e) {
      print('Error adding diaper change: $e');
      return false;
    }
  }

  // Alt değişimi kaydı güncelleme
  Future<bool> updateDiaperChange(DiaperChangeModel diaperChange) async {
    try {
      final updatedDiaperChange = diaperChange.copyWith(
        updatedAt: DateTime.now(),
      );
      await _diaperBox.put(diaperChange.id, updatedDiaperChange);
      return true;
    } catch (e) {
      print('Error updating diaper change: $e');
      return false;
    }
  }

  // Alt değişimi kaydı silme
  Future<bool> deleteDiaperChange(String diaperChangeId) async {
    try {
      await _diaperBox.delete(diaperChangeId);
      return true;
    } catch (e) {
      print('Error deleting diaper change: $e');
      return false;
    }
  }

  // Belirli bebeğin alt değişimi kayıtlarını getir
  Future<List<DiaperChangeModel>> getDiaperChangesForBaby(
    String babyId, {
    int? limit,
  }) async {
    try {
      final diaperChanges =
          _diaperBox.values.where((change) => change.babyId == babyId).toList();

      // Tarihe göre sırala (en yeni önce)
      diaperChanges.sort((a, b) => b.timestamp.compareTo(a.timestamp));

      if (limit != null && limit > 0) {
        return diaperChanges.take(limit).toList();
      }

      return diaperChanges;
    } catch (e) {
      print('Error getting diaper changes for baby: $e');
      return [];
    }
  }

  // Bugünkü alt değişimi kayıtlarını getir
  Future<List<DiaperChangeModel>> getTodayDiaperChanges(String babyId) async {
    try {
      final today = DateTime.now();
      final diaperChanges = await getDiaperChangesForBaby(babyId);

      return diaperChanges.where((change) {
        return change.timestamp.day == today.day &&
            change.timestamp.month == today.month &&
            change.timestamp.year == today.year;
      }).toList();
    } catch (e) {
      print('Error getting today\'s diaper changes: $e');
      return [];
    }
  }

  // Belirli tarih aralığındaki alt değişimi kayıtlarını getir
  Future<List<DiaperChangeModel>> getDiaperChangesByDateRange(
    String babyId,
    DateTime startDate,
    DateTime endDate,
  ) async {
    try {
      final diaperChanges = await getDiaperChangesForBaby(babyId);
      return diaperChanges.where((change) {
        return change.timestamp.isAfter(startDate) &&
            change.timestamp.isBefore(endDate);
      }).toList();
    } catch (e) {
      print('Error getting diaper changes by date range: $e');
      return [];
    }
  }

  // Son alt değişiminin üzerinden ne kadar zaman geçtiğini getir
  Future<Duration?> getTimeSinceLastChange(String babyId) async {
    try {
      final diaperChanges = await getDiaperChangesForBaby(babyId, limit: 1);
      if (diaperChanges.isNotEmpty) {
        return DateTime.now().difference(diaperChanges.first.timestamp);
      }
      return null;
    } catch (e) {
      print('Error getting time since last change: $e');
      return null;
    }
  }

  // Alt değişimi tipine göre kayıtları getir
  Future<List<DiaperChangeModel>> getDiaperChangesByType(
    String babyId,
    DiaperType type, {
    int? limit,
  }) async {
    try {
      final diaperChanges = await getDiaperChangesForBaby(babyId);
      final filteredChanges =
          diaperChanges.where((change) => change.type == type).toList();

      if (limit != null && limit > 0) {
        return filteredChanges.take(limit).toList();
      }

      return filteredChanges;
    } catch (e) {
      print('Error getting diaper changes by type: $e');
      return [];
    }
  }

  // Alt değişimi istatistiklerini getir
  Future<Map<String, dynamic>> getDiaperChangeStats(String babyId) async {
    try {
      final today = DateTime.now();
      final thisWeek = today.subtract(const Duration(days: 7));
      final thisMonth = DateTime(today.year, today.month, 1);

      final todayChanges = await getTodayDiaperChanges(babyId);
      final weekChanges = await getDiaperChangesByDateRange(
        babyId,
        thisWeek,
        today,
      );
      final monthChanges = await getDiaperChangesByDateRange(
        babyId,
        thisMonth,
        today,
      );

      // Bugünkü tip dağılımı
      final todayWet =
          todayChanges.where((c) => c.type == DiaperType.wet).length;
      final todayDirty =
          todayChanges.where((c) => c.type == DiaperType.dirty).length;
      final todayBoth =
          todayChanges.where((c) => c.type == DiaperType.both).length;
      final todayClean =
          todayChanges.where((c) => c.type == DiaperType.clean).length;

      // Haftalık ortalama
      final weeklyAverage = weekChanges.length / 7;

      // Son değişimden bu yana geçen süre
      final timeSinceLast = await getTimeSinceLastChange(babyId);

      return {
        'todayCount': todayChanges.length,
        'todayWet': todayWet,
        'todayDirty': todayDirty,
        'todayBoth': todayBoth,
        'todayClean': todayClean,
        'weeklyCount': weekChanges.length,
        'weeklyAverage': weeklyAverage.toStringAsFixed(1),
        'monthlyCount': monthChanges.length,
        'timeSinceLastMinutes': timeSinceLast?.inMinutes ?? 0,
        'timeSinceLastHours':
            timeSinceLast != null
                ? (timeSinceLast.inMinutes / 60).toStringAsFixed(1)
                : '0',
        'lastChangeTime':
            todayChanges.isNotEmpty ? todayChanges.first.timestamp : null,
      };
    } catch (e) {
      print('Error getting diaper change stats: $e');
      return {
        'todayCount': 0,
        'todayWet': 0,
        'todayDirty': 0,
        'todayBoth': 0,
        'todayClean': 0,
        'weeklyCount': 0,
        'weeklyAverage': '0.0',
        'monthlyCount': 0,
        'timeSinceLastMinutes': 0,
        'timeSinceLastHours': '0',
        'lastChangeTime': null,
      };
    }
  }

  // Tüm alt değişimi kayıtlarını getir (yedekleme/export için)
  Future<List<DiaperChangeModel>> getAllDiaperChanges() async {
    try {
      return _diaperBox.values.toList();
    } catch (e) {
      print('Error getting all diaper changes: $e');
      return [];
    }
  }

  // Tüm kayıtları temizle
  Future<bool> clearAllDiaperChanges() async {
    try {
      await _diaperBox.clear();
      return true;
    } catch (e) {
      print('Error clearing all diaper changes: $e');
      return false;
    }
  }
}
