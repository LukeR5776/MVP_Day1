import 'dart:io';
import 'dart:typed_data';
import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../recording/data/models/vlog.dart';

/// A branded share card showing vlog info, designed for social sharing.
///
/// Usage: call [VlogShareBottomSheet.show] from any widget to present
/// the share options modal. The card inside can be captured as an image.
class VlogShareCard extends StatelessWidget {
  final Vlog vlog;
  final Color categoryColor;
  final String categoryEmoji;

  const VlogShareCard({
    super.key,
    required this.vlog,
    required this.categoryColor,
    required this.categoryEmoji,
  });

  String _formatDate(DateTime date) {
    const months = [
      'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
      'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec',
    ];
    return '${months[date.month - 1]} ${date.day}, ${date.year}';
  }

  @override
  Widget build(BuildContext context) {
    return AspectRatio(
      aspectRatio: 1,
      child: Container(
        decoration: BoxDecoration(
          color: AppColors.backgroundPrimary,
          borderRadius: BorderRadius.circular(20),
        ),
        clipBehavior: Clip.antiAlias,
        child: Stack(
          children: [
            // Category color radial glow background
            Positioned.fill(
              child: CustomPaint(
                painter: _RadialGlowPainter(color: categoryColor),
              ),
            ),

            // Content
            Padding(
              padding: const EdgeInsets.all(AppSpacing.lg),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Top row: DAY1 wordmark + emoji
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'DAY1',
                        style: AppTypography.h4.copyWith(
                          color: AppColors.textPrimary,
                          fontWeight: FontWeight.w900,
                          letterSpacing: 2,
                        ),
                      ),
                      Text(
                        categoryEmoji,
                        style: const TextStyle(fontSize: 24),
                      ),
                    ],
                  ),

                  const Spacer(),

                  // Day number — hero text
                  Text(
                    'Day ${vlog.dayNumber}',
                    style: AppTypography.dayCounter.copyWith(
                      color: AppColors.textPrimary,
                      fontSize: 64,
                    ),
                  ),

                  const SizedBox(height: 4),

                  // Habit name
                  Text(
                    vlog.habitName,
                    style: AppTypography.h3.copyWith(
                      color: categoryColor,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),

                  const SizedBox(height: AppSpacing.lg),

                  // Duration + date row
                  Row(
                    children: [
                      _Pill(
                        icon: Icons.play_circle_outline_rounded,
                        label: vlog.formattedDuration,
                        color: categoryColor,
                      ),
                      const SizedBox(width: AppSpacing.sm),
                      _Pill(
                        icon: Icons.calendar_today_rounded,
                        label: _formatDate(vlog.date),
                        color: AppColors.textTertiary,
                      ),
                    ],
                  ),

                  const SizedBox(height: AppSpacing.md),

                  // Divider + tagline
                  Container(
                    height: 1,
                    color: AppColors.borderSubtle,
                  ),
                  const SizedBox(height: AppSpacing.sm),
                  Text(
                    'day1app.com',
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
    );
  }
}

/// Small pill badge used inside the share card.
class _Pill extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;

  const _Pill({
    required this.icon,
    required this.label,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: AppColors.backgroundCard,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.borderSubtle),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 12, color: color),
          const SizedBox(width: 4),
          Text(
            label,
            style: AppTypography.caption.copyWith(color: color),
          ),
        ],
      ),
    );
  }
}

/// Paints a radial gradient glow from the top-left corner.
class _RadialGlowPainter extends CustomPainter {
  final Color color;

  _RadialGlowPainter({required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..shader = RadialGradient(
        center: Alignment.topRight,
        radius: 1.4,
        colors: [
          color.withValues(alpha: 0.2),
          color.withValues(alpha: 0.0),
        ],
      ).createShader(Offset.zero & size);

    canvas.drawRect(Offset.zero & size, paint);
  }

  @override
  bool shouldRepaint(_RadialGlowPainter oldDelegate) =>
      oldDelegate.color != color;
}

/// Bottom sheet that shows the share card preview and share actions.
///
/// Call [VlogShareBottomSheet.show] to present it.
class VlogShareBottomSheet extends StatefulWidget {
  final Vlog vlog;
  final Color categoryColor;
  final String categoryEmoji;
  final VoidCallback onMarkShared;

  const VlogShareBottomSheet({
    super.key,
    required this.vlog,
    required this.categoryColor,
    required this.categoryEmoji,
    required this.onMarkShared,
  });

  /// Presents the share bottom sheet.
  static Future<void> show(
    BuildContext context, {
    required Vlog vlog,
    required Color categoryColor,
    required String categoryEmoji,
    required VoidCallback onMarkShared,
  }) {
    return showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => VlogShareBottomSheet(
        vlog: vlog,
        categoryColor: categoryColor,
        categoryEmoji: categoryEmoji,
        onMarkShared: onMarkShared,
      ),
    );
  }

  @override
  State<VlogShareBottomSheet> createState() => _VlogShareBottomSheetState();
}

class _VlogShareBottomSheetState extends State<VlogShareBottomSheet> {
  final _cardKey = GlobalKey();
  bool _isCapturing = false;

  /// Captures the share card as a PNG and shares it.
  Future<void> _shareCard() async {
    if (_isCapturing) return;
    setState(() => _isCapturing = true);

    try {
      final boundary =
          _cardKey.currentContext?.findRenderObject() as RenderRepaintBoundary?;
      if (boundary == null) throw Exception('Could not find card boundary');

      // Capture at 3× pixel ratio for crisp output
      final image = await boundary.toImage(pixelRatio: 3.0);
      final byteData = await image.toByteData(format: ui.ImageByteFormat.png);
      if (byteData == null) throw Exception('Could not encode card as PNG');

      final Uint8List pngBytes = byteData.buffer.asUint8List();

      final tempDir = await getTemporaryDirectory();
      final fileName =
          'day1_card_${widget.vlog.habitName.replaceAll(' ', '_')}_day${widget.vlog.dayNumber}.png';
      final tempFile = File('${tempDir.path}/$fileName');
      await tempFile.writeAsBytes(pngBytes);

      if (!mounted) return;
      Navigator.of(context).pop();

      await Share.shareXFiles(
        [XFile(tempFile.path)],
        text: 'Day ${widget.vlog.dayNumber} of ${widget.vlog.habitName} 🎬 #Day1',
      );

      widget.onMarkShared();
    } catch (e) {
      debugPrint('❌ Error sharing card: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to share card: $e'),
            backgroundColor: AppColors.streakFire,
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _isCapturing = false);
    }
  }

  /// Shares the raw video file.
  Future<void> _shareVideo() async {
    Navigator.of(context).pop();

    try {
      await Share.shareXFiles(
        [XFile(widget.vlog.videoPath)],
        text: 'Day ${widget.vlog.dayNumber} - ${widget.vlog.habitName}',
      );
      widget.onMarkShared();
    } catch (e) {
      debugPrint('❌ Error sharing video: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: AppColors.backgroundCard,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      padding: const EdgeInsets.fromLTRB(
        AppSpacing.screenHorizontal,
        AppSpacing.md,
        AppSpacing.screenHorizontal,
        AppSpacing.lg,
      ),
      child: SafeArea(
        top: false,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Handle bar
            Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: AppColors.borderDefault,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(height: AppSpacing.md),

            // Title
            Text(
              'Share Your Progress',
              style: AppTypography.h3.copyWith(color: AppColors.textPrimary),
            ),
            const SizedBox(height: AppSpacing.md),

            // Card preview (captured via RepaintBoundary)
            RepaintBoundary(
              key: _cardKey,
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 300),
                child: VlogShareCard(
                  vlog: widget.vlog,
                  categoryColor: widget.categoryColor,
                  categoryEmoji: widget.categoryEmoji,
                ),
              ),
            ),

            const SizedBox(height: AppSpacing.lg),

            // Action buttons
            Row(
              children: [
                Expanded(
                  child: _ShareActionButton(
                    icon: Icons.image_rounded,
                    label: 'Share Card',
                    subtitle: 'Image for stories',
                    color: widget.categoryColor,
                    isLoading: _isCapturing,
                    onTap: _shareCard,
                  ),
                ),
                const SizedBox(width: AppSpacing.sm),
                Expanded(
                  child: _ShareActionButton(
                    icon: Icons.videocam_rounded,
                    label: 'Share Video',
                    subtitle: 'Full vlog .mp4',
                    color: AppColors.textSecondary,
                    isLoading: false,
                    onTap: _shareVideo,
                  ),
                ),
              ],
            ),

            const SizedBox(height: AppSpacing.sm),

            // Cancel
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text(
                'Cancel',
                style: AppTypography.buttonText.copyWith(
                  color: AppColors.textTertiary,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Tappable action button inside the share bottom sheet.
class _ShareActionButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final String subtitle;
  final Color color;
  final bool isLoading;
  final VoidCallback onTap;

  const _ShareActionButton({
    required this.icon,
    required this.label,
    required this.subtitle,
    required this.color,
    required this.isLoading,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: isLoading ? null : onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(
          vertical: AppSpacing.md,
          horizontal: AppSpacing.sm,
        ),
        decoration: BoxDecoration(
          color: AppColors.backgroundSurface,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: AppColors.borderSubtle),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            isLoading
                ? SizedBox(
                    width: 24,
                    height: 24,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: color,
                    ),
                  )
                : Icon(icon, color: color, size: 28),
            const SizedBox(height: 6),
            Text(
              label,
              style: AppTypography.bodySmall.copyWith(
                color: AppColors.textPrimary,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 2),
            Text(
              subtitle,
              style: AppTypography.caption.copyWith(
                color: AppColors.textTertiary,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
