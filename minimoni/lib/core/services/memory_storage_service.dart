import 'package:hive_flutter/hive_flutter.dart';
import '../models/memory_model.dart';

class MemoryStorageService {
  static const String _boxName = 'memories';
  static Box<MemoryModel>? _box;

  static MemoryStorageService? _instance;
  static MemoryStorageService get instance {
    _instance ??= MemoryStorageService._();
    return _instance!;
  }

  MemoryStorageService._();

  static Future<void> initialize() async {
    _box = Hive.box<MemoryModel>(_boxName);
  }

  Box<MemoryModel> get _memoryBox {
    if (_box == null || !_box!.isOpen) {
      // Fallback to get box if not initialized
      _box = Hive.box<MemoryModel>(_boxName);
      if (_box == null || !_box!.isOpen) {
        throw Exception('Memory box is not initialized');
      }
    }
    return _box!;
  }

  // Anı ekleme
  Future<bool> addMemory(MemoryModel memory) async {
    try {
      await _memoryBox.put(memory.id, memory);
      return true;
    } catch (e) {
      print('Error adding memory: $e');
      return false;
    }
  }

  // Anı güncelleme
  Future<bool> updateMemory(MemoryModel memory) async {
    try {
      final updatedMemory = memory.copyWith(updatedAt: DateTime.now());
      await _memoryBox.put(memory.id, updatedMemory);
      return true;
    } catch (e) {
      print('Error updating memory: $e');
      return false;
    }
  }

  // Anı silme
  Future<bool> deleteMemory(String memoryId) async {
    try {
      await _memoryBox.delete(memoryId);
      return true;
    } catch (e) {
      print('Error deleting memory: $e');
      return false;
    }
  }

  // Tek anı getirme
  Future<MemoryModel?> getMemory(String memoryId) async {
    try {
      return _memoryBox.get(memoryId);
    } catch (e) {
      print('Error getting memory: $e');
      return null;
    }
  }

  // Belirli bebeğin anılarını getir
  Future<List<MemoryModel>> getMemoriesForBaby(
    String babyId, {
    int? limit,
    bool favoritesOnly = false,
  }) async {
    try {
      var memories =
          _memoryBox.values.where((memory) => memory.babyId == babyId).toList();

      if (favoritesOnly) {
        memories = memories.where((memory) => memory.isFavorite).toList();
      }

      // Tarihe göre sırala (en yeni önce)
      memories.sort((a, b) => b.timestamp.compareTo(a.timestamp));

      if (limit != null && limit > 0) {
        return memories.take(limit).toList();
      }

      return memories;
    } catch (e) {
      print('Error getting memories for baby: $e');
      return [];
    }
  }

  // Bu ayki anıları getir
  Future<List<MemoryModel>> getThisMonthMemories(String babyId) async {
    try {
      final now = DateTime.now();
      final thisMonth = DateTime(now.year, now.month, 1);
      final nextMonth = DateTime(now.year, now.month + 1, 1);

      final memories = await getMemoriesForBaby(babyId);

      return memories.where((memory) {
        return memory.timestamp.isAfter(thisMonth) &&
            memory.timestamp.isBefore(nextMonth);
      }).toList();
    } catch (e) {
      print('Error getting this month memories: $e');
      return [];
    }
  }

  // Bugünkü anıları getir
  Future<List<MemoryModel>> getTodayMemories(String babyId) async {
    try {
      final today = DateTime.now();
      final memories = await getMemoriesForBaby(babyId);

      return memories.where((memory) {
        return memory.timestamp.day == today.day &&
            memory.timestamp.month == today.month &&
            memory.timestamp.year == today.year;
      }).toList();
    } catch (e) {
      print('Error getting today memories: $e');
      return [];
    }
  }

  // Belirli tarih aralığındaki anıları getir
  Future<List<MemoryModel>> getMemoriesByDateRange(
    String babyId,
    DateTime startDate,
    DateTime endDate,
  ) async {
    try {
      final memories = await getMemoriesForBaby(babyId);
      return memories.where((memory) {
        return memory.timestamp.isAfter(startDate) &&
            memory.timestamp.isBefore(endDate);
      }).toList();
    } catch (e) {
      print('Error getting memories by date range: $e');
      return [];
    }
  }

  // Ruh haline göre anıları getir
  Future<List<MemoryModel>> getMemoriesByMood(
    String babyId,
    MoodType mood, {
    int? limit,
  }) async {
    try {
      final memories = await getMemoriesForBaby(babyId);
      final filteredMemories =
          memories.where((memory) => memory.mood == mood).toList();

      if (limit != null && limit > 0) {
        return filteredMemories.take(limit).toList();
      }

      return filteredMemories;
    } catch (e) {
      print('Error getting memories by mood: $e');
      return [];
    }
  }

  // Tag'e göre anıları getir
  Future<List<MemoryModel>> getMemoriesByTag(
    String babyId,
    String tag, {
    int? limit,
  }) async {
    try {
      final memories = await getMemoriesForBaby(babyId);
      final filteredMemories =
          memories
              .where(
                (memory) => memory.tags.any(
                  (t) => t.toLowerCase().contains(tag.toLowerCase()),
                ),
              )
              .toList();

      if (limit != null && limit > 0) {
        return filteredMemories.take(limit).toList();
      }

      return filteredMemories;
    } catch (e) {
      print('Error getting memories by tag: $e');
      return [];
    }
  }

  // Anı arama (başlık ve not içinde)
  Future<List<MemoryModel>> searchMemories(
    String babyId,
    String searchQuery, {
    int? limit,
  }) async {
    try {
      final memories = await getMemoriesForBaby(babyId);
      final query = searchQuery.toLowerCase();

      final filteredMemories =
          memories.where((memory) {
            final titleMatch = memory.title.toLowerCase().contains(query);
            final noteMatch =
                memory.hasNote && memory.note!.toLowerCase().contains(query);
            final tagMatch = memory.tags.any(
              (tag) => tag.toLowerCase().contains(query),
            );

            return titleMatch || noteMatch || tagMatch;
          }).toList();

      if (limit != null && limit > 0) {
        return filteredMemories.take(limit).toList();
      }

      return filteredMemories;
    } catch (e) {
      print('Error searching memories: $e');
      return [];
    }
  }

  // Favoriye ekleme/çıkarma
  Future<bool> toggleFavorite(String memoryId) async {
    try {
      final memory = await getMemory(memoryId);
      if (memory != null) {
        final updatedMemory = memory.copyWith(
          isFavorite: !memory.isFavorite,
          updatedAt: DateTime.now(),
        );
        return await updateMemory(updatedMemory);
      }
      return false;
    } catch (e) {
      print('Error toggling favorite: $e');
      return false;
    }
  }

  // Favori anıları getir
  Future<List<MemoryModel>> getFavoriteMemories(String babyId) async {
    return await getMemoriesForBaby(babyId, favoritesOnly: true);
  }

  // Anı istatistiklerini getir
  Future<Map<String, dynamic>> getMemoryStats(String babyId) async {
    try {
      final now = DateTime.now();
      final thisWeek = now.subtract(const Duration(days: 7));
      final thisMonth = DateTime(now.year, now.month, 1);

      final allMemories = await getMemoriesForBaby(babyId);
      final todayMemories = await getTodayMemories(babyId);
      final weekMemories = await getMemoriesByDateRange(babyId, thisWeek, now);
      final monthMemories = await getThisMonthMemories(babyId);
      final favoriteMemories = await getFavoriteMemories(babyId);

      // Ruh hali dağılımı
      final moodDistribution = <MoodType, int>{};
      for (final mood in MoodType.values) {
        moodDistribution[mood] =
            allMemories.where((m) => m.mood == mood).length;
      }

      // En popüler ruh hali
      final mostCommonMood =
          moodDistribution.entries
              .where((entry) => entry.value > 0)
              .reduce((a, b) => a.value > b.value ? a : b)
              .key;

      // Fotoğraflı anı sayısı
      final memoriesWithPhotos = allMemories.where((m) => m.hasPhoto).length;

      // En uzun not
      final longestNote = allMemories
          .where((m) => m.hasNote)
          .fold<String>(
            '',
            (longest, memory) =>
                memory.note!.length > longest.length ? memory.note! : longest,
          );

      // Son anının üzerinden geçen süre
      final lastMemoryTime =
          allMemories.isNotEmpty
              ? DateTime.now().difference(allMemories.first.timestamp)
              : null;

      return {
        'totalCount': allMemories.length,
        'todayCount': todayMemories.length,
        'weekCount': weekMemories.length,
        'monthCount': monthMemories.length,
        'favoriteCount': favoriteMemories.length,
        'memoriesWithPhotos': memoriesWithPhotos,
        'photoPercentage':
            allMemories.isNotEmpty
                ? ((memoriesWithPhotos / allMemories.length) * 100)
                    .toStringAsFixed(1)
                : '0.0',
        'mostCommonMood': mostCommonMood,
        'moodDistribution': moodDistribution,
        'longestNoteLength': longestNote.length,
        'lastMemoryDaysAgo': lastMemoryTime?.inDays ?? 0,
        'averagePerWeek':
            allMemories.length > 0
                ? (allMemories.length /
                        ((DateTime.now()
                                        .difference(allMemories.last.timestamp)
                                        .inDays /
                                    7)
                                .ceil())
                            .clamp(1, double.infinity))
                    .toStringAsFixed(1)
                : '0.0',
      };
    } catch (e) {
      print('Error getting memory stats: $e');
      return {
        'totalCount': 0,
        'todayCount': 0,
        'weekCount': 0,
        'monthCount': 0,
        'favoriteCount': 0,
        'memoriesWithPhotos': 0,
        'photoPercentage': '0.0',
        'mostCommonMood': MoodType.happy,
        'moodDistribution': <MoodType, int>{},
        'longestNoteLength': 0,
        'lastMemoryDaysAgo': 0,
        'averagePerWeek': '0.0',
      };
    }
  }

  // Tüm kullanılan tag'leri getir
  Future<List<String>> getAllTags(String babyId) async {
    try {
      final memories = await getMemoriesForBaby(babyId);
      final allTags = <String>{};

      for (final memory in memories) {
        allTags.addAll(memory.tags);
      }

      return allTags.toList()..sort();
    } catch (e) {
      print('Error getting all tags: $e');
      return [];
    }
  }

  // Tüm anıları getir (yedekleme/export için)
  Future<List<MemoryModel>> getAllMemories() async {
    try {
      return _memoryBox.values.toList();
    } catch (e) {
      print('Error getting all memories: $e');
      return [];
    }
  }

  // Tüm anıları temizle
  Future<bool> clearAllMemories() async {
    try {
      await _memoryBox.clear();
      return true;
    } catch (e) {
      print('Error clearing all memories: $e');
      return false;
    }
  }

  // Belirli bebeğin anılarını temizle
  Future<bool> clearMemoriesForBaby(String babyId) async {
    try {
      final memories = await getMemoriesForBaby(babyId);
      for (final memory in memories) {
        await _memoryBox.delete(memory.id);
      }
      return true;
    } catch (e) {
      print('Error clearing memories for baby: $e');
      return false;
    }
  }
}
