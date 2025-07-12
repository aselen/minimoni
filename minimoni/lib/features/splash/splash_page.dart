import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../shared/widgets/logo_widget.dart';
import '../../app/router.dart';
import '../../core/constants/colors.dart';
import '../../core/services/baby_storage_service.dart';

/// MiniMoni Splash Screen
/// Beautiful animated splash screen with logo
class SplashPage extends ConsumerStatefulWidget {
  const SplashPage({super.key});

  @override
  ConsumerState<SplashPage> createState() => _SplashPageState();
}

class _SplashPageState extends ConsumerState<SplashPage>
    with TickerProviderStateMixin {
  late AnimationController _fadeController;
  late AnimationController _scaleController;
  late Animation<double> _fadeAnimation;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();

    // Initialize animations
    _fadeController = AnimationController(
      duration: const Duration(milliseconds: 1200),
      vsync: this,
    );

    _scaleController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _fadeController, curve: Curves.easeInOut),
    );

    _scaleAnimation = Tween<double>(begin: 0.8, end: 1.0).animate(
      CurvedAnimation(parent: _scaleController, curve: Curves.elasticOut),
    );

    // Start animations
    _startAnimations();

    // Navigate to next screen after delay
    _navigateToNext();
  }

  void _startAnimations() async {
    await Future.delayed(const Duration(milliseconds: 300));
    _scaleController.forward();
    await Future.delayed(const Duration(milliseconds: 200));
    _fadeController.forward();
  }

  void _navigateToNext() async {
    await Future.delayed(const Duration(milliseconds: 3000));

    if (mounted) {
      try {
        // Onboarding tamamlandı mı kontrol et
        final isOnboardingComplete =
            await BabyStorageService.instance.isOnboardingComplete();
        final hasBaby = await BabyStorageService.instance.hasBaby();

        if (isOnboardingComplete && hasBaby) {
          // Onboarding tamamlanmış, dashboard'a git
          context.go(AppRoutes.dashboard);
        } else {
          // Onboarding tamamlanmamış, onboarding'e git
          context.go(AppRoutes.onboarding);
        }
      } catch (e) {
        print('Onboarding durumu kontrol edilemedi: $e');
        // Hata durumunda onboarding'e yönlendir
        context.go(AppRoutes.onboarding);
      }
    }
  }

  @override
  void dispose() {
    _fadeController.dispose();
    _scaleController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(gradient: AppColors.softGradient),
        child: SafeArea(
          child: Column(
            children: [
              // Top spacer
              const Spacer(flex: 2),

              // Logo and title
              Center(
                child: AnimatedBuilder(
                  animation: Listenable.merge([
                    _fadeAnimation,
                    _scaleAnimation,
                  ]),
                  builder: (context, child) {
                    return Transform.scale(
                      scale: _scaleAnimation.value,
                      child: Opacity(
                        opacity: _fadeAnimation.value,
                        child: const LogoWidget(size: 160, showText: true),
                      ),
                    );
                  },
                ),
              ),

              // Middle spacer
              const Spacer(flex: 1),

              // Loading indicator
              AnimatedBuilder(
                animation: _fadeAnimation,
                builder: (context, child) {
                  return Opacity(
                    opacity: _fadeAnimation.value * 0.7,
                    child: Column(
                      children: [
                        SizedBox(
                          width: 32,
                          height: 32,
                          child: CircularProgressIndicator(
                            strokeWidth: 3,
                            valueColor: AlwaysStoppedAnimation<Color>(
                              AppColors.primaryPink.withOpacity(0.8),
                            ),
                          ),
                        ),
                        const SizedBox(height: 16),
                        Text(
                          'Bebeğiniz için hazırlanıyor...',
                          style: Theme.of(
                            context,
                          ).textTheme.bodyMedium?.copyWith(
                            color: AppColors.textLight,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  );
                },
              ),

              // Bottom spacer
              const Spacer(flex: 2),

              // Bottom info
              AnimatedBuilder(
                animation: _fadeAnimation,
                builder: (context, child) {
                  return Opacity(
                    opacity: _fadeAnimation.value * 0.5,
                    child: Padding(
                      padding: const EdgeInsets.all(24),
                      child: Column(
                        children: [
                          Text(
                            '✨ AI Destekli Bebek Takibi',
                            style: Theme.of(context).textTheme.bodySmall
                                ?.copyWith(color: AppColors.textLight),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'v1.0.0',
                            style: Theme.of(
                              context,
                            ).textTheme.bodySmall?.copyWith(
                              color: AppColors.textDisabled,
                              fontSize: 10,
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
