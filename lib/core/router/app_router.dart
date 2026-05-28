import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../features/auth/presentation/screens/login_screen.dart';
import '../../features/auth/presentation/screens/signup_screen.dart';
import '../../features/auth/providers/auth_provider.dart';
import '../../features/habits/presentation/screens/habits_home_screen.dart';
import '../../features/habits/presentation/screens/create_habit_screen.dart';
import '../../features/habits/presentation/screens/habit_detail_screen.dart';
import '../../features/journey/presentation/screens/journey_screen.dart';
import '../../features/journey/presentation/screens/habit_journey_screen.dart';
import '../../features/journey/presentation/screens/vlog_player_screen.dart';
import '../../features/onboarding/presentation/screens/onboarding_screen.dart';
import '../../features/recording/presentation/screens/record_screen.dart';
import '../../features/recording/presentation/screens/camera_screen.dart';
import '../../features/gamification/presentation/screens/stats_screen.dart';
import '../../features/settings/presentation/screens/profile_screen.dart';
import '../../shared/widgets/layout/app_bottom_nav.dart';
import '../theme/app_colors.dart';
import 'go_router_refresh_stream.dart';

final _rootNavigatorKey = GlobalKey<NavigatorState>();
final _shellNavigatorKey = GlobalKey<NavigatorState>();

final appRouterProvider = Provider<GoRouter>((ref) {
  // GoRouter is created once and never recreated on auth changes.
  // The refreshListenable fires when auth state changes, causing GoRouter to
  // re-evaluate redirect. We read current auth state inside the callback
  // (not from a closure) so it always reflects the latest session.
  return GoRouter(
    navigatorKey: _rootNavigatorKey,
    initialLocation: '/home',
    refreshListenable: GoRouterRefreshStream(
      Supabase.instance.client.auth.onAuthStateChange,
    ),
    redirect: (context, state) {
      final isLoggedIn = Supabase.instance.client.auth.currentUser != null;
      final onboardingComplete = ref.read(onboardingCompleteProvider);
      final location = state.matchedLocation;
      final authPages = {'/login', '/signup', '/onboarding'};

      if (!isLoggedIn && !onboardingComplete) {
        if (!authPages.contains(location)) return '/onboarding';
        return null;
      }

      if (!isLoggedIn && onboardingComplete) {
        if (!authPages.contains(location)) return '/login';
        return null;
      }

      // Logged in — bounce away from auth screens
      if (authPages.contains(location)) return '/home';

      return null;
    },
    routes: [
      GoRoute(
        path: '/onboarding',
        name: 'onboarding',
        parentNavigatorKey: _rootNavigatorKey,
        builder: (context, state) => const OnboardingScreen(),
      ),
      GoRoute(
        path: '/login',
        name: 'login',
        parentNavigatorKey: _rootNavigatorKey,
        builder: (context, state) => const LoginScreen(),
      ),
      GoRoute(
        path: '/signup',
        name: 'signup',
        parentNavigatorKey: _rootNavigatorKey,
        builder: (context, state) => const SignUpScreen(),
      ),

      // Shell route with bottom navigation
      ShellRoute(
        navigatorKey: _shellNavigatorKey,
        builder: (context, state, child) {
          return AppBottomNav(child: child);
        },
        routes: [
          GoRoute(
            path: '/home',
            name: 'home',
            builder: (context, state) => const HabitsHomeScreen(),
          ),
          GoRoute(
            path: '/journey',
            name: 'journey',
            builder: (context, state) => const JourneyScreen(),
          ),
          GoRoute(
            path: '/record',
            name: 'record',
            builder: (context, state) => const RecordScreen(),
          ),
          GoRoute(
            path: '/stats',
            name: 'stats',
            builder: (context, state) => const StatsScreen(),
          ),
          GoRoute(
            path: '/profile',
            name: 'profile',
            builder: (context, state) => const ProfileScreen(),
          ),
        ],
      ),

      // Full-screen routes (no bottom nav)
      GoRoute(
        path: '/create-habit',
        name: 'createHabit',
        parentNavigatorKey: _rootNavigatorKey,
        builder: (context, state) => const CreateHabitScreen(),
      ),
      GoRoute(
        path: '/habit/:id',
        name: 'habitDetail',
        parentNavigatorKey: _rootNavigatorKey,
        builder: (context, state) {
          final habitId = state.pathParameters['id']!;
          return HabitDetailScreen(habitId: habitId);
        },
      ),
      GoRoute(
        path: '/camera/:habitId',
        name: 'camera',
        parentNavigatorKey: _rootNavigatorKey,
        builder: (context, state) {
          final habitId = state.pathParameters['habitId']!;
          final extra = state.extra as Map<String, dynamic>?;
          return CameraScreen(
            habitId: habitId,
            habitName: extra?['habitName'] as String? ?? 'Unknown',
            dayNumber: extra?['dayNumber'] as int? ?? 1,
            habitColor: extra?['habitColor'] as Color? ?? AppColors.primary,
          );
        },
      ),
      GoRoute(
        path: '/habit/:id/journey',
        name: 'habitJourney',
        parentNavigatorKey: _rootNavigatorKey,
        builder: (context, state) {
          final habitId = state.pathParameters['id']!;
          return HabitJourneyScreen(habitId: habitId);
        },
      ),
      GoRoute(
        path: '/vlog/:id',
        name: 'vlogPlayer',
        parentNavigatorKey: _rootNavigatorKey,
        builder: (context, state) {
          final vlogId = state.pathParameters['id']!;
          return VlogPlayerScreen(vlogId: vlogId);
        },
      ),
    ],
  );
});
