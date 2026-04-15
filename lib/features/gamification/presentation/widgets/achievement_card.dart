import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../shared/widgets/cards/base_card.dart';
import '../../data/models/achievement.dart';

/// Displays a single achievement in locked or unlocked state.
class AchievementCard extends StatelessWidget {
  final Achievement achievement;
  final bool isUnlocked;
  final VoidCallback? onTap;

  const AchievementCard({
    super.key,
    required this.achievement,
    required this.isUnlocked,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return BaseCard(
      accentColor: isUnlocked ? achievement.rarity.color : AppColors.borderDefault,
      onTap: onTap,
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.md,
        vertical: AppSpacing.md,
      ),
      child: isUnlocked ? _UnlockedContent(achievement: achievement) : _LockedContent(achievement: achievement),
    );
  }
}

class _UnlockedContent extends StatelessWidget {
  final Achievement achievement;
  const _UnlockedContent({required this.achievement});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              achievement.emoji,
              style: const TextStyle(fontSize: 28),
            ),
            // XP badge
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
              decoration: BoxDecoration(
                color: AppColors.xpGold.withValues(alpha: 0.15),
                borderRadius: BorderRadius.circular(6),
              ),
              child: Text(
                '+${achievement.xpReward} XP',
                style: AppTypography.caption.copyWith(
                  color: AppColors.xpGold,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: AppSpacing.sm),
        Text(
          achievement.title,
          style: AppTypography.h4.copyWith(color: AppColors.textPrimary),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
        const SizedBox(height: 2),
        // Rarity chip
        _RarityChip(rarity: achievement.rarity),
      ],
    );
  }
}

class _LockedContent extends StatelessWidget {
  final Achievement achievement;
  const _LockedContent({required this.achievement});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            ColorFiltered(
              colorFilter: const ColorFilter.matrix(<double>[
                0.2126, 0.7152, 0.0722, 0, 0,
                0.2126, 0.7152, 0.0722, 0, 0,
                0.2126, 0.7152, 0.0722, 0, 0,
                0,      0,      0,      0.4, 0,
              ]),
              child: Text(
                achievement.emoji,
                style: const TextStyle(fontSize: 28),
              ),
            ),
            const Icon(
              Icons.lock_outline_rounded,
              color: AppColors.textTertiary,
              size: 16,
            ),
          ],
        ),
        const SizedBox(height: AppSpacing.sm),
        Text(
          achievement.title,
          style: AppTypography.h4.copyWith(color: AppColors.textTertiary),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
        const SizedBox(height: 2),
        _RarityChip(rarity: achievement.rarity, locked: true),
      ],
    );
  }
}

class _RarityChip extends StatelessWidget {
  final AchievementRarity rarity;
  final bool locked;

  const _RarityChip({required this.rarity, this.locked = false});

  @override
  Widget build(BuildContext context) {
    final color = locked ? AppColors.textTertiary : rarity.color;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        border: Border.all(color: color.withValues(alpha: 0.5)),
        borderRadius: BorderRadius.circular(4),
      ),
      child: Text(
        rarity.displayName.toUpperCase(),
        style: AppTypography.caption.copyWith(
          color: color,
          fontSize: 10,
          fontWeight: FontWeight.w700,
          letterSpacing: 0.5,
        ),
      ),
    );
  }
}
