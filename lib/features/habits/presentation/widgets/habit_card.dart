import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_typography.dart';
import '../../data/models/habit.dart';
import '../../providers/habits_provider.dart';

/// Habit card widget for the home screen
/// Shows habit name, category, day number, and today's progress
class HabitCard extends StatefulWidget {
  final Habit habit;
  final TodayStatus todayStatus;
  final int clipsRecorded;
  final VoidCallback? onTap;
  final VoidCallback? onRecordTap;

  const HabitCard({
    super.key,
    required this.habit,
    this.todayStatus = TodayStatus.notStarted,
    this.clipsRecorded = 0,
    this.onTap,
    this.onRecordTap,
  });

  @override
  State<HabitCard> createState() => _HabitCardState();
}

class _HabitCardState extends State<HabitCard> {
  bool _isPressed = false;
  Timer? _ticker;

  @override
  void initState() {
    super.initState();
    // Tick every minute so countdown text stays current
    _ticker = Timer.periodic(const Duration(minutes: 1), (_) {
      if (mounted) setState(() {});
    });
  }

  @override
  void dispose() {
    _ticker?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isCompleted = widget.todayStatus == TodayStatus.completed;

    return GestureDetector(
      onTapDown: (_) => setState(() => _isPressed = true),
      onTapUp: (_) => setState(() => _isPressed = false),
      onTapCancel: () => setState(() => _isPressed = false),
      onTap: widget.onTap,
      child: AnimatedScale(
        scale: _isPressed ? 0.98 : 1.0,
        duration: const Duration(milliseconds: 100),
        curve: Curves.easeOut,
        child: Container(
          decoration: BoxDecoration(
            color: AppColors.backgroundCard,
            borderRadius: BorderRadius.circular(AppSpacing.cardRadius),
            border: Border.all(
              color: isCompleted
                  ? widget.habit.category.color.withValues(alpha: 0.5)
                  : AppColors.borderSubtle,
              width: 1,
            ),
          ),
          child: Row(
            children: [
              // Left accent border
              Container(
                width: 4,
                height: 100,
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
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Header row: name + day number
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Expanded(
                            child: Row(
                              children: [
                                Icon(
                                  widget.habit.category.icon,
                                  size: 20,
                                  color: widget.habit.category.color,
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
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: AppSpacing.sm,
                              vertical: AppSpacing.xs,
                            ),
                            decoration: BoxDecoration(
                              color: widget.habit.category.color
                                  .withValues(alpha: 0.15),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Text(
                              widget.habit.dayDisplay,
                              style: AppTypography.caption.copyWith(
                                color: widget.habit.category.color,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: AppSpacing.sm),
                      // Progress section
                      Row(
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                // Progress indicator
                                _ProgressIndicator(
                                  status: widget.todayStatus,
                                  clipsRecorded: widget.clipsRecorded,
                                  color: widget.habit.category.color,
                                ),
                                const SizedBox(height: 4),
                                // Status text
                                Text(
                                  _getStatusText(),
                                  style: AppTypography.bodySmall.copyWith(
                                    color: isCompleted
                                        ? AppColors.success
                                        : AppColors.textSecondary,
                                  ),
                                ),
                                // Streak / reset indicator
                                _buildTimingIndicator(),
                              ],
                            ),
                          ),
                          // Action button
                          _ActionButton(
                            status: widget.todayStatus,
                            color: widget.habit.category.color,
                            onTap: widget.onRecordTap,
                          ),
                        ],
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

  String _getStatusText() {
    switch (widget.todayStatus) {
      case TodayStatus.completed:
        return 'Complete ✓';
      case TodayStatus.inProgress:
        return '${widget.clipsRecorded}/3 clips recorded';
      case TodayStatus.notStarted:
        return 'Not started';
    }
  }

  Widget _buildTimingIndicator() {
    final habit = widget.habit;

    // Completed today — show reset countdown
    if (widget.todayStatus == TodayStatus.completed) {
      final mins = habit.minutesUntilDailyReset;
      final hours = mins ~/ 60;
      final label = hours > 0 ? 'Resets in ${hours}h' : 'Resets in ${mins}m';
      return Padding(
        padding: const EdgeInsets.only(top: 3),
        child: Text(
          label,
          style: AppTypography.caption.copyWith(
            color: AppColors.textTertiary,
            fontSize: 11,
          ),
        ),
      );
    }

    // Streak at risk — show expiry warning when streak > 0 and not yet done today
    final streakAtRisk = habit.currentStreak > 0 &&
        widget.todayStatus != TodayStatus.completed;
    if (streakAtRisk) {
      final hours = habit.hoursUntilStreakExpires ?? habit.minutesUntilDailyReset ~/ 60;
      Color warningColor;
      IconData warningIcon;
      String label;
      if (hours == 0) {
        warningColor = AppColors.streakFire;
        warningIcon = LucideIcons.flame;
        label = 'Streak expires < 1h!';
      } else if (hours <= 3) {
        warningColor = AppColors.streakFire;
        warningIcon = LucideIcons.flame;
        label = 'Streak expires in ${hours}h!';
      } else if (hours <= 8) {
        warningColor = AppColors.warning;
        warningIcon = LucideIcons.zap;
        label = 'Streak expires in ${hours}h';
      } else {
        warningColor = AppColors.xpGold;
        warningIcon = LucideIcons.flame;
        label = 'Complete today to keep streak';
      }
      return Padding(
        padding: const EdgeInsets.only(top: 3),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(warningIcon, size: 11, color: warningColor),
            const SizedBox(width: 3),
            Text(
              label,
              style: AppTypography.caption.copyWith(
                color: warningColor,
                fontSize: 11,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      );
    }

    return const SizedBox.shrink();
  }
}

class _ProgressIndicator extends StatelessWidget {
  final TodayStatus status;
  final int clipsRecorded;
  final Color color;

  const _ProgressIndicator({
    required this.status,
    required this.clipsRecorded,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        _ProgressSegment(
          isCompleted: clipsRecorded >= 1,
          isActive: clipsRecorded == 0 && status != TodayStatus.completed,
          color: color,
          label: 'I',
        ),
        const SizedBox(width: 4),
        _ProgressSegment(
          isCompleted: clipsRecorded >= 2,
          isActive: clipsRecorded == 1,
          color: color,
          label: 'E',
        ),
        const SizedBox(width: 4),
        _ProgressSegment(
          isCompleted: clipsRecorded >= 3 || status == TodayStatus.completed,
          isActive: clipsRecorded == 2,
          color: color,
          label: 'R',
        ),
      ],
    );
  }
}

class _ProgressSegment extends StatelessWidget {
  final bool isCompleted;
  final bool isActive;
  final Color color;
  final String label;

  const _ProgressSegment({
    required this.isCompleted,
    required this.isActive,
    required this.color,
    required this.label,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        height: 6,
        decoration: BoxDecoration(
          color: isCompleted
              ? color
              : isActive
                  ? color.withValues(alpha: 0.5)
                  : AppColors.backgroundSurface,
          borderRadius: BorderRadius.circular(3),
        ),
      ),
    );
  }
}

class _ActionButton extends StatefulWidget {
  final TodayStatus status;
  final Color color;
  final VoidCallback? onTap;

  const _ActionButton({
    required this.status,
    required this.color,
    this.onTap,
  });

  @override
  State<_ActionButton> createState() => _ActionButtonState();
}

class _ActionButtonState extends State<_ActionButton> {
  bool _isPressed = false;

  @override
  Widget build(BuildContext context) {
    final isCompleted = widget.status == TodayStatus.completed;

    return GestureDetector(
      onTapDown: isCompleted ? null : (_) => setState(() => _isPressed = true),
      onTapUp: isCompleted ? null : (_) => setState(() => _isPressed = false),
      onTapCancel: isCompleted ? null : () => setState(() => _isPressed = false),
      onTap: isCompleted ? null : widget.onTap,
      child: AnimatedScale(
        scale: _isPressed ? 0.9 : 1.0,
        duration: const Duration(milliseconds: 100),
        child: Container(
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.md,
            vertical: AppSpacing.sm,
          ),
          decoration: BoxDecoration(
            color: isCompleted
                ? AppColors.success.withValues(alpha: 0.15)
                : widget.color,
            borderRadius: BorderRadius.circular(AppSpacing.buttonRadius),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                isCompleted
                    ? Icons.check_circle
                    : widget.status == TodayStatus.inProgress
                        ? Icons.videocam
                        : Icons.play_arrow,
                color: isCompleted ? AppColors.success : Colors.white,
                size: 18,
              ),
              const SizedBox(width: 4),
              Text(
                isCompleted
                    ? 'Done'
                    : widget.status == TodayStatus.inProgress
                        ? 'Continue'
                        : 'Start',
                style: AppTypography.buttonText.copyWith(
                  color: isCompleted ? AppColors.success : Colors.white,
                  fontSize: 14,
                ),
              ),
            ],
          ),
        ),
      ),
    ).animate(target: isCompleted ? 1 : 0).shimmer(
          duration: 800.ms,
          color: AppColors.success.withValues(alpha: 0.3),
        );
  }
}
