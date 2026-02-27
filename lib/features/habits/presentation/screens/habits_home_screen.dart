import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:go_router/go_router.dart';
import '../../../../shared/widgets/indicators/xp_bar.dart';
import '../../../../shared/widgets/cards/base_card.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_typography.dart';
import '../../data/models/habit.dart';
import '../../providers/habits_provider.dart';
import '../widgets/habit_card.dart';
import '../widgets/empty_habits_state.dart';
import '../../../recording/providers/recording_provider.dart';
import '../../../recording/data/models/daily_log.dart';

class HabitsHomeScreen extends ConsumerWidget {
  const HabitsHomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final habits = ref.watch(habitsProvider);
    final hasHabits = habits.isNotEmpty;

    return Scaffold(
      backgroundColor: AppColors.backgroundPrimary,
      body: SafeArea(
        child: hasHabits
            ? _buildHabitsList(context, ref, habits)
            : EmptyHabitsState(
                onCreateHabit: () => context.push('/create-habit'),
              ),
      ),
      floatingActionButton: hasHabits
          ? FloatingActionButton(
              onPressed: () => context.push('/create-habit'),
              backgroundColor: AppColors.primary,
              child: const Icon(Icons.add, color: Colors.white),
            )
                .animate()
                .scale(delay: 300.ms, duration: 400.ms, curve: Curves.elasticOut)
          : null,
    );
  }

  Widget _buildHabitsList(
    BuildContext context,
    WidgetRef ref,
    List<Habit> habits,
  ) {
    // Calculate total streak (sum of all current streaks)
    final totalStreak = habits.fold<int>(
      0,
      (int sum, Habit habit) => sum + habit.currentStreak,
    );

    return CustomScrollView(
      slivers: [
        // App bar
        SliverAppBar(
          floating: true,
          backgroundColor: AppColors.backgroundPrimary,
          title: Text(
            'Today',
            style: AppTypography.h1.copyWith(color: AppColors.textPrimary),
          ),
          actions: [
            IconButton(
              icon: const Icon(Icons.notifications_outlined),
              color: AppColors.textSecondary,
              onPressed: () {
                // TODO: Show notifications
              },
            ),
          ],
        ),

        // Content
        SliverPadding(
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.screenHorizontal,
          ),
          sliver: SliverList(
            delegate: SliverChildListDelegate([
              const SizedBox(height: AppSpacing.md),

              // Streak and XP Section
              _buildStatsCard(context, totalStreak)
                  .animate()
                  .fadeIn(duration: 400.ms)
                  .slideY(begin: 0.1, end: 0),

              const SizedBox(height: AppSpacing.lg),

              // Section header
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    "TODAY'S HABITS",
                    style: AppTypography.h4.copyWith(
                      color: AppColors.textSecondary,
                      letterSpacing: 1,
                    ),
                  ),
                  Text(
                    '${habits.length}/6',
                    style: AppTypography.caption.copyWith(
                      color: AppColors.textTertiary,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: AppSpacing.md),

              // Habit cards
              ...habits.asMap().entries.map((entry) {
                final index = entry.key;
                final habit = entry.value;
                final todayLog = ref.watch(todayLogProvider(habit.id));

                // Determine status based on actual data
                TodayStatus status;
                if (todayLog == null) {
                  status = TodayStatus.notStarted;
                } else if (todayLog.status == DailyLogStatus.vlogCompiled) {
                  status = TodayStatus.completed;
                } else {
                  status = TodayStatus.inProgress;
                }

                return Padding(
                  padding: const EdgeInsets.only(bottom: AppSpacing.cardGap),
                  child: HabitCard(
                    habit: habit,
                    todayStatus: status,
                    clipsRecorded: todayLog?.clipCount ?? 0,
                    onTap: () => context.push('/habit/${habit.id}'),
                    onRecordTap: () => context.go('/record'),
                  )
                      .animate()
                      .fadeIn(
                        duration: 400.ms,
                        delay: Duration(milliseconds: 100 + (index * 100)),
                      )
                      .slideX(begin: 0.1, end: 0),
                );
              }),

              const SizedBox(height: AppSpacing.bottomNavClearance),
            ]),
          ),
        ),
      ],
    );
  }

  Widget _buildStatsCard(BuildContext context, int totalStreak) {
    return BaseCard(
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              // Streak section
              Expanded(
                child: GestureDetector(
                  onTap: () {
                    // TODO: Show streak details
                  },
                  child: Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(AppSpacing.sm),
                        decoration: BoxDecoration(
                          color: AppColors.streakFire.withValues(alpha: 0.15),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: const Text(
                          '🔥',
                          style: TextStyle(fontSize: 24),
                        ),
                      ),
                      const SizedBox(width: AppSpacing.md),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            '$totalStreak',
                            style: AppTypography.h2.copyWith(
                              color: AppColors.textPrimary,
                            ),
                          ),
                          Text(
                            'day streak',
                            style: AppTypography.caption.copyWith(
                              color: AppColors.textSecondary,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),

              // Divider
              Container(
                width: 1,
                height: 50,
                color: AppColors.divider,
              ),

              // XP section
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.only(left: AppSpacing.md),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          const Text(
                            '⚡',
                            style: TextStyle(fontSize: 16),
                          ),
                          const SizedBox(width: 4),
                          Text(
                            'Level 1',
                            style: AppTypography.h4.copyWith(
                              color: AppColors.textPrimary,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      const XPBar(
                        currentXP: 0,
                        maxXP: 100,
                      ),
                      const SizedBox(height: 4),
                      Text(
                        '0 / 100 XP',
                        style: AppTypography.caption.copyWith(
                          color: AppColors.textTertiary,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
