import 'package:flutter/material.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
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
          // Streak icon
          Icon(
            LucideIcons.flame,
            size: isCompact ? 32 : 48,
            color: AppColors.streakFire,
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
            streakDays == 1 ? 'day streak' : 'day streaks',
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
