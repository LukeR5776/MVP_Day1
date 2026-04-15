import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../../../shared/widgets/layout/screen_scaffold.dart';
import '../../../../shared/widgets/indicators/xp_bar.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../data/models/achievement.dart';
import '../../providers/gamification_provider.dart';
import '../widgets/achievement_card.dart';
import '../../../habits/providers/habits_provider.dart';

class StatsScreen extends ConsumerWidget {
  const StatsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final progress = ref.watch(gamificationProvider);
    final habits = ref.watch(habitsProvider);

    final unlocked = progress.unlockedAchievementIds;
    const all = AchievementDefinitions.all;

    // Split: unlocked first, then locked
    final unlockedAchievements = all
        .where((a) => unlocked.contains(a.id))
        .toList();
    final lockedAchievements = all
        .where((a) => !unlocked.contains(a.id))
        .toList();
    final sorted = [...unlockedAchievements, ...lockedAchievements];

    // Best streak across all habits
    final bestStreak = habits.isEmpty
        ? 0
        : habits.map((h) => h.bestStreak).reduce((a, b) => a > b ? a : b);

    return ScreenScaffold(
      title: 'Achievements',
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: AppSpacing.md),

            // Level card
            _LevelCard(progress: progress)
                .animate()
                .fadeIn(duration: 400.ms)
                .slideY(begin: 0.1, end: 0),

            const SizedBox(height: AppSpacing.lg),

            // Stats grid
            _StatsGrid(
              totalXP: progress.totalXP,
              bestStreak: bestStreak,
              totalVlogs: progress.totalVlogsCreated,
              totalMinutes: progress.totalRecordingSeconds ~/ 60,
            )
                .animate()
                .fadeIn(duration: 400.ms, delay: 100.ms),

            const SizedBox(height: AppSpacing.lg),

            // Achievements header
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'ACHIEVEMENTS',
                  style: AppTypography.h4.copyWith(
                    color: AppColors.textSecondary,
                    letterSpacing: 1,
                  ),
                ),
                Text(
                  '${unlocked.length}/${all.length}',
                  style: AppTypography.caption.copyWith(
                    color: AppColors.textTertiary,
                  ),
                ),
              ],
            )
                .animate()
                .fadeIn(duration: 400.ms, delay: 200.ms),

            const SizedBox(height: AppSpacing.md),

            // Achievement grid
            GridView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                crossAxisSpacing: AppSpacing.sm,
                mainAxisSpacing: AppSpacing.sm,
                childAspectRatio: 1.3,
              ),
              itemCount: sorted.length,
              itemBuilder: (context, index) {
                final achievement = sorted[index];
                final isUnlocked = unlocked.contains(achievement.id);
                return AchievementCard(
                  achievement: achievement,
                  isUnlocked: isUnlocked,
                ).animate().fadeIn(
                      duration: 300.ms,
                      delay: Duration(milliseconds: 200 + (index * 30)),
                    );
              },
            ),

            const SizedBox(height: AppSpacing.bottomNavClearance),
          ],
        ),
      ),
    );
  }
}

// ── Level card ────────────────────────────────────────────────────────────────

class _LevelCard extends StatelessWidget {
  final dynamic progress; // UserProgress

  const _LevelCard({required this.progress});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: AppColors.backgroundCard,
        borderRadius: BorderRadius.circular(AppSpacing.cardRadius),
        border: Border.all(color: AppColors.levelPurple.withValues(alpha: 0.3)),
      ),
      child: Row(
        children: [
          // Level badge
          Container(
            width: 80,
            height: 80,
            decoration: const BoxDecoration(
              shape: BoxShape.circle,
              gradient: LinearGradient(
                colors: [AppColors.levelPurple, Color(0xFF7C3AED)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
            ),
            child: Center(
              child: Text(
                '${progress.level}',
                style: const TextStyle(
                  fontSize: 32,
                  fontWeight: FontWeight.w900,
                  color: AppColors.textPrimary,
                ),
              ),
            ),
          ),
          const SizedBox(width: AppSpacing.md),

          // Level info
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  progress.levelTitle,
                  style: AppTypography.h3.copyWith(
                    color: AppColors.textPrimary,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Level ${progress.level}',
                  style: AppTypography.bodySmall.copyWith(
                    color: AppColors.levelPurple,
                  ),
                ),
                const SizedBox(height: AppSpacing.sm),
                XPBar(
                  currentXP: progress.xpProgressInCurrentLevel,
                  maxXP: progress.xpNeededForNextLevel,
                ),
                const SizedBox(height: 4),
                Text(
                  '${progress.xpProgressInCurrentLevel} / ${progress.xpNeededForNextLevel} XP to Level ${progress.level + 1}',
                  style: AppTypography.caption.copyWith(
                    color: AppColors.textTertiary,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ── Stats grid ────────────────────────────────────────────────────────────────

class _StatsGrid extends StatelessWidget {
  final int totalXP;
  final int bestStreak;
  final int totalVlogs;
  final int totalMinutes;

  const _StatsGrid({
    required this.totalXP,
    required this.bestStreak,
    required this.totalVlogs,
    required this.totalMinutes,
  });

  @override
  Widget build(BuildContext context) {
    return GridView.count(
      crossAxisCount: 2,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisSpacing: AppSpacing.sm,
      mainAxisSpacing: AppSpacing.sm,
      childAspectRatio: 1.6,
      children: [
        _StatChip(label: 'Total XP', value: '$totalXP', emoji: '⚡'),
        _StatChip(label: 'Best Streak', value: '${bestStreak}d', emoji: '🔥'),
        _StatChip(label: 'Total Vlogs', value: '$totalVlogs', emoji: '🎬'),
        _StatChip(label: 'Minutes', value: '$totalMinutes', emoji: '🕐'),
      ],
    );
  }
}

class _StatChip extends StatelessWidget {
  final String label;
  final String value;
  final String emoji;

  const _StatChip({
    required this.label,
    required this.value,
    required this.emoji,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: AppColors.backgroundCard,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.borderSubtle),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(emoji, style: const TextStyle(fontSize: 20)),
          const SizedBox(height: 4),
          Text(
            value,
            style: AppTypography.h3.copyWith(color: AppColors.textPrimary),
          ),
          Text(
            label,
            style: AppTypography.caption.copyWith(
              color: AppColors.textSecondary,
            ),
          ),
        ],
      ),
    );
  }
}
