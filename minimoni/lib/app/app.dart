import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:go_router/go_router.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:google_fonts/google_fonts.dart';

import 'router.dart';
import 'theme.dart';
import '../core/providers/theme_provider.dart';
import '../features/dashboard/dashboard_page.dart';
import '../core/services/music_service.dart';

// Hive models
import '../core/models/badge_model.dart';
import '../core/models/sleep_model.dart';

/// Ana uygulama sınıfı
/// Riverpod ProviderScope ile sarmalanmış MaterialApp
class MiniMoniApp extends ConsumerStatefulWidget {
  const MiniMoniApp({super.key});

  @override
  ConsumerState<MiniMoniApp> createState() => _MiniMoniAppState();
}

class _MiniMoniAppState extends ConsumerState<MiniMoniApp> {
  late final GoRouter _router;
  bool _isHiveInitialized = false;

  @override
  void initState() {
    super.initState();
    _initializeHive();
    _router = ref.read(routerProvider);
  }

  @override
  void dispose() {
    // Global müzik servisini temizle
    MusicService().dispose();
    super.dispose();
  }

  Future<void> _initializeHive() async {
    try {
      await Hive.initFlutter();

      // Hive Type Adapters - Only register models that have Hive annotations
      if (!Hive.isAdapterRegistered(1)) {
        Hive.registerAdapter(BadgeModelAdapter());
      }
      if (!Hive.isAdapterRegistered(2)) {
        Hive.registerAdapter(BadgeTypeAdapter());
      }
      if (!Hive.isAdapterRegistered(3)) {
        Hive.registerAdapter(SleepModelAdapter());
      }
      if (!Hive.isAdapterRegistered(4)) {
        Hive.registerAdapter(SleepTypeAdapter());
      }
      if (!Hive.isAdapterRegistered(5)) {
        Hive.registerAdapter(SleepQualityAdapter());
      }

      // Hive Box'ları aç
      await Hive.openBox<BadgeModel>('badges');
      await Hive.openBox<SleepModel>('sleep');

      setState(() {
        _isHiveInitialized = true;
      });
    } catch (e) {
      debugPrint('Hive initialization error: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    if (!_isHiveInitialized) {
      return const MaterialApp(
        home: Scaffold(body: Center(child: CircularProgressIndicator())),
      );
    }

    return Consumer(
      builder: (context, ref, child) {
        // Tema provider'ını dinle
        final currentThemeMode = ref.watch(themeModeProvider);
        print('Current theme mode: $currentThemeMode'); // DEBUG
        print('Building MaterialApp with theme: $currentThemeMode'); // DEBUG

        return MaterialApp.router(
          key: ValueKey('theme_${currentThemeMode.name}'),
          title: 'MiniMoni',
          routerConfig: _router,
          theme: AppTheme.lightTheme,
          darkTheme: AppTheme.darkTheme,
          themeMode: _getThemeMode(currentThemeMode),
          debugShowCheckedModeBanner: false,
          localizationsDelegates: const [
            GlobalMaterialLocalizations.delegate,
            GlobalWidgetsLocalizations.delegate,
            GlobalCupertinoLocalizations.delegate,
          ],
          supportedLocales: const [Locale('tr', 'TR'), Locale('en', 'US')],
        );
      },
    );
  }

  ThemeMode _getThemeMode(AppThemeMode appThemeMode) {
    switch (appThemeMode) {
      case AppThemeMode.light:
        return ThemeMode.light;
      case AppThemeMode.dark:
        return ThemeMode.dark;
      case AppThemeMode.auto:
        return ThemeMode.system;
    }
  }

  Widget _buildHomePage() {
    // Router yerine basit bir home page kullan
    return const DashboardPage();
  }

  ThemeData _getTheme(AppThemeMode appThemeMode, BuildContext context) {
    print('_getTheme called with: $appThemeMode'); // DEBUG

    switch (appThemeMode) {
      case AppThemeMode.light:
        print('Returning light theme'); // DEBUG
        return AppTheme.lightTheme;
      case AppThemeMode.dark:
        print('Returning dark theme'); // DEBUG
        return AppTheme.darkTheme;
      case AppThemeMode.auto:
        // Sistem temasını kullan
        final brightness = MediaQuery.of(context).platformBrightness;
        final autoTheme =
            brightness == Brightness.dark
                ? AppTheme.darkTheme
                : AppTheme.lightTheme;
        print(
          'Auto theme - brightness: $brightness, returning: ${brightness == Brightness.dark ? "dark" : "light"}',
        ); // DEBUG
        return autoTheme;
    }
  }
}
