import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../features/habits/presentation/screens/habits_home_screen.dart';
import '../../features/habits/presentation/screens/create_habit_screen.dart';
import '../../features/habits/presentation/screens/habit_detail_screen.dart';
import '../../features/journey/presentation/screens/journey_screen.dart';
import '../../features/journey/presentation/screens/habit_journey_screen.dart';
import '../../features/journey/presentation/screens/vlog_player_screen.dart';
import '../../features/recording/presentation/screens/record_screen.dart';
import '../../features/recording/presentation/screens/camera_screen.dart';
import '../../features/gamification/presentation/screens/stats_screen.dart';
import '../../features/settings/presentation/screens/profile_screen.dart';
import '../../shared/widgets/layout/app_bottom_nav.dart';
import '../theme/app_colors.dart';

class AppRouter {
  static final _rootNavigatorKey = GlobalKey<NavigatorState>();
  static final _shellNavigatorKey = GlobalKey<NavigatorState>();

  static final router = GoRouter(
    navigatorKey: _rootNavigatorKey,
    initialLocation: '/home',
    routes: [
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
      // Habit-specific journey screen
      GoRoute(
        path: '/habit/:id/journey',
        name: 'habitJourney',
        parentNavigatorKey: _rootNavigatorKey,
        builder: (context, state) {
          final habitId = state.pathParameters['id']!;
          return HabitJourneyScreen(habitId: habitId);
        },
      ),
      // Vlog player screen
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
}
