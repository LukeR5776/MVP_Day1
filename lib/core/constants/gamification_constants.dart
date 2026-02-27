import 'dart:math' as math;

/// Gamification constants matching the development plan
class GamificationConstants {
  // XP Rewards
  static const int xpIntentionClip = 10;
  static const int xpEvidenceClip = 15;
  static const int xpReflectionClip = 10;
  static const int xpCompleteDailyLog = 25;
  static const int xpCompileVlog = 15;

  // Daily Bonuses
  static const int xpFirstHabitOfDay = 20;
  static const int xpEarlyBird = 15; // Before 8 AM
  static const int xpNightOwl = 10; // After 10 PM
  static const int xpCompleteAllHabits = 50;

  // Streak Multipliers
  static const Map<int, double> streakMultipliers = {
    3: 1.1,
    7: 1.25,
    14: 1.5,
    30: 2.0,
    100: 3.0,
  };

  /// Calculate XP required for a given level
  /// Formula: 100 × (level ^ 1.5)
  static int xpForLevel(int level) {
    if (level <= 1) return 0;
    return (100 * math.pow(level, 1.5)).round();
  }

  /// Get streak multiplier based on current streak
  static double getStreakMultiplier(int streakDays) {
    double multiplier = 1.0;
    for (final entry in streakMultipliers.entries) {
      if (streakDays >= entry.key) {
        multiplier = entry.value;
      }
    }
    return multiplier;
  }
}
