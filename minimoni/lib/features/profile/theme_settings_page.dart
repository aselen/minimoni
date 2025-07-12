import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../core/constants/colors.dart';
import '../../core/providers/theme_provider.dart';

class ThemeSettingsPage extends ConsumerStatefulWidget {
  const ThemeSettingsPage({super.key});

  @override
  ConsumerState<ThemeSettingsPage> createState() => _ThemeSettingsPageState();
}

class _ThemeSettingsPageState extends ConsumerState<ThemeSettingsPage> {
  AppThemeMode _localTheme = AppThemeMode.light;

  @override
  void initState() {
    super.initState();
    _localTheme = ref.read(themeProvider).currentTheme;
  }

  @override
  Widget build(BuildContext context) {
    final themeProviderInstance = ref.watch(themeProvider);
    final currentTheme = themeProviderInstance.currentTheme;

    return Scaffold(
      backgroundColor:
          _localTheme == AppThemeMode.dark ? Colors.black : Colors.grey.shade50,
      appBar: AppBar(
        backgroundColor:
            _localTheme == AppThemeMode.dark ? Colors.black : Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: Icon(
            Icons.arrow_back,
            color:
                _localTheme == AppThemeMode.dark
                    ? Colors.white
                    : AppColors.textDark,
          ),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: Text(
          'Tema Ayarları',
          style: GoogleFonts.inter(
            fontSize: 18,
            fontWeight: FontWeight.w600,
            color:
                _localTheme == AppThemeMode.dark
                    ? Colors.white
                    : AppColors.textDark,
          ),
        ),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Uygulama Teması',
              style: GoogleFonts.inter(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color:
                    _localTheme == AppThemeMode.dark
                        ? Colors.white
                        : AppColors.textDark,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Tercih ettiğiniz tema seçeneğini belirleyin',
              style: GoogleFonts.inter(
                fontSize: 14,
                color:
                    _localTheme == AppThemeMode.dark
                        ? Colors.grey[300]
                        : AppColors.textMedium,
              ),
            ),
            const SizedBox(height: 24),
            // TEST BUTTON
            ElevatedButton(
              onPressed: () {
                print('Test button pressed');
                setState(() {
                  _localTheme = AppThemeMode.dark;
                });
                themeProviderInstance.setTheme(AppThemeMode.dark);
              },
              child: Text('TEST: Koyu Temaya Geç'),
            ),
            const SizedBox(height: 12),
            _buildThemeOption(
              context,
              AppThemeMode.light,
              _localTheme,
              themeProviderInstance,
              'Açık Tema',
              'Açık renkli tema',
              Icons.wb_sunny,
              Colors.orange,
            ),
            const SizedBox(height: 12),
            _buildThemeOption(
              context,
              AppThemeMode.dark,
              _localTheme,
              themeProviderInstance,
              'Koyu Tema',
              'Koyu renkli tema',
              Icons.nightlight_round,
              Colors.indigo,
            ),
            const SizedBox(height: 12),
            _buildThemeOption(
              context,
              AppThemeMode.auto,
              _localTheme,
              themeProviderInstance,
              'Sistem',
              'Sistem ayarlarına göre',
              Icons.settings_system_daydream,
              Colors.green,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildThemeOption(
    BuildContext context,
    AppThemeMode theme,
    AppThemeMode currentTheme,
    ThemeProvider themeProvider,
    String title,
    String subtitle,
    IconData icon,
    Color iconColor,
  ) {
    final isSelected = currentTheme == theme;

    return Container(
      decoration: BoxDecoration(
        color:
            isSelected
                ? (_localTheme == AppThemeMode.dark
                    ? Colors.grey[800]
                    : AppColors.primaryPink.withOpacity(0.1))
                : (_localTheme == AppThemeMode.dark
                    ? Colors.grey[900]
                    : Colors.white),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color:
              isSelected
                  ? AppColors.primaryPink
                  : (_localTheme == AppThemeMode.dark
                      ? Colors.grey[700]!
                      : Colors.grey.shade200),
          width: isSelected ? 2 : 1,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
        leading: Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: iconColor.withOpacity(0.1),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(icon, color: iconColor, size: 24),
        ),
        title: Text(
          title,
          style: GoogleFonts.inter(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color:
                isSelected
                    ? AppColors.primaryPink
                    : (_localTheme == AppThemeMode.dark
                        ? Colors.white
                        : AppColors.textDark),
          ),
        ),
        subtitle: Text(
          subtitle,
          style: GoogleFonts.inter(
            fontSize: 14,
            color:
                _localTheme == AppThemeMode.dark
                    ? Colors.grey[300]
                    : AppColors.textMedium,
          ),
        ),
        trailing:
            isSelected
                ? Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: AppColors.primaryPink,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: const Icon(Icons.check, color: Colors.white, size: 16),
                )
                : null,
        onTap: () {
          print('Theme option tapped: $theme'); // DEBUG
          setState(() {
            _localTheme = theme;
          });
          themeProvider.setTheme(theme);
          // Navigator.of(context).pop(); // KALDIRILDI - Tema değişikliğini görmek için
        },
      ),
    );
  }
}
