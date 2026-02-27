import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';

class XPBar extends StatelessWidget {
  final int currentXP;
  final int maxXP;
  final double height;
  final bool showLabel;

  const XPBar({
    super.key,
    required this.currentXP,
    required this.maxXP,
    this.height = 8.0,
    this.showLabel = false,
  });

  @override
  Widget build(BuildContext context) {
    final progress = maxXP > 0 ? (currentXP / maxXP).clamp(0.0, 1.0) : 0.0;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (showLabel)
          Padding(
            padding: const EdgeInsets.only(bottom: 8),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Level Progress',
                  style: Theme.of(context).textTheme.bodySmall,
                ),
                Text(
                  '$currentXP / $maxXP XP',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: AppColors.xpGold,
                      ),
                ),
              ],
            ),
          ),
        ClipRRect(
          borderRadius: BorderRadius.circular(height / 2),
          child: Container(
            height: height,
            width: double.infinity,
            decoration: BoxDecoration(
              color: AppColors.backgroundSurface,
            ),
            child: Stack(
              children: [
                AnimatedContainer(
                  duration: const Duration(milliseconds: 500),
                  curve: Curves.easeOut,
                  width: MediaQuery.of(context).size.width * progress,
                  decoration: const BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        AppColors.xpGold,
                        AppColors.warning,
                      ],
                      begin: Alignment.centerLeft,
                      end: Alignment.centerRight,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
