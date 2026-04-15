import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../data/models/user_progress.dart';
import '../data/models/achievement.dart';
import '../data/repositories/progress_repository.dart';
import '../../habits/data/models/habit.dart';
import '../../habits/providers/habits_provider.dart';
import '../../recording/data/repositories/recording_repository.dart';
import '../../recording/providers/recording_provider.dart';
import '../../recording/data/models/daily_log.dart';

// ── Provider ──────────────────────────────────────────────────────────────────

final gamificationProvider =
    StateNotifierProvider<GamificationNotifier, UserProgress>((ref) {
  return GamificationNotifier(ref);
});

// ── Result type ───────────────────────────────────────────────────────────────

/// Result returned after awarding XP for a completed vlog.
class GamificationResult {
  final int xpAwarded;
  final int? newLevel; // non-null if a level-up occurred
  final List<Achievement> unlockedAchievements;
  final int newStreak;
  final double streakMultiplier;

  const GamificationResult({
    required this.xpAwarded,
    this.newLevel,
    required this.unlockedAchievements,
    required this.newStreak,
    required this.streakMultiplier,
  });
}

// ── Notifier ──────────────────────────────────────────────────────────────────

class GamificationNotifier extends StateNotifier<UserProgress> {
  final Ref _ref;
  final ProgressRepository _repo = ProgressRepository();

  GamificationNotifier(this._ref) : super(const UserProgress()) {
    _load();
  }

  Future<void> _load() async {
    state = await _repo.load();
  }

  // ── XP for completing a vlog ───────────────────────────────────────────────

  /// Awards XP after a daily vlog is compiled.
  ///
  /// Also updates the habit's streak and day number, checks achievements,
  /// and persists the updated progress.
  Future<GamificationResult> awardXpForCompletion({
    required Habit habit,
    required int totalVlogCount,
    required int totalSeconds,
    required RecordingRepositoryState recordingState,
  }) async {
    final habitsNotifier = _ref.read(habitsProvider.notifier);

    // ── 1. Calculate new streak ────────────────────────────────────────────
    final yesterday = DateTime.now().subtract(const Duration(days: 1));
    final yesterdayKey =
        '${habit.id}_${yesterday.toIso8601String().split('T')[0]}';
    final yesterdayCompiled =
        recordingState.dailyLogs[yesterdayKey]?.status ==
            DailyLogStatus.vlogCompiled;

    final newStreak = yesterdayCompiled ? habit.currentStreak + 1 : 1;

    // ── 2. Update habit (streak + day number) ─────────────────────────────
    habitsNotifier.updateStreak(habit.id, newStreak);
    habitsNotifier.incrementDayNumber(habit.id);

    // ── 3. Read updated habits for achievement checking ───────────────────
    final updatedHabits = _ref.read(habitsProvider);

    // ── 4. Calculate XP with streak multiplier ────────────────────────────
    const int baseXP = 75;
    final multiplier = _streakMultiplier(newStreak);
    final xpAwarded = (baseXP * multiplier).round();

    // ── 5. Build updated UserProgress (before achievements) ───────────────
    final prev = state;
    var next = prev.copyWith(
      totalXP: prev.totalXP + xpAwarded,
      totalVlogsCreated: totalVlogCount,
      totalRecordingSeconds: totalSeconds,
    );

    // ── 6. Check achievements ─────────────────────────────────────────────
    final newAchievements = AchievementChecker.checkNewlyUnlocked(
      prev: prev,
      next: next,
      habits: updatedHabits,
      recordingState: recordingState,
    );

    // ── 7. Award achievement XP + add IDs ─────────────────────────────────
    if (newAchievements.isNotEmpty) {
      final achievementXP =
          newAchievements.fold<int>(0, (sum, a) => sum + a.xpReward);
      next = next.copyWith(
        totalXP: next.totalXP + achievementXP,
        unlockedAchievementIds: [
          ...next.unlockedAchievementIds,
          ...newAchievements.map((a) => a.id),
        ],
      );
    }

    // ── 8. Detect level-up ────────────────────────────────────────────────
    final int? levelUp = next.level > prev.level ? next.level : null;

    // ── 9. Persist ────────────────────────────────────────────────────────
    state = next;
    await _repo.save(state);

    return GamificationResult(
      xpAwarded: xpAwarded,
      newLevel: levelUp,
      unlockedAchievements: newAchievements,
      newStreak: newStreak,
      streakMultiplier: multiplier,
    );
  }

  // ── XP for sharing a vlog ─────────────────────────────────────────────────

  Future<void> awardXpForShare() async {
    const int shareXP = 10;
    final prev = state;
    final next = prev.copyWith(
      totalXP: prev.totalXP + shareXP,
      totalVlogsShared: prev.totalVlogsShared + 1,
    );

    // Check social achievements
    final newAchievements = AchievementChecker.checkNewlyUnlocked(
      prev: prev,
      next: next,
      habits: _ref.read(habitsProvider),
      recordingState: _ref.read(recordingRepositoryProvider),
    );

    if (newAchievements.isNotEmpty) {
      final achievementXP =
          newAchievements.fold<int>(0, (sum, a) => sum + a.xpReward);
      state = next.copyWith(
        totalXP: next.totalXP + achievementXP,
        unlockedAchievementIds: [
          ...next.unlockedAchievementIds,
          ...newAchievements.map((a) => a.id),
        ],
      );
    } else {
      state = next;
    }

    await _repo.save(state);
  }

  // ── Helpers ───────────────────────────────────────────────────────────────

  static double _streakMultiplier(int streak) {
    if (streak >= 100) return 3.0;
    if (streak >= 30) return 2.0;
    if (streak >= 14) return 1.5;
    if (streak >= 7) return 1.25;
    if (streak >= 3) return 1.1;
    return 1.0;
  }
}
