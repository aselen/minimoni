import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

enum AppThemeMode { light, dark, auto }

class ThemeProvider extends ChangeNotifier {
  AppThemeMode _currentTheme = AppThemeMode.light;

  AppThemeMode get currentTheme => _currentTheme;

  ThemeProvider() {
    _loadTheme();
  }

  static const String _themeKey = 'app_theme';

  Future<void> _loadTheme() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final themeIndex = prefs.getInt(_themeKey) ?? 0;
      _currentTheme = AppThemeMode.values[themeIndex];
      print('Loaded theme from preferences: $_currentTheme'); // DEBUG
      notifyListeners();
    } catch (e) {
      print('Error loading theme: $e'); // DEBUG
      _currentTheme = AppThemeMode.light;
      notifyListeners();
    }
  }

  Future<void> setTheme(AppThemeMode theme) async {
    print('Setting theme to: $theme'); // DEBUG
    print('Previous theme was: $_currentTheme'); // DEBUG

    if (_currentTheme != theme) {
      _currentTheme = theme;
      print('Theme changed to: $_currentTheme'); // DEBUG

      // Hemen notify et
      notifyListeners();
      print('notifyListeners() called'); // DEBUG
    } else {
      print('Theme is already set to: $theme'); // DEBUG
    }

    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setInt(_themeKey, theme.index);
      print('Theme saved to preferences: ${theme.index}'); // DEBUG
    } catch (e) {
      print('Error saving theme: $e'); // DEBUG
    }
  }

  String getThemeDisplayName(AppThemeMode theme) {
    switch (theme) {
      case AppThemeMode.light:
        return 'Açık Tema';
      case AppThemeMode.dark:
        return 'Koyu Tema';
      case AppThemeMode.auto:
        return 'Sistem';
    }
  }

  String getThemeDescription(AppThemeMode theme) {
    switch (theme) {
      case AppThemeMode.light:
        return 'Açık renkli tema';
      case AppThemeMode.dark:
        return 'Koyu renkli tema';
      case AppThemeMode.auto:
        return 'Sistem ayarlarına göre';
    }
  }
}

final themeProvider = ChangeNotifierProvider<ThemeProvider>((ref) {
  return ThemeProvider();
});

// Tema modunu dinlemek için provider
final themeModeProvider = Provider<AppThemeMode>((ref) {
  final themeNotifier = ref.watch(themeProvider);
  final currentTheme = themeNotifier.currentTheme;
  print('themeModeProvider returning: $currentTheme'); // DEBUG
  return currentTheme;
});
