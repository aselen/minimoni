import 'package:hive/hive.dart';
import '../models/growth_model.dart';

class GrowthStorageService {
  static const String _boxName = 'growth_records';
  static Box<GrowthModel>? _box;

  static Future<void> init() async {
    if (_box == null || !_box!.isOpen) {
      _box = await Hive.openBox<GrowthModel>(_boxName);
    }
  }

  static Box<GrowthModel> get _growthBox {
    if (_box == null || !_box!.isOpen) {
      throw Exception('GrowthStorageService not initialized');
    }
    return _box!;
  }

  // CRUD Operations
  static Future<void> addGrowthRecord(GrowthModel growth) async {
    await _growthBox.put(growth.id, growth);
  }

  static Future<void> updateGrowthRecord(GrowthModel growth) async {
    final updatedGrowth = growth.copyWith(updatedAt: DateTime.now());
    await _growthBox.put(growth.id, updatedGrowth);
  }

  static Future<void> deleteGrowthRecord(String id) async {
    await _growthBox.delete(id);
  }

  static GrowthModel? getGrowthRecord(String id) {
    return _growthBox.get(id);
  }

  // Query Operations
  static List<GrowthModel> getAllGrowthRecords() {
    return _growthBox.values.toList()
      ..sort((a, b) => b.measurementDate.compareTo(a.measurementDate));
  }

  static List<GrowthModel> getGrowthRecordsByBaby(String babyId) {
    return _growthBox.values.where((growth) => growth.babyId == babyId).toList()
      ..sort((a, b) => b.measurementDate.compareTo(a.measurementDate));
  }

  static List<GrowthModel> getGrowthRecordsInDateRange(
    String babyId,
    DateTime startDate,
    DateTime endDate,
  ) {
    return _growthBox.values
        .where(
          (growth) =>
              growth.babyId == babyId &&
              growth.measurementDate.isAfter(
                startDate.subtract(const Duration(days: 1)),
              ) &&
              growth.measurementDate.isBefore(
                endDate.add(const Duration(days: 1)),
              ),
        )
        .toList()
      ..sort((a, b) => a.measurementDate.compareTo(b.measurementDate));
  }

  // Analysis Functions
  static GrowthModel? getLatestGrowthRecord(String babyId) {
    final records = getGrowthRecordsByBaby(babyId);
    return records.isNotEmpty ? records.first : null;
  }

  static Map<String, double> getGrowthStats(String babyId) {
    final records = getGrowthRecordsByBaby(babyId);
    if (records.isEmpty) {
      return {
        'totalRecords': 0,
        'avgHeight': 0,
        'avgWeight': 0,
        'maxHeight': 0,
        'maxWeight': 0,
        'minHeight': 0,
        'minWeight': 0,
      };
    }

    final heights = records.map((r) => r.height).toList();
    final weights = records.map((r) => r.weight).toList();

    return {
      'totalRecords': records.length.toDouble(),
      'avgHeight': heights.reduce((a, b) => a + b) / heights.length,
      'avgWeight': weights.reduce((a, b) => a + b) / weights.length,
      'maxHeight': heights.reduce((a, b) => a > b ? a : b),
      'maxWeight': weights.reduce((a, b) => a > b ? a : b),
      'minHeight': heights.reduce((a, b) => a < b ? a : b),
      'minWeight': weights.reduce((a, b) => a < b ? a : b),
    };
  }

  static Map<String, double> getGrowthTrend(
    String babyId, {
    int lastDays = 30,
  }) {
    final endDate = DateTime.now();
    final startDate = endDate.subtract(Duration(days: lastDays));
    final records = getGrowthRecordsInDateRange(babyId, startDate, endDate);

    if (records.length < 2) {
      return {'heightTrend': 0, 'weightTrend': 0};
    }

    final firstRecord = records.first;
    final lastRecord = records.last;

    final heightTrend = lastRecord.height - firstRecord.height;
    final weightTrend = lastRecord.weight - firstRecord.weight;

    return {'heightTrend': heightTrend, 'weightTrend': weightTrend};
  }

  // Chart Data
  static List<Map<String, dynamic>> getHeightChartData(
    String babyId, {
    int lastDays = 30,
  }) {
    final endDate = DateTime.now();
    final startDate = endDate.subtract(Duration(days: lastDays));
    final records = getGrowthRecordsInDateRange(babyId, startDate, endDate);

    return records
        .map(
          (record) => {
            'date': record.measurementDate,
            'height': record.height,
            'formattedDate':
                '${record.measurementDate.day}/${record.measurementDate.month}',
          },
        )
        .toList();
  }

  static List<Map<String, dynamic>> getWeightChartData(
    String babyId, {
    int lastDays = 30,
  }) {
    final endDate = DateTime.now();
    final startDate = endDate.subtract(Duration(days: lastDays));
    final records = getGrowthRecordsInDateRange(babyId, startDate, endDate);

    return records
        .map(
          (record) => {
            'date': record.measurementDate,
            'weight': record.weight,
            'formattedDate':
                '${record.measurementDate.day}/${record.measurementDate.month}',
          },
        )
        .toList();
  }

  // Monthly Analysis
  static Map<String, dynamic> getMonthlyGrowthAnalysis(String babyId) {
    final now = DateTime.now();
    final thisMonth = DateTime(now.year, now.month, 1);
    final lastMonth = DateTime(now.year, now.month - 1, 1);
    final nextMonth = DateTime(now.year, now.month + 1, 1);

    final thisMonthRecords = getGrowthRecordsInDateRange(
      babyId,
      thisMonth,
      nextMonth,
    );
    final lastMonthRecords = getGrowthRecordsInDateRange(
      babyId,
      lastMonth,
      thisMonth,
    );

    double thisMonthAvgHeight = 0;
    double thisMonthAvgWeight = 0;
    double lastMonthAvgHeight = 0;
    double lastMonthAvgWeight = 0;

    if (thisMonthRecords.isNotEmpty) {
      thisMonthAvgHeight =
          thisMonthRecords.map((r) => r.height).reduce((a, b) => a + b) /
          thisMonthRecords.length;
      thisMonthAvgWeight =
          thisMonthRecords.map((r) => r.weight).reduce((a, b) => a + b) /
          thisMonthRecords.length;
    }

    if (lastMonthRecords.isNotEmpty) {
      lastMonthAvgHeight =
          lastMonthRecords.map((r) => r.height).reduce((a, b) => a + b) /
          lastMonthRecords.length;
      lastMonthAvgWeight =
          lastMonthRecords.map((r) => r.weight).reduce((a, b) => a + b) /
          lastMonthRecords.length;
    }

    final heightChange = thisMonthAvgHeight - lastMonthAvgHeight;
    final weightChange = thisMonthAvgWeight - lastMonthAvgWeight;

    return {
      'thisMonthRecords': thisMonthRecords.length,
      'lastMonthRecords': lastMonthRecords.length,
      'heightChange': heightChange,
      'weightChange': weightChange,
      'heightChangePercent':
          lastMonthAvgHeight > 0
              ? (heightChange / lastMonthAvgHeight) * 100
              : 0,
      'weightChangePercent':
          lastMonthAvgWeight > 0
              ? (weightChange / lastMonthAvgWeight) * 100
              : 0,
    };
  }

  // Cleanup
  static Future<void> clearAllGrowthRecords() async {
    await _growthBox.clear();
  }

  static Future<void> close() async {
    await _box?.close();
    _box = null;
  }
}
