import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_typography.dart';
import '../../data/models/clip_type.dart';
import '../../data/models/daily_log.dart';

/// Horizontal selector for clip type with prompts
class ClipTypeSelector extends StatelessWidget {
  final ClipType selectedType;
  final DailyLog? dailyLog;
  final ValueChanged<ClipType> onTypeSelected;
  final Color habitColor;

  const ClipTypeSelector({
    super.key,
    required this.selectedType,
    this.dailyLog,
    required this.onTypeSelected,
    this.habitColor = AppColors.primary,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: AppColors.backgroundPrimary.withValues(alpha: 0.95),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Type pills
          Row(
            children: ClipType.values.map((type) {
              final isSelected = selectedType == type;
              final isRecorded = dailyLog?.hasClip(type) ?? false;

              return Expanded(
                child: GestureDetector(
                  onTap: () => onTypeSelected(type),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    margin: EdgeInsets.only(
                      right: type != ClipType.reflection ? 8 : 0,
                    ),
                    padding: const EdgeInsets.symmetric(
                      horizontal: AppSpacing.sm,
                      vertical: AppSpacing.sm,
                    ),
                    decoration: BoxDecoration(
                      color: isSelected
                          ? habitColor.withValues(alpha: 0.2)
                          : AppColors.backgroundSurface,
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(
                        color: isSelected ? habitColor : AppColors.borderSubtle,
                        width: isSelected ? 2 : 1,
                      ),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        if (isRecorded)
                          Icon(
                            Icons.check_circle,
                            color: AppColors.success,
                            size: 16,
                          )
                        else
                          Icon(
                            type.icon,
                            color: isSelected ? habitColor : AppColors.textTertiary,
                            size: 16,
                          ),
                        const SizedBox(width: 4),
                        Text(
                          type.displayName,
                          style: AppTypography.caption.copyWith(
                            color: isSelected
                                ? habitColor
                                : isRecorded
                                    ? AppColors.success
                                    : AppColors.textSecondary,
                            fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              );
            }).toList(),
          ),
          const SizedBox(height: AppSpacing.md),
          // Prompt text
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(AppSpacing.md),
            decoration: BoxDecoration(
              color: AppColors.backgroundCard,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Column(
              children: [
                Icon(
                  selectedType.icon,
                  color: habitColor,
                  size: 24,
                ),
                const SizedBox(height: AppSpacing.sm),
                Text(
                  selectedType.prompt,
                  style: AppTypography.bodyDefault.copyWith(
                    color: AppColors.textPrimary,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: AppSpacing.xs),
                Text(
                  selectedType.description,
                  style: AppTypography.caption.copyWith(
                    color: AppColors.textTertiary,
                  ),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
