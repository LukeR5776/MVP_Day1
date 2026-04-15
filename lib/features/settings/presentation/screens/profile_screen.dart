import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:go_router/go_router.dart';
import '../../../../shared/widgets/layout/screen_scaffold.dart';
import '../../../../shared/widgets/indicators/xp_bar.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../gamification/providers/gamification_provider.dart';
import '../../../gamification/data/models/achievement.dart';
import '../../../gamification/presentation/widgets/achievement_card.dart';
import '../../../habits/providers/habits_provider.dart';

class ProfileScreen extends ConsumerWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final progress = ref.watch(gamificationProvider);
    final habits = ref.watch(habitsProvider);

    final bestStreak = habits.isEmpty
        ? 0
        : habits.map((h) => h.bestStreak).reduce((a, b) => a > b ? a : b);

    // Get last 3 unlocked achievements
    final recentAchievements = progress.unlockedAchievementIds
        .reversed
        .take(3)
        .map((id) => AchievementDefinitions.byId(id))
        .whereType<Achievement>()
        .toList();

    return ScreenScaffold(
      title: 'Profile',
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            const SizedBox(height: AppSpacing.lg),

            // Hero section
            _HeroSection(progress: progress)
                .animate()
                .fadeIn(duration: 500.ms)
                .scale(begin: const Offset(0.9, 0.9), end: const Offset(1, 1)),

            const SizedBox(height: AppSpacing.lg),

            // XP Progress card
            _XpProgressCard(progress: progress)
                .animate()
                .fadeIn(duration: 400.ms, delay: 100.ms)
                .slideY(begin: 0.1, end: 0),

            const SizedBox(height: AppSpacing.lg),

            // Stats grid
            _ProfileStatsGrid(
              level: progress.level,
              totalXP: progress.totalXP,
              bestStreak: bestStreak,
              totalVlogs: progress.totalVlogsCreated,
            )
                .animate()
                .fadeIn(duration: 400.ms, delay: 200.ms),

            // Recent achievements (only if any)
            if (recentAchievements.isNotEmpty) ...[
              const SizedBox(height: AppSpacing.lg),
              _RecentAchievements(
                achievements: recentAchievements,
                onViewAll: () => context.go('/stats'),
              )
                  .animate()
                  .fadeIn(duration: 400.ms, delay: 300.ms),
            ],

            const SizedBox(height: AppSpacing.bottomNavClearance),
          ],
        ),
      ),
    );
  }
}

// ── Hero section ──────────────────────────────────────────────────────────────

class _HeroSection extends StatelessWidget {
  final dynamic progress; // UserProgress

  const _HeroSection({required this.progress});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // Level badge
        Container(
          width: 100,
          height: 100,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            gradient: const LinearGradient(
              colors: [AppColors.levelPurple, Color(0xFF7C3AED)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            boxShadow: [
              BoxShadow(
                color: AppColors.levelPurple.withValues(alpha: 0.4),
                blurRadius: 24,
                spreadRadius: 4,
              ),
            ],
          ),
          child: Center(
            child: Text(
              '${progress.level}',
              style: const TextStyle(
                fontSize: 40,
                fontWeight: FontWeight.w900,
                color: AppColors.textPrimary,
              ),
            ),
          ),
        ),
        const SizedBox(height: AppSpacing.md),

        // Username
        Text(
          'Day1 Athlete',
          style: AppTypography.h2.copyWith(color: AppColors.textPrimary),
        ),
        const SizedBox(height: 4),
        Text(
          progress.levelTitle,
          style: AppTypography.bodySmall.copyWith(
            color: AppColors.levelPurple,
          ),
        ),
      ],
    );
  }
}

// ── XP progress card ──────────────────────────────────────────────────────────

class _XpProgressCard extends StatelessWidget {
  final dynamic progress;

  const _XpProgressCard({required this.progress});

  @override
  Widget build(BuildContext context) {
    final xpLeft = progress.xpNeededForNextLevel - progress.xpProgressInCurrentLevel;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: AppColors.backgroundCard,
        borderRadius: BorderRadius.circular(AppSpacing.cardRadius),
        border: Border.all(color: AppColors.borderSubtle),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Level ${progress.level} → ${progress.level + 1}',
                style: AppTypography.h4.copyWith(color: AppColors.textPrimary),
              ),
              Text(
                '${progress.totalXP} XP total',
                style: AppTypography.caption.copyWith(
                  color: AppColors.xpGold,
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.sm),
          XPBar(
            currentXP: progress.xpProgressInCurrentLevel,
            maxXP: progress.xpNeededForNextLevel,
            height: 10,
          ),
          const SizedBox(height: AppSpacing.xs),
          Text(
            '$xpLeft XP to Level ${progress.level + 1}',
            style: AppTypography.caption.copyWith(
              color: AppColors.textTertiary,
            ),
          ),
        ],
      ),
    );
  }
}

// ── Stats grid ────────────────────────────────────────────────────────────────

class _ProfileStatsGrid extends StatelessWidget {
  final int level;
  final int totalXP;
  final int bestStreak;
  final int totalVlogs;

  const _ProfileStatsGrid({
    required this.level,
    required this.totalXP,
    required this.bestStreak,
    required this.totalVlogs,
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
        _StatTile(label: 'Level', value: '$level', emoji: '⭐'),
        _StatTile(label: 'Total XP', value: '$totalXP', emoji: '⚡'),
        _StatTile(label: 'Best Streak', value: '${bestStreak}d', emoji: '🔥'),
        _StatTile(label: 'Vlogs Made', value: '$totalVlogs', emoji: '🎬'),
      ],
    );
  }
}

class _StatTile extends StatelessWidget {
  final String label;
  final String value;
  final String emoji;

  const _StatTile({
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

// ── Recent achievements ───────────────────────────────────────────────────────

class _RecentAchievements extends StatelessWidget {
  final List<Achievement> achievements;
  final VoidCallback onViewAll;

  const _RecentAchievements({
    required this.achievements,
    required this.onViewAll,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'RECENT ACHIEVEMENTS',
              style: AppTypography.h4.copyWith(
                color: AppColors.textSecondary,
                letterSpacing: 1,
              ),
            ),
            GestureDetector(
              onTap: onViewAll,
              child: Text(
                'View All →',
                style: AppTypography.caption.copyWith(
                  color: AppColors.primary,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: AppSpacing.md),
        Row(
          children: achievements.map((a) {
            return Expanded(
              child: Padding(
                padding: const EdgeInsets.only(right: AppSpacing.sm),
                child: AchievementCard(
                  achievement: a,
                  isUnlocked: true,
                ),
              ),
            );
          }).toList(),
        ),
      ],
    );
  }
}
