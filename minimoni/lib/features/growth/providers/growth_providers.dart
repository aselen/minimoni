import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/models/growth_model.dart';
import '../../../core/services/growth_storage_service.dart';
import '../../../core/services/baby_storage_service.dart';

// Growth Records Provider
final growthRecordsProvider =
    StateNotifierProvider<GrowthRecordsNotifier, List<GrowthModel>>((ref) {
      return GrowthRecordsNotifier();
    });

class GrowthRecordsNotifier extends StateNotifier<List<GrowthModel>> {
  GrowthRecordsNotifier() : super([]) {
    _loadGrowthRecords();
  }

  Future<void> _loadGrowthRecords() async {
    try {
      final baby = await BabyStorageService.instance.getActiveBaby();
      if (baby != null) {
        final records = GrowthStorageService.getGrowthRecordsByBaby(baby.id);
        state = records;
      }
    } catch (e) {
      print('Error loading growth records: $e');
    }
  }

  Future<void> addGrowthRecord(GrowthModel growth) async {
    try {
      await GrowthStorageService.addGrowthRecord(growth);
      state = [...state, growth]
        ..sort((a, b) => b.measurementDate.compareTo(a.measurementDate));
    } catch (e) {
      print('Error adding growth record: $e');
    }
  }

  Future<void> updateGrowthRecord(GrowthModel growth) async {
    try {
      await GrowthStorageService.updateGrowthRecord(growth);
      state =
          state
              .map((record) => record.id == growth.id ? growth : record)
              .toList();
    } catch (e) {
      print('Error updating growth record: $e');
    }
  }

  Future<void> deleteGrowthRecord(String id) async {
    try {
      await GrowthStorageService.deleteGrowthRecord(id);
      state = state.where((record) => record.id != id).toList();
    } catch (e) {
      print('Error deleting growth record: $e');
    }
  }

  Future<void> refresh() async {
    await _loadGrowthRecords();
  }
}

// Latest Growth Record Provider
final latestGrowthRecordProvider = FutureProvider<GrowthModel?>((ref) async {
  try {
    final baby = await BabyStorageService.instance.getActiveBaby();
    if (baby != null) {
      return GrowthStorageService.getLatestGrowthRecord(baby.id);
    }
    return null;
  } catch (e) {
    print('Error getting latest growth record: $e');
    return null;
  }
});

// Growth Stats Provider
final growthStatsProvider = FutureProvider<Map<String, double>>((ref) async {
  try {
    final baby = await BabyStorageService.instance.getActiveBaby();
    if (baby != null) {
      return GrowthStorageService.getGrowthStats(baby.id);
    }
    return {};
  } catch (e) {
    print('Error getting growth stats: $e');
    return {};
  }
});

// Growth Trend Provider
final growthTrendProvider = FutureProvider<Map<String, double>>((ref) async {
  try {
    final baby = await BabyStorageService.instance.getActiveBaby();
    if (baby != null) {
      return GrowthStorageService.getGrowthTrend(baby.id);
    }
    return {};
  } catch (e) {
    print('Error getting growth trend: $e');
    return {};
  }
});

// Height Chart Data Provider
final heightChartDataProvider = FutureProvider<List<Map<String, dynamic>>>((
  ref,
) async {
  try {
    final baby = await BabyStorageService.instance.getActiveBaby();
    if (baby != null) {
      return GrowthStorageService.getHeightChartData(baby.id);
    }
    return [];
  } catch (e) {
    print('Error getting height chart data: $e');
    return [];
  }
});

// Weight Chart Data Provider
final weightChartDataProvider = FutureProvider<List<Map<String, dynamic>>>((
  ref,
) async {
  try {
    final baby = await BabyStorageService.instance.getActiveBaby();
    if (baby != null) {
      return GrowthStorageService.getWeightChartData(baby.id);
    }
    return [];
  } catch (e) {
    print('Error getting weight chart data: $e');
    return [];
  }
});

// Monthly Growth Analysis Provider
final monthlyGrowthAnalysisProvider = FutureProvider<Map<String, dynamic>>((
  ref,
) async {
  try {
    final baby = await BabyStorageService.instance.getActiveBaby();
    if (baby != null) {
      return GrowthStorageService.getMonthlyGrowthAnalysis(baby.id);
    }
    return {};
  } catch (e) {
    print('Error getting monthly growth analysis: $e');
    return {};
  }
});

// Growth Records Count Provider
final growthRecordsCountProvider = FutureProvider<int>((ref) async {
  try {
    final baby = await BabyStorageService.instance.getActiveBaby();
    if (baby != null) {
      final records = GrowthStorageService.getGrowthRecordsByBaby(baby.id);
      return records.length;
    }
    return 0;
  } catch (e) {
    print('Error getting growth records count: $e');
    return 0;
  }
});

// Growth Records for Date Range Provider
final growthRecordsForDateRangeProvider =
    FutureProvider.family<List<GrowthModel>, Map<String, DateTime>>((
      ref,
      dateRange,
    ) async {
      try {
        final baby = await BabyStorageService.instance.getActiveBaby();
        if (baby != null) {
          final startDate = dateRange['startDate']!;
          final endDate = dateRange['endDate']!;
          return GrowthStorageService.getGrowthRecordsInDateRange(
            baby.id,
            startDate,
            endDate,
          );
        }
        return [];
      } catch (e) {
        print('Error getting growth records for date range: $e');
        return [];
      }
    });
