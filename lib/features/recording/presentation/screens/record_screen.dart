import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../shared/widgets/buttons/primary_button.dart';
import '../../../habits/data/models/habit.dart';
import '../../../habits/providers/habits_provider.dart';
import '../../providers/recording_provider.dart';

/// Record screen - shows habit selection before recording
class RecordScreen extends ConsumerWidget {
  const RecordScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final habits = ref.watch(habitsProvider);

    return Scaffold(
      backgroundColor: AppColors.backgroundPrimary,
      appBar: AppBar(
        backgroundColor: AppColors.backgroundPrimary,
        title: Text(
          'Record',
          style: AppTypography.h1.copyWith(color: AppColors.textPrimary),
        ),
        elevation: 0,
      ),
      body: habits.isEmpty
          ? _buildEmptyState(context)
          : _buildHabitList(context, ref, habits),
    );
  }

  Widget _buildEmptyState(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.xl),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 100,
              height: 100,
              decoration: BoxDecoration(
                color: AppColors.primary.withValues(alpha: 0.1),
                shape: BoxShape.circle,
              ),
              child: const Center(
                child: Text(
                  '📹',
                  style: TextStyle(fontSize: 48),
                ),
              ),
            ),
            const SizedBox(height: AppSpacing.lg),
            Text(
              'No habits yet',
              style: AppTypography.h2.copyWith(color: AppColors.textPrimary),
            ),
            const SizedBox(height: AppSpacing.sm),
            Text(
              'Create a habit first to start recording your vlogs',
              style: AppTypography.bodyDefault.copyWith(
                color: AppColors.textSecondary,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: AppSpacing.xl),
            PrimaryButton(
              text: 'Create Habit',
              icon: Icons.add,
              onPressed: () => context.push('/create-habit'),
              fullWidth: false,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHabitList(
    BuildContext context,
    WidgetRef ref,
    List<Habit> habits,
  ) {
    return ListView(
      padding: const EdgeInsets.all(AppSpacing.screenHorizontal),
      children: [
        Text(
          'Select a habit to record',
          style: AppTypography.bodyDefault.copyWith(
            color: AppColors.textSecondary,
          ),
        ),
        const SizedBox(height: AppSpacing.md),
        ...habits.asMap().entries.map((entry) {
          final index = entry.key;
          final habit = entry.value;
          final todayLog = ref.watch(todayLogProvider(habit.id));

          return Padding(
            padding: const EdgeInsets.only(bottom: AppSpacing.cardGap),
            child: _HabitRecordCard(
              habit: habit,
              clipsRecorded: todayLog?.clipCount ?? 0,
              isComplete: todayLog?.hasAllClips ?? false,
              onTap: () {
                context.push(
                  '/camera/${habit.id}',
                  extra: {
                    'habitName': habit.name,
                    'dayNumber': habit.currentDayNumber,
                    'habitColor': habit.category.color,
                  },
                );
              },
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
      ],
    );
  }
}

class _HabitRecordCard extends StatefulWidget {
  final Habit habit;
  final int clipsRecorded;
  final bool isComplete;
  final VoidCallback onTap;

  const _HabitRecordCard({
    required this.habit,
    required this.clipsRecorded,
    required this.isComplete,
    required this.onTap,
  });

  @override
  State<_HabitRecordCard> createState() => _HabitRecordCardState();
}

class _HabitRecordCardState extends State<_HabitRecordCard> {
  bool _isPressed = false;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: (_) => setState(() => _isPressed = true),
      onTapUp: (_) => setState(() => _isPressed = false),
      onTapCancel: () => setState(() => _isPressed = false),
      onTap: widget.onTap,
      child: AnimatedScale(
        scale: _isPressed ? 0.98 : 1.0,
        duration: const Duration(milliseconds: 100),
        child: Container(
          decoration: BoxDecoration(
            color: AppColors.backgroundCard,
            borderRadius: BorderRadius.circular(AppSpacing.cardRadius),
            border: Border.all(
              color: widget.isComplete
                  ? AppColors.success.withValues(alpha: 0.5)
                  : AppColors.borderSubtle,
              width: 1,
            ),
          ),
          child: Row(
            children: [
              // Left accent border
              Container(
                width: 4,
                height: 88,
                decoration: BoxDecoration(
                  color: widget.habit.category.color,
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(AppSpacing.cardRadius),
                    bottomLeft: Radius.circular(AppSpacing.cardRadius),
                  ),
                ),
              ),
              // Card content
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.all(AppSpacing.cardPadding),
                  child: Row(
                    children: [
                      // Habit info
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Text(
                                  widget.habit.category.emoji,
                                  style: const TextStyle(fontSize: 20),
                                ),
                                const SizedBox(width: AppSpacing.sm),
                                Expanded(
                                  child: Text(
                                    widget.habit.name,
                                    style: AppTypography.h3.copyWith(
                                      color: AppColors.textPrimary,
                                    ),
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: AppSpacing.xs),
                            Row(
                              children: [
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 8,
                                    vertical: 2,
                                  ),
                                  decoration: BoxDecoration(
                                    color: widget.habit.category.color
                                        .withValues(alpha: 0.15),
                                    borderRadius: BorderRadius.circular(6),
                                  ),
                                  child: Text(
                                    widget.habit.dayDisplay,
                                    style: AppTypography.caption.copyWith(
                                      color: widget.habit.category.color,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ),
                                const SizedBox(width: AppSpacing.sm),
                                Text(
                                  widget.isComplete
                                      ? 'Complete ✓'
                                      : '${widget.clipsRecorded}/3 clips',
                                  style: AppTypography.bodySmall.copyWith(
                                    color: widget.isComplete
                                        ? AppColors.success
                                        : AppColors.textSecondary,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                      // Record button
                      Container(
                        padding: const EdgeInsets.all(AppSpacing.md),
                        decoration: BoxDecoration(
                          color: widget.isComplete
                              ? AppColors.success.withValues(alpha: 0.15)
                              : widget.habit.category.color,
                          shape: BoxShape.circle,
                        ),
                        child: Icon(
                          widget.isComplete
                              ? Icons.check
                              : widget.clipsRecorded > 0
                                  ? Icons.play_arrow
                                  : Icons.videocam,
                          color: widget.isComplete
                              ? AppColors.success
                              : Colors.white,
                          size: 24,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
