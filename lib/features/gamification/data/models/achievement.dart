import 'package:flutter/material.dart';
import '../../../habits/data/models/habit.dart';
import '../../../habits/data/models/habit_enums.dart';
import '../../../recording/data/repositories/recording_repository.dart';
import 'user_progress.dart';

// ── Rarity ───────────────────────────────────────────────────────────────────

enum AchievementRarity {
  common,
  uncommon,
  rare,
  epic,
  legendary;

  Color get color {
    switch (this) {
      case AchievementRarity.common:
        return const Color(0xFFA3A3A3);
      case AchievementRarity.uncommon:
        return const Color(0xFF22C55E);
      case AchievementRarity.rare:
        return const Color(0xFF3B82F6);
      case AchievementRarity.epic:
        return const Color(0xFFA855F7);
      case AchievementRarity.legendary:
        return const Color(0xFFF59E0B);
    }
  }

  String get displayName {
    switch (this) {
      case AchievementRarity.common:
        return 'Common';
      case AchievementRarity.uncommon:
        return 'Uncommon';
      case AchievementRarity.rare:
        return 'Rare';
      case AchievementRarity.epic:
        return 'Epic';
      case AchievementRarity.legendary:
        return 'Legendary';
    }
  }
}

// ── Achievement model ─────────────────────────────────────────────────────────

class Achievement {
  final String id;
  final String title;
  final String description;
  final String emoji;
  final AchievementRarity rarity;
  final int xpReward;

  const Achievement({
    required this.id,
    required this.title,
    required this.description,
    required this.emoji,
    required this.rarity,
    required this.xpReward,
  });
}

// ── Definitions ───────────────────────────────────────────────────────────────

class AchievementDefinitions {
  static const List<Achievement> all = [
    // Streak achievements
    Achievement(
      id: 'streak_3',
      title: 'First Flame',
      description: 'Maintain a 3-day streak on any habit.',
      emoji: '🔥',
      rarity: AchievementRarity.common,
      xpReward: 50,
    ),
    Achievement(
      id: 'streak_7',
      title: 'Week Warrior',
      description: 'Maintain a 7-day streak on any habit.',
      emoji: '🔥🔥',
      rarity: AchievementRarity.common,
      xpReward: 100,
    ),
    Achievement(
      id: 'streak_14',
      title: 'Fortnight Fighter',
      description: 'Maintain a 14-day streak on any habit.',
      emoji: '🔥',
      rarity: AchievementRarity.uncommon,
      xpReward: 200,
    ),
    Achievement(
      id: 'streak_30',
      title: 'Monthly Master',
      description: 'Maintain a 30-day streak on any habit.',
      emoji: '🔥',
      rarity: AchievementRarity.rare,
      xpReward: 500,
    ),
    Achievement(
      id: 'streak_90',
      title: 'Quarter Crusher',
      description: 'Maintain a 90-day streak on any habit.',
      emoji: '🔥',
      rarity: AchievementRarity.epic,
      xpReward: 1000,
    ),
    Achievement(
      id: 'streak_100',
      title: 'Centurion',
      description: 'Maintain a 100-day streak on any habit.',
      emoji: '💎🔥',
      rarity: AchievementRarity.epic,
      xpReward: 1500,
    ),

    // Vlog count achievements
    Achievement(
      id: 'vlogs_1',
      title: 'Day 1',
      description: 'Create your first vlog.',
      emoji: '🎬',
      rarity: AchievementRarity.common,
      xpReward: 25,
    ),
    Achievement(
      id: 'vlogs_10',
      title: 'Getting Started',
      description: 'Create 10 total vlogs.',
      emoji: '🎬',
      rarity: AchievementRarity.common,
      xpReward: 50,
    ),
    Achievement(
      id: 'vlogs_30',
      title: 'Consistent',
      description: 'Create 30 total vlogs.',
      emoji: '🎬',
      rarity: AchievementRarity.common,
      xpReward: 75,
    ),
    Achievement(
      id: 'vlogs_50',
      title: 'Content Creator',
      description: 'Create 50 total vlogs.',
      emoji: '🎬',
      rarity: AchievementRarity.uncommon,
      xpReward: 150,
    ),
    Achievement(
      id: 'vlogs_100',
      title: 'Prolific',
      description: 'Create 100 total vlogs.',
      emoji: '🎬',
      rarity: AchievementRarity.rare,
      xpReward: 300,
    ),

    // Social achievements
    Achievement(
      id: 'share_1',
      title: 'Social Butterfly',
      description: 'Share your first vlog.',
      emoji: '📱',
      rarity: AchievementRarity.common,
      xpReward: 50,
    ),
    Achievement(
      id: 'share_10',
      title: 'Influencer',
      description: 'Share 10 vlogs.',
      emoji: '📱',
      rarity: AchievementRarity.uncommon,
      xpReward: 150,
    ),

    // Category starters
    Achievement(
      id: 'cat_physical_7',
      title: 'Physical Starter',
      description: 'Complete 7 days on a Physical habit.',
      emoji: '💪',
      rarity: AchievementRarity.common,
      xpReward: 75,
    ),
    Achievement(
      id: 'cat_mental_7',
      title: 'Mental Starter',
      description: 'Complete 7 days on a Mental habit.',
      emoji: '🧠',
      rarity: AchievementRarity.common,
      xpReward: 75,
    ),
    Achievement(
      id: 'cat_creative_7',
      title: 'Creative Starter',
      description: 'Complete 7 days on a Creative habit.',
      emoji: '🎨',
      rarity: AchievementRarity.common,
      xpReward: 75,
    ),
    Achievement(
      id: 'cat_growth_7',
      title: 'Growth Starter',
      description: 'Complete 7 days on a Growth habit.',
      emoji: '🌱',
      rarity: AchievementRarity.common,
      xpReward: 75,
    ),

    // Category champions
    Achievement(
      id: 'cat_physical_30',
      title: 'Physical Champion',
      description: 'Complete 30 days on a Physical habit.',
      emoji: '💪',
      rarity: AchievementRarity.uncommon,
      xpReward: 200,
    ),
    Achievement(
      id: 'cat_mental_30',
      title: 'Mental Champion',
      description: 'Complete 30 days on a Mental habit.',
      emoji: '🧠',
      rarity: AchievementRarity.uncommon,
      xpReward: 200,
    ),
    Achievement(
      id: 'cat_creative_30',
      title: 'Creative Champion',
      description: 'Complete 30 days on a Creative habit.',
      emoji: '🎨',
      rarity: AchievementRarity.uncommon,
      xpReward: 200,
    ),
    Achievement(
      id: 'cat_growth_30',
      title: 'Growth Champion',
      description: 'Complete 30 days on a Growth habit.',
      emoji: '🌱',
      rarity: AchievementRarity.uncommon,
      xpReward: 200,
    ),

    // Special achievements
    Achievement(
      id: 'balanced',
      title: 'Balanced',
      description: 'Have an active habit in all 4 categories.',
      emoji: '⚖️',
      rarity: AchievementRarity.uncommon,
      xpReward: 200,
    ),
    Achievement(
      id: 'collector',
      title: 'Collector',
      description: 'Have 6 active habits at once.',
      emoji: '📚',
      rarity: AchievementRarity.uncommon,
      xpReward: 150,
    ),
    Achievement(
      id: 'level_5',
      title: 'Rising Up',
      description: 'Reach Level 5.',
      emoji: '⭐',
      rarity: AchievementRarity.common,
      xpReward: 100,
    ),
    Achievement(
      id: 'level_10',
      title: 'Double Digits',
      description: 'Reach Level 10.',
      emoji: '⭐⭐',
      rarity: AchievementRarity.rare,
      xpReward: 300,
    ),
    Achievement(
      id: 'marathon',
      title: 'Marathon',
      description: 'Record 100+ minutes of footage total.',
      emoji: '🕐',
      rarity: AchievementRarity.rare,
      xpReward: 300,
    ),
    Achievement(
      id: 'multi_flame',
      title: 'Multi-Flame',
      description: 'Maintain a 7-day streak on 3 or more habits at once.',
      emoji: '🔥🔥🔥',
      rarity: AchievementRarity.rare,
      xpReward: 300,
    ),
    Achievement(
      id: 'comeback_kid',
      title: 'Comeback Kid',
      description: 'Record a vlog after a 7+ day break.',
      emoji: '💪',
      rarity: AchievementRarity.uncommon,
      xpReward: 150,
    ),
    Achievement(
      id: 'early_adopter',
      title: 'Early Adopter',
      description: 'Create 7 vlogs within the first 10 days.',
      emoji: '🚀',
      rarity: AchievementRarity.rare,
      xpReward: 250,
    ),
    Achievement(
      id: 'perfect_week',
      title: 'Perfect Week',
      description: 'All active habits reach a 7-day streak simultaneously.',
      emoji: '🗓️',
      rarity: AchievementRarity.uncommon,
      xpReward: 250,
    ),
  ];

  static Achievement? byId(String id) {
    try {
      return all.firstWhere((a) => a.id == id);
    } catch (_) {
      return null;
    }
  }
}

// ── Checker ───────────────────────────────────────────────────────────────────

class AchievementChecker {
  /// Returns achievements newly unlocked by moving from [prev] to [next] state.
  ///
  /// [habits] should be the updated habits list (post-streak + day increment).
  /// Achievement IDs already in [prev.unlockedAchievementIds] are excluded.
  static List<Achievement> checkNewlyUnlocked({
    required UserProgress prev,
    required UserProgress next,
    required List<Habit> habits,
    required RecordingRepositoryState recordingState,
  }) {
    final alreadyUnlocked = prev.unlockedAchievementIds.toSet();
    final result = <Achievement>[];

    for (final achievement in AchievementDefinitions.all) {
      if (alreadyUnlocked.contains(achievement.id)) continue;
      if (_isMet(achievement.id, next, habits, recordingState)) {
        result.add(achievement);
      }
    }

    return result;
  }

  static bool _isMet(
    String id,
    UserProgress progress,
    List<Habit> habits,
    RecordingRepositoryState recordingState,
  ) {
    switch (id) {
      // ── Streak ──────────────────────────────────────────────────────────────
      case 'streak_3':
        return habits.any((h) => h.currentStreak >= 3);
      case 'streak_7':
        return habits.any((h) => h.currentStreak >= 7);
      case 'streak_14':
        return habits.any((h) => h.currentStreak >= 14);
      case 'streak_30':
        return habits.any((h) => h.currentStreak >= 30);
      case 'streak_90':
        return habits.any((h) => h.currentStreak >= 90);
      case 'streak_100':
        return habits.any((h) => h.currentStreak >= 100);

      // ── Vlog counts ──────────────────────────────────────────────────────────
      case 'vlogs_1':
        return progress.totalVlogsCreated >= 1;
      case 'vlogs_10':
        return progress.totalVlogsCreated >= 10;
      case 'vlogs_30':
        return progress.totalVlogsCreated >= 30;
      case 'vlogs_50':
        return progress.totalVlogsCreated >= 50;
      case 'vlogs_100':
        return progress.totalVlogsCreated >= 100;

      // ── Social ───────────────────────────────────────────────────────────────
      case 'share_1':
        return progress.totalVlogsShared >= 1;
      case 'share_10':
        return progress.totalVlogsShared >= 10;

      // ── Category starters (7 days) ───────────────────────────────────────────
      case 'cat_physical_7':
        return habits.any(
          (h) =>
              h.category == HabitCategory.physical &&
              h.totalDaysCompleted >= 7,
        );
      case 'cat_mental_7':
        return habits.any(
          (h) =>
              h.category == HabitCategory.mental && h.totalDaysCompleted >= 7,
        );
      case 'cat_creative_7':
        return habits.any(
          (h) =>
              h.category == HabitCategory.creative &&
              h.totalDaysCompleted >= 7,
        );
      case 'cat_growth_7':
        return habits.any(
          (h) =>
              h.category == HabitCategory.growth && h.totalDaysCompleted >= 7,
        );

      // ── Category champions (30 days) ─────────────────────────────────────────
      case 'cat_physical_30':
        return habits.any(
          (h) =>
              h.category == HabitCategory.physical &&
              h.totalDaysCompleted >= 30,
        );
      case 'cat_mental_30':
        return habits.any(
          (h) =>
              h.category == HabitCategory.mental && h.totalDaysCompleted >= 30,
        );
      case 'cat_creative_30':
        return habits.any(
          (h) =>
              h.category == HabitCategory.creative &&
              h.totalDaysCompleted >= 30,
        );
      case 'cat_growth_30':
        return habits.any(
          (h) =>
              h.category == HabitCategory.growth && h.totalDaysCompleted >= 30,
        );

      // ── Special ──────────────────────────────────────────────────────────────
      case 'balanced':
        final categories = habits.map((h) => h.category).toSet();
        return categories.containsAll(HabitCategory.values);

      case 'collector':
        return habits.length >= 6;

      case 'level_5':
        return progress.level >= 5;
      case 'level_10':
        return progress.level >= 10;

      case 'marathon':
        return progress.totalRecordingSeconds >= 6000; // 100 minutes

      case 'multi_flame':
        return habits.where((h) => h.currentStreak >= 7).length >= 3;

      case 'comeback_kid':
        // Streak just became 1, and there's a prior compiled log 7+ days old
        final justStarted =
            habits.any((h) => h.currentStreak == 1 && h.totalDaysCompleted > 1);
        if (!justStarted) return false;
        final sevenDaysAgo = DateTime.now().subtract(const Duration(days: 7));
        return recordingState.vlogs.values.any(
          (v) => v.date.isBefore(sevenDaysAgo),
        );

      case 'early_adopter':
        // 7+ vlogs and earliest habit created within the last 10 days
        if (progress.totalVlogsCreated < 7) return false;
        final tenDaysAgo = DateTime.now().subtract(const Duration(days: 10));
        return habits.any((h) => h.createdAt.isAfter(tenDaysAgo));

      case 'perfect_week':
        if (habits.isEmpty) return false;
        return habits.every((h) => h.currentStreak >= 7);

      default:
        return false;
    }
  }
}
