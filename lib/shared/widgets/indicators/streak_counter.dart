import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_typography.dart';
import '../../../core/theme/app_spacing.dart';

class StreakCounter extends StatelessWidget {
  final int streakDays;
  final bool isCompact;

  const StreakCounter({
    super.key,
    required this.streakDays,
    this.isCompact = false,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(isCompact ? AppSpacing.sm : AppSpacing.md),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Fire emoji
          Text(
            '🔥',
            style: TextStyle(
              fontSize: isCompact ? 32 : 48,
              height: 1.0,
            ),
          ),
          const SizedBox(height: 4),
          // Streak number
          Text(
            '$streakDays',
            style: isCompact
                ? AppTypography.h1.copyWith(
                    color: AppColors.streakFire,
                  )
                : AppTypography.levelNumber.copyWith(
                    color: AppColors.streakFire,
                  ),
          ),
          const SizedBox(height: 4),
          // Label
          Text(
            streakDays == 1 ? 'day streak' : 'day streak',
            style: isCompact
                ? AppTypography.bodySmall
                : AppTypography.bodyDefault.copyWith(
                    color: AppColors.textSecondary,
                  ),
          ),
        ],
      ),
    );
  }
}
