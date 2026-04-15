import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../data/models/achievement.dart';

/// Slide-up toast shown when an achievement is unlocked.
///
/// Auto-dismisses after 3 seconds or when tapped.
/// Use [AchievementToast.show] to display it as a dialog.
class AchievementToast extends StatefulWidget {
  final Achievement achievement;

  const AchievementToast({super.key, required this.achievement});

  /// Show the toast as a dialog. Awaiting returns when dismissed.
  static Future<void> show(BuildContext context, Achievement achievement) {
    return showDialog(
      context: context,
      barrierColor: Colors.transparent,
      barrierDismissible: true,
      builder: (_) => AchievementToast(achievement: achievement),
    );
  }

  @override
  State<AchievementToast> createState() => _AchievementToastState();
}

class _AchievementToastState extends State<AchievementToast> {
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _timer = Timer(const Duration(seconds: 3), () {
      if (mounted && Navigator.canPop(context)) {
        Navigator.of(context).pop();
      }
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.bottomCenter,
      child: Padding(
        padding: const EdgeInsets.only(
          left: AppSpacing.screenHorizontal,
          right: AppSpacing.screenHorizontal,
          bottom: 100,
        ),
        child: GestureDetector(
          onTap: () => Navigator.of(context).pop(),
          child: Material(
            color: Colors.transparent,
            child: Container(
              decoration: BoxDecoration(
                color: AppColors.backgroundCard,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: widget.achievement.rarity.color.withValues(alpha: 0.5),
                ),
                boxShadow: [
                  BoxShadow(
                    color: widget.achievement.rarity.color.withValues(alpha: 0.2),
                    blurRadius: 20,
                    spreadRadius: 2,
                  ),
                ],
              ),
              padding: const EdgeInsets.symmetric(
                horizontal: AppSpacing.md,
                vertical: AppSpacing.md,
              ),
              child: Row(
                children: [
                  // Emoji
                  Text(
                    widget.achievement.emoji,
                    style: const TextStyle(fontSize: 32),
                  ),
                  const SizedBox(width: AppSpacing.md),

                  // Text
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          'Achievement Unlocked!',
                          style: AppTypography.caption.copyWith(
                            color: widget.achievement.rarity.color,
                            fontWeight: FontWeight.w700,
                            letterSpacing: 0.5,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          widget.achievement.title,
                          style: AppTypography.h4.copyWith(
                            color: AppColors.textPrimary,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          '+${widget.achievement.xpReward} XP',
                          style: AppTypography.caption.copyWith(
                            color: AppColors.xpGold,
                          ),
                        ),
                      ],
                    ),
                  ),

                  // Rarity chip
                  _RarityChip(rarity: widget.achievement.rarity),
                ],
              ),
            )
                .animate()
                .slideY(begin: 1.0, end: 0, duration: 350.ms, curve: Curves.easeOut)
                .fadeIn(duration: 200.ms),
          ),
        ),
      ),
    );
  }
}

class _RarityChip extends StatelessWidget {
  final AchievementRarity rarity;
  const _RarityChip({required this.rarity});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: rarity.color.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: rarity.color.withValues(alpha: 0.4)),
      ),
      child: Text(
        rarity.displayName.toUpperCase(),
        style: AppTypography.caption.copyWith(
          color: rarity.color,
          fontSize: 10,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }
}
