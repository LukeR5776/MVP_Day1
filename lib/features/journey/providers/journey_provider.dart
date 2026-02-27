import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../recording/data/models/vlog.dart';
import '../../recording/providers/recording_provider.dart';
import '../../habits/providers/habits_provider.dart';
import '../../habits/data/models/habit_enums.dart';

/// View mode for journey gallery
enum JourneyViewMode { grid, calendar, timeline }

/// Provider for current view mode in gallery
final journeyViewModeProvider = StateProvider<JourneyViewMode>((ref) {
  return JourneyViewMode.grid;
});

/// Provider for all vlogs (main gallery)
/// Watches repository state to rebuild when vlogs are added/removed
final allVlogsProvider = Provider<List<Vlog>>((ref) {
  final state = ref.watch(recordingRepositoryProvider);
  return state.vlogs.values.toList()..sort((a, b) => b.date.compareTo(a.date));
});

/// Provider for vlogs filtered by habit
final habitVlogsProvider = Provider.family<List<Vlog>, String>((ref, habitId) {
  final state = ref.watch(recordingRepositoryProvider);
  return state.vlogs.values
      .where((vlog) => vlog.habitId == habitId)
      .toList()
    ..sort((a, b) => b.date.compareTo(a.date));
});

/// Provider for a single vlog by ID
final vlogByIdProvider = Provider.family<Vlog?, String>((ref, vlogId) {
  final state = ref.watch(recordingRepositoryProvider);
  return state.vlogs[vlogId];
});

/// Grouped vlogs by habit name for gallery display
final vlogsGroupedByHabitProvider = Provider<Map<String, List<Vlog>>>((ref) {
  final vlogs = ref.watch(allVlogsProvider);
  final grouped = <String, List<Vlog>>{};

  for (final vlog in vlogs) {
    final habitName = vlog.habitName;
    if (!grouped.containsKey(habitName)) {
      grouped[habitName] = [];
    }
    grouped[habitName]!.add(vlog);
  }

  // Sort each group by day number
  for (final key in grouped.keys) {
    grouped[key]!.sort((a, b) => a.dayNumber.compareTo(b.dayNumber));
  }

  return grouped;
});

/// Journey state for a specific habit
class HabitJourneyState {
  final String habitId;
  final String habitName;
  final List<Vlog> vlogs;
  final int totalDays;
  final HabitCategory category;
  final int currentStreak;

  const HabitJourneyState({
    required this.habitId,
    required this.habitName,
    required this.vlogs,
    required this.totalDays,
    required this.category,
    required this.currentStreak,
  });

  int get completedDays => vlogs.length;

  bool get hasVlogs => vlogs.isNotEmpty;

  /// Get vlog for a specific day number
  Vlog? getVlogForDay(int dayNumber) {
    try {
      return vlogs.firstWhere((v) => v.dayNumber == dayNumber);
    } catch (_) {
      return null;
    }
  }

  /// Get vlog for a specific date
  Vlog? getVlogForDate(DateTime date) {
    try {
      return vlogs.firstWhere((v) =>
          v.date.year == date.year &&
          v.date.month == date.month &&
          v.date.day == date.day);
    } catch (_) {
      return null;
    }
  }
}

/// Provider for habit journey state
final habitJourneyProvider =
    Provider.family<HabitJourneyState, String>((ref, habitId) {
  final habit = ref.watch(habitByIdProvider(habitId));
  final vlogs = ref.watch(habitVlogsProvider(habitId));

  return HabitJourneyState(
    habitId: habitId,
    habitName: habit?.name ?? 'Unknown Habit',
    vlogs: vlogs,
    totalDays: habit?.currentDayNumber ?? 0,
    category: habit?.category ?? HabitCategory.physical,
    currentStreak: habit?.currentStreak ?? 0,
  );
});

/// State notifier for managing vlog operations
class VlogOperationsNotifier extends StateNotifier<AsyncValue<void>> {
  final Ref ref;

  VlogOperationsNotifier(this.ref) : super(const AsyncValue.data(null));

  /// Delete a vlog
  Future<bool> deleteVlog(String vlogId) async {
    state = const AsyncValue.loading();
    try {
      final repository = ref.read(recordingRepositoryProvider.notifier);
      await repository.deleteVlog(vlogId);
      state = const AsyncValue.data(null);
      return true;
    } catch (e, st) {
      state = AsyncValue.error(e, st);
      return false;
    }
  }

  /// Mark vlog as shared
  void markAsShared(String vlogId) {
    final repository = ref.read(recordingRepositoryProvider.notifier);
    repository.markVlogAsShared(vlogId);
  }
}

/// Provider for vlog operations
final vlogOperationsProvider =
    StateNotifierProvider<VlogOperationsNotifier, AsyncValue<void>>((ref) {
  return VlogOperationsNotifier(ref);
});
