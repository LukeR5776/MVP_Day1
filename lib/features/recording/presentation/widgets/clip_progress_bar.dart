import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_typography.dart';
import '../../data/models/clip_type.dart';
import '../../data/models/daily_log.dart';

/// Progress bar showing I-E-R clip recording status
class ClipProgressBar extends StatelessWidget {
  final DailyLog? dailyLog;
  final ClipType currentClipType;
  final bool isRecording;
  final Color habitColor;

  const ClipProgressBar({
    super.key,
    this.dailyLog,
    required this.currentClipType,
    this.isRecording = false,
    this.habitColor = AppColors.primary,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.md,
        vertical: AppSpacing.sm,
      ),
      decoration: BoxDecoration(
        color: AppColors.backgroundPrimary.withValues(alpha: 0.9),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          _ClipSegment(
            type: ClipType.intention,
            isCompleted: dailyLog?.hasClip(ClipType.intention) ?? false,
            isCurrent: currentClipType == ClipType.intention,
            isRecording: isRecording && currentClipType == ClipType.intention,
            color: habitColor,
          ),
          _SegmentConnector(
            isCompleted: dailyLog?.hasClip(ClipType.intention) ?? false,
            color: habitColor,
          ),
          _ClipSegment(
            type: ClipType.evidence,
            isCompleted: dailyLog?.hasClip(ClipType.evidence) ?? false,
            isCurrent: currentClipType == ClipType.evidence,
            isRecording: isRecording && currentClipType == ClipType.evidence,
            color: habitColor,
          ),
          _SegmentConnector(
            isCompleted: dailyLog?.hasClip(ClipType.evidence) ?? false,
            color: habitColor,
          ),
          _ClipSegment(
            type: ClipType.reflection,
            isCompleted: dailyLog?.hasClip(ClipType.reflection) ?? false,
            isCurrent: currentClipType == ClipType.reflection,
            isRecording: isRecording && currentClipType == ClipType.reflection,
            color: habitColor,
          ),
        ],
      ),
    );
  }
}

class _ClipSegment extends StatelessWidget {
  final ClipType type;
  final bool isCompleted;
  final bool isCurrent;
  final bool isRecording;
  final Color color;

  const _ClipSegment({
    required this.type,
    required this.isCompleted,
    required this.isCurrent,
    required this.isRecording,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        // Circle indicator
        AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          width: 32,
          height: 32,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: isCompleted
                ? color
                : isCurrent
                    ? color.withValues(alpha: 0.3)
                    : AppColors.backgroundSurface,
            border: Border.all(
              color: isCompleted || isCurrent ? color : AppColors.borderDefault,
              width: 2,
            ),
          ),
          child: Center(
            child: isCompleted
                ? const Icon(
                    Icons.check,
                    color: Colors.white,
                    size: 18,
                  )
                : Text(
                    type.shortLabel,
                    style: AppTypography.caption.copyWith(
                      color: isCurrent ? color : AppColors.textTertiary,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
          ),
        )
            .animate(target: isRecording ? 1 : 0)
            .scale(
              begin: const Offset(1, 1),
              end: const Offset(1.1, 1.1),
              duration: 500.ms,
            )
            .then()
            .scale(
              begin: const Offset(1.1, 1.1),
              end: const Offset(1, 1),
              duration: 500.ms,
            ),
        const SizedBox(height: 4),
        // Label
        Text(
          type.shortLabel,
          style: AppTypography.caption.copyWith(
            color: isCompleted || isCurrent
                ? AppColors.textPrimary
                : AppColors.textTertiary,
            fontWeight: isCurrent ? FontWeight.bold : FontWeight.normal,
          ),
        ),
      ],
    );
  }
}

class _SegmentConnector extends StatelessWidget {
  final bool isCompleted;
  final Color color;

  const _SegmentConnector({
    required this.isCompleted,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 24,
      height: 2,
      margin: const EdgeInsets.only(bottom: 20),
      decoration: BoxDecoration(
        color: isCompleted ? color : AppColors.backgroundSurface,
        borderRadius: BorderRadius.circular(1),
      ),
    );
  }
}
