import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'app/app.dart';
import 'core/models/baby_model.dart';
import 'core/models/feeding_model.dart';
import 'core/models/sleep_model.dart';
import 'core/models/badge_model.dart';
import 'core/models/diaper_change_model.dart';
import 'core/models/memory_model.dart';
import 'core/models/sleep_notification_model.dart';
import 'core/models/growth_model.dart';
import 'core/services/sleep_storage_service.dart';
import 'core/services/badge_storage_service.dart';
import 'core/services/diaper_change_storage_service.dart';
import 'core/services/memory_storage_service.dart';
import 'core/services/sleep_notification_service.dart';
import 'core/services/growth_storage_service.dart';
import 'core/services/notification_service.dart';
import 'core/services/feeding_notification_service.dart';

void main() async {
  // Ensure Flutter is initialized
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize Hive
  await Hive.initFlutter();

  // Register Hive adapters
  if (!Hive.isAdapterRegistered(1)) {
    Hive.registerAdapter(BadgeModelAdapter());
  }
  if (!Hive.isAdapterRegistered(2)) {
    Hive.registerAdapter(BadgeTypeAdapter());
  }
  if (!Hive.isAdapterRegistered(4)) {
    Hive.registerAdapter(SleepModelAdapter());
  }
  if (!Hive.isAdapterRegistered(5)) {
    Hive.registerAdapter(SleepTypeAdapter());
  }
  if (!Hive.isAdapterRegistered(6)) {
    Hive.registerAdapter(SleepQualityAdapter());
  }
  if (!Hive.isAdapterRegistered(7)) {
    Hive.registerAdapter(DiaperChangeModelAdapter());
  }
  if (!Hive.isAdapterRegistered(8)) {
    Hive.registerAdapter(DiaperTypeAdapter());
  }
  if (!Hive.isAdapterRegistered(9)) {
    Hive.registerAdapter(MemoryModelAdapter());
  }
  if (!Hive.isAdapterRegistered(10)) {
    Hive.registerAdapter(MoodTypeAdapter());
  }
  if (!Hive.isAdapterRegistered(11)) {
    Hive.registerAdapter(SleepNotificationModelAdapter());
  }
  if (!Hive.isAdapterRegistered(12)) {
    Hive.registerAdapter(NotificationTypeAdapter());
  }
  if (!Hive.isAdapterRegistered(13)) {
    Hive.registerAdapter(GrowthModelAdapter());
  }
  if (!Hive.isAdapterRegistered(14)) {
    Hive.registerAdapter(FeedingNotificationModelAdapter());
  }
  if (!Hive.isAdapterRegistered(15)) {
    Hive.registerAdapter(FeedingNotificationTypeAdapter());
  }

  // Open Hive boxes
  await Hive.openBox('babies');
  await Hive.openBox('feedings');
  await Hive.openBox<SleepModel>('sleep_records');
  await Hive.openBox<BadgeModel>('badges');
  await Hive.openBox<DiaperChangeModel>('diaper_changes');
  await Hive.openBox<MemoryModel>('memories');
  await Hive.openBox<SleepNotificationModel>('sleep_notifications');
  await Hive.openBox<GrowthModel>('growth_records');
  await Hive.openBox<FeedingNotificationModel>('feeding_notifications');

  // Initialize services
  await SleepStorageService.initialize();
  await BadgeStorageService.initialize();
  await DiaperChangeStorageService.initialize();
  await MemoryStorageService.initialize();
  await SleepNotificationService.initialize();
  await GrowthStorageService.init();
  await NotificationService.initialize();
  await FeedingNotificationService.initialize();

  runApp(const ProviderScope(child: MiniMoniApp()));
}
