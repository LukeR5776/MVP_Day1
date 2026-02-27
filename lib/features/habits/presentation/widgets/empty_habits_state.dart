import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../shared/widgets/buttons/primary_button.dart';

/// Empty state widget when user has no habits
class EmptyHabitsState extends StatelessWidget {
  final VoidCallback onCreateHabit;

  const EmptyHabitsState({
    super.key,
    required this.onCreateHabit,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.xl),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Illustration
            Container(
              width: 120,
              height: 120,
              decoration: BoxDecoration(
                color: AppColors.primary.withValues(alpha: 0.1),
                shape: BoxShape.circle,
              ),
              child: const Center(
                child: Text(
                  '🌅',
                  style: TextStyle(fontSize: 56),
                ),
              ),
            )
                .animate(onPlay: (c) => c.repeat(reverse: true))
                .scale(
                  begin: const Offset(1, 1),
                  end: const Offset(1.05, 1.05),
                  duration: 2000.ms,
                  curve: Curves.easeInOut,
                )
                .then()
                .shimmer(
                  duration: 1500.ms,
                  color: AppColors.xpGold.withValues(alpha: 0.3),
                ),
            const SizedBox(height: AppSpacing.xl),
            // Headline
            Text(
              'Every journey starts\nwith Day 1',
              textAlign: TextAlign.center,
              style: AppTypography.h1.copyWith(
                color: AppColors.textPrimary,
                height: 1.2,
              ),
            )
                .animate()
                .fadeIn(duration: 600.ms)
                .slideY(begin: 0.2, end: 0),
            const SizedBox(height: AppSpacing.md),
            // Body text
            Text(
              'Create your first habit and start\ndocumenting your transformation',
              textAlign: TextAlign.center,
              style: AppTypography.bodyLarge.copyWith(
                color: AppColors.textSecondary,
                height: 1.5,
              ),
            )
                .animate()
                .fadeIn(duration: 600.ms, delay: 200.ms)
                .slideY(begin: 0.2, end: 0),
            const SizedBox(height: AppSpacing.xl),
            // CTA Button
            PrimaryButton(
              text: 'Create First Habit',
              icon: Icons.add,
              onPressed: onCreateHabit,
              fullWidth: false,
            )
                .animate()
                .fadeIn(duration: 600.ms, delay: 400.ms)
                .scale(begin: const Offset(0.8, 0.8), end: const Offset(1, 1)),
            const SizedBox(height: AppSpacing.lg),
            // Sub-hint
            Text(
              'It only takes 30 seconds',
              style: AppTypography.caption.copyWith(
                color: AppColors.textTertiary,
              ),
            )
                .animate()
                .fadeIn(duration: 600.ms, delay: 600.ms),
          ],
        ),
      ),
    );
  }
}
