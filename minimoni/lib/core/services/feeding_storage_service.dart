import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/feeding_model.dart';

class FeedingStorageService {
  static const String _feedingListKey = 'feeding_records';
  static FeedingStorageService? _instance;

  FeedingStorageService._();

  static FeedingStorageService get instance {
    _instance ??= FeedingStorageService._();
    return _instance!;
  }

  /// Add a new feeding record
  Future<bool> addFeeding(FeedingModel feeding) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final feedingList = await getAllFeedings();

      // Add new feeding to the beginning of the list (most recent first)
      feedingList.insert(0, feeding);

      // Convert to JSON strings
      final jsonList = feedingList.map((f) => jsonEncode(f.toJson())).toList();

      // Save to SharedPreferences
      return await prefs.setStringList(_feedingListKey, jsonList);
    } catch (e) {
      print('Error adding feeding: $e');
      return false;
    }
  }

  /// Get all feeding records
  Future<List<FeedingModel>> getAllFeedings() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final jsonList = prefs.getStringList(_feedingListKey) ?? [];

      return jsonList
          .map((jsonString) => FeedingModel.fromJson(jsonDecode(jsonString)))
          .toList();
    } catch (e) {
      print('Error getting all feedings: $e');
      return [];
    }
  }

  /// Get feeding records for a specific baby
  Future<List<FeedingModel>> getFeedingsForBaby(String babyId) async {
    try {
      final allFeedings = await getAllFeedings();
      return allFeedings.where((feeding) => feeding.babyId == babyId).toList();
    } catch (e) {
      print('Error getting feedings for baby: $e');
      return [];
    }
  }

  /// Get recent feeding records (last N feedings)
  Future<List<FeedingModel>> getRecentFeedings({int limit = 10}) async {
    try {
      final allFeedings = await getAllFeedings();
      if (allFeedings.length <= limit) {
        return allFeedings;
      }
      return allFeedings.sublist(0, limit);
    } catch (e) {
      print('Error getting recent feedings: $e');
      return [];
    }
  }

  /// Get recent feeding records for a specific baby
  Future<List<FeedingModel>> getRecentFeedingsForBaby(
    String babyId, {
    int limit = 10,
  }) async {
    try {
      final babyFeedings = await getFeedingsForBaby(babyId);
      if (babyFeedings.length <= limit) {
        return babyFeedings;
      }
      return babyFeedings.sublist(0, limit);
    } catch (e) {
      print('Error getting recent feedings for baby: $e');
      return [];
    }
  }

  /// Get feedings for today
  Future<List<FeedingModel>> getTodaysFeedings(String babyId) async {
    try {
      final allFeedings = await getFeedingsForBaby(babyId);
      final today = DateTime.now();

      return allFeedings.where((feeding) {
        return feeding.timestamp.year == today.year &&
            feeding.timestamp.month == today.month &&
            feeding.timestamp.day == today.day;
      }).toList();
    } catch (e) {
      print('Error getting today\'s feedings: $e');
      return [];
    }
  }

  /// Update a feeding record
  Future<bool> updateFeeding(FeedingModel updatedFeeding) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final feedingList = await getAllFeedings();

      // Find and update the feeding
      final index = feedingList.indexWhere((f) => f.id == updatedFeeding.id);
      if (index != -1) {
        feedingList[index] = updatedFeeding;

        // Convert to JSON strings
        final jsonList =
            feedingList.map((f) => jsonEncode(f.toJson())).toList();

        // Save to SharedPreferences
        return await prefs.setStringList(_feedingListKey, jsonList);
      }
      return false;
    } catch (e) {
      print('Error updating feeding: $e');
      return false;
    }
  }

  /// Delete a feeding record
  Future<bool> deleteFeeding(String feedingId) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final feedingList = await getAllFeedings();

      // Remove the feeding
      feedingList.removeWhere((f) => f.id == feedingId);

      // Convert to JSON strings
      final jsonList = feedingList.map((f) => jsonEncode(f.toJson())).toList();

      // Save to SharedPreferences
      return await prefs.setStringList(_feedingListKey, jsonList);
    } catch (e) {
      print('Error deleting feeding: $e');
      return false;
    }
  }

  /// Get feeding statistics for a baby
  Future<Map<String, dynamic>> getFeedingStats(String babyId) async {
    try {
      final todaysFeedings = await getTodaysFeedings(babyId);

      int breastCount = 0;
      int formulaCount = 0;
      int solidCount = 0;
      int totalAmount = 0;
      Duration totalDuration = Duration.zero;

      for (final feeding in todaysFeedings) {
        switch (feeding.type) {
          case 'breast':
            breastCount++;
            if (feeding.duration != null) {
              totalDuration += feeding.duration!;
            }
            break;
          case 'formula':
            formulaCount++;
            if (feeding.amount != null) {
              totalAmount += feeding.amount!;
            }
            break;
          case 'solid':
            solidCount++;
            if (feeding.amount != null) {
              totalAmount += feeding.amount!;
            }
            break;
        }
      }

      return {
        'totalFeedings': todaysFeedings.length,
        'breastFeedings': breastCount,
        'formulaFeedings': formulaCount,
        'solidFeedings': solidCount,
        'totalAmount': totalAmount, // ml
        'totalDuration': totalDuration.inMinutes, // minutes
        'lastFeeding': todaysFeedings.isNotEmpty ? todaysFeedings.first : null,
      };
    } catch (e) {
      print('Error getting feeding stats: $e');
      return {
        'totalFeedings': 0,
        'breastFeedings': 0,
        'formulaFeedings': 0,
        'solidFeedings': 0,
        'totalAmount': 0,
        'totalDuration': 0,
        'lastFeeding': null,
      };
    }
  }

  /// Clear all feeding records (for testing/reset)
  Future<bool> clearAllFeedings() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      return await prefs.remove(_feedingListKey);
    } catch (e) {
      print('Error clearing feedings: $e');
      return false;
    }
  }

  /// Get last feeding of a specific type for a baby
  Future<FeedingModel?> getLastFeedingOfType(String babyId, String type) async {
    try {
      final babyFeedings = await getFeedingsForBaby(babyId);
      final typeFeedings = babyFeedings.where((f) => f.type == type).toList();

      if (typeFeedings.isNotEmpty) {
        return typeFeedings.first; // Already sorted by most recent first
      }
      return null;
    } catch (e) {
      print('Error getting last feeding of type: $e');
      return null;
    }
  }

  /// Get total milk (ml) for a given month
  Future<int> getMonthlyMilkTotal(String babyId, {DateTime? forMonth}) async {
    final allFeedings = await getFeedingsForBaby(babyId);
    final now = forMonth ?? DateTime.now();
    final monthFeedings = allFeedings.where(
      (feeding) =>
          feeding.timestamp.year == now.year &&
          feeding.timestamp.month == now.month &&
          feeding.amount != null,
    );
    return monthFeedings.fold<int>(0, (int sum, f) => sum + (f.amount ?? 0));
  }

  /// Get total milk (ml) for a given week (Monday-Sunday)
  Future<int> getWeeklyMilkTotal(String babyId, {DateTime? forWeek}) async {
    final allFeedings = await getFeedingsForBaby(babyId);
    final now = forWeek ?? DateTime.now();
    final weekStart = now.subtract(Duration(days: now.weekday - 1));
    final weekEnd = weekStart.add(const Duration(days: 7));
    final weekFeedings = allFeedings.where(
      (feeding) =>
          feeding.timestamp.isAfter(
            weekStart.subtract(const Duration(seconds: 1)),
          ) &&
          feeding.timestamp.isBefore(weekEnd) &&
          feeding.amount != null,
    );
    return weekFeedings.fold<int>(0, (int sum, f) => sum + (f.amount ?? 0));
  }

  /// Get total milk (ml) for a given day
  Future<int> getDailyMilkTotal(String babyId, {DateTime? forDay}) async {
    final allFeedings = await getFeedingsForBaby(babyId);
    final now = forDay ?? DateTime.now();
    final dayFeedings = allFeedings.where(
      (feeding) =>
          feeding.timestamp.year == now.year &&
          feeding.timestamp.month == now.month &&
          feeding.timestamp.day == now.day &&
          feeding.amount != null,
    );
    return dayFeedings.fold<int>(0, (int sum, f) => sum + (f.amount ?? 0));
  }

  /// Get percent change in milk (ml) between this week and last week
  Future<double> getWeeklyMilkPercentChange(String babyId) async {
    final now = DateTime.now();
    final thisWeekTotal = await getWeeklyMilkTotal(babyId, forWeek: now);
    final lastWeek = now.subtract(const Duration(days: 7));
    final lastWeekTotal = await getWeeklyMilkTotal(babyId, forWeek: lastWeek);
    if (lastWeekTotal == 0) return 0.0;
    return ((thisWeekTotal - lastWeekTotal) / lastWeekTotal) * 100.0;
  }
}
