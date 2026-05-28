import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../data/models/user_progress.dart';

/// Full-screen overlay shown when the user levels up.
/// Dismiss by tapping anywhere.
class LevelUpOverlay extends StatelessWidget {
  final int level;

  const LevelUpOverlay({super.key, required this.level});

  /// Show the overlay as a dialog. Awaiting this returns when dismissed.
  static Future<void> show(BuildContext context, {required int level}) {
    return showDialog(
      context: context,
      barrierColor: Colors.black87,
      barrierDismissible: true,
      builder: (_) => LevelUpOverlay(level: level),
    );
  }

  @override
  Widget build(BuildContext context) {
    final title = _levelTitle(level);

    return GestureDetector(
      onTap: () => Navigator.of(context).pop(),
      child: Material(
        color: Colors.transparent,
        child: SafeArea(
          child: Center(
            child: Padding(
              padding: const EdgeInsets.all(AppSpacing.xl),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // Celebration icons
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(LucideIcons.star, size: 24, color: AppColors.xpGold)
                          .animate()
                          .fadeIn(delay: 200.ms)
                          .slideY(begin: -0.5, end: 0),
                      const SizedBox(width: 16),
                      const Icon(LucideIcons.partyPopper, size: 32, color: Colors.white)
                          .animate()
                          .fadeIn(delay: 300.ms)
                          .slideY(begin: -0.5, end: 0),
                      const SizedBox(width: 16),
                      const Icon(LucideIcons.sparkles, size: 24, color: AppColors.levelPurple)
                          .animate()
                          .fadeIn(delay: 400.ms)
                          .slideY(begin: -0.5, end: 0),
                    ],
                  ),
                  const SizedBox(height: AppSpacing.lg),

                  // "LEVEL UP!" label
                  Text(
                    'LEVEL UP!',
                    style: AppTypography.h2.copyWith(
                      color: AppColors.levelPurple,
                      letterSpacing: 2,
                    ),
                  )
                      .animate()
                      .fadeIn(duration: 300.ms)
                      .slideY(begin: 0.3, end: 0),

                  const SizedBox(height: AppSpacing.md),

                  // Level number — big and bold
                  Text(
                    '$level',
                    style: const TextStyle(
                      fontSize: 96,
                      fontWeight: FontWeight.w900,
                      color: AppColors.textPrimary,
                      height: 1,
                    ),
                  )
                      .animate()
                      .scale(
                        duration: 600.ms,
                        curve: Curves.elasticOut,
                        begin: const Offset(0.3, 0.3),
                        end: const Offset(1.0, 1.0),
                      )
                      .fadeIn(duration: 200.ms),

                  const SizedBox(height: AppSpacing.sm),

                  // Level title
                  Text(
                    title,
                    style: AppTypography.h3.copyWith(
                      color: AppColors.textSecondary,
                    ),
                  )
                      .animate()
                      .fadeIn(duration: 400.ms, delay: 400.ms),

                  const SizedBox(height: AppSpacing.xl),

                  // Tap hint
                  Text(
                    'Tap to continue',
                    style: AppTypography.caption.copyWith(
                      color: AppColors.textTertiary,
                    ),
                  )
                      .animate()
                      .fadeIn(delay: 800.ms),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  static String _levelTitle(int level) {
    return UserProgress(totalXP: UserProgress.xpThresholdForLevel(level))
        .levelTitle;
  }
}
