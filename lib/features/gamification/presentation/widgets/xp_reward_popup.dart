import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../shared/widgets/indicators/xp_bar.dart';
import '../../data/models/user_progress.dart';
import '../../providers/gamification_provider.dart';

/// Inline XP reward display shown inside the completion dialog.
///
/// Shows the XP awarded, streak multiplier (if any), and the user's updated
/// level progress bar.
class XpRewardPopup extends StatelessWidget {
  final GamificationResult result;
  final UserProgress updatedProgress;

  const XpRewardPopup({
    super.key,
    required this.result,
    required this.updatedProgress,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        // Divider
        Container(
          height: 1,
          color: AppColors.divider,
          margin: const EdgeInsets.symmetric(vertical: AppSpacing.md),
        ),

        // "+X XP" label
        Text(
          '+${result.xpAwarded} XP',
          style: AppTypography.h1.copyWith(
            color: AppColors.xpGold,
            fontSize: 40,
            fontWeight: FontWeight.w800,
          ),
        )
            .animate()
            .scale(duration: 400.ms, curve: Curves.elasticOut)
            .fadeIn(duration: 200.ms),

        const SizedBox(height: AppSpacing.xs),

        // Streak multiplier row
        if (result.streakMultiplier > 1.0)
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Text('🔥', style: TextStyle(fontSize: 14)),
              const SizedBox(width: 4),
              Text(
                '${result.newStreak}-day streak  ·  ${_formatMultiplier(result.streakMultiplier)} bonus',
                style: AppTypography.bodySmall.copyWith(
                  color: AppColors.textSecondary,
                ),
              ),
            ],
          ).animate().fadeIn(duration: 300.ms, delay: 200.ms),

        const SizedBox(height: AppSpacing.md),

        // Level + XP bar
        Container(
          padding: const EdgeInsets.all(AppSpacing.md),
          decoration: BoxDecoration(
            color: AppColors.backgroundSurface,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Level ${updatedProgress.level}',
                    style: AppTypography.h4.copyWith(
                      color: AppColors.textPrimary,
                    ),
                  ),
                  Text(
                    updatedProgress.levelTitle,
                    style: AppTypography.caption.copyWith(
                      color: AppColors.levelPurple,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: AppSpacing.sm),
              XPBar(
                currentXP: updatedProgress.xpProgressInCurrentLevel,
                maxXP: updatedProgress.xpNeededForNextLevel,
              ),
              const SizedBox(height: 4),
              Text(
                '${updatedProgress.xpProgressInCurrentLevel} / ${updatedProgress.xpNeededForNextLevel} XP',
                style: AppTypography.caption.copyWith(
                  color: AppColors.textTertiary,
                ),
              ),
            ],
          ),
        ).animate().fadeIn(duration: 400.ms, delay: 300.ms),
      ],
    );
  }

  String _formatMultiplier(double m) {
    if (m == m.truncateToDouble()) return '${m.toInt()}x';
    return '${m}x';
  }
}
