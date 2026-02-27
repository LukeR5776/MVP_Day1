import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_spacing.dart';

class BaseCard extends StatefulWidget {
  final Widget child;
  final VoidCallback? onTap;
  final Color? accentColor;
  final EdgeInsets? padding;

  const BaseCard({
    super.key,
    required this.child,
    this.onTap,
    this.accentColor,
    this.padding,
  });

  @override
  State<BaseCard> createState() => _BaseCardState();
}

class _BaseCardState extends State<BaseCard> {
  bool _isPressed = false;

  @override
  Widget build(BuildContext context) {
    final hasInteraction = widget.onTap != null;

    return GestureDetector(
      onTapDown: hasInteraction ? (_) => setState(() => _isPressed = true) : null,
      onTapUp: hasInteraction ? (_) => setState(() => _isPressed = false) : null,
      onTapCancel: hasInteraction ? () => setState(() => _isPressed = false) : null,
      onTap: widget.onTap,
      child: AnimatedScale(
        scale: _isPressed ? 0.98 : 1.0,
        duration: const Duration(milliseconds: 100),
        curve: Curves.easeOut,
        child: Container(
          decoration: BoxDecoration(
            color: AppColors.backgroundCard,
            borderRadius: BorderRadius.circular(AppSpacing.cardRadius),
            border: Border.all(
              color: AppColors.borderSubtle,
              width: 1,
            ),
          ),
          child: Row(
            children: [
              // Left accent border (optional)
              if (widget.accentColor != null)
                Container(
                  width: 4,
                  decoration: BoxDecoration(
                    color: widget.accentColor,
                    borderRadius: const BorderRadius.only(
                      topLeft: Radius.circular(AppSpacing.cardRadius),
                      bottomLeft: Radius.circular(AppSpacing.cardRadius),
                    ),
                  ),
                ),
              // Card content
              Expanded(
                child: Padding(
                  padding: widget.padding ??
                      const EdgeInsets.all(AppSpacing.cardPadding),
                  child: widget.child,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
