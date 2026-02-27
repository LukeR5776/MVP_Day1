import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../../../core/theme/app_colors.dart';

/// Main record button with idle/recording states
class RecordButton extends StatefulWidget {
  final bool isRecording;
  final VoidCallback onTap;
  final bool isEnabled;

  const RecordButton({
    super.key,
    required this.isRecording,
    required this.onTap,
    this.isEnabled = true,
  });

  @override
  State<RecordButton> createState() => _RecordButtonState();
}

class _RecordButtonState extends State<RecordButton>
    with SingleTickerProviderStateMixin {
  late AnimationController _pulseController;
  bool _isPressed = false;

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1000),
    );
  }

  @override
  void didUpdateWidget(covariant RecordButton oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.isRecording && !oldWidget.isRecording) {
      _pulseController.repeat(reverse: true);
    } else if (!widget.isRecording && oldWidget.isRecording) {
      _pulseController.stop();
      _pulseController.reset();
    }
  }

  @override
  void dispose() {
    _pulseController.dispose();
    super.dispose();
  }

  void _handleTap() {
    if (!widget.isEnabled) return;
    HapticFeedback.mediumImpact();
    widget.onTap();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: widget.isEnabled ? (_) => setState(() => _isPressed = true) : null,
      onTapUp: widget.isEnabled ? (_) => setState(() => _isPressed = false) : null,
      onTapCancel: widget.isEnabled ? () => setState(() => _isPressed = false) : null,
      onTap: _handleTap,
      child: AnimatedBuilder(
        animation: _pulseController,
        builder: (context, child) {
          final pulseValue = widget.isRecording
              ? 1.0 + (_pulseController.value * 0.1)
              : 1.0;

          return AnimatedScale(
            scale: _isPressed ? 0.9 : pulseValue,
            duration: const Duration(milliseconds: 100),
            child: Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(
                  color: widget.isEnabled ? Colors.white : AppColors.textTertiary,
                  width: 4,
                ),
              ),
              padding: const EdgeInsets.all(6),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                decoration: BoxDecoration(
                  color: widget.isRecording
                      ? AppColors.streakFire
                      : widget.isEnabled
                          ? Colors.white
                          : AppColors.textTertiary,
                  borderRadius: BorderRadius.circular(
                    widget.isRecording ? 8 : 40,
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}

/// Recording timer display
class RecordingTimer extends StatelessWidget {
  final int seconds;
  final bool isRecording;

  const RecordingTimer({
    super.key,
    required this.seconds,
    this.isRecording = false,
  });

  @override
  Widget build(BuildContext context) {
    final minutes = seconds ~/ 60;
    final secs = seconds % 60;
    final timeString = '${minutes.toString().padLeft(2, '0')}:${secs.toString().padLeft(2, '0')}';

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        if (isRecording)
          Container(
            width: 8,
            height: 8,
            decoration: const BoxDecoration(
              color: AppColors.streakFire,
              shape: BoxShape.circle,
            ),
          )
              .animate(onPlay: (c) => c.repeat())
              .fadeIn(duration: 500.ms)
              .then()
              .fadeOut(duration: 500.ms),
        if (isRecording) const SizedBox(width: 8),
        Text(
          timeString,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 18,
            fontWeight: FontWeight.w600,
            fontFeatures: [FontFeature.tabularFigures()],
          ),
        ),
      ],
    );
  }
}
