import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../data/models/habit.dart';
import '../data/models/habit_enums.dart';
import '../data/repositories/habit_repository.dart';
import '../data/repositories/supabase_habit_repository.dart';

/// Provider for the habit repository singleton
final habitRepositoryProvider = Provider<HabitRepository>((ref) {
  return HabitRepository();
});

final supabaseHabitRepositoryProvider =
    Provider<SupabaseHabitRepository>((_) => SupabaseHabitRepository());

/// Provider for all active habits
final habitsProvider = StateNotifierProvider<HabitsNotifier, List<Habit>>((ref) {
  final repository = ref.watch(habitRepositoryProvider);
  final supabaseRepo = ref.watch(supabaseHabitRepositoryProvider);
  return HabitsNotifier(repository, supabaseRepo);
});

/// Provider for habits filtered by category
final habitsByCategoryProvider = Provider.family<List<Habit>, HabitCategory>((ref, category) {
  final habits = ref.watch(habitsProvider);
  return habits.where((h) => h.category == category).toList();
});

/// Provider for a single habit by ID
final habitByIdProvider = Provider.family<Habit?, String>((ref, id) {
  final habits = ref.watch(habitsProvider);
  try {
    return habits.firstWhere((h) => h.id == id);
  } catch (_) {
    return null;
  }
});

/// Provider for checking if user can add more habits
final canAddMoreHabitsProvider = Provider<bool>((ref) {
  final habits = ref.watch(habitsProvider);
  return habits.length < 6;
});

/// Provider for total active habits count
final activeHabitsCountProvider = Provider<int>((ref) {
  return ref.watch(habitsProvider).length;
});

/// Notifier for managing habits state
class HabitsNotifier extends StateNotifier<List<Habit>> {
  final HabitRepository _repository;
  final SupabaseHabitRepository _supabaseRepo;
  late final StreamSubscription<AuthState> _authSub;

  HabitsNotifier(this._repository, this._supabaseRepo) : super([]) {
    _loadHabits();
    _repository.addListener(_loadHabits);
    _loadFromSupabase();
    // Reload from Supabase whenever the user signs in (e.g. returning user).
    _authSub = Supabase.instance.client.auth.onAuthStateChange.listen((event) {
      if (event.event == AuthChangeEvent.signedIn ||
          event.event == AuthChangeEvent.tokenRefreshed) {
        _loadFromSupabase();
      } else if (event.event == AuthChangeEvent.signedOut) {
        _repository.replaceAll([]);
      }
    });
  }

  void _loadHabits() {
    state = _repository.getAll();
  }

  Future<void> _loadFromSupabase() async {
    final userId = Supabase.instance.client.auth.currentUser?.id;
    if (userId == null) return;
    try {
      final habits = await _supabaseRepo.fetchAll(userId);
      _repository.replaceAll(habits);
    } catch (e) {
      debugPrint('Supabase habit load failed: $e');
    }
  }

  String? get _userId => Supabase.instance.client.auth.currentUser?.id;

  void _syncHabit(Habit habit) {
    final userId = _userId;
    if (userId == null) return;
    _supabaseRepo.upsertHabit(habit, userId).catchError((Object e) {
      debugPrint('Supabase habit sync failed: $e');
    });
  }

  /// Add a new habit
  void addHabit(Habit habit) {
    _repository.add(habit);
    _syncHabit(habit);
  }

  /// Update an existing habit
  void updateHabit(Habit habit) {
    _repository.update(habit);
    _syncHabit(habit);
  }

  /// Archive a habit
  void archiveHabit(String id) {
    _repository.archive(id);
    final habit = _repository.getById(id);
    if (habit?.archivedAt != null) {
      _supabaseRepo
          .archiveHabit(id, habit!.archivedAt!)
          .catchError((Object e) => debugPrint('Supabase archive failed: $e'));
    }
  }

  /// Delete a habit permanently
  void deleteHabit(String id) {
    _repository.delete(id);
    _supabaseRepo
        .deleteHabit(id)
        .catchError((Object e) => debugPrint('Supabase delete failed: $e'));
  }

  /// Increment day number when completing a habit
  void incrementDayNumber(String id) {
    _repository.incrementDayNumber(id);
    final habit = _repository.getById(id);
    if (habit != null) _syncHabit(habit);
  }

  /// Update streak
  void updateStreak(String id, int newStreak) {
    _repository.updateStreak(id, newStreak);
    final habit = _repository.getById(id);
    if (habit != null) _syncHabit(habit);
  }

  @override
  void dispose() {
    _authSub.cancel();
    _repository.removeListener(_loadHabits);
    super.dispose();
  }
}

/// Enum for today's habit completion status
enum TodayStatus {
  notStarted,
  inProgress,
  completed;

  String get displayText {
    switch (this) {
      case TodayStatus.notStarted:
        return 'Not started';
      case TodayStatus.inProgress:
        return 'In progress';
      case TodayStatus.completed:
        return 'Completed';
    }
  }
}

/// Extended habit data with today's status
class HabitWithStatus {
  final Habit habit;
  final TodayStatus todayStatus;
  final int clipsRecorded;
  final int totalClipsNeeded;

  const HabitWithStatus({
    required this.habit,
    this.todayStatus = TodayStatus.notStarted,
    this.clipsRecorded = 0,
    this.totalClipsNeeded = 3,
  });

  String get progressText {
    if (todayStatus == TodayStatus.completed) {
      return 'Complete';
    } else if (clipsRecorded > 0) {
      return '$clipsRecorded/$totalClipsNeeded clips';
    }
    return todayStatus.displayText;
  }
}
