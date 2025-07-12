import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/services/feeding_storage_service.dart';
import '../../core/providers/baby_providers.dart';
import '../memory/memory_providers.dart';

final monthlyMilkTotalProvider = FutureProvider.autoDispose<int>((ref) async {
  final baby = await ref.watch(activeBabyProvider.future);
  if (baby == null) return 0;
  return FeedingStorageService.instance.getMonthlyMilkTotal(baby.id);
});

final weeklyMilkTotalProvider = FutureProvider.autoDispose<int>((ref) async {
  final baby = await ref.watch(activeBabyProvider.future);
  if (baby == null) return 0;
  return FeedingStorageService.instance.getWeeklyMilkTotal(baby.id);
});

final dailyMilkTotalProvider = FutureProvider.autoDispose<int>((ref) async {
  final baby = await ref.watch(activeBabyProvider.future);
  if (baby == null) return 0;
  return FeedingStorageService.instance.getDailyMilkTotal(baby.id);
});

final weeklyMilkPercentChangeProvider = FutureProvider.autoDispose<double>((
  ref,
) async {
  final baby = await ref.watch(activeBabyProvider.future);
  if (baby == null) return 0.0;
  return FeedingStorageService.instance.getWeeklyMilkPercentChange(baby.id);
});

final weeklyMilkChartProvider = FutureProvider.autoDispose<List<int>>((
  ref,
) async {
  final baby = await ref.watch(activeBabyProvider.future);
  if (baby == null) return List.filled(7, 0);
  final now = DateTime.now();
  List<int> dailyTotals = [];
  for (int i = 6; i >= 0; i--) {
    final day = now.subtract(Duration(days: i));
    final total = await FeedingStorageService.instance.getDailyMilkTotal(
      baby.id,
      forDay: day,
    );
    dailyTotals.add(total);
  }
  return dailyTotals;
});
