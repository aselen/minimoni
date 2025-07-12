import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../core/providers/theme_provider.dart';

// Import pages
import '../features/splash/splash_page.dart';
import '../features/onboarding/onboarding_page.dart';
import '../features/dashboard/dashboard_page.dart';
import '../features/feeding/feeding_page.dart';
import '../features/feeding/feeding_analysis_page.dart';
import '../features/sleep/sleep_page.dart';
import '../features/sleep/sleep_notification_page.dart';
import '../features/diaper/diaper_page.dart';
import '../features/memory/memory_page.dart';
import '../features/growth/growth_input_page.dart';
import '../features/growth/growth_analysis_page.dart';
import '../features/calendar/calendar_analysis_page.dart';
import '../features/profile/profile_page.dart';
import '../features/notifications/notifications_page.dart';
// import '../features/ai_assistant/ai_assistant_page.dart';

// Temporary placeholder page
class PlaceholderPage extends StatelessWidget {
  final String title;

  const PlaceholderPage({super.key, required this.title});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(title)),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.construction, size: 64, color: Colors.grey),
            const SizedBox(height: 16),
            Text(
              '$title Page',
              style: Theme.of(context).textTheme.headlineMedium,
            ),
            const SizedBox(height: 8),
            Text('Coming Soon!', style: Theme.of(context).textTheme.bodyMedium),
          ],
        ),
      ),
    );
  }
}

/// App Routes
class AppRoutes {
  static const splash = '/';
  static const onboarding = '/onboarding';
  static const dashboard = '/dashboard';
  static const feeding = '/feeding';
  static const sleep = '/sleep';
  static const diaper = '/diaper';
  static const growth = '/growth';
  static const aiAssistant = '/ai-assistant';
  static const diary = '/diary';
  static const profile = '/profile';
  static const settings = '/settings';
  static const notifications = '/notifications';
}

/// Router Provider
final routerProvider = Provider<GoRouter>((ref) {
  // Tema değişikliğini dinle
  ref.watch(themeModeProvider);

  return GoRouter(
    initialLocation: AppRoutes.splash,
    routes: [
      // Splash / Loading
      GoRoute(
        path: AppRoutes.splash,
        builder: (context, state) => const SplashPage(),
      ),

      // Onboarding
      GoRoute(
        path: AppRoutes.onboarding,
        builder: (context, state) => const OnboardingPage(),
      ),

      // Dashboard (Main)
      GoRoute(
        path: AppRoutes.dashboard,
        builder: (context, state) => const DashboardPage(),
        routes: [
          // Nested routes for main features
          GoRoute(
            path: 'feeding',
            builder: (context, state) => const FeedingPage(),
          ),
          GoRoute(
            path: 'feeding-analysis',
            builder: (context, state) => const FeedingAnalysisPage(),
          ),
          GoRoute(
            path: 'sleep',
            builder: (context, state) => const SleepPage(),
            routes: [
              GoRoute(
                path: 'notifications',
                builder: (context, state) => const SleepNotificationPage(),
              ),
            ],
          ),
          GoRoute(
            path: 'diaper',
            builder: (context, state) => const DiaperPage(),
          ),
          GoRoute(
            path: 'growth',
            builder: (context, state) => const GrowthInputPage(),
          ),
          GoRoute(
            path: 'growth-analysis',
            builder: (context, state) => const GrowthAnalysisPage(),
          ),
          GoRoute(
            path: 'calendar-analysis',
            builder: (context, state) => const CalendarAnalysisPage(),
          ),
          GoRoute(
            path: 'ai-assistant',
            builder:
                (context, state) =>
                    const PlaceholderPage(title: 'AI Assistant'),
          ),
          GoRoute(
            path: 'memory',
            builder: (context, state) => const MemoryPage(),
          ),
          GoRoute(
            path: 'profile',
            builder: (context, state) => const ProfilePage(),
          ),
          GoRoute(
            path: 'notifications',
            builder: (context, state) => const NotificationsPage(),
          ),
          GoRoute(
            path: 'settings',
            builder:
                (context, state) => const PlaceholderPage(title: 'Settings'),
          ),
        ],
      ),
    ],

    // Error handling
    errorBuilder:
        (context, state) => Scaffold(
          body: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.error_outline, size: 64, color: Colors.red),
                const SizedBox(height: 16),
                Text(
                  'Oops! Page not found',
                  style: Theme.of(context).textTheme.headlineMedium,
                ),
                const SizedBox(height: 8),
                Text(
                  state.error.toString(),
                  style: Theme.of(context).textTheme.bodySmall,
                ),
                const SizedBox(height: 16),
                ElevatedButton(
                  onPressed: () => context.go(AppRoutes.dashboard),
                  child: const Text('Go to Dashboard'),
                ),
              ],
            ),
          ),
        ),
  );
});
