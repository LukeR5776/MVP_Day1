import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../data/models/habit.dart';
import '../data/models/habit_enums.dart';
import '../data/repositories/habit_repository.dart';

/// Provider for the habit repository singleton
final habitRepositoryProvider = Provider<HabitRepository>((ref) {
  return HabitRepository();
});

/// Provider for all active habits
final habitsProvider = StateNotifierProvider<HabitsNotifier, List<Habit>>((ref) {
  final repository = ref.watch(habitRepositoryProvider);
  return HabitsNotifier(repository);
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

  HabitsNotifier(this._repository) : super([]) {
    // Load initial habits
    _loadHabits();
    // Listen to repository changes
    _repository.addListener(_loadHabits);
  }

  void _loadHabits() {
    state = _repository.getAll();
  }

  /// Add a new habit
  void addHabit(Habit habit) {
    _repository.add(habit);
  }

  /// Update an existing habit
  void updateHabit(Habit habit) {
    _repository.update(habit);
  }

  /// Archive a habit
  void archiveHabit(String id) {
    _repository.archive(id);
  }

  /// Delete a habit permanently
  void deleteHabit(String id) {
    _repository.delete(id);
  }

  /// Increment day number when completing a habit
  void incrementDayNumber(String id) {
    _repository.incrementDayNumber(id);
  }

  /// Update streak
  void updateStreak(String id, int newStreak) {
    _repository.updateStreak(id, newStreak);
  }

  @override
  void dispose() {
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
