import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/models/memory_model.dart';
import '../../core/services/memory_storage_service.dart';
import '../../core/providers/baby_providers.dart';

// Memory Storage Service Provider
final memoryServiceProvider = Provider<MemoryStorageService>((ref) {
  return MemoryStorageService.instance;
});

// Selected Baby's Memories Provider
final memoriesProvider = FutureProvider<List<MemoryModel>>((ref) async {
  final baby = await ref.watch(activeBabyProvider.future);
  if (baby == null) return [];

  final service = ref.read(memoryServiceProvider);
  return await service.getMemoriesForBaby(baby.id);
});

// Memory Stats Provider
final memoryStatsProvider = FutureProvider<Map<String, dynamic>>((ref) async {
  final baby = await ref.watch(activeBabyProvider.future);
  if (baby == null) return {};

  final service = ref.read(memoryServiceProvider);
  return await service.getMemoryStats(baby.id);
});

// Today's Memories Provider
final todayMemoriesProvider = FutureProvider<List<MemoryModel>>((ref) async {
  final baby = await ref.watch(activeBabyProvider.future);
  if (baby == null) return [];

  final service = ref.read(memoryServiceProvider);
  return await service.getTodayMemories(baby.id);
});

// This Month's Memories Provider
final thisMonthMemoriesProvider = FutureProvider<List<MemoryModel>>((
  ref,
) async {
  final baby = await ref.watch(activeBabyProvider.future);
  if (baby == null) return [];

  final service = ref.read(memoryServiceProvider);
  return await service.getThisMonthMemories(baby.id);
});

// Favorite Memories Provider
final favoriteMemoriesProvider = FutureProvider<List<MemoryModel>>((ref) async {
  final baby = await ref.watch(activeBabyProvider.future);
  if (baby == null) return [];

  final service = ref.read(memoryServiceProvider);
  return await service.getFavoriteMemories(baby.id);
});

// Recent Memories Provider (for dashboard)
final recentMemoriesProvider = FutureProvider<List<MemoryModel>>((ref) async {
  final baby = await ref.watch(activeBabyProvider.future);
  if (baby == null) return [];

  final service = ref.read(memoryServiceProvider);
  return await service.getMemoriesForBaby(baby.id, limit: 5);
});

// All Tags Provider
final allTagsProvider = FutureProvider<List<String>>((ref) async {
  final baby = await ref.watch(activeBabyProvider.future);
  if (baby == null) return [];

  final service = ref.read(memoryServiceProvider);
  return await service.getAllTags(baby.id);
});

// Search Memories Provider
final searchMemoriesProvider = FutureProvider.family<List<MemoryModel>, String>(
  (ref, query) async {
    final baby = await ref.watch(activeBabyProvider.future);
    if (baby == null) return [];

    final service = ref.read(memoryServiceProvider);
    return await service.searchMemories(baby.id, query);
  },
);

// Memories by Mood Provider
final memoriesByMoodProvider =
    FutureProvider.family<List<MemoryModel>, MoodType>((ref, mood) async {
      final baby = await ref.watch(activeBabyProvider.future);
      if (baby == null) return [];

      final service = ref.read(memoryServiceProvider);
      return await service.getMemoriesByMood(baby.id, mood);
    });

// Memories by Tag Provider
final memoriesByTagProvider = FutureProvider.family<List<MemoryModel>, String>((
  ref,
  tag,
) async {
  final baby = await ref.watch(activeBabyProvider.future);
  if (baby == null) return [];

  final service = ref.read(memoryServiceProvider);
  return await service.getMemoriesByTag(baby.id, tag);
});

// Dashboard Memory Summary Provider
final dashboardMemorySummaryProvider = FutureProvider<Map<String, dynamic>>((
  ref,
) async {
  final baby = await ref.watch(activeBabyProvider.future);
  if (baby == null)
    return {
      'totalCount': 0,
      'todayCount': 0,
      'lastMemoryTime': null,
      'lastMemoryTitle': null,
      'favoriteCount': 0,
    };

  final service = ref.read(memoryServiceProvider);
  final stats = await service.getMemoryStats(baby.id);
  final recentMemories = await service.getMemoriesForBaby(baby.id, limit: 1);

  return {
    'totalCount': stats['totalCount'],
    'todayCount': stats['todayCount'],
    'lastMemoryTime':
        recentMemories.isNotEmpty ? recentMemories.first.timeAgo : null,
    'lastMemoryTitle':
        recentMemories.isNotEmpty ? recentMemories.first.title : null,
    'favoriteCount': stats['favoriteCount'],
    'monthCount': stats['monthCount'],
  };
});

// Memory Form State Provider
class MemoryFormState {
  final bool isLoading;
  final String? error;
  final bool showForm;

  const MemoryFormState({
    this.isLoading = false,
    this.error,
    this.showForm = false,
  });

  MemoryFormState copyWith({bool? isLoading, String? error, bool? showForm}) {
    return MemoryFormState(
      isLoading: isLoading ?? this.isLoading,
      error: error ?? this.error,
      showForm: showForm ?? this.showForm,
    );
  }
}

class MemoryFormNotifier extends StateNotifier<MemoryFormState> {
  MemoryFormNotifier() : super(const MemoryFormState());

  void setLoading(bool loading) {
    state = state.copyWith(isLoading: loading);
  }

  void setError(String? error) {
    state = state.copyWith(error: error);
  }

  void toggleForm() {
    state = state.copyWith(showForm: !state.showForm);
  }

  void hideForm() {
    state = state.copyWith(showForm: false);
  }

  void reset() {
    state = const MemoryFormState();
  }
}

final memoryFormProvider =
    StateNotifierProvider<MemoryFormNotifier, MemoryFormState>((ref) {
      return MemoryFormNotifier();
    });

// Memory operations
class MemoryOperations {
  final MemoryStorageService _service;
  final Ref _ref;

  MemoryOperations(this._service, this._ref);

  Future<bool> addMemory(MemoryModel memory) async {
    final success = await _service.addMemory(memory);
    if (success) {
      // Invalidate all related providers to refresh data
      _ref.invalidate(memoriesProvider);
      _ref.invalidate(memoryStatsProvider);
      _ref.invalidate(todayMemoriesProvider);
      _ref.invalidate(thisMonthMemoriesProvider);
      _ref.invalidate(favoriteMemoriesProvider);
      _ref.invalidate(recentMemoriesProvider);
      _ref.invalidate(dashboardMemorySummaryProvider);
      _ref.invalidate(allTagsProvider);
    }
    return success;
  }

  Future<bool> updateMemory(MemoryModel memory) async {
    final success = await _service.updateMemory(memory);
    if (success) {
      // Invalidate all related providers to refresh data
      _ref.invalidate(memoriesProvider);
      _ref.invalidate(memoryStatsProvider);
      _ref.invalidate(todayMemoriesProvider);
      _ref.invalidate(thisMonthMemoriesProvider);
      _ref.invalidate(favoriteMemoriesProvider);
      _ref.invalidate(recentMemoriesProvider);
      _ref.invalidate(dashboardMemorySummaryProvider);
      _ref.invalidate(allTagsProvider);
    }
    return success;
  }

  Future<bool> deleteMemory(String memoryId) async {
    final success = await _service.deleteMemory(memoryId);
    if (success) {
      // Invalidate all related providers to refresh data
      _ref.invalidate(memoriesProvider);
      _ref.invalidate(memoryStatsProvider);
      _ref.invalidate(todayMemoriesProvider);
      _ref.invalidate(thisMonthMemoriesProvider);
      _ref.invalidate(favoriteMemoriesProvider);
      _ref.invalidate(recentMemoriesProvider);
      _ref.invalidate(dashboardMemorySummaryProvider);
      _ref.invalidate(allTagsProvider);
    }
    return success;
  }

  Future<bool> toggleFavorite(String memoryId) async {
    final success = await _service.toggleFavorite(memoryId);
    if (success) {
      // Invalidate all related providers to refresh data
      _ref.invalidate(memoriesProvider);
      _ref.invalidate(memoryStatsProvider);
      _ref.invalidate(favoriteMemoriesProvider);
      _ref.invalidate(recentMemoriesProvider);
      _ref.invalidate(dashboardMemorySummaryProvider);
    }
    return success;
  }
}

final memoryOperationsProvider = Provider<MemoryOperations>((ref) {
  final service = ref.read(memoryServiceProvider);
  return MemoryOperations(service, ref);
});

// Memory Filter State
class MemoryFilterState {
  final MoodType? selectedMood;
  final String? selectedTag;
  final DateTime? startDate;
  final DateTime? endDate;
  final bool favoritesOnly;
  final String searchQuery;

  const MemoryFilterState({
    this.selectedMood,
    this.selectedTag,
    this.startDate,
    this.endDate,
    this.favoritesOnly = false,
    this.searchQuery = '',
  });

  MemoryFilterState copyWith({
    MoodType? selectedMood,
    String? selectedTag,
    DateTime? startDate,
    DateTime? endDate,
    bool? favoritesOnly,
    String? searchQuery,
  }) {
    return MemoryFilterState(
      selectedMood: selectedMood ?? this.selectedMood,
      selectedTag: selectedTag ?? this.selectedTag,
      startDate: startDate ?? this.startDate,
      endDate: endDate ?? this.endDate,
      favoritesOnly: favoritesOnly ?? this.favoritesOnly,
      searchQuery: searchQuery ?? this.searchQuery,
    );
  }

  bool get hasFilters =>
      selectedMood != null ||
      selectedTag != null ||
      startDate != null ||
      endDate != null ||
      favoritesOnly ||
      searchQuery.isNotEmpty;
}

class MemoryFilterNotifier extends StateNotifier<MemoryFilterState> {
  MemoryFilterNotifier() : super(const MemoryFilterState());

  void setMoodFilter(MoodType? mood) {
    state = state.copyWith(selectedMood: mood);
  }

  void setTagFilter(String? tag) {
    state = state.copyWith(selectedTag: tag);
  }

  void setDateRange(DateTime? start, DateTime? end) {
    state = state.copyWith(startDate: start, endDate: end);
  }

  void setFavoritesOnly(bool favorites) {
    state = state.copyWith(favoritesOnly: favorites);
  }

  void setSearchQuery(String query) {
    state = state.copyWith(searchQuery: query);
  }

  void clearFilters() {
    state = const MemoryFilterState();
  }
}

final memoryFilterProvider =
    StateNotifierProvider<MemoryFilterNotifier, MemoryFilterState>((ref) {
      return MemoryFilterNotifier();
    });

// Filtered Memories Provider
final filteredMemoriesProvider = FutureProvider<List<MemoryModel>>((ref) async {
  final baby = await ref.watch(activeBabyProvider.future);
  if (baby == null) return [];

  final service = ref.read(memoryServiceProvider);
  final filters = ref.watch(memoryFilterProvider);

  List<MemoryModel> memories = [];

  if (filters.searchQuery.isNotEmpty) {
    memories = await service.searchMemories(baby.id, filters.searchQuery);
  } else if (filters.selectedMood != null) {
    memories = await service.getMemoriesByMood(baby.id, filters.selectedMood!);
  } else if (filters.selectedTag != null) {
    memories = await service.getMemoriesByTag(baby.id, filters.selectedTag!);
  } else if (filters.startDate != null && filters.endDate != null) {
    memories = await service.getMemoriesByDateRange(
      baby.id,
      filters.startDate!,
      filters.endDate!,
    );
  } else if (filters.favoritesOnly) {
    memories = await service.getFavoriteMemories(baby.id);
  } else {
    memories = await service.getMemoriesForBaby(baby.id);
  }

  return memories;
});
