import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_typography.dart';
import '../../data/models/habit_enums.dart';

/// Frequency picker widget for habit creation
class FrequencyPicker extends StatelessWidget {
  final HabitFrequency? selectedFrequency;
  final ValueChanged<HabitFrequency> onFrequencySelected;

  const FrequencyPicker({
    super.key,
    this.selectedFrequency,
    required this.onFrequencySelected,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Frequency',
          style: AppTypography.h4.copyWith(
            color: AppColors.textSecondary,
          ),
        ),
        const SizedBox(height: AppSpacing.md),
        ...HabitFrequency.values
            .where((f) => f != HabitFrequency.custom) // Hide custom for MVP
            .map((frequency) {
          return Padding(
            padding: const EdgeInsets.only(bottom: AppSpacing.sm),
            child: _FrequencyOption(
              frequency: frequency,
              isSelected: selectedFrequency == frequency,
              onTap: () => onFrequencySelected(frequency),
            ),
          );
        }),
      ],
    );
  }
}

class _FrequencyOption extends StatefulWidget {
  final HabitFrequency frequency;
  final bool isSelected;
  final VoidCallback onTap;

  const _FrequencyOption({
    required this.frequency,
    required this.isSelected,
    required this.onTap,
  });

  @override
  State<_FrequencyOption> createState() => _FrequencyOptionState();
}

class _FrequencyOptionState extends State<_FrequencyOption> {
  bool _isPressed = false;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: (_) => setState(() => _isPressed = true),
      onTapUp: (_) => setState(() => _isPressed = false),
      onTapCancel: () => setState(() => _isPressed = false),
      onTap: widget.onTap,
      child: AnimatedScale(
        scale: _isPressed ? 0.98 : 1.0,
        duration: const Duration(milliseconds: 100),
        curve: Curves.easeOut,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.all(AppSpacing.md),
          decoration: BoxDecoration(
            color: widget.isSelected
                ? AppColors.primary.withValues(alpha: 0.15)
                : AppColors.backgroundCard,
            borderRadius: BorderRadius.circular(AppSpacing.buttonRadius),
            border: Border.all(
              color: widget.isSelected
                  ? AppColors.primary
                  : AppColors.borderSubtle,
              width: widget.isSelected ? 2 : 1,
            ),
          ),
          child: Row(
            children: [
              AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                width: 24,
                height: 24,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: widget.isSelected
                      ? AppColors.primary
                      : Colors.transparent,
                  border: Border.all(
                    color: widget.isSelected
                        ? AppColors.primary
                        : AppColors.textTertiary,
                    width: 2,
                  ),
                ),
                child: widget.isSelected
                    ? const Icon(
                        Icons.check,
                        color: Colors.white,
                        size: 16,
                      )
                    : null,
              ),
              const SizedBox(width: AppSpacing.md),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      widget.frequency.displayName,
                      style: AppTypography.bodyLarge.copyWith(
                        color: widget.isSelected
                            ? AppColors.textPrimary
                            : AppColors.textPrimary,
                        fontWeight: widget.isSelected
                            ? FontWeight.w600
                            : FontWeight.normal,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      widget.frequency.description,
                      style: AppTypography.caption.copyWith(
                        color: AppColors.textTertiary,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
